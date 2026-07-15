-- Modern Classic-style gold overview and WotLK auction appraiser UI.
local addonName, addonNamespace = ...
local ZGV
if type(addonNamespace) == "table" then
  ZGV = addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV
end
if not ZGV then ZGV = _G.ZygorGuidesViewer end
if type(ZGV) ~= "table" then return end

local Gold = ZGV:RegisterModule("GoldTracker", {})
local Appraiser = ZGV.GoldAppraiser
local MAX_HISTORY = 60
local PAGE_ROWS = 9

local function profile()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.gold
end

local function money()
  return GetMoney and (GetMoney() or 0) or 0
end

local function formatMoney(amount, compact)
  amount = math.max(0, math.floor(tonumber(amount) or 0))
  local gold = math.floor(amount / 10000)
  local silver = math.floor((amount % 10000) / 100)
  local copper = amount % 100
  if compact then return string.format("%dg %02ds %02dc", gold, silver, copper) end
  return string.format("|cffffd100%dg|r |cffc7c7cf%ds|r |cffeda55f%dc|r", gold, silver, copper)
end

local function parseMoney(value)
  value = string.lower(tostring(value or "")):gsub(",", ""):gsub("%s+", "")
  if value == "" then return 0 end
  local gold = tonumber(value:match("([%d%.]+)g")) or 0
  local silver = tonumber(value:match("(%d+)s")) or 0
  local copper = tonumber(value:match("(%d+)c")) or 0
  if value:find("[gsc]") then return math.max(0, math.floor(gold * 10000 + silver * 100 + copper + .5)) end
  return math.max(0, math.floor((tonumber(value) or 0) * 10000 + .5))
end

local function makeText(parent, size, layer)
  local text = parent:CreateFontString(nil, layer or "ARTWORK", "GameFontNormal")
  local path, _, flags = GameFontNormal:GetFont()
  text:SetFont(path, size, flags)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("MIDDLE")
  return text
end

local function makeButton(parent, text, width)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetWidth(width or 90)
  button:SetHeight(22)
  button:SetText(text)
  return button
end

local function makeInput(parent, width)
  local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
  input:SetWidth(width or 120)
  input:SetHeight(22)
  input:SetAutoFocus(false)
  input:SetTextInsets(4, 4, 0, 0)
  return input
end

local function setEnabled(button, enabled)
  if enabled then button:Enable() else button:Disable() end
end

local function makePanel(parent)
  local panel = CreateFrame("Frame", nil, parent)
  panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -72)
  panel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, 10)
  return panel
end

local function makeRows(parent, onClick, width, startY)
  local rows = {}
  startY = tonumber(startY) or -34
  for index = 1, PAGE_ROWS do
    local row = CreateFrame("Button", nil, parent)
    row:SetWidth(width or 548)
    row:SetHeight(27)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, startY - (index - 1) * 29)
    row:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white" })
    row:SetBackdropColor(index % 2 == 0 and .10 or .075, index % 2 == 0 and .10 or .075, index % 2 == 0 and .10 or .075, .92)
    row:RegisterForClicks("LeftButtonUp")
    row:SetScript("OnClick", function(self) if self.data then onClick(self.data, self) end end)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(22); icon:SetHeight(22); icon:SetPoint("LEFT", row, "LEFT", 3, 0)
    row.icon = icon
    local left = makeText(row, 11)
    left:SetPoint("LEFT", icon, "RIGHT", 5, 0); left:SetWidth((width or 548) - 190); left:SetHeight(25)
    row.left = left
    local right = makeText(row, 10)
    right:SetPoint("RIGHT", row, "RIGHT", -6, 0); right:SetWidth(155); right:SetHeight(25); right:SetJustifyH("RIGHT")
    row.right = right
    rows[index] = row
  end
  return rows
end

local function populateRows(rows, data, offset, formatter, selected)
  offset = math.max(1, tonumber(offset) or 1)
  for index, row in ipairs(rows) do
    local item = data[offset + index - 1]
    row.data = item
    if item then
      local left, right, texture = formatter(item)
      row.left:SetText(left or "")
      row.right:SetText(right or "")
      row.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
      if item == selected then row:SetBackdropColor(.42, .28, .05, .95)
      else row:SetBackdropColor(index % 2 == 0 and .10 or .075, index % 2 == 0 and .10 or .075, index % 2 == 0 and .10 or .075, .92) end
      row:Show()
    else
      row:Hide()
    end
  end
end

