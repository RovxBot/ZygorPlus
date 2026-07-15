local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local state = ZGV._LegacyTalentBuildRegistration
if not state then return end

if state.previousAdvisor == nil then
	_G.ZygorTalentAdvisor = nil
else
	_G.ZygorTalentAdvisor = state.previousAdvisor
end

local bridge = ZGV.LegacyTalentAdvisorBridge
if bridge and bridge.builds then
	bridge.builds.registered = state.registered
	bridge.builds.filteredDebug = state.filteredDebug
	bridge.builds.missingHook = state.missingHook
	bridge.builds.complete =
		state.registered == bridge.builds.expectedReleaseRegistrations and
		state.filteredDebug == bridge.builds.expectedFilteredDebugRegistrations and
		state.missingHook == 0
end

ZGV._LegacyTalentBuildRegistration = nil
