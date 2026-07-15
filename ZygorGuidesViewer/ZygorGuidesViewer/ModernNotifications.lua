-- Notification queue for the WotLK viewer.  Keep this source deliberately
-- conservative: it is parsed directly by the 3.3.5a Lua loader.
local addonName, addonNamespace = ...
local ZGV
if type(addonNamespace) == "table" then
  ZGV = addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV
end
if not ZGV then ZGV = _G.ZygorGuidesViewer end
if type(ZGV) ~= "table" then return end

local Center = ZGV:RegisterModule("NotificationCenter", {})
Center.queue = Center.queue or {}
Center.active = Center.active or {}
Center.Entries = Center.Entries or {}
Center.Types = Center.Types or {}

local MAX_VISIBLE = 3
local MAX_HISTORY = 60
local iconSlots = {
  info = 8,
  warning = 9,
  reward = 5,
  complete = 8,
  route = 9,
  error = 13,
}

local function skinData(name, fallback)
  if ZGV.GetSkinData then
    local data = ZGV:GetSkinData(name)
    if data ~= nil then return data end
  end
  return fallback
end

local function baseBackdrop()
  return {
    bgFile = ZGV.SKINDIR .. "white",
    edgeFile = ZGV.SKINDIR .. "white",
    edgeSize = 1,
  }
end

local function createText(parent, size)
  local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  local path, _, flags = GameFontNormal:GetFont()
  text:SetFont(path, size, flags)
  text:SetJustifyH("LEFT")
  return text
end

