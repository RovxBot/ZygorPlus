-- Compact WotLK gear advisor.  Item-ItemScore owns the client-era rules;
-- this module is strictly the presentation and interaction layer.
local addonName, addonNamespace = ...
local ZGV
if type(addonNamespace) == "table" then
  ZGV = addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV
end
if not ZGV then ZGV = _G.ZygorGuidesViewer end
if type(ZGV) ~= "table" then return end

local Gear = ZGV:RegisterModule("GearAdvisor", { rows = {}, pending = false })

local classRoles = {
  WARRIOR = "tank", PALADIN = "tank", DEATHKNIGHT = "tank",
  ROGUE = "melee", HUNTER = "melee", SHAMAN = "melee", DRUID = "melee",
  MAGE = "caster", WARLOCK = "caster", PRIEST = "healer",
}

local function profile()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.gear
end

function Gear:GetRole()
  local options = profile()
  if options and options.role and ({melee=true,caster=true,healer=true,tank=true})[options.role] then return options.role end
  if ZGV.ItemScore and ZGV.ItemScore:GetRule() then return ZGV.ItemScore:GetRule().role end
  local _, class = UnitClass("player")
  return classRoles[class] or "melee"
end

function Gear:Score(link)
  if not link or not ZGV.ItemScore then return 0 end
  local score=ZGV.ItemScore:GetItemScore(link)
  return tonumber(score) and math.max(0,score) or 0
end

function Gear:GetCandidateSlot(equipLocation)
  if not (ZGV.ItemScore and ZGV.ItemScore.Upgrades) then return nil,0 end
  local details={equipslot=equipLocation}
  return ZGV.ItemScore.Upgrades:GetReplacement(details)
end

function Gear:GetUpgrades()
  local options = profile()
  if not options or not options.enabled or not (ZGV.ItemScore and ZGV.ItemScore.Upgrades) then return {} end
  local service=ZGV.ItemScore.Upgrades
  service:ScanBagsForUpgrades()
  local upgrades = {}
  for _,entry in ipairs(service:GetUpgradeList()) do
    upgrades[#upgrades+1]={
      item=entry.item, slot=entry.slot, score=entry.score,
      equippedScore=entry.score-entry.delta, delta=entry.delta,
      equipLocation=entry.details.equipslot, raw=entry,
    }
  end
  return upgrades
end

function Gear:Notify(upgrades)
  local options = profile()
  local best = upgrades[1]
  if not options or not options.notifications or not best then return end
  local id = tostring(best.item.itemID or best.item.itemLink)
  if options.seen[id] then return end
  options.seen[id] = true
  ZGV:Fire("ZGV_NOTIFICATION", {
    title = "Gear upgrade found",
    message = best.item.name or best.item.itemLink or "An equipped upgrade is available.",
    kind = "reward",
    duration = 5,
  })
end

function Gear:Refresh()
  self.pending = false
  self.upgrades = self:GetUpgrades()
  self:Notify(self.upgrades)
  if self.frame and self.frame:IsShown() then self:Render() end
  ZGV:Fire("ZGV_GEAR_UPDATED", self.upgrades)
end

function Gear:QueueRefresh()
  if self.pending then return end
  self.pending = true
  if ZGV.Compat and ZGV.Compat.Timer then
    ZGV.Compat.Timer:After(.25, function() Gear:Refresh() end)
  else
    self:Refresh()
  end
end

local function makeText(parent, size)
  local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  local path, _, flags = GameFontNormal:GetFont()
  text:SetFont(path, size, flags)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("MIDDLE")
  return text
end

local function weightText(value)
  if value==nil then return "" end
  return ("%.3f"):format(value):gsub("0+$",""):gsub("%.$","")
end

