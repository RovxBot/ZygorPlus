local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Talent = Compat:CreateService("Talent")

function Talent:GetActiveGroup(is_pet)
	if type(_G.GetActiveTalentGroup) ~= "function" then return 1 end
	return tonumber(_G.GetActiveTalentGroup(false, is_pet and true or false)) or 1
end

function Talent:GetNumGroups(is_pet)
	if type(_G.GetNumTalentGroups) ~= "function" then return 1 end
	return tonumber(_G.GetNumTalentGroups(false, is_pet and true or false)) or 1
end

function Talent:GetTab(tab, is_pet, group)
	if type(_G.GetTalentTabInfo) ~= "function" then return nil end
	group = tonumber(group) or self:GetActiveGroup(is_pet)
	local name, icon, points_spent, background, preview_points = _G.GetTalentTabInfo(tab, false, is_pet and true or false, group)
	if not name then return nil end
	return {
		index = tab,
		name = name,
		iconFileID = icon,
		texture = icon,
		pointsSpent = tonumber(points_spent) or 0,
		background = background,
		previewPointsSpent = tonumber(preview_points),
		isPet = is_pet and true or false,
		group = group,
	}
end

function Talent:GetPrerequisite(tab, talent, is_pet)
	if type(_G.GetTalentPrereqs) ~= "function" then return nil end
	local prerequisite_tab, prerequisite_talent, learnable =
		_G.GetTalentPrereqs(tab, talent, false, is_pet and true or false)
	prerequisite_tab = tonumber(prerequisite_tab)
	prerequisite_talent = tonumber(prerequisite_talent)
	if not prerequisite_tab or not prerequisite_talent then return nil end
	return {
		tab = prerequisite_tab,
		index = prerequisite_talent,
		learnable = Compat.Bool(learnable),
	}
end

function Talent:GetInfo(tab, talent, is_pet, group)
	if type(_G.GetTalentInfo) ~= "function" then return nil end
	group = tonumber(group) or self:GetActiveGroup(is_pet)
	local name, icon, tier, column, rank, max_rank, exceptional, meets_prereq,
		preview_rank, meets_preview_prereq = _G.GetTalentInfo(tab, talent, false, is_pet and true or false, group)
	if not name then return nil end
	local prerequisite = self:GetPrerequisite(tab, talent, is_pet)
	return {
		tab = tab,
		index = talent,
		name = name,
		iconFileID = icon,
		texture = icon,
		tier = tonumber(tier),
		column = tonumber(column),
		rank = tonumber(rank) or 0,
		maxRank = tonumber(max_rank) or 0,
		isExceptional = Compat.Bool(exceptional),
		meetsPrerequisite = Compat.Bool(meets_prereq),
		prerequisite = prerequisite,
		prerequisiteTab = prerequisite and prerequisite.tab or nil,
		prerequisiteIndex = prerequisite and prerequisite.index or nil,
		prerequisiteLearnable = prerequisite and prerequisite.learnable,
		previewRank = tonumber(preview_rank),
		meetsPreviewPrerequisite = Compat.Bool(meets_preview_prereq),
		isPet = is_pet and true or false,
		group = group,
	}
end

function Talent:GetTrees(is_pet, group)
	local trees = {}
	local count = type(_G.GetNumTalentTabs) == "function" and tonumber(_G.GetNumTalentTabs(false, is_pet and true or false)) or (is_pet and 1 or 3)
	count = count or (is_pet and 1 or 3)
	for tab = 1, count do
		local tree = self:GetTab(tab, is_pet, group)
		if tree then
			tree.talents = {}
			local talent_count = type(_G.GetNumTalents) == "function" and tonumber(_G.GetNumTalents(tab, false, is_pet and true or false)) or 0
			for talent = 1, talent_count do
				local info = self:GetInfo(tab, talent, is_pet, group)
				if info then tree.talents[#tree.talents + 1] = info end
			end
			trees[#trees + 1] = tree
		end
	end
	return trees
end

function Talent:GetUnspentPoints(is_pet)
	-- Build 12340 exposes this for both player and pet trees; using the same
	-- API as Blizzard's preview frame keeps previewed points out of the
	-- spendable recommendation count.
	if type(_G.GetUnspentTalentPoints) == "function" then
		return tonumber(_G.GetUnspentTalentPoints(false, is_pet and true or false)) or 0
	end
	if type(_G.UnitCharacterPoints) == "function" then return tonumber(_G.UnitCharacterPoints("player")) or 0 end
	return 0
end

function Talent:Learn(tab, talent, is_pet)
	local info = self:GetInfo(tab, talent, is_pet)
	if not info then return Compat:Result(false, "unknown_talent", { tab = tab, talent = talent }) end
	if info.rank >= info.maxRank then return Compat:Result(false, "max_rank", { talentInfo = info }) end
	if not info.meetsPrerequisite then return Compat:Result(false, "prerequisite", { talentInfo = info }) end
	if type(_G.LearnTalent) ~= "function" then return Compat:Result(false, "api_unavailable", { talentInfo = info }) end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then return Compat:Result(false, "combat_lockdown", { talentInfo = info }) end
	local result = Compat.Pack(pcall(_G.LearnTalent, tab, talent, is_pet and true or false))
	return Compat:Result(result[1], result[1] and "learn_requested" or "lua_error", { talentInfo = info, error = result[2] })
end

function Talent:ActivateGroup(group)
	group = tonumber(group)
	if not group or group < 1 or group > self:GetNumGroups(false) then return Compat:Result(false, "invalid_group", { group = group }) end
	if type(_G.SetActiveTalentGroup) ~= "function" then return Compat:Result(false, "api_unavailable", { group = group }) end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then return Compat:Result(false, "combat_lockdown", { group = group }) end
	local result = Compat.Pack(pcall(_G.SetActiveTalentGroup, group))
	return Compat:Result(result[1], result[1] and "activation_requested" or "lua_error", { group = group, error = result[2] })
end

function Talent:GetGlyphs(group)
	local glyphs = {}
	if type(_G.GetNumGlyphSockets) ~= "function" or type(_G.GetGlyphSocketInfo) ~= "function" then return glyphs end
	group = tonumber(group) or self:GetActiveGroup(false)
	for socket = 1, (_G.GetNumGlyphSockets() or 0) do
		-- Build 12340 returns four values; there is no tooltip-index field in the
		-- Wrath tuple.  Tooltips can be obtained from the socket/spell separately.
		local enabled, glyph_type, glyph_spell_id, icon = _G.GetGlyphSocketInfo(socket, group)
		glyphs[#glyphs + 1] = {
			index = socket,
			enabled = Compat.Bool(enabled),
			type = glyph_type,
			spellID = tonumber(glyph_spell_id),
			iconFileID = icon,
			texture = icon,
			group = group,
		}
	end
	return glyphs
end
