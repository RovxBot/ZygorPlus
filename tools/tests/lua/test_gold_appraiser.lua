local repo = assert(arg[1], "repository root required")

local now = 10
local fired = {}
local bidCalls, postCalls, queryCalls = 0, 0, 0
local queryOptions = {}
local canQuery = true
local canQueryAll = false
local currentAuction
local auctionPayload

GetRealmName = function() return "Test Realm" end
UnitFactionGroup = function() return "Alliance" end
time = function() return 1000 + math.floor(now) end

local Compat = {}
function Compat.Now() return now end
function Compat:Result(ok, code, fields) fields = fields or {}; fields.ok = ok and true or false; fields.code = code; return fields end
function Compat:On() return {} end
Compat.Timer = {
  NewTimer = function(_, delay, callback)
    return { delay = delay, callback = callback, Cancel = function(self) self.cancelled = true end }
  end,
}
Compat.Auction = {
  open = true,
  CanQuery = function() return { canQuery = canQuery, canQueryAll = canQueryAll, available = true } end,
  Query = function(_, options) queryCalls = queryCalls + 1; queryOptions[#queryOptions + 1] = options; return Compat:Result(true, "query_sent", { options = options }) end,
  GetItems = function() return auctionPayload or { items = { currentAuction }, counts = { batchCount = 1, totalCount = 1 } } end,
  GetItemInfo = function() return currentAuction end,
  Bid = function(_, listType, index, amount)
    bidCalls = bidCalls + 1
    return Compat:Result(true, "bid_requested", { listType = listType, index = index, amount = amount })
  end,
  GetSellItemInfo = function() return { ready = true, itemID = 100, count = 10 } end,
  Start = function(_, bid, buyout, duration, stackSize, stackCount)
    postCalls = postCalls + 1
    return Compat:Result(true, "auction_requested", { bid = bid, buyout = buyout, duration = duration, stackSize = stackSize, stackCount = stackCount })
  end,
}
Compat.Item = {
  GetCount = function(_, itemID) return { itemID = itemID, count = itemID == 100 and 2 or 0 } end,
  GetInfo = function(_, itemID) return { itemID = itemID, name = itemID == 100 and "Copper Bar" or "Other", maxStack = itemID == 100 and 20 or 5, ready = true } end,
  GetBinding = function(_, item) return { known = item.itemID ~= 888, bound = item.itemID == 999 } end,
}
Compat.Profession = {
  GetTradeSkillLine = function() return { open = true, name = "Blacksmithing" } end,
  GetRecipes = function() return {} end,
}
Compat.Container = {
  Enumerate = function()
    return {
      { itemID = 100, count = 3, bag = 0, slot = 1, ready = true },
      { itemID = 100, count = 2, bag = 1, slot = 1, ready = true },
      { itemID = 999, count = 1, bag = 0, slot = 2, ready = true },
      { itemID = 888, count = 4, bag = 0, slot = 3, ready = true },
    }
  end,
}

ZygorGuidesViewer = {
  Compat = Compat,
  db = {
    profile = { gold = {
      scans = {}, appraisals = {}, shopping = {}, query = { minInterval = .8, timeout = 15 },
      trend = { maxSamples = 20, maxScans = 40 }, appraisalMaxAge = 7200, undercutCopper = 1,
      fullScan = { maxDuration = 300, maxPages = 200, maxRows = 30000 },
      opportunities = { minDiscount = .15, minPotential = 0, limit = 100 }, crafting = { auctionCut = .05 },
    } },
    global = { trendData = {} },
  },
  RegisterModule = function(self, name, module) self[name] = module; return module end,
  Fire = function(_, event) fired[#fired + 1] = event end,
}
ZGV = ZygorGuidesViewer

dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/GoldAppraiser.lua")
local Appraiser = assert(ZygorGuidesViewer.GoldAppraiser)

local raw = {
  { ready = true, index = 1, itemID = 100, name = "Copper Bar", count = 2, buyoutPrice = 200, minBid = 100, minIncrement = 5, owner = "A" },
  { ready = true, index = 2, itemID = 100, name = "Copper Bar", count = 1, buyoutPrice = 90, minBid = 50, minIncrement = 5, owner = "B" },
  { ready = true, index = 3, itemID = 200, name = "Copper Ore", count = 5, buyoutPrice = 250, owner = "C" },
}
local normalized = Appraiser:NormalizeAuctions(raw, "Copper Bar", 100)
assert(#normalized == 2, "exact name and item filtering")
assert(normalized[1].unitBuyout == 90 and normalized[2].unitBuyout == 100, "per-unit price normalization and sorting")
local summary = Appraiser:Summarize(normalized)
assert(summary.ready and summary.low == 90 and summary.median == 100 and summary.high == 100, "weighted percentiles")

local summaries = Appraiser:RecordScan({ name = "Copper Bar", itemID = 100 }, normalized)
assert(summaries[100].low == 90, "scan summary by item")
local trend = Appraiser:GetTrend(100)
assert(trend and trend.pMedian == 100 and trend.sampleCount == 1, "durable realm/faction trend")
assert(ZygorGuidesViewer.db.global.trendData["Test Realm\031Alliance"], "realm/faction market key")

ZygorGuidesViewer.Runtime = {
  currentStep = 1,
  currentGuide = { steps = { { goals = { { action = "buy", itemID = 100, count = 5, target = "Copper Bar" } } } } },
  GetStepState = function() return { goals = { { complete = false } } } end,
}
local shopping = Appraiser:BuildShoppingList()
assert(#shopping == 1 and shopping[1].count == 3 and shopping[1].source == "guide", "guide shopping count")
assert(Appraiser:AddShoppingItem(200, 4, "Copper Ore").ok, "manual shopping add")
shopping = Appraiser:BuildShoppingList()
assert(#shopping == 2, "guide and manual shopping merge")

local inventory = Appraiser:BuildInventoryList()
assert(#inventory == 1 and inventory[1].itemID == 100 and inventory[1].count == 5, "unbound inventory aggregation")
assert(inventory[1].maxStack == 20, "inventory uses live item max stack")

canQuery = false
local queued = Appraiser:StartNamedScan("Copper Bar", 100)
assert(queued.ok and queued.code == "query_queued" and queryCalls == 0, "server throttle queues named scan")
Appraiser:CancelScan()
canQuery = true
local sent = Appraiser:StartNamedScan("Copper Bar", 100)
assert(sent.ok and sent.code == "query_sent" and queryCalls == 1, "named scan sent through adapter")
currentAuction = raw[1]
Appraiser:OnAuctionEvent("AUCTION_EVENT", "AUCTION_ITEM_LIST_UPDATE")
assert(#Appraiser.lastResults == 1, "auction update captures normalized results")

local actionable = Appraiser.lastResults[1]
now = now + 1
assert(Appraiser:Bid(actionable, false).code == "user_action_required", "bid requires explicit user action")
assert(Appraiser:Bid(actionable, true).ok and bidCalls == 1, "explicit bid routes through adapter")
assert(Appraiser:Post({ itemID = 100, unitBid = 100, unitBuyout = 120, stackSize = 5, stackCount = 2, duration = 24 }, false).code == "user_action_required", "post requires explicit user action")
assert(Appraiser:Post({ itemID = 100, unitBid = 100, unitBuyout = 120, stackSize = 5, stackCount = 2, duration = 24 }, true).ok and postCalls == 1, "explicit post routes through adapter")
assert(Appraiser:Post({ itemID = 100, unitBid = 100, unitBuyout = 120, stackSize = 21, stackCount = 1, duration = 24 }, true).code == "stack_exceeds_item_max", "post validates live max stack")

local productRecords = Appraiser:NormalizeAuctions({
  { ready = true, index = 1, itemID = 200, name = "Other", count = 1, buyoutPrice = 500, owner = "Maker" },
})
Appraiser:RecordScan({ name = "Other", itemID = 200 }, productRecords)
local opportunities = Appraiser:BuildAuctionOpportunities({
  { itemID = 100, name = "Copper Bar", count = 4, unitBuyout = 50, buyoutPrice = 200 },
})
assert(#opportunities == 1 and opportunities[1].potential == 200 and opportunities[1].actionable == false, "trend-backed opportunity is informational")
local crafting = Appraiser:BuildCraftingProfits({
  { name = "Other", spellID = 777, productID = 200, numMade = { 1, 1 }, reagents = { { itemID = 100, name = "Copper Bar", required = 2 } } },
})
assert(#crafting == 1 and crafting[1].cost == 200 and crafting[1].profit == 275, "known recipe profit uses appraiser prices and auction cut")

local loadedGuide
ZygorGuidesViewer.Catalog = {
  sorted = {
    { id = "guide:farm", title = "GOLD\\Farming\\Elemental Earth", name = "Elemental Earth" },
    { id = "guide:gather", title = "GOLD\\Gathering\\Copper Ore", name = "Copper Ore" },
    { id = "guide:level", title = "Leveling\\Starter", name = "Starter" },
  },
  Get = function(self, value)
    for _, guide in ipairs(self.sorted) do if value == guide.id or value == guide.title then return guide end end
  end,
}
ZygorGuidesViewer.SetGuide = function(_, value) loadedGuide = value; return value == "guide:gather" end
local goldGuides = Appraiser:DiscoverGoldGuides("copper")
assert(#goldGuides == 1 and goldGuides[1].id == "guide:gather", "gold routes are discovered from Catalog")
assert(Appraiser:LoadGoldGuide(goldGuides[1], false).code == "user_action_required", "guide load requires explicit UI action")
assert(Appraiser:LoadGoldGuide(goldGuides[1], true).ok and loadedGuide == "guide:gather", "Catalog guide entry loads by stable ID")

Appraiser:CancelScan()
ZygorGuidesViewer.db.profile.gold.query.minInterval = 0
auctionPayload = {
  items = { { ready = true, index = 1, itemID = 100, name = "Copper Bar", count = 1, buyoutPrice = 50, owner = "PageOne" } },
  counts = { batchCount = 1, totalCount = 51 },
}
assert(Appraiser:StartFullScan(false, true).code == "user_action_required", "full scan must be manually initiated")
local full = Appraiser:StartFullScan(true, true)
assert(full.ok and queryOptions[#queryOptions].page == 0 and not queryOptions[#queryOptions].getAll, "full scan safely falls back to paging")
Appraiser:OnAuctionEvent("AUCTION_EVENT", "AUCTION_ITEM_LIST_UPDATE")
assert(queryOptions[#queryOptions].page == 1, "paged scan advances through throttled query facade")
auctionPayload = {
  items = { { ready = true, index = 1, itemID = 200, name = "Other", count = 1, buyoutPrice = 400, owner = "PageTwo" } },
  counts = { batchCount = 1, totalCount = 51 },
}
Appraiser:OnAuctionEvent("AUCTION_EVENT", "AUCTION_ITEM_LIST_UPDATE")
assert(#Appraiser.lastFullResults == 2 and Appraiser:GetScanStatus().state == "complete", "paged full scan completes with bounded aggregate")
assert(Appraiser:Bid(Appraiser.lastFullResults[1], true).code == "named_rescan_required", "full scan result cannot be purchased without named rescan")

canQueryAll = true
auctionPayload = {
  items = { { ready = true, index = 1, itemID = 100, name = "Copper Bar", count = 1, buyoutPrice = 80, owner = "GetAll" } },
  counts = { batchCount = 1, totalCount = 1 },
}
assert(Appraiser:StartFullScan(true, true).ok and queryOptions[#queryOptions].getAll, "full scan uses guarded get-all when server permits")
Appraiser:OnAuctionEvent("AUCTION_EVENT", "AUCTION_ITEM_LIST_UPDATE")
assert(Appraiser.lastFullQuery.mode == "getall" and #Appraiser.lastFullResults == 1, "get-all scan completes")

print("gold appraiser headless tests passed")
