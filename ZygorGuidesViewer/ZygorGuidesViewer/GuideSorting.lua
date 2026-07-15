-- Canonical menu ordering from the Classic viewer.  Entries that do not
-- exist in the WotLK content packs are harmless; retaining them lets optional
-- shared packs keep their authored order instead of falling back to ASCII.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" or not ZGV.RegisterGuideSorting then return end

ZGV:RegisterGuideSorting({"BETA","Leveling","Loremaster","Dungeons","Gear","Dailies","Events","Reputations","Gold","Professions","Pets & Mounts","Titles","Achievements","Macros"})
ZGV:RegisterGuideSorting({"Classic Dungeons","Classic Raids","Outland Dungeons","Outland Raids","Northrend Dungeons","Northrend Raids","Cataclysm Dungeons","Cataclysm Raids","Pandaria Dungeons","Pandaria Raids","Pandaria Scenarios","Draenor Dungeons","Draenor Raids","Legion Dungeons","Legion Raids","Legion Scenarios","Battle for Azeroth Dungeons","Battle for Azeroth Raids","Shadowlands Dungeons","Shadowlands Raids"})
ZGV:RegisterGuideSorting({"Starter Guides","Classic (1-50)","The Burning Crusade (10-50)","Wrath of the Lich King (10-50)","Cataclysm (10-50)","Pandaria (10-50)","Draenor (10-50)","Legion (10-50)","Battle for Azeroth (10-50)","Shadowlands (50-60)","The Loremaster"})

if type(UnitFactionGroup)=="function" and UnitFactionGroup("player")=="Alliance" then
  ZGV:RegisterGuideSorting({"Human (1-5)","Dwarf (1-5)","Night Elf (1-11)","Gnome (1-5)","Draenei (1-5)","Worgen (1-13)","Pandaren (1-15)","Death Knight (8-10)","Demon Hunter (98-100)"})
else
  ZGV:RegisterGuideSorting({"Orc (1-5)","Undead (1-10)","Tauren (1-4)","Troll (1-5)","Blood Elf (1-5)","Goblin (1-10)","Pandaren (1-15)","Death Knight (8-10)","Demon Hunter (98-100)"})
end

-- Wrath's authored folders.  These are deliberately before generic lexical
-- order, which restores the exact Classic browsing flow for the packs built
-- for this client.
ZGV:RegisterGuideSorting({"Classic (1-60)","Outland (60-70)","Northrend (70-80)","Eastern Kingdoms","Kalimdor","Outland","Northrend","The Frozen North","Zandalar","Allied Races","Intro & Quest Zone Choice","War Campaign","The Burning of Teldrassil","The Battle for Lordaeron","Silithus: The Wound"})

-- The shipped Anniversary and legacy-Wrath packs use their literal catalog
-- names rather than the localized short labels above.  Register those names
-- as the final (therefore authoritative) sibling sequences.  Leaf guides not
-- listed here deliberately retain file registration order: the source files
-- are authored in leveling progression order, not alphabetical zone order.
ZGV:RegisterGuideSorting({
  "Leveling Guides",
  "Zygor's Alliance Leveling Guides",
  "Zygor's Horde Leveling Guides",
  "Dungeon Guides",
  "Dailies Guides",
  "Zygor's Alliance Dailies Guides",
  "Zygor's Horde Dailies Guides",
  "Events Guides",
  "Reputation Guides",
  "GOLD",
  "Profession Guides",
  "Titles",
})

ZGV:RegisterGuideSorting({
  "Starter Guides (1-11)",
  "Classic (11-60)",
  "The Burning Crusade (60-70)",
  "Class Quests",
  "Boosted Characters",
  "Ahn'Qiraj Gear",
})
