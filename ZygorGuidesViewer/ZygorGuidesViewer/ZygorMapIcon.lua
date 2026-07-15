-- Classic minimap-icon behaviour attached to ModernViewer's WotLK-safe
-- button.  Keeping one button prevents duplicate icons while retaining the
-- source's radial drag, loading state, notification click, and tooltip API.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

ZygorGuidesViewerMapIcon_Mixin=ZygorGuidesViewerMapIcon_Mixin or {}
local Icon=ZygorGuidesViewerMapIcon_Mixin
local RADIUS_ADJUST=-5

function Icon:OnUpdate()
  if self.loading and self.spinner and ZGV.RotateTex then ZGV.RotateTex(self.spinner,(GetTime and GetTime() or 0)*-3) end
  if not self.dragging or not self:GetParent() then return end
  local minimap=self:GetParent(); local x,y=minimap:GetCenter(); local scale=minimap:GetEffectiveScale()
  local cursorX,cursorY=GetCursorPosition(); cursorX,cursorY=cursorX/scale,cursorY/scale
  local dx,dy=cursorX-x,cursorY-y; local distance=(dx*dx+dy*dy)^.5
  if distance<.01 then return end
  local radius=(minimap:GetWidth()+self:GetWidth())/2
  local snap=radius+RADIUS_ADJUST; local pull=radius+self:GetWidth()*.7; local free=radius+self:GetWidth()
  local clamp
  if distance<=radius+self:GetWidth()*.2 then self.snapped=true; clamp=snap
  elseif distance<pull and self.snapped then clamp=snap
  elseif distance<free and self.snapped then clamp=snap+(distance-pull)/2
  else self.snapped=false end
  if clamp then dx,dy=dx/(distance/clamp),dy/(distance/clamp) end
  self:ClearAllPoints(); self:SetPoint("CENTER",minimap,"CENTER",dx,dy)
end

function Icon:Setup()
  if ZGV.F and ZGV.F.AssignButtonTexture then ZGV.F.AssignButtonTexture(self,ZGV.SKINDIR.."minimap-icon",1,2) end
end
function Icon:SetLoading(enabled)
  self.loading=enabled and true or false
  if self.spinner then self.spinner:SetTexture(ZGV.SKINDIR.."loading"); ZGV.Compat.UI:SetShown(self.spinner,self.loading) end
end
function Icon:OnClick(button)
  GameTooltip:Hide()
  local notifications=ZGV.NotificationCenter
  if button=="LeftButton" and ZGV.db and ZGV.db.profile.notifications and ZGV.db.profile.notifications.enabled and notifications then
    notifications:ShowAll()
  elseif ZGV.ToggleFrame then ZGV:ToggleFrame() end
end
function Icon:OnDragStart() self.dragging=true; self:StartMoving() end
function Icon:OnDragStop()
  self.dragging=false; self:StopMovingOrSizing()
  local x,y=self:GetCenter(); local mx,my=Minimap:GetCenter()
  if x and mx and ZGV.db and ZGV.db.profile.minimap then
    local profile=ZGV.db.profile.minimap; profile.x=math.floor(x-mx+.5); profile.y=math.floor(y-my+.5)
    self:ClearAllPoints(); self:SetPoint("CENTER",Minimap,"CENTER",profile.x,profile.y)
  end
end
function Icon:OnLoad()
  self:RegisterForClicks("LeftButtonUp","RightButtonUp"); self:RegisterForDrag("LeftButton")
end
function Icon:OnEnter()
  GameTooltip:SetOwner(self,"BOTTOMLEFT")
  GameTooltip:SetText((ZGV.L and (ZGV.L.name or ZGV.L.ADDON_NAME)) or "Zygor Guides")
  GameTooltip:AddLine((ZGV.L and ZGV.L.minimap_tooltip) or "Left-click for notifications; right-click to toggle the viewer.",.75,.75,.75,true)
  GameTooltip:Show()
end
function Icon:OnLeave() GameTooltip:Hide() end

function Icon:Attach(button)
  if not button or button.zgvMapIconAttached then return button end
  button.zgvMapIconAttached=true
  for name,method in pairs(Icon) do if type(method)=="function" and name~="Attach" then button[name]=method end end
  button:OnLoad(); button:Setup()
  button:SetScript("OnClick",function(self,mouse) self:OnClick(mouse) end)
  button:SetScript("OnDragStart",function(self) self:OnDragStart() end)
  button:SetScript("OnDragStop",function(self) self:OnDragStop() end)
  button:SetScript("OnUpdate",function(self) self:OnUpdate() end)
  button:SetScript("OnEnter",function(self) self:OnEnter() end)
  button:SetScript("OnLeave",function(self) self:OnLeave() end)
  return button
end

local function attach()
  local button=ZGV.UI and ZGV.UI.minimapButton or _G.ZygorGuidesViewerMapIcon
  if button then Icon:Attach(button) end
end
if ZGV.UI and ZGV.UI.CreateMinimapButton and not ZGV.UI._classicMapIconWrapped then
  local original=ZGV.UI.CreateMinimapButton
  ZGV.UI.CreateMinimapButton=function(self,...)
    return Icon:Attach(original(self,...))
  end
  ZGV.UI._classicMapIconWrapped=true
end
ZGV:RegisterCallback("ZGV_STARTED",attach)
