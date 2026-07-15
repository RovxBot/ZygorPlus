local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Profession = Compat:CreateService("Profession")

Profession.recipeCache = Profession.recipeCache or {}
Profession.recipeByProduct = Profession.recipeByProduct or {}

local profession_skills = {
	{ skillLine = 171, spellID = 2259, category = "primary" }, -- Alchemy
	{ skillLine = 164, spellID = 2018, category = "primary" }, -- Blacksmithing
	{ skillLine = 773, spellID = 45357, category = "primary" }, -- Inscription
	{ skillLine = 755, spellID = 25229, category = "primary" }, -- Jewelcrafting
	{ skillLine = 165, spellID = 2108, category = "primary" }, -- Leatherworking
	{ skillLine = 197, spellID = 3908, category = "primary" }, -- Tailoring
	{ skillLine = 333, spellID = 7411, category = "primary" }, -- Enchanting
	{ skillLine = 202, spellID = 4036, category = "primary" }, -- Engineering
	{ skillLine = 182, spellID = 13614, category = "primary" }, -- Herbalism
	{ skillLine = 186, spellID = 2575, category = "primary" }, -- Mining
	{ skillLine = 393, spellID = 8613, category = "primary" }, -- Skinning
	{ skillLine = 185, spellID = 2550, category = "cooking" },
	{ skillLine = 129, spellID = 3273, category = "firstAid" },
	{ skillLine = 356, spellID = 7620, category = "fishing" },
}

local function get_skill_descriptors()
	local by_name = {}
	for _, descriptor in ipairs(profession_skills) do
		local name, _, icon
		if type(_G.GetSpellInfo) == "function" then name, _, icon = _G.GetSpellInfo(descriptor.spellID) end
		if name then
			descriptor.localizedName = name
			descriptor.icon = icon
			by_name[name] = descriptor
		end
	end
	return by_name
end

local function get_legacy_skill_lines()
	local professions = {}
	if type(_G.GetSkillLineInfo) ~= "function" then return professions end
	local descriptors = get_skill_descriptors()
	local count = type(_G.GetNumSkillLines) == "function" and tonumber(_G.GetNumSkillLines()) or 128
	for index = 1, (count or 128) do
		local name, is_header, _, rank, temporary, modifier, maximum, is_abandonable = _G.GetSkillLineInfo(index)
		local descriptor = name and descriptors[name]
		if descriptor and not Compat.Bool(is_header) then
			professions[#professions + 1] = {
				index = index,
				name = name,
				iconFileID = descriptor.icon,
				texture = descriptor.icon,
				skillLevel = tonumber(rank) or 0,
				maxSkillLevel = tonumber(maximum) or 0,
				temporaryBonus = tonumber(temporary) or 0,
				skillModifier = tonumber(modifier) or 0,
				isAbandonable = Compat.Bool(is_abandonable),
				skillLine = descriptor.skillLine,
				category = descriptor.category,
				source = "skill_lines",
			}
		end
	end
	return professions
end

function Profession:GetInfo(index)
	if not index then return nil end
	if type(_G.GetProfessionInfo) ~= "function" then
		for _, profession in ipairs(get_legacy_skill_lines()) do if profession.index == index then return profession end end
		return nil
	end
	local name, icon, skill_level, max_skill_level, ability_count, spell_offset, skill_line = _G.GetProfessionInfo(index)
	if not name then return nil end
	return {
		index = index,
		name = name,
		iconFileID = icon,
		texture = icon,
		skillLevel = tonumber(skill_level) or 0,
		maxSkillLevel = tonumber(max_skill_level) or 0,
		abilityCount = tonumber(ability_count) or 0,
		spellOffset = tonumber(spell_offset) or 0,
		skillLine = tonumber(skill_line),
	}
end

