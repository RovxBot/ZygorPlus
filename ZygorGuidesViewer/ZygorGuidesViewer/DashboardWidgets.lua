-- WotLK-native dashboard payloads for the Anniversary widget manager.
-- Retail-only currencies and activities are intentionally not emulated.
local ZGV = ZygorGuidesViewer
local Widgets = ZGV and ZGV.Widgets
if type(Widgets) ~= "table" then return end

local function duration(seconds)
  seconds = math.max(0, math.floor(tonumber(seconds) or 0))
  local days = math.floor(seconds / 86400); seconds = seconds % 86400
  local hours = math.floor(seconds / 3600); seconds = seconds % 3600
  local minutes = math.floor(seconds / 60)
  if days > 0 then return string.format("%dd %dh", days, hours) end
  if hours > 0 then return string.format("%dh %dm", hours, minutes) end
  return string.format("%dm %ds", minutes, seconds % 60)
end

local function money(value)
  return ZGV.GetMoneyString and ZGV.GetMoneyString(value, true, nil, true) or tostring(value or 0)
end

local function line(frame, index, size)
  frame.dashboardLines = frame.dashboardLines or {}
  local label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  label:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -27 - (index - 1) * 24)
  label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -27 - (index - 1) * 24)
  label:SetHeight(20); label:SetJustifyH("LEFT"); label:SetJustifyV("MIDDLE")
  if size then local path, _, flags = GameFontHighlightSmall:GetFont(); label:SetFont(path, size, flags) end
  frame.dashboardLines[index] = label
  return label
end

local function hideFrom(lines, first)
  for index = first, #(lines or {}) do lines[index]:Hide() end
end

local function guideFor(entry)
  if type(entry) == "table" then return ZGV.Catalog:Get(entry.id or entry.title) end
  return ZGV.Catalog:Get(entry)
end

local history = {
  ident = "guidehistory", name = "Recent Guides", group = "general",
  description = "Recently opened guides from this profile.", sizes = { { width = 3, height = 2 } },
  messages = { ZGV_GUIDE_CHANGED = true, ZGV_CATALOG_FINALIZED = true },
}
function history:Initialise(frame)
  self.buttons = {}
  for index = 1, 5 do
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -27 - (index - 1) * 27)
    button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -27 - (index - 1) * 27); button:SetHeight(23)
    button:GetFontString():SetJustifyH("LEFT")
    button:SetScript("OnClick", function(self) if self.guide then ZGV.Runtime:SelectGuide(self.guide.id or self.guide.title) end end)
    self.buttons[index] = button
  end
end
function history:Update()
  local count = 0
  for _, entry in ipairs(ZGV.db.profile.history or {}) do
    local guide = guideFor(entry)
    if guide then
      count = count + 1; local button = self.buttons[count]; if not button then break end
      button.guide = guide; button:SetText(guide.name or guide.title); button:Show()
    end
  end
  for index = count + 1, #self.buttons do self.buttons[index].guide = nil; self.buttons[index]:Hide() end
  if count == 0 then self.frame.heading:SetText("Recent Guides - none yet") else self.frame.heading:SetText("Recent Guides") end
end
function history:OnEvent() if self.active then self:Update() end end
Widgets:RegisterWidget(history)

local suggestions = {
  ident = "guidesuggest", name = "Suggested Guide", group = "general",
  description = "The best currently applicable WotLK guide.", sizes = { { width = 3, height = 1 } },
  messages = { ZGV_GUIDE_CHANGED = true, ZGV_CATALOG_FINALIZED = true },
}
function suggestions:Initialise(frame)
  self.button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  self.button:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -30); self.button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -30); self.button:SetHeight(32)
  self.button:GetFontString():SetJustifyH("LEFT")
  self.button:SetScript("OnClick", function() if suggestions.guide then ZGV.Runtime:SelectGuide(suggestions.guide.id or suggestions.guide.title) end end)
end
function suggestions:Update()
  local guide = ZGV.Runtime and ZGV.Runtime:ChooseSuggestedGuide()
  self.guide = guide; self.button:SetText(guide and (guide.name or guide.title) or "No applicable guide found")
  ZGV.Compat.UI:SetEnabled(self.button, guide ~= nil)
end
function suggestions:OnEvent() if self.active then self:Update() end end
Widgets:RegisterWidget(suggestions)

local played = {
  ident = "timeplayed", name = "Time Played", group = "general", tick = 1,
  description = "Character and current-level play time reported by build 12340.", sizes = { { width = 2, height = 1 } },
  events = { TIME_PLAYED_MSG = true },
}
function played:Initialise(frame)
  self.total = line(frame, 1, 13); self.level = line(frame, 2, 11)
  if type(RequestTimePlayed) == "function" then RequestTimePlayed() end
end
function played:Update()
  local saved = ZGV.db.char.dashboardTimePlayed or {}
  self.total:SetText("Total: " .. duration(saved.total))
  self.level:SetText("Level " .. tostring(saved.playerLevel or UnitLevel("player") or "?") .. ": " .. duration(saved.level))
