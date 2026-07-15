local ZGV = ZygorGuidesViewer or ZGV
if not ZGV or type(ZGV.RegisterGuide) ~= "function" then return end

local prefix = "Zygor's Alliance Leveling Guides\\Northrend ("
local state = {
	originalRegisterGuide = ZGV.RegisterGuide,
	installedWasNil = ZGV.AllianceInstalled == nil,
	installed = ZGV.AllianceInstalled,
	registrationSource = ZGV._registrationSource,
	registrationPriority = ZGV._registrationPriority,
	accepted = 0,
	skipped = 0,
}

ZGV._LegacyWrathAllianceFilter = state
ZGV._registrationSource = "legacy-wrath-alliance-leveling"
ZGV._registrationPriority = 100
ZGV.RegisterGuide = function(self, title, ...)
	if type(title) == "string" and title:sub(1, #prefix) == prefix then
		state.accepted = state.accepted + 1
		return state.originalRegisterGuide(self, title, ...)
	end
	state.skipped = state.skipped + 1
end
