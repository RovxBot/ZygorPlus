-- WotLK auction appraisal model. Queries and actions are routed exclusively
-- through Compat.Auction; no purchase, post, or bag pickup is automatic.
local addonName, addonNamespace = ...
local ZGV
if type(addonNamespace) == "table" then
  ZGV = addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV
end
if not ZGV then ZGV = _G.ZygorGuidesViewer end
if type(ZGV) ~= "table" or not ZGV.Compat then return end

local Appraiser = ZGV:RegisterModule("GoldAppraiser", {})
local Compat = ZGV.Compat
local Auction = Compat.Auction
local MAX_RESULT_AGE = 60
local AUCTIONS_PER_PAGE = tonumber(_G.NUM_AUCTION_ITEMS_PER_PAGE) or 50

local function wallTime()
  return type(time) == "function" and time() or math.floor(Compat.Now())
end

local function trim(value)
  value = tostring(value or "")
  return value:match("^%s*(.-)%s*$") or ""
end

local function profile()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.gold
end

local function copyArray(source)
  local result = {}
  for index = 1, #(source or {}) do result[index] = source[index] end
  return result
end

local function median(values)
  values = copyArray(values)
  if #values == 0 then return 0 end
  table.sort(values)
  local middle = math.floor((#values + 1) / 2)
  if #values % 2 == 1 then return values[middle] end
  return math.floor((values[middle] + values[middle + 1]) / 2 + .5)
end

local function weightedPercentile(records, percentile)
  local total = 0
  for _, record in ipairs(records) do total = total + math.max(1, tonumber(record.count) or 1) end
  if total == 0 then return 0 end
  local threshold = math.max(1, math.ceil(total * percentile))
  local seen = 0
  for _, record in ipairs(records) do
    seen = seen + math.max(1, tonumber(record.count) or 1)
    if seen >= threshold then return tonumber(record.unitPrice) or 0 end
  end
  return tonumber(records[#records] and records[#records].unitPrice) or 0
end

local function result(ok, code, fields)
  return Compat:Result(ok, code, fields)
end

function Appraiser:MarketKey()
  local realm = type(GetRealmName) == "function" and GetRealmName() or "Unknown Realm"
  local faction = type(UnitFactionGroup) == "function" and UnitFactionGroup("player") or "Neutral"
  return tostring(realm) .. "\031" .. tostring(faction or "Neutral")
end

function Appraiser:GetMarket(create)
  if not (ZGV.db and ZGV.db.global) then return nil end
  local all = ZGV.db.global.trendData
  if type(all) ~= "table" then
    if not create then return nil end
    all = {}
    ZGV.db.global.trendData = all
  end
  local key = self:MarketKey()
  local market = all[key]
  if type(market) ~= "table" and create then
    market = { schema = 1, key = key, items = {}, scans = {}, lastScan = 0 }
    all[key] = market
  end
  if market then
    market.items = type(market.items) == "table" and market.items or {}
    market.scans = type(market.scans) == "table" and market.scans or {}
  end
  return market
end

function Appraiser:NormalizeAuctions(items, expectedName, expectedItemID)
  local records = {}
  local wantedName = string.lower(trim(expectedName))
  local wantedID = tonumber(expectedItemID)
  for _, item in ipairs(items or {}) do
    local itemID = tonumber(item.itemID)
    local name = trim(item.name)
    local nameMatches = wantedName == "" or string.lower(name) == wantedName
    local idMatches = not wantedID or itemID == wantedID
    local count = math.max(0, tonumber(item.count) or 0)
    if item.ready and count > 0 and nameMatches and idMatches then
      local buyout = math.max(0, tonumber(item.buyoutPrice) or 0)
      local bid = math.max(0, tonumber(item.bidAmount) or 0)
      local minimum = math.max(0, tonumber(item.minBid) or 0)
      local increment = math.max(0, tonumber(item.minIncrement) or 0)
      local nextBid = bid > 0 and (bid + increment) or minimum
      local unitBuyout = buyout > 0 and math.floor(buyout / count + .5) or 0
      local unitBid = nextBid > 0 and math.floor(nextBid / count + .5) or 0
      records[#records + 1] = {
        index = tonumber(item.index),
        itemID = itemID,
        name = name,
        itemLink = item.itemLink or item.hyperlink,
        texture = item.texture or item.iconFileID,
        quality = tonumber(item.quality),
        count = count,
        buyoutPrice = buyout,
        unitBuyout = unitBuyout,
        nextBid = nextBid,
        unitBid = unitBid,
        unitPrice = unitBuyout > 0 and unitBuyout or unitBid,
        owner = item.owner,
        highBidder = item.highBidder and true or false,
        timeLeft = tonumber(item.timeLeft),
      }
    end
  end
  table.sort(records, function(a, b)
    local aBuy, bBuy = a.unitBuyout > 0, b.unitBuyout > 0
    if aBuy ~= bBuy then return aBuy end
    if a.unitPrice ~= b.unitPrice then return a.unitPrice < b.unitPrice end
    if a.count ~= b.count then return a.count > b.count end
    return (a.index or 0) < (b.index or 0)
  end)
  return records
end

function Appraiser:Summarize(records)
  local marketRecords = {}
  local quantity = 0
  for _, record in ipairs(records or {}) do
    if (record.unitBuyout or 0) > 0 then
      marketRecords[#marketRecords + 1] = record
      quantity = quantity + math.max(1, record.count or 1)
    end
  end
  table.sort(marketRecords, function(a, b) return a.unitBuyout < b.unitBuyout end)
  if #marketRecords == 0 then
    return { ready = false, auctions = #(records or {}), buyoutAuctions = 0, quantity = 0, low = 0, median = 0, high = 0 }
  end
  for _, record in ipairs(marketRecords) do record.unitPrice = record.unitBuyout end
  return {
    ready = true,
    auctions = #(records or {}),
    buyoutAuctions = #marketRecords,
    quantity = quantity,
    low = weightedPercentile(marketRecords, .10),
    median = weightedPercentile(marketRecords, .50),
    high = weightedPercentile(marketRecords, .90),
  }
end

local function rebuildTrend(entry)
  local lows, medians, highs, quantities = {}, {}, {}, {}
  for _, sample in ipairs(entry.samples or {}) do
    lows[#lows + 1] = tonumber(sample.low) or 0
    medians[#medians + 1] = tonumber(sample.median) or 0
    highs[#highs + 1] = tonumber(sample.high) or 0
    quantities[#quantities + 1] = tonumber(sample.quantity) or 0
  end
  entry.pLow = median(lows)
  entry.pMedian = median(medians)
  entry.pHigh = median(highs)
  entry.qMedian = median(quantities)
  entry.sampleCount = #medians
end

function Appraiser:RecordScan(query, records)
  query = query or {}
  local at = wallTime()
  local groups = {}
  for _, record in ipairs(records or {}) do
    if record.itemID then
      groups[record.itemID] = groups[record.itemID] or {}
      groups[record.itemID][#groups[record.itemID] + 1] = record
    end
  end
  local market = self:GetMarket(true)
  local settings = profile()
  if settings then
    settings.appraisals = type(settings.appraisals) == "table" and settings.appraisals or {}
    settings.scans = type(settings.scans) == "table" and settings.scans or {}
  end
  local maxSamples = settings and settings.trend and tonumber(settings.trend.maxSamples) or 20
  local maxScans = settings and settings.trend and tonumber(settings.trend.maxScans) or 40
  local scanRecord = {
    at = at,
    name = trim(query.name),
    itemID = tonumber(query.itemID),
    resultCount = #(records or {}),
    itemCount = 0,
  }
  local summaries = {}
  for itemID, itemRecords in pairs(groups) do
    local summary = self:Summarize(itemRecords)
    summary.at = at
    summary.itemID = itemID
    summary.name = itemRecords[1] and itemRecords[1].name or query.name
    summaries[itemID] = summary
    scanRecord.itemCount = scanRecord.itemCount + 1
    if summary.ready and market then
      local entry = market.items[itemID]
      if type(entry) ~= "table" then entry = { itemID = itemID, samples = {} }; market.items[itemID] = entry end
      entry.samples = type(entry.samples) == "table" and entry.samples or {}
      entry.name = summary.name
      entry.lastScan = at
      entry.last = summary
      entry.samples[#entry.samples + 1] = {
        at = at,
        low = summary.low,
        median = summary.median,
        high = summary.high,
        quantity = summary.quantity,
        auctions = summary.buyoutAuctions,
      }
      while #entry.samples > math.max(1, maxSamples) do table.remove(entry.samples, 1) end
      rebuildTrend(entry)
    end
    if settings then settings.appraisals[itemID] = summary end
  end
  if market then
    market.lastScan = at
    market.scans[#market.scans + 1] = scanRecord
    while #market.scans > math.max(1, maxScans) do table.remove(market.scans, 1) end
  end
  if settings then
    settings.scans[#settings.scans + 1] = scanRecord
    while #settings.scans > math.max(1, maxScans) do table.remove(settings.scans, 1) end
  end
  return summaries, scanRecord
end

function Appraiser:GetTrend(itemID)
  local market = self:GetMarket(false)
  return market and market.items and market.items[tonumber(itemID)] or nil
end

function Appraiser:GetPrice(itemID)
  itemID = tonumber(itemID)
  local settings = profile()
  local appraisal = settings and settings.appraisals and settings.appraisals[itemID]
  local maxAge = settings and tonumber(settings.appraisalMaxAge) or 7200
  if appraisal and appraisal.ready and wallTime() - (tonumber(appraisal.at) or 0) <= maxAge then
    return { itemID = itemID, unitPrice = appraisal.low, source = "scan", at = appraisal.at, appraisal = appraisal }
  end
  local trend = self:GetTrend(itemID)
  if trend and (trend.pMedian or 0) > 0 then
    return { itemID = itemID, unitPrice = trend.pMedian, source = "trend", at = trend.lastScan, trend = trend }
  end
  return { itemID = itemID, unitPrice = 0, source = "none" }
end

function Appraiser:GetSellPrice(itemID, count)
  count = math.max(1, tonumber(count) or 1)
  local price = self:GetPrice(itemID)
  local settings = profile()
  local undercut = settings and tonumber(settings.undercutCopper) or 1
  local unitPrice = price.unitPrice > 0 and math.max(1, price.unitPrice - math.max(0, undercut)) or 0
  return { itemID = tonumber(itemID), count = count, unitPrice = unitPrice, total = unitPrice * count, source = price.source, empty = unitPrice == 0 }
end

function Appraiser:GetPriceStatus(itemID, unitPrice)
  unitPrice = tonumber(unitPrice) or 0
  local trend = self:GetTrend(itemID)
  local baseline = trend and tonumber(trend.pMedian) or 0
  if baseline <= 0 then return { code = "no_data", text = "No realm trend", ratio = 0 } end
  if unitPrice <= 0 then return { code = "empty", text = "No buyout", ratio = 0 } end
  local ratio = unitPrice / baseline
  if ratio <= .60 then return { code = "dumped", text = "Well below trend", ratio = ratio }
  elseif ratio <= .85 then return { code = "down", text = "Below trend", ratio = ratio }
  elseif ratio >= 1.20 then return { code = "gouged", text = "Well above trend", ratio = ratio }
  elseif ratio >= 1.15 then return { code = "up", text = "Above trend", ratio = ratio }
  end
  return { code = "normal", text = "Near trend", ratio = ratio }
end

function Appraiser:GetItemStackInfo(item)
  local info = Compat.Item and Compat.Item:GetInfo(item) or {}
  return {
    itemID = tonumber(info.itemID),
    name = info.name,
    itemLink = info.itemLink or info.hyperlink,
    texture = info.texture or info.iconFileID,
    maxStack = tonumber(info.maxStack),
    ready = info.ready and true or false,
    reason = info.reason,
  }
end

function Appraiser:BuildAuctionOpportunities(records, options)
  options = options or {}
  local settings = profile()
  local configured = settings and settings.opportunities or {}
  local minDiscount = tonumber(options.minDiscount) or tonumber(configured.minDiscount) or .15
  local minPotential = tonumber(options.minPotential) or tonumber(configured.minPotential) or 0
  local limit = math.max(1, math.floor(tonumber(options.limit) or tonumber(configured.limit) or 100))
  local opportunities = {}
  for _, record in ipairs(records or {}) do
    local unitPrice = tonumber(record.unitBuyout) or 0
    local trend = record.itemID and self:GetTrend(record.itemID) or nil
    local baseline = trend and tonumber(trend.pMedian) or 0
    if unitPrice > 0 and baseline > unitPrice and unitPrice <= baseline * (1 - minDiscount) then
      local count = math.max(1, tonumber(record.count) or 1)
      local potential = math.max(0, (baseline - unitPrice) * count)
      if potential >= minPotential then
        local entry = {}
        for key, value in pairs(record) do entry[key] = value end
        entry.trendPrice = baseline
        entry.discount = 1 - unitPrice / baseline
        entry.potential = potential
        entry.trendSamples = tonumber(trend.sampleCount) or 0
        entry.actionable = false
        opportunities[#opportunities + 1] = entry
      end
    end
  end
  table.sort(opportunities, function(a, b)
    if a.potential ~= b.potential then return a.potential > b.potential end
    if a.discount ~= b.discount then return a.discount > b.discount end
    return (a.unitBuyout or 0) < (b.unitBuyout or 0)
  end)
  while #opportunities > limit do table.remove(opportunities) end
  return opportunities
end

function Appraiser:BuildCraftingProfits(recipes)
  local profits = {}
  local cut = profile() and profile().crafting and tonumber(profile().crafting.auctionCut) or .05
  cut = math.max(0, math.min(.25, cut))
  for _, recipe in ipairs(recipes or {}) do
    if not recipe.isHeader and recipe.productID then
      local product = self:GetPrice(recipe.productID)
      local made = math.max(1, tonumber(recipe.numMade and recipe.numMade[1]) or 1)
      local revenue = math.max(0, tonumber(product.unitPrice) or 0) * made
      local cost, missing = 0, {}
      for _, reagent in ipairs(recipe.reagents or {}) do
        local required = math.max(0, tonumber(reagent.required) or 0)
        local reagentPrice = reagent.itemID and self:GetPrice(reagent.itemID) or { unitPrice = 0, source = "none" }
        if required > 0 and (tonumber(reagentPrice.unitPrice) or 0) <= 0 then
          missing[#missing + 1] = reagent.name or tostring(reagent.itemID or "unknown reagent")
        end
        cost = cost + required * math.max(0, tonumber(reagentPrice.unitPrice) or 0)
      end
      if revenue > 0 and #missing == 0 then
        local productInfo = self:GetItemStackInfo(recipe.productID)
        profits[#profits + 1] = {
          recipe = recipe,
          recipeID = recipe.spellID,
          productID = recipe.productID,
          name = productInfo.name or recipe.name,
          itemLink = productInfo.itemLink or recipe.itemLink,
          texture = productInfo.texture,
          made = made,
          revenue = revenue,
          cost = cost,
          profit = math.floor(revenue * (1 - cut) + .5) - cost,
          productSource = product.source,
        }
      end
    end
  end
  table.sort(profits, function(a, b)
    if a.profit ~= b.profit then return a.profit > b.profit end
    return string.lower(a.name or "") < string.lower(b.name or "")
  end)
  return profits
end

function Appraiser:RefreshCraftingProfits()
  local profession = Compat.Profession
  local line = profession and profession:GetTradeSkillLine() or { open = false, reason = "api_unavailable" }
  if not line.open then
    return result(false, line.reason or "trade_skill_closed", { profits = self.lastCraftingProfits or {} })
  end
  local recipes = profession:GetRecipes()
  self.lastCraftingProfits = self:BuildCraftingProfits(recipes)
  self.lastCraftingLine = line
  return result(true, "crafting_refreshed", { profits = self.lastCraftingProfits, profession = line, recipes = #recipes })
end

function Appraiser:DiscoverGoldGuides(search)
  search = string.lower(trim(search))
  local guides = {}
  local catalog = ZGV.Catalog
  local source = catalog and ((#(catalog.sorted or {}) > 0 and catalog.sorted) or catalog.guides) or {}
  for _, guide in ipairs(source or {}) do
    local title = tostring(guide.title or "")
    local lowered = string.lower(title)
    local kind
    if lowered:find("^gold\\gathering\\") or lowered:find("\\gathering\\", 1, true) then kind = "gathering"
    elseif lowered:find("^gold\\farming\\") or lowered:find("\\farming guides\\", 1, true) then kind = "farming" end
    if kind and (search == "" or lowered:find(search, 1, true)) then
      guides[#guides + 1] = {
        id = guide.id,
        title = title,
        name = guide.name or title:match("([^\\]+)$") or title,
        kind = kind,
        guide = guide,
      }
    end
  end
  table.sort(guides, function(a, b)
    if a.kind ~= b.kind then return a.kind < b.kind end
    return string.lower(a.title) < string.lower(b.title)
  end)
  return guides
end

function Appraiser:LoadGoldGuide(entry, userInitiated)
  if userInitiated ~= true then return result(false, "user_action_required") end
  local guide = entry
  if type(entry) == "table" then
    guide = entry.id or entry.title
    if not guide and type(entry.guide) == "table" then guide = entry.guide.id or entry.guide.title end
  end
  if not guide or not ZGV.Catalog or not ZGV.Catalog:Get(guide) then return result(false, "guide_missing") end
  if type(ZGV.SetGuide) == "function" and ZGV:SetGuide(guide) then return result(true, "guide_loaded", { guide = guide }) end
  if ZGV.Runtime and type(ZGV.Runtime.SelectGuide) == "function" and ZGV.Runtime:SelectGuide(guide) then
    return result(true, "guide_loaded", { guide = guide })
  end
  return result(false, "guide_load_failed", { guide = guide })
end

function Appraiser:GetHelpText()
  return table.concat({
    "Auction scans only run after you press a scan button at an open Auction House.",
    "Full Scan uses Blizzard's guarded get-all query when available; otherwise it pages with throttle, time, page, and row limits. You can cancel at any time.",
    "Deals are compared with this realm and faction's trend history. Inspect a deal with a fresh named scan before buying.",
    "Crafting profit uses recipes visible in the currently open profession window and live appraiser prices, less the configured Auction House cut.",
    "Farm & Gather searches the loaded guide Catalog and only loads the guide you explicitly select.",
    "Buying and posting require their own button click. The addon never moves an item from your bags into the auction sell slot.",
  }, "\n\n")
end

function Appraiser:AddShoppingItem(itemID, count, name)
  itemID = tonumber(itemID)
  if not itemID then return result(false, "invalid_item") end
  local settings = profile()
  if not settings then return result(false, "database_unavailable") end
  settings.shopping = settings.shopping or {}
  settings.shopping[itemID] = {
    itemID = itemID,
    count = math.max(1, tonumber(count) or 1),
    name = trim(name),
  }
  ZGV:Fire("ZGV_GOLD_SHOPPING_UPDATED")
  return result(true, "shopping_item_added", { itemID = itemID })
end

function Appraiser:RemoveShoppingItem(itemID)
  local settings = profile()
  itemID = tonumber(itemID)
  if not settings or not settings.shopping or not itemID then return false end
  settings.shopping[itemID] = nil
  ZGV:Fire("ZGV_GOLD_SHOPPING_UPDATED")
  return true
end

function Appraiser:BuildShoppingList()
  local merged = {}
  local settings = profile()
  for key, entry in pairs(settings and settings.shopping or {}) do
    local itemID = tonumber(entry.itemID) or tonumber(key)
    if itemID then
      merged[itemID] = {
        itemID = itemID,
        count = math.max(1, tonumber(entry.count) or 1),
        name = trim(entry.name),
        source = "manual",
      }
    end
  end
  local runtime = ZGV.Runtime
  local step = runtime and runtime.currentGuide and runtime.currentGuide.steps and runtime.currentGuide.steps[runtime.currentStep]
  local state = step and runtime.GetStepState and runtime:GetStepState(step, runtime.currentStep) or nil
  for index, goal in ipairs(step and step.goals or {}) do
    if goal.action == "buy" and (goal.itemID or goal.itemid) and not (state and state.goals[index] and state.goals[index].complete) then
      local itemID = tonumber(goal.itemID or goal.itemid)
      local wanted = math.max(1, tonumber(goal.count) or 1)
      local have = Compat.Item and Compat.Item:GetCount(itemID, false).count or 0
      local needed = math.max(0, wanted - have)
      if needed > 0 then
        local item = merged[itemID] or { itemID = itemID, count = 0, source = "guide" }
        item.count = math.max(item.count or 0, needed)
        item.source = item.source == "manual" and "manual+guide" or "guide"
        item.name = item.name ~= "" and item.name or trim(goal.target or goal.text)
        merged[itemID] = item
      end
    end
  end
  local list = {}
  for itemID, item in pairs(merged) do
    local info = Compat.Item and Compat.Item:GetInfo(itemID) or {}
    if item.name == "" then item.name = info.name or ("Item " .. tostring(itemID)) end
    item.itemLink = info.itemLink
    item.texture = info.texture
    local price = self:GetPrice(itemID)
    item.unitPrice = price.unitPrice
    item.totalPrice = price.unitPrice * item.count
    item.priceSource = price.source
    list[#list + 1] = item
  end
  table.sort(list, function(a, b) return string.lower(a.name or "") < string.lower(b.name or "") end)
  return list
end

function Appraiser:BuildInventoryList()
  local aggregated = {}
  local items = Compat.Container and Compat.Container:Enumerate() or {}
  for _, item in ipairs(items) do
    if item.itemID and not item.isQuestItem then
      local binding = Compat.Item and Compat.Item:GetBinding(item) or { known = false, bound = false }
      if binding.known and not binding.bound then
        local entry = aggregated[item.itemID]
        if not entry then
          local info = Compat.Item and Compat.Item:GetInfo(item.itemLink or item.itemID) or {}
          entry = {
            itemID = item.itemID,
            name = info.name or ("Item " .. tostring(item.itemID)),
            itemLink = item.itemLink or info.itemLink,
            texture = item.texture or info.texture,
            quality = item.quality or info.quality,
            maxStack = math.max(1, tonumber(info.maxStack) or 1),
            count = 0,
            locations = {},
            bindingKnown = binding.known,
          }
          aggregated[item.itemID] = entry
        end
        entry.count = entry.count + math.max(1, tonumber(item.count) or 1)
        entry.locations[#entry.locations + 1] = { bag = item.bag, slot = item.slot, count = item.count }
      end
    end
  end
  local list = {}
  for _, entry in pairs(aggregated) do
    local price = self:GetSellPrice(entry.itemID, entry.count)
    entry.unitPrice = price.unitPrice
    entry.totalPrice = price.total
    entry.priceSource = price.source
    list[#list + 1] = entry
  end
  table.sort(list, function(a, b)
    if a.totalPrice ~= b.totalPrice then return a.totalPrice > b.totalPrice end
    return string.lower(a.name or "") < string.lower(b.name or "")
  end)
  return list
end

local function pageSignature(records, counts)
  local first = records and records[1] or {}
  local last = records and records[#records] or {}
  return table.concat({
    tostring(counts and counts.batchCount or #records), tostring(counts and counts.totalCount or 0),
    tostring(first.itemID or 0), tostring(first.count or 0), tostring(first.buyoutPrice or 0), tostring(first.owner or ""),
    tostring(last.itemID or 0), tostring(last.count or 0), tostring(last.buyoutPrice or 0), tostring(last.owner or ""),
  }, "\031")
end

function Appraiser:GetScanStatus()
  local query = self.activeQuery or self.queuedScan
  if query then
    return {
      active = true,
      state = self.activeQuery and "waiting" or "queued",
      kind = query.kind or "named",
      mode = query.mode or "named",
      page = (tonumber(query.page) or 0) + 1,
      pages = tonumber(query.pages) or 0,
      rows = #(query.records or {}),
      startedAt = query.startedAt,
    }
  end
  return self.lastFullStatus or { active = false, state = "idle", kind = "none", page = 0, pages = 0, rows = 0 }
end

function Appraiser:_ScheduleScanRetry(delay)
  if self.scanRetry or not Compat.Timer then return end
  self.scanRetry = Compat.Timer:NewTimer(math.max(.1, tonumber(delay) or .5), function()
    Appraiser.scanRetry = nil
    Appraiser:_TrySendScan()
  end)
end

function Appraiser:_TrySendScan()
  local request = self.queuedScan
  if not request then return result(false, "no_queued_query") end
  if Compat.Now() > request.deadline or (request.finishDeadline and Compat.Now() > request.finishDeadline) then
    self.queuedScan = nil
    local code = request.kind == "full" and "full_scan_timeout" or "query_timeout"
    self.lastFullStatus = request.kind == "full" and { active = false, state = "cancelled", kind = "full", code = code, rows = #(request.records or {}) } or self.lastFullStatus
    ZGV:Fire("ZGV_GOLD_SCAN_STATUS", code, request)
    return result(false, code)
  end
  if not Auction or not Auction.open then
    self.queuedScan = nil
    return result(false, "auction_house_closed")
  end
  local settings = profile()
  local interval = settings and settings.query and tonumber(settings.query.minInterval) or .8
  local wait = interval - (Compat.Now() - (self.lastQueryAt or -interval))
  local permission = Auction:CanQuery()
  local getAllBlocked = request.mode == "getall" and not permission.canQueryAll
  if wait > 0 or not permission.canQuery or getAllBlocked then
    self:_ScheduleScanRetry(math.max(.25, wait, getAllBlocked and 1 or 0))
    local code = request.kind == "full" and "full_scan_queued" or "query_queued"
    ZGV:Fire("ZGV_GOLD_SCAN_STATUS", code, request)
    return result(true, code, { permission = permission })
  end
  local sent = Auction:Query({
    name = request.name or "",
    page = tonumber(request.page) or 0,
    getAll = request.mode == "getall",
  })
  if not sent.ok then
    if sent.code == "query_throttled" or sent.code == "get_all_throttled" then self:_ScheduleScanRetry(.5) end
    if sent.code ~= "query_throttled" and sent.code ~= "get_all_throttled" then self.queuedScan = nil end
    return sent
  end
  self.activeQuery = request
  self.queuedScan = nil
  self.lastQueryAt = Compat.Now()
  local code = request.kind == "full" and "full_scan_page_sent" or "query_sent"
  ZGV:Fire("ZGV_GOLD_SCAN_STATUS", code, request)
  return sent
end

function Appraiser:StartNamedScan(name, itemID)
  name = trim(name)
  if name == "" then return result(false, "name_required") end
  if string.len(name) > 63 then return result(false, "name_too_long") end
  if self.activeQuery or self.queuedScan then return result(false, "query_busy") end
  local settings = profile()
  local timeout = settings and settings.query and tonumber(settings.query.timeout) or 15
  self.queuedScan = {
    kind = "named",
    mode = "named",
    name = name,
    itemID = tonumber(itemID),
    requestedAt = wallTime(),
    deadline = Compat.Now() + math.max(2, timeout),
  }
  return self:_TrySendScan()
end

function Appraiser:StartFullScan(userInitiated, preferGetAll)
  if userInitiated ~= true then return result(false, "user_action_required") end
  if self.activeQuery or self.queuedScan then return result(false, "query_busy") end
  if not Auction or not Auction.open then return result(false, "auction_house_closed") end
  local settings = profile()
  local querySettings = settings and settings.query or {}
  local fullSettings = settings and settings.fullScan or {}
  local permission = Auction:CanQuery()
  local mode = preferGetAll ~= false and permission.canQueryAll and "getall" or "paged"
  local now = Compat.Now()
  self.queuedScan = {
    kind = "full",
    mode = mode,
    name = "",
    page = 0,
    pages = 0,
    records = {},
    seenPages = {},
    startedAt = wallTime(),
    startedMono = now,
    requestedAt = wallTime(),
    deadline = now + math.max(2, tonumber(querySettings.timeout) or 15),
    finishDeadline = now + math.max(30, tonumber(fullSettings.maxDuration) or 300),
    maxPages = math.max(1, math.floor(tonumber(fullSettings.maxPages) or 200)),
    maxRows = math.max(AUCTIONS_PER_PAGE, math.floor(tonumber(fullSettings.maxRows) or 30000)),
  }
  ZGV:Fire("ZGV_GOLD_SCAN_STATUS", "full_scan_started", self.queuedScan)
  return self:_TrySendScan()
end

function Appraiser:CancelScan(code)
  local query = self.activeQuery or self.queuedScan
  self.activeQuery = nil
  self.queuedScan = nil
  if self.scanRetry then self.scanRetry:Cancel(); self.scanRetry = nil end
  code = code or "query_cancelled"
  if query and query.kind == "full" then
    self.lastFullStatus = { active = false, state = "cancelled", kind = "full", code = code, rows = #(query.records or {}) }
  end
  ZGV:Fire("ZGV_GOLD_SCAN_STATUS", code, query)
  return result(true, code, { query = query })
end

function Appraiser:_CompleteFullScan(query)
  local records = query.records or {}
  self.lastFullResults = records
  self.lastFullResultAt = Compat.Now()
  self.lastFullQuery = query
  self.lastFullSummaries, self.lastFullScan = self:RecordScan({ name = "", kind = "full", mode = query.mode }, records)
  self.lastOpportunities = self:BuildAuctionOpportunities(records)
  local market = self:GetMarket(true)
  if market then
    market.lastFullScan = wallTime()
    market.lastFullRows = #records
    market.lastFullMode = query.mode
  end
  self.lastFullStatus = {
    active = false, state = "complete", kind = "full", mode = query.mode,
    page = tonumber(query.page) and query.page + 1 or 1, pages = query.pages or 1, rows = #records,
  }
  ZGV:Fire("ZGV_GOLD_SCAN_STATUS", "full_scan_complete", query)
  ZGV:Fire("ZGV_GOLD_FULL_SCAN_COMPLETE", records, self.lastOpportunities, query)
end

function Appraiser:_AbortFullScan(query, code)
  self.activeQuery = nil
  self.queuedScan = nil
  if self.scanRetry then self.scanRetry:Cancel(); self.scanRetry = nil end
  self.lastFullStatus = { active = false, state = "cancelled", kind = "full", code = code, rows = #(query.records or {}) }
  ZGV:Fire("ZGV_GOLD_SCAN_STATUS", code, query)
  ZGV:Fire("ZGV_GOLD_FULL_SCAN_CANCELLED", code, query)
end

function Appraiser:OnAuctionEvent(topic, event)
  if event == "AUCTION_HOUSE_CLOSED" then self:CancelScan("auction_house_closed"); return end
  if event ~= "AUCTION_ITEM_LIST_UPDATE" or not self.activeQuery then return end
  local query = self.activeQuery
  self.activeQuery = nil
  local payload = Auction:GetItems("list")
  if query.kind == "full" then
    local pageRecords = self:NormalizeAuctions(payload.items)
    local counts = payload.counts or {}
    if query.mode == "getall" then
      if #pageRecords > query.maxRows then self:_AbortFullScan(query, "full_scan_row_limit"); return end
      for _, record in ipairs(pageRecords) do record.actionable = false; record.page = 0; query.records[#query.records + 1] = record end
      query.pages = 1
      self:_CompleteFullScan(query)
      return
    end

    local total = math.max(0, tonumber(counts.totalCount) or 0)
    local pages = total > 0 and math.ceil(total / AUCTIONS_PER_PAGE) or 1
    query.pages = math.max(query.pages or 0, pages)
    if query.pages > query.maxPages or (query.page or 0) >= query.maxPages then self:_AbortFullScan(query, "full_scan_page_limit"); return end
    if #query.records + #pageRecords > query.maxRows then self:_AbortFullScan(query, "full_scan_row_limit"); return end
    if #pageRecords > 0 then
      local signature = pageSignature(pageRecords, counts)
      if query.seenPages[signature] then self:_AbortFullScan(query, "full_scan_duplicate_page"); return end
      query.seenPages[signature] = query.page
      for _, record in ipairs(pageRecords) do
        record.actionable = false
        record.page = query.page
        query.records[#query.records + 1] = record
      end
    end
    ZGV:Fire("ZGV_GOLD_SCAN_STATUS", "full_scan_page_received", query)
    local batch = math.max(0, tonumber(counts.batchCount) or #pageRecords)
    if batch == 0 or query.page + 1 >= query.pages then self:_CompleteFullScan(query); return end
    query.page = query.page + 1
    local timeout = profile() and profile().query and tonumber(profile().query.timeout) or 15
    query.deadline = Compat.Now() + math.max(2, timeout)
    self.queuedScan = query
    self:_TrySendScan()
    return
  end
  local records = self:NormalizeAuctions(payload.items, query.name, query.itemID)
  for _, record in ipairs(records) do record.actionable = true end
  self.lastResults = records
  self.lastResultAt = Compat.Now()
  self.lastQuery = query
  self.lastSummaries, self.lastScan = self:RecordScan(query, records)
  ZGV:Fire("ZGV_GOLD_SCAN_COMPLETE", records, self.lastSummaries, query)
end

local function sameAuction(a, b)
  return a and b
    and tonumber(a.itemID) == tonumber(b.itemID)
    and tonumber(a.count) == tonumber(b.count)
    and tonumber(a.buyoutPrice) == tonumber(b.buyoutPrice)
    and tostring(a.owner or "") == tostring(b.owner or "")
end

function Appraiser:Bid(record, userInitiated)
  if userInitiated ~= true then return result(false, "user_action_required") end
  if not record or not record.index then return result(false, "auction_required") end
  if record.actionable == false then return result(false, "named_rescan_required") end
  if Compat.Now() - (self.lastResultAt or 0) > MAX_RESULT_AGE then return result(false, "auction_result_stale") end
  local current = Auction:GetItemInfo("list", record.index)
  if not current.ready or not sameAuction(record, current) then return result(false, "auction_result_changed") end
  local amount = (record.buyoutPrice or 0) > 0 and record.buyoutPrice or record.nextBid
  if not amount or amount <= 0 then return result(false, "price_unavailable") end
  return Auction:Bid("list", record.index, amount)
end

function Appraiser:Post(options, userInitiated)
  if userInitiated ~= true then return result(false, "user_action_required") end
  options = options or {}
  local sellItem = Auction:GetSellItemInfo()
  if not sellItem.ready then return result(false, sellItem.reason or "sell_item_required", { sellItem = sellItem }) end
  local selectedItemID = tonumber(options.itemID)
  if selectedItemID and sellItem.itemID and selectedItemID ~= sellItem.itemID then
    return result(false, "sell_item_changed", { sellItem = sellItem })
  end
  local stackSize = math.max(1, math.floor(tonumber(options.stackSize) or 1))
  local stackCount = math.max(1, math.floor(tonumber(options.stackCount) or 1))
  local duration = tonumber(options.duration) or 24
  local unitBid = math.max(0, math.floor(tonumber(options.unitBid) or 0))
  local unitBuyout = math.max(0, math.floor(tonumber(options.unitBuyout) or 0))
  local stackInfo = self:GetItemStackInfo(sellItem.itemLink or sellItem.itemID)
  if stackInfo.ready and stackInfo.maxStack and stackSize > stackInfo.maxStack then
    return result(false, "stack_exceeds_item_max", { sellItem = sellItem, maxStack = stackInfo.maxStack })
  end
  if stackSize * stackCount > (tonumber(sellItem.count) or 0) then return result(false, "not_enough_sell_items", { sellItem = sellItem }) end
  if unitBid <= 0 and unitBuyout <= 0 then return result(false, "price_required") end
  return Auction:Start(unitBid * stackSize, unitBuyout * stackSize, duration, stackSize, stackCount)
end

function Appraiser:OnStartup()
  if not self.auctionToken then self.auctionToken = Compat:On("AUCTION_EVENT", self, "OnAuctionEvent") end
  self:GetMarket(true)
end

-- Small compatibility facade for guide/runtime code that expects the old gold
-- namespace. It intentionally exposes appraisal only, not automated workflows.
ZGV.Gold = ZGV.Gold or {}
ZGV.Gold.Appraiser = Appraiser
ZGV.Gold.Scan = ZGV.Gold.Scan or {}
function ZGV.Gold.Scan:GetPrice(itemID) return Appraiser:GetPrice(itemID).unitPrice end
function ZGV.Gold:GetItemPrice(itemID)
  local info = Compat.Item and Compat.Item:GetInfo(itemID) or {}
  return tonumber(info.vendorPrice) or 0, Appraiser:GetPrice(itemID).unitPrice
end
function ZGV.Gold:GetSellPrice(itemID, count)
  local price = Appraiser:GetSellPrice(itemID, count)
  return price.total, price.unitPrice, price.empty
end
function ZGV.Gold:GetPriceStatus(itemID, price) return Appraiser:GetPriceStatus(itemID, price) end