end
function played:OnEvent(event, total, level)
  if event ~= "TIME_PLAYED_MSG" then return end
  ZGV.db.char.dashboardTimePlayed = { total = tonumber(total) or 0, level = tonumber(level) or 0, playerLevel = UnitLevel("player"), updated = time() }
  if self.active then self:Update() end
end
function played:OnTick()
  local saved = ZGV.db.char.dashboardTimePlayed
  if saved then saved.total = (saved.total or 0) + 1; saved.level = (saved.level or 0) + 1; saved.updated = time(); self:Update() end
end
Widgets:RegisterWidget(played)

local daily = {
  ident = "dailyreset", name = "Daily Reset", group = "dailies", tick = 1,
  description = "Time remaining to the server's daily quest reset.", sizes = { { width = 2, height = 1 } },
}
function daily:Initialise(frame) self.value = line(frame, 1, 17) end
function daily:Update()
  local seconds = type(GetQuestResetTime) == "function" and GetQuestResetTime()
  self.value:SetText(seconds and duration(seconds) or "Reset timer unavailable")
end
function daily:OnTick() self:Update() end
Widgets:RegisterWidget(daily)

local bank = {
  ident = "bank", name = "Bank Inventory", group = "general",
  description = "Summary of the most recently scanned character bank.", sizes = { { width = 2, height = 1 } },
  events = { BANKFRAME_OPENED = true, BANKFRAME_CLOSED = true, BAG_UPDATE = true },
  messages = { ZGV_INVENTORY_UPDATED = true },
}
function bank:Initialise(frame) self.summary = line(frame, 1, 13); self.updated = line(frame, 2, 10) end
function bank:Update()
  local saved, quantity = ZGV.db.char.bank or {}, 0
  for _, item in ipairs(saved) do quantity = quantity + (tonumber(item.count) or 1) end
  self.summary:SetText(string.format("%d stacks / %d items", #saved, quantity))
  local stamp = tonumber(ZGV.db.char.bankUpdated)
  self.updated:SetText(stamp and ("Scanned " .. duration(time() - stamp) .. " ago") or "Open your bank to scan")
end
function bank:OnEvent() if self.active then self:Update() end end
Widgets:RegisterWidget(bank)

local gold = {
  ident = "gold", name = "Gold Summary", group = "general",
  description = "Current money and session earnings from the WotLK Gold appraiser.", sizes = { { width = 2, height = 1 } },
  events = { PLAYER_MONEY = true }, messages = { ZGV_GOLD_UPDATED = true },
}
function gold:Initialise(frame)
  self.current = line(frame, 1, 13); self.change = line(frame, 2, 11)
  frame:SetScript("OnClick", function() if ZGV.GoldTracker then ZGV.GoldTracker:Show() end end)
end
function gold:Update()
  local session = ZGV.GoldTracker and ZGV.GoldTracker:GetSession() or {}
  local current = type(GetMoney) == "function" and GetMoney() or 0
  local net = (tonumber(session.earned) or 0) - (tonumber(session.spent) or 0)
  self.current:SetText("Current: " .. money(current))
  self.change:SetText((net >= 0 and "Session: +" or "Session: -") .. money(math.abs(net)))
end
function gold:OnEvent() if self.active then self:Update() end end
Widgets:RegisterWidget(gold)

local calendar = {
  ident = "worldevents", name = "Calendar", group = "dailies", tick = 60,
  description = "Today's Blizzard calendar events using the WotLK calendar API.", sizes = { { width = 3, height = 2 } },
  events = { CALENDAR_UPDATE_EVENT_LIST = true, PLAYER_ENTERING_WORLD = true },
  valid = function() return type(CalendarGetDate) == "function" and type(CalendarGetNumDayEvents) == "function" and type(CalendarGetDayEvent) == "function" end,
}
function calendar:Initialise(frame)
  self.lines = {}
  for index = 1, 5 do self.lines[index] = line(frame, index, index == 1 and 12 or 11) end
end
function calendar:Update()
  local _, month, day, year = CalendarGetDate()
  if type(CalendarSetAbsMonth) == "function" then CalendarSetAbsMonth(month, year) end
  local count = tonumber(CalendarGetNumDayEvents(0, day)) or 0
  local shownCount = math.min(count, #self.lines)
  for index = 1, shownCount do
    local title, hour, minute = CalendarGetDayEvent(0, day, index)
    local at = type(hour) == "number" and string.format("%02d:%02d  ", hour, tonumber(minute) or 0) or ""
    self.lines[index]:SetText(at .. tostring(title or "Calendar event")); self.lines[index]:Show()
  end
  hideFrom(self.lines, shownCount + 1)
  if shownCount == 0 then self.lines[1]:SetText("No events today"); self.lines[1]:Show() end
end
function calendar:OnEvent() if self.active then self:Update() end end
function calendar:OnTick() self:Update() end
Widgets:RegisterWidget(calendar)

ZGV.DashboardWidgets = {
  history = history, suggestions = suggestions, timePlayed = played, dailyReset = daily,
  bank = bank, gold = gold, calendar = calendar, FormatDuration = duration,
}
