local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Gossip = Compat:CreateService("Gossip")

local function call_values(func)
	if type(func) ~= "function" then return nil, "api_unavailable" end
	local result = Compat.Pack(pcall(func))
	if not result[1] then return nil, result[2] end
	local values = { n = result.n - 1 }
	for index = 2, result.n do values[index - 1] = result[index] end
	return values
end

local function clean_text(text)
	if type(text) ~= "string" then return text end
	text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
	text = string.gsub(text, "|r", "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	text = string.gsub(text, "%s+", " ")
	return text
end

local function text_matches(actual, expected, insensitive)
	actual, expected = clean_text(actual), clean_text(expected)
	if insensitive and type(actual) == "string" and type(expected) == "string" then
		return string.lower(actual) == string.lower(expected)
	end
	return actual == expected
end

function Gossip:GetOptions()
	local values, error_message = call_values(_G.GetGossipOptions)
	if not values then return {}, error_message end
	local options = {}
	for offset = 1, values.n, 2 do
		local text, option_type = values[offset], values[offset + 1]
		if text then
			local index = math.floor((offset + 1) / 2)
			options[#options + 1] = {
				index = index,
				id = index,
				gossipOptionID = index,
				text = text,
				name = text,
				type = option_type,
			}
		end
	end
	return options
end

function Gossip:ResolveOption(criteria)
	if type(criteria) == "string" then criteria = { text = criteria } end
	if type(criteria) == "number" then criteria = { index = criteria } end
	criteria = criteria or {}
	local options, error_message = self:GetOptions()
	if error_message then
		return Compat:Result(false, "api_unavailable", { error = error_message, candidates = {} })
	end
	local candidates = {}
	for _, option in ipairs(options) do
		local matches = true
		if criteria.index and option.index ~= tonumber(criteria.index) then matches = false end
		if criteria.type and option.type ~= criteria.type then matches = false end
		if criteria.text and not text_matches(option.text, criteria.text, criteria.caseInsensitive) then matches = false end
		if matches then candidates[#candidates + 1] = option end
	end
	if #candidates == 1 then
		return Compat:Result(true, "unique", { option = candidates[1], candidates = candidates })
	elseif #candidates == 0 then
		return Compat:Result(false, "missing", { candidates = candidates, options = options })
	end
	return Compat:Result(false, "ambiguous", { candidates = candidates, options = options })
end

function Gossip:SelectOption(criteria)
	local resolved = self:ResolveOption(criteria)
	if not resolved.ok then return resolved end
	if type(_G.SelectGossipOption) ~= "function" then
		return Compat:Result(false, "api_unavailable", { option = resolved.option })
	end
	local call = Compat.Pack(pcall(_G.SelectGossipOption, resolved.option.index))
	return Compat:Result(call[1], call[1] and "selected" or "lua_error", {
		option = resolved.option,
		error = call[2],
	})
end

local function get_quest_records(kind)
	local active = kind == "active"
	local count_func = active and _G.GetNumGossipActiveQuests or _G.GetNumGossipAvailableQuests
	local list_func = active and _G.GetGossipActiveQuests or _G.GetGossipAvailableQuests
	local count = type(count_func) == "function" and tonumber(count_func()) or 0
	local values, error_message = call_values(list_func)
	if not values then return {}, error_message end
	if count <= 0 then return {} end
	local stride = math.floor(values.n / count)
	if stride < 3 then stride = 3 end
	local quests = {}
	for index = 1, count do
		local offset = (index - 1) * stride + 1
		local title = values[offset]
		if title then
			local quest = {
				index = index,
				title = title,
				name = title,
				level = tonumber(values[offset + 1]) or 0,
				isTrivial = Compat.Bool(values[offset + 2]),
				kind = kind,
			}
			if active then
				quest.isComplete = Compat.Bool(values[offset + 3])
			else
				quest.isDaily = Compat.Bool(values[offset + 3])
				quest.isRepeatable = Compat.Bool(values[offset + 4])
			end
			if Compat.Quest then
				local log_entry = Compat.Quest:FindInLog(title)
				if log_entry and log_entry.index then quest.questID = log_entry.questID end
			end
			quests[#quests + 1] = quest
		end
	end
	return quests
end

function Gossip:GetAvailableQuests()
	return get_quest_records("available")
end

function Gossip:GetActiveQuests()
	return get_quest_records("active")
end

function Gossip:ResolveQuest(kind, criteria)
	if type(criteria) == "string" then criteria = { title = criteria } end
	if type(criteria) == "number" then criteria = { questID = criteria } end
	criteria = criteria or {}
	local expected_title = criteria.title
	if not expected_title and criteria.questID and type(ZGV.Data) == "table" then
		local quests = ZGV.Data.Quests or ZGV.Data.quests
		local data = type(quests) == "table" and (quests[tonumber(criteria.questID)] or quests[tostring(criteria.questID)]) or nil
		if type(data) == "string" then expected_title = data
		elseif type(data) == "table" then expected_title = data.title or data.name end
	end
	local quests, error_message = get_quest_records(kind)
	if error_message then return Compat:Result(false, "api_unavailable", { error = error_message, candidates = {} }) end
	local candidates = {}
	for _, quest in ipairs(quests) do
		local matches = true
		if criteria.index and quest.index ~= tonumber(criteria.index) then matches = false end
		if criteria.questID then
			if quest.questID then
				if quest.questID ~= tonumber(criteria.questID) then matches = false end
			elseif expected_title then
				if not text_matches(quest.title, expected_title, criteria.caseInsensitive) then matches = false end
			else
				matches = false
			end
		end
		if criteria.level and quest.level ~= tonumber(criteria.level) then matches = false end
		if expected_title and not text_matches(quest.title, expected_title, criteria.caseInsensitive) then matches = false end
		if matches then candidates[#candidates + 1] = quest end
	end
	if #candidates == 1 then return Compat:Result(true, "unique", { quest = candidates[1], candidates = candidates }) end
	if #candidates == 0 then return Compat:Result(false, "missing", { candidates = candidates, quests = quests }) end
	return Compat:Result(false, "ambiguous", { candidates = candidates, quests = quests })
end

function Gossip:SelectQuest(kind, criteria)
	local resolved = self:ResolveQuest(kind, criteria)
	if not resolved.ok then return resolved end
	local func = kind == "active" and _G.SelectGossipActiveQuest or _G.SelectGossipAvailableQuest
	if type(func) ~= "function" then return Compat:Result(false, "api_unavailable", { quest = resolved.quest }) end
	local call = Compat.Pack(pcall(func, resolved.quest.index))
	return Compat:Result(call[1], call[1] and "selected" or "lua_error", { quest = resolved.quest, error = call[2] })
end

function Gossip:Close()
	if type(_G.CloseGossip) ~= "function" then return Compat:Result(false, "api_unavailable") end
	local call = Compat.Pack(pcall(_G.CloseGossip))
	return Compat:Result(call[1], call[1] and "closed" or "lua_error", { error = call[2] })
end
