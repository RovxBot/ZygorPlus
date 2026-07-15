local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Quest = Compat:CreateService("Quest")

Quest.completed = Quest.completed or {}
Quest.completedState = Quest.completedState or "cold"
Quest.completedUpdatedAt = Quest.completedUpdatedAt or 0
Quest.queryThrottle = Quest.queryThrottle or 10
Quest.queryTimeout = Quest.queryTimeout or 15
Quest.queryGeneration = Quest.queryGeneration or 0
Quest.pendingCallbacks = Quest.pendingCallbacks or {}
Quest.log = Quest.log or { entries = {}, byID = {}, byTitle = {}, updatedAt = 0 }

local function parse_progress(text)
	if type(text) ~= "string" then return nil, nil end
	local current, required = string.match(text, "(%d+)%s*/%s*(%d+)")
	return tonumber(current), tonumber(required)
end

local function read_objectives(quest_index)
	local objectives = {}
	if type(_G.GetNumQuestLeaderBoards) ~= "function" or type(_G.GetQuestLogLeaderBoard) ~= "function" then
		return objectives
	end
	local count = tonumber(_G.GetNumQuestLeaderBoards(quest_index)) or 0
	for objective_index = 1, count do
		local text, objective_type, finished = _G.GetQuestLogLeaderBoard(objective_index, quest_index)
		local current, required = parse_progress(text)
		objectives[#objectives + 1] = {
			index = objective_index,
			text = text,
			description = text,
			type = objective_type,
			finished = Compat.Bool(finished),
			current = current,
			required = required,
		}
	end
	return objectives
end

function Quest:GetLogEntry(index, with_objectives)
	if type(_G.GetQuestLogTitle) ~= "function" then return nil end
	local title, level, tag, suggested_group, is_header, is_collapsed, completion,
		is_daily, quest_id = _G.GetQuestLogTitle(index)
	if not title then return nil end
	local entry = {
		index = index,
		questID = tonumber(quest_id),
		id = tonumber(quest_id),
		title = title,
		level = tonumber(level) or 0,
		tag = tag,
		suggestedGroup = tonumber(suggested_group) or 0,
		isHeader = Compat.Bool(is_header),
		isCollapsed = Compat.Bool(is_collapsed),
		completionState = tonumber(completion),
		isComplete = completion == 1 or completion == true,
		isFailed = completion == -1,
		isDaily = Compat.Bool(is_daily),
	}
	if with_objectives ~= false and not entry.isHeader then
		entry.objectives = read_objectives(index)
	else
		entry.objectives = {}
	end
	return entry
end

