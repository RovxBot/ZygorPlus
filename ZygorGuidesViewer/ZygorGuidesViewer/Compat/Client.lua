local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Client = Compat:CreateService("Client")

local function safe_call(func, ...)
	if type(func) ~= "function" then return nil end
	local result = Compat.Pack(pcall(func, ...))
	if not result[1] then return nil end
	return Compat.Unpack(result, 2)
end

function Client:GetBuild()
	local version, build_string, build_date, interface = safe_call(_G.GetBuildInfo)
	local build = tonumber(build_string)
	interface = tonumber(interface)
	local locale = safe_call(_G.GetLocale) or "enUS"
	return {
		version = version,
		buildString = build_string,
		build = build,
		date = build_date,
		interface = interface,
		locale = locale,
		expansion = 2,
		project = "WOTLK",
		isWotLK = interface == Compat.TARGET_INTERFACE,
		isTargetBuild = interface == Compat.TARGET_INTERFACE and build == Compat.TARGET_BUILD,
		supported = interface == Compat.TARGET_INTERFACE,
	}
end

function Client:IsSupported()
	local build = self:GetBuild()
	return build.supported, build
end

function Client:GetPlayer()
	local name, realm
	if type(_G.UnitName) == "function" then name, realm = _G.UnitName("player") end
	if not realm or realm == "" then realm = safe_call(_G.GetRealmName) end
	local localized_class, class = safe_call(_G.UnitClass, "player")
	local localized_race, race = safe_call(_G.UnitRace, "player")
	local faction = safe_call(_G.UnitFactionGroup, "player")
	return {
		name = name,
		realm = realm,
		fullName = name and realm and (name .. "-" .. realm) or name,
		className = localized_class,
		class = class,
		raceName = localized_race,
		race = race,
		faction = faction,
		level = safe_call(_G.UnitLevel, "player") or 0,
		guid = safe_call(_G.UnitGUID, "player"),
	}
end

function Client:GetCapabilities()
	return {
		completedQuestQuery = type(_G.QueryQuestsCompleted) == "function" and type(_G.GetQuestsCompleted) == "function",
		areaMapIDs = type(_G.GetCurrentMapAreaID) == "function" and type(_G.SetMapByID) == "function",
		addonPrefixRegistration = type(_G.RegisterAddonMessagePrefix) == "function",
		dualSpec = type(_G.GetNumTalentGroups) == "function" and type(_G.SetActiveTalentGroup) == "function",
		glyphs = type(_G.GetGlyphSocketInfo) == "function",
		auctionHouse = type(_G.QueryAuctionItems) == "function",
		itemStats = type(_G.GetItemStats) == "function",
		astrolabe = type(_G.Astrolabe) == "table",
	}
end

function Client:GetAddonInfo(addon)
	if type(_G.GetAddOnInfo) ~= "function" then
		return { name = addon, available = false, reason = "api_unavailable" }
	end
	local name, title, notes, enabled, loadable, reason, security = _G.GetAddOnInfo(addon)
	return {
		name = name or addon,
		title = title,
		notes = notes,
		enabled = Compat.Bool(enabled),
		loadable = Compat.Bool(loadable),
		reason = reason,
		security = security,
		available = name ~= nil,
	}
end

function Client:GetAddonMetadata(addon, field)
	return safe_call(_G.GetAddOnMetadata, addon, field)
end

function Client:LoadAddon(addon)
	if type(_G.LoadAddOn) ~= "function" then
		return Compat:Result(false, "api_unavailable", { addon = addon })
	end
	local result = Compat.Pack(pcall(_G.LoadAddOn, addon))
	if not result[1] then
		return Compat:Result(false, "lua_error", { addon = addon, error = result[2] })
	end
	local loaded, reason = result[2], result[3]
	return Compat:Result(loaded == true or loaded == 1, loaded and "loaded" or (reason or "load_failed"), {
		addon = addon,
		reason = reason,
	})
end

