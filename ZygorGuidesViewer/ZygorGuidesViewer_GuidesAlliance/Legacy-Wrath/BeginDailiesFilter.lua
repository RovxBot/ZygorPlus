local ZGV = ZygorGuidesViewer or ZGV
if not ZGV or type(ZGV.RegisterGuide) ~= "function" then return end

local prefix = "Zygor's Alliance Dailies Guides\\"
local categories = {
	["Borean Tundra"] = true,
	["Dalaran"] = true,
	["Dragonblight"] = true,
	["Grizzly Hills"] = true,
	["Howling Fjord"] = true,
	["Icecrown"] = true,
	["Sholazar Basin"] = true,
	["The Storm Peaks"] = true,
	["Zul'Drak"] = true,
	["Speed Gold Runs"] = true,
	["Reputation"] = true,
}
local state = {
	originalRegisterGuide = ZGV.RegisterGuide,
	installedWasNil = ZGV.AllianceDailiesInstalled == nil,
	installed = ZGV.AllianceDailiesInstalled,
	registrationSource = ZGV._registrationSource,
	registrationPriority = ZGV._registrationPriority,
	accepted = 0,
	skipped = 0,
}

ZGV._LegacyWrathAllianceDailiesFilter = state
ZGV._registrationSource = "legacy-wrath-alliance-dailies"
ZGV._registrationPriority = 100
ZGV.RegisterGuide = function(self, title, ...)
	local category
	if type(title) == "string" and title:sub(1, #prefix) == prefix then
		category = title:sub(#prefix + 1):match("^([^\\]+)")
	end
	if category and categories[category] then
		state.accepted = state.accepted + 1
		return state.originalRegisterGuide(self, title, ...)
	end
	state.skipped = state.skipped + 1
end