local function attachPager(panel, previous, nextPage)
  local previousButton = makeButton(panel, "Previous", 76)
  previousButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
  previousButton:SetScript("OnClick", previous)
  local nextButton = makeButton(panel, "Next", 76)
  nextButton:SetPoint("LEFT", previousButton, "RIGHT", 5, 0)
  nextButton:SetScript("OnClick", nextPage)
  panel.previousButton, panel.nextButton = previousButton, nextButton
end

function Gold:StartSession()
  local settings = profile()
  if not settings then return end
  settings.session = { startedAt = time(), startingMoney = money(), lastMoney = money(), earned = 0, spent = 0 }
end

function Gold:GetSession()
  local settings = profile()
  local session = settings and settings.session
  if not session then self:StartSession(); session = settings and settings.session end
  return session
end

function Gold:RecordDelta()
  local settings = profile()
  local session = self:GetSession()
  if not settings or not session then return end
  local current = money()
  local prior = tonumber(session.lastMoney) or current
  local delta = current - prior
  session.lastMoney = current
  if delta == 0 then return end
  if delta > 0 then session.earned = (session.earned or 0) + delta else session.spent = (session.spent or 0) - delta end
  settings.history[#settings.history + 1] = { time = time(), delta = delta, money = current }
  while #settings.history > MAX_HISTORY do table.remove(settings.history, 1) end
  ZGV:Fire("ZGV_GOLD_UPDATED", session, delta)
  if self.frame and self.frame:IsShown() then self:RenderOverview() end
end

function Gold:SetStatus(text, color)
  if not self.frame then return end
  self.frame.status:SetText(tostring(text or ""))
  color = color or { .75, .75, .75 }
  self.frame.status:SetTextColor(color[1], color[2], color[3], 1)
end

function Gold:CreateOverview(frame)
  local panel = makePanel(frame)
  frame.views.overview = panel
  local current = makeText(panel, 15); current:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -8); panel.current = current
  local net = makeText(panel, 13); net:SetPoint("TOPLEFT", current, "BOTTOMLEFT", 0, -10); panel.net = net
  local earned = makeText(panel, 12); earned:SetPoint("TOPLEFT", net, "BOTTOMLEFT", 0, -9); panel.earned = earned
  local spent = makeText(panel, 12); spent:SetPoint("TOPLEFT", earned, "BOTTOMLEFT", 0, -6); panel.spent = spent
  local recent = makeText(panel, 11); recent:SetPoint("TOPLEFT", spent, "BOTTOMLEFT", 0, -18); recent:SetWidth(535); recent:SetHeight(75); recent:SetJustifyV("TOP"); panel.recent = recent
  local market = makeText(panel, 11); market:SetPoint("TOPLEFT", recent, "BOTTOMLEFT", 0, -12); market:SetWidth(535); market:SetHeight(60); market:SetJustifyV("TOP"); panel.market = market
  local reset = makeButton(panel, "Reset Session", 105); reset:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
  reset:SetScript("OnClick", function() Gold:StartSession(); Gold:RenderOverview() end)
end

