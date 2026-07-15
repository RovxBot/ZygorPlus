local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Tooltip = Compat:CreateService("Tooltip")

local TOOLTIP_NAME = "ZGVCompatScanningTooltip"

function Tooltip:_GetFrame()
	if self.frame then return self.frame end
	if type(_G.CreateFrame) ~= "function" then return nil end
	local parent = _G.UIParent or _G.WorldFrame
	local frame = _G[TOOLTIP_NAME] or _G.CreateFrame("GameTooltip", TOOLTIP_NAME, parent, "GameTooltipTemplate")
	frame:SetOwner(parent, "ANCHOR_NONE")
	self.frame = frame
	return frame
end

function Tooltip:_Read(kind, reference)
	local frame = self:_GetFrame()
	if not frame then return { kind = kind, reference = reference, ready = false, reason = "api_unavailable", lines = {} } end
	frame:Show()
	local lines = {}
	local line_count = tonumber(frame:NumLines()) or 0
	for index = 1, line_count do
		local left_region = _G[TOOLTIP_NAME .. "TextLeft" .. index]
		local right_region = _G[TOOLTIP_NAME .. "TextRight" .. index]
		local left = left_region and left_region:GetText() or nil
		local right = right_region and right_region:GetText() or nil
		local left_r, left_g, left_b
		local right_r, right_g, right_b
		if left_region and left_region.GetTextColor then left_r, left_g, left_b = left_region:GetTextColor() end
		if right_region and right_region.GetTextColor then right_r, right_g, right_b = right_region:GetTextColor() end
		lines[#lines + 1] = {
			index = index,
			left = left,
			right = right,
			leftColor = { r = left_r, g = left_g, b = left_b },
			rightColor = { r = right_r, g = right_g, b = right_b },
		}
	end
	frame:Hide()
	frame:ClearLines()
	local text = {}
	for _, line in ipairs(lines) do
		if line.left then text[#text + 1] = line.left end
		if line.right then text[#text + 1] = line.right end
	end
	return {
		kind = kind,
		reference = reference,
		ready = #lines > 0,
		lines = lines,
		text = table.concat(text, "\n"),
	}
end

function Tooltip:ScanHyperlink(link)
	local frame = self:_GetFrame()
	if not frame or type(link) ~= "string" then return { kind = "hyperlink", reference = link, ready = false, reason = "invalid_link", lines = {} } end
	frame:ClearLines()
	frame:SetOwner(_G.UIParent or _G.WorldFrame, "ANCHOR_NONE")
	local result = Compat.Pack(pcall(frame.SetHyperlink, frame, link))
	if not result[1] then
		frame:Hide()
		return { kind = "hyperlink", reference = link, ready = false, reason = "scan_failed", error = result[2], lines = {} }
	end
	return self:_Read("hyperlink", link)
end

function Tooltip:ScanItem(item)
	local link = type(item) == "string" and item or ("item:" .. tostring(item))
	local scan = self:ScanHyperlink(link)
	scan.kind = "item"
	scan.itemID = Compat.Item and Compat.Item:GetID(item) or tonumber(item)
	if Compat.Item then
		local info = Compat.Item:GetInfo(item)
		if not info.ready then
			scan.ready = false
			scan.reason = "not_cached"
		end
	end
	return scan
end

function Tooltip:ScanSpell(spell_id)
	local frame = self:_GetFrame()
	if not frame then return { kind = "spell", spellID = tonumber(spell_id), ready = false, reason = "api_unavailable", lines = {} } end
	frame:ClearLines()
	frame:SetOwner(_G.UIParent or _G.WorldFrame, "ANCHOR_NONE")
	local result
	if type(frame.SetSpellByID) == "function" then result = Compat.Pack(pcall(frame.SetSpellByID, frame, spell_id))
	else result = Compat.Pack(pcall(frame.SetHyperlink, frame, "spell:" .. tostring(spell_id))) end
	if not result[1] then return { kind = "spell", spellID = tonumber(spell_id), ready = false, reason = "scan_failed", error = result[2], lines = {} } end
	local scan = self:_Read("spell", spell_id)
	scan.spellID = tonumber(spell_id)
	return scan
end

function Tooltip:ScanBagItem(bag, slot)
	local frame = self:_GetFrame()
	if not frame or type(frame.SetBagItem) ~= "function" then
		return { kind = "bagItem", bag = bag, slot = slot, ready = false, reason = "api_unavailable", lines = {} }
	end
	frame:ClearLines()
	frame:SetOwner(_G.UIParent or _G.WorldFrame, "ANCHOR_NONE")
	local result = Compat.Pack(pcall(frame.SetBagItem, frame, bag, slot))
	if not result[1] then return { kind = "bagItem", bag = bag, slot = slot, ready = false, reason = "scan_failed", error = result[2], lines = {} } end
	local scan = self:_Read("bagItem", { bag = bag, slot = slot })
	scan.bag, scan.slot = bag, slot
	return scan
end

function Tooltip:ScanInventoryItem(unit, slot)
	local frame = self:_GetFrame()
	if not frame or type(frame.SetInventoryItem) ~= "function" then
		return { kind = "inventoryItem", unit = unit, slot = slot, ready = false, reason = "api_unavailable", lines = {} }
	end
	frame:ClearLines()
	frame:SetOwner(_G.UIParent or _G.WorldFrame, "ANCHOR_NONE")
	local result = Compat.Pack(pcall(frame.SetInventoryItem, frame, unit or "player", slot))
	if not result[1] then return { kind = "inventoryItem", unit = unit, slot = slot, ready = false, reason = "scan_failed", error = result[2], lines = {} } end
	local scan = self:_Read("inventoryItem", { unit = unit or "player", slot = slot })
	scan.unit, scan.slot = unit or "player", slot
	return scan
end

function Tooltip:ScanUnit(unit)
	local frame = self:_GetFrame()
	if not frame or type(frame.SetUnit) ~= "function" then return { kind = "unit", unit = unit, ready = false, reason = "api_unavailable", lines = {} } end
	frame:ClearLines()
	frame:SetOwner(_G.UIParent or _G.WorldFrame, "ANCHOR_NONE")
	local result = Compat.Pack(pcall(frame.SetUnit, frame, unit))
	if not result[1] then return { kind = "unit", unit = unit, ready = false, reason = "scan_failed", error = result[2], lines = {} } end
	local scan = self:_Read("unit", unit)
	scan.unit = unit
	return scan
end

function Tooltip:ScanQuestLogItem(item_type, item_index, quest_index)
	local frame = self:_GetFrame()
	if not frame or type(frame.SetQuestLogItem) ~= "function" then return { kind = "questItem", ready = false, reason = "api_unavailable", lines = {} } end
	local old_selection = type(_G.GetQuestLogSelection) == "function" and _G.GetQuestLogSelection() or nil
	if quest_index and type(_G.SelectQuestLogEntry) == "function" then
		local selected, select_error = pcall(_G.SelectQuestLogEntry, quest_index)
		if not selected then return { kind = "questItem", ready = false, reason = "selection_failed", error = select_error, lines = {} } end
	end
	frame:ClearLines()
	frame:SetOwner(_G.UIParent or _G.WorldFrame, "ANCHOR_NONE")
	local result = Compat.Pack(pcall(frame.SetQuestLogItem, frame, item_type, item_index))
	if old_selection ~= nil and type(_G.SelectQuestLogEntry) == "function" then pcall(_G.SelectQuestLogEntry, old_selection) end
	if not result[1] then return { kind = "questItem", ready = false, reason = "scan_failed", error = result[2], lines = {} } end
	return self:_Read("questItem", { itemType = item_type, itemIndex = item_index, questIndex = quest_index })
end

function Tooltip:Contains(scan, text, plain)
	if type(scan) ~= "table" or type(scan.text) ~= "string" or type(text) ~= "string" then return false end
	return string.find(scan.text, text, 1, plain ~= false) ~= nil
end

function Tooltip:GetItemBinding(item)
	local scan
	if type(item) == "table" and item.bag ~= nil and item.slot then
		scan = self:ScanBagItem(item.bag, item.slot)
		scan.itemID = item.itemID or (Compat.Container and Compat.Container:GetItemID(item.bag, item.slot))
	elseif type(item) == "table" and item.inventorySlot then
		scan = self:ScanInventoryItem(item.unit or "player", item.inventorySlot)
		scan.itemID = item.itemID
	else
		scan = self:ScanItem(item)
	end
	local constants = {
		{ code = "soulbound", text = _G.ITEM_SOULBOUND },
		{ code = "bind_on_pickup", text = _G.ITEM_BIND_ON_PICKUP },
		{ code = "bind_on_equip", text = _G.ITEM_BIND_ON_EQUIP },
		{ code = "bind_on_use", text = _G.ITEM_BIND_ON_USE },
		{ code = "account_bound", text = _G.ITEM_BIND_TO_ACCOUNT },
	}
	for _, binding in ipairs(constants) do
		if binding.text and self:Contains(scan, binding.text, true) then
			return { itemID = scan.itemID, known = true, bound = binding.code == "soulbound" or binding.code == "account_bound", binding = binding.code, scan = scan }
		end
	end
	return { itemID = scan.itemID, known = scan.ready, bound = false, binding = nil, scan = scan }
end
