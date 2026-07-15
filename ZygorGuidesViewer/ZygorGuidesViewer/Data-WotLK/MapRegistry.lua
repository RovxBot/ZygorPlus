-- Canonical map keys are the only map identifiers persisted by this port.
-- anniversary.uiMapID identifies the source guide coordinate space. legacy
-- identifies the build-12340 map selected by SetMapZoom; Astrolabe provides
-- the checked-in world-dimension transform for those mapFile values.
local ZGV = ZygorGuidesViewer

local maps = {}
local function map(name, uiMapID, continent, mapFile, instance, floor)
  local key = name .. "/" .. tostring(floor or 0)
  maps[key] = {
    key=key, name=name, floor=floor or 0,
    anniversary={ uiMapID=uiMapID },
    legacy={ continent=continent, mapFile=mapFile, instanceID=instance, transform="Astrolabe-0.4-Zygor" },
  }
end

map("Azeroth",947,0,"Azeroth")
map("Eastern Kingdoms",1415,2,"Azeroth")
map("Kalimdor",1414,1,"Kalimdor")
map("Outland",1945,3,"Expansion01")
map("Northrend",113,4,"Northrend")

map("Alterac Mountains",1416,2,"Alterac")
map("Arathi Highlands",1417,2,"ArathiHighlands")
map("Badlands",1418,2,"Badlands")
map("Blasted Lands",1419,2,"BlastedLands")
map("Burning Steppes",1428,2,"BurningSteppes")
map("Deadwind Pass",1430,2,"DeadwindPass")
map("Dun Morogh",1426,2,"DunMorogh")
map("Duskwood",1431,2,"Duskwood")
map("Eastern Plaguelands",1423,2,"EasternPlaguelands")
map("Elwynn Forest",1429,2,"Elwynn")
map("Eversong Woods",1941,2,"EversongWoods")
map("Ghostlands",1942,2,"Ghostlands")
map("Hillsbrad Foothills",1424,2,"Hilsbrad")
map("Ironforge",1455,2,"Ironforge")
map("Isle of Quel'Danas",1957,2,"Sunwell")
map("Loch Modan",1432,2,"LochModan")
map("Redridge Mountains",1433,2,"Redridge")
map("Searing Gorge",1427,2,"SearingGorge")
map("Silvermoon City",1954,2,"SilvermoonCity")
map("Silverpine Forest",1421,2,"Silverpine")
map("Stormwind City",1453,2,"Stormwind")
map("Stranglethorn Vale",1434,2,"Stranglethorn")
map("Swamp of Sorrows",1435,2,"SwampOfSorrows")
map("The Hinterlands",1425,2,"Hinterlands")
map("Tirisfal Glades",1420,2,"Tirisfal")
map("Undercity",1458,2,"Undercity")
map("Western Plaguelands",1422,2,"WesternPlaguelands")
map("Westfall",1436,2,"Westfall")
map("Wetlands",1437,2,"Wetlands")

map("Ashenvale",1440,1,"Ashenvale")
map("Azshara",1447,1,"Aszhara")
map("Azuremyst Isle",1943,1,"AzuremystIsle")
map("Bloodmyst Isle",1950,1,"BloodmystIsle")
map("Darkshore",1439,1,"Darkshore")
map("Darnassus",1457,1,"Darnassis")
map("Desolace",1443,1,"Desolace")
map("Durotar",1411,1,"Durotar")
map("Dustwallow Marsh",1445,1,"Dustwallow")
map("Felwood",1448,1,"Felwood")
map("Feralas",1444,1,"Feralas")
map("Moonglade",1450,1,"Moonglade")
map("Mulgore",1412,1,"Mulgore")
map("Orgrimmar",1454,1,"Ogrimmar")
map("Silithus",1451,1,"Silithus")
map("Stonetalon Mountains",1442,1,"StonetalonMountains")
map("Tanaris",1446,1,"Tanaris")
map("Teldrassil",1438,1,"Teldrassil")
map("The Barrens",1413,1,"Barrens")
map("The Exodar",1947,1,"Exodar")
map("Thousand Needles",1441,1,"ThousandNeedles")
map("Thunder Bluff",1456,1,"ThunderBluff")
map("Un'Goro Crater",1449,1,"UngoroCrater")
map("Winterspring",1452,1,"Winterspring")

map("Blade's Edge Mountains",1949,3,"BladesEdgeMountains")
map("Hellfire Peninsula",1944,3,"Hellfire")
map("Nagrand",1951,3,"Nagrand")
map("Netherstorm",1953,3,"Netherstorm")
map("Shadowmoon Valley",1948,3,"ShadowmoonValley")
map("Shattrath City",1955,3,"ShattrathCity")
map("Terokkar Forest",1952,3,"TerokkarForest")
map("Zangarmarsh",1946,3,"Zangarmarsh")