function Gold:CreateAppraise(frame)
  local panel = makePanel(frame)
  frame.views.appraise = panel
  local search = makeInput(panel, 185); search:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -3); panel.search = search
  local scan = makeButton(panel, "Named Scan", 90); scan:SetPoint("LEFT", search, "RIGHT", 7, 0); panel.scan = scan
  scan:SetScript("OnClick", function() Gold:StartScan() end)
  search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); Gold:StartScan() end)
  local full = makeButton(panel, "Full Scan", 85); full:SetPoint("LEFT", scan, "RIGHT", 5, 0); panel.fullScan = full
  full:SetScript("OnClick", function() Gold:StartFullScan() end)
  local cancel = makeButton(panel, "Cancel", 70); cancel:SetPoint("LEFT", full, "RIGHT", 5, 0); panel.cancel = cancel
  cancel:SetScript("OnClick", function() Gold:CancelScan() end)
  local clear = makeButton(panel, "Clear", 55); clear:SetPoint("LEFT", cancel, "RIGHT", 5, 0)
  clear:SetScript("OnClick", function() search:SetText(""); Gold.pendingSearchItemID = nil end)
  panel.rows = makeRows(panel, function(item) Gold:SelectAuction(item) end)
  attachPager(panel,
    function() Gold.appraiseOffset = math.max(1, (Gold.appraiseOffset or 1) - PAGE_ROWS); Gold:RenderAppraise() end,
    function() if (Gold.appraiseOffset or 1) + PAGE_ROWS <= #(Appraiser.lastResults or {}) then Gold.appraiseOffset = (Gold.appraiseOffset or 1) + PAGE_ROWS; Gold:RenderAppraise() end end)
  local buy = makeButton(panel, "Buy Selected", 105); buy:SetPoint("LEFT", panel.nextButton, "RIGHT", 12, 0); panel.buy = buy
  buy:SetScript("OnClick", function() Gold:BuySelected() end)
  local add = makeButton(panel, "Add to Shopping", 120); add:SetPoint("LEFT", buy, "RIGHT", 5, 0); panel.add = add
  add:SetScript("OnClick", function() Gold:AddSelectedToShopping() end)
end

function Gold:CreateOpportunities(frame)
  local panel = makePanel(frame)
  frame.views.opportunities = panel
  panel.modeButtons = {}
  local modes = { { "deals", "Deals" }, { "crafting", "Crafting" }, { "guides", "Farm & Gather" } }
  for index, definition in ipairs(modes) do
    local button = makeButton(panel, definition[2], definition[1] == "guides" and 105 or 82)
    button:SetPoint("TOPLEFT", panel, "TOPLEFT", 4 + (index - 1) * 88, -3)
    button:SetScript("OnClick", function() Gold:SetOpportunityMode(definition[1]) end)
    panel.modeButtons[definition[1]] = button
  end
  local search = makeInput(panel, 160); search:SetPoint("TOPLEFT", panel, "TOPLEFT", 292, -3); panel.search = search
  search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); Gold:RenderOpportunities() end)
  local refresh = makeButton(panel, "Refresh", 82); refresh:SetPoint("LEFT", search, "RIGHT", 6, 0); panel.refresh = refresh
  refresh:SetScript("OnClick", function() Gold:RefreshOpportunities() end)
  local hint = makeText(panel, 9); hint:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -31); hint:SetWidth(530); hint:SetHeight(22); panel.hint = hint
  panel.rows = makeRows(panel, function(item) Gold:SelectOpportunity(item) end, 548, -56)
  attachPager(panel,
    function() Gold.opportunityOffset = math.max(1, (Gold.opportunityOffset or 1) - PAGE_ROWS); Gold:RenderOpportunities() end,
    function() if (Gold.opportunityOffset or 1) + PAGE_ROWS <= #(Gold.opportunityItems or {}) then Gold.opportunityOffset = (Gold.opportunityOffset or 1) + PAGE_ROWS; Gold:RenderOpportunities() end end)
  local use = makeButton(panel, "Inspect Item", 115); use:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0); use:SetScript("OnClick", function() Gold:UseOpportunity() end); panel.use = use
end

function Gold:CreateHelp(frame)
  local panel = makePanel(frame)
  panel:SetFrameLevel(frame:GetFrameLevel() + 8)
  panel:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white", edgeSize = 1 })
  panel:SetBackdropColor(.045, .045, .045, .995); panel:SetBackdropBorderColor(.42, .32, .12, 1)
  local title = makeText(panel, 14); title:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10); title:SetText("Gold Guide help & safety")
  local body = makeText(panel, 11); body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12); body:SetWidth(515); body:SetHeight(285); body:SetJustifyV("TOP")
  body:SetText(Appraiser and Appraiser:GetHelpText() or "Gold help is unavailable.")
  local close = makeButton(panel, "Back", 85); close:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 8); close:SetScript("OnClick", function() Gold:ToggleHelp(false) end)
  panel:Hide(); frame.helpPanel = panel
end

function Gold:CreateShopping(frame)
  local panel = makePanel(frame)
  frame.views.shopping = panel
  local heading = makeText(panel, 11); heading:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -4); heading:SetText("Current guide purchases and your saved shopping list")
  panel.rows = makeRows(panel, function(item) Gold:SelectShopping(item) end)
  attachPager(panel,
    function() Gold.shoppingOffset = math.max(1, (Gold.shoppingOffset or 1) - PAGE_ROWS); Gold:RenderShopping() end,
    function() if (Gold.shoppingOffset or 1) + PAGE_ROWS <= #(Gold.shoppingItems or {}) then Gold.shoppingOffset = (Gold.shoppingOffset or 1) + PAGE_ROWS; Gold:RenderShopping() end end)
  local remove = makeButton(panel, "Remove Manual", 110); remove:SetPoint("LEFT", panel.nextButton, "RIGHT", 12, 0); panel.remove = remove
  remove:SetScript("OnClick", function()
    if Gold.selectedShopping and Gold.selectedShopping.source ~= "guide" then
      Appraiser:RemoveShoppingItem(Gold.selectedShopping.itemID); Gold.selectedShopping = nil; Gold:RenderShopping()
    end
  end)
  local appraise = makeButton(panel, "Appraise Item", 105); appraise:SetPoint("LEFT", remove, "RIGHT", 5, 0)
  appraise:SetScript("OnClick", function() Gold:AppraiseShopping() end)
end

local function addLabeledInput(panel, label, x, y, width)
  local caption = makeText(panel, 10); caption:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y); caption:SetText(label)
  local input = makeInput(panel, width); input:SetPoint("TOPLEFT", caption, "BOTTOMLEFT", 0, -2)
  return input
