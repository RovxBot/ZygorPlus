local ZGV = ZygorGuidesViewer or ZGV
if not ZGV or type(ZGV.RegisterGuide) ~= "function" then return end

local prefix = "Zygor's Horde Leveling Guides\\Northrend ("
local state = {
	originalRegisterGuide = ZGV.RegisterGuide,
	installedWasNil = ZGV.HordeInstalled == nil,
	installed = ZGV.HordeInstalled,
	registrationSource = ZGV._registrationSource,
	registrationPriority = ZGV._registrationPriority,
	accepted = 0,
	skipped = 0,
}

ZGV._LegacyWrathHordeFilter = state
ZGV._registrationSource = "legacy-wrath-horde-leveling"
ZGV._registrationPriority = 100
ZGV.RegisterGuide = function(self, title, ...)
	if type(title) == "string" and title:sub(1, #prefix) == prefix then
		state.accepted = state.accepted + 1
		return state.originalRegisterGuide(self, title, ...)
	end
	state.skipped = state.skipped + 1
end
