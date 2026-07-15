-- Small WotLK-safe replacement for the Anniversary module collection.  Keep
-- the useful onboarding APIs while deliberately omitting housing, which has
-- no equivalent in the 3.3.5a client.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local Modules=ZGV.Modules

local IntroWizard=Modules.IntroWizard or {name="IntroWizard"}
Modules.IntroWizard=IntroWizard
ZGV.IntroWizard=IntroWizard

local checks={
  {"Guide viewer",function() return ZGV.Runtime and ZGV.Runtime.currentGuide~=nil end},
  {"Navigation",function() return ZGV.db and ZGV.db.profile.navigation and ZGV.db.profile.navigation.enabled~=false end},
  {"Map and POIs",function() return ZGV.db and ZGV.db.profile.map and ZGV.db.profile.map.poiEnabled~=false end},
  {"Guide automation",function() return ZGV.db and ZGV.db.profile.automation and (ZGV.db.profile.automation.accept or ZGV.db.profile.automation.turnin) end},
}

function IntroWizard:EnsureChecks()
  if not (ZGV.db and ZGV.db.char) then return {} end
  local saved=ZGV.db.char.checks or {}
  ZGV.db.char.checks=saved
  for index=1,#checks do saved[index]=saved[index] or {value=false,override=false} end
  return saved
end

function IntroWizard:CheckObjectives()
  local saved=self:EnsureChecks()
  for index,check in ipairs(checks) do if not saved[index].override then saved[index].value=check[2]() and true or false end end
  if self.frame then self:RefreshFrame() end
  return saved
end
function IntroWizard:CheckAllObjectives() return self:CheckObjectives() end
function IntroWizard:ToggleCheck(index)
  local saved=self:EnsureChecks(); local check=saved[tonumber(index)]
  if not check then return false end
  check.override=not check.override; check.value=check.override and true or checks[tonumber(index)][2]() and true or false
  self:RefreshFrame(); return check.value
end

function IntroWizard:CreateFrame()
  if self.frame then return self.frame end
  local frame=CreateFrame("Frame","ZygorGuidesViewerChecklist",UIParent)
  frame:SetWidth(270); frame:SetHeight(150); frame:SetPoint("CENTER",UIParent,"CENTER",0,20)
  frame:SetFrameStrata("DIALOG"); frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  frame:SetBackdropColor(.06,.06,.06,.96); frame:SetBackdropBorderColor(.8,.45,0,1)
  frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self) self:StartMoving() end); frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
  local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge"); title:SetPoint("TOP",0,-12); title:SetText("Zygor setup checklist")
  frame.rows={}
  for index,entry in ipairs(checks) do
    local button=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
    button:SetWidth(238); button:SetHeight(22); button:SetPoint("TOP",frame,"TOP",0,-35-(index-1)*24)
    button:SetScript("OnClick",function() IntroWizard:ToggleCheck(index) end); frame.rows[index]=button
  end
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",3,3); close:SetScript("OnClick",function() frame:Hide() end)
  frame:Hide(); self.frame=frame; return frame
end

function IntroWizard:RefreshFrame()
  if not self.frame then return end
  local saved=self:EnsureChecks()
  for index,entry in ipairs(checks) do
    local state=saved[index]; local mark=state.value and "|cff1ac730✓|r" or "|cffffa000○|r"
    self.frame.rows[index]:SetText(mark.." "..entry[1]..(state.override and " |cffaaaaaa(manual)|r" or ""))
  end
end
function IntroWizard:Checklist()
  self:CreateFrame(); self:CheckObjectives(); self.frame:Show(); return self.frame
end
function IntroWizard:OnStartup() self:EnsureChecks(); self:CheckObjectives() end

-- Presence-only compatibility: housing APIs must never be invoked on 3.3.5a.
local Housing=Modules.Housing or {name="Housing",unsupported=true}
function Housing:OnStartup() end
Modules.Housing=Housing

-- ZGV.Modules is also the core module registry.  Registering a module called
-- "Modules" would overwrite that registry through RegisterModule's legacy
-- ZGV[name] alias, so use a distinct lifecycle owner and keep the namespace.
local ModuleRuntime=ZGV:RegisterModule("ModuleBootstrap",{})
function ModuleRuntime:OnStartup()
  IntroWizard:OnStartup()
  Housing:OnStartup()
end
