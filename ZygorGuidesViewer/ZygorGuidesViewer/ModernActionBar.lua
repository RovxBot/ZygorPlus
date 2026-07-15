-- Contextual secure action bar for the 3.3.5a viewer.  This retains the
-- Classic bar's useful actions (items, spells, targeting, pet actions,
-- profession casts, scripts and trash) while taking its state from the modern
-- Runtime model.
local _,namespace=...
local ZGV=(type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end
local unpack=unpack or table.unpack

local ActionBar=ZGV:RegisterModule("ActionBar",{buttons={},entries={}})
local BUTTON_SIZE,MAX_BUTTONS=34,5
local fallbackTexture="Interface\\Icons\\INV_Misc_QuestionMark"
local actionTexture=(ZGV.DIR or "Interface\\AddOns\\ZygorGuidesViewer").."\\Skins\\actionbar"

local function inCombat()
  return type(InCombatLockdown)=="function" and InCombatLockdown()
end

local function retryOutOfCombat(key,callback)
  if not inCombat() then return false end
  if ZGV.Compat and ZGV.Compat.UI then
    ZGV.Compat.UI:RunOutOfCombat("actionbar:"..tostring(key),callback)
  end
  return true
end

local function setCombatVisibility(frame,enabled)
  if not frame then return end
  if enabled and not frame.combatVisibilityDriver and type(RegisterStateDriver)=="function" then
    -- The secure visibility driver is allowed to hide protected descendants
    -- at combat entry; ordinary Lua must leave their layout untouched.
    RegisterStateDriver(frame,"visibility","[combat] hide; show")
    frame.combatVisibilityDriver=true
  elseif frame.combatVisibilityDriver and type(UnregisterStateDriver)=="function" then
    UnregisterStateDriver(frame,"visibility")
    frame.combatVisibilityDriver=nil
  end
end

local function settings()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.actionbar
end

local function displayGoals()
  local runtime=ZGV.Runtime
  return runtime and runtime.currentGuide and runtime:GetDisplayGoals(runtime.currentStep) or {}
end

local function targetMacro(goal,kind)
  local name=tostring(goal.useName or goal.usename or goal.target or goal.npcName or "")
  if name=="" then return nil end
  name=name:gsub("[\r\n;]"," ")
  local marker=kind=="kill" and "\n/tm 8" or (kind=="clicknpc" and "\n/tm 6" or "\n/tm 1")
  local clear=kind=="kill" and "\n/cleartarget [dead]" or ""
  return "/cleartarget\n/targetexact "..name..clear..marker
end

local function petActionInfo(action)
  local goal=action and action.entry and action.entry.goal
  if goal and ZGV.FindPetActionInfo then return ZGV.FindPetActionInfo(goal) end
  if type(GetPetActionInfo)~="function" then return nil end
  local wanted=action and action.identity
  if tonumber(wanted) then
    local name,_,texture=GetPetActionInfo(tonumber(wanted))
    if name then return tonumber(wanted),name,texture end
    return nil
  end
  wanted=tostring(wanted or ""):lower()
  if wanted=="" then return nil end
  for slot=1,12 do
    local name,_,texture=GetPetActionInfo(slot)
    if name and name:lower():find(wanted,1,true) then return slot,name,texture end
  end
end

local function setCooldown(frame,start,duration,enabled)
  start,duration=tonumber(start) or 0,tonumber(duration) or 0
  if start<=0 or duration<=0 then frame:Hide(); return end
  if type(CooldownFrame_SetTimer)=="function" then CooldownFrame_SetTimer(frame,start,duration,enabled)
  elseif type(frame.SetCooldown)=="function" then frame:SetCooldown(start,duration)
  else frame:Hide(); return end
  frame:Show()
end

local function classify(entry)
  local goal=entry.goal
  if goal.itemID and (goal.action=="use" or goal.action=="equip" or goal.action=="unequip") then
    return goal.action=="equip" and "equip" or "item",goal.itemID
  elseif goal.spellID and (goal.action=="cast" or goal.action=="learn" or goal.action=="create" or goal.action=="craft") then
    return "spell",goal.spellID
  elseif goal.petaction or goal.petAction or goal.action=="petaction" then
    return "petaction",goal.petaction or goal.petAction or goal.spellID or goal.targetID or goal.target
  elseif goal.action=="talk" or goal.action=="clicknpc" or goal.action=="kill" then
    return goal.action,goal.npcID or goal.target
  elseif goal.macro then
    local source=goal.parentGuide and goal.parentGuide.source or ""
    if source~="user" or (ZGV.db and ZGV.db.global and ZGV.db.global.trustedUserScripts) then return "macro",goal.macro end
  elseif goal.script or goal.autoscript then return "runtime",goal.script or goal.autoscript
  elseif goal.nextJump or goal.nextGuide or goal.loadGuide or goal.confirm then return "runtime",goal.nextJump or goal.nextGuide or goal.loadGuide or goal.text
  elseif goal:IsActionable() then return "runtime",goal.text end
end

local function collectActions()
  local runtime=ZGV.Runtime
  local config=settings()
  local result,seen={},{}
  if not runtime or not config then return result end
  for _,entry in ipairs(displayGoals()) do
    local goal=entry.goal
    local complete=entry.state and entry.state.complete
    if not complete and runtime:IsGoalApplicable(goal) then
      local kind,identity=classify(entry)
      local enabled=(kind=="item" or kind=="equip" or kind=="spell" or kind=="runtime" or kind=="macro" or kind=="petaction") and config.quest
        or ((kind=="talk" or kind=="clicknpc") and config.talk)
        or (kind=="kill" and config.kill)
      local key=tostring(kind)..":"..tostring(identity)
      if kind and enabled and not seen[key] then
        result[#result+1]={kind=kind,identity=identity,entry=entry}
        seen[key]=true
        if #result>=MAX_BUTTONS then break end
      end
    end
  end
  if config.trash and #result<MAX_BUTTONS and ZGV.Inventory and ZGV.Inventory.merchantOpen then
    result[#result+1]={kind="trash",identity="trash"}
  end
  return result
end

local function iconFor(action)
  if not action then return fallbackTexture end
  if action.kind=="item" or action.kind=="equip" then
    return select(10,GetItemInfo(action.identity)) or fallbackTexture
  elseif action.kind=="spell" then
    return select(3,GetSpellInfo(action.identity)) or fallbackTexture
  elseif action.kind=="petaction" and GetPetActionInfo then
    local _,_,texture=petActionInfo(action)
    return texture or fallbackTexture
  elseif action.kind=="talk" or action.kind=="clicknpc" then return actionTexture,0,.125,0,1
  elseif action.kind=="kill" then return actionTexture,.125,.25,0,1
  elseif action.kind=="trash" then return actionTexture,.5,.625,0,1
  elseif action.kind=="runtime" or action.kind=="macro" then return actionTexture,.375,.5,0,1
  end
  return "Interface\\Icons\\INV_Misc_Note_01"
end

local function configure(button,action)
  local attributes={}
  if action then
    if action.kind=="item" then attributes.type="item"; attributes.item="item:"..tostring(action.identity)
    elseif action.kind=="equip" then attributes.type="macro"; attributes.macrotext="/equip item:"..tostring(action.identity)
    elseif action.kind=="spell" then attributes.type="spell"; attributes.spell=action.identity
    elseif action.kind=="petaction" then
      local slot=petActionInfo(action)
      if slot then attributes.type="pet"; attributes.action=slot end
    elseif action.kind=="macro" then attributes.type="macro"; attributes.macrotext=tostring(action.identity)
    elseif action.kind=="talk" or action.kind=="clicknpc" or action.kind=="kill" then
      attributes.type="macro"; attributes.macrotext=targetMacro(action.entry.goal,action.kind)
    end
  end
  local apply=function()
    for _,key in ipairs({"type","item","spell","action","petaction","macrotext"}) do button:SetAttribute(key,attributes[key]) end
    button.secure=attributes.type~=nil
  end
  if ZGV.Compat and ZGV.Compat.UI then ZGV.Compat.UI:RunOutOfCombat("actionbar:"..button:GetName(),apply) else apply() end
end

function ActionBar:Create()
  if self.frame then return self.frame end
  if inCombat() then return nil end
  local config=settings() or {}
  local frame=CreateFrame("Frame","ZygorGuidesViewerActionBar",UIParent,"SecureHandlerStateTemplate")
  frame:SetHeight(BUTTON_SIZE+12); frame:SetWidth(MAX_BUTTONS*BUTTON_SIZE+12)
  frame:SetScale(config.scale or 1); frame:SetPoint("CENTER",UIParent,"CENTER",config.x or 0,config.y or 80)
  frame:SetFrameStrata("LOW"); frame:SetToplevel(true); frame:SetMovable(true); frame:EnableMouse(true); frame:SetClampedToScreen(true)
  frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  frame:SetBackdropColor(.06,.06,.06,.95); frame:SetBackdropBorderColor(.2,.2,.2,1)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self) if not (settings() or {}).locked and not InCombatLockdown() then self:StartMoving() end end)
  frame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    local x,y=self:GetCenter(); local px,py=UIParent:GetCenter(); local saved=settings()
    if saved and x and px then saved.x,saved.y=math.floor(x-px+.5),math.floor(y-py+.5) end
  end)
  frame:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_BOTTOMLEFT"); GameTooltip:SetText("Zygor Action Bar"); GameTooltip:AddLine("Drag to move. Buttons follow active guide actions.",.7,.7,.7); GameTooltip:Show() end)
  frame:SetScript("OnLeave",function() GameTooltip:Hide() end)
  self.frame=frame
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
  close:SetWidth(18); close:SetHeight(18)
  close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-2,3)
  close:SetScript("OnClick",function()
    local config=settings()
    if config then config.enabled=false end
    ActionBar:Refresh()
  end)
  close:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText("Retract action bar")
    GameTooltip:AddLine("Re-enable it in Settings > Action Buttons.",.7,.7,.7)
    GameTooltip:Show()
  end)
  close:SetScript("OnLeave",function() GameTooltip:Hide() end)
  frame.close=close
  for index=1,MAX_BUTTONS do
    local button=CreateFrame("Button","ZygorAB"..index,frame,"SecureActionButtonTemplate")
    button:SetSize(BUTTON_SIZE,BUTTON_SIZE); button:RegisterForClicks("AnyUp"); button:RegisterForDrag("LeftButton")
    local icon=button:CreateTexture(nil,"ARTWORK")
    icon:SetPoint("TOPLEFT",button,"TOPLEFT",2,-2); icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
    button.icon=icon
    local border=button:CreateTexture(nil,"OVERLAY")
    border:SetAllPoints(button); border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    button.border=border
    local cooldown=CreateFrame("Cooldown",nil,button,"CooldownFrameTemplate"); cooldown:SetAllPoints(button); button.cooldown=cooldown
    button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    -- SecureActionButtonTemplate owns OnClick on build 12340.  Replacing it
    -- prevents the secure type/item/spell/pet attributes above from firing.
    -- PostClick preserves Blizzard's protected action and still lets the
    -- viewer update an unprotected guide action after the hardware click.
    button:SetScript("PostClick",function(self)
      local action=self.action
      if action and not self.secure then
        if action.kind=="trash" and ZGV.Inventory then ZGV.Inventory:SellGreys()
        elseif action.entry then ZGV.Runtime:ActivateGoal(action.entry.stepIndex,action.entry.goalIndex) end
      end
      ActionBar:Refresh()
    end)
    button:SetScript("OnEnter",function(self)
      if not self.action then return end
      GameTooltip:SetOwner(self,"ANCHOR_TOP")
      local action=self.action
      if action.entry then
        GameTooltip:SetText(action.entry.goal:GetText())
        GameTooltip:AddLine(action.kind=="runtime" and "Click to perform this guide action." or "Click to use this guide action.",.6,.8,1)
      else GameTooltip:SetText("Sell grey items") end
      GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart",function(self)
      if InCombatLockdown() or not self.action then return end
      local action=self.action
      if (action.kind=="item" or action.kind=="equip") and PickupItem then PickupItem(action.identity)
      elseif action.kind=="spell" and PickupSpell then PickupSpell(action.identity)
      elseif action.kind=="petaction" and PickupPetAction then
        local slot=petActionInfo(action); if slot then PickupPetAction(slot) end
      end
    end)
    button:Hide(); self.buttons[index]=button
    _G["BINDING_NAME_CLICK ZygorAB"..index..":LeftButton"]="Zygor Action Bar Button "..index
  end
  _G.BINDING_HEADER_ZYGORGUIDESACTIONBAR="Zygor Guides Viewer Action Bar"
  self:ApplySkin()
  return frame