function Quest:RefreshLog()
	local reported_entries = 0
	if type(_G.GetNumQuestLogEntries) == "function" then
		reported_entries = tonumber((_G.GetNumQuestLogEntries())) or 0
	end
	-- 3.3.5 clients can under-report entries when headers are collapsed. Reading
	-- through the fixed upper bound is non-mutating and recovers every visible row.
	local upper_bound = math.max(reported_entries, 50)
	local snapshot = { entries = {}, byID = {}, byTitle = {}, updatedAt = Compat.Now() }
	local empty_run = 0
	for index = 1, upper_bound do
		local entry = self:GetLogEntry(index, true)
		if entry then
			empty_run = 0
			snapshot.entries[#snapshot.entries + 1] = entry
			if not entry.isHeader then
				if entry.questID then snapshot.byID[entry.questID] = entry end
				local same_title = snapshot.byTitle[entry.title]
				if same_title then
					if same_title.index then snapshot.byTitle[entry.title] = { same_title, entry }
					else same_title[#same_title + 1] = entry end
				else
					snapshot.byTitle[entry.title] = entry
				end
			end
		else
			empty_run = empty_run + 1
			if index > reported_entries and empty_run >= 5 then break end
		end
	end
	self.log = snapshot
	Compat:Fire("QUEST_LOG_CACHE_UPDATED", snapshot)
	return snapshot
end

function Quest:GetLog()
	if not self.log.updatedAt or self.log.updatedAt == 0 then return self:RefreshLog() end
	return self.log
end

function Quest:FindInLog(quest_or_title)
	local log = self:GetLog()
	if type(quest_or_title) == "number" or tonumber(quest_or_title) then
		return log.byID[tonumber(quest_or_title)]
	end
	return log.byTitle[quest_or_title]
end

function Quest:IsOnQuest(quest_id)
	local entry = self:FindInLog(tonumber(quest_id))
	return entry ~= nil, entry
end

local function normalize_completed(raw)
	local completed = {}
	if type(raw) ~= "table" then return completed end
	local array_length = #raw
	for index = 1, array_length do
		local quest_id = tonumber(raw[index])
		if quest_id then completed[quest_id] = true end
	end
	for key, value in pairs(raw) do
		local numeric_key = tonumber(key)
		if numeric_key and (value == true or value == 1) then
			completed[numeric_key] = true
		elseif type(value) == "number" then
			completed[value] = true
		end
	end
	return completed
end

function Quest:_ReadCompleted()
	if type(_G.GetQuestsCompleted) ~= "function" then
		return nil, "api_unavailable"
	end
	-- Build 12340 uses an output-table contract.  Some private servers expose
	-- the later no-argument/table-return shape, so try that only when the native
	-- call itself rejects the table argument.
	local target = {}
	local call = Compat.Pack(pcall(_G.GetQuestsCompleted, target))
	local raw
	if call[1] then
		raw = type(call[2]) == "table" and call[2] or target
	else
		local table_error = call[2]
		call = Compat.Pack(pcall(_G.GetQuestsCompleted))
		if not call[1] then return nil, tostring(table_error) .. "; fallback: " .. tostring(call[2]) end
		if type(call[2]) ~= "table" then return nil, "invalid completed-quest result" end
		raw = call[2]
	end
	return normalize_completed(raw)
end

function Quest:_FinishCallbacks(result)
	local callbacks = self.pendingCallbacks
	self.pendingCallbacks = {}
	for _, callback in ipairs(callbacks) do
		local call = Compat.Pack(pcall(callback, result))
		if not call[1] then Compat:ReportError(call[2]) end
	end
end

function Quest:_AcceptCompleted(completed)
	self.completed = completed
	self.completedState = "ready"
	self.completedUpdatedAt = Compat.Now()
	local result = Compat:Result(true, "ready", {
		state = self.completedState,
		updatedAt = self.completedUpdatedAt,
		completed = self.completed,
	})
	self:_FinishCallbacks(result)
	Compat:Fire("QUEST_COMPLETED_CACHE_UPDATED", result)
	return result
end

function Quest:OnCompletedQuery()
	local completed, error_message = self:_ReadCompleted()
	if not completed then
		self.completedState = self.completedUpdatedAt > 0 and "stale" or "unavailable"
		local result = Compat:Result(false, "read_failed", {
			state = self.completedState,
			error = error_message,
			completed = self.completed,
		})
		self:_FinishCallbacks(result)
		Compat:Fire("QUEST_COMPLETED_CACHE_UPDATED", result)
		return result
	end
	return self:_AcceptCompleted(completed)
end

function Quest:_OnQueryTimeout(generation)
	if generation ~= self.queryGeneration or self.completedState ~= "querying" then return end
	self.completedState = self.completedUpdatedAt > 0 and "stale" or "unavailable"
	local result = Compat:Result(false, "timeout", {
		state = self.completedState,
		completed = self.completed,
		stale = self.completedUpdatedAt > 0,
	})
	self:_FinishCallbacks(result)
	Compat:Fire("QUEST_COMPLETED_CACHE_UPDATED", result)
end

function Quest:RefreshCompleted(force, callback)
	if type(callback) == "function" then self.pendingCallbacks[#self.pendingCallbacks + 1] = callback end
	if self.completedState == "querying" and not force then
		return Compat:Result(true, "already_querying", { state = self.completedState })
	end
	local now = Compat.Now()
	if not force and self.completedState == "ready" and now - self.completedUpdatedAt < self.queryThrottle then
		local result = Compat:Result(true, "fresh", {
			state = self.completedState,
			updatedAt = self.completedUpdatedAt,
			completed = self.completed,
		})
		self:_FinishCallbacks(result)
		return result
	end
	if not force and self.lastQueryAt and now - self.lastQueryAt < self.queryThrottle then
		local result = Compat:Result(false, "query_throttled", {
			state = self.completedState,
			retryAfter = self.queryThrottle - (now - self.lastQueryAt),
			completed = self.completed,
		})
		self:_FinishCallbacks(result)
		return result
	end
	if type(_G.GetQuestsCompleted) ~= "function" then
		self.completedState = "unavailable"
		local result = Compat:Result(false, "api_unavailable", { state = self.completedState })
		self:_FinishCallbacks(result)
		return result
	end
	if type(_G.QueryQuestsCompleted) ~= "function" then
		return self:OnCompletedQuery()
	end
	self.queryGeneration = self.queryGeneration + 1
	local generation = self.queryGeneration
	self.completedState = "querying"
	self.lastQueryAt = now
	local call = Compat.Pack(pcall(_G.QueryQuestsCompleted))
	if not call[1] then
		self.completedState = self.completedUpdatedAt > 0 and "stale" or "unavailable"
		local result = Compat:Result(false, "query_failed", { state = self.completedState, error = call[2] })
		self:_FinishCallbacks(result)
		return result
	end
	if Compat.Timer then
		Compat.Timer:After(self.queryTimeout, function() Quest:_OnQueryTimeout(generation) end)
	end
	return Compat:Result(true, "query_started", { state = self.completedState, generation = generation })
end

function Quest:GetCompletion(quest_id)
	quest_id = tonumber(quest_id)
	local has_snapshot = self.completedUpdatedAt > 0
	return {
		questID = quest_id,
		completed = quest_id and self.completed[quest_id] == true or false,
		known = has_snapshot,
		fresh = self.completedState == "ready",
		pending = self.completedState == "querying",
		state = self.completedState,
		updatedAt = self.completedUpdatedAt,
		stale = self.completedState == "stale",
	}
end

function Quest:IsCompleted(quest_id)
	local result = self:GetCompletion(quest_id)
	return result.completed, result.known, result
end

-- A completed-quest query is asynchronous on 3.3.5a and ChromieCraft may
-- not publish its new snapshot until after the quest window closes.  A
-- successful GetQuestReward call is an exact local fact, so retain it until
-- the next query reconciles the authoritative table.  Do not alter the
-- snapshot timestamp: callers can still distinguish this bridge from a full
-- historical completion scan.
function Quest:MarkCompleted(quest_id, source)
	quest_id = tonumber(quest_id)
	if not quest_id then return false end
	self.completed = self.completed or {}
	if self.completed[quest_id] then return false end
	self.completed[quest_id] = true
	Compat:Fire("QUEST_COMPLETED_LOCAL", quest_id, source or "local")
	return true
end

local function get_quest_reward(kind, index)
	if type(_G.GetQuestItemInfo) ~= "function" then return nil end
	local name, texture, count, quality, usable, item_id = _G.GetQuestItemInfo(kind, index)
	local link = type(_G.GetQuestItemLink) == "function" and _G.GetQuestItemLink(kind, index) or nil
	if not item_id and type(link) == "string" then item_id = tonumber(string.match(link, "item:(%d+)")) end
	if not name and not link then return nil end
	return {
		index = index,
		kind = kind,
		itemID = tonumber(item_id),
		name = name,
		iconFileID = texture,
		texture = texture,
		count = tonumber(count) or 1,
		quality = tonumber(quality),
		isUsable = Compat.Bool(usable),
		hyperlink = link,
		itemLink = link,
	}
end

function Quest:GetDialog()
	local choice_count = type(_G.GetNumQuestChoices) == "function" and tonumber(_G.GetNumQuestChoices()) or 0
	local reward_count = type(_G.GetNumQuestRewards) == "function" and tonumber(_G.GetNumQuestRewards()) or 0
	local choices, rewards = {}, {}
	for index = 1, choice_count do
		local reward = get_quest_reward("choice", index)
		if reward then choices[#choices + 1] = reward end
	end
	for index = 1, reward_count do
		local reward = get_quest_reward("reward", index)
		if reward then rewards[#rewards + 1] = reward end
	end
	local quest_id = type(_G.GetQuestID) == "function" and tonumber(_G.GetQuestID()) or nil
	return {
		questID = quest_id,
		title = type(_G.GetTitleText) == "function" and _G.GetTitleText() or nil,
		description = type(_G.GetQuestText) == "function" and _G.GetQuestText() or nil,
		progressText = type(_G.GetProgressText) == "function" and _G.GetProgressText() or nil,
		rewardText = type(_G.GetRewardText) == "function" and _G.GetRewardText() or nil,
		isCompletable = type(_G.IsQuestCompletable) == "function" and Compat.Bool(_G.IsQuestCompletable()) or nil,
		choiceCount = choice_count,
		rewardCount = reward_count,
		choices = choices,
		rewards = rewards,
	}
end

local function quest_action(func, success_code, ...)
	if type(func) ~= "function" then return Compat:Result(false, "api_unavailable") end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then return Compat:Result(false, "combat_lockdown") end
	local result = Compat.Pack(pcall(func, ...))
	return Compat:Result(result[1], result[1] and success_code or "lua_error", { error = result[2] })
end

function Quest:Accept()
	return quest_action(_G.AcceptQuest, "accept_requested")
end

function Quest:Complete()
	if type(_G.IsQuestCompletable) == "function" and not Compat.Bool(_G.IsQuestCompletable()) then
		return Compat:Result(false, "not_completable")
	end
	return quest_action(_G.CompleteQuest, "completion_requested")
end

function Quest:ClaimReward(choice_index)
	local choices = type(_G.GetNumQuestChoices) == "function" and tonumber(_G.GetNumQuestChoices()) or 0
	choice_index = tonumber(choice_index)
	if choices > 0 and (not choice_index or choice_index < 1 or choice_index > choices) then
		return Compat:Result(false, "reward_choice_required", { choiceCount = choices })
	end
	if choices > 0 then return quest_action(_G.GetQuestReward, "reward_requested", choice_index) end
	return quest_action(_G.GetQuestReward, "reward_requested")
end

function Quest:Decline()
	return quest_action(_G.DeclineQuest, "declined")
end

function Quest:AddWatch(quest_id)
	local entry = self:FindInLog(tonumber(quest_id))
	if not entry then return Compat:Result(false, "not_in_log", { questID = tonumber(quest_id) }) end
	if type(_G.IsQuestWatched) == "function" and _G.IsQuestWatched(entry.index) then
		return Compat:Result(true, "already_watched", { entry = entry })
	end
	if type(_G.AddQuestWatch) ~= "function" then return Compat:Result(false, "api_unavailable", { entry = entry }) end
	local call = Compat.Pack(pcall(_G.AddQuestWatch, entry.index))
	return Compat:Result(call[1], call[1] and "watched" or "lua_error", { entry = entry, error = call[2] })
end

function Quest:RemoveWatch(quest_id)
	local entry = self:FindInLog(tonumber(quest_id))
	if not entry then return Compat:Result(false, "not_in_log", { questID = tonumber(quest_id) }) end
	if type(_G.RemoveQuestWatch) ~= "function" then return Compat:Result(false, "api_unavailable", { entry = entry }) end
	local call = Compat.Pack(pcall(_G.RemoveQuestWatch, entry.index))
	return Compat:Result(call[1], call[1] and "removed" or "lua_error", { entry = entry, error = call[2] })
end

function Quest:Abandon(quest_id)
	local entry = self:FindInLog(tonumber(quest_id))
	if not entry then return Compat:Result(false, "not_in_log", { questID = tonumber(quest_id) }) end
	if type(_G.SelectQuestLogEntry) ~= "function" or type(_G.SetAbandonQuest) ~= "function" or type(_G.AbandonQuest) ~= "function" then
		return Compat:Result(false, "api_unavailable", { entry = entry })
	end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then
		return Compat:Result(false, "combat_lockdown", { entry = entry })
	end
	local old_selection = type(_G.GetQuestLogSelection) == "function" and _G.GetQuestLogSelection() or nil
	local call = Compat.Pack(pcall(function()
		_G.SelectQuestLogEntry(entry.index)
		_G.SetAbandonQuest()
		_G.AbandonQuest()
	end))
	if old_selection and old_selection > 0 then pcall(_G.SelectQuestLogEntry, old_selection) end
	return Compat:Result(call[1], call[1] and "abandoned" or "lua_error", { entry = entry, error = call[2] })
end

function Quest:OnEvent(event)
	if event == "QUEST_QUERY_COMPLETE" then
		self:OnCompletedQuery()
	elseif event == "QUEST_LOG_UPDATE" then
		self:RefreshLog()
	elseif event == "PLAYER_LOGIN" then
		self:RefreshLog()
		self:RefreshCompleted(false)
	end
end

Compat:RegisterEvent("PLAYER_LOGIN", Quest, "OnEvent")
Compat:RegisterEvent("QUEST_LOG_UPDATE", Quest, "OnEvent")
Compat:RegisterEvent("QUEST_QUERY_COMPLETE", Quest, "OnEvent")
