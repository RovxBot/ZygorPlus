local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local manifest = {
	schema = 1,
	id = "ZygorGuidesViewer_GuidesHorde",
	kind = "faction",
	faction = "Horde",
	interface = 30300,
	version = "0.1.0",
	priority = 200,
	trial = false,
	expectedAnniversaryGuideRegistrations = 607,
	requires = {"ZygorGuidesViewer_GuidesCommon"},
	source = "ZygorGuidesViewerClassicTBCAnniv/Guides-TBC/Autoload.xml",
	sourceVersion = "8.1",
	files = {
		"Includes/General/H_General_Includes.lua",
		"Includes/General/H_Quest_Includes.lua",
		"Includes/PetsMounts/H_Mounts_Includes.lua",
		"Includes/PetsMounts/H_Pets_Includes.lua",
		"Includes/Professions/H_Professions_Includes.lua",
		"Includes/Reputations/H_Reputation_Includes.lua",
		"Includes/Titles/H_Titles_Includes.lua",
		"Leveling/ZygorLevelingHordeCLASSIC.lua",
		"Dailies/ZygorDailiesHordeCLASSIC.lua",
		"Dungeons/ZygorDungeonHordeCLASSIC.lua",
		"Dungeons/ZygorDungeonScenariosHordeCLASSIC.lua",
		"Dungeons/ZygorGearHordeCLASSIC.lua",
		"Professions/ZygorProfessionsHordeCLASSIC.lua",
		"PetsMounts/ZygorHunterPetHordeCLASSIC.lua",
		"PetsMounts/ZygorMountsHordeCLASSIC.lua",
		"PetsMounts/ZygorPetsHordeCLASSIC.lua",
		"Titles/ZygorTitlesHordeCLASSIC.lua",
		"Reputations/ZygorReputationsHordeCLASSIC.lua",
		"Events/ZygorEventsHordeCLASSIC.lua",
		"Gold/ZygorFarmingHordeCLASSIC.lua",
		"Gold/ZygorGatheringHordeCLASSIC.lua",
		"Gold/ZygorGoldRunsHordeCLASSIC.lua",
	},
	legacy = {
		source = "Zgor 3.3.5a/ZygorGuidesViewer/Guides/ZygorGuidesHorde.lua",
		sourceSHA256 = "96a5f50c05e904bf64129be737e2e218287d1806ffbfced81cc50ecf4e30296b",
		file = "Legacy-Wrath/ZygorLevelingHordeWOTLK.lua",
		filterPrefix = "Zygor's Horde Leveling Guides\\Northrend (",
		expectedRegistrations = 5,
		priority = 100,
	},
	legacyDailies = {
		source = "Zgor 3.3.5a/ZygorGuidesViewer/Guides/ZygorDailiesHorde.lua",
		sourceSHA256 = "e97d3a5c1de489220b063b125b5b897f1d437d383f2d53369ea8b22f529d606e",
		file = "Legacy-Wrath/ZygorDailiesHordeWOTLK.lua",
		packagedSHA256 = "ae846358bd468ac1c684c47112f4b13cba5eecfe19d1172ba956068fa75ac1d0",
		filterPrefix = "Zygor's Horde Dailies Guides\\",
		categories = {
			"Borean Tundra", "Dalaran", "Dragonblight", "Grizzly Hills", "Howling Fjord",
			"Icecrown", "Sholazar Basin", "The Storm Peaks", "Zul'Drak", "Speed Gold Runs", "Reputation",
		},
		expectedRegistrations = 63,
		expectedFilteredRegistrations = 28,
		priority = 100,
	},
	rewrites = {
		"Seven modern item-count guide expressions now use ZGV.Compat.Item:GetCount.",
		"The anniversary level-70 endpoint now continues into the legacy Horde Northrend guide chain.",
	},
	deduplicated = {
		"Legacy Events/Zalazane's Fall Pre-Cataclysm Event (kept the first registration; the category remains filtered from release)",
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
		"The active anniversary Horde scenarios module is an empty registration stub; no scenario UI is exposed.",
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