map("Borean Tundra",114,4,"BoreanTundra")
map("Crystalsong Forest",127,4,"CrystalsongForest")
map("Dalaran",125,4,"Dalaran")
map("Dalaran",126,4,"Dalaran",nil,1)
map("Dragonblight",115,4,"Dragonblight")
map("Grizzly Hills",116,4,"GrizzlyHills")
map("Hrothgar's Landing",170,4,"HrothgarsLanding")
map("Howling Fjord",117,4,"HowlingFjord")
map("Icecrown",118,4,"IcecrownGlacier")
map("Sholazar Basin",119,4,"SholazarBasin")
map("The Storm Peaks",120,4,"TheStormPeaks")
map("Wintergrasp",123,4,"LakeWintergrasp")
map("Zul'Drak",121,4,"ZulDrak")

-- Instance keys use unique port IDs; the anniversary source contained a fake
-- ID collision between Onyxia and Ragefire Chasm. Instance IDs remain the
-- build-12340 GetInstanceInfo identifiers.
local instances = {
  {"Ragefire Chasm",99001,389},{"The Deadmines",99002,36},{"Wailing Caverns",99003,43},
  {"Shadowfang Keep",99004,33},{"Blackfathom Deeps",99005,48},{"The Stockade",99006,34},
  {"Gnomeregan",99007,90},{"Razorfen Kraul",99008,47},{"Scarlet Monastery",99009,189},
  {"Razorfen Downs",99010,129},{"Uldaman",99011,70},{"Zul'Farrak",99012,209},
  {"Maraudon",99013,349},{"The Temple of Atal'Hakkar",99014,109},{"Blackrock Depths",99015,230},
  {"Blackrock Spire",99016,229},{"Dire Maul",99017,429},{"Stratholme",99018,329},
  {"Scholomance",99019,289},{"Molten Core",99020,409},{"Onyxia's Lair",99021,249},
  {"Hellfire Ramparts",99022,543},{"The Blood Furnace",99023,542},{"The Shattered Halls",99024,540},
  {"The Slave Pens",99025,547},{"The Underbog",99026,546},{"The Steamvault",99027,545},
  {"Mana-Tombs",99028,557},{"Auchenai Crypts",99029,558},{"Sethekk Halls",99030,556},
  {"Shadow Labyrinth",99031,555},{"Old Hillsbrad Foothills",99032,560},{"The Black Morass",99033,269},
  {"The Mechanar",99034,554},{"The Botanica",99035,553},{"The Arcatraz",99036,552},
  {"Magisters' Terrace",99037,585},{"Utgarde Keep",99038,574},{"The Nexus",99039,576},
  {"Azjol-Nerub",99040,601},{"Ahn'kahet: The Old Kingdom",99041,619},{"Drak'Tharon Keep",99042,600},
  {"The Violet Hold",99043,608},{"Gundrak",99044,604},{"Halls of Stone",99045,599},
  {"Halls of Lightning",99046,602},{"The Oculus",99047,578},{"Utgarde Pinnacle",99048,575},
  {"The Culling of Stratholme",99049,595},{"Trial of the Champion",99050,650},
  {"The Forge of Souls",99051,632},{"Pit of Saron",99052,658},{"Halls of Reflection",99053,668},
  {"Naxxramas",99054,533},{"The Obsidian Sanctum",99055,615},{"The Eye of Eternity",99056,616},
  {"Ulduar",99057,603},{"Trial of the Crusader",99058,649},{"Icecrown Citadel",99059,631},
  {"The Ruby Sanctum",99060,724},
}
for i=1,#instances do
  local row=instances[i]
  map(row[1],row[2],0,row[1]:gsub("[^%w]",""),row[3])
end

ZGV.Data:Register("maps", 1, maps, {
  source="Anniversary LibRover map IDs plus build-12340 Astrolabe and instance metadata",
  transform="Libs/Astrolabe/Astrolabe.lua revision 106",
})

ZGV.MapRegistry = maps
function ZGV:CanonicalMapKey(name, floor)
  if type(name)=="number" then
    for key,record in pairs(maps) do
      if record.anniversary.uiMapID==name then return key end
    end
    return tostring(name).."/"..tostring(floor or 0)
  end
  name = tostring(name or ""):gsub("^%s+",""):gsub("%s+$","")
  local explicitName,explicitFloor = name:match("^(.-)/(%d+)$")
  if explicitName then name,floor=explicitName,tonumber(explicitFloor) end
  local key=name.."/"..tostring(floor or 0)
  if maps[key] then return key end
  return key
end
