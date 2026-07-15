-- Loaded 3.3.5-safe counterpart for the Anniversary popout controller.
-- The actual frame is constructed by ModernTalentAdvisor.lua so it can avoid
-- post-Wrath XML mixins while these global entry points remain compatible.
local _,ZGV=...
if not ZGV then ZGV=_G.ZygorGuidesViewer end
local Advisor=ZGV and ZGV.TalentAdvisor
if not Advisor then return end

local function popout()
  local frame=Advisor:Create()
  Advisor.popout=frame
  return frame
end

function _G.ZygorTalentAdvisorPopout_Show()
  Advisor:Show()
  return popout()
end

function _G.ZygorTalentAdvisorPopout_Hide()
  local frame=popout()
  frame:Hide()
  return frame
end

function _G.ZygorTalentAdvisorPopout_Toggle()
  Advisor:Toggle()
  return popout()
end

function _G.ZygorTalentAdvisorPopout_Update()
  Advisor:Refresh()
  return popout()
end

function _G.ZygorTalentAdvisorPopout_Reparent()
  Advisor:ApplyDocking()
  return popout()
end

function _G.ZygorTalentAdvisorPopout_UpdateDocking(value)
  if value~=nil and ZGV.db and ZGV.db.profile then ZGV.db.profile.talent.docked=value and true or false end
  Advisor:ApplyDocking()
  return popout()
end

function _G.ZygorTalentAdvisorPopout_Hook()
  return Advisor:HookTalentFrame()
end

Advisor.popout=popout()
