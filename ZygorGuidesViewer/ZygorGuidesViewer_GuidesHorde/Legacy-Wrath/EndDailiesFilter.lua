local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local state = ZGV._LegacyWrathHordeDailiesFilter
if not state then return end

ZGV.RegisterGuide = state.originalRegisterGuide
ZGV._registrationSource = state.registrationSource
ZGV._registrationPriority = state.registrationPriority
if state.installedWasNil then
	ZGV.HordeDailiesInstalled = nil
else
	ZGV.HordeDailiesInstalled = state.installed
end

local manifest = ZGV.ContentPackages and ZGV.ContentPackages["ZygorGuidesViewer_GuidesHorde"]
if manifest and manifest.legacyDailies then
	manifest.legacyDailies.registered = state.accepted
	manifest.legacyDailies.filtered = state.skipped
	manifest.legacyDailies.complete =
		state.accepted == manifest.legacyDailies.expectedRegistrations and
		state.skipped == manifest.legacyDailies.expectedFilteredRegistrations
end

ZGV._LegacyWrathHordeDailiesFilter = nil