end

function Gold:CreatePost(frame)
  local panel = makePanel(frame)
  frame.views.post = panel
  local heading = makeText(panel, 11); heading:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -4); heading:SetText("Unbound bag inventory (ranked by appraised value)")
  panel.rows = makeRows(panel, function(item) Gold:SelectInventory(item) end, 330)
  panel.rows[1]:ClearAllPoints()
  for index, row in ipairs(panel.rows) do
    row:ClearAllPoints(); row:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -34 - (index - 1) * 29)
    row.left:SetWidth(195); row.right:SetWidth(100)
  end
  local refresh = makeButton(panel, "Refresh Bags", 95); refresh:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 0)
  refresh:SetScript("OnClick", function() Gold:RefreshInventory() end)
  local previous = makeButton(panel, "Prev", 55); previous:SetPoint("LEFT", refresh, "RIGHT", 5, 0)
  previous:SetScript("OnClick", function() Gold.inventoryOffset = math.max(1, (Gold.inventoryOffset or 1) - PAGE_ROWS); Gold:RenderPost() end)
  local nextPage = makeButton(panel, "Next", 55); nextPage:SetPoint("LEFT", previous, "RIGHT", 5, 0)
  nextPage:SetScript("OnClick", function() if (Gold.inventoryOffset or 1) + PAGE_ROWS <= #(Gold.inventoryItems or {}) then Gold.inventoryOffset = (Gold.inventoryOffset or 1) + PAGE_ROWS; Gold:RenderPost() end end)

  local selected = makeText(panel, 11); selected:SetPoint("TOPLEFT", panel, "TOPLEFT", 345, -36); selected:SetWidth(195); selected:SetHeight(36); selected:SetJustifyV("TOP"); panel.selected = selected
  panel.unitBid = addLabeledInput(panel, "Unit bid (12g 34s)", 345, -86, 185)
  panel.unitBuyout = addLabeledInput(panel, "Unit buyout", 345, -137, 185)
  panel.stackSize = addLabeledInput(panel, "Stack size", 345, -188, 85)
  panel.stackCount = addLabeledInput(panel, "Stacks", 445, -188, 85)
  panel.duration = addLabeledInput(panel, "Duration (12/24/48)", 345, -239, 185)
  local warning = makeText(panel, 9); warning:SetPoint("TOPLEFT", panel, "TOPLEFT", 345, -292); warning:SetWidth(195); warning:SetHeight(45); warning:SetJustifyV("TOP")
  warning:SetText("Place the selected item in Blizzard's auction sell slot, review every value, then click Post. Zygor never picks up or posts items automatically.")
  warning:SetTextColor(1, .74, .25, 1)
  local post = makeButton(panel, "Post Auction", 110); post:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0); panel.post = post
  post:SetScript("OnClick", function() Gold:PostSelected() end)
end

function Gold:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "ZygorGuidesViewerGoldTracker", UIParent)
  frame:SetWidth(590); frame:SetHeight(475); frame:SetPoint("CENTER", UIParent, "CENTER", 155, -10)
  frame:SetFrameStrata("DIALOG"); frame:SetToplevel(true); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  frame:SetScript("OnShow", function() Gold:Render() end)
  frame:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white", edgeSize = 1 })
  frame:SetBackdropColor(.055, .055, .055, .98); frame:SetBackdropBorderColor(.30, .24, .12, 1); frame:Hide()
  self.frame = frame
  frame.views, frame.tabs = {}, {}

  local icon = frame:CreateTexture(nil, "ARTWORK"); icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -8); icon:SetWidth(24); icon:SetHeight(24)
  icon:SetTexture(ZGV.SKINDIR .. "icons-gold"); icon:SetTexCoord(0, .125, 0, 1)
  local title = makeText(frame, 14); title:SetPoint("LEFT", icon, "RIGHT", 7, 0); title:SetText("Gold Guide & Appraiser")
  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2); close:SetScript("OnClick", function() frame:Hide() end)
  local help = makeButton(frame, "?", 24); help:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -29, -9); help:SetScript("OnClick", function() Gold:ToggleHelp() end)
  local status = makeText(frame, 10); status:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -59, -14); status:SetWidth(250); status:SetJustifyH("RIGHT"); frame.status = status

  local tabs = { { "overview", "Overview" }, { "appraise", "Appraise" }, { "shopping", "Shopping" }, { "opportunities", "Opportunities" }, { "post", "Post" } }
  for index, definition in ipairs(tabs) do
    local button = makeButton(frame, definition[2], 108)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + (index - 1) * 112, -42)
    button:SetScript("OnClick", function() Gold:SetTab(definition[1]) end)
    frame.tabs[definition[1]] = button
  end
  self:CreateOverview(frame); self:CreateAppraise(frame); self:CreateShopping(frame); self:CreateOpportunities(frame); self:CreatePost(frame); self:CreateHelp(frame)
  self:SetTab("overview")
  return frame
