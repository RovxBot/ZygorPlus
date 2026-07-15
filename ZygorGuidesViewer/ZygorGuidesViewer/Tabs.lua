-- Compatibility controller for the modern viewer's native guide-tab strip.
-- It preserves Classic Tabs calls and persistence without adding a second UI.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local Tabs={Pool={},maxTabs=4}
ZGV.Tabs=Tabs

local function ui() return ZGV.UI end
local function saved()
  ZGV.db.char.tabguides=ZGV.db.char.tabguides or {}
  return ZGV.db.char.tabguides
end
function Tabs:Save()
  local target=saved(); for index=#target,1,-1 do table.remove(target,index) end
  for _,tab in ipairs((ui() and ui().openTabs) or {}) do target[#target+1]={title=tab.id,step=tab.step or 1} end
end
function Tabs:Initialize()
  local viewer=ui(); if not viewer then return end
  viewer.openTabs=viewer.openTabs or {}
  if #viewer.openTabs==0 then
    for _,entry in ipairs(saved()) do
      local guide=ZGV.Catalog and ZGV.Catalog:Get(entry.title)
      if guide then viewer.openTabs[#viewer.openTabs+1]={id=guide.id,title=guide.name or guide.title,step=entry.step or 1} end
    end
  end
  if ZGV.Runtime and ZGV.Runtime.currentGuide then viewer:EnsureGuideTab(ZGV.Runtime.currentGuide) end
  viewer:UpdateGuideTabs(); self:Save()
end
function Tabs:LoadGuideToTab(guide,step,special,shared,previous)
  local target=ZGV.Catalog and ZGV.Catalog:Get(guide) or guide
  if not target or not ZGV.Runtime:SelectGuide(target,step) then return false end
  local viewer=ui(); if viewer then viewer:EnsureGuideTab(ZGV.Runtime.currentGuide); viewer:UpdateGuideTabs() end
  self:Save(); return true
end
function Tabs:GetTabFromPool() return {AssignGuide=function(tab,guide,step) return Tabs:LoadGuideToTab(guide,step) end,ActivateGuide=function() end,SetAsCurrent=function() end} end
function Tabs:GetSpecialTabFromPool() return self:GetTabFromPool() end
function Tabs:TryToActivateGuide(guide) return self:LoadGuideToTab(guide) end
function Tabs:ApplySkin() if ui() and ui().ApplyModernSkin then ui():ApplyModernSkin() end end
function Tabs:ReanchorTabs() if ui() and ui().UpdateGuideTabs then ui():UpdateGuideTabs() end end
function Tabs:ToggleRemainingMenu() if ZGV.GuideMenu then ZGV.GuideMenu:Show("RECENT") end end
function Tabs:UpdateCurrentTab() if ui() and ZGV.Runtime.currentGuide then ui():EnsureGuideTab(ZGV.Runtime.currentGuide); self:Save() end end
function Tabs:DoesTabExist(guide) return ui() and ui():FindGuideTab(ZGV.Catalog and ZGV.Catalog:Get(guide) or guide) ~= nil end
function Tabs:DoesSpecialTabExist() return false end
function Tabs:HideInteraction() end
function Tabs:ShowInteraction() end
function Tabs:CreateTab() return self:GetTabFromPool() end
function Tabs:SetBusy() end
function Tabs:SetAsCurrent(tab) if tab and ui() then ui():SelectGuideTab(tab) end end
function Tabs:HandleClick(tab) return self:SetAsCurrent(tab) end
function Tabs:ActivateGuide(tab) return self:SetAsCurrent(tab) end
function Tabs:AssignGuide(tab,guide,step) return self:LoadGuideToTab(guide,step) end
function Tabs:RemoveTab(tab) if ui() and tab then ui():CloseGuideTab(tab); self:Save() end end
function Tabs:OptionalTab() return nil end
function Tabs:IsGuideTabbed(guide) return self:DoesTabExist(guide) end
function Tabs:CheckForStepCompletion() end
function Tabs:StartSizing() end
function Tabs:StopMovingOrSizing() end
function Tabs:OnDragStart() end
function Tabs:OnDragStop() self:Save() end
function Tabs.AddButtonOnClick(_,button) if ZGV.GuideMenu then ZGV.GuideMenu:Show(button=="RightButton" and "SUGGESTED" or "HOME") end end
function Tabs.AddButtonOnEnter(self) GameTooltip:SetOwner(self,"ANCHOR_TOP"); GameTooltip:SetText("Select a guide"); GameTooltip:Show() end
local Bootstrap=ZGV:RegisterModule("TabsBootstrap",{})
function Bootstrap:OnStartup() Tabs:Initialize() end
ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",function() Tabs:UpdateCurrentTab() end)
