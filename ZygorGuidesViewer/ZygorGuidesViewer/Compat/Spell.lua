local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Spell = Compat:CreateService("Spell")

function Spell:GetInfo(spell)
	if type(_G.GetSpellInfo) ~= "function" then return { spellID = tonumber(spell), ready = false, reason = "api_unavailable" } end
	-- Build 12340 uses the pre-6.0 nine-value signature.
	local name, rank, icon, power_cost, is_funnel, power_type, cast_time, min_range, max_range = _G.GetSpellInfo(spell)
	return {
		spellID = tonumber(spell),
		id = tonumber(spell),
		name = name,
		rank = rank,
		iconFileID = icon,
		texture = icon,
		powerCost = tonumber(power_cost) or 0,
		isFunnel = Compat.Bool(is_funnel),
		powerType = power_type,
		castTime = tonumber(cast_time) or 0,
		minRange = tonumber(min_range),
		maxRange = tonumber(max_range),
		ready = name ~= nil,
		reason = name and nil or "not_cached",
	}
end

function Spell:GetCooldown(spell)
	if type(_G.GetSpellCooldown) ~= "function" then
		return { spellID = tonumber(spell), available = false, startTime = 0, duration = 0, enabled = false }
	end
	local start_time, duration, enabled = _G.GetSpellCooldown(spell)
	return {
		spellID = tonumber(spell),
		available = true,
		startTime = tonumber(start_time) or 0,
		duration = tonumber(duration) or 0,
		enabled = Compat.Bool(enabled),
		endsAt = (tonumber(start_time) or 0) + (tonumber(duration) or 0),
	}
end

function Spell:IsUsable(spell)
	if type(_G.IsUsableSpell) ~= "function" then return { spellID = tonumber(spell), usable = false, noMana = false, available = false } end
	local usable, no_mana = _G.IsUsableSpell(spell)
	return { spellID = tonumber(spell), usable = Compat.Bool(usable), noMana = Compat.Bool(no_mana), available = true }
end

function Spell:GetBook()
	local spells = {}
	if type(_G.GetNumSpellTabs) ~= "function" or type(_G.GetSpellTabInfo) ~= "function" or type(_G.GetSpellName) ~= "function" then
		return spells
	end
	local book_type = _G.BOOKTYPE_SPELL or "spell"
	for tab = 1, (_G.GetNumSpellTabs() or 0) do
		local tab_name, tab_texture, offset, count = _G.GetSpellTabInfo(tab)
		for slot = (offset or 0) + 1, (offset or 0) + (count or 0) do
			local name, rank = _G.GetSpellName(slot, book_type)
			if name then
				spells[#spells + 1] = {
					tab = tab,
					tabName = tab_name,
					tabTexture = tab_texture,
					slot = slot,
					name = name,
					rank = rank,
				}
			end
		end
	end
	return spells
end

function Spell:IsKnown(spell)
	if type(_G.IsSpellKnown) == "function" and tonumber(spell) then
		return { spellID = tonumber(spell), known = Compat.Bool(_G.IsSpellKnown(tonumber(spell))), available = true }
	end
	local requested = self:GetInfo(spell)
	for _, known in ipairs(self:GetBook()) do
		if known.name == requested.name and (not requested.rank or requested.rank == "" or known.rank == requested.rank) then
			return { spellID = requested.spellID, known = true, available = true, bookEntry = known }
		end
	end
	return { spellID = requested.spellID, known = false, available = requested.ready }
end

function Spell:Pickup(spell)
	if type(_G.PickupSpell) ~= "function" then return Compat:Result(false, "api_unavailable", { spellID = tonumber(spell) }) end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then return Compat:Result(false, "combat_lockdown", { spellID = tonumber(spell) }) end
	local result = Compat.Pack(pcall(_G.PickupSpell, spell))
	return Compat:Result(result[1], result[1] and "picked_up" or "lua_error", { spellID = tonumber(spell), error = result[2] })
end