-- Gear Manager is one of the stock frames shipped by the 3.3.5a client.  It
-- gives the advisor and its editor the same framed treatment as the original
-- Classic popouts without depending on the newer addon's white placeholder
-- texture or any post-Wrath skin APIs.
local function makeGearManagerBorder(frame)
  local title=frame:CreateTexture(nil,"BACKGROUND")
  title:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",9,-6)
  title:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",-4,-25)

  local background=frame:CreateTexture(nil,"BACKGROUND")
  background:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
  background:SetPoint("TOPLEFT",frame,"TOPLEFT",8,-24)
  background:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-6,8)
  background:SetVertexColor(0,0,0,.9)

  local function piece(width,height,point,relativePoint,x,y,left,right,top,bottom,secondPoint,secondRelative,x2,y2)
    local texture=frame:CreateTexture(nil,"BORDER")
    texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    texture:SetWidth(width)
    texture:SetHeight(height)
    texture:SetPoint(point,frame,relativePoint,x,y)
    if secondPoint then texture:SetPoint(secondPoint,frame,secondRelative,x2,y2) end
    texture:SetTexCoord(left,right,top,bottom)
  end
  piece(64,64,"TOPLEFT","TOPLEFT",0,0,.501953125,.625,0,1)
  piece(64,64,"TOPRIGHT","TOPRIGHT",0,0,.625,.75,0,1)
  piece(1,64,"TOPLEFT","TOPLEFT",64,0,.25,.369140625,0,1,"TOPRIGHT","TOPRIGHT",-64,0)
  piece(64,64,"BOTTOMLEFT","BOTTOMLEFT",0,0,.751953125,.875,0,1)
  piece(64,64,"BOTTOMRIGHT","BOTTOMRIGHT",0,0,.875,1,0,1)
  piece(1,64,"BOTTOMLEFT","BOTTOMLEFT",64,0,.376953125,.498046875,0,1,"BOTTOMRIGHT","BOTTOMRIGHT",-64,0)
  piece(64,1,"TOPLEFT","TOPLEFT",0,-64,.001953125,.125,0,1,"BOTTOMLEFT","BOTTOMLEFT",0,64)
  piece(64,1,"TOPRIGHT","TOPRIGHT",0,-64,.1171875,.2421875,0,1,"BOTTOMRIGHT","BOTTOMRIGHT",0,64)
end

function Gear:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "ZygorGuidesViewerGearAdvisor", UIParent)
  frame:SetWidth(350)
  frame:SetHeight(286)
  frame:SetPoint("CENTER", UIParent, "CENTER", 230, 30)
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  makeGearManagerBorder(frame)
  frame:Hide()
  self.frame = frame

  local logo = frame:CreateTexture(nil, "ARTWORK")
  logo:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -9)
  logo:SetWidth(22)
  logo:SetHeight(22)
  logo:SetTexture(ZGV.SKINDIR .. "gear-logo-64")
  self.logo = logo

  local title = makeText(frame, 14)
  title:SetPoint("LEFT", logo, "RIGHT", 7, 0)
  title:SetText("Gear Advisor")
  self.title = title

  local role = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  role:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -34, -8)
  role:SetWidth(82)
  role:SetHeight(22)
  role:SetScript("OnClick", function() Gear:CycleRole() end)
  self.roleButton = role

  local weights = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  weights:SetPoint("RIGHT", role, "LEFT", -5, 0)
  weights:SetWidth(74)
  weights:SetHeight(22)
  weights:SetText("Weights")
  weights:SetScript("OnClick", function() Gear:ShowWeightEditor() end)
  self.weightsButton = weights

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
  close:SetScript("OnClick", function() frame:Hide() end)

  for index = 1, 7 do
    local row = CreateFrame("Button", nil, frame)
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -42 - (index - 1) * 31)
    row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -42 - (index - 1) * 31)
    row:SetHeight(28)
    row:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white" })
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("LEFT", row, "LEFT", 4, 0)
    icon:SetWidth(22)
    icon:SetHeight(22)
    row.icon = icon
    local text = makeText(row, 11)
    text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.text = text
    row:SetScript("OnEnter", function(self)
      if self.upgrade and self.upgrade.item.itemLink then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.upgrade.item.itemLink)
        GameTooltip:AddLine("Right-click to equip this item.", .7, .8, 1)
        GameTooltip:Show()
      end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:SetScript("OnClick", function(self, button)
      if button == "RightButton" and self.upgrade and not (InCombatLockdown and InCombatLockdown()) then
        local upgrades=ZGV.ItemScore and ZGV.ItemScore.Upgrades
        if upgrades then upgrades:EquipFromBags(self.upgrade.raw) end
      end
    end)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:Hide()
    self.rows[index] = row
  end
  return frame
end