end

function ActionBar:ApplySkin()
  if not self.frame then return end
  if retryOutOfCombat("skin",function() ActionBar:ApplySkin() end) then return end
  local backdrop=ZGV.GetSkinData and ZGV:GetSkinData("ActionBarBackdrop")
  local colour=ZGV.GetSkinData and ZGV:GetSkinData("ActionBarBackdropColor") or {.06,.06,.06,.95}
  local border=ZGV.GetSkinData and ZGV:GetSkinData("ActionBarBackdropBorderColor") or {.2,.2,.2,1}
  if backdrop then self.frame:SetBackdrop(backdrop) end
  self.frame:SetBackdropColor(unpack(colour)); self.frame:SetBackdropBorderColor(unpack(border))
end

function ActionBar:Refresh()
  -- Attributes, anchors, parent visibility, and arbitrary fields on protected
  -- buttons must remain stable in combat.  Coalesce any number of progress or
  -- cooldown events into one refresh after PLAYER_REGEN_ENABLED.
  if retryOutOfCombat("refresh",function() ActionBar:Refresh() end) then return false,"combat" end
  local frame=self:Create()
  if not frame then return false,"unavailable" end
  local config=settings()
  if not config or not config.enabled then setCombatVisibility(frame,false); frame:Hide(); return end
  frame:SetScale(config.scale or 1)
  local actions=collectActions()
  self.entries=actions
  local previous,width=nil,12
  local leftToRight=config.direction~=1
  for index,button in ipairs(self.buttons) do
    local action=actions[index]
    button:ClearAllPoints()
    if action then
      configure(button,action)
      button.action=action
      local texture,left,right,top,bottom=iconFor(action)
      button.icon:SetTexture(texture)
      button.icon:SetTexCoord(left or 0,right or 1,top or 0,bottom or 1)
      if action.kind=="item" and GetItemCooldown then
        local start,duration,enabled=GetItemCooldown(action.identity)
        setCooldown(button.cooldown,start,duration,enabled)
      elseif action.kind=="spell" and GetSpellCooldown then
        local start,duration,enabled=GetSpellCooldown(action.identity)
        setCooldown(button.cooldown,start,duration,enabled)
      elseif action.kind=="petaction" and GetPetActionCooldown then
        local slot=petActionInfo(action)
        if slot then setCooldown(button.cooldown,GetPetActionCooldown(slot)) else button.cooldown:Hide() end
      else button.cooldown:Hide() end
      local point=leftToRight and "LEFT" or "RIGHT"
      local relative=leftToRight and "RIGHT" or "LEFT"
      if previous then button:SetPoint(point,previous,relative,2,0)
      else button:SetPoint(point,frame,point,leftToRight and 6 or -26,0) end
      previous=button; width=width+BUTTON_SIZE+2; button:Show()
    else
      configure(button,nil); button.action=nil; button.icon:SetTexCoord(0,1,0,1); button:Hide()
    end
  end
  frame:SetWidth(math.max(BUTTON_SIZE+32,width+24))
  setCombatVisibility(frame,config.hideInCombat and #actions>0)
  if #actions>0 then frame:Show() else frame:Hide() end
  return true
end

function ActionBar:ClearBar(forceHide)
  if retryOutOfCombat("clear",function() ActionBar:ClearBar(forceHide) end) then return false,"combat" end
  for _,button in ipairs(self.buttons) do configure(button,nil); button.action=nil; button:Hide() end
  if forceHide and self.frame then setCombatVisibility(self.frame,false); self.frame:Hide() end
  return true
end
function ActionBar:CreateFrame() return self:Create() end
function ActionBar:SavePosition()
  if not self.frame then return end
  local x,y=self.frame:GetCenter(); local px,py=UIParent:GetCenter(); local config=settings()
  if config and x and px then config.x,config.y=math.floor(x-px+.5),math.floor(y-py+.5) end
end
function ActionBar:PositionX() self:Refresh() end
function ActionBar:ShowDisabledOverlay() self:SetAlpha(.35) end
function ActionBar:ToggleFrame() local config=settings(); if config then config.enabled=not config.enabled end self:Refresh() end
function ActionBar:SetScale()
  if retryOutOfCombat("scale",function() ActionBar:SetScale() end) then return end
  if self.frame then self.frame:SetScale((settings() or {}).scale or 1) end
end
function ActionBar:SetAlpha(value)
  if retryOutOfCombat("alpha",function() ActionBar:SetAlpha(value) end) then return end
  if self.frame then self.frame:SetAlpha(value or 1) end
end
function ActionBar:SetActionButtons() self:Refresh() end
function ActionBar:SetActionButtonsQueued() self:Refresh() end
function ActionBar:ReanchorButtons() self:Refresh() end
function ActionBar:GetDirection() self:Refresh(); return (settings() or {}).direction end
function ActionBar:SetCombatHiding(mode)
  local config=settings()
  if config and mode~=nil then config.hideInCombat=mode and true or false end
  self:Refresh()
end
function ActionBar:TutorialPreview(mode)
  if mode~="on" then return self:Refresh() end
  if retryOutOfCombat("preview",function() ActionBar:TutorialPreview(mode) end) then return end
  self:Create()
  local button=self.buttons[1]
  button.action={kind="runtime",identity="preview",entry=nil}; button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark"); button.icon:SetTexCoord(0,1,0,1)
  button:SetPoint("LEFT",self.frame,"LEFT",6,0); button:Show(); self.frame:Show()
end
function ActionBar:Initialise() self:Create(); self:Refresh() end
function ActionBar:OnStartup() self:Initialise() end

ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",ActionBar,"Refresh")
ZGV:RegisterCallback("ZGV_STEP_CHANGED",ActionBar,"Refresh")
ZGV:RegisterCallback("ZGV_GOAL_UPDATED",ActionBar,"Refresh")
ZGV:RegisterCallback("ZGV_RUNTIME_TICK",ActionBar,"Refresh")
ZGV:RegisterEvent("PLAYER_REGEN_ENABLED",ActionBar,"Refresh")
ZGV:AddMessageHandler("SKIN_UPDATED",function() ActionBar:ApplySkin() end)