local function createEntry(parent)
  local entry = CreateFrame("Button", nil, parent)
  entry:SetWidth(265)
  entry:SetHeight(48)
  entry:SetBackdrop(baseBackdrop())

  local icon = entry:CreateTexture(nil, "ARTWORK")
  icon:SetPoint("LEFT", entry, "LEFT", 8, 0)
  icon:SetWidth(26)
  icon:SetHeight(26)
  icon:SetTexture(ZGV.SKINDIR .. "icons-notificationcenter")
  entry.icon = icon

  local title = createText(entry, 11)
  title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 7, -7)
  title:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -22, -7)
  entry.title = title

  local text = createText(entry, 10)
  text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
  text:SetPoint("TOPRIGHT", entry, "TOPRIGHT", -22, -2)
  text:SetJustifyV("TOP")
  entry.text = text

  local close = CreateFrame("Button", nil, entry, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", entry, "TOPRIGHT", 2, 2)
  close:SetScale(.65)
  close:SetScript("OnClick", function()
    Center:Dismiss(entry)
  end)

  entry:SetScript("OnClick", function(self)
    if self.notification and self.notification.action then
      self.notification.action(self.notification)
    end
    Center:Dismiss(self)
  end)
  entry:SetScript("OnEnter", function(self)
    if self.dismissTimer then
      ZGV:CancelTimer(self.dismissTimer)
      self.dismissTimer = nil
    end
  end)
  entry:SetScript("OnLeave", function(self)
    if self.notification then
      Center:ScheduleDismiss(self, self.notification.duration or 2)
    end
  end)
  entry:Hide()
  return entry
end

function Center:ApplySkin()
  local backdrop = skinData("NotificationPopupContentBackdrop", skinData("FloatMenuSmallBackdrop", baseBackdrop()))
  local color = skinData("NotificationPopupContentBackdropColor", { .08, .08, .08, .96 })
  local border = skinData("NotificationPopupContentBackdropBorderColor", { .2, .2, .2, 1 })
  local textColor = skinData("NotificationTextColor", { .8, .8, .8, 1 })
  for index = 1, #self.active do
    local entry = self.active[index]
    entry:SetBackdrop(backdrop)
    entry:SetBackdropColor(unpack(color))
    entry:SetBackdropBorderColor(unpack(border))
    entry.text:SetTextColor(unpack(textColor))
  end
end

function Center:Create()
  if self.anchor then return self.anchor end
  local options = ZGV.db.profile.notifications
  local anchor = CreateFrame("Frame", "ZygorGuidesViewerNotificationAnchor", UIParent)
  anchor:SetWidth(265)
  anchor:SetHeight(1)
  anchor:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", options.x or -30, options.y or -180)
  anchor:SetFrameStrata("HIGH")
  self.anchor = anchor

  for index = 1, MAX_VISIBLE do
    local entry = createEntry(anchor)
    if index == 1 then
      entry:SetPoint("TOPRIGHT", anchor, "TOPRIGHT")
    else
      entry:SetPoint("TOPRIGHT", self.active[index - 1], "BOTTOMRIGHT", 0, -5)
    end
    self.active[index] = entry
  end
  self:ApplySkin()
  return anchor
end

function Center:Save(notification)
  local history = ZGV.db.profile.notifications.history
  history[#history + 1] = {
    message = notification.message,
    kind = notification.kind,
    title = notification.title,
    time = time(),
  }
  while #history > MAX_HISTORY do table.remove(history, 1) end
end

function Center:ScheduleDismiss(entry, delay)
  if entry.dismissTimer then ZGV:CancelTimer(entry.dismissTimer) end
  entry.dismissTimer = ZGV:ScheduleTimer(function()
    Center:Dismiss(entry)
  end, delay)
end

function Center:ShowNext()
  self:Create()
  if #self.queue == 0 then return end
  local target
  for index = 1, #self.active do
    if not self.active[index]:IsShown() then
      target = self.active[index]
      break
    end
  end
  if not target then return end

  local notification = table.remove(self.queue, 1)
  target.notification = notification
  target.title:SetText(notification.title)
  target.text:SetText(notification.message)
  local slot = iconSlots[notification.kind] or iconSlots.info
  target.icon:SetTexCoord((slot - 1) / 32, slot / 32, 0, 1)
  target:Show()
  self:ScheduleDismiss(target, notification.duration)
end

function Center:Dismiss(entry)
  if not entry or not entry:IsShown() then return end
  if entry.dismissTimer then
    ZGV:CancelTimer(entry.dismissTimer)
    entry.dismissTimer = nil
  end
  entry:Hide()
  entry.notification = nil
  self:ShowNext()
end

function Center:Push(notification)
  local options = ZGV.db.profile.notifications
  if not options.enabled or not options.toast then return end
  notification = notification or {}
  notification.message = tostring(notification.message or "")
  notification.kind = notification.kind or "info"
  notification.title = notification.title or "Zygor Guides"
  notification.duration = notification.duration or options.duration or 5
  self:Save(notification)
  self.queue[#self.queue + 1] = notification
  self:ShowNext()
end

-- Classic NotificationCenter API ------------------------------------------------
-- The old menu renderer is not part of the WotLK viewer, but guide modules
-- still create durable entries through this API.  Keep those entries as the
-- source of truth and project unread ones into the existing toast queue.
local function entryAction(entry)
  local data=entry.data or {}
  local kind=entry.notiftype
  if kind=="gear" or kind=="gearpop" then
    if ZGV.GearAdvisor and ZGV.GearAdvisor.Show then ZGV.GearAdvisor:Show() end
  elseif kind=="goldbuy" then
    if ZGV.Inventory and ZGV.Inventory.BuyItems then ZGV.Inventory:BuyItems() end
  elseif kind=="orientation" then
    if ZGV.Modules and ZGV.Modules.IntroWizard then ZGV.Modules.IntroWizard:Checklist() end
  elseif kind=="options" then
    ZGV:OpenOptions(data.tab)
  elseif (kind=="guide" or kind=="dungeon" or kind=="invalid" or kind=="mount" or kind=="pet") and data.guide and ZGV.Runtime then
    ZGV.Runtime:SelectGuide(data.guide)
  elseif type(data.click)=="function" then
    data.click(entry)
  end
end

function Center:Startup()
  self:LoadNotifications()
  self:CheckDynamicNotifications()
end

function Center:AddEntry(notiftype,title,text,data)
  if not (ZGV.db and ZGV.db.profile and ZGV.db.profile.notifications and ZGV.db.profile.notifications.enabled) then return nil end
  data=data or {}
  if data.cleartype then self:RemoveEntriesByType(notiftype) end
  self.entrySerial=(self.entrySerial or 0)+1
  local ident=data.ident or tostring(notiftype or "info")..":"..tostring(time and time() or 0)..":"..tostring(self.entrySerial)
  local entry={
    ident=ident,notiftype=tostring(notiftype or "info"),title=tostring(title or "Zygor Guides"),text=tostring(text or ""),
    data=data,priority=tonumber(data.priority) or 100,
  }
  entry.data.added=entry.data.added or (time and time() or 0)
  entry.func=function()
    entryAction(entry)
    if not entry.data.keeponclick then Center:RemoveEntry(entry.ident) end
  end
  table.insert(self.Entries,1,entry)
  if not data.shown and not data.transient then
    self:ShowOne(entry)
  elseif data.special then
    self:ShowOne(entry)
  end
  self:UpdateButton()
  return ident
end

function Center:RemoveEntriesByType(notiftype)
  local count=0
  for index=#self.Entries,1,-1 do
    if self.Entries[index].notiftype==notiftype then table.remove(self.Entries,index); count=count+1 end
  end
  self:UpdateButton()
  return count
end

function Center:RemoveEntry(ident)
  for index=#self.Entries,1,-1 do if self.Entries[index].ident==ident then table.remove(self.Entries,index) end end
  for index=#self.queue,1,-1 do if self.queue[index].ident==ident then table.remove(self.queue,index) end end
  for _,frame in ipairs(self.active) do
    if frame.notification and frame.notification.ident==ident then self:Dismiss(frame) end
  end
  self:UpdateButton()
end

function Center:GetEntry(ident)
  for _,entry in ipairs(self.Entries) do if entry.ident==ident then return entry end end
end

function Center:ClearNotifications()
  self.Entries={}; self.queue={}
  if self.Saved then for index=#self.Saved,1,-1 do table.remove(self.Saved,index) end end
  for _,frame in ipairs(self.active) do self:Dismiss(frame) end
  self:UpdateButton()
end

function Center:LoadNotifications()
  if not (ZGV.db and ZGV.db.char) or self.loadedEntries then return end
  self.loadedEntries=true
  ZGV.db.char.savednotifications=ZGV.db.char.savednotifications or {}
  self.Saved=ZGV.db.char.savednotifications
  for _,saved in ipairs(self.Saved) do
    local data={}
    for key,value in pairs(saved.data or {}) do data[key]=value end
    data.shown=true
    self:AddEntry(saved.notiftype,saved.title,saved.text,data)
  end
end

function Center:SaveNotifications()
  if not (ZGV.db and ZGV.db.char) then return end
  ZGV.db.char.savednotifications=ZGV.db.char.savednotifications or {}
  self.Saved=ZGV.db.char.savednotifications
  for index=#self.Saved,1,-1 do table.remove(self.Saved,index) end
  for _,entry in ipairs(self.Entries) do
    if not entry.data.nosave then
      local data={}
      for key,value in pairs(entry.data or {}) do if type(value)~="function" then data[key]=value end end
      data.shown=true
      self.Saved[#self.Saved+1]={notiftype=entry.notiftype,title=entry.title,text=entry.text,data=data}
    end
  end
end

function Center:ShowOne(entry)
  if not entry then return false end
  entry.data=entry.data or {}; entry.data.shown=true; entry.data.reviewed=true
  self:Push({ident=entry.ident,title=entry.title,message=entry.text,kind=entry.notiftype,duration=entry.data.displaytime,action=entry.func})
  self:UpdateButton()
  return true
end

function Center:ShowAll()
  local result={}
  for _,entry in ipairs(self.Entries) do if not entry.data.transient then result[#result+1]=entry; entry.data.reviewed=true end end
  self:UpdateButton()
  return result
end
function Center:ShowSub() return self:ShowAll() end

function Center:CreateHistoryFrame()
  if self.historyFrame then return self.historyFrame end
  local frame=CreateFrame("Frame","ZygorGuidesViewerNotificationHistory",UIParent)
  frame:SetWidth(430); frame:SetHeight(300); frame:SetPoint("CENTER",UIParent,"CENTER",0,20)
  frame:SetFrameStrata("DIALOG"); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",frame.StartMoving); frame:SetScript("OnDragStop",frame.StopMovingOrSizing)
  frame:SetBackdrop(baseBackdrop()); frame:SetBackdropColor(.05,.05,.05,.96); frame:SetBackdropBorderColor(.25,.25,.25,1)
  local title=createText(frame,14); title:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-12); title:SetText("Notification history"); frame.title=title
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,2); close:SetScript("OnClick",function() frame:Hide() end)
  frame.lines={}
  for index=1,10 do
    local line=createText(frame,11); line:SetPoint("TOPLEFT",frame,"TOPLEFT",14,-34-(index-1)*24); line:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-14,-34-(index-1)*24)
    line:SetHeight(22); line:SetWordWrap(false); frame.lines[index]=line
  end
  frame:Hide(); self.historyFrame=frame; return frame
end

function Center:ShowHistory()
  local frame=self:CreateHistoryFrame(); local history=ZGV.db.profile.notifications.history or {}
  for index,line in ipairs(frame.lines) do
    local entry=history[#history-index+1]
    if entry then
      local stamp=date and date("%H:%M",tonumber(entry.time) or 0) or ""
      line:SetText("["..stamp.."] "..tostring(entry.title or "Zygor")..": "..tostring(entry.message or "")); line:Show()
    else line:SetText(""); line:Hide() end
  end
  frame:Show(); return frame
end

function Center:UpdateButton()
  local unread=false
  for _,entry in ipairs(self.Entries) do if not entry.data.reviewed then unread=true break end end
  ZGV:Fire("ZGV_NOTIFICATION_CENTER_UPDATED",unread,#self.Entries)
  return unread
end

function Center:CheckDynamicNotifications()
  if self.dynamicChecked then return end
  self.dynamicChecked=true
  -- GetQuestResetTime is available in build 12340; no Calendar/C_DateTime
  -- calls are needed.  Keep this as a lightweight reset signal for callers.
  if GetQuestResetTime then
    local seconds=GetQuestResetTime()
    if seconds and seconds>0 then ZGV:Fire("ZGV_QUEST_RESET_PENDING",seconds) end
  end
end

function Center:OnGuideChanged(guide)
  if guide then
    self:Push({ title = "Guide loaded", message = guide.name or guide.title, kind = "info", duration = 3 })
  end
end

function Center:OnGuideComplete(guide)
  if guide then
    self:Push({ title = "Guide complete", message = guide.name or guide.title, kind = "complete", duration = 6 })
  end
end

function Center:OnStartup()
  self:Create()
  self:Startup()
end

ZGV:RegisterEvent("PLAYER_LOGOUT",function() Center:SaveNotifications() end)

ZGV:RegisterCallback("ZGV_NOTIFICATION", Center, "Push")
ZGV:RegisterCallback("ZGV_GUIDE_CHANGED", Center, "OnGuideChanged")
ZGV:RegisterCallback("ZGV_GUIDE_COMPLETE", Center, "OnGuideComplete")
