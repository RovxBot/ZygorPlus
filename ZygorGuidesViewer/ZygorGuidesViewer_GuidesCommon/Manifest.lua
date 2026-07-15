local ZGV = ZygorGuidesViewer or ZGV
if not ZGV then return end

local manifest = {
	schema = 1,
	id = "ZygorGuidesViewer_GuidesCommon",
	kind = "common",
	interface = 30300,
	version = "0.1.0",
	priority = 200,
	trial = false,
	expectedGuideRegistrations = 105,
	source = "ZygorGuidesViewerClassicTBCAnniv/Guides-TBC/Autoload.xml + legacy 3.3.5a WotLK gear tables",
	sourceVersion = "8.1",
	imageRoot = "Interface\\AddOns\\ZygorGuidesViewer_GuidesCommon\\Images\\",
	files = {
		"Images/Images.lua",
		"Includes/General/N_General_Includes.lua",
		"Includes/General/N_Quest_Includes.lua",
		"Includes/PetsMounts/N_Mounts_Includes.lua",
		"Includes/PetsMounts/N_Pets_Includes.lua",
		"Includes/Professions/N_Professions_Includes.lua",
		"Includes/Reputations/N_Reputation_Includes.lua",
		"Includes/Titles/N_Titles_Includes.lua",
		"Dailies/ZygorDailiesCommonCLASSIC.lua",
		"Dungeons/ZygorGearCommonCLASSIC.lua",
		"Dungeons/ZygorGearCommonTBC.lua",
		"Dungeons/ZygorGearCommonWOTLK.lua",
		"Professions/ZygorProfessionsCommonCLASSIC.lua",
		"PetsMounts/ZygorPetsCommonCLASSIC.lua",
		"Reputations/ZygorReputationsCommonCLASSIC.lua",
		"Gold/ZygorFarmingCommonCLASSIC.lua",
		"Gold/ZygorGatheringCommonCLASSIC.lua",
		"Gold/ZygorGoldRunsCommonCLASSIC.lua",
	},
	assets = {
		root = "Images",
		fileCount = 143,
		textureFileCount = 142,
		loaderFileCount = 1,
		legacyGapFillers = {
			"Azuremyst.blp -> Azuremyst Isle.blp",
			"Bloodmyst.blp -> Bloodmyst Isle.blp",
			"Eversong 5-12.blp -> Eversong Woods.blp",
			"Ghostlands 12-20.blp -> Ghostlands.blp",
		},
	},
	excluded = {
		{
			path = "TalentAdvisor-Builds.lua",
			reason = "TBC talent trees are invalid on 3.3.5a; Wrath builds are supplied through the WotLK talent data path.",
		},
		{
			pattern = "*Trial.lua",
			reason = "Trial registrations duplicate or truncate the full guide catalog.",
		},
		{
			path = "Poi/Common.lua",
			reason = "The source Autoload.xml reference is commented out and is not part of the active load graph.",
		},
	},
	deduplicated = {
		"Profession Guides/Cooking/Farming Guides/Talbuk Venison (kept the longer route)",
		"Profession Guides/Cooking/Farming Guides/Raptor Ribs (kept the longer route)",
		"Profession Guides/Cooking/Farming Guides/Jaggal Clam Meat (kept the first identical registration)",
	},
	knownGaps = {
		"Classic/TBC/WotLK item, quest, route, and profession steps still require in-client 3.3.5a validation.",
		"No server price-trend dataset is bundled.",
	},
	loaded = false,
}

ZGV.ContentPackages = ZGV.ContentPackages or {}
ZGV.ContentPackages[manifest.id] = manifest
manifest.previousContentPackage = ZGV.CurrentContentPackage
ZGV.CurrentContentPackage = manifest.id

-- Guide headers resolve this path while faction companions are loaded later.
ZGV.IMAGESDIR = manifest.imageRoot
ZGV.guide_images_installed = true

if type(ZGV.RegisterContentPackage) == "function" then
	ZGV:RegisterContentPackage(manifest)
end
