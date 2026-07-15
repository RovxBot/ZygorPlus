local ZGV = ZygorGuidesViewer or ZGV
if not ZGV or not ZGV.ContentPackages then return end

local manifest = ZGV.ContentPackages["ZygorGuidesViewer_GuidesCommon"]
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
manifest.registrationComplete = manifest.registeredGuideCount == manifest.expectedGuideRegistrations

if type(ZGV.ContentPackageLoaded) == "function" then
	ZGV:ContentPackageLoaded(manifest)
end

ZGV.CurrentContentPackage = manifest.previousContentPackage
manifest.previousContentPackage = nil
