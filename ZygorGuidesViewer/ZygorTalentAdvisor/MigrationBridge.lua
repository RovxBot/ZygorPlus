local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local legacySettings = ZygorTalentAdvisorSettings
local hookCalled = false

-- The bridge treats the old AceDB table as read-only. The core owns all field
-- mapping and writes only to its new WotLK settings database.
if type(ZGV.ImportLegacyTalentAdvisorSettings) == "function" then
	ZGV:ImportLegacyTalentAdvisorSettings(legacySettings)
	hookCalled = true
elseif type(ZGV.Migration) == "table" and type(ZGV.Migration.ImportLegacyTalentAdvisorSettings) == "function" then
	ZGV.Migration:ImportLegacyTalentAdvisorSettings(legacySettings)
	hookCalled = true
end

ZGV.LegacyTalentAdvisorBridge = {
	schema = 1,
	loaded = true,
	hasSettings = type(legacySettings) == "table" and next(legacySettings) ~= nil,
	hookCalled = hookCalled,
	loadsLegacyUI = false,
	builds = {
		source = "Zgor 3.3.5a/ZygorTalentAdvisor/Builds/ZygorGuidesBuilds.lua",
		sourceSHA256 = "55d75cc27ab9eec329e72a63b4efb3df47fc887b35efd11ca0f00dcf414aac6b",
		sourceRegistrations = 78,
		expectedReleaseRegistrations = 67,
		expectedFilteredDebugRegistrations = 11,
		registered = 0,
		filteredDebug = 0,
		missingHook = 0,
	},
}
