local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Auction = Compat:CreateService("Auction")

Auction.open = Auction.open or false
Auction.lastUpdate = Auction.lastUpdate or {}

local function item_id_from_link(link)
	return type(link) == "string" and tonumber(string.match(link, "item:(%d+)")) or nil
end

function Auction:GetCounts(list_type)
	list_type = list_type or "list"
	if type(_G.GetNumAuctionItems) ~= "function" then
		return { listType = list_type, batchCount = 0, totalCount = 0, available = false }
	end
	local batch, total = _G.GetNumAuctionItems(list_type)
	return {
		listType = list_type,
		batchCount = tonumber(batch) or 0,
		totalCount = tonumber(total) or tonumber(batch) or 0,
		available = true,
	}
end

function Auction:GetItemInfo(list_type, index)
	list_type = list_type or "list"
	if type(_G.GetAuctionItemInfo) ~= "function" then
		return { listType = list_type, index = index, ready = false, reason = "api_unavailable" }
	end
	-- The final two fields were added during Wrath; clients omitting them simply
	-- return nil, so this also tolerates common build-12340 server variants.
	local name, texture, count, quality, can_use, level, min_bid, min_increment,
		buyout, bid_amount, high_bidder, owner, sale_status, item_id, has_all_info =
		_G.GetAuctionItemInfo(list_type, index)
	local link = type(_G.GetAuctionItemLink) == "function" and _G.GetAuctionItemLink(list_type, index) or nil
	item_id = tonumber(item_id) or item_id_from_link(link)
	local time_left = type(_G.GetAuctionItemTimeLeft) == "function" and _G.GetAuctionItemTimeLeft(list_type, index) or nil
	return {
		listType = list_type,
		index = index,
		itemID = item_id,
		name = name,
		hyperlink = link,
		itemLink = link,
		iconFileID = texture,
		texture = texture,
		count = tonumber(count) or 0,
		quality = tonumber(quality),
		canUse = Compat.Bool(can_use),
		level = tonumber(level) or 0,
		minBid = tonumber(min_bid) or 0,
		minIncrement = tonumber(min_increment) or 0,
		buyoutPrice = tonumber(buyout) or 0,
		bidAmount = tonumber(bid_amount) or 0,
		highBidder = Compat.Bool(high_bidder),
		owner = owner,
		saleStatus = sale_status,
		hasAllInfo = has_all_info == nil and name ~= nil or Compat.Bool(has_all_info),
		timeLeft = tonumber(time_left),
		ready = name ~= nil,
	}
end

