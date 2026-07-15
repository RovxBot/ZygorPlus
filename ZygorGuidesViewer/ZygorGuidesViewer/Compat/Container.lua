local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Container = Compat:CreateService("Container")

Container.bankOpen = Container.bankOpen or false

local function parse_item_id(link)
	return type(link) == "string" and tonumber(string.match(link, "item:(%d+)")) or nil
end

function Container:GetNumSlots(bag)
	if type(_G.GetContainerNumSlots) ~= "function" then return { bag = bag, count = 0, available = false } end
	return { bag = bag, count = tonumber(_G.GetContainerNumSlots(bag)) or 0, available = true }
end

function Container:GetNumFreeSlots(bag)
	if type(_G.GetContainerNumFreeSlots) ~= "function" then
		return { bag = bag, free = 0, bagFamily = 0, available = false }
	end
	local free, bag_family = _G.GetContainerNumFreeSlots(bag)
	return { bag = bag, free = tonumber(free) or 0, bagFamily = tonumber(bag_family) or 0, available = true }
end

function Container:GetItemInfo(bag, slot)
	if type(_G.GetContainerItemInfo) ~= "function" then
		return { bag = bag, slot = slot, ready = false, reason = "api_unavailable" }
	end
	local texture, count, locked, quality, readable, lootable, link, filtered, no_value, item_id =
		_G.GetContainerItemInfo(bag, slot)
	if not link and type(_G.GetContainerItemLink) == "function" then link = _G.GetContainerItemLink(bag, slot) end
	item_id = tonumber(item_id) or parse_item_id(link)
	local is_quest_item, quest_id, is_active
	if type(_G.GetContainerItemQuestInfo) == "function" then
		is_quest_item, quest_id, is_active = _G.GetContainerItemQuestInfo(bag, slot)
	end
	return {
		bag = bag,
		slot = slot,
		itemID = item_id,
		id = item_id,
		iconFileID = texture,
		texture = texture,
		count = tonumber(count) or 0,
		isLocked = Compat.Bool(locked),
		quality = tonumber(quality),
		isReadable = Compat.Bool(readable),
		isLootable = Compat.Bool(lootable),
		hyperlink = link,
		itemLink = link,
		isFiltered = Compat.Bool(filtered),
		hasNoValue = Compat.Bool(no_value),
		isQuestItem = Compat.Bool(is_quest_item),
		questID = tonumber(quest_id),
		isQuestActive = Compat.Bool(is_active),
		ready = texture ~= nil or link ~= nil,
	}
end

function Container:GetItemID(bag, slot)
	return self:GetItemInfo(bag, slot).itemID
end

function Container:GetItemLink(bag, slot)
	return self:GetItemInfo(bag, slot).itemLink
end

function Container:GetInventoryID(bag)
	if type(_G.ContainerIDToInventoryID) ~= "function" then return nil end
	return _G.ContainerIDToInventoryID(bag)
end

function Container:GetBags(options)
	options = options or {}
	local bags = { 0 }
	local bag_slots = tonumber(_G.NUM_BAG_SLOTS) or 4
	for bag = 1, bag_slots do bags[#bags + 1] = bag end
	if options.includeKeyring then bags[#bags + 1] = _G.KEYRING_CONTAINER or -2 end
	if options.includeBank and (self.bankOpen or options.allowClosedBank) then
		bags[#bags + 1] = _G.BANK_CONTAINER or -1
		local first = (_G.NUM_BAG_SLOTS or 4) + 1
		local last = first + (_G.NUM_BANKBAGSLOTS or 7) - 1
		for bag = first, last do bags[#bags + 1] = bag end
	end
	return bags
end

function Container:Enumerate(options)
	local items = {}
	for _, bag in ipairs(self:GetBags(options)) do
		local slots = self:GetNumSlots(bag).count
		for slot = 1, slots do
			local item = self:GetItemInfo(bag, slot)
			if item.ready then items[#items + 1] = item end
		end
	end
	return items
end

function Container:FindItem(item_id, options)
	item_id = tonumber(item_id)
	local found = {}
	for _, item in ipairs(self:Enumerate(options)) do
		if item.itemID == item_id then found[#found + 1] = item end
	end
	return found
end

local function container_action(func, code, bag, slot, extra)
	if type(func) ~= "function" then return Compat:Result(false, "api_unavailable", { bag = bag, slot = slot }) end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then
		return Compat:Result(false, "combat_lockdown", { bag = bag, slot = slot })
	end
	local result
	if extra ~= nil then result = Compat.Pack(pcall(func, bag, slot, extra))
	else result = Compat.Pack(pcall(func, bag, slot)) end
	return Compat:Result(result[1], result[1] and code or "lua_error", { bag = bag, slot = slot, error = result[2] })
end

function Container:Pickup(bag, slot) return container_action(_G.PickupContainerItem, "picked_up", bag, slot) end
function Container:Use(bag, slot) return container_action(_G.UseContainerItem, "used", bag, slot) end
function Container:Split(bag, slot, count) return container_action(_G.SplitContainerItem, "split", bag, slot, tonumber(count) or 1) end

function Container:OnEvent(event)
	if event == "BANKFRAME_OPENED" then self.bankOpen = true
	elseif event == "BANKFRAME_CLOSED" then self.bankOpen = false end
end

Compat:RegisterEvent("BANKFRAME_OPENED", Container, "OnEvent")
Compat:RegisterEvent("BANKFRAME_CLOSED", Container, "OnEvent")