function Gear:CycleRole()
  local order = { "melee", "caster", "healer", "tank" }
  local options = profile()
  if not options then return end
  local current = self:GetRole()
  local index = 1
  for i, role in ipairs(order) do if role == current then index = i break end end
  options.role = order[index % #order + 1]
  options.seen = {}
  if ZGV.ItemScore then ZGV.ItemScore:SetFilters() end
  self:Refresh()
end

function Gear:CreateWeightEditor()
  if self.weightFrame then return self.weightFrame end
  if type(CreateFrame)~="function" then return nil end
  local score=ZGV.ItemScore
  local order=score and score.CustomWeightOrder or {}
  local labels=score and score.CustomWeightLabels or {}
  local frame=CreateFrame("Frame","ZygorGuidesViewerGearWeights",UIParent)
  frame:SetWidth(520)
  frame:SetHeight(480)
  frame:SetPoint("CENTER",UIParent,"CENTER",255,20)
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
  makeGearManagerBorder(frame)
  frame:Hide()
  self.weightFrame=frame

  local title=makeText(frame,14)
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",14,-13)
  title:SetText("WoWSims Custom Stat Weights")
  local hint=makeText(frame,10)
  hint:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-4)
  hint:SetPoint("RIGHT",frame,"RIGHT",-34,0)
  hint:SetText("Profile-specific values used by Gear Advisor and Find Upgrades.")
  hint:SetTextColor(.72,.72,.72)

  local content=CreateFrame("Frame",nil,frame)
  content:SetPoint("TOPLEFT",frame,"TOPLEFT",13,-48)
  content:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-13,13)
  content:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=10,insets={left=2,right=2,top=2,bottom=2}})
  content:SetBackdropColor(.035,.035,.035,.94)
  content:SetBackdropBorderColor(.48,.36,.16,.75)
  frame.content=content

  local importLabel=makeText(content,10)
  importLabel:SetPoint("TOPLEFT",content,"TOPLEFT",12,-10)
  importLabel:SetText("Import from WoWSims")
  importLabel:SetTextColor(1,.82,.25)

  local import=CreateFrame("EditBox",nil,content,"InputBoxTemplate")
  import:SetPoint("TOPLEFT",importLabel,"BOTTOMLEFT",2,-5)
  import:SetWidth(390)
  import:SetHeight(20)
  import:SetAutoFocus(false)
  import:SetMaxLetters(255)
  frame.import=import
  local apply=CreateFrame("Button",nil,content,"UIPanelButtonTemplate")
  apply:SetPoint("LEFT",import,"RIGHT",8,0)
  apply:SetWidth(82)
  apply:SetHeight(22)
  apply:SetText("Apply")
  local importStatus=makeText(content,10)
  importStatus:SetPoint("TOPLEFT",import,"BOTTOMLEFT",0,-4)
  importStatus:SetPoint("TOPRIGHT",content,"TOPRIGHT",-12,-4)
  importStatus:SetHeight(14)
  importStatus:SetText("Use semicolon-separated values, e.g. Melee Hit=1.38; MH DPS=5.21.")
  importStatus:SetTextColor(.72,.72,.72)
  frame.importStatus=importStatus

  local headerY=-67
  for column=0,1 do
    local x=12+column*246
    local statHeader=makeText(content,10)
    statHeader:SetPoint("TOPLEFT",content,"TOPLEFT",x,headerY)
    statHeader:SetWidth(139)
    statHeader:SetText("STAT")
    statHeader:SetTextColor(1,.82,.25)
    local weightHeader=makeText(content,10)
    weightHeader:SetPoint("TOPLEFT",content,"TOPLEFT",x+142,headerY)
    weightHeader:SetWidth(49)
    weightHeader:SetJustifyH("CENTER")
    weightHeader:SetText("VALUE")
    weightHeader:SetTextColor(1,.82,.25)
    local defaultHeader=makeText(content,10)
    defaultHeader:SetPoint("TOPLEFT",content,"TOPLEFT",x+195,headerY)
    defaultHeader:SetWidth(39)
    defaultHeader:SetJustifyH("CENTER")
    defaultHeader:SetText("BASE")
    defaultHeader:SetTextColor(.65,.65,.65)
  end
  local divider=content:CreateTexture(nil,"ARTWORK")
  divider:SetTexture("Interface\\Buttons\\WHITE8X8")
  divider:SetVertexColor(.65,.48,.18,.4)
  divider:SetPoint("TOPLEFT",content,"TOPLEFT",12,headerY-18)
  divider:SetPoint("TOPRIGHT",content,"TOPRIGHT",-12,headerY-18)
  divider:SetHeight(1)

  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
  close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,2)
  close:SetScript("OnClick",function() frame:Hide() end)
  frame.inputs={}
  for index,stat in ipairs(order) do
    local column=(index-1)%2
    local row=math.floor((index-1)/2)
    local x=12+column*246
    local y=-94-row*27
    local stripe=content:CreateTexture(nil,"BACKGROUND")
    stripe:SetTexture("Interface\\Buttons\\WHITE8X8")
    stripe:SetPoint("TOPLEFT",content,"TOPLEFT",x-3,y+3)
    stripe:SetWidth(238)
    stripe:SetHeight(23)
    stripe:SetVertexColor(1,1,1,row%2==0 and .045 or .018)
    local label=makeText(content,11)
    label:SetPoint("TOPLEFT",content,"TOPLEFT",x,y)
    label:SetWidth(138)
    label:SetText(labels[stat] or stat)
    local input=CreateFrame("EditBox",nil,content,"InputBoxTemplate")
    input:SetPoint("TOPLEFT",content,"TOPLEFT",x+142,y+3)
    input:SetWidth(49)
    input:SetHeight(19)
    input:SetAutoFocus(false)
    input:SetMaxLetters(7)
    input.stat=stat
    local function commit(edit)
      local itemScore=ZGV.ItemScore
      if not itemScore then return end
      local ok=itemScore:SetCustomWeight(edit.stat,edit:GetText())
      if ok then
        edit:SetText(weightText(itemScore:GetEffectiveWeight(edit.stat)))
        edit.default:SetText(weightText(itemScore:GetDefaultWeight(edit.stat)))
        Gear:Refresh()
      end
      edit:ClearFocus()
    end
    input:SetScript("OnEnterPressed",commit)
    input:SetScript("OnEditFocusLost",commit)
    input:SetScript("OnEscapePressed",function(edit)
      local itemScore=ZGV.ItemScore
      if itemScore then edit:SetText(weightText(itemScore:GetEffectiveWeight(edit.stat))) end
      edit:ClearFocus()
    end)
    local default=makeText(content,10)
    default:SetPoint("LEFT",input,"RIGHT",5,0)
    default:SetWidth(39)
    default:SetJustifyH("CENTER")
    default:SetTextColor(.65,.65,.65)
    input.default=default
    frame.inputs[stat]=input
  end
  apply:SetScript("OnClick",function()
    local itemScore=ZGV.ItemScore
    local ok,count=itemScore and itemScore:ImportCustomWeights(import:GetText())
    if ok then
      importStatus:SetText(("Applied %d values"):format(count))
      importStatus:SetTextColor(.20,1,.20)
      Gear:RefreshWeightEditor()
      Gear:Refresh()
    else
      importStatus:SetText(count or "Nothing recognised")
      importStatus:SetTextColor(1,.28,.28)
    end
  end)
  import:SetScript("OnEnterPressed",function() apply:GetScript("OnClick")(apply) import:ClearFocus() end)
  local reset=CreateFrame("Button",nil,content,"UIPanelButtonTemplate")
  reset:SetPoint("BOTTOMLEFT",content,"BOTTOMLEFT",10,11)
  reset:SetWidth(162)
  reset:SetHeight(22)
  reset:SetText("Reset this profile")
  reset:SetScript("OnClick",function()
    if ZGV.ItemScore then ZGV.ItemScore:ResetCustomWeights() end
    Gear:RefreshWeightEditor()
    Gear:Refresh()
  end)
  local preset=CreateFrame("Button",nil,content,"UIPanelButtonTemplate")
  preset:SetPoint("LEFT",reset,"RIGHT",8,0)
  preset:SetWidth(166)
  preset:SetHeight(22)
  preset:SetText("Use WoWSims preset")
  preset:SetScript("OnClick",function()
    local itemScore=ZGV.ItemScore
    local ok,message=itemScore and itemScore:ApplyWoWSimsPreset()
    if ok then
      importStatus:SetText(message.." applied")
      importStatus:SetTextColor(.20,1,.20)
      Gear:RefreshWeightEditor()
      Gear:Refresh()
    else
      importStatus:SetText(message or "No preset available")
      importStatus:SetTextColor(1,.28,.28)
    end
  end)
  return frame
