-- Source-name facade for ModernNotifications.lua.
-- The modern module owns the queue, persistence, toast frames, and history;
-- this file only restores source entry points used by optional integrations.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" or type(ZGV.NotificationCenter) ~= "table" then return end

local Center = ZGV.NotificationCenter

function Center:UpdatePosition()
  local anchor = self.anchor or (type(self.Create) == "function" and self:Create())
  local options = ZGV.db and ZGV.db.profile and ZGV.db.profile.notifications or {}
  if not anchor then return nil end
  anchor:ClearAllPoints()
  anchor:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", options.x or -30, options.y or -180)
  return anchor
end

function Center:ShowSpecial(entry)
  return self:ShowOne(entry)
end

function Center.HandleQueue()
  return Center:ShowNext()
end

function Center:EventsTrigger()
  return self:CheckDynamicNotifications()
end

function Center:QuestResetTrigger()
  return self:CheckDynamicNotifications()
end

function Center:OrientationTrigger()
  return self:CheckDynamicNotifications()
end

-- The source mixins belonged to templates that use post-Wrath XML features.
-- They are not instantiated by the target, but these small methods let an
-- optional integration reuse their names without loading the incompatible XML.
ZGV_Notification_Entry_Template_Mixin = ZGV_Notification_Entry_Template_Mixin or {}
function ZGV_Notification_Entry_Template_Mixin:ApplySkin()
  if type(Center.ApplySkin) == "function" then return Center:ApplySkin() end
end
function ZGV_Notification_Entry_Template_Mixin:SetEntry(entry)
  self.entry = entry
  if self.title and type(self.title.SetText) == "function" then self.title:SetText(entry and entry.title or "") end
  if self.text and type(self.text.SetText) == "function" then self.text:SetText(entry and entry.text or "") end
  return entry
end
function ZGV_Notification_Entry_Template_Mixin:StartFadeTimer()
  if self.notification and type(Center.ScheduleDismiss) == "function" then
    return Center:ScheduleDismiss(self, self.notification.duration or 5)
  end
end
function ZGV_Notification_Entry_Template_Mixin:CancelFadeTimer()
  if self.dismissTimer and type(ZGV.CancelTimer) == "function" then ZGV:CancelTimer(self.dismissTimer) end
  self.dismissTimer = nil
end
function ZGV_Notification_Entry_Template_Mixin:UpdateMode() end
function ZGV_Notification_Entry_Template_Mixin:OnEnter()
  self:CancelFadeTimer()
  if self.entry and self.entry.data and self.entry.data.tooltip and GameTooltip then
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:SetText(self.entry.data.tooltip)
    GameTooltip:Show()
  end
end
function ZGV_Notification_Entry_Template_Mixin:OnLeave()
  if GameTooltip then GameTooltip:Hide() end
  self:StartFadeTimer()
end
function ZGV_Notification_Entry_Template_Mixin:UpdateHeight() return self:GetHeight() end

ZGV_Notification_Entry_Close_Template_Mixin = ZGV_Notification_Entry_Close_Template_Mixin or {}
function ZGV_Notification_Entry_Close_Template_Mixin:OnClick()
  local parent = self:GetParent()
  if parent and parent.entry then return Center:RemoveEntry(parent.entry.ident) end
end
function ZGV_Notification_Entry_Close_Template_Mixin:OnEnter()
  local parent = self:GetParent()
  local script = parent and parent:GetScript("OnEnter")
  if script then script(parent) end
end
function ZGV_Notification_Entry_Close_Template_Mixin:OnLeave()
  local parent = self:GetParent()
  local script = parent and parent:GetScript("OnLeave")
  if script then script(parent) end
end

ZGV_Notification_Settings_Template_Mixin = ZGV_Notification_Settings_Template_Mixin or {}
function ZGV_Notification_Settings_Template_Mixin:OnEnter()
  if self.tooltip and GameTooltip then
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(self.tooltip)
    GameTooltip:Show()
  end
end
function ZGV_Notification_Settings_Template_Mixin:OnLeave()
  if GameTooltip then GameTooltip:Hide() end
end
