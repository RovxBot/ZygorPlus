local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local manifest = {
	schema = 1,
	id = "ZygorGuidesViewer_GuidesAlliance",
	kind = "faction",
	faction = "Alliance",
	interface = 30300,
	version = "0.1.0",
	priority = 200,
	trial = false,
	expectedAnniversaryGuideRegistrations = 630,
	requires = {"ZygorGuidesViewer_GuidesCommon"},
	source = "ZygorGuidesViewerClassicTBCAnniv/Guides-TBC/Autoload.xml",
	sourceVersion = "8.1",
	files = {
		"Includes/General/A_General_Includes.lua",
		"Includes/General/A_Quest_Includes.lua",
		"Includes/PetsMounts/A_Mounts_Includes.lua",
		"Includes/PetsMounts/A_Pets_Includes.lua",
		"Includes/Professions/A_Professions_Includes.lua",
		"Includes/Reputations/A_Reputation_Includes.lua",
		"Includes/Titles/A_Titles_Includes.lua",
		"Leveling/ZygorLevelingAllianceCLASSIC.lua",
		"Dailies/ZygorDailiesAllianceCLASSIC.lua",
		"Dungeons/ZygorDungeonAllianceCLASSIC.lua",
		"Dungeons/ZygorGearAllianceCLASSIC.lua",
		"Professions/ZygorProfessionsAllianceCLASSIC.lua",
		"PetsMounts/ZygorHunterPetAllianceCLASSIC.lua",
		"PetsMounts/ZygorMountsAllianceCLASSIC.lua",
		"PetsMounts/ZygorPetsAllianceCLASSIC.lua",
		"Titles/ZygorTitlesAllianceCLASSIC.lua",
		"Reputations/ZygorReputationsAllianceCLASSIC.lua",
		"Events/ZygorEventsAllianceCLASSIC.lua",
		"Gold/ZygorFarmingAllianceCLASSIC.lua",
		"Gold/ZygorGatheringAllianceCLASSIC.lua",
		"Gold/ZygorGoldRunsAllianceCLASSIC.lua",
	},
	legacy = {
		source = "Zgor 3.3.5a/ZygorGuidesViewer/Guides/ZygorGuidesAlliance.lua",
		sourceSHA256 = "eed559a2e3399db9d53ab2a66257ca429344277596b00e898f908b9fc42acef5",
		file = "Legacy-Wrath/ZygorLevelingAllianceWOTLK.lua",
		filterPrefix = "Zygor's Alliance Leveling Guides\\Northrend (",
		expectedRegistrations = 5,
		priority = 100,
	},
	legacyDailies = {
		source = "Zgor 3.3.5a/ZygorGuidesViewer/Guides/ZygorDailiesAlliance.lua",
		sourceSHA256 = "d0e99c074f2b163530b1b13f831ecd3d77b3e08e53c5ebf7399187e137072399",
		file = "Legacy-Wrath/ZygorDailiesAllianceWOTLK.lua",
		filterPrefix = "Zygor's Alliance Dailies Guides\\",
		categories = {
			"Borean Tundra", "Dalaran", "Dragonblight", "Grizzly Hills", "Howling Fjord",
			"Icecrown", "Sholazar Basin", "The Storm Peaks", "Zul'Drak", "Speed Gold Runs", "Reputation",
		},
		expectedRegistrations = 69,
		expectedFilteredRegistrations = 31,
		priority = 100,
	},
	rewrites = {
		"One modern item-count guide expression now uses ZGV.Compat.Item:GetCount.",
		"The anniversary level-70 endpoint now continues into the legacy Alliance Northrend guide chain.",
	},
	deduplicated = {
		"GOLD/Farming/Lesser Nether Essence",
		"GOLD/Farming/Greater Nether Essence",
		"Profession Guides/Enchanting/Farming Guides/Lesser Nether Essence",
		"Profession Guides/Enchanting/Farming Guides/Greater Nether Essence",
	},
	excluded = {
		{pattern = "*Trial.lua", reason = "Full guides take precedence over duplicate trial registrations."},
		{reason = "Legacy pre-70 leveling is excluded because anniversary full guides take precedence."},
		{reason = "Mixed-generation legacy Cata/MoP and unreachable guide files are excluded."},
	},
	knownGaps = {
		"The five legacy 70-80 guides retain the legacy dotted DSL and require the dual-DSL parser.",
		"The legacy Wrath dailies retain the legacy dotted DSL and require in-client quest/event validation.",
		"No safe legacy Wrath dungeon corpus was present in the active old load graph.",
	},
	loaded = false,
}

ZGV.ContentPackages = ZGV.ContentPackages or {}
ZGV.ContentPackages[manifest.id] = manifest
manifest.previousContentPackage = ZGV.CurrentContentPackage
ZGV.CurrentContentPackage = manifest.id

if type(ZGV.RegisterContentPackage) == "function" then
	ZGV:RegisterContentPackage(manifest)
end