end

function Gear:RefreshWeightEditor()
  local frame=self.weightFrame
  local score=ZGV.ItemScore
  if not frame or not score then return end
  for stat,input in pairs(frame.inputs or {}) do
    input:SetText(weightText(score:GetEffectiveWeight(stat)))
    if input.default then input.default:SetText(weightText(score:GetDefaultWeight(stat))) end
  end
end

function Gear:ShowWeightEditor()
  local frame=self:CreateWeightEditor()
  if not frame then return false end
  self:RefreshWeightEditor()
  frame:Show()
  return true
end

function Gear:Render()
  local upgrades = self.upgrades or self:GetUpgrades()
  self.roleButton:SetText(self:GetRole():gsub("^%l", string.upper))
  for index, row in ipairs(self.rows) do
    local upgrade = upgrades[index]
    row.upgrade = upgrade
    if upgrade then
      row.icon:SetTexture(upgrade.item.texture)
      row.text:SetText((upgrade.item.name or upgrade.item.itemLink or "Upgrade") .. string.format("  +%.1f", upgrade.delta))
      row:SetBackdropColor(.12, .12, .12, index % 2 == 0 and .7 or .45)
      row:Show()
    else
      row:Hide()
    end
  end
  if #upgrades == 0 then
    self.rows[1].text:SetText("No scored bag upgrades are available.")
    self.rows[1].icon:SetTexture(nil)
    self.rows[1]:Show()
  end
end

function Gear:Show()
  self:Create()
  self.frame:Show()
  self:Refresh()
end

function Gear:OnStartup()
  self:QueueRefresh()
end

ZGV:RegisterCallback("ZGV_INVENTORY_UPDATED", Gear, "QueueRefresh")