function Auction:GetItems(list_type)
	local items = {}
	local counts = self:GetCounts(list_type)
	for index = 1, counts.batchCount do items[#items + 1] = self:GetItemInfo(list_type, index) end
	return { listType = list_type or "list", items = items, counts = counts, updatedAt = self.lastUpdate[list_type or "list"] }
end

function Auction:GetSellItemInfo()
	if type(_G.GetAuctionSellItemInfo) ~= "function" then
		return { ready = false, reason = "api_unavailable", count = 0 }
	end
	local name, texture, count, quality, can_use, vendor_price = _G.GetAuctionSellItemInfo()
	local link = type(_G.GetAuctionSellItemLink) == "function" and _G.GetAuctionSellItemLink() or nil
	return {
		itemID = item_id_from_link(link),
		name = name,
		hyperlink = link,
		itemLink = link,
		iconFileID = texture,
		texture = texture,
		count = tonumber(count) or 0,
		quality = tonumber(quality),
		canUse = Compat.Bool(can_use),
		vendorPrice = tonumber(vendor_price) or 0,
		ready = name ~= nil and (tonumber(count) or 0) > 0,
		reason = name and nil or "sell_item_required",
	}
end

function Auction:CanQuery()
	if type(_G.CanSendAuctionQuery) ~= "function" then
		return { canQuery = self.open, canQueryAll = false, available = false }
	end
	local can_query, can_query_all = _G.CanSendAuctionQuery()
	return { canQuery = Compat.Bool(can_query), canQueryAll = Compat.Bool(can_query_all), available = true }
end

function Auction:Query(options)
	options = options or {}
	if not self.open then return Compat:Result(false, "auction_house_closed") end
	if type(_G.QueryAuctionItems) ~= "function" then return Compat:Result(false, "api_unavailable") end
	local query_name = options.name or ""
	if type(query_name) ~= "string" then return Compat:Result(false, "invalid_name") end
	-- Build 12340 can disconnect on names longer than the protocol's 63 bytes.
	if string.len(query_name) > 63 then return Compat:Result(false, "name_too_long", { length = string.len(query_name) }) end
	local permission = self:CanQuery()
	if not permission.canQuery then return Compat:Result(false, "query_throttled", { permission = permission }) end
	if options.getAll and not permission.canQueryAll then return Compat:Result(false, "get_all_throttled", { permission = permission }) end
	local result = Compat.Pack(pcall(_G.QueryAuctionItems,
		query_name,
		tonumber(options.minLevel) or 0,
		tonumber(options.maxLevel) or 0,
		tonumber(options.inventoryTypeIndex) or 0,
		tonumber(options.classIndex) or 0,
		tonumber(options.subclassIndex) or 0,
		tonumber(options.page) or 0,
		options.isUsable and true or false,
		tonumber(options.qualityIndex) or 0,
		options.getAll and true or false
	))
	return Compat:Result(result[1], result[1] and "query_sent" or "lua_error", { options = options, error = result[2] })
end

function Auction:Bid(list_type, index, amount)
	if not self.open then return Compat:Result(false, "auction_house_closed") end
	if type(_G.PlaceAuctionBid) ~= "function" then return Compat:Result(false, "api_unavailable") end
	amount = tonumber(amount)
	index = tonumber(index)
	if not index or index < 1 then return Compat:Result(false, "invalid_index") end
	if not amount or amount <= 0 then return Compat:Result(false, "invalid_amount") end
	local result = Compat.Pack(pcall(_G.PlaceAuctionBid, list_type or "list", index, amount))
	return Compat:Result(result[1], result[1] and "bid_requested" or "lua_error", { listType = list_type or "list", index = index, amount = amount, error = result[2] })
end

function Auction:Start(min_bid, buyout, duration, stack_size, stack_count)
	if not self.open then return Compat:Result(false, "auction_house_closed") end
	if type(_G.StartAuction) ~= "function" then return Compat:Result(false, "api_unavailable") end
	min_bid, buyout = tonumber(min_bid) or 0, tonumber(buyout) or 0
	duration, stack_size, stack_count = tonumber(duration) or 12, tonumber(stack_size) or 1, tonumber(stack_count) or 1
	if min_bid < 0 or buyout < 0 then return Compat:Result(false, "invalid_price") end
	local duration_codes = { [12] = 1, [24] = 2, [48] = 3 }
	local duration_hours = { [1] = 12, [2] = 24, [3] = 48 }
	local duration_code = duration_codes[duration]
	if not duration_code and duration_hours[duration] then duration_code, duration = duration, duration_hours[duration] end
	if not duration_code then return Compat:Result(false, "invalid_duration") end
	if stack_size < 1 or stack_count < 1 then return Compat:Result(false, "invalid_stack") end
	local result = Compat.Pack(pcall(_G.StartAuction,
		min_bid,
		buyout,
		duration_code,
		stack_size,
		stack_count
	))
	return Compat:Result(result[1], result[1] and "auction_requested" or "lua_error", {
		duration = duration,
		durationCode = duration_code,
		error = result[2],
	})
end

function Auction:OnEvent(event)
	if event == "AUCTION_HOUSE_SHOW" then self.open = true
	elseif event == "AUCTION_HOUSE_CLOSED" then self.open = false
	elseif event == "AUCTION_ITEM_LIST_UPDATE" then self.lastUpdate.list = Compat.Now()
	elseif event == "AUCTION_OWNED_LIST_UPDATE" then self.lastUpdate.owner = Compat.Now()
	elseif event == "AUCTION_BIDDER_LIST_UPDATE" then self.lastUpdate.bidder = Compat.Now() end
	Compat:Fire("AUCTION_EVENT", event, self.lastUpdate)
end

Compat:RegisterEvent("AUCTION_HOUSE_SHOW", Auction, "OnEvent")
Compat:RegisterEvent("AUCTION_HOUSE_CLOSED", Auction, "OnEvent")
Compat:RegisterEvent("AUCTION_ITEM_LIST_UPDATE", Auction, "OnEvent")
Compat:RegisterEvent("AUCTION_OWNED_LIST_UPDATE", Auction, "OnEvent")
Compat:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE", Auction, "OnEvent")