end

function Gold:ToggleHelp(show)
  if not self.frame then return end
  local panel = self.frame.helpPanel
  show = show == nil and not panel:IsShown() or show
  if show then
    for _, view in pairs(self.frame.views) do view:Hide() end
    panel:Show()
  else
    panel:Hide()
    local current = self.frame.views[self.currentTab]
    if current then current:Show() end
  end
end

function Gold:SetTab(name)
  if self.frame.helpPanel then self.frame.helpPanel:Hide() end
  self.currentTab = name
  for id, panel in pairs(self.frame.views) do
    if id == name then panel:Show() else panel:Hide() end
    if self.frame.tabs[id] then
      if id == name then self.frame.tabs[id]:Disable() else self.frame.tabs[id]:Enable() end
    end
  end
  self:Render()
end

function Gold:RenderOverview()
  if not self.frame then return end
  local panel = self.frame.views.overview
  local session = self:GetSession()
  if not session then return end
  local current = money()
  local net = current - (session.startingMoney or current)
  panel.current:SetText("Current: " .. formatMoney(current))
  panel.net:SetText("Session: " .. (net >= 0 and "+" or "-") .. formatMoney(math.abs(net)))
  panel.net:SetTextColor(net >= 0 and .25 or 1, net >= 0 and 1 or .25, .25, 1)
  panel.earned:SetText("Earned: " .. formatMoney(session.earned or 0))
  panel.spent:SetText("Spent: " .. formatMoney(session.spent or 0))
  local recent = profile().history
  local lines = {}
  for index = #recent, math.max(1, #recent - 3), -1 do
    local item = recent[index]
    lines[#lines + 1] = (item.delta >= 0 and "+" or "-") .. formatMoney(math.abs(item.delta))
  end
  panel.recent:SetText(#lines > 0 and ("Recent changes:\n" .. table.concat(lines, "   ")) or "Recent changes: none this session")
  local market = Appraiser and Appraiser:GetMarket(false)
  local scanCount = market and #market.scans or 0
  local itemCount = 0
  if market then for _ in pairs(market.items or {}) do itemCount = itemCount + 1 end end
  local full = Appraiser and Appraiser:GetScanStatus() or {}
  local fullText = full.kind == "full" and string.format(" Full scan: %s, %d rows.", full.state or "idle", full.rows or 0) or ""
  panel.market:SetText(string.format("Realm/faction trend history: %d scans, %d appraised items.%s\nOpen an Auction House before scanning, buying, or posting.", scanCount, itemCount, fullText))
end

function Gold:RenderAppraise()
  if not self.frame then return end
  local panel = self.frame.views.appraise
  local results = Appraiser and Appraiser.lastResults or {}
  populateRows(panel.rows, results, self.appraiseOffset, function(item)
    local kind = item.unitBuyout > 0 and "buyout" or "bid"
    return string.format("%s x%d  |cff888888%s|r", item.name, item.count, item.owner or "?"), formatMoney(item.unitPrice) .. " /ea " .. kind, item.texture
  end, self.selectedAuction)
  setEnabled(panel.buy, self.selectedAuction ~= nil)
  setEnabled(panel.add, self.selectedAuction and self.selectedAuction.itemID ~= nil)
  local scan = Appraiser and Appraiser:GetScanStatus() or {}
  setEnabled(panel.scan, not scan.active)
  setEnabled(panel.fullScan, not scan.active)
  setEnabled(panel.cancel, scan.active)
end

function Gold:RenderShopping()
  if not self.frame or not Appraiser then return end
  self.shoppingItems = Appraiser:BuildShoppingList()
  local panel = self.frame.views.shopping
  populateRows(panel.rows, self.shoppingItems, self.shoppingOffset, function(item)
    local source = item.source == "guide" and "guide" or item.source == "manual" and "saved" or "saved + guide"
    local price = item.unitPrice > 0 and formatMoney(item.totalPrice) or "no price"
    return string.format("%dx %s  |cff888888%s|r", item.count, item.name, source), price, item.texture
  end, self.selectedShopping)
  setEnabled(panel.remove, self.selectedShopping and self.selectedShopping.source ~= "guide")
end

local function filterNamed(items, search)
  search = string.lower(tostring(search or ""))
  if search == "" then return items or {} end
  local filtered = {}
  for _, item in ipairs(items or {}) do
    if string.lower(tostring(item.name or item.title or "")):find(search, 1, true) then filtered[#filtered + 1] = item end
  end
  return filtered
end

function Gold:SetOpportunityMode(mode)
  self.opportunityMode = mode
  self.selectedOpportunity = nil
  self.opportunityOffset = 1
  self:RenderOpportunities()
end

function Gold:RefreshOpportunities()
  if not Appraiser then return end
  local mode = self.opportunityMode or "deals"
  if mode == "deals" then
    Appraiser.lastOpportunities = Appraiser:BuildAuctionOpportunities(Appraiser.lastFullResults or {})
    self:SetStatus("Deal list refreshed from the last full scan", { .25, 1, .25 })
  elseif mode == "crafting" then
    local refreshed = Appraiser:RefreshCraftingProfits()
    self:SetStatus(refreshed.ok and ("Crafting profit refreshed: " .. tostring(#refreshed.profits)) or "Open a profession recipe window, then Refresh", refreshed.ok and { .25, 1, .25 } or { 1, .72, .2 })
  else
    self:SetStatus("Farm and gathering guides refreshed from the loaded Catalog", { .25, 1, .25 })
  end
  self.selectedOpportunity = nil
  self.opportunityOffset = 1
  self:RenderOpportunities()
end

function Gold:RenderOpportunities()
  if not self.frame or not Appraiser then return end
  local panel = self.frame.views.opportunities
  local mode = self.opportunityMode or "deals"
  self.opportunityMode = mode
  for name, button in pairs(panel.modeButtons) do if name == mode then button:Disable() else button:Enable() end end
  local search = panel.search:GetText() or ""
  if mode == "deals" then
    self.opportunityItems = filterNamed(Appraiser.lastOpportunities or {}, search)
    panel.hint:SetText("Informational trend deals from the last full scan. Inspect runs a fresh named scan before any buy is allowed.")
    panel.use:SetText("Inspect Item")
  elseif mode == "crafting" then
    self.opportunityItems = filterNamed(Appraiser.lastCraftingProfits or {}, search)
    panel.hint:SetText("Known recipes from the profession window, priced from realm trends after the Auction House cut.")
    panel.use:SetText("Appraise Product")
  else
    self.opportunityItems = Appraiser:DiscoverGoldGuides(search)
    panel.hint:SetText("Farming and gathering routes discovered in the currently loaded guide Catalog.")
    panel.use:SetText("Load Guide")
  end
  populateRows(panel.rows, self.opportunityItems, self.opportunityOffset, function(item)
    if mode == "deals" then
      return string.format("%s x%d  |cff888888%d samples|r", item.name or "Item", item.count or 1, item.trendSamples or 0), string.format("%d%% below; %s", math.floor((item.discount or 0) * 100 + .5), formatMoney(item.potential or 0)), item.texture
    elseif mode == "crafting" then
      local profit = tonumber(item.profit) or 0
      return string.format("%s  |cff888888cost %s|r", item.name or "Recipe", formatMoney(item.cost or 0)), profit >= 0 and ("+" .. formatMoney(profit)) or ("-" .. formatMoney(math.abs(profit))), item.texture
    end
    return item.name or item.title, item.kind == "gathering" and "Gathering" or "Farming", "Interface\\Icons\\INV_Misc_Map_01"
  end, self.selectedOpportunity)
  setEnabled(panel.use, self.selectedOpportunity ~= nil)
end

function Gold:SelectOpportunity(item)
  self.selectedOpportunity = item
  self:RenderOpportunities()
end

function Gold:UseOpportunity()
  local item = self.selectedOpportunity
  if not item or not Appraiser then return end
  if self.opportunityMode == "guides" then
    local loaded = Appraiser:LoadGoldGuide(item, true)
    self:SetStatus(loaded.ok and "Gold route loaded in the viewer" or ("Guide: " .. tostring(loaded.code)), loaded.ok and { .25, 1, .25 } or { 1, .25, .25 })
    if loaded.ok then self.frame:Hide() end
    return
  end
  self.frame.views.appraise.search:SetText(item.name or "")
  self.pendingSearchItemID = item.itemID or item.productID
  self:SetTab("appraise")
  self:SetStatus("Press Named Scan to inspect live auctions; full-scan rows cannot be bought", { 1, .72, .2 })
end

function Gold:RefreshInventory()
  self.inventoryItems = Appraiser and Appraiser:BuildInventoryList() or {}
  self.inventoryOffset = 1
  self:RenderPost()
end

function Gold:RenderPost()
  if not self.frame then return end
  local panel = self.frame.views.post
  self.inventoryItems = self.inventoryItems or (Appraiser and Appraiser:BuildInventoryList()) or {}
  populateRows(panel.rows, self.inventoryItems, self.inventoryOffset, function(item)
    return string.format("%s x%d", item.name, item.count), item.unitPrice > 0 and (formatMoney(item.totalPrice) .. " total") or "no price", item.texture
  end, self.selectedInventory)
  panel.selected:SetText(self.selectedInventory and (self.selectedInventory.name .. "\n" .. formatMoney(self.selectedInventory.unitPrice) .. " suggested /ea") or "Select an inventory item to appraise for posting.")
  setEnabled(panel.post, self.selectedInventory ~= nil)
end

function Gold:Render()
  if not self.frame then return end
  if self.currentTab == "overview" then self:RenderOverview()
  elseif self.currentTab == "appraise" then self:RenderAppraise()
  elseif self.currentTab == "shopping" then self:RenderShopping()
  elseif self.currentTab == "opportunities" then self:RenderOpportunities()
  elseif self.currentTab == "post" then self:RenderPost() end
end

function Gold:StartScan()
  if not Appraiser then return end
  local name = self.frame.views.appraise.search:GetText()
  local started = Appraiser:StartNamedScan(name, self.pendingSearchItemID)
  if started.ok then self:SetStatus(started.code == "query_queued" and "Scan queued for server throttle" or "Named scan sent", { 1, .72, .2 })
  else self:SetStatus("Scan: " .. tostring(started.code), { 1, .25, .25 }) end
end

function Gold:StartFullScan()
  if not Appraiser then return end
  local started = Appraiser:StartFullScan(true, true)
  if started.ok then self:SetStatus("Full Auction House scan started; Cancel remains available", { 1, .72, .2 })
  else self:SetStatus("Full scan: " .. tostring(started.code), { 1, .25, .25 }) end
  self:RenderAppraise()
end

function Gold:CancelScan()
  if not Appraiser then return end
  Appraiser:CancelScan("query_cancelled")
  self:SetStatus("Auction scan cancelled", { 1, .72, .2 })
  self:RenderAppraise()
end

function Gold:SelectAuction(item)
  self.selectedAuction = item
  self:RenderAppraise()
  local status = Appraiser:GetPriceStatus(item.itemID, item.unitPrice)
  self:SetStatus(status.text, (status.code == "down" or status.code == "dumped") and { .25, 1, .25 } or nil)
end

function Gold:BuySelected()
  if not self.selectedAuction then return end
  local action = Appraiser:Bid(self.selectedAuction, true)
  self:SetStatus(action.ok and "Bid/buyout requested" or ("Buy: " .. tostring(action.code)), action.ok and { .25, 1, .25 } or { 1, .25, .25 })
end

function Gold:AddSelectedToShopping()
  local item = self.selectedAuction
  if not item or not item.itemID then return end
  local added = Appraiser:AddShoppingItem(item.itemID, 1, item.name)
  self:SetStatus(added.ok and "Added to saved shopping" or tostring(added.code), added.ok and { .25, 1, .25 } or { 1, .25, .25 })
end

function Gold:SelectShopping(item)
  self.selectedShopping = item
  self:RenderShopping()
  self:SetStatus("Shopping item selected", { 1, .72, .2 })
end

function Gold:AppraiseShopping()
  local item = self.selectedShopping
  if not item then return end
  self.frame.views.appraise.search:SetText(item.name or "")
  self.pendingSearchItemID = item.itemID
  self:SetTab("appraise")
  self:SetStatus("Shopping item selected; press Scan by Name", { 1, .72, .2 })
end

function Gold:SelectInventory(item)
  self.selectedInventory = item
  local panel = self.frame.views.post
  local settings = profile().post
  local suggested = math.max(0, tonumber(item.unitPrice) or 0)
  panel.unitBid:SetText(formatMoney(suggested, true))
  panel.unitBuyout:SetText(formatMoney(suggested, true))
  panel.stackSize:SetText(tostring(math.min(item.count, tonumber(item.maxStack) or 1, tonumber(settings.stackSize) or 1)))
  panel.stackCount:SetText(tostring(tonumber(settings.stackCount) or 1))
  panel.duration:SetText(tostring(tonumber(settings.duration) or 24))
  self:RenderPost()
end

function Gold:PostSelected()
  local item = self.selectedInventory
  if not item then return end
  local panel = self.frame.views.post
  local options = {
    itemID = item.itemID,
    unitBid = parseMoney(panel.unitBid:GetText()),
    unitBuyout = parseMoney(panel.unitBuyout:GetText()),
    stackSize = tonumber(panel.stackSize:GetText()),
    stackCount = tonumber(panel.stackCount:GetText()),
    duration = tonumber(panel.duration:GetText()),
  }
  local action = Appraiser:Post(options, true)
  if action.ok then
    local settings = profile().post
    settings.stackSize, settings.stackCount, settings.duration = options.stackSize, options.stackCount, options.duration
  end
  self:SetStatus(action.ok and "Auction post requested" or ("Post: " .. tostring(action.code)), action.ok and { .25, 1, .25 } or { 1, .25, .25 })
end

function Gold:OnScanStatus(code)
  local status = Appraiser and Appraiser:GetScanStatus() or {}
  local labels = {
    query_queued = "Waiting for auction query throttle", query_sent = "Named scan sent", query_timeout = "Auction scan timed out", auction_house_closed = "Auction House closed",
    full_scan_started = "Full scan started", full_scan_queued = "Full scan waiting for server throttle", full_scan_page_sent = "Full scan query sent",
    full_scan_page_received = string.format("Full scan page %d/%s: %d rows", status.page or 0, status.pages and status.pages > 0 and status.pages or "?", status.rows or 0),
    full_scan_complete = string.format("Full scan complete: %d rows", status.rows or 0), full_scan_timeout = "Full scan stopped at its time limit",
    full_scan_page_limit = "Full scan stopped at its page safety limit", full_scan_row_limit = "Full scan stopped at its row safety limit",
    full_scan_duplicate_page = "Full scan stopped: server repeated an auction page", query_cancelled = "Auction scan cancelled",
  }
  local failed = code == "query_timeout" or code == "full_scan_timeout" or code == "full_scan_page_limit" or code == "full_scan_row_limit" or code == "full_scan_duplicate_page"
  self:SetStatus(labels[code] or tostring(code), failed and { 1, .25, .25 } or { 1, .72, .2 })
  self:RenderAppraise()
end

function Gold:OnScanComplete(records)
  self.selectedAuction = nil
  self.appraiseOffset = 1
  self:SetStatus(string.format("Scan complete: %d exact-name auctions", #(records or {})), { .25, 1, .25 })
  self:RenderAppraise(); self:RenderShopping(); self:RefreshInventory()
end

function Gold:OnFullScanComplete(records, opportunities)
  Appraiser.lastOpportunities = opportunities or Appraiser:BuildAuctionOpportunities(records)
  self.selectedOpportunity = nil
  self.opportunityOffset = 1
  self:SetStatus(string.format("Full scan complete: %d rows, %d trend deals", #(records or {}), #(Appraiser.lastOpportunities or {})), { .25, 1, .25 })
  self:RenderOverview()
  if self.currentTab == "opportunities" then self:RenderOpportunities() end
end

function Gold:Show()
  self:Create(); self.frame:Show(); self:Render()
end

function Gold:OnStartup()
  if not self:GetSession() then self:StartSession() end
end

function Gold:OnEvent(event)
  if event == "PLAYER_MONEY" then self:RecordDelta()
  elseif event == "PLAYER_ENTERING_WORLD" then self:GetSession()
  elseif event == "BAG_UPDATE" and self.frame and self.frame:IsShown() and self.currentTab == "post" then self:RefreshInventory() end
end

local registered, registrationError = pcall(function()
  ZGV:RegisterEvent("PLAYER_MONEY", Gold, "OnEvent")
  ZGV:RegisterEvent("PLAYER_ENTERING_WORLD", Gold, "OnEvent")
  ZGV:RegisterEvent("BAG_UPDATE", Gold, "OnEvent")
  ZGV:RegisterCallback("ZGV_GOLD_SCAN_STATUS", Gold, "OnScanStatus")
  ZGV:RegisterCallback("ZGV_GOLD_SCAN_COMPLETE", Gold, "OnScanComplete")
  ZGV:RegisterCallback("ZGV_GOLD_FULL_SCAN_COMPLETE", Gold, "OnFullScanComplete")
  ZGV:RegisterCallback("ZGV_GOLD_SHOPPING_UPDATED", Gold, "RenderShopping")
  ZGV:RegisterCallback("ZGV_GUIDE_CHANGED", Gold, "RenderShopping")
  ZGV:RegisterCallback("ZGV_STEP_CHANGED", Gold, "RenderShopping")
  ZGV:RegisterCallback("ZGV_GOAL_UPDATED", Gold, "RenderShopping")
end)
if not registered and ZGV.LogError then ZGV:LogError("load: ModernGoldTracker", registrationError) end
