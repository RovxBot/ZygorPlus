local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Item = Compat:CreateService("Item")

Item.pending = Item.pending or {}
Item.requestTimeout = Item.requestTimeout or 10
Item.pollInterval = Item.pollInterval or 0.25

function Item:GetID(item)
	if type(item) == "number" then return item end
	if type(item) ~= "string" then return nil end
	local numeric = tonumber(item)
	if numeric then return numeric end
	return tonumber(string.match(item, "item:(%d+)"))
end

function Item:GetInfo(item)
	local item_id = self:GetID(item)
	if type(_G.GetItemInfo) ~= "function" then
		return { itemID = item_id, ready = false, reason = "api_unavailable" }
	end
	local name, link, quality, item_level, required_level, class_name, subclass_name,
		max_stack, equip_location, texture, vendor_price = _G.GetItemInfo(item)
	if not name and item_id and item ~= item_id then
		name, link, quality, item_level, required_level, class_name, subclass_name,
			max_stack, equip_location, texture, vendor_price = _G.GetItemInfo(item_id)
	end
	if not item_id then item_id = self:GetID(link) end
	return {
		itemID = item_id,
		id = item_id,
		name = name,
		hyperlink = link,
		itemLink = link,
		quality = tonumber(quality),
		itemLevel = tonumber(item_level),
		requiredLevel = tonumber(required_level),
		className = class_name,
		subclassName = subclass_name,
		maxStack = tonumber(max_stack),
		equipLocation = equip_location,
		iconFileID = texture,
		texture = texture,
		vendorPrice = tonumber(vendor_price),
		ready = name ~= nil,
		reason = name and nil or "not_cached",
	}
end

function Item:GetCount(item, include_bank, include_charges)
	if type(_G.GetItemCount) ~= "function" then return { count = 0, available = false } end
	-- Build 12340 accepts only the item and include-bank arguments. Charges are
	-- reported as unsupported rather than passing a modern third argument.
	local count = _G.GetItemCount(item, include_bank and true or false)
	return { itemID = self:GetID(item), count = tonumber(count) or 0, available = true, includeChargesSupported = not include_charges }
end

function Item:GetStats(item)
	if type(_G.GetItemStats) ~= "function" then
		return { itemID = self:GetID(item), ready = false, reason = "api_unavailable", stats = {} }
	end
	local stats = {}
	local returned = _G.GetItemStats(item, stats)
	if type(returned) == "table" then stats = returned end
	local copy = {}
	for stat, value in pairs(stats) do copy[stat] = value end
	return { itemID = self:GetID(item), ready = self:GetInfo(item).ready, stats = copy }
end

function Item:GetCooldown(item)
	if type(_G.GetItemCooldown) ~= "function" then
		return { itemID = self:GetID(item), available = false, startTime = 0, duration = 0, enabled = false }
	end
	local start_time, duration, enabled = _G.GetItemCooldown(item)
	return {
		itemID = self:GetID(item),
		available = true,
		startTime = tonumber(start_time) or 0,
		duration = tonumber(duration) or 0,
		enabled = Compat.Bool(enabled),
		endsAt = (tonumber(start_time) or 0) + (tonumber(duration) or 0),
	}
end

function Item:IsUsable(item)
	if type(_G.IsUsableItem) ~= "function" then return { usable = false, noMana = false, available = false } end
	local usable, no_mana = _G.IsUsableItem(item)
	return { itemID = self:GetID(item), usable = Compat.Bool(usable), noMana = Compat.Bool(no_mana), available = true }
end

function Item:IsEquipped(item)
	local equipped = type(_G.IsEquippedItem) == "function" and _G.IsEquippedItem(item)
	return { itemID = self:GetID(item), equipped = Compat.Bool(equipped), available = type(_G.IsEquippedItem) == "function" }
end

function Item:GetQualityColor(quality)
	quality = tonumber(quality)
	if type(_G.GetItemQualityColor) == "function" then
		local red, green, blue, hex = _G.GetItemQualityColor(quality or 0)
		return { quality = quality, r = red, g = green, b = blue, hex = hex, available = true }
	end
	local color = _G.ITEM_QUALITY_COLORS and _G.ITEM_QUALITY_COLORS[quality or 0]
	return {
		quality = quality,
		r = color and color.r or 1,
		g = color and color.g or 1,
		b = color and color.b or 1,
		hex = color and color.hex,
		available = color ~= nil,
	}
end

function Item:_PollRequests()
	local now = Compat.Now()
	for item_id, request in pairs(self.pending) do
		local info = self:GetInfo(item_id)
		if info.ready or now >= request.deadline then
			self.pending[item_id] = nil
			info.timedOut = not info.ready
			for _, callback in ipairs(request.callbacks) do
				local result = Compat.Pack(pcall(callback, info))
				if not result[1] then Compat:ReportError(result[2]) end
			end
		end
	end
	if not next(self.pending) and self.poller then
		self.poller:Cancel()
		self.poller = nil
	end
end

function Item:RequestInfo(item, callback, timeout)
	local item_id = self:GetID(item)
	if not item_id then return Compat:Result(false, "invalid_item") end
	local info = self:GetInfo(item_id)
	if info.ready then
		if type(callback) == "function" then
			local result = Compat.Pack(pcall(callback, info))
			if not result[1] then Compat:ReportError(result[2]) end
		end
		return Compat:Result(true, "ready", { info = info })
	end
	local request = self.pending[item_id]
	if not request then
		request = { callbacks = {}, deadline = Compat.Now() + (tonumber(timeout) or self.requestTimeout) }
		self.pending[item_id] = request
	end
	if type(callback) == "function" then request.callbacks[#request.callbacks + 1] = callback end
	if Compat.Timer and not self.poller then
		self.poller = Compat.Timer:NewTicker(self.pollInterval, function() Item:_PollRequests() end)
	end
	return Compat:Result(true, "pending", { itemID = item_id, info = info })
end

local function item_action(action, item)
	if type(action) ~= "function" then return Compat:Result(false, "api_unavailable", { itemID = Item:GetID(item) }) end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then
		return Compat:Result(false, "combat_lockdown", { itemID = Item:GetID(item) })
	end
	local result = Compat.Pack(pcall(action, item))
	return Compat:Result(result[1], result[1] and "performed" or "lua_error", { itemID = Item:GetID(item), error = result[2] })
end

function Item:Pickup(item) return item_action(_G.PickupItem, item) end
function Item:Equip(item) return item_action(_G.EquipItemByName, item) end

function Item:GetBinding(item)
	if not Compat.Tooltip then return { itemID = self:GetID(item), known = false, reason = "tooltip_unavailable" } end
	return Compat.Tooltip:GetItemBinding(item)
end
