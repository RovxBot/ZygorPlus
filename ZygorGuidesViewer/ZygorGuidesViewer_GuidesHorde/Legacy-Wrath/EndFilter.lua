local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local state = ZGV._LegacyWrathHordeFilter
if not state then return end

ZGV.RegisterGuide = state.originalRegisterGuide
ZGV._registrationSource = state.registrationSource
ZGV._registrationPriority = state.registrationPriority
if state.installedWasNil then
	ZGV.HordeInstalled = nil
else
	ZGV.HordeInstalled = state.installed
end

local manifest = ZGV.ContentPackages and ZGV.ContentPackages["ZygorGuidesViewer_GuidesHorde"]
if manifest and manifest.legacy then
	manifest.legacy.registered = state.accepted
	manifest.legacy.filtered = state.skipped
	manifest.legacy.complete = state.accepted == manifest.legacy.expectedRegistrations
end

ZGV._LegacyWrathHordeFilter = nil
