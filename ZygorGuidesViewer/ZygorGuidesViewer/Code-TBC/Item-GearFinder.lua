-- Character-frame era names backed by the standalone WotLK Gear Finder.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local GearFinder=ZGV and ZGV.ItemScore and ZGV.ItemScore.GearFinder
if type(GearFinder)~="table" then return end

GearFinder.PAST_DUNGEONS_LIMIT=GearFinder.PAST_DUNGEONS_LIMIT or 30
GearFinder.FUTURE_DUNGEONS_LIMIT=GearFinder.FUTURE_DUNGEONS_LIMIT or 5

if type(GearFinder.Initialise)~="function" then
  function GearFinder:Initialise()
    self.MainFrame=self:CreateFrame()
    return self.MainFrame
  end
end
if type(GearFinder.CreateMainFrame)~="function" then GearFinder.CreateMainFrame=GearFinder.Initialise end
if type(GearFinder.AttachFrame)~="function" then
  function GearFinder:AttachFrame() return self:Initialise() end
end
if type(GearFinder.ShowFinder)~="function" then
  function GearFinder:ShowFinder()
    self:Show()
    self.MainFrame=self.frame or self.MainFrame
    return self.MainFrame
  end
end
if type(GearFinder.IsEnabled)~="function" then
  function GearFinder:IsEnabled()
    local profile=ZGV.db and ZGV.db.profile
    if profile and profile.gear then return profile.gear.enabled~=false end
    if profile and profile.autogear_finder~=nil then return profile.autogear_finder and true or false end
    return true
  end
end
if type(GearFinder.UpdateSystemTab)~="function" then
  function GearFinder:UpdateSystemTab()
    local frame=self.frame or self.MainFrame
    if not self:IsEnabled() and frame and type(frame.Hide)=="function" then frame:Hide() end
    if self:IsEnabled() and frame and type(frame.IsShown)=="function" and frame:IsShown() and type(self.Render)=="function" then self:Render() end
    return self:IsEnabled()
  end
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.GearFinder=GearFinder
