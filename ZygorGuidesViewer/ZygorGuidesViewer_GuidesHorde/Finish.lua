local ZGV = ZygorGuidesViewer or ZGV
if not ZGV or not ZGV.ContentPackages then return end

local manifest = ZGV.ContentPackages["ZygorGuidesViewer_GuidesHorde"]
if not manifest then return end

manifest.loaded = true
manifest.loadedAt = type(GetTime) == "function" and GetTime() or 0
manifest.registeredGuideCount = 0
if ZGV.Catalog and type(ZGV.Catalog.guides) == "table" then
	for _, guide in ipairs(ZGV.Catalog.guides) do
		if guide.package == manifest.id then
			manifest.registeredGuideCount = manifest.registeredGuideCount + 1
		end
	end
end
manifest.expectedGuideRegistrations =
	manifest.expectedAnniversaryGuideRegistrations +
	manifest.legacy.expectedRegistrations +
	manifest.legacyDailies.expectedRegistrations
manifest.registrationComplete =
	manifest.registeredGuideCount == manifest.expectedGuideRegistrations and
	manifest.legacy.complete and manifest.legacyDailies.complete

if type(ZGV.ContentPackageLoaded) == "function" then
	ZGV:ContentPackageLoaded(manifest)
end

ZGV.CurrentContentPackage = manifest.previousContentPackage
manifest.previousContentPackage = nil
