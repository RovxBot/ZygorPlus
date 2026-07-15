local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if UnitFactionGroup("player")~="Alliance" then return end
if ZGV:DoMutex("DailiesACLASSIC") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 1, Capturing Sanctum)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 1.\n\n"..
"Phase 1 occurs until you recover Sun's Reach Sanctum.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept The Sanctum Wards##11496 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip He walknside the building.
accept Erratic Behavior##11524 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11524/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11524) or completedq(11524)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11496
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11496) or completedq(11496)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11496/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11496) or completedq(11496)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin The Sanctum Wards##11496 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11496) or completedq(11496)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Erratic Behavior##11524 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11524) or completedq(11524)
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11496,11524,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 2, Capturing Armory, Activating Portal)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 2 while activating the portal.\n\n"..
"Phase 2 occurs until you recover Sun's Reach Armory.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle for the Sun's Reach Armory##11538 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept Distraction at the Dead Scar##11532 |goto Isle of Quel'Danas/0 47.52,35.07
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11538/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11538) or completedq(11538)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11538/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11538) or completedq(11538)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11532
|only if haveq(11532) or completedq(11532)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11532/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11532) or completedq(11532)) |next "Get_On_Taxi" |or
|only if haveq(11532) or completedq(11532)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11532/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11532) or completedq(11532)) |next "Get_On_Taxi" |or
|only if haveq(11532) or completedq(11532)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11532/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11532) or completedq(11532)) |next "Get_On_Taxi" |or
|only if haveq(11532) or completedq(11532)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11532
|only if haveq(11532) or completedq(11532)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle for the Sun's Reach Armory##11538 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11538) or completedq(11538)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin Distraction at the Dead Scar##11532 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11532) or completedq(11532)
step
talk Exarch Nasuun##24932
accept Intercepting the Mana Cells##11513 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11513
|only if haveq(11513) or completedq(11513)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11513
|only if haveq(11513) or completedq(11513)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11513/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11513) or completedq(11513)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Intercepting the Mana Cells##11513 |goto Shattrath City/0 49.10,42.48
|only if haveq(11513) or completedq(11513)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11538,11532,11513,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 2, Capturing Armory, Portal Activated)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 2 after the portal is activated.\n\n"..
"Phase 2 occurs until you recover Sun's Reach Armory.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle for the Sun's Reach Armory##11538 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept Distraction at the Dead Scar##11532 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11538/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11538) or completedq(11538)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11538/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11538) or completedq(11538)
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11532
|only if haveq(11532) or completedq(11532)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11532/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11532) or completedq(11532)) |next "Get_On_Taxi" |or
|only if haveq(11532) or completedq(11532)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11532/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11532) or completedq(11532)) |next "Get_On_Taxi" |or
|only if haveq(11532) or completedq(11532)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11532/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11532) or completedq(11532)) |next "Get_On_Taxi" |or
|only if haveq(11532) or completedq(11532)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11532
|only if haveq(11532) or completedq(11532)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle for the Sun's Reach Armory##11538 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11538) or completedq(11538)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin Distraction at the Dead Scar##11532 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11532) or completedq(11532)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11538,11532,11547,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 3, Recovering Harbor, Rebuilding Forge)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 3 while rebuilding the Forge.\n\n"..
"Phase 3 occurs until you recover Sun's Reach Harbor.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
accept Intercept the Reinforcements##11542 |goto Isle of Quel'Danas/0 50.58,39.00
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
accept Taking the Harbor##11539 |goto Isle of Quel'Danas/0 49.33,40.38
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
accept Make Ready##11535 |goto Isle of Quel'Danas/0 50.58,40.77
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11537/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11537) or completedq(11537)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11537/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11537) or completedq(11537)
stickystart "Kill_6_Dawnblade_Summoners"
stickystart "Kill_6_Dawnblade_Blood_Knights"
stickystart "Kill_3_Dawnblade_Marksman"
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
label "Kill_6_Dawnblade_Summoners"
kill 6 Dawnblade Summoner##24978 |q 11539/1 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11539) or completedq(11539)
step
label "Kill_6_Dawnblade_Blood_Knights"
kill 6 Dawnblade Blood Knight##24976 |q 11539/2 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11539) or completedq(11539)
step
label "Kill_3_Dawnblade_Marksman"
kill 3 Dawnblade Marksman##24979 |q 11539/3 |goto Isle of Quel'Danas/0 43.40,38.57
You can find more around: |notinsticky
[Isle of Quel'Danas/0 39.17,40.26]
[Isle of Quel'Danas/0 46.64,40.03]
|only if haveq(11539) or completedq(11539)
stickystart "Collect_3_Darkspine_Ore"
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Collect_3_Darkspine_Ore"
Kill Darkspine enemies around this area
collect 3 Darkspine Iron Ore##34479 |q 11535/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11535) or completedq(11535)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11533
|only if haveq(11533) or completedq(11533)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11533/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11533/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11533/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11533
|only if haveq(11533) or completedq(11533)
step
talk Ayren Cloudbreaker##25059
Select _"I need to intercept the Dawnblade reinforcements."_
Take a Flight to the Dawnblade Fleet |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11542
|only if haveq(11542) or completedq(11542)
stickystart "Burn_the_Bloodoath_Sails"
stickystart "Burn_the_Dawnchaser_Sails"
step
use the Flaming Oil##34489
|tip Drop the oil on the ship's sails.
Burn the Sin'loren's Sails |q 11542/1 |goto Isle of Quel'Danas/0 52.55,14.99
|only if haveq(11542) or completedq(11542)
step
label "Burn_the_Bloodoath_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Bloodoath's Sails |q 11542/2 |goto Isle of Quel'Danas/0 50.59,10.04
|only if haveq(11542) or completedq(11542)
step
label "Burn_the_Dawnchaser_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Dawnchaser's Sails |q 11542/3 |goto Isle of Quel'Danas/0 55.48,12.12
|only if haveq(11542) or completedq(11542)
step
kill 6 Dawnblade Reservist##25087 |q 11542/4 |goto Isle of Quel'Danas/0 52.55,14.99
|tip Swim out to any of the three ships and run up the ramp on the side.
|only if haveq(11542) or completedq(11542)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11537) or completedq(11537)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11533) or completedq(11533)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
turnin Intercept the Reinforcements##11542 |goto Isle of Quel'Danas/0 50.58,39.00
|only if haveq(11542) or completedq(11542)
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
turnin Taking the Harbor##11539 |goto Isle of Quel'Danas/0 49.33,40.38
|only if haveq(11539) or completedq(11539)
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
turnin Make Ready##11535 |goto Isle of Quel'Danas/0 50.58,40.77
|only if haveq(11535) or completedq(11535)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11537,11533,11547,11542,11539,11535,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 3, Recovering Harbor, Forge Rebuilt)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 3 after rebuilding the Forge.\n\n"..
"Phase 3 occurs until you recover Sun's Reach Harbor.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
accept Intercept the Reinforcements##11542 |goto Isle of Quel'Danas/0 50.58,39.00
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
accept Taking the Harbor##11539 |goto Isle of Quel'Danas/0 49.33,40.38
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
accept Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77
accept Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11537/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11537) or completedq(11537)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11537/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11537) or completedq(11537)
stickystart "Kill_6_Dawnblade_Summoners"
stickystart "Kill_6_Dawnblade_Blood_Knights"
stickystart "Kill_3_Dawnblade_Marksman"
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
label "Kill_6_Dawnblade_Summoners"
kill 6 Dawnblade Summoner##24978 |q 11539/1 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11539) or completedq(11539)
step
label "Kill_6_Dawnblade_Blood_Knights"
kill 6 Dawnblade Blood Knight##24976 |q 11539/2 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11539) or completedq(11539)
step
label "Kill_3_Dawnblade_Marksman"
kill 3 Dawnblade Marksman##24979 |q 11539/3 |goto Isle of Quel'Danas/0 43.40,38.57
You can find more around: |notinsticky
[Isle of Quel'Danas/0 39.17,40.26]
[Isle of Quel'Danas/0 46.64,40.03]
|only if haveq(11539) or completedq(11539)
stickystart "Collect_3_Darkspine_Ore"
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Collect_3_Darkspine_Ore"
Kill Darkspine enemies around this area
collect 3 Darkspine Iron Ore##34479 |q 11536/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11536) or completedq(11536)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11533
|only if haveq(11533) or completedq(11533)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11533/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11533/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11533/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11533
|only if haveq(11533) or completedq(11533)
step
talk Ayren Cloudbreaker##25059
Select _"I need to intercept the Dawnblade reinforcements."_
Take a Flight to the Dawnblade Fleet |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11542
|only if haveq(11542) or completedq(11542)
stickystart "Burn_the_Bloodoath_Sails"
stickystart "Burn_the_Dawnchaser_Sails"
step
use the Flaming Oil##34489
|tip Drop the oil on the ship's sails.
Burn the Sin'loren's Sails |q 11542/1 |goto Isle of Quel'Danas/0 52.55,14.99
|only if haveq(11542) or completedq(11542)
step
label "Burn_the_Bloodoath_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Bloodoath's Sails |q 11542/2 |goto Isle of Quel'Danas/0 50.59,10.04
|only if haveq(11542) or completedq(11542)
step
label "Burn_the_Dawnchaser_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Dawnchaser's Sails |q 11542/3 |goto Isle of Quel'Danas/0 55.48,12.12
|only if haveq(11542) or completedq(11542)
step
kill 6 Dawnblade Reservist##25087 |q 11542/4 |goto Isle of Quel'Danas/0 52.55,14.99
|tip Swim out to any of the three ships and run up the ramp on the side.
|only if haveq(11542) or completedq(11542)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11537) or completedq(11537)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11533) or completedq(11533)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
turnin Intercept the Reinforcements##11542 |goto Isle of Quel'Danas/0 50.58,39.00
|only if haveq(11542) or completedq(11542)
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
turnin Taking the Harbor##11539 |goto Isle of Quel'Danas/0 49.33,40.38
|only if haveq(11539) or completedq(11539)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
Kill Shadowmoon enemies around this area
collect 5 Ata'mal Armament##34500 |goto Shadowmoon Valley/0 68.74,37.35 |q 11544
|only if haveq(11544) or completedq(11544)
step
use the Ata'mal Armament##34500
collect 5 Cleansed Ata'mal Metal##34501 |q 11544/1 |goto Isle of Quel'Danas/0 50.63,40.74
|only if haveq(11544) or completedq(11544)
step
talk Smith Hauthaa##25046
turnin Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11536) or completedq(11536)
turnin Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11544) or completedq(11544)
|only if haveq(11536,11544) or completedq(11536,11544)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11537,11533,11547,11542,11539,11536,11544,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 4, No Alchemy Lab or Monument)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 4 before building the Alchemy Lab or Monument.\n\n"..
"Phase 4 occurs after recovering the major portions of Sun's Reach.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
step
talk Anchorite Ayuri##25112
accept A Charitable Donation##11545 |goto Isle of Quel'Danas/0 49.12,37.61 |or
|tip This quest requires you to donate ten gold in exchange for 150 Shattered Sun Offensive reputation.
|tip
Click Here to Skip It |confirm |or
step
talk Anchorite Ayuri##25112
turnin A Charitable Donation##11545 |goto Isle of Quel'Danas/0 49.12,37.61
|only if readyq(11545)
stickystart "Collect_10_Gold"
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
accept Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
accept Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
accept Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77
accept Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11537/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11537) or completedq(11537)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11537/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11537) or completedq(11537)
stickystart "Kill_6_Dawnblade_Summoners"
stickystart "Kill_6_Dawnblade_Blood_Knights"
stickystart "Kill_3_Dawnblade_Marksman"
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
label "Kill_6_Dawnblade_Summoners"
kill 6 Dawnblade Summoner##24978 |q 11540/1 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_6_Dawnblade_Blood_Knights"
kill 6 Dawnblade Blood Knight##24976 |q 11540/2 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_3_Dawnblade_Marksman"
kill 3 Dawnblade Marksman##24979 |q 11540/3 |goto Isle of Quel'Danas/0 43.40,38.57
You can find more around: |notinsticky
[Isle of Quel'Danas/0 39.17,40.26]
[Isle of Quel'Danas/0 46.64,40.03]
|only if haveq(11540) or completedq(11540)
step
talk Mar'nah##24975
|tip Inside the building.
accept Rediscovering Your Roots##11520 |goto Isle of Quel'Danas/0 51.49,32.46
step
talk Captain Valindria##25088
accept Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
stickystart "Free_10_Greengill_Slaves"
stickystart "Collect_3_Darkspine_Ore"
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Free_10_Greengill_Slaves"
Kill Darkspine enemies around this area
collect Orb of Murloc Control##34483 |n
use Orb of Murloc Control##34483
|tip Throw the orb on groups of murlocs around this area.
Free #10# Greengill Slaves |q 11541/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11541) or completedq(11541)
step
label "Collect_3_Darkspine_Ore"
Kill Darkspine enemies around this area
collect 3 Darkspine Iron Ore##34479 |q 11536/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11536) or completedq(11536)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11533
|only if haveq(11533) or completedq(11533)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11533/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11533/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11533/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11533
|only if haveq(11533) or completedq(11533)
step
talk Ayren Cloudbreaker##25059
Select _"I need to intercept the Dawnblade reinforcements."_
Take a Flight to the Dawnblade Fleet |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11543
|only if haveq(11543) or completedq(11543)
stickystart "Burn_the_Bloodoath_Sails"
stickystart "Burn_the_Dawnchaser_Sails"
step
use the Flaming Oil##34489
|tip Drop the oil on the ship's sails.
Burn the Sin'loren's Sails |q 11543/1 |goto Isle of Quel'Danas/0 52.55,14.99
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Bloodoath_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Bloodoath's Sails |q 11543/2 |goto Isle of Quel'Danas/0 50.59,10.04
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Dawnchaser_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Dawnchaser's Sails |q 11543/3 |goto Isle of Quel'Danas/0 55.48,12.12
|only if haveq(11543) or completedq(11543)
step
kill 6 Dawnblade Reservist##25087 |q 11543/4 |goto Isle of Quel'Danas/0 52.55,14.99
|tip Swim out to any of the three ships and run up the ramp on the side.
|only if haveq(11543) or completedq(11543)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11537) or completedq(11537)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11533) or completedq(11533)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
turnin Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
|only if haveq(11543) or completedq(11543)
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
turnin Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
|only if haveq(11540) or completedq(11540)
step
talk Captain Valindria##25088
turnin Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
|only if haveq(11541) or completedq(11541)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
kill Razorthorn Flayer##24920+
collect Razorthorn Flayer Gland##34255 |goto Terokkar Forest/0 58.21,12.97 |q 11520
|only if haveq(11520) or completedq(11520)
step
use the Razorthorn Flayer Gland##34255
|tip Use it on Razorthorn Ravager.
|tip Once it is charmed, take it near dirt mounds and use the "Expose Razorthorn Root" ability on your pet bar.
click Razorthorn Root##187072+
|tip They appear after being exposed by a Razorthorn Ravager.
collect 5 Razorthorn Root##34254 |q 11520/1 |goto Terokkar Forest/0 58.21,12.97
|only if haveq(11520) or completedq(11520)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
Kill Shadowmoon enemies around this area
collect 5 Ata'mal Armament##34500 |goto Shadowmoon Valley/0 68.74,37.35 |q 11544
|only if haveq(11544) or completedq(11544)
step
use the Ata'mal Armament##34500
collect 5 Cleansed Ata'mal Metal##34501 |q 11544/1 |goto Isle of Quel'Danas/0 50.63,40.74
|only if haveq(11544) or completedq(11544)
step
talk Smith Hauthaa##25046
turnin Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11536) or completedq(11536)
turnin Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11544) or completedq(11544)
|only if haveq(11536,11544) or completedq(11536,11544)
step
talk Mar'nah##24975
|tip Inside the building.
turnin Rediscovering Your Roots##11520 |goto Isle of Quel'Danas/0 51.49,32.46
|only if haveq(11520) or completedq(11520)
step
label "Collect_10_Gold"
Collect 10 Gold |q 11545/1
|only if haveq(11545) or completedq(11545)
step
talk Anchorite Ayuri##25112
turnin A Charitable Donation##11545 |goto Isle of Quel'Danas/0 49.12,37.61
|only if haveq(11545) or completedq(11545)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11537,11533,11547,11545,11543,11540,11536,11544,11520,11541,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 4, Alchemy Lab Built)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 4 after building the Alchemy Lab but before building the Monument.\n\n"..
"Phase 4 occurs after recovering the major portions of Sun's Reach.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
step
talk Mar'nah##24975
|tip Inside the building.
accept Rediscovering Your Roots##11521 |goto Isle of Quel'Danas/0 51.49,32.46
accept Open for Business##11546 |goto Isle of Quel'Danas/0 51.49,32.46
stickystart "Collect_5_Bloodberries"
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_5_Bloodberries"
Kill Wretched enemies around this area
collect 5 Bloodberry##34502 |q 11546/1 |goto Isle of Quel'Danas/0 45.00,27.92
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11546) or completedq(11546)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
step
talk Anchorite Ayuri##25112
accept A Charitable Donation##11545 |goto Isle of Quel'Danas/0 49.12,37.61 |or
|tip This quest requires you to donate ten gold in exchange for 150 Shattered Sun Offensive reputation.
|tip
Click Here to Skip It |confirm |or
step
talk Anchorite Ayuri##25112
turnin A Charitable Donation##11545 |goto Isle of Quel'Danas/0 49.12,37.61
|only if readyq(11545)
stickystart "Collect_10_Gold"
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
accept Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
accept Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
accept Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77
accept Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11537/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11537) or completedq(11537)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11537/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11537) or completedq(11537)
stickystart "Kill_6_Dawnblade_Summoners"
stickystart "Kill_6_Dawnblade_Blood_Knights"
stickystart "Kill_3_Dawnblade_Marksman"
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
label "Kill_6_Dawnblade_Summoners"
kill 6 Dawnblade Summoner##24978 |q 11540/1 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_6_Dawnblade_Blood_Knights"
kill 6 Dawnblade Blood Knight##24976 |q 11540/2 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_3_Dawnblade_Marksman"
kill 3 Dawnblade Marksman##24979 |q 11540/3 |goto Isle of Quel'Danas/0 43.40,38.57
You can find more around: |notinsticky
[Isle of Quel'Danas/0 39.17,40.26]
[Isle of Quel'Danas/0 46.64,40.03]
|only if haveq(11540) or completedq(11540)
step
talk Captain Valindria##25088
accept Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
stickystart "Free_10_Greengill_Slaves"
stickystart "Collect_3_Darkspine_Ore"
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Free_10_Greengill_Slaves"
Kill Darkspine enemies around this area
collect Orb of Murloc Control##34483 |n
use Orb of Murloc Control##34483
|tip Throw the orb on groups of murlocs around this area.
Free #10# Greengill Slaves |q 11541/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11541) or completedq(11541)
step
label "Collect_3_Darkspine_Ore"
Kill Darkspine enemies around this area
collect 3 Darkspine Iron Ore##34479 |q 11536/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11536) or completedq(11536)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11533
|only if haveq(11533) or completedq(11533)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11533/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11533/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11533/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11533
|only if haveq(11533) or completedq(11533)
step
talk Ayren Cloudbreaker##25059
Select _"I need to intercept the Dawnblade reinforcements."_
Take a Flight to the Dawnblade Fleet |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11543
|only if haveq(11543) or completedq(11543)
stickystart "Burn_the_Bloodoath_Sails"
stickystart "Burn_the_Dawnchaser_Sails"
step
use the Flaming Oil##34489
|tip Drop the oil on the ship's sails.
Burn the Sin'loren's Sails |q 11543/1 |goto Isle of Quel'Danas/0 52.55,14.99
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Bloodoath_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Bloodoath's Sails |q 11543/2 |goto Isle of Quel'Danas/0 50.59,10.04
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Dawnchaser_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Dawnchaser's Sails |q 11543/3 |goto Isle of Quel'Danas/0 55.48,12.12
|only if haveq(11543) or completedq(11543)
step
kill 6 Dawnblade Reservist##25087 |q 11543/4 |goto Isle of Quel'Danas/0 52.55,14.99
|tip Swim out to any of the three ships and run up the ramp on the side.
|only if haveq(11543) or completedq(11543)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11537) or completedq(11537)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11533) or completedq(11533)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
turnin Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
|only if haveq(11543) or completedq(11543)
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
turnin Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
|only if haveq(11540) or completedq(11540)
step
talk Captain Valindria##25088
turnin Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
|only if haveq(11541) or completedq(11541)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
kill Razorthorn Flayer##24920+
collect Razorthorn Flayer Gland##34255 |goto Terokkar Forest/0 58.21,12.97 |q 11521
|only if haveq(11521) or completedq(11521)
step
use the Razorthorn Flayer Gland##34255
|tip Use it on Razorthorn Ravager.
|tip Once it is charmed, take it near dirt mounds and use the "Expose Razorthorn Root" ability on your pet bar.
click Razorthorn Root##187072+
|tip They appear after being exposed by a Razorthorn Ravager.
collect 5 Razorthorn Root##34254 |q 11521/1 |goto Terokkar Forest/0 58.21,12.97
|only if haveq(11521) or completedq(11521)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
Kill Shadowmoon enemies around this area
collect 5 Ata'mal Armament##34500 |goto Shadowmoon Valley/0 68.74,37.35 |q 11544
|only if haveq(11544) or completedq(11544)
step
use the Ata'mal Armament##34500
collect 5 Cleansed Ata'mal Metal##34501 |q 11544/1 |goto Isle of Quel'Danas/0 50.63,40.74
|only if haveq(11544) or completedq(11544)
step
talk Smith Hauthaa##25046
turnin Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11536) or completedq(11536)
turnin Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11544) or completedq(11544)
|only if haveq(11536,11544) or completedq(11536,11544)
step
talk Mar'nah##24975
|tip Inside the building.
turnin Rediscovering Your Roots##11521 |goto Isle of Quel'Danas/0 51.49,32.46 |only if haveq(11521) or completedq(11521)
turnin Open for Business##11546 |goto Isle of Quel'Danas/0 51.49,32.46 |only if haveq(11546) or completedq(11546)
|only if haveq(11521,11546) or completedq(11521,11546)
step
label "Collect_10_Gold"
Collect 10 Gold |q 11545/1
|only if haveq(11545) or completedq(11545)
step
talk Anchorite Ayuri##25112
turnin A Charitable Donation##11545 |goto Isle of Quel'Danas/0 49.12,37.61
|only if haveq(11545) or completedq(11545)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11521,11546,11537,11533,11547,11545,11543,11540,11536,11544,11541,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 4, Monument Built)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 4 after building the Monument but before building the Alchemy Lab.\n\n"..
"Phase 4 occurs after recovering the major portions of Sun's Reach.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
step
talk Anchorite Ayuri##25112
accept Your Continued Support##11548 |goto Isle of Quel'Danas/0 49.12,37.61 |or
|tip This quest requires you to donate ten gold in exchange for 150 Shattered Sun Offensive reputation.
|tip
Click Here to Skip It |confirm |or
step
talk Anchorite Ayuri##25112
turnin Your Continued Support##11548 |goto Isle of Quel'Danas/0 49.12,37.61
|only if readyq(11548)
stickystart "Collect_10_Gold"
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
accept Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
accept Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
accept Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77
accept Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11537/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11537) or completedq(11537)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11537/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11537) or completedq(11537)
stickystart "Kill_6_Dawnblade_Summoners"
stickystart "Kill_6_Dawnblade_Blood_Knights"
stickystart "Kill_3_Dawnblade_Marksman"
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
label "Kill_6_Dawnblade_Summoners"
kill 6 Dawnblade Summoner##24978 |q 11540/1 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_6_Dawnblade_Blood_Knights"
kill 6 Dawnblade Blood Knight##24976 |q 11540/2 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_3_Dawnblade_Marksman"
kill 3 Dawnblade Marksman##24979 |q 11540/3 |goto Isle of Quel'Danas/0 43.40,38.57
You can find more around: |notinsticky
[Isle of Quel'Danas/0 39.17,40.26]
[Isle of Quel'Danas/0 46.64,40.03]
|only if haveq(11540) or completedq(11540)
step
talk Mar'nah##24975
|tip Inside the building.
accept Rediscovering Your Roots##11520 |goto Isle of Quel'Danas/0 51.49,32.46
step
talk Captain Valindria##25088
accept Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
stickystart "Free_10_Greengill_Slaves"
stickystart "Collect_3_Darkspine_Ore"
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Free_10_Greengill_Slaves"
Kill Darkspine enemies around this area
collect Orb of Murloc Control##34483 |n
use Orb of Murloc Control##34483
|tip Throw the orb on groups of murlocs around this area.
Free #10# Greengill Slaves |q 11541/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11541) or completedq(11541)
step
label "Collect_3_Darkspine_Ore"
Kill Darkspine enemies around this area
collect 3 Darkspine Iron Ore##34479 |q 11536/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11536) or completedq(11536)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11533
|only if haveq(11533) or completedq(11533)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11533/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11533/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11533/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11533
|only if haveq(11533) or completedq(11533)
step
talk Ayren Cloudbreaker##25059
Select _"I need to intercept the Dawnblade reinforcements."_
Take a Flight to the Dawnblade Fleet |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11543
|only if haveq(11543) or completedq(11543)
stickystart "Burn_the_Bloodoath_Sails"
stickystart "Burn_the_Dawnchaser_Sails"
step
use the Flaming Oil##34489
|tip Drop the oil on the ship's sails.
Burn the Sin'loren's Sails |q 11543/1 |goto Isle of Quel'Danas/0 52.55,14.99
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Bloodoath_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Bloodoath's Sails |q 11543/2 |goto Isle of Quel'Danas/0 50.59,10.04
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Dawnchaser_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Dawnchaser's Sails |q 11543/3 |goto Isle of Quel'Danas/0 55.48,12.12
|only if haveq(11543) or completedq(11543)
step
kill 6 Dawnblade Reservist##25087 |q 11543/4 |goto Isle of Quel'Danas/0 52.55,14.99
|tip Swim out to any of the three ships and run up the ramp on the side.
|only if haveq(11543) or completedq(11543)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11537) or completedq(11537)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11533) or completedq(11533)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
turnin Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
|only if haveq(11543) or completedq(11543)
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
turnin Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
|only if haveq(11540) or completedq(11540)
step
talk Captain Valindria##25088
turnin Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
|only if haveq(11541) or completedq(11541)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
kill Razorthorn Flayer##24920+
collect Razorthorn Flayer Gland##34255 |goto Terokkar Forest/0 58.21,12.97 |q 11520
|only if haveq(11520) or completedq(11520)
step
use the Razorthorn Flayer Gland##34255
|tip Use it on Razorthorn Ravager.
|tip Once it is charmed, take it near dirt mounds and use the "Expose Razorthorn Root" ability on your pet bar.
click Razorthorn Root##187072+
|tip They appear after being exposed by a Razorthorn Ravager.
collect 5 Razorthorn Root##34254 |q 11520/1 |goto Terokkar Forest/0 58.21,12.97
|only if haveq(11520) or completedq(11520)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
Kill Shadowmoon enemies around this area
collect 5 Ata'mal Armament##34500 |goto Shadowmoon Valley/0 68.74,37.35 |q 11544
|only if haveq(11544) or completedq(11544)
step
use the Ata'mal Armament##34500
collect 5 Cleansed Ata'mal Metal##34501 |q 11544/1 |goto Isle of Quel'Danas/0 50.63,40.74
|only if haveq(11544) or completedq(11544)
step
talk Smith Hauthaa##25046
turnin Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11536) or completedq(11536)
turnin Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11544) or completedq(11544)
|only if haveq(11536,11544) or completedq(11536,11544)
step
talk Mar'nah##24975
|tip Inside the building.
turnin Rediscovering Your Roots##11520 |goto Isle of Quel'Danas/0 51.49,32.46
|only if haveq(11520) or completedq(11520)
step
label "Collect_10_Gold"
Collect 10 Gold |q 11548/1
|only if haveq(11548) or completedq(11548)
step
talk Anchorite Ayuri##25112
turnin Your Continued Support##11548 |goto Isle of Quel'Danas/0 49.12,37.61
|only if haveq(11548) or completedq(11548)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11537,11533,11547,11548,11543,11540,11536,11544,11520,11541,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattered Sun Offensive\\Shattered Sun Dailies (Phase 4, Fully Built)", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through the Shattered Sun Offensive daily quests during phase 4 after building the Alchemy Lab and Monument.\n\n"..
"Phase 4 occurs after recovering the major portions of Sun's Reach.",
startlevel=70,
},[[
leechsteps "Leveling Guides\\The Burning Crusade (60-70)\\Isle of Quel'danas" 1-10
step
label "Begin_Daily_Quests"
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
accept Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
step
talk Vindicator Xayann##24965
|tip Inside the building.
accept Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
step
talk Mar'nah##24975
|tip Inside the building.
accept Rediscovering Your Roots##11521 |goto Isle of Quel'Danas/0 51.49,32.46
accept Open for Business##11546 |goto Isle of Quel'Danas/0 51.49,32.46
stickystart "Collect_5_Bloodberries"
stickystart "Collect_4_Mana_Remnants"
step
kill Erratic Sentry##24972+
use the Attuned Crystal Cores##34368
|tip Use them on defeated Erratic Sentries.
Deploy #5# Converted Sentries |q 11525/1 |goto Isle of Quel'Danas/0 41.59,28.00
You can find more around:
[Isle of Quel'Danas/0 37.19,26.88]
[Isle of Quel'Danas/0 35.72,33.23]
|only if haveq(11525) or completedq(11525)
step
label "Collect_5_Bloodberries"
Kill Wretched enemies around this area
collect 5 Bloodberry##34502 |q 11546/1 |goto Isle of Quel'Danas/0 45.00,27.92
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11546) or completedq(11546)
step
label "Collect_4_Mana_Remnants"
Kill Wretched enemies around this area
collect 4 Mana Remnants##34338 |goto Isle of Quel'Danas/0 45.00,27.92 |q 11523
You can find more around: |notinsticky
[Isle of Quel'Danas/0 41.00,28.24]
[Isle of Quel'Danas/0 38.18,33.33]
|only if haveq(11523) or completedq(11523)
step
use the Mana Remnants##34338
Energize a Crystal Ward |q 11523/1 |goto Isle of Quel'Danas/0 46.52,35.31
|only if haveq(11523) or completedq(11523)
step
Enter the building |goto Isle of Quel'Danas/0 47.14,30.05 < 7 |walk
talk Captain Theris Dawnhearth##24967
|tip Inside the building.
turnin Arm the Wards!##11523 |goto Isle of Quel'Danas/0 47.45,30.48
|only if haveq(11523) or completedq(11523)
step
talk Vindicator Xayann##24965
|tip Inside the building.
turnin Further Conversions##11525 |goto Isle of Quel'Danas/0 47.12,30.68
|only if haveq(11525) or completedq(11525)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
accept The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
step
talk Battlemage Arynna##25057
|tip Inside the building.
accept The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
step
talk Astromancer Darnarian##25133
|tip Inside the building.
accept Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
step
talk Anchorite Ayuri##25112
accept Your Continued Support##11548 |goto Isle of Quel'Danas/0 49.12,37.61 |or
|tip This quest requires you to donate ten gold in exchange for 150 Shattered Sun Offensive reputation.
|tip
Click Here to Skip It |confirm |or
step
talk Anchorite Ayuri##25112
turnin Your Continued Support##11548 |goto Isle of Quel'Danas/0 49.12,37.61
|only if readyq(11548)
stickystart "Collect_10_Gold"
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
accept Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
accept Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
step
Jump down here |goto Isle of Quel'Danas/0 50.57,41.21 < 10 |only if walking
talk Smith Hauthaa##25046
accept Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77
accept Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77
stickystart "Slay_6_Burning_Legion_Demons"
step
kill Emissary of Hate##25003
use Shattered Sun Banner##34414
|tip Use it on the Emissary's corpse.
Impale the Emissary of Hate |q 11537/1 |goto Isle of Quel'Danas/0 48.52,42.99
|only if haveq(11537) or completedq(11537)
step
use the Astromancer's Crystal##34533
Take a Portal Reading |q 11547/1 |goto Isle of Quel'Danas/0 48.51,44.45
|only if haveq(11547) or completedq(11547)
step
label "Slay_6_Burning_Legion_Demons"
Kill enemies around this area
Slay #6# Burning Legion Demons |q 11537/2 |goto Isle of Quel'Danas/0 47.74,41.81
|only if haveq(11537) or completedq(11537)
stickystart "Kill_6_Dawnblade_Summoners"
stickystart "Kill_6_Dawnblade_Blood_Knights"
stickystart "Kill_3_Dawnblade_Marksman"
step
use the Astromancer's Crystal##34533
|tip Inside the building.
Take a Bloodcrystal Reading |q 11547/3 |goto Isle of Quel'Danas/0 42.07,35.70
|only if haveq(11547) or completedq(11547)
step
label "Kill_6_Dawnblade_Summoners"
kill 6 Dawnblade Summoner##24978 |q 11540/1 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_6_Dawnblade_Blood_Knights"
kill 6 Dawnblade Blood Knight##24976 |q 11540/2 |goto Isle of Quel'Danas/0 42.08,35.70
|only if haveq(11540) or completedq(11540)
step
label "Kill_3_Dawnblade_Marksman"
kill 3 Dawnblade Marksman##24979 |q 11540/3 |goto Isle of Quel'Danas/0 43.40,38.57
You can find more around: |notinsticky
[Isle of Quel'Danas/0 39.17,40.26]
[Isle of Quel'Danas/0 46.64,40.03]
|only if haveq(11540) or completedq(11540)
step
talk Captain Valindria##25088
accept Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
stickystart "Free_10_Greengill_Slaves"
stickystart "Collect_3_Darkspine_Ore"
step
Follow the road |goto Isle of Quel'Danas/0 52.42,38.39 < 30 |only if walking
Follow the path |goto Isle of Quel'Danas/0 58.39,39.59 < 15 |only if walking
Continue following the path |goto Isle of Quel'Danas/0 58.48,48.43 < 30 |only if walking
use the Astromancer's Crystal##34533
Take a Shrine Reading |q 11547/2 |goto Isle of Quel'Danas/0 61.19,62.54
|only if haveq(11547) or completedq(11547)
step
label "Free_10_Greengill_Slaves"
Kill Darkspine enemies around this area
collect Orb of Murloc Control##34483 |n
use Orb of Murloc Control##34483
|tip Throw the orb on groups of murlocs around this area.
Free #10# Greengill Slaves |q 11541/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11541) or completedq(11541)
step
label "Collect_3_Darkspine_Ore"
Kill Darkspine enemies around this area
collect 3 Darkspine Iron Ore##34479 |q 11536/1 |goto Isle of Quel'Danas/0 61.92,52.28
|only if haveq(11536) or completedq(11536)
step
label "Get_On_Taxi"
talk Ayren Cloudbreaker##25059
Select _"Speaking of action, I've been ordered to undertake an air strike."_
Take a Flight to the Dead Scar |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11533
|only if haveq(11533) or completedq(11533)
stickystart "Kill_3_Eredar_Sorcerer"
stickystart "Kill_12_Wrath_Enforcers"
step
use the Arcane Charges##34475
|tip Fly to the Dead Scar.
|tip Drop the bombs on enemies below you.
kill 2 Pit Overlord##25031 |q 11533/1 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_3_Eredar_Sorcerer"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 3 Eredar Sorcerer##25033 |q 11533/2 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
label "Kill_12_Wrath_Enforcers"
use the Arcane Charges##34475 |notinsticky
|tip Drop the bombs on enemies below you. |notinsticky
kill 12 Wrath Enforcer##25030 |q 11533/3 |goto Isle of Quel'Danas/0 53.20,71.64 |or
'|complete outvehicle() and not (readyq(11533) or completedq(11533)) |next "Get_On_Taxi" |or
|only if haveq(11533) or completedq(11533)
step
Return to Sun's Reach |outvehicle |goto Isle of Quel'Danas/0 48.39,25.25 |q 11533
|only if haveq(11533) or completedq(11533)
step
talk Ayren Cloudbreaker##25059
Select _"I need to intercept the Dawnblade reinforcements."_
Take a Flight to the Dawnblade Fleet |invehicle |goto Isle of Quel'Danas/0 48.51,25.22 |q 11543
|only if haveq(11543) or completedq(11543)
stickystart "Burn_the_Bloodoath_Sails"
stickystart "Burn_the_Dawnchaser_Sails"
step
use the Flaming Oil##34489
|tip Drop the oil on the ship's sails.
Burn the Sin'loren's Sails |q 11543/1 |goto Isle of Quel'Danas/0 52.55,14.99
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Bloodoath_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Bloodoath's Sails |q 11543/2 |goto Isle of Quel'Danas/0 50.59,10.04
|only if haveq(11543) or completedq(11543)
step
label "Burn_the_Dawnchaser_Sails"
use the Flaming Oil##34489 |notinsticky
|tip Drop the oil on the ship's sails. |notinsticky
Burn the Dawnchaser's Sails |q 11543/3 |goto Isle of Quel'Danas/0 55.48,12.12
|only if haveq(11543) or completedq(11543)
step
kill 6 Dawnblade Reservist##25087 |q 11543/4 |goto Isle of Quel'Danas/0 52.55,14.99
|tip Swim out to any of the three ships and run up the ramp on the side.
|only if haveq(11543) or completedq(11543)
step
Enter the building |goto Isle of Quel'Danas/0 47.96,35.96 < 7 |walk
talk Harbinger Inuuro##25061
|tip Inside the building.
turnin The Battle Must Go On##11537 |goto Isle of Quel'Danas/0 47.64,35.07
|only if haveq(11537) or completedq(11537)
step
talk Battlemage Arynna##25057
|tip Inside the building.
turnin The Air Strikes Must Continue##11533 |goto Isle of Quel'Danas/0 47.52,35.07
|only if haveq(11533) or completedq(11533)
step
talk Astromancer Darnarian##25133
|tip Inside the building.
turnin Know Your Ley Lines##11547 |goto Isle of Quel'Danas/0 47.49,35.34
|only if haveq(11547) or completedq(11547)
step
Run up the ramp |goto Isle of Quel'Danas/0 49.17,39.67 < 7 |only if walking
Cross the bridge |goto Isle of Quel'Danas/0 49.75,39.95 < 5 |only if walking
talk Vindicator Kaalan##25108
turnin Keeping the Enemy at Bay##11543 |goto Isle of Quel'Danas/0 50.58,39.00
|only if haveq(11543) or completedq(11543)
step
Continue up the ramp |goto Isle of Quel'Danas/0 50.80,40.34 < 7 |only if walking
Enter the building |goto Isle of Quel'Danas/0 50.09,40.59 < 7 |walk
talk Magister Ilastar##25069
|tip Inside the building.
turnin Crush the Dawnblade##11540 |goto Isle of Quel'Danas/0 49.33,40.38
|only if haveq(11540) or completedq(11540)
step
talk Captain Valindria##25088
turnin Disrupt the Greengill Coast##11541 |goto Isle of Quel'Danas/0 53.77,34.26
|only if haveq(11541) or completedq(11541)
step
talk Exarch Nasuun##24932
accept Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
step
talk Lord Torvos##25140
accept Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
step
talk Emissary Mordin##19202
accept Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if skill("Herbalism") >= 301 or skill("Mining") >= 301 or skill("Skinning") >= 301
step
talk Harbinger Haronem##19475
accept The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
stickystart "Collect_8_Nether_Residue"
step
Equip the Multiphase Spectrographic Goggles |equipped Multiphase Spectrographic Goggles##35233 |goto Nagrand/0 39.70,68.79 |q 11880
|only if haveq(11880) or completedq(11880)
step
use the Multiphase Spectrographic Goggles##35233
|tip Use them on floating orange globes around the Spirit Fields near the big crystal.
Take #6# Multiphase Readings |q 11880/1 |goto Nagrand/0 39.70,68.79
|only if haveq(11880) or completedq(11880)
step
kill Razorthorn Flayer##24920+
collect Razorthorn Flayer Gland##34255 |goto Terokkar Forest/0 58.21,12.97 |q 11521
|only if haveq(11521) or completedq(11521)
step
use the Razorthorn Flayer Gland##34255
|tip Use it on Razorthorn Ravager.
|tip Once it is charmed, take it near dirt mounds and use the "Expose Razorthorn Root" ability on your pet bar.
click Razorthorn Root##187072+
|tip They appear after being exposed by a Razorthorn Ravager.
collect 5 Razorthorn Root##34254 |q 11521/1 |goto Terokkar Forest/0 58.21,12.97
|only if haveq(11521) or completedq(11521)
step
talk Magistrix Seyla##24937
accept Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58
accept Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58
|only if completedq(11526)
stickystart "Destroy_the_Legion_Gateway"
step
kill Wrath Herald##24919+
collect 4 Demonic Blood##34259 |goto Hellfire Peninsula/0 63.40,18.59 |q 11515
|only if haveq(11515) or completedq(11515)
step
use the Fel Siphon##34257
|tip Use it on Felblood Initiates.
kill 4 Emaciated Felblood##24918 |q 11515/1 |goto Hellfire Peninsula/0 61.79,22.27
|tip The Felblood Initiates will transform.
|only if haveq(11515) or completedq(11515)
step
label "Destroy_the_Legion_Gateway"
use Sizzling Embers##34253
|tip This will summon a Living Flare.
|tip Flying on your flying mount will cause it to despawn and reset your progress.
kill Incandescent Fel Spark##22323+
|tip Kill them until the Living Flare becomes unstable.
Destroy the Legion Gateway |q 11516/1 |goto Hellfire Peninsula/0 58.60,18.74
You can find Incandescent Fel Sparks around:
[Hellfire Peninsula/0 58.55,21.48]
[Hellfire Peninsula/0 61.75,19.73]
[Hellfire Peninsula/0 64.82,19.36]
|only if haveq(11516) or completedq(11516)
step
talk Magistrix Seyla##24937
turnin Blood for Blood##11515 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11515) or completedq(11515)
turnin Blast the Gateway##11516 |goto Hellfire Peninsula/0 58.18,17.58 |only if haveq(11516) or completedq(11516)
|only if haveq(11515,11516) or completedq(11515,11516)
step
Kill Bash'ir enemies around this area
collect 1 Bash'ir Phasing Device##34248 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
use the Bash'ir Phasing Device##34248
Gain the "Bash'ir Phasing Device" Buff |havebuff spell:44856 |goto Blade's Edge Mountains/0 51.36,18.88 |q 11514
|only if haveq(11514) or completedq(11514)
step
click Smuggled Mana Cell##187039
|tip They look like small pink boxes on the ground around this area.
collect 10 Smuggled Mana Cell##34246 |q 11514/1 |goto Blade's Edge Mountains/0 51.36,18.88
|only if haveq(11514) or completedq(11514)
step
Kill Sunfury enemies around this area
Sunfury Attack Plans |q 11877/1 |goto Netherstorm/0 28.74,40.64
|only if haveq(11877) or completedq(11877)
step
label "Collect_8_Nether_Residue"
collect 8 Nether Residue##35229 |q 11875/1
|tip These drop from Mining veins, herbs, and skinned enemies.
|tip Use profession farming guides to farm herbs in Outland zones. |only if skill("Herbalism") >= 301
|tip Use profession farming guides to farm ore in Outland zones. |only if skill("Mining") >= 301
|tip Use profession farming guides to farm leather in Outland zones. |only if skill("Skinning") >= 301
|only if haveq(11875) or completedq(11875)
step
talk Exarch Nasuun##24932
turnin Maintaining the Sunwell Portal##11514 |goto Shattrath City/0 49.10,42.48
|only if haveq(11514) or completedq(11514)
step
talk Lord Torvos##25140
turnin Sunfury Attack Plans##11877 |goto Shattrath City/0 62.76,35.98
|only if haveq(11877) or completedq(11877)
step
talk Emissary Mordin##19202
turnin Gaining the Advantage##11875 |goto Shattrath City/0 62.81,35.59
|only if haveq(11875) or completedq(11875)
step
talk Harbinger Haronem##19475
turnin The Multiphase Survey##11880 |goto Shattrath City/0 61.64,52.16
|only if haveq(11880) or completedq(11880)
step
Kill Shadowmoon enemies around this area
collect 5 Ata'mal Armament##34500 |goto Shadowmoon Valley/0 68.74,37.35 |q 11544
|only if haveq(11544) or completedq(11544)
step
use the Ata'mal Armament##34500
collect 5 Cleansed Ata'mal Metal##34501 |q 11544/1 |goto Isle of Quel'Danas/0 50.63,40.74
|only if haveq(11544) or completedq(11544)
step
talk Smith Hauthaa##25046
turnin Don't Stop Now....##11536 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11536) or completedq(11536)
turnin Ata'mal Armaments##11544 |goto Isle of Quel'Danas/0 50.58,40.77 |only if haveq(11544) or completedq(11544)
|only if haveq(11536,11544) or completedq(11536,11544)
step
talk Mar'nah##24975
|tip Inside the building.
turnin Rediscovering Your Roots##11521 |goto Isle of Quel'Danas/0 51.49,32.46 |only if haveq(11521) or completedq(11521)
turnin Open for Business##11546 |goto Isle of Quel'Danas/0 51.49,32.46 |only if haveq(11546) or completedq(11546)
|only if haveq(11521,11546) or completedq(11521,11546)
step
label "Collect_10_Gold"
Collect 10 Gold |q 11548/1
|only if haveq(11548) or completedq(11548)
step
talk Anchorite Ayuri##25112
turnin Your Continued Support##11548 |goto Isle of Quel'Danas/0 49.12,37.61
|only if haveq(11548) or completedq(11548)
step
You have completed all available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11523,11525,11521,11546,11537,11533,11547,11548,11543,11540,11536,11544,11541,11514,11877,11875,11880,11515,11516) |next "Begin_Daily_Quests"
]])
