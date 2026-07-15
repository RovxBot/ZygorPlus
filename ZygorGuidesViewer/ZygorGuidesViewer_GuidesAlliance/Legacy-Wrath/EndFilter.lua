local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local state = ZGV._LegacyWrathAllianceFilter
if not state then return end

ZGV.RegisterGuide = state.originalRegisterGuide
ZGV._registrationSource = state.registrationSource
ZGV._registrationPriority = state.registrationPriority
if state.installedWasNil then
	ZGV.AllianceInstalled = nil
else
	ZGV.AllianceInstalled = state.installed
end

local manifest = ZGV.ContentPackages and ZGV.ContentPackages["ZygorGuidesViewer_GuidesAlliance"]
if manifest and manifest.legacy then
	manifest.legacy.registered = state.accepted
	manifest.legacy.filtered = state.skipped
	manifest.legacy.complete = state.accepted == manifest.legacy.expectedRegistrations
end

ZGV._LegacyWrathAllianceFilter = nil
