local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local state = {
	previousAdvisor = rawget(_G, "ZygorTalentAdvisor"),
	registered = 0,
	filteredDebug = 0,
	missingHook = 0,
}

local proxy = {}
function proxy:RegisterBuild(class, title, ...)
	if type(title) == "string" and title:lower():find("debug", 1, true) then
		state.filteredDebug = state.filteredDebug + 1
		return
	end

	if type(ZGV.RegisterTalentBuild) == "function" then
		ZGV:RegisterTalentBuild(class, title, ...)
		state.registered = state.registered + 1
	else
		state.missingHook = state.missingHook + 1
	end
end

state.proxy = proxy
ZGV._LegacyTalentBuildRegistration = state
_G.ZygorTalentAdvisor = proxy