function Profession:GetAll()
	local professions = {}
	if type(_G.GetProfessions) ~= "function" or type(_G.GetProfessionInfo) ~= "function" then return get_legacy_skill_lines() end
	local primary1, primary2, archaeology, fishing, cooking, first_aid = _G.GetProfessions()
	local indices = {
		{ index = primary1, category = "primary" },
		{ index = primary2, category = "primary" },
		{ index = archaeology, category = "archaeology" },
		{ index = fishing, category = "fishing" },
		{ index = cooking, category = "cooking" },
		{ index = first_aid, category = "firstAid" },
	}
	for _, descriptor in ipairs(indices) do
		local info = self:GetInfo(descriptor.index)
		if info then
			info.category = descriptor.category
			professions[#professions + 1] = info
		end
	end
	return professions
end

function Profession:Find(name_or_skill_line)
	local numeric = tonumber(name_or_skill_line)
	local wanted = type(name_or_skill_line) == "string" and string.lower(name_or_skill_line) or nil
	for _, profession in ipairs(self:GetAll()) do
		if (numeric and profession.skillLine == numeric) or profession.name == name_or_skill_line
			or (wanted and type(profession.name) == "string" and string.lower(profession.name) == wanted) then
			return profession
		end
	end
	return nil
end

function Profession:GetSkill(name_or_skill_line)
	local profession = self:Find(name_or_skill_line)
	if not profession then return { name = name_or_skill_line, rank = 0, max = 0, skillLevel = 0, maxSkillLevel = 0, known = false } end
	profession.rank = profession.skillLevel
	profession.max = profession.maxSkillLevel
	profession.known = true
	return profession
end

function Profession:GetTradeSkillLine()
	if type(_G.GetTradeSkillLine) ~= "function" then return { open = false, reason = "api_unavailable" } end
	local name, current, maximum = _G.GetTradeSkillLine()
	return {
		open = name ~= nil and name ~= "UNKNOWN",
		name = name,
		skillLevel = tonumber(current) or 0,
		maxSkillLevel = tonumber(maximum) or 0,
	}
end

function Profession:GetRecipes()
	local recipes = {}
	if type(_G.GetNumTradeSkills) ~= "function" or type(_G.GetTradeSkillInfo) ~= "function" then return recipes end
	for index = 1, (_G.GetNumTradeSkills() or 0) do
		local name, difficulty, available, expanded = _G.GetTradeSkillInfo(index)
		local link = type(_G.GetTradeSkillRecipeLink) == "function" and _G.GetTradeSkillRecipeLink(index) or nil
		local item_link = type(_G.GetTradeSkillItemLink) == "function" and _G.GetTradeSkillItemLink(index) or nil
		local recipe_spell = type(link) == "string" and tonumber(link:match("|H[%a]+:(%d+)")) or nil
		local product_id = type(item_link) == "string" and tonumber(item_link:match("|Hitem:(%d+)")) or nil
		local minimum, maximum
		if difficulty ~= "header" and type(_G.GetTradeSkillNumMade) == "function" then
			minimum, maximum = _G.GetTradeSkillNumMade(index)
		end
		local recipe = {
			index = index,
			name = name,
			difficulty = difficulty,
			numAvailable = tonumber(available),
			isExpanded = Compat.Bool(expanded),
			isHeader = difficulty == "header",
			recipeLink = link,
			itemLink = item_link,
			spellID = recipe_spell,
			productID = product_id,
			numMade = { tonumber(minimum) or 1, tonumber(maximum) or tonumber(minimum) or 1 },
			reagents = {},
		}
		if not recipe.isHeader and type(_G.GetTradeSkillNumReagents) == "function" then
			for reagent_index = 1, (tonumber(_G.GetTradeSkillNumReagents(index)) or 0) do
				local reagent_name, reagent_texture, required, owned = _G.GetTradeSkillReagentInfo(index, reagent_index)
				local reagent_link = type(_G.GetTradeSkillReagentItemLink) == "function" and _G.GetTradeSkillReagentItemLink(index, reagent_index) or nil
				recipe.reagents[#recipe.reagents + 1] = {
					name = reagent_name,
					texture = reagent_texture,
					required = tonumber(required) or 0,
					owned = tonumber(owned) or 0,
					link = reagent_link,
					itemID = type(reagent_link) == "string" and tonumber(reagent_link:match("|Hitem:(%d+)")) or nil,
				}
			end
		end
		recipes[#recipes + 1] = recipe
	end
	return recipes
end

function Profession:RefreshRecipes()
	local by_spell, by_product = {}, {}
	for _, recipe in ipairs(self:GetRecipes()) do
		if recipe.spellID then by_spell[recipe.spellID] = recipe end
		if recipe.productID then by_product[recipe.productID] = recipe end
	end
	self.recipeCache, self.recipeByProduct = by_spell, by_product
	return by_spell
end

function Profession:FindRecipe(identifier)
	local numeric = tonumber(identifier)
	local wanted = type(identifier) == "string" and string.lower(identifier) or nil
	if not next(self.recipeCache) then self:RefreshRecipes() end
	if numeric and self.recipeCache[numeric] then return self.recipeCache[numeric] end
	if numeric and self.recipeByProduct[numeric] then return self.recipeByProduct[numeric] end
	for _, recipe in pairs(self.recipeCache) do
		if wanted and type(recipe.name) == "string" and string.lower(recipe.name) == wanted then return recipe end
	end
	return nil
end

function Profession:Craft(identifier, count)
	local line = self:GetTradeSkillLine()
	if not line.open then return Compat:Result(false, line.reason or "trade_skill_closed") end
	local recipe = self:FindRecipe(identifier)
	if not recipe or recipe.isHeader then return Compat:Result(false, "recipe_missing") end
	if type(_G.DoTradeSkill) ~= "function" then return Compat:Result(false, "api_unavailable", { recipe = recipe }) end
	count = math.max(1, math.floor(tonumber(count) or 1))
	local ok, error_message = pcall(_G.DoTradeSkill, recipe.index, count)
	return Compat:Result(ok, ok and "craft_requested" or "lua_error", { recipe = recipe, count = count, error = error_message })
end

function Profession:OnEvent(event)
	if event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE" then self:RefreshRecipes()
	elseif event == "TRADE_SKILL_CLOSE" then self.recipeCache, self.recipeByProduct = {}, {} end
end

Compat:RegisterEvent("TRADE_SKILL_SHOW", Profession, "OnEvent")
Compat:RegisterEvent("TRADE_SKILL_UPDATE", Profession, "OnEvent")
Compat:RegisterEvent("TRADE_SKILL_CLOSE", Profession, "OnEvent")

-- Legacy public facade retained for profession guide conditions and older
-- Gold/Goal callers.  The Anniversary payload shipped static Classic/TBC
-- recipes and trainer ranks; live build-12340 APIs include Inscription,
-- Death Knight-era training, and every Wrath recipe actually known by the
-- current character.
local Legacy = ZGV.Professions or {}
ZGV.Professions = Legacy
Legacy.tradeskills = Legacy.tradeskills or {
	[129] = { name = "First Aid", crafting = true, skill = 129 },
	[164] = { name = "Blacksmithing", crafting = true, skill = 164 },
	[165] = { name = "Leatherworking", crafting = true, skill = 165 },
	[171] = { name = "Alchemy", crafting = true, skill = 171 },
	[182] = { name = "Herbalism", skill = 182 },
	[185] = { name = "Cooking", crafting = true, skill = 185 },
	[186] = { name = "Mining", crafting = true, skill = 186 },
	[197] = { name = "Tailoring", crafting = true, skill = 197 },
	[202] = { name = "Engineering", crafting = true, skill = 202 },
	[333] = { name = "Enchanting", crafting = true, skill = 333 },
	[356] = { name = "Fishing", skill = 356 },
	[393] = { name = "Skinning", skill = 393 },
	[755] = { name = "Jewelcrafting", crafting = true, skill = 755 },
	[773] = { name = "Inscription", crafting = true, skill = 773 },
}
function Legacy:GetSkill(name_or_skill_line) return Profession:GetSkill(name_or_skill_line) end
function Legacy:GetRecipe(identifier) return Profession:FindRecipe(identifier) end
function Legacy:KnowsRecipe(identifier)
	local numeric = tonumber(identifier)
	if numeric and type(_G.IsSpellKnown) == "function" and _G.IsSpellKnown(numeric) then return true end
	return Profession:FindRecipe(identifier) ~= nil
end
function Legacy:HasProfessionSlot()
	local count = 0
	for _, info in ipairs(Profession:GetAll()) do if info.category == "primary" then count = count + 1 end end
	return count < 2
end
function Legacy:HasProfessionUnscanned(name) return Profession:Find(name) ~= nil and not next(Profession.recipeCache) end

function ZGV:CacheSkills() return Profession:GetAll() end
function ZGV:CacheRecipes() return Profession:RefreshRecipes() end
function ZGV:FindTradeSkillNum(identifier)
	local recipe = Profession:FindRecipe(identifier)
	return recipe and recipe.index or nil
end
function ZGV:PerformTradeSkill(identifier, count) return Profession:Craft(identifier, count) end
function ZGV:PerformTradeSkillGoal(goal)
	if not goal then return Compat:Result(false, "goal_missing") end
	local identifier = goal.spellID or goal.spellid or goal.targetID or goal.targetid
	local count = goal.skillnum or goal.count or 1
	if goal.targetID or goal.targetid then
		local item_id = goal.targetID or goal.targetid
		local owned = type(_G.GetItemCount) == "function" and (_G.GetItemCount(item_id) or 0) or 0
		count = math.max(0, (tonumber(count) or 1) - owned)
	end
	if count <= 0 then return Compat:Result(true, "already_complete") end
	return Profession:Craft(identifier, count)
end
