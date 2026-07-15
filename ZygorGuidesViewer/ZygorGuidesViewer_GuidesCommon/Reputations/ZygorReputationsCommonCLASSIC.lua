local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if ZGV:DoMutex("ReputationsCCLASSIC") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZGV.BETASTART()
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Sha'tari Skyguard",{
author="support@zygorguides.com",
description="\nThis guide section will walk you through completing the Sha'tari Skyguard prerequisite quests.",
condition_end=function() return rep("Sha'tari Skyguard") == Exalted and completedq(11026) end,
},[[
step
Train Artisan Flying |complete skill("Riding") >= 225
|tip Flying is required to complete this questline.
step
talk Yuula##23449
accept Threat from Above##11096 |goto Shattrath City/0 64.35,42.34
step
kill Gordunni Elementalist##22144, Gordunni Back-Breaker##22143, Gordunni Head-Splitter##22148
|tip In the mountains above Shattrath City.
|tip Avoid the elite enemies if you aren't grouped.
Slay #20# Gordunni Ogres |q 11096/1 |goto Terokkar Forest/0 26.75,10.20
|mapmarker Terokkar Forest/0 23.80,9.17
|mapmarker Terokkar Forest/0 22.17,11.32
|mapmarker Terokkar Forest/0 22.74,13.54
|mapmarker Terokkar Forest/0 20.46,14.84
step
talk Yuula##23449
turnin Threat from Above##11096 |goto Shattrath City/0 64.35,42.34
accept To Skettis!##11098 |goto Shattrath City/0 64.35,42.34
step
talk Sky Sergeant Doryn##23048
turnin To Skettis!##11098 |goto Terokkar Forest/0 64.54,66.70
step
talk Skyguard Handler Deesak##23415
accept Hungry Nether Rays##11093 |goto Terokkar Forest/0 63.49,65.80
step
talk Severin##23042
accept World of Shadows##11004 |goto Terokkar Forest/0 64.05,66.88
stickystart "Collect_Shadow_Dust"
step
use the Nether Ray Cage##32834
|tip Keep your Nether Ray summoned while killing Warp Chasers.
|tip Shortly after the Nether Ray does an emote, you'll gain credit towards the goal.
|tip Wait until it is done eating before you kill another.
kill Blackwind Warp Chaser##23219+
Provide the Nether Ray #10# Meals |q 11093/1 |goto Terokkar Forest/0 60.80,82.98
|mapmarker Terokkar Forest/0 62.98,82.63
|mapmarker Terokkar Forest/0 65.04,84.63
|mapmarker Terokkar Forest/0 67.81,87.26
|mapmarker Terokkar Forest/0 61.96,79.43
step
label "Collect_Shadow_Dust"
kill Skettis Wing Guard##21644, Skettis Windwalker##21649, Skettis Soulcaller##21911, Skettis Talonite##21650
|tip Arakkoas.
collect 6 Shadow Dust##32388 |q 11004/1 |goto Terokkar Forest/0 61.99,74.76
|mapmarker Terokkar Forest/0 69.69,84.52
|mapmarker Terokkar Forest/0 70.16,79.66
|mapmarker Terokkar Forest/0 72.96,80.80
|mapmarker Terokkar Forest/0 75.18,81.18
|mapmarker Terokkar Forest/0 61.41,78.19
|mapmarker Terokkar Forest/0 69.19,74.85
step
talk Severin##23042
turnin World of Shadows##11004 |goto Terokkar Forest/0 64.05,66.88
step
talk Skyguard Handler Deesak##23415
turnin Hungry Nether Rays##11093 |goto Terokkar Forest/0 63.49,65.80
step
Watch the dialogue
talk Sky Commander Adaris##23038
accept Secrets of the Talonpriests##11005 |goto Terokkar Forest/0 64.09,66.90
step
use the Elixir of Shadows##32446
Gain the Elixir of Shadows Buff |havebuff  Elixir of Shadows##37678 |q 11005
step
kill Talonpriest Zellek##23068 |q 11005/3 |goto Terokkar Forest/0 70.13,74.40
|tip On the platform.
step
kill Talonpriest Ishaal##23066 |q 11005/1 |goto Terokkar Forest/0 69.26,78.24
|tip On the platform.
collect Ishaal's Almanac##32523 |n
|tip Loot it from Talonpriest Ishaal's corpse.
use Ishaal's Almanac##32523
accept Ishaal's Almanac##11021 |goto Terokkar Forest/0 69.26,78.24
step
kill Talonpriest Skizzik##23067+ |q 11005/2 |goto Terokkar Forest/0 69.75,81.82
|tip Inside the building.
step
talk Sky Commander Adaris##23038
turnin Secrets of the Talonpriests##11005 |goto Terokkar Forest/0 64.09,66.90
turnin Ishaal's Almanac##11021 |goto Terokkar Forest/0 64.09,66.90
accept An Ally in Lower City##11024 |goto Terokkar Forest/0 64.09,66.90
step
talk Rilak the Redeemed##22292
turnin An Ally in Lower City##11024 |goto Shattrath City/0 52.52,21.01
accept Countdown to Doom##11028 |goto Shattrath City/0 52.52,21.01
step
talk Sky Commander Adaris##23038
turnin Countdown to Doom##11028 |goto Terokkar Forest/0 64.09,66.90
step
talk Hazzik##23306
|tip In a cage.
accept Hazzik's Bargain##11056 |goto Terokkar Forest/0 64.23,66.97
step
click Hazzik's Package##185954
|tip Inside the building.
collect Hazzik's Package##32687 |q 11056/1 |goto Terokkar Forest/0 74.85,80.08
step
talk Hazzik##23306
|tip In a cage.
turnin Hazzik's Bargain##11056 |goto Terokkar Forest/0 64.23,66.97
accept A Shabby Disguise##11029 |goto Terokkar Forest/0 64.23,66.97
step
use the Shabby Arakkoa Disguise##32741
Wear the Shabby Arakkoa Disguise |havebuff Shabby Arakkoa Disguise##41181 |goto Terokkar Forest/0 66.21,77.49 |q 11029
step
talk Sahaak##23363
|tip Inside the building.
Select _"Skwak!"_ |gossip 118854
buy 1 Adversarial Bloodlines##32742 |q 11029/1 |goto Terokkar Forest/0 67.01,79.65
step
talk Hazzik##23306
|tip In a cage.
turnin A Shabby Disguise##11029 |goto Terokkar Forest/0 64.23,66.97
accept Adversarial Blood##11885 |goto Terokkar Forest/0 64.23,66.97
|tip This quest is intended for a group.
step
kill Skettis Wing Guard##21644, Skettis Windwalker##21649, Skettis Soulcaller##21911, Skettis Talonite##21650
|tip Arakkoas.
collect 12 Shadow Dust##32388 |goto Terokkar Forest/0 61.99,74.76 |q 11885
|tip You can also buy them from the Auction House.
|mapmarker Terokkar Forest/0 69.69,84.52
|mapmarker Terokkar Forest/0 70.16,79.66
|mapmarker Terokkar Forest/0 72.96,80.80
|mapmarker Terokkar Forest/0 75.18,81.18
|mapmarker Terokkar Forest/0 61.41,78.19
|mapmarker Terokkar Forest/0 69.19,74.85
step
talk Severin##23042
accept More Shadow Dust##11006
|tip Repeatable.
collect 2 Elixir of Shadows##32446 |goto Terokkar Forest/0 64.05,66.88 |q 11885
step
use the Elixir of Shadows##32446
Gain the Elixir of Shadows Buff |havebuff  Elixir of Shadows##37678 |q 11885
step
kill Time-Lost Skettis Worshipper##21763, kill Time-Lost Skettis Reaver##21651, kill Time-Lost Skettis High Priest##21787
collect 40 Time-Lost Scroll##32620 |goto Terokkar Forest 61.6,75.3 |q 11885
|tip You can also buy them from the Auction House.
|mapmarker Terokkar Forest 69.5,85.5
|mapmarker Terokkar Forest 73.2,87.9
|mapmarker Terokkar Forest 75.2,81.3
|mapmarker Terokkar Forest 69.2,74.1
step
click Skull Pile##185913
|tip This will consume 10 Time-Lost Scrolls.
Select _"<Call forth Gezzarak the Huntress.>"_ |gossip 36671
kill Gezzarak the Huntress##23163 |q 11885/3 |goto Terokkar Forest/0 69.66,74.70
|tip Intended for a group.
|tip You may need help with this.
|mapmarker Terokkar Forest/0 70.07,79.43
|mapmarker Terokkar Forest/0 70.23,83.35
|mapmarker Terokkar Forest/0 73.53,80.70
collect Gezzarak's Claws##32716 |q 11885
|tip Loot it from Gezzarak the Huntress' corpse.
step
click Skull Pile##185913
|tip This will consume 10 Time-Lost Scrolls.
Select _"<Call forth Darkscreecher Akkarai.>"_ |gossip 36672
kill Darkscreecher Akkarai##23161 |q 11885/1 |goto Terokkar Forest/0 69.66,74.70
|tip Intended for a group.
|tip You may need help with this.
|mapmarker Terokkar Forest/0 70.07,79.43
|mapmarker Terokkar Forest/0 70.23,83.35
|mapmarker Terokkar Forest/0 73.53,80.70
collect Akkarai's Talons##32715 |q 11885
|tip Loot it from Darkscreecher Akkarai's corpse.
step
click Skull Pile##185913
|tip This will consume 10 Time-Lost Scrolls.
Select _"<Call forth Karrog.>"_ |gossip 36673
kill Karrog##23165 |q 11885/2 |goto Terokkar Forest/0 69.66,74.70
|tip Intended for a group.
|tip You may need help with this.
|mapmarker Terokkar Forest/0 70.07,79.43
|mapmarker Terokkar Forest/0 70.23,83.35
|mapmarker Terokkar Forest/0 73.53,80.70
collect Karrog's Spine##32717 |q 11885
|tip Loot it from Karrog's corpse.
step
click Skull Pile##185913
|tip This will consume 10 Time-Lost Scrolls.
Select _"<Call forth Vakkiz the Windrager.>"_ |gossip 36674
kill Vakkiz the Windrager##23204 |q 11885/4 |goto Terokkar Forest/0 69.66,74.70
|tip Intended for a group.
|tip You may need help with this.
|mapmarker Terokkar Forest/0 70.07,79.43
|mapmarker Terokkar Forest/0 70.23,83.35
|mapmarker Terokkar Forest/0 73.53,80.70
collect Vakkiz's Scale##32718 |q 11885
|tip Loot it from Vakkiz the Windrager's corpse.
step
talk Hazzik##23306
|tip In a cage.
turnin Adversarial Blood##11885 |goto Terokkar Forest/0 64.23,66.97
Watch the dialogue
accept Tokens of the Descendants##11074 |goto Terokkar Forest/0 64.23,66.97
step
talk Sky Commander Adaris##23038
accept Terokk's Downfall##11073 |goto Terokkar Forest/0 64.09,66.90
step
click Skull Pile##185913
|tip This will consume 1 Time-Lost Offering.
Select _"<Call forth Terokk.>"_ |gossip 35384
kill Terokk##21838 |q 11073/1 |goto Terokkar Forest/0 66.21,77.48
|tip When he becomes immune, walk him over the blue smoke.
|tip A meteor will come down and break his shield.
step
talk Sky Commander Adaris##23038
turnin Terokk's Downfall##11073 |goto Terokkar Forest/0 64.09,66.90
step
talk V'eru##22497
accept Speak with the Ogre##10984 |goto Shattrath City/0 56.45,49.10
step
talk Grok##22940
turnin Speak with the Ogre##10984 |goto Shattrath City/0 64.93,68.12
accept Mog'dorg the Wizened##10983 |goto Shattrath City/0 64.93,68.12
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Mog'dorg the Wizened##10983 |goto Blade's Edge Mountains/0 55.48,44.86
accept Grulloc Has Two Skulls##10995 |goto Blade's Edge Mountains/0 55.48,44.86
accept Maggoc's Treasure Chest##10996 |goto Blade's Edge Mountains/0 55.48,44.86
accept Even Gronn Have Standards##10997 |goto Blade's Edge Mountains/0 55.48,44.86
|tip These quests are intended for group play.
step
kill Grulloc##20216
|tip Intended for a group.
click Grulloc's Dragon Skull##185567
|tip It appears after Grulloc dies.
collect Grulloc's Dragon Skull##32379 |q 10995/1 |goto Blade's Edge Mountains/0 61.05,47.79
step
map Blade's Edge Mountains/0
path	follow loose;	curved;		dist 30
path	59.3,64.7	59.6,56.8	65.0,54.1	67.5,58.5	68.4,65.8
path	68.4,73.7
kill Maggoc##20600
|tip Patrols along the path.
|tip Intended for a group.
click Maggoc's Treasure Chest##185569
|tip It appears after Maggoc dies.
collect 1 Maggoc's Treasure Chest##32380 |q 10996/1 |goto Blade's Edge Mountains/0 67.83,65.85
step
kill Slaag##22199
|tip Inside the building.
|tip Intended for a group.
click Slaag's Standard##185574
|tip It appears after Slaag dies.
collect 1 Slaag's Standard##32382 |q 10997/1 |goto Terokkar Forest/0 20.52,17.70
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Grulloc Has Two Skulls##10995 |goto Blade's Edge Mountains/0 55.48,44.86
turnin Maggoc's Treasure Chest##10996 |goto Blade's Edge Mountains/0 55.48,44.86
turnin Even Gronn Have Standards##10997 |goto Blade's Edge Mountains/0 55.48,44.86
accept Grim(oire) Business##10998 |goto Blade's Edge Mountains/0 55.48,44.86
|tip This quest is intended for group play.
step
kill Vim'gol the Vile##22911
|tip Intended for a group.
|tip Stand in the fire until Vim'gol the Vile spawns.
click Vim'gol's Vile Grimoire##185562
|tip It appears after Vim'gol the Vile dies.
collect 1 Vim'gol's Vile Grimoire##32358 |q 10998/1 |goto Blade's Edge Mountains/0 77.47,31.28
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Grim(oire) Business##10998 |goto Blade's Edge Mountains/0 55.48,44.86
accept Into the Soulgrinder##11000 |goto Blade's Edge Mountains/0 55.48,44.86
|tip This quest is intended for group play.
step
use Vim'gol's Grimoire##32467
kill Sundered Spirit##22912
|tip Adds will attack in waves after.
|tip Defend the Soulgrinder.
|tip Intended for a group.
kill Skulloc Soulgrinder##22910
click Skulloc's Soul##185577
|tip It appears after Skulloc dies.
collect 1 Skulloc's Soul##32383 |q 11000/1 |goto Blade's Edge Mountains/0 60.67,25.51
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Into the Soulgrinder##11000 |goto Blade's Edge Mountains/0 55.48,44.86
step
Watch the dialogue
talk Bladespire Supplicant##23053
|tip It will spawn around this area.
accept Speak with Mog'dorg##11022 |goto Blade's Edge Mountains/0 55.77,46.38
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Speak with Mog'dorg##11022 |goto Blade's Edge Mountains/0 55.48,44.86
accept Ogre Heaven##11009 |goto Blade's Edge Mountains/0 55.48,44.86
step
talk Chu'a'lor##23233
turnin Ogre Heaven##11009 |goto Blade's Edge Mountains/0 28.76,57.36
accept The Crystals##11025 |goto Blade's Edge Mountains/0 28.76,57.36
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911+
|tip They look like large clusters of crystals on the ground around this area.
collect 5 Apexis Shard##32569 |q 11025/1 |goto Blade's Edge Mountains/0 31.78,57.42
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
talk Chu'a'lor##23233
turnin The Crystals##11025 |goto Blade's Edge Mountains/0 28.76,57.36
accept An Apexis Relic##11058 |goto Blade's Edge Mountains/0 28.76,57.36
step
talk Torkus##23316
accept Our Boy Wants To Be A Skyguard Ranger##11030 |goto Blade's Edge Mountains/0 28.38,57.65
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911+
|tip They look like large clusters of crystals on the ground around this area.
collect Apexis Shard##32569 |q 11058 |goto Blade's Edge Mountains/0 31.78,57.42
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Apexis Relic
|tip It looks like a small floating crystal hovering over a white orb on the ground.
Select _"Insert an Apexis Shard, and begin!"_ |gossip 36294
Repeat the color patterns that are shown
|tip Ignore the floating crystal and focus on the crystals on the ground.
|tip Observe the color sequence and click the stones on the ground in the same order.
|tip It's random every time, and you'll have to repeat 6 sequences.
Attain the Apexis Vibrations |q 11058/1 |goto Blade's Edge Mountains/0 32.06,63.35
|tip If you fail, you will need to farm another Apexis Shard.
step
talk Chu'a'lor##23233
turnin An Apexis Relic##11058 |goto Blade's Edge Mountains/0 28.76,57.36
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 10 Apexis Shard##32569 |q 11030 |goto Blade's Edge Mountains/0 31.78,57.42
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Fel Crystalforge##7392
|tip It looks like a metal machine with green bubbles floating out of it.
Select _"Purchase 1 Unstable Flask of the Beast for the cost of 10 Apexis Shards"_ |gossip 34677
collect Unstable Flask of the Beast##32598 |q 11030/1 |goto Blade's Edge Mountains/0 32.79,40.46
step
talk Torkus##23316
turnin Our Boy Wants To Be A Skyguard Ranger##11030 |goto Blade's Edge Mountains/0 28.38,57.65
step
talk Chu'a'lor##23233
accept The Skyguard Outpost##11062 |goto Blade's Edge Mountains/0 28.76,57.36
step
talk Sky Commander Keller##23334
turnin The Skyguard Outpost##11062 |goto Blade's Edge Mountains/0 27.40,52.69
step
talk Sky Sergeant Vanderlip##23120
accept Bombing Run##11010 |goto Blade's Edge Mountains/0 27.57,52.91 |only if not raceclass("Druid")
accept Bombing Run##11102 |goto Blade's Edge Mountains/0 27.57,52.91 |only if raceclass("Druid")
step
use the Skyguard Bombs##32456
|tip You must be mounted to use the bombs.
|tip Use them on Fel Cannonball Stacks.
|tip They are stacks of cannonballs with a green hue on the underside.
|tip Fel Cannons will try to shoot you down while flying.
|tip Mount up on the ground near a Fel Cannonball Stack and immediately use the bombs on the stack.
|tip This will dismount you quickly before a cannon can fire at you.
Destroy #15# Fel Cannonball Stacks |q 11010/1 |goto Blade's Edge Mountains/0 34.49,41.07 |only if not raceclass("Druid")
Destroy #15# Fel Cannonball Stacks |q 11102/1 |goto Blade's Edge Mountains/0 34.49,41.07 |only if raceclass("Druid")
|mapmarker Blade's Edge Mountains/0 37.62,38.36
|mapmarker Blade's Edge Mountains/0 37.39,40.44
|mapmarker Blade's Edge Mountains/0 36.26,39.91
|mapmarker Blade's Edge Mountains/0 33.26,39.45
|mapmarker Blade's Edge Mountains/0 32.42,40.57
|mapmarker Blade's Edge Mountains/0 33.21,43.91
|mapmarker Blade's Edge Mountains/0 33.79,43.96
|mapmarker Blade's Edge Mountains/0 33.45,45.27
|mapmarker Blade's Edge Mountains/0 27.05,74.34
|mapmarker Blade's Edge Mountains/0 27.63,74.96
|mapmarker Blade's Edge Mountains/0 28.51,79.75
|mapmarker Blade's Edge Mountains/0 28.29,84.59
|mapmarker Blade's Edge Mountains/0 30.19,84.70
|mapmarker Blade's Edge Mountains/0 30.60,85.71
|mapmarker Blade's Edge Mountains/0 31.09,84.37
|mapmarker Blade's Edge Mountains/0 29.95,81.70
|mapmarker Blade's Edge Mountains/0 30.07,79.98
|mapmarker Blade's Edge Mountains/0 29.73,76.72
|mapmarker Blade's Edge Mountains/0 30.29,76.21
step
talk Sky Sergeant Vanderlip##23120
turnin Bombing Run##11010 |goto Blade's Edge Mountains/0 27.57,52.91 |only if not raceclass("Druid")
turnin Bombing Run##11102 |goto Blade's Edge Mountains/0 27.57,52.91 |only if raceclass("Druid")
step
talk Sky Commander Keller##23334
accept Assault on Bash'ir Landing!##11119 |goto Blade's Edge Mountains/0 27.40,52.69
step
talk Aether-tech Apprentice##23473
turnin Assault on Bash'ir Landing!##11119 |goto Blade's Edge Mountains/0 27.90,52.17
step
talk Skyguard Khatie##23335
accept Wrangle Some Aether Rays!##11065 |goto Blade's Edge Mountains/0 27.95,51.45
step
kill Aether Ray##22181+
use the Wrangling Rope##32698
|tip Use it on weakened Aether Rays around this area.
|tip Reduce their health until you see a message indicating they can be wrangled.
|tip If you are well-geared, you may need to unequip some of your gear to avoid killing them.
Wrangle #5# Aether Rays |q 11065/1 |goto Blade's Edge Mountains/0 29.11,49.82
|mapmarker Blade's Edge Mountains/0 29.16,46.54
|mapmarker Blade's Edge Mountains/0 29.93,48.16
|mapmarker Blade's Edge Mountains/0 30.88,51.64
|mapmarker Blade's Edge Mountains/0 31.74,55.55
|mapmarker Blade's Edge Mountains/0 29.62,63.94
|mapmarker Blade's Edge Mountains/0 28.27,63.23
|mapmarker Blade's Edge Mountains/0 28.06,66.55
|mapmarker Blade's Edge Mountains/0 30.29,67.03
|mapmarker Blade's Edge Mountains/0 30.97,69.29
|mapmarker Blade's Edge Mountains/0 29.19,70.89
|mapmarker Blade's Edge Mountains/0 31.47,61.93
|mapmarker Blade's Edge Mountains/0 31.36,59.45
|mapmarker Blade's Edge Mountains/0 30.29,55.65
|mapmarker Blade's Edge Mountains/0 29.71,53.45
|markmaker Blade's Edge Mountains/0 32.88,59.73
step
talk Chu'a'lor##23233
accept Guardian of the Monument##11059 |goto Blade's Edge Mountains/0 28.76,57.36
|tip This quest is elite and will require a group.
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 35 Apexis Shard##32569 |q 11059 |goto Blade's Edge Mountains/0 31.78,57.42
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Apexis Monument##185944
|tip It's a huge floating crystal with alternating colors in the middle of the platform.
Select _"Insert 35 Apexis Shards, and begin!"_ |gossip 36942
Click any of the 4 big colored buttons on the ground
|tip Only do this if you have good gear.
|tip You will get hit for 7,000 damage each time.
|tip This will make the quest mob spawn faster.
kill Apexis Guardian##22275
|tip It will eventually spawn.
|tip This enemy is elite and will require a group.
collect Apexis Guardian's Head##32697 |q 11059/1 |goto Blade's Edge Mountains/0 31.76,63.80
step
talk Chu'a'lor##23233
turnin Guardian of the Monument##11059 |goto Blade's Edge Mountains/0 28.76,57.36
step
talk Skyguard Khatie##23335
turnin Wrangle Some Aether Rays!##11065 |goto Blade's Edge Mountains/0 27.95,51.45
step
talk Sky Commander Keller##23334
accept To Rule The Skies##11078 |goto Blade's Edge Mountains/0 27.40,52.69
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 35 Apexis Shard##32569 |q 11078 |goto Blade's Edge Mountains/0 31.78,57.42
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Rivendark's Egg##185936
Select _"Place 35 Apexis Shards near the dragon egg to crack it open."_ |gossip 35385
kill Rivendark##23061
collect Dragon Teeth##32732 |q 11078/1 |goto Blade's Edge Mountains/0 27.16,64.80
step
talk Sky Commander Keller##23334
turnin To Rule The Skies##11078 |goto Blade's Edge Mountains/0 27.40,52.69
step
Reach Honored Reputation with Ogri'la |complete rep("Ogri'la") >= Honored |or
|tip Use the "Ogri'la" reputation guide to accomplish this.
Click Here to Load the {o}Ogri'la{} Reputation guide |confirm |loadguide "Reputation Guides\\The Burning Crusade\\Ogri'la" |or
step
talk Kronk##23253
accept Banish the Demons##11026 |goto Blade's Edge Mountains/0 28.89,57.92
step
use the Banishing Crystal##32696
Kill enemies around this area
|tip Kill Fear Fiends and Abyssal Flamebringers that spawn near the portal that opens.
Banish #15# Demons |q 11026/1 |goto Blade's Edge Mountains/0 29.1,79.3
step
talk Kronk##23253
turnin Banish the Demons##11026 |goto Blade's Edge Mountains/0 28.89,57.92
step
Reach Exalted Reputation with Sha'tari Skyguard |complete rep("Sha'tari Skyguard") >= Exalted
|tip Use the "Sha'tari Skyguard Daily Quests" guide to accomplish this.
|tip You can also form a group and use the "Sha'tari Skyguard Terokk Farming" guide to kill elites for rep.
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Ogri'la",{
author="support@zygorguides.com",
condition_suggested=function() return level >= 70 and not completedq(11026) end,
condition_end=function() return rep("Ogri'la") == Exalted and completedq(11026) end,
},[[
step
Train Artisan Riding |complete skill("Riding") >= 225
|tip Flying is required to complete this questline.
step
talk V'eru##22497
accept Speak with the Ogre##10984 |goto Shattrath City/0 56.45,49.10
|only if not completedq(10983) and not haveq(10983)
step
talk Grok##22940
turnin Speak with the Ogre##10984 |goto Shattrath City/0 64.93,68.12
accept Mog'dorg the Wizened##10983 |goto Shattrath City/0 64.93,68.12
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Mog'dorg the Wizened##10983 |goto Blade's Edge Mountains/0 55.48,44.86
accept Grulloc Has Two Skulls##10995 |goto Blade's Edge Mountains/0 55.48,44.86
accept Maggoc's Treasure Chest##10996 |goto Blade's Edge Mountains/0 55.48,44.86
accept Even Gronn Have Standards##10997 |goto Blade's Edge Mountains/0 55.48,44.86
|tip These quests are intended for group play.
step
kill Grulloc##20216
|tip Intended for a group.
click Grulloc's Dragon Skull##185567
|tip It appears after Grulloc dies.
collect Grulloc's Dragon Skull##32379 |q 10995/1 |goto Blade's Edge Mountains/0 61.05,47.79
step
map Blade's Edge Mountains/0
path	follow loose;	curved;		dist 30
path	59.3,64.7	59.6,56.8	65.0,54.1	67.5,58.5	68.4,65.8
path	68.4,73.7
kill Maggoc##20600
|tip Patrols along the path.
|tip Intended for a group.
click Maggoc's Treasure Chest##185569
|tip It appears after Maggoc dies.
collect 1 Maggoc's Treasure Chest##32380 |q 10996/1 |goto Blade's Edge Mountains/0 67.83,65.85
step
kill Slaag##22199
|tip Inside the building.
|tip Intended for a group.
click Slaag's Standard##185574
|tip It appears after Slaag dies.
collect 1 Slaag's Standard##32382 |q 10997/1 |goto Terokkar Forest/0 20.52,17.70
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Grulloc Has Two Skulls##10995 |goto Blade's Edge Mountains/0 55.48,44.86
turnin Maggoc's Treasure Chest##10996 |goto Blade's Edge Mountains/0 55.48,44.86
turnin Even Gronn Have Standards##10997 |goto Blade's Edge Mountains/0 55.48,44.86
accept Grim(oire) Business##10998 |goto Blade's Edge Mountains/0 55.48,44.86
|tip This quest is intended for group play.
step
kill Vim'gol the Vile##22911
|tip Intended for a group.
|tip Stand in the fire until Vim'gol the Vile spawns.
click Vim'gol's Vile Grimoire##185562
|tip It appears after Vim'gol the Vile dies.
collect 1 Vim'gol's Vile Grimoire##32358 |q 10998/1 |goto Blade's Edge Mountains/0 77.47,31.28
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Grim(oire) Business##10998 |goto Blade's Edge Mountains/0 55.48,44.86
accept Into the Soulgrinder##11000 |goto Blade's Edge Mountains/0 55.48,44.86
|tip This quest is intended for group play.
step
use Vim'gol's Grimoire##32467
kill Sundered Spirit##22912
|tip Adds will attack in waves after.
|tip Defend the Soulgrinder.
|tip Intended for a group.
kill Skulloc Soulgrinder##22910
click Skulloc's Soul##185577
|tip It appears after Skulloc dies.
collect 1 Skulloc's Soul##32383 |q 11000/1 |goto Blade's Edge Mountains/0 60.67,25.51
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Into the Soulgrinder##11000 |goto Blade's Edge Mountains/0 55.48,44.86
step
Watch the dialogue
talk Bladespire Supplicant##23053
|tip It will spawn around this area.
accept Speak with Mog'dorg##11022 |goto Blade's Edge Mountains/0 55.77,46.38
step
talk Mog'dorg the Wizened##22941
|tip Top of the tower.
turnin Speak with Mog'dorg##11022 |goto Blade's Edge Mountains/0 55.48,44.86
accept Ogre Heaven##11009 |goto Blade's Edge Mountains/0 55.48,44.86
step
talk Chu'a'lor##23233
turnin Ogre Heaven##11009 |goto Blade's Edge Mountains/0 28.76,57.36
accept The Crystals##11025 |goto Blade's Edge Mountains/0 28.76,57.36
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911+
|tip They look like large clusters of crystals on the ground around this area.
collect 5 Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42 |q 11025/1
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
talk Chu'a'lor##23233
turnin The Crystals##11025 |goto Blade's Edge Mountains/0 28.76,57.36
accept An Apexis Relic##11058 |goto Blade's Edge Mountains/0 28.76,57.36
step
talk Torkus##23316
accept Our Boy Wants To Be A Skyguard Ranger##11030 |goto Blade's Edge Mountains/0 28.38,57.65
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911+
|tip They look like large clusters of crystals on the ground around this area.
collect Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42 |q 11058
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Apexis Relic
|tip It looks like a small floating crystal hovering over a white orb on the ground.
Select _"Insert an Apexis Shard, and begin!"_ |gossip 36294
Repeat the color patterns that are shown
|tip Ignore the floating crystal and focus on the crystals on the ground.
|tip Observe the color sequence and click the stones on the ground in the same order.
|tip It's random every time, and you'll have to repeat 6 sequences.
Attain the Apexis Vibrations |q 11058/1 |goto Blade's Edge Mountains/0 32.06,63.35
|tip If you fail, you will need to farm another Apexis Shard.
step
talk Chu'a'lor##23233
turnin An Apexis Relic##11058 |goto Blade's Edge Mountains/0 28.76,57.36
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 10 Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42  |q 11030
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Fel Crystalforge##7392
|tip It looks like a metal machine with green bubbles floating out of it.
Select _"Purchase 1 Unstable Flask of the Beast for the cost of 10 Apexis Shards"_ |gossip 34677
collect Unstable Flask of the Beast##32598 |q 11030/1 |goto Blade's Edge Mountains/0 32.79,40.46
step
talk Torkus##23316
turnin Our Boy Wants To Be A Skyguard Ranger##11030 |goto Blade's Edge Mountains/0 28.38,57.65
accept A Father's Duty##11061 |goto Blade's Edge Mountains/0 28.38,57.65
step
talk Chu'a'lor##23233
accept The Skyguard Outpost##11062 |goto Blade's Edge Mountains/0 28.76,57.36
step
talk Sky Commander Keller##23334
turnin The Skyguard Outpost##11062 |goto Blade's Edge Mountains/0 27.40,52.69
step
talk Sky Sergeant Vanderlip##23120
accept Bombing Run##11010 |goto Blade's Edge Mountains/0 27.57,52.91 |only if not raceclass("Druid")
accept Bombing Run##11102 |goto Blade's Edge Mountains/0 27.57,52.91 |only if raceclass("Druid")
step
use the Skyguard Bombs##32456
|tip You must be mounted to use the bombs.
|tip Use them on Fel Cannonball Stacks.
|tip They are stacks of cannonballs with a green hue on the underside.
|tip Fel Cannons will try to shoot you down while flying.
|tip Mount up on the ground near a Fel Cannonball Stack and immediately use the bombs on the stack.
|tip This will dismount you quickly before a cannon can fire at you.
Destroy #15# Fel Cannonball Stacks |q 11010/1 |goto Blade's Edge Mountains/0 34.49,41.07 |only if not raceclass("Druid")
Destroy #15# Fel Cannonball Stacks |q 11102/1 |goto Blade's Edge Mountains/0 34.49,41.07 |only if raceclass("Druid")
|mapmarker Blade's Edge Mountains/0 37.62,38.36
|mapmarker Blade's Edge Mountains/0 37.39,40.44
|mapmarker Blade's Edge Mountains/0 36.26,39.91
|mapmarker Blade's Edge Mountains/0 33.26,39.45
|mapmarker Blade's Edge Mountains/0 32.42,40.57
|mapmarker Blade's Edge Mountains/0 33.21,43.91
|mapmarker Blade's Edge Mountains/0 33.79,43.96
|mapmarker Blade's Edge Mountains/0 33.45,45.27
|mapmarker Blade's Edge Mountains/0 27.05,74.34
|mapmarker Blade's Edge Mountains/0 27.63,74.96
|mapmarker Blade's Edge Mountains/0 28.51,79.75
|mapmarker Blade's Edge Mountains/0 28.29,84.59
|mapmarker Blade's Edge Mountains/0 30.19,84.70
|mapmarker Blade's Edge Mountains/0 30.60,85.71
|mapmarker Blade's Edge Mountains/0 31.09,84.37
|mapmarker Blade's Edge Mountains/0 29.95,81.70
|mapmarker Blade's Edge Mountains/0 30.07,79.98
|mapmarker Blade's Edge Mountains/0 29.73,76.72
|mapmarker Blade's Edge Mountains/0 30.29,76.21
step
talk Sky Sergeant Vanderlip##23120
turnin Bombing Run##11010 |goto Blade's Edge Mountains/0 27.57,52.91 |only if not raceclass("Druid")
turnin Bombing Run##11102 |goto Blade's Edge Mountains/0 27.57,52.91 |only if raceclass("Druid")
step
talk Sky Commander Keller##23334
accept Assault on Bash'ir Landing!##11119 |goto Blade's Edge Mountains/0 27.40,52.69
step
talk Aether-tech Apprentice##23473
turnin Assault on Bash'ir Landing!##11119 |goto Blade's Edge Mountains/0 27.90,52.17
step
talk Skyguard Khatie##23335
accept Wrangle Some Aether Rays!##11065 |goto Blade's Edge Mountains/0 27.95,51.45
step
kill Aether Ray##22181+
use the Wrangling Rope##32698
|tip Use it on weakened Aether Rays around this area.
|tip Reduce their health until you see a message indicating they can be wrangled.
|tip If you are well-geared, you may need to unequip some of your gear to avoid killing them.
Wrangle #5# Aether Rays |q 11065/1 |goto Blade's Edge Mountains/0 29.11,49.82
|mapmarker Blade's Edge Mountains/0 29.16,46.54
|mapmarker Blade's Edge Mountains/0 29.93,48.16
|mapmarker Blade's Edge Mountains/0 30.88,51.64
|mapmarker Blade's Edge Mountains/0 31.74,55.55
|mapmarker Blade's Edge Mountains/0 29.62,63.94
|mapmarker Blade's Edge Mountains/0 28.27,63.23
|mapmarker Blade's Edge Mountains/0 28.06,66.55
|mapmarker Blade's Edge Mountains/0 30.29,67.03
|mapmarker Blade's Edge Mountains/0 30.97,69.29
|mapmarker Blade's Edge Mountains/0 29.19,70.89
|mapmarker Blade's Edge Mountains/0 31.47,61.93
|mapmarker Blade's Edge Mountains/0 31.36,59.45
|mapmarker Blade's Edge Mountains/0 30.29,55.65
|mapmarker Blade's Edge Mountains/0 29.71,53.45
|mapmarker Blade's Edge Mountains/0 32.88,59.73
step
talk Chu'a'lor##23233
accept Guardian of the Monument##11059 |goto Blade's Edge Mountains/0 28.76,57.37
|tip This quest is intended for group play.
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 35 Apexis Shard##32569  |goto Blade's Edge Mountains/0 31.78,57.42 |q 11059
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Apexis Monument##185944
|tip It's a huge floating crystal with alternating colors in the middle of the platform.
Select _"Insert 35 Apexis Shards, and begin!"_ |gossip 36942
Click any of the 4 big colored buttons on the ground
|tip Only do this if you have good gear.
|tip You will get hit for 7,000 damage each time.
|tip This will make the quest mob spawn faster.
kill Apexis Guardian##22275
|tip It will eventually spawn.
|tip This enemy is elite and will require a group.
collect Apexis Guardian's Head##32697 |q 11059/1 |goto Blade's Edge Mountains/0 31.76,63.80
step
talk Chu'a'lor##23233
turnin Guardian of the Monument##11059 |goto Blade's Edge Mountains/0 28.76,57.37
step
talk Skyguard Khatie##23335
turnin Wrangle Some Aether Rays!##11065 |goto Blade's Edge Mountains/0 27.95,51.45
step
talk Sky Commander Keller##23334
accept To Rule The Skies##11078 |goto Blade's Edge Mountains/0 27.40,52.69
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 35 Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42 |q 11078
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Rivendark's Egg##185936
|tip This quest is intended for group play.
Select _"Place 35 Apexis Shards near the dragon egg to crack it open."_ |gossip 35385
kill Rivendark##23061
collect Dragon Teeth##32732 |q 11078/1 |goto Blade's Edge Mountains/0 27.16,64.80
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 10 Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42 |q 11078
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
talk Sky Commander Keller##23334
turnin To Rule The Skies##11078 |goto Blade's Edge Mountains/0 27.40,52.69
step
click the Bash'ir Crystalforge##7392
Select _"Purchase 1 Unstable Flask of the Sorcerer for the cost of 10 Apexis Shards"_ |gossip 34121
collect Unstable Flask of the Sorcerer##32601 |q 11061/1 |goto Blade's Edge Mountains/0 54.39,10.71
step
talk Torkus##23316
turnin A Father's Duty##11061 |goto Blade's Edge Mountains/0 28.4,57.6
step
talk Gahk##23300
accept A Fel Whip For Gahk##11079 |goto Blade's Edge Mountains/0 28.48,58.08
|tip This quest is intended for group play.
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911
|tip They look like large clusters of crystals on the ground around this area.
collect 35 Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42 |q 11079
|mapmarker Blade's Edge Mountains/0 32.13,54.77
|mapmarker Blade's Edge Mountains/0 33.35,51.74
|mapmarker Blade's Edge Mountains/0 32.83,49.34
|mapmarker Blade's Edge Mountains/0 29.17,46.50
|mapmarker Blade's Edge Mountains/0 29.75,50.06
|mapmarker Blade's Edge Mountains/0 28.82,52.31
|mapmarker Blade's Edge Mountains/0 29.98,54.59
|mapmarker Blade's Edge Mountains/0 29.69,60.03
|mapmarker Blade's Edge Mountains/0 30.39,62.84
|mapmarker Blade's Edge Mountains/0 28.36,64.76
|mapmarker Blade's Edge Mountains/0 27.51,68.44
|mapmarker Blade's Edge Mountains/0 27.64,70.84
|mapmarker Blade's Edge Mountains/0 30.99,68.03
|mapmarker Blade's Edge Mountains/0 30.91,64.29
step
click Fel Crystal Prism##185927
|tip It's a big green crystal floating in green smoke above 4 metal vents.
Select _"Place 35 Apexis Shards into the prism."_ |gossip 35752
kill Mo'arg Incinerator##23354
|tip Intended for a group.
collect Fel Whip##32733 |q 11079/1 |goto Blade's Edge Mountains/0 33.9,44.2
step
talk Gahk##23300
turnin A Fel Whip For Gahk##11079 |goto Blade's Edge Mountains/0 28.48,58.08
step
Reach Friendly Reputation with Ogri'la |complete rep("Ogri'la") >= Friendly
|tip Use the "Ogri'la Daily Quests" guide to accomplish this.
Click Here to Load the {o}Ogri'la Daily Quests{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Ogri'la\\Ogri'la Daily Quests"
step
talk Chu'a'lor##23233
accept A Special Thank You##11091 |goto Blade's Edge Mountains/0 28.76,57.37
step
talk Jho'nass##23428
turnin A Special Thank You##11091 |goto Blade's Edge Mountains/0 27.99,58.86
step
Reach Honored Reputation with Ogri'la |complete rep("Ogri'la") >= Honored
|tip Use the "Ogri'la Daily Quests" guide to accomplish this.
Click Here to Load the {o}Ogri'la Daily Quests{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Ogri'la\\Ogri'la Daily Quests"
step
talk Kronk##23253
accept Banish the Demons##11026 |goto Blade's Edge Mountains/0 28.89,57.90
step
use the Banishing Crystal##32696
|tip Enemies must die near the portal you summon.
kill Abyssal Flamebringer##19973, Fear Fiend##22204, Wrath Speaker##22195, Furnace Guard##22291, Wrath Hound##20557
Banish #15# Demons |q 11026/1 |goto Blade's Edge Mountains/0 32.74,44.94
|mapmarker Blade's Edge Mountains/0 32.10,42.58
|mapmarker Blade's Edge Mountains/0 31.40,40.45
|mapmarker Blade's Edge Mountains/0 32.48,38.85
|mapmarker Blade's Edge Mountains/0 34.20,38.29
|mapmarker Blade's Edge Mountains/0 34.66,40.01
|mapmarker Blade's Edge Mountains/0 34.89,42.55
|mapmarker Blade's Edge Mountains/0 36.54,41.13
|mapmarker Blade's Edge Mountains/0 36.28,37.33
|mapmarker Blade's Edge Mountains/0 28.33,76.82
|mapmarker Blade's Edge Mountains/0 28.69,78.43
|mapmarker Blade's Edge Mountains/0 28.30,80.95
|mapmarker Blade's Edge Mountains/0 28.90,83.18
|mapmarker Blade's Edge Mountains/0 29.00,85.27
|mapmarker Blade's Edge Mountains/0 30.34,83.49
|mapmarker Blade's Edge Mountains/0 30.33,80.93
|mapmarker Blade's Edge Mountains/0 30.05,78.43
|mapmarker Blade's Edge Mountains/0 28.71,78.06
step
talk Kronk##23253
turnin Banish the Demons##11026 |goto Blade's Edge Mountains/0 28.89,57.90
step
Reach Exalted Reputation with Ogri'la |complete rep("Ogri'la") >= Exalted
|tip Use the "Ogri'la Daily Quests" guide to accomplish this.
Click Here to Load the {o}Ogri'la Daily Quests{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Ogri'la\\Ogri'la Daily Quests"
]])
ZygorGuidesViewer:RegisterGuide("Reputations Guides\\The Burning Crusade\\The Consortium",{
author="support@zygorguides.com",
description="\nThis guide will walk you through becoming exalted with The Consortium faction.",
patch='30003',
},[[
step
talk Consortium Recruiter##18335
accept The Consortium Needs You!##9913 |goto Nagrand/0 51.94,34.78
|tip Be careful to avoid the Horde guards nearby. |only if Alliance
step
kill Wild Elekk##18334+
|tip Elephants.
collect 3 Pair of Ivory Tusks##25463 |goto Nagrand/0 69.40,54.00 |q 9914 |future
|tip Don't vendor them.
|mapmarker Nagrand/0 64.60,65.60
|mapmarker Nagrand/0 66.80,60.00
|mapmarker Nagrand/0 70.60,67.60
|mapmarker Nagrand/0 70.60,69.80
|mapmarker Nagrand/0 70.60,72.60
|mapmarker Nagrand/0 68.20,71.20
|mapmarker Nagrand/0 66.40,68.80
|mapmarker Nagrand/0 68.40,67.00
|mapmarker Nagrand/0 67.00,62.80
|mapmarker Nagrand/0 73.80,58.40
|mapmarker Nagrand/0 71.60,55.80
|mapmarker Nagrand/0 72.00,50.80
|mapmarker Nagrand/0 72.80,44.60
|mapmarker Nagrand/0 72.60,37.40
|mapmarker Nagrand/0 68.80,40.00
|mapmarker Nagrand/0 65.60,37.40
|mapmarker Nagrand/0 62.60,35.40
|mapmarker Nagrand/0 60.40,39.00
|mapmarker Nagrand/0 61.00,43.00
|mapmarker Nagrand/0 60.40,47.00
|mapmarker Nagrand/0 60.60,49.40
|mapmarker Nagrand/0 63.80,51.40
|mapmarker Nagrand/0 65.60,46.00
|mapmarker Nagrand/0 64.60,43.20
|mapmarker Nagrand/0 69.40,47.00
|mapmarker Nagrand/0 69.40,60.80
|mapmarker Nagrand/0 66.00,51.00
step
talk Shadrek##18333
accept A Head Full of Ivory##9914 |goto Nagrand/0 31.77,56.78
step
talk Shadrek##18333
turnin A Head Full of Ivory##9914 |goto Nagrand/0 31.77,56.78
step
talk Gezhe##18265
turnin The Consortium Needs You!##9913 |goto Nagrand/0 31.36,57.80
accept Stealing from Thieves##9882 |goto Nagrand/0 31.36,57.80
step
talk Zerid##18276
accept Gava'xi##9900 |goto Nagrand/0 30.78,58.14
accept Matters of Security##9925 |goto Nagrand/0 30.78,58.14
stickystart "Kill_Voidspawns"
stickystart "Collect_Oshugun_Crystal_Fragments"
step
kill Gava'xi##18298 |q 9900/1 |goto Nagrand/0 42.40,73.49
|tip Mummy.
|tip Walks around.
|tip Spawns on the hill.
|mapmarker Nagrand/0 41.40,71.20
|mapmarker Nagrand/0 42.60,72.40
step
label "Collect_Oshugun_Crystal_Fragments"
kill Vir'aani Raider##17149+
|tip Mummies.
click Oshu'gun Crystal Fragment##182258+
|tip Green and white crystals.
collect 10 Oshu'gun Crystal Fragment##25416 |q 9882/1 |goto Nagrand/0 41.70,71.20
|mapmarker Nagrand/0 30.20,76.50
|mapmarker Nagrand/0 34.40,63.50
|mapmarker Nagrand/0 34.80,75.80
|mapmarker Nagrand/0 36.60,66.70
|mapmarker Nagrand/0 39.00,72.40
step
label "Kill_Voidspawns"
kill 12 Voidspawn##17981 |q 9925/1 |goto Nagrand/0 39.60,65.20
|tip Voidwalkers.
|mapmarker Nagrand/0 30.20,73.40
|mapmarker Nagrand/0 30.40,66.40
|mapmarker Nagrand/0 31.20,75.60
|mapmarker Nagrand/0 31.40,77.80
|mapmarker Nagrand/0 31.80,69.00
|mapmarker Nagrand/0 32.60,71.40
|mapmarker Nagrand/0 33.20,65.20
|mapmarker Nagrand/0 33.80,76.40
|mapmarker Nagrand/0 35.20,65.40
|mapmarker Nagrand/0 36.40,79.20
|mapmarker Nagrand/0 36.60,77.00
|mapmarker Nagrand/0 37.40,65.80
|mapmarker Nagrand/0 38.40,62.80
|mapmarker Nagrand/0 38.80,79.20
|mapmarker Nagrand/0 39.00,75.00
|mapmarker Nagrand/0 39.40,68.40
|mapmarker Nagrand/0 40.00,70.40
|mapmarker Nagrand/0 40.00,77.40
|mapmarker Nagrand/0 41.00,74.00
|mapmarker Nagrand/0 41.20,62.40
|mapmarker Nagrand/0 41.40,66.60
kill Voidspawn##17981+ |q 9925/1 |goto Nagrand 36.2,65.5
You can find more around [Nagrand 37.9,66.1]
step
talk Gezhe##18265
turnin Stealing from Thieves##9882 |goto Nagrand/0 31.36,57.80
step
talk Zerid##18276
turnin Gava'xi##9900 |goto Nagrand/0 30.78,58.14
turnin Matters of Security##9925 |goto Nagrand/0 30.78,58.14
step
label "Friendly_Rep_Farm"
kill Vir'aani Raider##17149+
|tip Mummies.
click Oshu'gun Crystal Fragment##182258+
|tip Green and white crystals.
collect Oshu'gun Crystal Fragment##25416 |n |goto Nagrand/0 41.70,71.20
|tip It takes 10 to gain 250 Rep.
|tip Look at how much rep you need, then gather enough to reach {o}Friendly{}.
|mapmarker Nagrand/0 30.20,76.50
|mapmarker Nagrand/0 34.40,63.50
|mapmarker Nagrand/0 34.80,75.80
|mapmarker Nagrand/0 36.60,66.70
|mapmarker Nagrand/0 39.00,72.40
Click Here to Turn In Your Fragments |confirm |or
Reach {o}Friendly{} Reputation with the Consortium |complete rep('The Consortium')>=Friendly |or
step
talk Gezhe##18265
accept More Crystal Fragments##9883 |goto Nagrand/0 31.36,57.80
Click Here to Continue Farming |next "Friendly_Rep_Farm" |confirm |only if rep("The Consortium")<=Neutral
Reach {o}Friendly{} Reputation with The Consortium |complete rep('The Consortium')>=Friendly |or
step
talk Shadrek##18333
turnin A Head Full of Ivory##9914 |goto Nagrand/0 31.77,56.78
step
talk Gezhe##18265
accept Membership Benefits##9886 |goto Nagrand/0 31.36,57.80
accept Obsidian Warbeads##9893 |goto Nagrand/0 31.36,57.80
step
kill Boulderfist Crusher##17134, Boulderfist Mystic##17135, Warmaul Brute##18065, Warmaul Warlock##18037, Warmaul Shaman##18064, Warmaul Reaver##17138
collect 10 Obsidian Warbeads##25433 |q 9893/1 |goto Nagrand/0 73.80,71.00
|mapmarker Nagrand/0 72.40,70.20
|mapmarker Nagrand/0 73.60,68.20
|mapmarker Nagrand/0 73.80,62.40
|mapmarker Nagrand/0 74.40,69.60
|mapmarker Nagrand/0 75.60,64.80
|mapmarker Nagrand/0 75.60,68.00
|mapmarker Nagrand/0 49.94,56.62
|mapmarker Nagrand/0 40.75,31.57
|mapmarker Nagrand/0 24.10,30.69
|mapmarker Nagrand/0 25.85,23.85
|mapmarker Nagrand/0 26.85,23.10
|mapmarker Nagrand/0 26.11,21.23
|mapmarker Nagrand/0 27.19,18.84
|mapmarker Nagrand/0 42.85,21.33
|mapmarker Nagrand/0 42.64,22.70
|mapmarker Nagrand/0 43.87,21.83
|mapmarker Nagrand/0 44.64,20.86
|mapmarker Nagrand/0 46.14,19.54
|mapmarker Nagrand/0 45.79,21.47
|mapmarker Nagrand/0 46.09,23.93
|mapmarker Nagrand/0 47.32,23.72
|mapmarker Nagrand/0 49.15,21.86
step
talk Gezhe##18265
turnin Obsidian Warbeads##9893 |goto Nagrand/0 31.36,57.80
step
label "Collect_Obsidian_Warbeads"
kill Boulderfist Crusher##17134, Boulderfist Mystic##17135, Warmaul Brute##18065, Warmaul Warlock##18037, Warmaul Shaman##18064, Warmaul Reaver##17138
collect Obsidian Warbeads##25433 |n |goto Nagrand/0 73.80,71.00
|tip It takes 10 to gain 250 Rep.
|tip Look at how much rep you need, then gather enough to reach {o}Honored{}.
|tip Don't vendor them.
|mapmarker Nagrand/0 72.40,70.20
|mapmarker Nagrand/0 73.60,68.20
|mapmarker Nagrand/0 73.80,62.40
|mapmarker Nagrand/0 74.40,69.60
|mapmarker Nagrand/0 75.60,64.80
|mapmarker Nagrand/0 75.60,68.00
|mapmarker Nagrand/0 49.94,56.62
|mapmarker Nagrand/0 40.75,31.57
|mapmarker Nagrand/0 24.10,30.69
|mapmarker Nagrand/0 25.85,23.85
|mapmarker Nagrand/0 26.85,23.10
|mapmarker Nagrand/0 26.11,21.23
|mapmarker Nagrand/0 27.19,18.84
|mapmarker Nagrand/0 42.85,21.33
|mapmarker Nagrand/0 42.64,22.70
|mapmarker Nagrand/0 43.87,21.83
|mapmarker Nagrand/0 44.64,20.86
|mapmarker Nagrand/0 46.14,19.54
|mapmarker Nagrand/0 45.79,21.47
|mapmarker Nagrand/0 46.09,23.93
|mapmarker Nagrand/0 47.32,23.72
|mapmarker Nagrand/0 49.15,21.86
Click Here to Continue|confirm |or
Reach {o}Honored{} Reputation with The Consortium |complete rep('The Consortium')>=Honored |or
step
talk Gezhe##18265
accept More Obsidian Warbeads##9892 |goto Nagrand/0 31.36,57.80
Click Here to Farm More Warbeads |next "Collect_Obsidian_Warbeads" |confirm |only if rep("The Consortium")<=Friendly
Reach {o}Honored{} Reputation with The Consortium |complete rep('The Consortium')>=Honored |next
step
talk Nether-Stalker Khay'ji##19880
accept Consortium Crystal Collection##10265 |goto Netherstorm/0 32.44,64.20
step
kill Pentatharon##20215
collect Arklon Crystal Artifact##28829 |q 10265/1 |goto Netherstorm/0 42.46,72.75
step
talk Nether-Stalker Khay'ji##19880
turnin Consortium Crystal Collection##10265 |goto Netherstorm/0 32.44,64.20
accept A Heap of Ethereals##10262 |goto Netherstorm/0 32.44,64.20
step
kill Zaxxis Raider##18875, Zaxxis Stalker##19642
collect 10 Zaxxis Insignia##29209 |q 10262/1 |goto Netherstorm/0 29.80,75.60
|mapmarker Netherstorm/0 28.20,77.00
|mapmarker Netherstorm/0 28.20,79.40
|mapmarker Netherstorm/0 30.40,78.20
|mapmarker Netherstorm/0 31.60,74.40
step
talk Nether-Stalker Khay'ji##19880
turnin A Heap of Ethereals##10262 |goto Netherstorm/0 32.44,64.20
accept Warp-Raider Nesaad##10205 |goto Netherstorm/0 32.44,64.20
step
kill Warp-Raider Nesaad##19641 |q 10205/1 |goto Netherstorm 28.27,79.60
step
talk Nether-Stalker Khay'ji##19880
turnin Warp-Raider Nesaad##10205 |goto Netherstorm/0 32.44,64.20
accept Request for Assistance##10266 |goto Netherstorm/0 32.44,64.20
step
talk Gahruj##20066
turnin Request for Assistance##10266 |goto Netherstorm/0 46.67,56.95
accept Rightful Repossession##10267 |goto Netherstorm/0 46.67,56.95
accept Drijya Needs Your Help##10311 |goto Netherstorm/0 46.67,56.95
step
talk Mehrdad##20810
accept Run a Diagnostic!##10417 |goto Netherstorm/0 46.45,56.41
accept New Opportunities##10348 |goto Netherstorm/0 46.45,56.41
stickystart "Collect_Ivory_Bells"
step
click Diagnostic Equipment##184589
collect Diagnostic Results##29741 |q 10417/1 |goto Netherstorm/0 48.21,55.00
step
talk Mehrdad##20810
turnin Run a Diagnostic!##10417 |goto Netherstorm/0 46.45,56.41
accept Deal With the Saboteurs##10418 |goto Netherstorm/0 46.45,56.41
step
kill 8 Barbscale Crocolisk##20773+ |q 10418/1 |goto Netherstorm/0 46.40,54.60
|mapmarker Netherstorm/0 45.20,51.40
|mapmarker Netherstorm/0 45.40,49.80
|mapmarker Netherstorm/0 45.60,53.00
|mapmarker Netherstorm/0 46.80,51.40
|mapmarker Netherstorm/0 47.80,53.80
step
label "Collect_Ivory_Bells"
click Ivory Bell##184443+
|tip Pink drooping flowers.
collect 15 Ivory Bell##29474 |q 10348/1 |goto Netherstorm/0 44.30,56.70
|mapmarker Netherstorm/0 42.80,51.20
|mapmarker Netherstorm/0 42.90,55.10
|mapmarker Netherstorm/0 43.90,48.60
|mapmarker Netherstorm/0 44.80,51.00
|mapmarker Netherstorm/0 45.40,53.20
|mapmarker Netherstorm/0 45.90,48.10
|mapmarker Netherstorm/0 46.30,57.50
|mapmarker Netherstorm/0 46.80,50.20
|mapmarker Netherstorm/0 47.70,55.20
|mapmarker Netherstorm/0 48.10,51.80
step
click Box Surveying Equipment##184031+
|tip Silver metal boxes.
collect 10 Box of Surveying Equipment##28913 |q 10267/1 |goto Netherstorm/0 58.50,62.90
|mapmarker Netherstorm/0 56.80,64.10
|mapmarker Netherstorm/0 57.00,65.70
|mapmarker Netherstorm/0 58.70,66.80
|mapmarker Netherstorm/0 60.00,66.00
step
talk Mehrdad##20810
turnin Run a Diagnostic!##10417 |goto Netherstorm/0 46.45,56.41
step
talk Mehrdad##20810
turnin Deal With the Saboteurs##10418 |goto Netherstorm/0 46.45,56.41
turnin New Opportunities##10348 |goto Netherstorm/0 46.45,56.41
accept To the Stormspire##10423 |goto Netherstorm/0 46.45,56.41
step
talk Gahruj##20066
turnin Rightful Repossession##10267 |goto Netherstorm/0 46.67,56.95
accept An Audience with the Prince##10268 |goto Netherstorm/0 46.67,56.95
step
talk Drijya##20281
turnin Drijya Needs Your Help##10311 |goto Netherstorm/0 48.11,63.50
accept Sabotage the Warp-Gate!##10310 |goto Netherstorm/0 48.11,63.50
step
Follow Drijya
kill Terror Imp##20399, Warp-Gate Engineer##20404, Legion Shocktrooper##20402, Legion Destroyer##20403
|tip Protect him from enemies that attack.
|tip You will be attacked each time Drijya stops.
Sabotage the Legion Warp-Gate |q 10310/1
|mapmarker Netherstorm/0 49.43,64.72
|mapmarker Netherstorm/0 50.02,65.46
|mapmarker Netherstorm/0 49.40,65.85
step
talk Gahruj##20066
turnin Sabotage the Warp-Gate!##10310 |goto Netherstorm/0 46.67,56.95
step
talk Ghabar##20811
turnin To the Stormspire##10423 |goto Netherstorm/0 43.53,35.14
accept Diagnosis: Critical##10424 |goto Netherstorm/0 43.53,35.14
step
talk Image of Nexus-Prince Haramad##20084
|tip Inside the building.
turnin An Audience with the Prince##10268 |goto Netherstorm/0 45.87,35.97
accept Triangulation Point One##10269 |goto Netherstorm/0 45.87,35.97
step
use Diagnostic Device##29803
collect Diagnostic Results##29769 |q 10424/1 |goto Netherstorm/0 47.63,26.80
step
talk Ghabar##20811
turnin Diagnosis: Critical##10424 |goto Netherstorm/0 43.54,35.15
accept Testing the Prototype##10430 |goto Netherstorm/0 43.54,35.15
step
talk Tashar##20913
turnin Testing the Prototype##10430 |goto Netherstorm/0 44.69,14.57
accept All Clear!##10436 |goto Netherstorm/0 44.69,14.57
step
kill 12 Scythetooth Raptor##20634+ |q 10436/1 |goto Netherstorm/0 45.20,11.20
|mapmarker Netherstorm/0 43.20,12.60
|mapmarker Netherstorm/0 45.00,8.40
|mapmarker Netherstorm/0 45.20,13.20
|mapmarker Netherstorm/0 47.00,10.00
|mapmarker Netherstorm/0 47.20,12.20
step
talk Tashar##20913
turnin All Clear!##10436 |goto Netherstorm/0 44.69,14.57
Watch the dialogue
accept Success!##10440 |goto Netherstorm/0 44.69,14.57
step
talk Ghabar##20811
turnin Success!##10440 |goto Netherstorm/0 43.54,35.15
step
use Triangulation Device##28962
|tip Run toward the red arrow.
|tip Appears nearby.
Discover the First Triangulation Point |q 10269/1 |goto Netherstorm/0 66.85,34.22
step
talk Dealer Hazzin##20092
turnin Triangulation Point One##10269 |goto Netherstorm/0 58.35,31.26
accept Triangulation Point Two##10275 |goto Netherstorm/0 58.35,31.26
step
talk Wind Trader Marid##20071
accept A Not-So-Modest Proposal##10270 |goto Netherstorm/0 58.31,31.65
step
talk Flesh Handler Viridius##20450
|tip Walks around.
accept Captain Tyralius##10422 |goto Netherstorm/0 60.06,32.57
|mapmarker Netherstorm/0 59.19,32.12
|mapmarker Netherstorm/0 58.59,31.76
step
talk Researcher Navuud##20449
accept Electro-Shock Goodness!##10411 |goto Netherstorm/0 59.25,32.57
step
talk Commander Ameer##20448
accept The Ethereum##10339 |goto Netherstorm/0 59.50,32.39
step
talk Professor Dabiri##20907
accept Recipe for Destruction##10437 |goto Netherstorm/0 60.10,31.73
stickystart "Kill_Ethereum_Shocktroopers"
stickystart "Kill_Ethereum_Researchers"
stickystart "Kill_Ethereum_Assassins"
step
Follow the path down |goto Netherstorm/0 57.21,32.58 < 20 |only if walking
kill Captain Zovax##20727 |q 10339/4 |goto Netherstorm/0 57.12,36.39
|tip Walks around.
step
label "Kill_Ethereum_Assassins"
kill 5 Ethereum Assassin##20452 |q 10339/1 |goto Netherstorm/0 56.47,38.93
step
label "Kill_Ethereum_Shocktroopers"
kill 5 Ethereum Shocktrooper##20453 |q 10339/2 |goto Netherstorm/0 57.12,36.39
step
label "Kill_Ethereum_Researchers"
kill 2 Ethereum Researcher##20456 |q 10339/3 |goto Netherstorm/0 57.12,36.39
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
turnin The Ethereum##10339 |goto Netherstorm/0 56.81,38.69
accept Ethereum Data##10384 |goto Netherstorm/0 56.81,38.69
step
click Ethereum Data Cell##184560
collect Ethereum Data Cell##29582 |q 10384/1 |goto Netherstorm/0 55.77,39.89
stickystart "Kill_Void_Waste_Globules"
step
kill Warden Icoshock##20770
|tip Walks around.
collect The Warden's Key##29742 |goto Netherstorm/0 55.00,41.60 |q 10422
|mapmarker Netherstorm/0 54.00,41.80
|mapmarker Netherstorm/0 54.40,40.20
step
click Captain Tyralius's Prison
Free Captain Tyralius |q 10422/1 |goto Netherstorm/0 53.33,41.48
step
use Navuud's Concoction##29737
Gain the Electro-Shock Therapy Buff |havebuff Electro-Shock Therapy##35685 |q 10411
step
label "Kill_Void_Waste_Globules"
kill Void Waste##20778+
|tip Oozes.
|tip Globules appear.
kill 30 Void Waste Globule##20805 |q 10411/2 |goto Netherstorm/0 56.40,38.40
|mapmarker Netherstorm/0 54.40,44.20
|mapmarker Netherstorm/0 55.00,41.40
|mapmarker Netherstorm/0 55.80,43.60
|mapmarker Netherstorm/0 56.40,45.00
|mapmarker Netherstorm/0 56.60,41.00
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
turnin Ethereum Data##10384 |goto Netherstorm/0 56.81,38.69
accept Potential for Brain Damage = High##10385 |goto Netherstorm/0 56.81,38.69
step
kill Ethereum Assassin##20452, Ethereum Researcher##20456, Ethereum Shocktrooper##20453
collect Ethereum Essence##29482+ |n
use Ethereum Essence##29482+
|tip This will allow you to see Ethereum Relays around this area.
|tip The effect only lasts for 1 minute, so you will need multiple.
kill Ethereum Relay##20619+
collect 15 Ethereum Relay Data##29459 |q 10385/1 |goto Netherstorm/0 55.72,40.82
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
turnin Potential for Brain Damage = High##10385 |goto Netherstorm/0 56.81,38.69
accept S-A-B-O-T-A-G-E##10405 |goto Netherstorm/0 56.81,38.69
step
kill Ethereum Archon##20458, Ethereum Overlord##20459
|tip Only Ethereum Overlords and Ethereum Archons will drop the quest item.
collect Prepared Ethereum Wrapping##29591 |q 10405/1 |goto Netherstorm/0 55.79,43.63
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
turnin S-A-B-O-T-A-G-E##10405 |goto Netherstorm/0 56.81,38.69
accept Delivering the Message##10406 |goto Netherstorm/0 56.81,38.69
step
Follow the Protectorate Demolitionist
|tip Kill enemies that attack him.
Sabotage the Ethereum Conduit |q 10406/1 |goto Netherstorm/0 56.63,42.60
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
turnin Delivering the Message##10406 |goto Netherstorm/0 56.81,38.69
step
kill Ethereum Archon##20458, Ethereum Overlord##20459
|tip This will cause the Ethereum Gladiator to spawn eventually.
kill Ethereum Gladiator##20854
|tip He will spawn at the same time as a Captured Protectorate Vanguard.
|tip The Ethereum Gladiator will attack the Captured Protectorate Vanguard.
|tip Protect the Captured Protectorate Vanguard.
talk Captured Protectorate Vanguard##20763
accept Escape from the Staging Grounds##10425 |goto Netherstorm/0 57.05,37.62
step
Follow the Captured Protectorate Vanguard
|tip Protect him as you follow.
Escort the Captured Protectorate Vanguard |q 10425/1
step
talk Commander Ameer##20448
turnin Escape from the Staging Grounds##10425 |goto Netherstorm/0 59.50,32.39
step
talk Flesh Handler Viridius##20450
|tip Walks around.
turnin Captain Tyralius##10422 |goto Netherstorm/0 60.06,32.57
|mapmarker Netherstorm/0 59.19,32.12
|mapmarker Netherstorm/0 58.59,31.76
step
use Navuud's Concoction##29737
Gain the Electro-Shock Therapy Buff |havebuff Electro-Shock Therapy##35685 |q 10411
stickystart "Kill_Seeping_Sludge_Globules"
step
kill Unstable Voidwraith##18869, Voidshrieker##18870
|tip Unstable Voidwraiths and Voidshriekers.
|tip Voidwalkers.
collect 8 Fragment of Dimensius##29822 |q 10437/1 |goto Netherstorm/0 62.80,35.40
|mapmarker Netherstorm/0 59.40,42.40
|mapmarker Netherstorm/0 60.40,39.40
|mapmarker Netherstorm/0 61.40,37.40
|mapmarker Netherstorm/0 61.80,40.40
|mapmarker Netherstorm/0 65.40,42.20
|mapmarker Netherstorm/0 65.60,38.60
|mapmarker Netherstorm/0 65.60,44.00
|mapmarker Netherstorm/0 66.80,43.00
step
label "Kill_Seeping_Sludge_Globules"
kill Seeping Sludge##20501+
|tip Oozes.
|tip Globules appear.
kill 30 Seeping Sludge Globule##20806 |q 10411/1 |goto Netherstorm/0 63.60,35.40
|mapmarker Netherstorm/0 57.40,39.20
|mapmarker Netherstorm/0 59.60,40.00
|mapmarker Netherstorm/0 60.80,42.40
|mapmarker Netherstorm/0 63.00,37.80
|mapmarker Netherstorm/0 63.20,44.20
|mapmarker Netherstorm/0 63.20,47.80
|mapmarker Netherstorm/0 63.80,42.80
|mapmarker Netherstorm/0 64.40,39.20
|mapmarker Netherstorm/0 65.80,41.80
step
talk Agent Araxes##20551
accept The Flesh Lies...##10345 |goto Netherstorm/0 59.42,45.04
stickystart "Burn_Withered_Corpses"
step
Enter the mine |goto Netherstorm/0 61.06,45.44 < 15 |walk |only if not (subzone("Access Shaft Zeon") and indoors())
Follow the path |goto Netherstorm/0 60.92,44.49 < 10 |walk
Follow the path |goto Netherstorm/0 60.11,43.49 < 10 |walk
talk Agent Ya-six##20552
|tip Downstairs inside the mine.
accept Arconus the Insatiable##10353 |goto Netherstorm/0 60.92,41.53
step
click Teleporter Power Pack##184075
|tip Inside the mine.
collect Teleporter Power Pack##28969 |q 10270/1 |goto Netherstorm/0 60.96,41.53
step
kill Arconus the Insatiable##20554 |q 10353/1 |goto Netherstorm/0 60.14,39.87
|tip Walks around.
|tip Upstairs inside the mine.
step
label "Burn_Withered_Corpses"
use Protectorate Igniter##29473
|tip On Withered Corpses.
|tip Dead blood elves.
|tip {o}Keep distance{} or they attack.
|tip Inside and outside the mine.
Burn #12# Withered Corpses |q 10345/1 |goto Netherstorm/0 61.06,45.44
|mapmarker Netherstorm/0 59.40,43.60
|mapmarker Netherstorm/0 60.20,40.20
|mapmarker Netherstorm/0 60.20,42.00
|mapmarker Netherstorm/0 60.60,46.80
|mapmarker Netherstorm/0 61.60,43.60
step
Leave the mine |goto Netherstorm/0 61.06,45.44 < 15 |walk |only if subzone("Access Shaft Zeon") and indoors()
talk Agent Araxes##20551
turnin The Flesh Lies...##10345 |goto Netherstorm/0 59.42,45.04
step
talk Researcher Navuud##20449
turnin Electro-Shock Goodness!##10411 |goto Netherstorm/0 59.25,32.57
step
talk Commander Ameer##20448
turnin Arconus the Insatiable##10353 |goto Netherstorm/0 59.50,32.39
step
talk Professor Dabiri##20907
turnin Recipe for Destruction##10437 |goto Netherstorm/0 60.10,31.73
accept On Nethery Wings##10438 |goto Netherstorm/0 60.10,31.73
step
talk Protectorate Nether Drake##20903
Select _"I'm ready to fly! Take me up, dragon!"_ |gossip 118470
Begin Flying with the Nether Drake |invehicle |goto Netherstorm/0 60.21,31.76 |q 10438
step
use Phase Disruptor##29778
|tip Repeatedly while flying.
|tip Top of Manaforge Ultris.
Destroy the Void Conduit |q 10438/1 |goto Netherstorm/0 62.45,40.90 |notravel
step
talk Professor Dabiri##20907
turnin On Nethery Wings##10438 |goto Netherstorm/0 60.10,31.73
accept Dimensius the All-Devouring##10439 |goto Netherstorm/0 60.10,31.73
|tip This quest is intended for a group.
step
talk Captain Saeed##20985
Select _"I am that fleshling, Saeed. Let's go!"_ |gossip 33088
Speak to Captain Saeed |q 10439/1 |goto Netherstorm/0 60.64,32.07
step
Follow Captain Saeed
kill Dimensius the All-Devouring##19554 |q 10439/2 |goto Netherstorm/0 62.4,40.8
|tip Inside the building.
step
talk Professor Dabiri##20907
turnin Dimensius the All-Devouring##10439 |goto Netherstorm/0 60.10,31.73
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
accept Nexus-King Salhadaar##10408 |goto Netherstorm/0 56.81,38.69
|tip This quest is intended for a group.
step
use Protectorate Disruptor##29618
|tip Use it next to any of the giant tubes with energy running through them nearby.
Watch the dialogue
kill Nexus-King Salhadaar##20454 |q 10408/1 |goto Netherstorm/0 52.89,42.34
|tip This enemy is elite and may require a group.
step
click Ethereum Transponder Zeta
talk Image of Commander Ameer##20482
turnin Nexus-King Salhadaar##10408 |goto Netherstorm/0 56.81,38.69
step
talk Zuben Elgenubi##20067
accept In Search of Farahlite##10290 |goto Netherstorm/0 44.08,36.05
step
click Ethereal Teleport Pad
|tip Follow the road down.
talk Image of Wind Trader Marid##20518
Select _"Attempt to contact Wind Trader Marid."_ |gossip 118445
turnin A Not-So-Modest Proposal##10270 |goto Netherstorm/0 71.14,38.99
step
Follow the path up |goto Netherstorm/0 29.58,41.34 < 30 |only if walking
use Triangulation Device##29018
|tip Run toward the red arrow.
|tip Appears nearby.
Discover the Second Triangulation Point |q 10275/1 |goto Netherstorm/0 29.03,40.72
step
talk Wind Trader Tuluman##20112
turnin Triangulation Point Two##10275 |goto Netherstorm/0 34.62,37.95
accept Full Triangle##10276 |goto Netherstorm/0 34.62,37.95
|tip This quest is intended for a group.
step
kill Farahlon Breaker##18886+
collect 4 Raw Farahlite##29163 |q 10290/1 |goto Netherstorm/0 44.5,21.6
|mapmarker Netherstorm/0 41.4,28.6
|mapmarker Netherstorm/0 43.6,24.0
|mapmarker Netherstorm/0 46.0,16.4
|mapmarker Netherstorm/0 52.8,16.6
|mapmarker Netherstorm/0 56.8,19.0
step
talk Zuben Elgenubi##20067
turnin In Search of Farahlite##10290 |goto Netherstorm/0 44.08,36.05
step
kill Culuthas##20138
|tip Intended for a group.
collect Ata'mal Crystal##29026 |q 10276/1 |goto Netherstorm/0 53.51,21.54
step
talk Image of Nexus-Prince Haramad##20084
|tip Inside the building.
turnin Full Triangle##10276 |goto Netherstorm/0 45.87,35.97
step
talk Zephyrion##20470
accept Surveying the Ruins##10335 |goto Netherstorm/0 44.7,34.9
step
talk Nether-Stalker Nauthis##20471
accept The Minions of Culuthas##10336 |goto Netherstorm/0 44.7,34.9
accept Fel Reavers, No Thanks!##10855 |goto Netherstorm/0 44.7,34.9
step
kill Gan'arg Mekgineer##16949+
collect 5 Condensed Nether Gas##31653 |q 10855 |goto Netherstorm/0 39.1,28.9
step
talk Inactive Fel Reaver##22293
|tip Complete the {g}Nether Gas In a Fel Fire Engine{} repeatable quest.
Watch the dialogue
Destroy the Inactive Fel Reaver |q 10855/1 |goto Netherstorm/0 35.86,28.84
stickystart "Kill_Eyes_And_Hounds_Of_Culuthas"
step
use Surveying Markers##29445
|tip Follow the road.
Place Surveying Marker One |q 10335/1 |goto Netherstorm/0 51.66,20.49
step
use Surveying Markers##29445
Place Surveying Marker Two |q 10335/2 |goto Netherstorm/0 54.56,22.82
step
use Surveying Markers##29445
Place Surveying Marker Three |q 10335/3 |goto Netherstorm/0 55.81,19.93
step
label "Kill_Eyes_And_Hounds_Of_Culuthas"
kill 5 Eye of Culuthas##20394 |q 10336/2 |goto Netherstorm/0 51.80,21.40
kill 10 Hound of Culuthas##20141 |q 10336/1 |goto Netherstorm/0 51.80,21.40
|mapmarker Netherstorm/0 49.40,22.40
|mapmarker Netherstorm/0 50.40,24.60
|mapmarker Netherstorm/0 51.20,19.40
|mapmarker Netherstorm/0 53.00,23.00
|mapmarker Netherstorm/0 53.80,20.00
|mapmarker Netherstorm/0 54.80,22.00
|mapmarker Netherstorm/0 54.80,25.00
|mapmarker Netherstorm/0 56.80,22.00
|mapmarker Netherstorm/0 56.80,24.60
step
talk Zephyrion##20470
turnin Surveying the Ruins##10335 |goto Netherstorm/0 44.72,34.86
step
talk Nether-Stalker Nauthis##20471
turnin The Minions of Culuthas##10336 |goto Netherstorm/0 44.70,34.94
turnin Fel Reavers, No Thanks!##10855 |goto Netherstorm/0 44.70,34.94
accept The Best Defense##10856 |goto Netherstorm/0 44.70,34.94
step
label "Kill_Wrathbringers"
kill 12 Wrathbringer##18858 |q 10856/1 |goto Netherstorm/0 40.20,25.40
|mapmarker Netherstorm/0 36.00,18.20
|mapmarker Netherstorm/0 37.40,21.40
|mapmarker Netherstorm/0 39.00,18.20
|mapmarker Netherstorm/0 39.40,23.40
|mapmarker Netherstorm/0 39.60,20.60
|mapmarker Netherstorm/0 41.40,17.80
|mapmarker Netherstorm/0 41.40,23.40
|mapmarker Netherstorm/0 42.00,20.60
step
talk Nether-Stalker Nauthis##20471
turnin The Best Defense##10856 |goto Netherstorm/0 44.70,34.94
accept Teleport This!##10857 |goto Netherstorm/0 44.70,34.94
step
use Mental Interference Rod##31678
|tip On a Cyber-Rage Forgelord.
|tip Stand near this structure and use item.
|tip Dismiss your pet.			|only if Warlock or Hunter
Destroy the Western Teleporter |q 10857/1 |goto Netherstorm/0 39.18,20.43
|tip Use the {o}Detonate Teleporter{} ability.
step
use Mental Interference Rod##31678
|tip On a Cyber-Rage Forgelord.
|tip Stand near this structure and use item.
|tip Dismiss your pet.			|only if Warlock or Hunter
Destroy the Central Teleporter |q 10857/2 |goto Netherstorm/0 41.08,19.42
|tip Use the {o}Detonate Teleporter{} ability.
step
use Mental Interference Rod##31678
|tip On a Cyber-Rage Forgelord.
|tip Stand near this structure and use item.
|tip Dismiss your pet.			|only if Warlock or Hunter
Destroy the Eastern Teleporter |q 10857/3 |goto Netherstorm/0 42.28,21.07
|tip Use the {o}Detonate Teleporter{} ability.
step
talk Nether-Stalker Nauthis##20471
turnin Teleport This!##10857 |goto Netherstorm/0 44.70,34.94
step
talk Commander Ameer##20448
accept A Mission of Mercy##10970 |goto Netherstorm/0 59.50,32.39
step
kill Ethereum Assassin##20452, Ethereum Shocktrooper##20453, Ethereum Researcher##20456
collect Salvaged Ethereum Prison Key##31956 |q 10970/1 |goto Netherstorm/0 56.47,38.93
step
talk Commander Ameer##20448
turnin A Mission of Mercy##10970 |goto Netherstorm/0 59.50,32.39
step
talk Commander Ameer##20448
turnin A Mission of Mercy##10970 |goto Netherstorm/0 59.50,32.39
accept Ethereum Secrets##10971 |goto Netherstorm/0 59.50,32.39
step
kill Ethereum Assassin##20452, Ethereum Shocktrooper##20453, Ethereum Researcher##20456
collect Ethereum Prison Key##29460 |goto Netherstorm/0 56.47,38.93
|tip This has a low drop rate.
|tip You can also buy them from the Auction House.
step
click Ethereum Prison##7183
kill Armbreaker Huffaz##20520
|tip Kill whatever attacks you.
collect Ethereum Prisoner I.D. Tag##31957 |q 10971/1 |goto Netherstorm/0 54.51,46.45
step
talk Commander Ameer##20448
turnin Ethereum Secrets##10971 |goto Netherstorm/0 59.50,32.39
step
label "Rep_Grind"
From here, you will need to grind for reputation
|tip You can run Heroic Mana-Tombs and kill every mob in the instance.
Click here to farm "Obsidian Warbeads" |confirm |next "Warbeads"
Click here to farm "Zaxxis Insignia" |confirm |next "Zaxxis_Insignia"
Click here to farm "Ethereum Prisoner I.D.'s" |confirm
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted"
step
label "Ethereum_Prisoner_ID"
kill Ethereum Assassin##20452, Ethereum Shocktrooper##20453, Ethereum Researcher##20456
collect Ethereum Prison Key##29460 |goto Netherstorm/0 56.47,38.93 |n
|tip These have a low drop rate.
|tip You can also buy them from the Auction House.
|confirm |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
click Ethereum Prison##7183
|tip You may be attacked.
|tip If you aren't attacked, you will recieve 500 rep.
|tip It's completely random.
kill Armbreaker Huffaz##20520, Wrathbringer Laz-tarash##20520, Malevus the Mad##20520, Porfus the Gem Gorger##20520, Gul'bor##20520, Fel Tinkerer Zortan##20520, Forgosh##20520
|tip Kill whatever attacks you.
collect Ethereum Prisoner I.D. Tag##31957 |goto Netherstorm/0 54.64,40.16 |n
|mapmarker Netherstorm/0 54.51,46.45
|tip These will give 250 rep per turn in.
|confirm |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
talk Commander Ameer##20448
accept Ethereum Prisoner I.D. Catalogue##10972 |goto Netherstorm/0 59.50,32.39
|tip Repeatable
Click Here to Farm More Keys |confirm |next "Ethereum_Prisoner_ID" |or
Click Here to Change the Grind Step |confirm |next "Rep_Grind" |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
label "Zaxxis_Insignia"
kill Zaxxis Raider##18875, Zaxxis Stalker##19642
collect Zaxxis Insignia##29209 |goto Netherstorm/0 29.80,75.60 |n
|tip Collect them in multiples of 10.
|tip Every 10 nets 250 rep.
|mapmarker Netherstorm/0 28.20,77.00
|mapmarker Netherstorm/0 28.20,79.40
|mapmarker Netherstorm/0 30.40,78.20
|mapmarker Netherstorm/0 31.60,74.40
|confirm |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
talk Nether-Stalker Khay'ji##19880
accept Another Heap of Ethereals##10308 |goto Netherstorm/0 32.44,64.20
|tip Repeatable.
Click Here to Farm More Zaxxis Insignia |confirm |next "Zaxxis_Insignia" |or
Click Here to Change the Grind Step |confirm |next "Rep_Grind" |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
label "Warbeads"
kill Boulderfist Crusher##17134, Boulderfist Mystic##17135, Warmaul Brute##18065, Warmaul Warlock##18037, Warmaul Shaman##18064, Warmaul Reaver##17138
collect Obsidian Warbeads##25433 |n |goto Nagrand/0 73.80,71.00
|tip It takes 10 to gain 250 Rep.
|tip Look at how much rep you need, then gather enough to reach {o}Honored{}.
|tip Don't vendor them.
|mapmarker Nagrand/0 72.40,70.20
|mapmarker Nagrand/0 73.60,68.20
|mapmarker Nagrand/0 73.80,62.40
|mapmarker Nagrand/0 74.40,69.60
|mapmarker Nagrand/0 75.60,64.80
|mapmarker Nagrand/0 75.60,68.00
|mapmarker Nagrand/0 49.94,56.62
|mapmarker Nagrand/0 40.75,31.57
|mapmarker Nagrand/0 24.10,30.69
|mapmarker Nagrand/0 25.85,23.85
|mapmarker Nagrand/0 26.85,23.10
|mapmarker Nagrand/0 26.11,21.23
|mapmarker Nagrand/0 27.19,18.84
|mapmarker Nagrand/0 42.85,21.33
|mapmarker Nagrand/0 42.64,22.70
|mapmarker Nagrand/0 43.87,21.83
|mapmarker Nagrand/0 44.64,20.86
|mapmarker Nagrand/0 46.14,19.54
|mapmarker Nagrand/0 45.79,21.47
|mapmarker Nagrand/0 46.09,23.93
|mapmarker Nagrand/0 47.32,23.72
|mapmarker Nagrand/0 49.15,21.86
|confirm |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
talk Gezhe##18265
accept More Obsidian Warbeads##9892 |goto Nagrand/0 31.36,57.80
|tip Repeatable.
Click Here to Farm More Warbeads |confirm |next "Warbeads" |or
Click Here to Change the Grind Step |confirm |next "Rep_Grind" |or
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |next "Exalted" |or
step
label "Exalted"
Reach Exalted Reputation with The Consortium |complete rep('The Consortium')==Exalted |or
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Netherwing",{
author="support@zygorguides.com",
startlevel=25,
description="\nThis guide section will walk you through completing Netherwing quests from neutral to exalted.",
},[[
step
talk Mordenai##22113
|tip He walks along the path.
accept Kindness##10804 |goto Shadowmoon Valley/0 59.06,58.71
|mapmarker Shadowmoon Valley/0 60.74,58.84
|mapmarker Shadowmoon Valley/0 61.86,59.48
|mapmarker Shadowmoon Valley/0 63.19,60.30
step
kill Rocknail Flayer##21477, Rocknail Ripper##21478
|tip Watch for the netherdrake riding elite that walks around the area.
collect Rocknail Flayer Giblets##31373 |n
use the Rocknail Flayer Giblets##31373
|tip Combine 5 giblets into a carcass.
collect 8 Rocknail Flayer Carcass##31372 |goto Shadowmoon Valley/0 61.54,54.76 |q 10804
|mapmarker Shadowmoon Valley/0 62.83,54.36
|mapmarker Shadowmoon Valley/0 63.89,55.35
|mapmarker Shadowmoon Valley/0 63.27,58.58
|mapmarker Shadowmoon Valley/0 64.13,61.07
|mapmarker Shadowmoon Valley/0 62.33,60.58
|mapmarker Shadowmoon Valley/0 60.01,57.70
|mapmarker Shadowmoon Valley/0 58.59,57.00
|mapmarker Shadowmoon Valley/0 59.65,59.98
|mapmarker Shadowmoon Valley/0 58.10,59.05
step
use the Rocknail Flayer Carcass##31372
|tip Stand on tall rocks or crystals.
Watch the Dialogue
Feed #8# Netherwing Drakes |q 10804/1 |goto Shadowmoon Valley/0 62.99,58.07
step
talk Mordenai##22113
|tip He walks along the path.
turnin Kindness##10804 |goto Shadowmoon Valley/0 59.06,58.71
accept Seek Out Neltharaku##10811 |goto Shadowmoon Valley/0 59.06,58.71
|mapmarker Shadowmoon Valley/0 60.74,58.84
|mapmarker Shadowmoon Valley/0 61.86,59.48
|mapmarker Shadowmoon Valley/0 63.19,60.30
step
map Shadowmoon Valley/0
path Loop on; Follow Smart
path	60.33,53.99	58.71,53.30	57.64,53.41	57.19,55.26	57.36,57.15
path	59.14,58.40	60.60,59.53	62.18,60.07	63.87,61.42	65.85,60.68
path	70.72,64.01	71.97,62.09	70.79,59.59	68.55,58.40	66.90,57.90
path	65.57,57.23	63.68,56.24	62.77,55.63	61.71,54.87
Follow the path
talk Neltharaku##21657
|tip Flies slightly above the netherdrakes in the area.
turnin Seek Out Neltharaku##10811
accept Neltharaku's Tale##10814
step
map Shadowmoon Valley/0
path Loop on; Follow Smart
path	60.33,53.99	58.71,53.30	57.64,53.41	57.19,55.26	57.36,57.15
path	59.14,58.40	60.60,59.53	62.18,60.07	63.87,61.42	65.85,60.68
path	70.72,64.01	71.97,62.09	70.79,59.59	68.55,58.40	66.90,57.90
path	65.57,57.23	63.68,56.24	62.77,55.63	61.71,54.87
Follow the path
talk Neltharaku##21657
|tip Flies slightly above the netherdrakes in the area.
Select _"I am listening, dragon."_ |gossip 33282
Select _"But you are dragons! How could orcs do this to you?"_ |gossip 35333
Select _"Your mate?"_ |gossip 35332
Select _"I have battled many beasts, dragon. I will help you."_ |gossip 36214
Listen to the Tale of Neltharaku |q 10814/1
step
map Shadowmoon Valley/0
path Loop on; Follow Smart
path	60.33,53.99	58.71,53.30	57.64,53.41	57.19,55.26	57.36,57.15
path	59.14,58.40	60.60,59.53	62.18,60.07	63.87,61.42	65.85,60.68
path	70.72,64.01	71.97,62.09	70.79,59.59	68.55,58.40	66.90,57.90
path	65.57,57.23	63.68,56.24	62.77,55.63	61.71,54.87
Follow the path
talk Neltharaku##21657
|tip Flies slightly above the netherdrakes in the area.
turnin Neltharaku's Tale##10814
accept Infiltrating Dragonmaw Fortress##10836
step
kill Dragonmaw Wrangler##21717, Dragonmaw Subjugator##21718, Dragonmaw Drake-Rider##21719, Dragonmaw Shaman##21720
|tip Inside and outside of the buildings.
Slay #15# Dragonmaw Orcs |q 10836/1 |goto Shadowmoon Valley/0 67.18,60.66
|mapmarker Shadowmoon Valley/0 68.58,60.30
|mapmarker Shadowmoon Valley/0 69.08,58.68
|mapmarker Shadowmoon Valley/0 68.99,61.94
|mapmarker Shadowmoon Valley/0 69.94,63.16
|mapmarker Shadowmoon Valley/0 71.31,63.97
|mapmarker Shadowmoon Valley/0 71.84,61.87
step
map Shadowmoon Valley/0
path Loop on; Follow Smart
path	60.33,53.99	58.71,53.30	57.64,53.41	57.19,55.26	57.36,57.15
path	59.14,58.40	60.60,59.53	62.18,60.07	63.87,61.42	65.85,60.68
path	70.72,64.01	71.97,62.09	70.79,59.59	68.55,58.40	66.90,57.90
path	65.57,57.23	63.68,56.24	62.77,55.63	61.71,54.87
Follow the path
talk Neltharaku##21657
|tip Flies slightly above the netherdrakes in the area.
turnin Infiltrating Dragonmaw Fortress##10836
accept To Netherwing Ledge!##10837
step
click Nethervine Crystal##185182+
|tip They look like big thorns with a glowing red ball atop them on the ground around this area.
collect 12 Nethervine Crystal##31504 |q 10837/1 |goto Shadowmoon Valley/0 67.76,80.27
|mapmarker Shadowmoon Valley/0 65.14,83.40
|mapmarker Shadowmoon Valley/0 64.33,80.96
|mapmarker Shadowmoon Valley/0 63.73,82.67
|mapmarker Shadowmoon Valley/0 62.68,86.92
|mapmarker Shadowmoon Valley/0 65.72,88.65
|mapmarker Shadowmoon Valley/0 64.17,89.50
|mapmarker Shadowmoon Valley/0 62.77,90.66
|mapmarker Shadowmoon Valley/0 67.12,90.98
|mapmarker Shadowmoon Valley/0 67.61,89.98
|mapmarker Shadowmoon Valley/0 68.20,85.72
|mapmarker Shadowmoon Valley/0 68.71,79.72
|mapmarker Shadowmoon Valley/0 70.17,80.82
|mapmarker Shadowmoon Valley/0 71.63,80.13
|mapmarker Shadowmoon Valley/0 72.18,81.32
|mapmarker Shadowmoon Valley/0 73.07,81.32
|mapmarker Shadowmoon Valley/0 73.31,83.60
|mapmarker Shadowmoon Valley/0 74.39,81.60
|mapmarker Shadowmoon Valley/0 73.64,80.21
|mapmarker Shadowmoon Valley/0 76.78,84.36
|mapmarker Shadowmoon Valley/0 76.31,85.64
|mapmarker Shadowmoon Valley/0 77.41,82.06
|mapmarker Shadowmoon Valley/0 75.66,86.38
|mapmarker Shadowmoon Valley/0 76.32,86.98
|mapmarker Shadowmoon Valley/0 78.63,85.11
|mapmarker Shadowmoon Valley/0 78.46,87.05
|mapmarker Shadowmoon Valley/0 76.24,86.41
|mapmarker Shadowmoon Valley/0 74.15,90.51
|mapmarker Shadowmoon Valley/0 72.45,89.28
|mapmarker Shadowmoon Valley/0 70.06,91.80
|mapmarker Shadowmoon Valley/0 69.98,89.18
step
map Shadowmoon Valley/0
path Loop on; Follow Smart
path	60.33,53.99	58.71,53.30	57.64,53.41	57.19,55.26	57.36,57.15
path	59.14,58.40	60.60,59.53	62.18,60.07	63.87,61.42	65.85,60.68
path	70.72,64.01	71.97,62.09	70.79,59.59	68.55,58.40	66.90,57.90
path	65.57,57.23	63.68,56.24	62.77,55.63	61.71,54.87
Follow the path
talk Neltharaku##21657
|tip Flies slightly above the netherdrakes in the area.
turnin To Netherwing Ledge!##10837
accept The Force of Neltharaku##10854
step
use the Enchanted Nethervine Crystal##31652
|tip Use it on Enslaved Netherwing Drakes.
|tip Keep your distance, you won't be able to use it while in combat.
kill Dragonmaw Subjugator##21718
|tip Kill the Subjugator after the Netherwing Drake emotes.
Free #5# Enslaved Netherwing Drakes |q 10854/1 |goto Shadowmoon Valley/0 67.18,60.66
|mapmarker Shadowmoon Valley/0 68.58,60.30
|mapmarker Shadowmoon Valley/0 69.08,58.68
|mapmarker Shadowmoon Valley/0 68.99,61.94
|mapmarker Shadowmoon Valley/0 69.94,63.16
|mapmarker Shadowmoon Valley/0 71.31,63.97
|mapmarker Shadowmoon Valley/0 71.84,61.87
step
map Shadowmoon Valley/0
path Loop on; Follow Smart
path	60.33,53.99	58.71,53.30	57.64,53.41	57.19,55.26	57.36,57.15
path	59.14,58.40	60.60,59.53	62.18,60.07	63.87,61.42	65.85,60.68
path	70.72,64.01	71.97,62.09	70.79,59.59	68.55,58.40	66.90,57.90
path	65.57,57.23	63.68,56.24	62.77,55.63	61.71,54.87
Follow the path
talk Neltharaku##21657
|tip Flies slightly above the netherdrakes in the area.
turnin The Force of Neltharaku##10854
accept Karynaku##10858
step
talk Karynaku##22112
turnin Karynaku##10858 |goto Shadowmoon Valley/0 69.90,61.43
accept Zuluhed the Whacked##10866 |goto Shadowmoon Valley/0 69.90,61.43
|tip This quest is intended for a group.
step
kill Zuluhed the Whacked##11980 |q 10866/2 |goto Shadowmoon Valley/0 69.85,61.29
|tip This encounter is intended for a group.
collect Zuluhed's Key##31664 |q 10866 |goto Shadowmoon Valley/0 69.85,61.29
step
click Zuluhed's Chains##185156
Free Karynaku |q 10866/1 |goto Shadowmoon Valley/0 69.85,61.29
step
talk Karynaku##22112
turnin Zuluhed the Whacked##10866 |goto Shadowmoon Valley/0 69.90,61.43
accept Ally of the Netherwing##10870 |goto Shadowmoon Valley/0 69.90,61.43
|tip Karynaku will carry you off once you accept this quest.
step
Train Artisan Flying |complete skill("Riding") >= 225
|tip Flying is required to continue this questline.
step
talk Mordenai##22113
turnin Ally of the Netherwing##10870 |goto Shadowmoon Valley/0 59.32,58.69
accept Blood Oath of the Netherwing##11012 |goto Shadowmoon Valley/0 59.32,58.69
accept In Service of the Illidari##11013 |goto Shadowmoon Valley/0 59.32,58.69
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin In Service of the Illidari##11013 |goto Shadowmoon Valley/0 66.22,85.66
accept Enter the Taskmaster##11014 |goto Shadowmoon Valley/0 66.22,85.66
step
talk Taskmaster Varkule Dragonbreath##23140
turnin Enter the Taskmaster##11014 |goto Shadowmoon Valley/0 66.12,86.36
step
talk Yarzill the Merc##23141
accept Your Friend on the Inside##11019 |goto Shadowmoon Valley/0 66.00,86.46
accept The Great Netherwing Egg Hunt##11049 |goto Shadowmoon Valley/0 66.00,86.46
step
click Netherwing Egg
|tip Small dark eggs with blue crystals.
|tip They spawn all over Netherwing Ledge.
collect 1 Netherwing Egg##32506 |q 11049/1 |goto Shadowmoon Valley/0 67.76,80.27
|mapmarker Shadowmoon Valley/0 69.40,63.60
|mapmarker Shadowmoon Valley/0 70.10,62.00
|mapmarker Shadowmoon Valley/0 71.40,60.70
|mapmarker Shadowmoon Valley/0 70.90,62.60
|mapmarker Shadowmoon Valley/0 71.30,62.60
|mapmarker Shadowmoon Valley/0 71.40,60.80
|mapmarker Shadowmoon Valley/0 70.00,60.30
|mapmarker Shadowmoon Valley/0 69.70,58.50
|mapmarker Shadowmoon Valley/0 68.10,59.70
|mapmarker Shadowmoon Valley/0 68.30,59.80
|mapmarker Shadowmoon Valley/0 68.50,61.20
|mapmarker Shadowmoon Valley/0 67.20,61.30
|mapmarker Shadowmoon Valley/0 68.90,62.50
|mapmarker Shadowmoon Valley/0 76.00,81.20
|mapmarker Shadowmoon Valley/0 75.20,82.30
|mapmarker Shadowmoon Valley/0 73.70,82.30
|mapmarker Shadowmoon Valley/0 73.00,84.00
|mapmarker Shadowmoon Valley/0 71.00,81.50
|mapmarker Shadowmoon Valley/0 68.20,81.70
|mapmarker Shadowmoon Valley/0 66.20,83.80
|mapmarker Shadowmoon Valley/0 65.70,84.20
|mapmarker Shadowmoon Valley/0 63.30,81.50
|mapmarker Shadowmoon Valley/0 65.40,76.50
|mapmarker Shadowmoon Valley/0 63.20,75.60
|mapmarker Shadowmoon Valley/0 62.20,74.20
|mapmarker Shadowmoon Valley/0 61.70,73.30
|mapmarker Shadowmoon Valley/0 63.00,71.60
|mapmarker Shadowmoon Valley/0 61.30,70.70
|mapmarker Shadowmoon Valley/0 60.60,73.40
|mapmarker Shadowmoon Valley/0 59.30,74.10
|mapmarker Shadowmoon Valley/0 60.00,76.70
|mapmarker Shadowmoon Valley/0 59.60,78.30
|mapmarker Shadowmoon Valley/0 61.20,77.30
|mapmarker Shadowmoon Valley/0 62.20,77.80
|mapmarker Shadowmoon Valley/0 63.30,81.50
|mapmarker Shadowmoon Valley/0 63.00,83.70
|mapmarker Shadowmoon Valley/0 63.50,84.80
|mapmarker Shadowmoon Valley/0 65.50,84.90
|mapmarker Shadowmoon Valley/0 64.00,86.10
|mapmarker Shadowmoon Valley/0 62.50,84.90
|mapmarker Shadowmoon Valley/0 60.20,87.10
|mapmarker Shadowmoon Valley/0 62.10,89.50
|mapmarker Shadowmoon Valley/0 64.90,90.80
|mapmarker Shadowmoon Valley/0 64.80,87.20
|mapmarker Shadowmoon Valley/0 68.80,86.10
|mapmarker Shadowmoon Valley/0 72.30,87.30
|mapmarker Shadowmoon Valley/0 69.90,85.80
|mapmarker Shadowmoon Valley/0 73.60,85.20
|mapmarker Shadowmoon Valley/0 73.00,89.30
|mapmarker Shadowmoon Valley/0 73.60,85.20
|mapmarker Shadowmoon Valley/0 68.50,81.60
|mapmarker Shadowmoon Valley/0 64.80,83.00
|mapmarker Shadowmoon Valley/0 65.30,90.20
|mapmarker Shadowmoon Valley/0 65.50,94.20
|mapmarker Shadowmoon Valley/0 68.00,94.90
|mapmarker Shadowmoon Valley/0 69.60,91.80
|mapmarker Shadowmoon Valley/0 70.90,89.20
|mapmarker Shadowmoon Valley/0 71.40,86.60
|mapmarker Shadowmoon Valley/0 72.20,87.10
|mapmarker Shadowmoon Valley/0 73.40,90.30
|mapmarker Shadowmoon Valley/0 75.80,91.60
|mapmarker Shadowmoon Valley/0 77.60,92.60
|mapmarker Shadowmoon Valley/0 77.40,95.70
|mapmarker Shadowmoon Valley/0 77.30,85.90
|mapmarker Shadowmoon Valley/0 76.50,83.30
|mapmarker Shadowmoon Valley/0 78.90,83.30
|mapmarker Shadowmoon Valley/0 78.10,81.20
|mapmarker Shadowmoon Valley/0 78.80,79.60
step
talk Yarzill the Merc##23141
turnin The Great Netherwing Egg Hunt##11049 |goto Shadowmoon Valley/0 66.00,86.46
step
Reach Friendly with the Netherwing |complete rep("Netherwing") >= Friendly
|tip Use the "Netherwing Daily Quests" guide to accomplish this.
|tip You can also farm eggs using the "Netherwing Egg" guide.
Click Here to Load the {o}Netherwing Daily Quests{} Guide|confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Daily Quests"
Click Here to Load the {o}Netherwing Eggs{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Eggs"
step
talk Taskmaster Varkule Dragonbreath##23140
accept Rise, Overseer!##11053 |goto Shadowmoon Valley/0 66.12,86.36
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin Rise, Overseer!##11053 |goto Shadowmoon Valley/0 66.22,85.66
step
talk Taskmaster Varkule Dragonbreath##23140
accept The Netherwing Mines##11075 |goto Shadowmoon Valley/0 66.12,86.36
step
talk Chief Overseer Mudlump##23291
accept Overseeing and You: Making the Right Choices##11054 |goto Shadowmoon Valley/0 66.84,86.11
step
talk Mistress of the Mines##23149
turnin The Netherwing Mines##11075 |goto Shadowmoon Valley/0 65.38,90.17
step
Enter the mine |goto Shadowmoon Valley/0 65.33,89.74 < 5 |walk
talk Ronag the Slave Driver##23166
|tip Inside the mine.
accept Crazed and Confused##11083 |goto Shadowmoon Valley/0 71.58,87.62
stickystart "Kill_Crazed_Murkblood_Miners"
step
Follow the path up |goto Shadowmoon Valley/0 68.93,85.85 < 7 |walk
Follow the path |goto Shadowmoon Valley/0 70.31,85.88 < 7 |walk
Cross the tracks |goto Shadowmoon Valley/0 71.18,84.48 < 7 |walk
kill 1 Crazed Murkblood Foreman##23305 |q 11083/1 |goto Shadowmoon Valley/0 74.31,89.47
|tip Inside the mine.
|tip Keep an eye out for Netherwing Eggs while in the mine.
|mapmarker Shadowmoon Valley/0 72.66,90.05
step
label "Kill_Crazed_Murkblood_Miners"
kill 5 Crazed Murkblood Miner##23324+ |q 11083/2 |goto Shadowmoon Valley/0 72.87,89.36
|tip Inside the mine.
|tip Keep an eye out for Netherwing Eggs while in the mine.
|mapmarker Shadowmoon Valley/0 73.74,88.42
step
talk Ronag the Slave Driver##23166
|tip Inside the mine.
turnin Crazed and Confused##11083 |goto Shadowmoon Valley/0 71.58,87.62
step
kill Black Blood of Draenor##23286+
|tip Inside the mine.
collect Sludge-covered Object##32724 |n
use the Sludge-covered Object##32724
collect Murkblood Escape Plans##32726 |n
use the Murkblood Escape Plans##32726
accept The Great Murkblood Revolt##11081  |goto Shadowmoon Valley/0 68.85,84.89 |q 11081 |future
|mapmarker Shadowmoon Valley/0 70.55,88.08
|mapmarker Shadowmoon Valley/0 69.25,86.78
|mapmarker Shadowmoon Valley/0 68.52,86.66
step
Leave the mine |goto Shadowmoon Valley/0 63.17,87.70 < 5 |walk
talk Mistress of the Mines##23149
turnin The Great Murkblood Revolt##11081 |goto Shadowmoon Valley/0 63.05,87.74
accept Seeker of Truth##11082 |goto Shadowmoon Valley/0 63.05,87.74
step
Enter the mine |goto Shadowmoon Valley/0 63.17,87.70 < 5 |walk
Follow the path |goto Shadowmoon Valley/0 70.31,85.88 < 7 |walk
Cross the tracks |goto Shadowmoon Valley/0 71.18,84.48 < 7 |walk
talk Murkblood Overseer##23309
Select _"I am here for you, overseer."_ |gossip 37098
Select _"How dare you question an overseer of the Dragonmaw!"_ |gossip 34535
Select _"Who speaks of me? What are you talking about, broken?"_ |gossip 36632
Select _"Continue please."_ |gossip 34338
Select _"Who are these bidders?"_ |gossip 35029
Select _"Well... yes."_ |gossip 35028
Gather Information From the Murkblood Overseer |q 11082/2 |goto Shadowmoon Valley/0 72.97,82.17
step
Watch the dialogue
|tip Inside the mine.
collect Hand of the Overseer##32734 |q 11082/1 |goto Shadowmoon Valley/0 72.97,82.17
step
Leave the mine |goto Shadowmoon Valley/0 63.17,87.70 < 5 |walk
talk Mistress of the Mines##23149
turnin Seeker of Truth##11082 |goto Shadowmoon Valley/0 63.05,87.74
step
collect 10 Knothide Leather##21887 |q 11054/1
|tip If you have the skinning skill, refer to the {o}Knothide Leather{} farming guide to accomplish this.
|tip You can also buy them from the Auction House.
step
kill Tyrantus##20931
collect Hardened Hide of Tyrantus##32666 |q 11054/2 |goto Netherstorm/0 45.94,7.82
|mapmarker Netherstorm/0 45.98,13.15
|mapmarker Netherstorm/0 46.17,11.34
|mapmarker Netherstorm/0 46.22,9.35
step
talk Chief Overseer Mudlump##23291
turnin Overseeing and You: Making the Right Choices##11054 |goto Shadowmoon Valley/0 66.84,86.11
step
Reach Honored with the Netherwing |complete rep("Netherwing") >= Honored
|tip Use the "Netherwing Daily Quests" guide to accomplish this.
|tip You can also farm eggs using the "Netherwing Egg" guide.
Click Here to Load the {o}Netherwing Daily Quests{} Guide|confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Daily Quests"
Click Here to Load the {o}Netherwing Eggs{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Eggs"
step
talk Taskmaster Varkule Dragonbreath##23140
accept Stand Tall, Captain!##11084 |goto Shadowmoon Valley/0 66.12,86.36
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin Stand Tall, Captain!##11084 |goto Shadowmoon Valley/0 66.22,85.66
step
talk Ja'y Nosliw##22433
accept Earning Your Wings...##11063 |goto Shadowmoon Valley/0 65.89,87.17
step
talk Murg "Oldie" Muckjaw##23340
accept Dragonmaw Race: The Ballad of Oldie McOld##11064 |goto Shadowmoon Valley/0 65.17,85.65
step
Follow Murg "Oldie" Muckjaw
|tip Dodge the pumpkins that Murg throws at you.
|tip The easiest strategy is to fly behind and above him, so that you are looking down on him as you fly.
Defeat Murg "Oldie" Muckjaw |q 11064/1 |goto Shadowmoon Valley 65.2,85.7
step
talk Ja'y Nosliw##22433
turnin Dragonmaw Race: The Ballad of Oldie McOld##11064 |goto Shadowmoon Valley/0 65.89,87.17
step
talk Trope the Filth-Belcher##23342
accept Dragonmaw Race: Trope the Filth-Belcher##11067 |goto Shadowmoon Valley/0 65.16,85.46
step
Follow Trope the Filth-Belcher
|tip Dodge the green bombs that Trope the Filth-Belcher throws at you.
|tip The easiest strategy is to fly behind him.
|tip Strafe to the sides when he throws the bombs and you can dodge them easily.
Defeat Trope the Filth-Belcher |q 11067/1 |goto Shadowmoon Valley 65.2,85.5
step
talk Ja'y Nosliw##22433
turnin Dragonmaw Race: Trope the Filth-Belcher##11067 |goto Shadowmoon Valley/0 65.89,87.17
step
talk Corlok the Vet##23344
accept Dragonmaw Race: Corlok the Vet##11068 |goto Shadowmoon Valley/0 65.20,85.23
step
Follow Corlok the Vet
|tip Dodge the skulls that Corlok the Vet throws at you.
|tip Strafe to the sides when he throws the skulls and you can dodge them easily.
Defeat Corlok the Vet |q 11068/1 |goto Shadowmoon Valley 65.2,85.2
step
talk Ja'y Nosliw##22433
turnin Dragonmaw Race: Corlok the Vet##11068 |goto Shadowmoon Valley/0 65.89,87.17
step
talk Wing Commander Ichman##13437
accept Dragonmaw Race: Wing Commander Ichman##11069 |goto Shadowmoon Valley/0 65.18,85.05
step
Follow Wing Commander Ichman as he flies
|tip Dodge the fireballs that Wing Commander Ichman throws at you.
|tip The easiest strategy is to fly behind and far above him while looking down.
|tip Strafe to the sides when he throws fireballs and you can dodge them easily.
|tip He does sharp turns and maneuvers, so it's easy to lose track of him if you aren't careful.
Defeat Wing Commander Ichman |q 11069/1 |goto Shadowmoon Valley 65.2,85.0
step
talk Ja'y Nosliw##22433
turnin Dragonmaw Race: Wing Commander Ichman##11069 |goto Shadowmoon Valley/0 65.89,87.17
step
talk Wing Commander Mulverick##13181
accept Dragonmaw Race: Wing Commander Mulverick##11070 |goto Shadowmoon Valley/0 65.18,84.88
step
Follow Wing Commander Mulverick as he flies
|tip Dodge the lightning bolts that Wing Commander Mulverick throws at you.
|tip The lightning bolts will follow you, unlike the previous race quests.
|tip The easiest strategy is to fly beside him, while strafing, and almost ahead of him.
Defeat Wing Commander Mulverick |q 11070/1 |goto Shadowmoon Valley 65.2,84.9
step
talk Ja'y Nosliw##22433
turnin Dragonmaw Race: Wing Commander Mulverick##11070 |goto Shadowmoon Valley/0 65.89,87.17
step
talk Captain Skyshatter##23348
accept Dragonmaw Race: Captain Skyshatter##11071 |goto Shadowmoon Valley/0 65.46,85.28
step
Follow Captain Skyshatter as he flies
|tip Dodge the meteors that fall all around you.
|tip The easiest strategy is to fly beside him while strafing and almost ahead of him.
|tip Stay close to him and the meteors will hit both of you, stopping him for a second and allowing you to catch up to him if needed.
|tip Meteors will briefly stun you rather than dismount you.
Defeat Captain Skyshatter |q 11071/1 |goto Shadowmoon Valley 65.5,85.3
step
talk Ja'y Nosliw##22433
turnin Dragonmaw Race: Captain Skyshatter##11071 |goto Shadowmoon Valley/0 65.89,87.17
step
Reach Revered with the Netherwing |complete rep("Netherwing") >= Revered
|tip Use the "Netherwing Daily Quests" guide to accomplish this.
|tip You can also farm eggs using the "Netherwing Egg" guide.
Click Here to Load the {o}Netherwing Daily Quests{} Guide|confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Daily Quests"
Click Here to Load the {o}Netherwing Eggs{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Eggs"
step
Reach {g}Friendly{} Reputation with {o}The Scryers{} |complete rep("The Scryers") >= Friendly |only if rep("The Scryers") >= Neutral |or
|tip Refer to The Scryer reputation guide to accomplish this. |only if rep("The Scryers") >= Neutral
Click Here to Load {o}The Scryers{} Reputation Guide |confirm |loadguide "Reputation Guides\\The Burning Crusade\\The Scryers" |only if rep("The Scryers") >= Neutral |or
Reach {g}Friendly{} Reputation with {o}The Aldor{} |complete rep("The Aldor") >= Friendly |only if rep("The Aldor") >= Neutral |or
|tip Refer to The Aldor reputation guide to accomplish this. |only if rep("The Aldor") >= Neutral
Click Here to Load {o}The Aldor{} Reputation Guide |confirm |loadguide "Reputation Guides\\The Burning Crusade\\The Aldor" |only if rep("The Aldor") >= Neutral |or
step
talk Taskmaster Varkule Dragonbreath##23140
accept Hail, Commander!##11092 |goto Shadowmoon Valley/0 66.12,86.36
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin Hail, Commander!##11092
accept Kill Them All!##11094 |goto Shadowmoon Valley/0 66.22,85.66 |only if rep("The Scryers") >= Friendly
accept Kill Them All!##11099 |goto Shadowmoon Valley/0 66.22,85.66 |only if rep("The Aldor") >= Friendly
step
kill Arvoar the Rapacious##23267+
|tip Large flayer running in circles.
|tip Intended for a group.
collect Partially Digested Hand##32621 |n
use the Partially Digested Hand##32621
accept A Job Unfinished...##11041 |goto Shadowmoon Valley/0 74.53,86.41
stickystart "Kil_Overmine_Flayers"
step
kill Barash the Den Mother |q 11041/2 |goto Shadowmoon Valley/0 70.10,84.20
|tip Large flayer running in circles.
|tip Intended for a group.
step
label "Kil_Overmine_Flayers"
kill 10 Overmine Flayer##23264 |q 11041/1 |goto Shadowmoon Valley/0 70.10,84.20
mapmarker Shadowmoon Valley/0 74.53,86.41
|mapmarker Shadowmoon Valley/0 70.87,85.21
|mapmarker Shadowmoon Valley/0 73.75,85.61
|mapmarker Shadowmoon Valley/0 72.71,86.18
|mapmarker Shadowmoon Valley/0 71.85,85.88
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin A Job Unfinished...##11041 |goto Shadowmoon Valley/0 66.22,85.66
step
talk Arcanist Thelis##21955
turnin Kill Them All!##11094 |goto Shadowmoon Valley/0 56.25,59.60
accept Commander Hobb##11095 |goto Shadowmoon Valley/0 56.25,59.60
|only if rep("The Scryers") >= Friendly
step
talk Commander Hobb##23434
turnin Commander Hobb##11095 |goto Shadowmoon Valley/0 56.48,58.65
|only if rep("The Scryers") >= Friendly
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin Kill Them All!##11099 |goto Shadowmoon Valley/0 62.58,28.38
accept Commander Arcus##11100 |goto Shadowmoon Valley/0 62.58,28.38
|only if rep("The Aldor") >= Friendly
step
talk Commander Arcus##23452
turnin Commander Arcus##11100 |goto Shadowmoon Valley 62.4,29.3
|only if rep("The Aldor") >= Friendly
step
Reach Exalted with the Netherwing |complete rep("Netherwing") >= Exalted
|tip Use the "Netherwing Daily Quests" guide to accomplish this.
|tip You can also farm eggs using the "Netherwing Egg" guide.
Click Here to Load the {o}Netherwing Daily Quests{} Guide|confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Daily Quests"
Click Here to Load the {o}Netherwing Eggs{} Guide |confirm |loadguide "Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Eggs"
step
talk Taskmaster Varkule Dragonbreath##23140
accept Bow to the Highlord##11107 |goto Shadowmoon Valley/0 66.12,86.36
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin Bow to the Highlord##11107 |goto Shadowmoon Valley/0 66.22,85.66
accept Lord Illidan Stormrage##11108 |goto Shadowmoon Valley/0 66.22,85.66
step
Watch the dialogue
Meet with Illidan Stormrage |q 11108/1 |goto Shadowmoon Valley/0 65.94,86.08
step
Watch the dialogue
Arrive in Shattrath City |goto Shattrath City 65.8,18.6 < 200 |noway |c |q 11108
step
talk Barthamus##23433
turnin Lord Illidan Stormrage##11108 |goto Shattrath City/0 66.62,16.41
step
Pick your favorite Netherdrake:
accept Voranaku the Violet Netherwing Drake##11113 |goto Shattrath City 66.8,17.6 |noautoaccept |or
accept Zoya the Veridian Netherwing Drake##11114 |goto Shattrath City 66.8,17.6 |noautoaccept |or
accept Suraku the Azure Netherwing Drake##11112 |goto Shattrath City 66.8,17.6 |noautoaccept |or
accept Onyxien the Onyx Netherwing Drake##11111 |goto Shattrath City 66.8,17.6 |noautoaccept |or
accept Malfas the Purple Netherwing Drake##11110 |goto Shattrath City 66.8,17.6 |noautoaccept |or
accept Jorus the Cobalt Netherwing Drake##11109 |goto Shattrath City 66.8,17.6 |noautoaccept |or
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\The Aldor",{
author="support@zygorguides.com",
startlevel=60,
endlevel=70,
},[[
step
talk Haggard War Veteran##19684
|tip He walks along the bridge.
accept A'dal##10210 |goto Shattrath City/0 60.29,16.69
step
talk A'dal##18481
|tip Inside the building.
turnin A'dal##10210 |goto Shattrath City/0 54.00,44.71
step
talk Khadgar##18166
|tip Inside the building.
accept City of Light##10211 |goto Shattrath City/0 54.75,44.32
step
Follow Khadgar's Servant and listen to its story |q 10211/1
|tip Make sure you follow it or you will have to repeat this step.
|tip Marking it with a Raid Target Icon can help track it.
step
talk Khadgar##18166
|tip Inside the building.
turnin City of Light##10211 |goto Shattrath City/0 54.76,44.33
accept Allegiance to the Aldor##10551 |instant |goto Shattrath City/0 54.76,44.33
step
talk Khadgar##18166
|tip Inside the building.
accept Ishanah##10554 |goto Shattrath City/0 54.76,44.33
step
Ride the elevator up |goto Shattrath City/0 41.68,38.61 < 15 |only if walking
talk Vindicator Kaan##23271
accept Assist Exarch Orelis##11038 |goto Shattrath City/0 35.07,32.36
step
talk Adyen the Lightwarden##18537
accept Marks of Kil'jaeden##10325 |goto Shattrath City/0 30.73,34.63
accept Marks of Sargeras##10653 |goto Shattrath City/0 30.73,34.63
step
talk Ishanah##18538
|tip Inside the building.
turnin Ishanah##10554 |goto Shattrath City/0 23.96,29.70
accept Restoring the Light##10021 |goto Shattrath City/0 23.96,29.70
accept A Cleansing Light##10420 |goto Shattrath City/0 23.96,29.70
step
talk Sha'nir##18597
|tip Inside the building.
accept A Cure for Zahlia##10020 |goto Shattrath City/0 64.48,15.10
step
kill Cabal Skirmisher##21661, Cabal Spell-weaver##21902, Cabal Initiate##21907
collect 10 Mark of Kil'jaeden##29425 |q 10325 |goto Terokkar Forest/0 39.60,57.60
|mapmarker Terokkar Forest/0 39.60,55.20
|mapmarker Terokkar Forest/0 38.20,55.20
|mapmarker Terokkar Forest/0 37.40,57.60
|mapmarker Terokkar Forest/0 38.20,59.00
|mapmarker Terokkar Forest/0 40.60,59.60
|mapmarker Terokkar Forest/0 41.60,57.40
|mapmarker Terokkar Forest/0 41.20,56.00
step
click Eastern Altar##182565
Purify the Eastern Altar |q 10021/2 |goto Terokkar Forest/0 49.22,20.33
|only if rep('The Aldor') >= Neutral
step
click Northern Altar##182563
Purify the Northern Altar |q 10021/1 |goto Terokkar Forest/0 50.65,16.59
|only if rep('The Aldor') >= Neutral
step
click Western Altar##182566
Purify the Western Altar |q 10021/3 |goto Terokkar Forest/0 48.13,14.49
|only if rep('The Aldor') >= Neutral
step
kill Stonegazer##18648+
|tip Walks around the area.
|tip You may need help with this.
collect Stonegazer's Blood##25815 |q 10020/1 |goto Terokkar Forest/0 60.74,23.13
|mapmarker Terokkar Forest/0 61.50,25.39
|mapmarker Terokkar Forest/0 62.30,27.39
|mapmarker Terokkar Forest/0 63.30,28.38
|mapmarker Terokkar Forest/0 64.35,29.82
|mapmarker Terokkar Forest/0 66.04,30.45
|mapmarker Terokkar Forest/0 67.57,30.82
|mapmarker Terokkar Forest/0 68.60,31.26
|mapmarker Terokkar Forest/0 69.71,30.88
step
talk Sha'nir##18597
turnin A Cure for Zahlia##10020 |goto Shattrath City/0 64.48,15.10
step
Ride the elevator up |goto Shattrath City/0 41.68,38.61 < 15 |only if walking
talk Adyen the Lightwarden##18537
turnin Marks of Kil'jaeden##10325 |goto Shattrath City/0 30.76,34.63
|only if rep('The Aldor') >= Neutral
step
talk Ishanah##18538
|tip Inside the building.
turnin Restoring the Light##10021 |goto Shattrath City/0 23.96,29.70
step
talk Vindicator Kaan##23271
accept Assist Exarch Orelis##11038 |goto Shattrath City/0 35.06,32.36
step
talk Exarch Orelis##19466
|tip Inside the building.
turnin Assist Exarch Orelis##11038 |goto Netherstorm/0 32.07,64.17
accept Distraction at Manaforge B'naar##10241 |goto Netherstorm/0 32.07,64.17
step
kill 8 Sunfury Magister##18855 |q 10241/1 |goto Netherstorm/0 26.00,69.80
kill 8 Sunfury Bloodwarder##18853 |q 10241/2 |goto Netherstorm/0 26.00,69.80
|mapmarker Netherstorm/0 20.20,72.20
|mapmarker Netherstorm/0 20.60,69.20
|mapmarker Netherstorm/0 21.40,74.40
|mapmarker Netherstorm/0 23.00,65.80
|mapmarker Netherstorm/0 24.40,71.80
|mapmarker Netherstorm/0 26.20,66.40
|mapmarker Netherstorm/0 26.80,72.60
|mapmarker Netherstorm/0 28.00,64.80
step
talk Exarch Orelis##19466
|tip Inside the building.
turnin Distraction at Manaforge B'naar##10241 |goto Netherstorm/0 32.07,64.17
accept Measuring Warp Energies##10313 |goto Netherstorm/0 32.07,64.17
step
talk Anchorite Karja##19467
|tip Inside the building.
accept Naaru Technology##10243 |goto Netherstorm/0 32.03,64.18
step
use Warp-Attuned Orb##29324
Measure the Northern Pipeline |q 10313/1 |goto Netherstorm/0 25.71,60.61
step
use Warp-Attuned Orb##29324
Measure the Western Pipeline |q 10313/4 |goto Netherstorm/0 20.90,66.88
step
use Warp-Attuned Orb##29324
Measure the Southern Pipeline |q 10313/3 |goto Netherstorm/0 20.54,70.62
step
click B'naar Control Console##183770
|tip Inside the building.
turnin Naaru Technology##10243 |goto Netherstorm/0 23.17,68.17
accept B'naar Console Transcription##10245 |goto Netherstorm/0 23.17,68.17
step
use Warp-Attuned Orb##29324
Measure the Eastern Pipeline |q 10313/2 |goto Netherstorm/0 28.81,72.01
step
talk Exarch Orelis##19466
|tip Inside the building.
turnin Measuring Warp Energies##10313 |goto Netherstorm/0 32.07,64.17
step
talk Anchorite Karja##19467
|tip Inside the building.
turnin B'naar Console Transcription##10245 |goto Netherstorm/0 32.03,64.18
accept Shutting Down Manaforge B'naar##10299 |goto Netherstorm/0 32.03,64.18
step
kill Overseer Theredis##20416
|tip Walks around.
|tip Inside the building.
collect B'naar Access Crystal##29366 |q 10299/2 |goto Netherstorm/0 23.83,70.58
step
click B'naar Control Console##183770
|tip Inside the building.
Select _"<Begin emergency shutdown.>"_ |gossip 118578
Kill the enemies that attack in waves
|tip Takes {o}2 minutes{}.
Shut Down Manaforge B'naar |q 10299/1 |goto Netherstorm/0 23.18,68.16
step
talk Anchorite Karja##19467
|tip Inside the building.
turnin Shutting Down Manaforge B'naar##10299 |goto Netherstorm/0 32.03,64.18
accept Shutting Down Manaforge Coruu##10321 |goto Netherstorm/0 32.03,64.18
step
talk Exarch Orelis##19466
|tip Inside the building.
accept Attack on Manaforge Coruu##10246 |goto Netherstorm/0 32.07,64.17
stickystart "Kill_Sunfury_Arcanists_Aldor"
step
label "Kill_Sunfury_Researchers_Aldor"
kill 5 Sunfury Researcher##20136 |q 10246/1 |goto Netherstorm/0 51.40,86.40
|mapmarker Netherstorm/0 53.40,83.00
|mapmarker Netherstorm/0 53.60,87.20
step
label "Kill_Sunfury_Arcanists_Aldor"
kill 8 Sunfury Arcanist##20134 |q 10246/2 |goto Netherstorm/0 51.40,82.00
|mapmarker Netherstorm/0 46.00,81.00
|mapmarker Netherstorm/0 46.40,82.80
|mapmarker Netherstorm/0 47.60,79.40
|mapmarker Netherstorm/0 48.00,85.40
|mapmarker Netherstorm/0 49.20,79.00
|mapmarker Netherstorm/0 51.80,83.60
step
kill Overseer Seylanna##20397
|tip Inside the building.
collect Coruu Access Crystal##29396 |q 10321/2 |goto Netherstorm/0 49.02,81.51
step
click Coruu Control Console##183956
|tip Inside the building.
Select _"<Begin emergency shutdown.>"_ |gossip 118561
Kill the enemies that attack in waves
|tip Takes {o}2 minutes{}.
Shut Down Manaforge Coruu |q 10321/1 |goto Netherstorm/0 48.95,81.51
step
talk Anchorite Karja##19467
|tip Inside the building.
turnin Shutting Down Manaforge Coruu##10321 |goto Netherstorm/0 32.03,64.18
accept Shutting Down Manaforge Duro##10322 |goto Netherstorm/0 32.03,64.18
step
talk Exarch Orelis##19466
|tip Inside the building.
turnin Attack on Manaforge Coruu##10246 |goto Netherstorm/0 32.07,64.17
accept Sunfury Briefings##10328 |goto Netherstorm/0 32.07,64.17
stickystart "Collect_Sunfury_Military_Briefing_Aldor"
step
label "Collect_Sunfury_Arcane_Briefing_Aldor"
kill Sunfury Conjurer##20139+
collect Sunfury Arcane Briefing##29546 |q 10328/2 |goto Netherstorm/0 59.20,63.60
|mapmarker Netherstorm/0 56.40,63.80
|mapmarker Netherstorm/0 56.40,66.40
|mapmarker Netherstorm/0 57.40,67.20
|mapmarker Netherstorm/0 57.60,63.40
|mapmarker Netherstorm/0 58.80,62.40
|only if rep('The Aldor') >= Neutral
step
label "Collect_Sunfury_Military_Briefing_Aldor"
kill Sunfury Bowman##20207, Sunfury Centurions##20140
|tip Bowmen and Centurions.
collect Sunfury Military Briefing##29545 |q 10328/1 |goto Netherstorm/0 58.40,63.40
|mapmarker Netherstorm/0 56.60,65.00
|mapmarker Netherstorm/0 58.00,67.40
|mapmarker Netherstorm/0 59.00,66.40
|mapmarker Netherstorm/0 61.20,65.40
step
Enter the building |goto Netherstorm/0 58.76,64.20 < 7 |walk
kill Overseer Athanel##20435
|tip Inside the building.
collect Duro Access Crystal##29397 |q 10322/2 |goto Netherstorm/0 59.99,68.50
step
click Duro Control Console##184311
|tip Inside the building.
Choose _<Begin emergency shutdown.>_
Kill the enemies that attack in waves
|tip This takes 2 minutes.
Shut Down Manaforge Duro |q 10322/1 |goto Netherstorm/0 59.11,66.78
step
talk Exarch Orelis##19466
|tip Inside the building.
turnin Sunfury Briefings##10328 |goto Netherstorm/0 32.07,64.17
accept Outside Assistance##10431 |goto Netherstorm/0 32.07,64.17
step
talk Anchorite Karja##19467
|tip Inside the building.
turnin Shutting Down Manaforge Duro##10322 |goto Netherstorm/0 32.03,64.18
accept Shutting Down Manaforge Ara##10323 |goto Netherstorm/0 32.03,64.18
step
talk Kaylaan##20780
turnin Outside Assistance##10431 |goto Netherstorm/0 34.79,38.30
accept A Dark Pact##10380 |goto Netherstorm/0 34.79,38.30
step
label "Kill_Moarg_Warp_Masters_And_Ganarg_Warp_Tinkerers_Aldor"
kill 3 Mo'arg Warp-Master##20326 |q 10380/3 |goto Netherstorm/0 26.37,43.96
kill 6 Gan'arg Warp-Tinker##20285 |q 10380/1 |goto Netherstorm/0 26.37,43.96
|tip Inside the mine. |notinsticky
|mapmarker Netherstorm/0 24.00,40.40
|mapmarker Netherstorm/0 25.80,38.60
|mapmarker Netherstorm/0 26.20,40.60
|mapmarker Netherstorm/0 26.80,36.40
step
label "Kill_Daughters_Of_Destiny_Aldor"
kill 3 Daughter of Destiny##18860 |q 10380/2 |goto Netherstorm/0 30.40,39.40
|tip Outside the mine.
|mapmarker Netherstorm/0 27.80,36.40
|mapmarker Netherstorm/0 28.00,42.60
|mapmarker Netherstorm/0 28.20,40.00
|mapmarker Netherstorm/0 28.80,44.60
|mapmarker Netherstorm/0 30.20,41.60
step
kill Overseer Azarad##20685
|tip Walking around inside the building.
collect Ara Access Crystal##29411 |q 10323/2 |goto Netherstorm/0 26.7,36.8
step
click the Ara Control Console##184312
|tip Inside the building.
Select _"<Begin emergency shutdown.>"_ |gossip 33314
Kill the enemies that attack in waves
|tip Takes {o}2 minutes{}.
|tip Intended for a group.
Shut Down Manaforge Ara |q 10323/1  |goto Netherstorm/0 26.01,38.76
step
talk Kaylaan##20780
turnin A Dark Pact##10380 |goto Netherstorm/0 34.79,38.30
accept Aldor No More##10381 |goto Netherstorm/0 34.79,38.30
step
talk Exarch Orelis##19466
|tip Inside the building.
turnin Aldor No More##10381 |goto Netherstorm/0 32.07,64.17
step
talk Anchorite Karja##19467
|tip Inside the building.
turnin Shutting Down Manaforge Ara##10323 |goto Netherstorm/0 32.03,64.18
accept Socrethar's Shadow##10407 |goto Netherstorm/0 32.03,64.18
stickystart "Aldor_Rep_Items"
step
kill Forgemaster Morug##20800
|tip Intended for a group.
collect First Half of Socrethar's Stone##29624 |q 10407/1 |goto Netherstorm/0 36.84,27.78
step
kill Silroth##20801
|tip Intended for a group.
collect Second Half of Socrethar's Stone##29625 |q 10407/2 |goto Netherstorm/0 40.86,19.52
step
label "Aldor_Rep_Items"
kill Wrathbringer##18858, Cyber-Rage Forgelord##16943, Gan'arg Mekgineer##16949, Wrath Priestess##18859, Ironspine Forgelord##20928, Terrorguard Protector##21923
|tip Demons.
collect Fel Armament##29740		|goto Netherstorm/0 40.20,25.40 |q 10420 |future
collect 10 Mark of Sargeras##30809	|goto Netherstorm/0 40.20,25.40 |q 10653 |future
|tip Needed for future quests.
|mapmarker Netherstorm/0 36.00,18.20
|mapmarker Netherstorm/0 37.40,21.40
|mapmarker Netherstorm/0 39.00,18.20
|mapmarker Netherstorm/0 39.40,23.40
|mapmarker Netherstorm/0 39.60,20.60
|mapmarker Netherstorm/0 41.40,17.80
|mapmarker Netherstorm/0 41.40,23.40
|mapmarker Netherstorm/0 42.00,20.60
|mapmarker Netherstorm/0 39.00,26.63
|mapmarker Netherstorm/0 38.47,27.92
|mapmarker Netherstorm/0 38.55,29.72
|mapmarker Netherstorm/0 37.45,30.45
|mapmarker Netherstorm/0 36.63,29.30
|mapmarker Netherstorm/0 35.52,28.66
|mapmarker Netherstorm/0 36.00,27.45
|mapmarker Netherstorm/0 36.59,26.40
|mapmarker Netherstorm/0 37.49,28.04
step
talk Anchorite Karja##19467
|tip Inside the building.
turnin Socrethar's Shadow##10407 |goto Netherstorm/0 32.03,64.18
accept Ishanah's Help##10410 |goto Netherstorm/0 32.03,64.18
step
Ride the elevator up |goto Shattrath City/0 41.68,38.61 < 15 |only if walking
talk Adyen the Lightwarden##18537
turnin Marks of Sargeras##10653 |goto Shattrath City/0 30.73,34.63
step
talk Ishanah##18538
|tip Inside the building.
turnin Ishanah's Help##10410 |goto Shattrath City/0 23.96,29.70
turnin A Cleansing Light##10420 |goto Shattrath City/0 23.96,29.70
accept Deathblow to the Legion##10409 |goto Shattrath City/0 23.96,29.70
step
use Voren'thal's Package##30260
collect 1 Socrethar's Teleportation Stone##29796 |n
collect 1 Voren'thal's Presence##30259 |n
use Socrethar's Teleportation Stone##29796
click Portal to Socrethar's Seat |goto Netherstorm/0 36.44,18.36
|tip It appears after using the Teleportation stone.
Arrive at Socrethar's Seat |goto Netherstorm/0 30.57,17.68 < 50 |q 10409 |future |c
step
use Voren'thal's Presence##30259
|tip Use it on Socrethar.
kill Socrethar##20132 |q 10409/1 |goto Netherstorm/0 29.32,13.70
|tip Intended for a group.
step
talk Ishanah##18538
turnin Deathblow to the Legion##10409 |goto Shattrath City/0 23.96,29.70
step
talk Exarch Onaala##21860
accept Karabor Training Grounds##10587 |goto Shadowmoon Valley/0 61.20,29.23
step
talk Vindicator Aluumen##21822
accept The Ashtongue Tribe##10619 |goto Shadowmoon Valley/0 61.17,29.14
step
talk Anchorite Ceyla##21402
|tip Inside the building.
accept Tablets of Baa'ri##10568 |goto Shadowmoon Valley/0 62.58,28.38
stickystart "Kill_Ashtongue_Enemies_Aldor"
step
Enter the Ruins of Baa'ri |goto Shadowmoon Valley/0 60.95,37.34 < 40 |only if walking and not subzone("Ruins of Baa'ri")
kill Ashtongue Worker##21455+
click Baar'ri Tablet Fragment##184870+
|tip Broken stone pieces glowing green.
collect 12 Baa'ri Tablet Fragment##30596 |q 10568/1 |goto Shadowmoon Valley/0 56.60,37.50
|mapmarker Shadowmoon Valley/0 54.30,36.40
|mapmarker Shadowmoon Valley/0 54.70,38.90
|mapmarker Shadowmoon Valley/0 56.10,33.50
|mapmarker Shadowmoon Valley/0 56.70,40.00
|mapmarker Shadowmoon Valley/0 57.10,35.40
|mapmarker Shadowmoon Valley/0 58.40,38.70
|mapmarker Shadowmoon Valley/0 59.80,35.60
step
label "Kill_Ashtongue_Enemies_Aldor"
kill 3 Ashtongue Handler##21803 |q 10619/1 |goto Shadowmoon Valley/0 57.00,37.80
|tip Usually with elephants.
kill 4 Ashtongue Warrior##21454 |q 10619/2 |goto Shadowmoon Valley/0 57.00,37.80
kill 6 Ashtongue Shaman##21453 |q 10619/3 |goto Shadowmoon Valley/0 57.00,37.80
|mapmarker Shadowmoon Valley/0 54.80,36.80
|mapmarker Shadowmoon Valley/0 55.20,38.80
|mapmarker Shadowmoon Valley/0 56.00,33.40
|mapmarker Shadowmoon Valley/0 57.20,39.80
|mapmarker Shadowmoon Valley/0 57.80,34.80
|mapmarker Shadowmoon Valley/0 59.00,37.60
step
Follow the path up |goto Shadowmoon Valley/0 66.58,46.31 < 30 |only if walking and not subzone("Ruins of Karabor")
kill Demon Hunter Initiate##21180, Demon Hunter Supplicant##21179
collect 8 Sunfury Glaive##30679 |q 10587/1 |goto Shadowmoon Valley/0 68.00,54.00
|mapmarker Shadowmoon Valley/0 67.40,50.40
|mapmarker Shadowmoon Valley/0 68.40,48.40
|mapmarker Shadowmoon Valley/0 69.80,52.80
|mapmarker Shadowmoon Valley/0 70.20,50.20
|mapmarker Shadowmoon Valley/0 71.60,48.40
|mapmarker Shadowmoon Valley/0 72.00,52.40
step
talk Vindicator Aluumen##21822
turnin The Ashtongue Tribe##10619 |goto Shadowmoon Valley/0 61.17,29.14
accept Reclaiming Holy Grounds##10816 |goto Shadowmoon Valley/0 61.17,29.14
step
talk Exarch Onaala##21860
turnin Karabor Training Grounds##10587 |goto Shadowmoon Valley/0 61.20,29.23
accept A Necessary Distraction##10637 |goto Shadowmoon Valley/0 61.20,29.23
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin Tablets of Baa'ri##10568 |goto Shadowmoon Valley/0 62.58,28.38
accept Oronu the Elder##10571 |goto Shadowmoon Valley/0 62.58,28.38
step
kill Oronu the Elder##21663
collect Orders From Akama##30649 |q 10571/1 |goto Shadowmoon Valley/0 57.19,32.87
step
label "Kill_Shadowmoon_Enemies_Aldor"
kill 4 Shadowmoon Darkweaver##22081 |q 10816/3 |goto Shadowmoon Valley/0 68.40,37.40
kill 8 Shadowmoon Slayer##22082 |q 10816/1 |goto Shadowmoon Valley/0 68.40,37.40
kill 8 Shadowmoon Chosen##22084 |q 10816/2 |goto Shadowmoon Valley/0 68.40,37.40
|mapmarker Shadowmoon Valley/0 68.00,34.20
|mapmarker Shadowmoon Valley/0 68.20,40.00
|mapmarker Shadowmoon Valley/0 70.20,39.40
|mapmarker Shadowmoon Valley/0 70.40,35.40
|mapmarker Shadowmoon Valley/0 71.20,37.40
step
kill Sunfury Warlock##21503+
|tip Every warlock channeling needs to be killed.
collect Scroll of Demonic Unbanishing##30811 |n
use the Scroll of Demonic Unbanishing##30811
kill Azaloth##21506
|tip Use it on Azaloth.
Free Azaloth |q 10637/1 |goto Shadowmoon Valley/0 69.83,51.40
step
talk Exarch Onaala##21860
turnin A Necessary Distraction##10637 |goto Shadowmoon Valley/0 61.20,29.23
accept Altruis##10640 |goto Shadowmoon Valley/0 61.20,29.23
step
talk Vindicator Aluumen##21822
turnin Reclaiming Holy Grounds##10816 |goto Shadowmoon Valley/0 61.17,29.14
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin Oronu the Elder##10571 |goto Shadowmoon Valley/0 62.58,28.38
accept The Ashtongue Corruptors##10574 |goto Shadowmoon Valley/0 62.58,28.38
step
kill Corrupt Water Totem##21420
|tip You will be attacked.
kill Lakaan##21416
|tip Vulnerable after all the totems are destroyed.
collect Lakaan's Medallion Fragment##30693 |q 10574/3 |goto Shadowmoon Valley/0 49.88,23.00
step
kill Corrupt Fire Totem##21703
|tip You will be attacked.
kill Uylaru##21710
|tip Vulnerable after all the totems are destroyed.
collect Uylaru's Medallion Fragment##30694 |q 10574/4 |goto Shadowmoon Valley/0 48.29,39.56
step
kill Corrupt Earth Totem##21704
|tip You will be attacked.
kill Eykenen##21709
|tip Vulnerable after all the totems are destroyed.
collect Eykenen's Medallion Fragment##30692 |q 10574/1 |goto Shadowmoon Valley/0 51.17,52.82
step
kill Corrupt Air Totem##21705
|tip You will be attacked.
kill Haalum##21711
|tip Vulnerable after all the totems are destroyed.
collect Haalum's Medallion Fragment##30691 |q 10574/2 |goto Shadowmoon Valley/0 57.09,73.66
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin The Ashtongue Corruptors##10574 |goto Shadowmoon Valley/0 62.58,28.38
accept The Warden's Cage##10575 |goto Shadowmoon Valley/0 62.58,28.38
step
Follow the path down |goto Shadowmoon Valley/0 57.36,49.66 < 5 |walk
talk Sanoru##21826
|tip Downstairs.
turnin The Warden's Cage##10575 |goto Shadowmoon Valley/0 57.33,49.59
step
talk Altruis the Sufferer##18417
turnin Altruis##10640 |goto Nagrand/0 27.34,43.09
accept Against All Odds##10669 |goto Nagrand/0 27.34,43.09
accept Against the Illidari##10668 |goto Nagrand/0 27.34,43.09
accept Against the Legion##10641 |goto Nagrand/0 27.34,43.09
step
use the Imbued Silver Spear##30853
kill Xeleth##21894 |q 10669/1 |goto Zangarmarsh/0 16.21,40.68
step
kill Wrath Priestess##18859+
|tip There are several walking around this area.
collect Freshly Drawn Blood##30850 |n
use the Freshly Drawn Blood##30850
|tip It only lasts for a minute.
kill Avatar of Sathal##21925 |q 10641/1 |goto Netherstorm/0 39.72,20.78
|mapmarker Netherstorm/0 40.18,21.76
|mapmarker Netherstorm/0 41.16,22.03
|mapmarker Netherstorm/0 41.43,22.42
|mapmarker Netherstorm/0 41.38,23.26
|mapmarker Netherstorm/0 40.86,24.32
|mapmarker Netherstorm/0 40.16,24.40
|mapmarker Netherstorm/0 39.71,23.73
|mapmarker Netherstorm/0 39.59,22.78
|mapmarker Netherstorm/0 39.24,22.54
|mapmarker Netherstorm/0 38.81,21.20
|mapmarker Netherstorm/0 38.49,20.24
|mapmarker Netherstorm/0 37.95,18.77
|mapmarker Netherstorm/0 38.19,18.02
|mapmarker Netherstorm/0 39.33,18.35
step
kill Lothros##21928 |q 10668/1 |goto Shadowmoon Valley/0 28.20,48.90
|tip Walks around the area.
|mapmarker Shadowmoon Valley/0 28.31,50.40
|mapmarker Shadowmoon Valley/0 27.61,51.27
step
talk Altruis the Sufferer##18417
turnin Against the Legion##10641 |goto Nagrand/0 27.34,43.09
turnin Against the Illidari##10668 |goto Nagrand/0 27.34,43.09
turnin Against All Odds##10669 |goto Nagrand/0 27.34,43.09
accept Illidan's Pupil##10646 |goto Nagrand/0 27.34,43.09
step
talk Altruis the Sufferer##18417
Select _"Tell me about the demon hunter training grounds at the Ruins of Karabor."_ |gossip 34530
Select _"I'm listening."_ |gossip 34755
Select _"Go on, please."_ |gossip 33588
Select _"Interesting."_ |gossip 34692
Select _"That's quite a story."_ |gossip 33281
Listen to the Story of Illidan's Pupil |q 10646/1 |goto Nagrand/0 27.34,43.09
step
talk Altruis the Sufferer##18417
turnin Illidan's Pupil##10646 |goto Nagrand/0 27.34,43.09
accept The Book of Fel Names##10649 |goto Nagrand/0 27.34,43.09
step
Inside the Shadow Labyrinth Dungeon:
kill Blackheart the Inciter##18667
|tip Second boss.
|tip Clear the room before engaging, or every enemy will aggro.
collect 1 Book of Fel Names##30808|q 10649/1
step
talk Altruis the Sufferer##18417
turnin The Book of Fel Names##10649 |goto Nagrand/0 27.34,43.09
accept Return to the Aldor##10650 |goto Nagrand/0 27.34,43.09
step
talk Exarch Onaala##21860
turnin Return to the Aldor##10650 |goto Shadowmoon Valley/0 61.20,29.23
accept Varedis Must Be Stopped##10651 |goto Shadowmoon Valley/0 61.20,29.23
step
kill Netharel##21164 |q 10651/2 |goto Shadowmoon Valley/0 68.71,52.69
|tip Walks around the area.
|tip Intended for a group.
step
kill Alandien##21171 |q 10651/4 |goto Shadowmoon Valley/0 69.57,54.08
|tip Intended for a group.
step
kill Varedis##21178
|tip Inside the building.
|tip Intended for a group.
use the Book of Fel Names##30854
|tip Use it when Varedis is at low health.
Slay Varedis |q 10651/1 |goto Shadowmoon Valley/0 72.16,53.67
step
kill Theras##21168 |q 10651/3 |goto Shadowmoon Valley/0 72.35,48.38
|tip Intended for a group.
step
talk Exarch Onaala##21860
turnin Varedis Must Be Stopped##10651 |goto Shadowmoon Valley/0 61.20,29.23
step
label "farming"
kill Wrathbringer##18858, Cyber-Rage Forgelord##16943, Gan'arg Mekgineer##16949, Wrath Priestess##18859, Ironspine Forgelord##20928, Terrorguard Protector##21923
|tip Demons.
collect Fel Armament##29740		|goto Netherstorm/0 40.20,25.40 |n
|tip Each Fel Armament turn in nets 350 reputation.
collect Mark of Sargeras##30809	|goto Netherstorm/0 40.20,25.40 |n
|tip Every 10 Mark of Sargeras turned in nets 250 reputation.
|tip Needed for future quests.
|mapmarker Netherstorm/0 36.00,18.20
|mapmarker Netherstorm/0 37.40,21.40
|mapmarker Netherstorm/0 39.00,18.20
|mapmarker Netherstorm/0 39.40,23.40
|mapmarker Netherstorm/0 39.60,20.60
|mapmarker Netherstorm/0 41.40,17.80
|mapmarker Netherstorm/0 41.40,23.40
|mapmarker Netherstorm/0 42.00,20.60
|mapmarker Netherstorm/0 39.00,26.63
|mapmarker Netherstorm/0 38.47,27.92
|mapmarker Netherstorm/0 38.55,29.72
|mapmarker Netherstorm/0 37.45,30.45
|mapmarker Netherstorm/0 36.63,29.30
|mapmarker Netherstorm/0 35.52,28.66
|mapmarker Netherstorm/0 36.00,27.45
|mapmarker Netherstorm/0 36.59,26.40
|mapmarker Netherstorm/0 37.49,28.04
Click here to continue |confirm
step
talk Adyen the Lightwarden##18537
accept More Marks of Sargeras##10654 |n |goto Shattrath City/0 30.73,34.63
|tip
talk Ishanah##18538
|tip Inside the building.
accept Fel Armaments##10421 |n |goto Shattrath City/0 23.96,29.70
|tip
Reach Exalted reputation with The Aldor |complete rep('The Aldor')==Exalted |next
confirm |next "farming"
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\The Scryers",{
author="support@zygorguides.com",
startlevel=60,
endlevel=70,
},[[
step
talk Haggard War Veteran##19684
|tip He walks along the bridge.
accept A'dal##10210 |goto Shattrath City/0 60.29,16.69
step
talk A'dal##18481
|tip Inside the building.
turnin A'dal##10210 |goto Shattrath City/0 54.00,44.71
step
talk Khadgar##18166
|tip Inside the building.
accept City of Light##10211 |goto Shattrath City/0 54.75,44.32
step
Follow Khadgar's Servant and listen to its story |q 10211/1
|tip Make sure you follow it or you will have to repeat this step.
|tip Marking it with a Raid Target Icon can help track it.
step
talk Khadgar##18166
|tip Inside the building.
turnin City of Light##10211 |goto Shattrath City/0 54.76,44.33
accept Allegiance to the Scryers##10552 |instant |goto Shattrath City/0 54.76,44.33
step
talk Khadgar##18166
accept Voren'thal the Seer##10553 |goto Shattrath City/0 54.76,44.33
step
Ride the elevator up |goto Shattrath City/0 49.94,62.96 < 7 |n |only if walking
talk Magistrix Fyalenn##18531
accept Firewing Signets##10412 |goto Shattrath City/0 45.20,81.44
accept Sunfury Signets##10656 |goto Shattrath City/0 45.20,81.44
step
talk Voren'thal the Seer##18530
|tip Upstairs inside the building.
turnin Voren'thal the Seer##10553 |goto Shattrath City/0 42.79,91.71
accept Synthesis of Power##10416 |goto Shattrath City/0 42.79,91.71
step
talk Arcanist Savan##23272
accept Report to Spymaster Thalodien##11039 |goto Shattrath City/0 44.59,76.41
step
talk Spymaster Thalodien##19468
|tip Inside the building.
turnin Report to Spymaster Thalodien##11039 |goto Netherstorm/0 32.00,64.07
accept Manaforge B'naar##10189 |goto Netherstorm/0 32.00,64.07
step
kill Captain Arathyn##19635
|tip He walks around this area on a big purple bird.
collect B'naar Personnel Roster##28376 |q 10189/1 |goto Netherstorm/0 27.8,65
step
talk Spymaster Thalodien##19468
|tip Inside the building.
turnin Manaforge B'naar##10189 |goto Netherstorm/0 32.00,64.07
accept High Value Targets##10193 |goto Netherstorm/0 32.00,64.07
step
talk Magistrix Larynna##19469
|tip Inside the building.
accept Bloodgem Crystals##10204 |goto Netherstorm/0 32.05,64.00
only if rep ('The Scryers') >= Friendly
stickystart "Kill_Sunfury_Warp_Masters_Scryers"
stickystart "Kill_Sunfury_Geologists_Scryers"
stickystart "Collect_10_Sunfury_Signets"
step
kill Sunfury Magister##18855+
collect Bloodgem Shard##28452 |n
use Bloodgem Shard##28452
|tip Next to a large floating crystal.
Siphon the Bloodgem Crystal |q 10204/1 |goto Netherstorm/0 25.16,66.11
|mapmarker Netherstorm/0 26.06,68.38
step
kill 6 Sunfury Warp-Engineer##18852 |q 10193/2 |goto Netherstorm/0 23.60,69.20
|tip Inside the building.
|tip More outside.
|mapmarker Netherstorm/0 20.20,70.60
|mapmarker Netherstorm/0 20.40,67.40
|mapmarker Netherstorm/0 22.60,66.40
step
label "Kill_Sunfury_Warp_Masters_Scryers"
kill 2 Sunfury Warp-Master##18857 |q 10193/1 |goto Netherstorm/0 25.40,69.00
|mapmarker Netherstorm/0 20.20,70.60
|mapmarker Netherstorm/0 20.40,67.00
|mapmarker Netherstorm/0 22.40,73.40
|mapmarker Netherstorm/0 22.60,66.40
|mapmarker Netherstorm/0 23.00,68.80
|mapmarker Netherstorm/0 27.60,70.00
|mapmarker Netherstorm/0 28.60,71.80
step
label "Kill_Sunfury_Geologists_Scryers"
kill 8 Sunfury Geologist##19779 |q 10193/3 |goto Netherstorm/0 26.80,73.00
|mapmarker Netherstorm/0 22.40,72.40
|mapmarker Netherstorm/0 24.20,71.40
|mapmarker Netherstorm/0 24.40,65.40
|mapmarker Netherstorm/0 24.80,73.80
|mapmarker Netherstorm/0 25.20,68.00
|mapmarker Netherstorm/0 26.40,70.40
|mapmarker Netherstorm/0 28.40,70.80
|mapmarker Netherstorm/0 28.80,72.80
step
label "Collect_10_Sunfury_Signets"
kill Sunfury Geologist##19779, Sunfury Warp-Master##18857, Sunfury Warp-Engineer##18852
collect 10 Sunfury Signet##30810 |q 10656/1 |goto Netherstorm/0 26.80,73.00
collect 1 Arcane Tome##29739 |q 10416/1 |goto Netherstorm/0 26.80,73.00
|tip You can also buy them from the auction house. |notinsticky
|mapmarker Netherstorm/0 22.40,72.40
|mapmarker Netherstorm/0 24.20,71.40
|mapmarker Netherstorm/0 24.40,65.40
|mapmarker Netherstorm/0 24.80,73.80
|mapmarker Netherstorm/0 25.20,68.00
|mapmarker Netherstorm/0 26.40,70.40
|mapmarker Netherstorm/0 28.40,70.80
|mapmarker Netherstorm/0 28.80,72.80
|mapmarker Netherstorm/0 20.20,70.60
|mapmarker Netherstorm/0 20.40,67.00
|mapmarker Netherstorm/0 22.40,73.40
|mapmarker Netherstorm/0 22.60,66.40
|mapmarker Netherstorm/0 23.00,68.80
|mapmarker Netherstorm/0 27.60,70.00
|mapmarker Netherstorm/0 28.60,71.80
|mapmarker Netherstorm/0 25.40,69.00
|mapmarker Netherstorm/0 20.20,70.60
|mapmarker Netherstorm/0 20.40,67.40
|mapmarker Netherstorm/0 23.60,69.20
step
talk Spymaster Thalodien##19468
|tip Inside the building.
turnin High Value Targets##10193 |goto Netherstorm/0 32.00,64.07
accept Shutting Down Manaforge B'naar##10329 |goto Netherstorm/0 32.00,64.07
step
talk Magistrix Larynna##19469
|tip Inside the building.
turnin Bloodgem Crystals##10204 |goto Netherstorm/0 32.05,64.00
step
Inside Manaforge B'naar:
kill Overseer Theredis##20416
|tip Walking around inside the building.
collect B'naar Access Crystal##29366 |q 10329/2 |goto Netherstorm/0 23.85,70.62
step
kill Overseer Theredis##20416
|tip Walks around.
|tip Inside the building.
collect B'naar Access Crystal##29366 |q 10329/2 |goto Netherstorm/0 23.83,70.58
step
click B'naar Control Console##183770
|tip Inside the building.
Select _"<Begin emergency shutdown.>"_ |gossip 118578
Kill the enemies that attack in waves
|tip Takes {o}2 minutes{}.
Shut Down Manaforge B'naar |q 10329/1 |goto Netherstorm/0 23.18,68.16
step
talk Spymaster Thalodien##19468
|tip Inside the building.
turnin Shutting Down Manaforge B'naar##10329 |goto Netherstorm/0 32.00,64.07
accept Stealth Flight##10194 |goto Netherstorm/0 32.00,64.07
step
talk Veronia##20162
turnin Stealth Flight##10194 |goto Netherstorm/0 33.81,64.23
accept Behind Enemy Lines##10652 |goto Netherstorm/0 33.81,64.23
step
talk Veronia##20162
Select _"I'm as ready as I'll ever be."_ |gossip 118684
Take a Flight to Manaforge Coruu |invehicle |goto Netherstorm/0 33.81,64.23 |q 10652
step
talk Caledis Brightdawn##19840
turnin Behind Enemy Lines##10652 |goto Netherstorm/0 48.24,86.60
accept A Convincing Disguise##10197 |goto Netherstorm/0 48.24,86.60
stickystart "Collect_Sunfury_Arcanist_Robes_Scryers"
stickystart "Collect_Sunfury_Guardsman_Medallion_Scryers"
step
kill Sunfury Researcher##20136+
collect Sunfury Researcher Gloves##28636 |q 10197/1 |goto Netherstorm/0 51.40,86.40
|mapmarker Netherstorm/0 53.40,83.00
|mapmarker Netherstorm/0 53.60,87.20
step
label "Collect_Sunfury_Arcanist_Robes_Scryers"
kill Sunfury Arcanist##20134+
collect Sunfury Arcanist Robes##28635 |q 10197/3 |goto Netherstorm/0 51.40,82.00
|mapmarker Netherstorm/0 46.00,81.00
|mapmarker Netherstorm/0 46.40,82.80
|mapmarker Netherstorm/0 47.60,79.40
|mapmarker Netherstorm/0 48.00,85.40
|mapmarker Netherstorm/0 49.20,79.00
|mapmarker Netherstorm/0 51.80,83.60
step
label "Collect_Sunfury_Guardsman_Medallion_Scryers"
kill Sunfury Guardsman##18850+
collect Sunfury Guardsman Medallion##28637 |q 10197/2 |goto Netherstorm/0 52.60,82.00
|mapmarker Netherstorm/0 47.00,80.80
|mapmarker Netherstorm/0 48.20,84.00
|mapmarker Netherstorm/0 49.00,81.40
|mapmarker Netherstorm/0 49.40,79.40
|mapmarker Netherstorm/0 50.40,83.00
|mapmarker Netherstorm/0 53.80,85.00
step
talk Caledis Brightdawn##19840
turnin A Convincing Disguise##10197 |goto Netherstorm/0 48.24,86.60
accept Information Gathering##10198 |goto Netherstorm/0 48.24,86.60
step
use Sunfury Disguise##28607
Wear the Sunfury Disguise |havebuff Sunfury Disguise##34603 |q 10198
step
Watch the dialogue
|tip Avoid the {o}Arcane Annihilator{}.
|tip Can see through your disguise.
|tip Inside the building.
Gather the Information |q 10198/1 |goto Netherstorm/0 48.19,84.07
step
talk Caledis Brightdawn##19840
turnin Information Gathering##10198 |goto Netherstorm/0 48.24,86.60
accept Shutting Down Manaforge Coruu##10330 |goto Netherstorm/0 48.24,86.60
step
kill Overseer Seylanna##20397
|tip Inside the building.
collect Coruu Access Crystal##29396 |q 10330/2 |goto Netherstorm/0 49.02,81.51
step
click Coruu Control Console##183956
|tip Inside the building.
Select _"<Begin emergency shutdown.>"_ |gossip 118561
Kill the enemies that attack in waves
|tip Takes {o}2 minutes{}.
Shut Down Manaforge Coruu |q 10330/1 |goto Netherstorm/0 48.95,81.51
step
talk Caledis Brightdawn##19840
turnin Shutting Down Manaforge Coruu##10330 |goto Netherstorm/0 48.24,86.60
accept Return to Thalodien##10200 |goto Netherstorm/0 48.24,86.60
step
talk Spymaster Thalodien##19468
|tip Inside the building.
turnin Return to Thalodien##10200 |goto Netherstorm/0 32.00,64.07
step
talk Magistrix Larynna##19469
accept Kick Them While They're Down##10341 |goto Netherstorm/0 32.00,64.07
step
talk Spymaster Thalodien##19468
accept Shutting Down Manaforge Duro##10338 |goto Netherstorm/0 32.00,64.07
only if rep ('The Scryers') >= Neutral
stickystart "Collect_Arcane_Tome_And_Sunfury_Signets_Scryers"
stickystart "Kill_Sunfury_Conjurers_Scryers"
stickystart "Kill_Sunfury_Centurions_And_Bowmen_Scryers"
step
kill Overseer Athanel##20435
|tip Inside the building.
collect Duro Access Crystal##29397|q 10338/2 |goto Netherstorm/0 59.99,68.51
step
click the Duro Control Console##184311
|tip Inside the building.
Choose _"<Begin emergency shutdown>"_
Kill the enemies that attack in waves
|tip Takes {o}2 minutes{}.
Shut Down Manaforge Duro |q 10338/1 |goto Netherstorm/0 59.11,66.78
step
label "Collect_Arcane_Tome_And_Sunfury_Signets_Scryers"
kill Sunfury Conjurer##20139, Sunfury Centurions##20140, Sunfury Bowman##20207
collect Arcane Tome##29739 |goto Netherstorm/0 59.20,63.60 |q 10416 |future
collect 10 Sunfury Signet##30810 |goto Netherstorm/0 59.20,63.60 |q 10656 |future
|tip Needed for future quests.
|mapmarker Netherstorm/0 56.40,63.80
|mapmarker Netherstorm/0 56.40,66.40
|mapmarker Netherstorm/0 57.40,67.20
|mapmarker Netherstorm/0 57.60,63.40
|mapmarker Netherstorm/0 58.80,62.40
|only if rep('The Scryers') >= Neutral
step
label "Kill_Sunfury_Conjurers_Scryers"
kill 8 Sunfury Conjurer##20139 |q 10341/1 |goto Netherstorm/0 59.20,63.60
|mapmarker Netherstorm/0 56.40,63.80
|mapmarker Netherstorm/0 56.40,66.40
|mapmarker Netherstorm/0 57.40,67.20
|mapmarker Netherstorm/0 57.60,63.40
|mapmarker Netherstorm/0 58.80,62.40
|only if rep('The Scryers') >= Neutral
step
label "Kill_Sunfury_Centurions_And_Bowmen_Scryers"
kill 4 Sunfury Centurions##20140 |q 10341/3 |goto Netherstorm/0 58.40,63.40
kill 6 Sunfury Bowman##20207 |q 10341/2 |goto Netherstorm/0 58.40,63.40
|mapmarker Netherstorm/0 56.60,65.00
|mapmarker Netherstorm/0 58.00,67.40
|mapmarker Netherstorm/0 59.00,66.40
|mapmarker Netherstorm/0 61.20,65.40
step
talk Spymaster Thalodien##19468
turnin Shutting Down Manaforge Duro##10338 |goto Netherstorm/0 32.00,64.07
step
talk Magistrix Larynna##19469
turnin Kick Them While They're Down##10341 |goto Netherstorm/0 32.00,64.07
accept A Defector##10202 |goto Netherstorm/0 32.00,64.07
only if rep ('The Scryers') >= Friendly
step
talk Magister Theledorn##20920
turnin A Defector##10202 |goto Netherstorm/0 26.2,41.6
accept Damning Evidence##10432 |goto Netherstorm/0 26.2,41.6
only if rep ('The Scryers') >= Friendly
step
Inside Manaforge Ara:
Kill enemies around this area
collect 8 Orders From Kael'thas##29797 |q 10432/1 |goto Netherstorm/0 27.11,39.19
only if rep ('The Scryers') >= Friendly
step
talk Spymaster Thalodien##19468
turnin Damning Evidence##10432 |goto Netherstorm/0 32.00,64.07
accept A Gift for Voren'thal##10508 |goto Netherstorm/0 32.00,64.07
only if rep ('The Scryers') >= Friendly
step
kill Forgemaster Morug##20800
|tip You may need help with this.
collect First Half of Socrethar's Stone##29624 |q 10508/1 |goto Netherstorm/0 36.83,27.87
only if rep ('The Scryers') >= Friendly
step
kill Silroth##20801
|tip You may need help with this.
collect Second Half of Socrethar's Stone##29625 |q 10508/2 |goto Netherstorm/0 40.88,19.54
only if rep ('The Scryers') >= Friendly
step
talk Spymaster Thalodien##19468
turnin A Gift for Voren'thal##10508 |goto Netherstorm/0 32.00,64.07
accept Bound for Glory##10509 |goto Netherstorm/0 32.00,64.07
step
talk Voren'thal the Seer##18530
|tip Upstairs inside the building.
turnin Bound for Glory##10509 |goto Shattrath City/0 42.77,91.72
accept Turnin Point##10507 |goto Shattrath City/0 42.77,91.72
step
use Voren'thal's Package##30260
collect 1 Socrethar's Teleportation Stone##29796 |n
collect 1 Voren'thal's Presence##30259 |n
Stand in the teleporter |goto Netherstorm/0 36.42,18.33
use Socrethar's Teleportation Stone##29796
Arrive at Socrethar's Seat |goto Netherstorm/0 30.56,17.72 < 10 |q 10507 |future |noway |c
step
use Voren'thal's Presence##30259
|tip Use it on Socrethar.
kill Socrethar##20132 |q 10507/1 |goto Netherstorm/0 29.31,13.71
step
talk Voren'thal the Seer##18530
|tip Upstairs inside the building.
turnin Turnin Point##10507 |goto Shattrath City/0 42.77,91.72
step
talk Larissa Sunstrike##21954
|tip Inside the building.
accept Karabor Training Grounds##10687 |goto Shadowmoon Valley/0 55.74,58.17
step
talk Battlemage Vyara##22211
accept Sunfury Signets##10824 |goto Shadowmoon Valley/0 56.29,58.80
step
talk Arcanist Thelis##21955
|tip Inside the building.
accept Tablets of Baa'ri##10683 |goto Shadowmoon Valley/0 56.25,59.60
step
talk Varen the Reclaimer##21953
accept The Ashtongue Broken##10807 |goto Shadowmoon Valley/0 54.73,58.20
step
Kill Eclipse enemies around this area
collect 10 Sunfury Signet##30810 |q 10824/1 |goto Shadowmoon Valley/0 51.50,59.08
You can find more around [Shadowmoon Valley/0 51.67,65.83]
step
talk Battlemage Vyara##22211
turnin Sunfury Signets##10824 |goto Shadowmoon Valley/0 56.29,58.80
stickystart "Collect_Arcane_Tome"
step
Kill Demon Hunter enemies around this area
collect 8 Sunfury Glaive##30679 |q 10687/1 |goto Shadowmoon Valley/0 70.42,51.98
step
label "Collect_Arcane_Tome"
Kill Demon Hunter enemies around this area
collect 1 Arcane Tome##29739 |q 10416/1 |goto Shadowmoon Valley/0 70.42,51.98
step
talk Larissa Sunstrike##21954
|tip Inside the building
turnin Karabor Training Grounds##10687 |goto Shadowmoon Valley/0 55.74,58.17
accept A Necessary Distraction##10688 |goto Shadowmoon Valley/0 55.74,58.17
step
kill Sunfury Warlock##21503+
collect Scroll of Demonic Unbanishing##30811 |n
use the Scroll of Demonic Unbanishing##30811
|tip Use it on Azaloth.
Free Azaloth |q 10688/1 |goto Shadowmoon Valley/0 70.0,51.4
step
talk Larissa Sunstrike##21954
|tip Inside the building.
turnin A Necessary Distraction##10688 |goto Shadowmoon Valley/0 55.74,58.17
accept Altruis##10689 |goto Shadowmoon Valley/0 55.74,58.17
stickystart "Kill_4_Ashtongue_Warriors"
stickystart "Kill_6_Ashtongue_Shaman"
stickystart "Collect_12_Baa'ri_Tablet_Fragments"
step
kill 3 Ashtongue Handler##21803+ |q 10807/1 |goto Shadowmoon Valley/0 56.20,36.71
step
label "Kill_4_Ashtongue_Warriors"
kill 4 Ashtongue Warrior##21454+ |q 10807/2 |goto Shadowmoon Valley/0 56.99,34.38
step
label "Kill_6_Ashtongue_Shaman"
kill 6 Ashtongue Shaman##21453+ |q 10807/3 |goto Shadowmoon Valley/0 55.72,39.22
step
label "Collect_12_Baa'ri_Tablet_Fragments"
click Baar'ri Tablet Fragment##6420
|tip On the ground around this area.
kill Ashtongue Worker##21455+
collect 12 Baa'ri Tablet Fragment##30596 |q 10683/1 |goto Shadowmoon Valley/0 59.84,36.36
step
talk Varen the Reclaimer##21953
turnin The Ashtongue Broken##10807 |goto Shadowmoon Valley/0 54.73,58.20
accept The Great Retribution##10817 |goto Shadowmoon Valley/0 54.73,58.20
step
talk Arcanist Thelis##21955
|tip Inside the building.
turnin Tablets of Baa'ri##10683 |goto Shadowmoon Valley/0 56.25,59.60
accept Oronu the Elder##10684 |goto Shadowmoon Valley/0 56.25,59.60
step
kill Oronu the Elder##21663
|tip Standing on the balcony.
collect Orders From Akama##30649 |q 10684/1 |goto Shadowmoon Valley/0 57.16,32.82
stickystart "Kill_8_Shadowmoon_Chosen"
stickystart "Kill_4_Shadowmoon_Darkweavers"
step
kill 8 Shadowmoon Slayer##22082+ |q 10817/1 |goto Shadowmoon Valley/0 68.65,39.55
step
label "Kill_8_Shadowmoon_Chosen"
kill 8 Shadowmoon Chosen##22084+ |q 10817/2 |goto Shadowmoon Valley/0 68.62,37.63
step
label "Kill_4_Shadowmoon_Darkweavers"
kill 4 Shadowmoon Darkweaver##22081+ |q 10817/3 |goto Shadowmoon Valley/0 68.77,35.70
You can find more around [Shadowmoon Valley/0 69.62,39.62]
step
talk Arcanist Thelis##21955
|tip Inside the building.
turnin Oronu the Elder##10684 |goto Shadowmoon Valley/0 56.25,59.60
accept The Ashtongue Corruptors##10685 |goto Shadowmoon Valley/0 56.25,59.60
step
kill Corrupt Air Totem##21705
|tip Destroy them all to make Haalum vulnerable.
kill Haalum##21711
collect Haalum's Medallion Fragment##30691 |q 10685/2 |goto Shadowmoon Valley/0 57.08,73.64
step
kill Corrupt Earth Totem##21704
|tip Destroy them all to make Eykenen vulnerable.
kill Eykenen##21709
collect Eykenen's Medallion Fragment##30692 |q 10685/1 |goto Shadowmoon Valley/0 51.18,52.83
step
kill Corrupt Fire Totem##21703
|tip Destroy them all to make Uylaru vulnerable.
kill Uylaru##21710
collect Uylaru's Medallion Fragment##30694 |q 10685/4 |goto Shadowmoon Valley/0 48.29,39.56
step
kill Corrupt Water Totem##21420
|tip Destroy them all to make Lakaan vulnerable.
kill Lakaan##21416
collect Lakaan's Medallion Fragment##30693 |q 10685/3 |goto Shadowmoon Valley/0 49.89,23.01
step
talk Arcanist Thelis##21955
|tip Inside the building.
turnin The Ashtongue Corruptors##10685 |goto Shadowmoon Valley/0 56.25,59.60
accept The Warden's Cage##10686 |goto Shadowmoon Valley/0 56.25,59.60
step
Follow the path down |goto Shadowmoon Valley/0 57.35,49.67 < 5 |walk
talk Sanoru##21826
|tip Downstairs.
turnin The Warden's Cage##10686 |goto Shadowmoon Valley/0 57.33,49.58
step
talk Altruis the Sufferer##18417
turnin Altruis##10640 |goto Nagrand/0 27.34,43.09
accept Against All Odds##10669 |goto Nagrand/0 27.34,43.09
accept Against the Illidari##10668 |goto Nagrand/0 27.34,43.09
accept Against the Legion##10641 |goto Nagrand/0 27.34,43.09
step
use the Imbued Silver Spear##30853
kill Xeleth##21894 |q 10669/1 |goto Zangarmarsh/0 16.19,40.69
step
kill Wrath Priestess##18859+
|tip Walks around this area.
collect Freshly Drawn Blood##30850 |n
use the Freshly Drawn Blood##30850
|tip It only lasts for a minute.
kill Avatar of Sathal##21925 |q 10641/1 |goto Netherstorm/0 39.66,20.55
step
kill Lothros##21928 |q 10668/1 |goto Shadowmoon Valley/0 28.20,48.90
|tip He walks around this area.
|tip You may need help with this.
step
talk Altruis the Sufferer##18417
turnin Against the Legion##10641 |goto Nagrand/0 27.34,43.09
turnin Against the Illidari##10668 |goto Nagrand/0 27.34,43.09
turnin Against All Odds##10669 |goto Nagrand/0 27.34,43.09
accept Illidan's Pupil##10646 |goto Nagrand/0 27.34,43.09
step
talk Altruis the Sufferer##18417
Choose _"Tell me about the demon hunter training grounds at the Ruins of Karabor."_
Listen to Illidan's Pupil |q 10646/1 |goto Nagrand/0 27.34,43.09
step
talk Altruis the Sufferer##18417
turnin Illidan's Pupil##10646 |goto Nagrand/0 27.34,43.09
accept The Book of Fel Names##10649 |goto Nagrand/0 27.34,43.09
step
Inside the Shadow Labyrinth Dungeon:
kill Blackheart the Inciter##18667
collect 1 Book of Fel Names##30808|q 10649/1
step
talk Altruis the Sufferer##18417
turnin The Book of Fel Names##10649 |goto Nagrand/0 27.34,43.09
accept Return to the Scryers##10691 |goto Nagrand/0 27.34,43.09
step
talk Larissa Sunstrike##21954
|tip Inside the building.
turnin Return to the Scryers##10691 |goto Shadowmoon Valley/0 55.74,58.17
accept Varedis Must Be Stopped##10692 |goto Shadowmoon Valley/0 55.74,58.17
step
kill Netharel##21164 |q 10692/2 |goto Shadowmoon Valley/0 68.71,52.69
|tip He walks around this area.
|tip You may need help with this.
step
kill Alandien##21171 |q 10692/4 |goto Shadowmoon Valley/0 69.59,54.08
|tip You may need help with this.
step
kill Varedis##21178
|tip Inside the building.
|tip You may need help with this.
use the Book of Fel Names##30854
|tip Use it when Varedis is at low health.
Slay Varedis |q 10692/1 |goto Shadowmoon Valley/0 72.2,53.7
step
kill Theras##21168 |q 10692/3 |goto Shadowmoon Valley/0 72.34,48.40
|tip You may need help with this.
step
talk Larissa Sunstrike##21954
|tip Inside the building.
turnin Return to the Scryers##10692 |goto Shadowmoon Valley/0 55.74,58.17
step
talk Magistrix Fyalenn##18531
turnin Firewing Signets##10412 |goto Shattrath City/0 45.21,81.43
turnin Sunfury Signets##10656 |goto Shattrath City/0 45.21,81.43
step
talk Voren'thal the Seer##18530
|tip Upstairs inside the building.
turnin Synthesis of Power##10416 |goto Shattrath City/0 42.77,91.72
step
label "farming"
You will need to farm "Arcane Tomes" and "Sunfury Signets"
|tip Every 10 Sunfury Signets turned in nets 250 reputation.
|tip Each Arcane Tome turn in nets 350 reputation.
Click here to continue |confirm
'|complete rep('The Scryers')==Exalted |next "exalted"
step
Kill Sunfury enemies around this area
collect Arcane Tome##29739 |n |goto Netherstorm/0 27.58,70.88
|tip Each Arcane Tome turn in nets 350 reputation.
collect Sunfury Signet##30810 |n |goto Netherstorm/0 27.58,70.88
|tip Every 10 Sunfury Signets turned in nets 250 reputation.
You can find more around [Netherstorm/0 25.23,65.72]
Click here to continue |confirm
step
talk Magistrix Fyalenn##18531
accept More Sunfury Signets##10658 |n |goto Shattrath City/0 45.21,81.43
Click here to continue |confirm
Reach Exalted reputation with The Scryers |next "exalted" |complete rep('The Scryers')==Exalted
step
talk Voren'thal the Seer##18530
|tip Upstairs inside the building.
accept Arcane Tomes##10419 |n |goto Shattrath City/0 42.77,91.72
Click here to continue |next "farming" |confirm
|tip Click the line above to continue farming.
Reach Exalted reputation with The Scryers. |next |complete rep('The Scryers')==Exalted
]])
ZGV.BETAEND()
