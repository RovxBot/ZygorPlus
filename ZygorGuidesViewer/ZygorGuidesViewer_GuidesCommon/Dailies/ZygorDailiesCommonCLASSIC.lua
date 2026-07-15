local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if ZGV:DoMutex("DailiesCLEGION") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Ogri'la\\Ogri'la Daily Quests",{
author="support@zygorguides.com",
condition_suggested=function() return completedq(11065) and rep("Ogri'la") < Exalted end,
},[[
step
Complete the Ogri'la Questline |complete completedq(11065) |or
|tip Use the "Ogri'la" reputation guide to accomplish this.
Click Here to Load the {o}Ogri'la{} Reputation guide |confirm |loadguide "Reputation Guides\\The Burning Crusade\\Ogri'la" |or
step
label "Reset"
talk Kronk##23253
accept Banish More Demons##11051 |goto Blade's Edge Mountains/0 28.89,57.90
|only if rep("Ogri'la") >= Honored
step
talk Chu'a'lor##23233
accept The Relic's Emanation##11080 |goto Blade's Edge Mountains/0 28.76,57.37
step
talk Sky Sergeant Vanderlip##23120
accept Bomb Them Again!##11023 |goto Blade's Edge Mountains/0 27.57,52.91
step
talk Skyguard Khatie##23335
accept Wrangle More Aether Rays!##11066 |goto Blade's Edge Mountains/0 27.95,51.45
step
kill Apexis Flayer##22175, Gan'arg Analyzer##23385, Shard-Hide Boar##22180, Wrath Corruptor##22254
click Apexis Shard Formation##185911+
|tip They look like large clusters of crystals on the ground around this area.
collect Apexis Shard##32569 |goto Blade's Edge Mountains/0 31.78,57.42 |q 11080
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
|only if haveq(11080) or completedq(11080)
step
click Apexis Relic
|tip It looks like a small floating crystal hovering over a white orb on the ground.
Select _"Insert an Apexis Shard, and begin!"_ |gossip 36294
Repeat the Color Patterns Beneath the Crystal
|tip There are four colored buttons around the floating crystal.
|tip Angle the camera so that it's top down, and observe the pattern that plays out.
|tip Repeat the pattern in the same order.
|tip It's random every time.
|tip There are 8 sequences.
|tip If you fail, you will need to farm another Apexis Shard.
Attain the Apexis Vibrations |q 11080/1 |goto Blade's Edge Mountains/0 32.06,63.35
|only if haveq(11080) or completedq(11080)
stickystart "Banish_Demons"
step
use the Skyguard Bombs##32456
|tip You must be mounted to use the bombs.
|tip Use them on Fel Cannonball Stacks.
|tip They are stacks of cannonballs with a green hue on the underside.
|tip Fel Cannons will try to shoot you down while flying.
|tip Mount up on the ground near a Fel Cannonball Stack and immediately use the bombs on the stack.
|tip This will dismount you quickly before a cannon can fire at you.
Destroy #15# Fel Cannonball Stacks |q 11023/1 |goto Blade's Edge Mountains/0 34.49,41.07
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
kill Aether Ray##22181+
use the Wrangling Rope##32698
|tip Use it on weakened Aether Rays around this area.
|tip Reduce their health until you see a message indicating they can be wrangled.
|tip If you are well-geared, you may need to unequip some of your gear to avoid killing them.
Wrangle #5# Aether Rays |q 11066/1 |goto Blade's Edge Mountains/0 29.11,49.82
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
|only if haveq(11066) or completedq(11066)
step
label "Banish_Demons"
use the Banishing Crystal##32696
|tip Enemies must die near the portal you summon.
kill Abyssal Flamebringer##19973, Fear Fiend##22204, Wrath Speaker##22195, Furnace Guard##22291, Wrath Hound##20557
Banish #15# Demons |q 11051/1 |goto Blade's Edge Mountains/0 32.74,44.94
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
|only if haveq(11051) or completedq(11051)
step
talk Chu'a'lor##23233
turnin The Relic's Emanation##11080 |goto Blade's Edge Mountains/0 28.76,57.37
|only if haveq(11080) or completedq(11080)
step
talk Kronk##23253
turnin Banish More Demons##11051 |goto Blade's Edge Mountains/0 28.89,57.90
|only if haveq(11051) or completedq(11051)
step
talk Sky Sergeant Vanderlip##23120
turnin Bomb Them Again!##11023 |goto Blade's Edge Mountains/0 27.57,52.91
|only if haveq(11023) or completedq(11023)
step
talk Skyguard Khatie##23335
turnin Wrangle More Aether Rays!##11066 |goto Blade's Edge Mountains/0 27.95,51.45
|only if haveq(11066) or completedq(11066)
step
You Have Completed All Ogri'la Daily Quests
|tip This guide will reset when more become available.
Wait for Daily Quests to Reset |complete not completedq(11080,11023,11066,11051) |next "Reset"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Sha'tari Skyguard\\Sha'tari Skyguard Daily Quests",{
author="support@zygorguides.com",
description="\nThis guide section will walk you through completing the Sha'tari Skyguard daily quests.",
condition_suggested=function() return completedq(11098) and rep("Sha'tari Skyguard") < Exalted end,
},[[
step
Complete the "To Skettis!" Quest |complete completedq(11098) |or
|tip Use the "Sha'tari Skyguard" reputation guide to accomplish this.
|tip This will unlock the first two of four possible daily quests.
Click Here to Load the "Sha'tari Skyguard" Reputation guide |confirm |loadguide "Reputation Guides\\The Burning Crusade\\Sha'tari Skyguard" |or
step
label "Begin_Daily_Quests"
talk Sky Sergeant Doryn##23048
accept Fires Over Skettis##11008 |goto Terokkar Forest 64.5,66.7
stickystart "Look_For_The_Prisoner"
stickystart "Escort"
step
use the Skyguard Blasting Charges##32406
|tip Use it at the top of the trees on Monstrous Kaliri Eggs.
|tip Search for the Sky Skyguard Prisoner while bombing eggs. |only if not haveq(11008) or completedq(11008)
Destroy #20# Monstrous Kaliri Eggs |q 11008/1 |goto Terokkar Forest/0 62.99,80.05
|mapmarker Terokkar Forest/0 60.88,75.30
|mapmarker Terokkar Forest/0 61.56,73.48
|mapmarker Terokkar Forest/0 61.39,79.87
|mapmarker Terokkar Forest/0 67.96,85.47
|mapmarker Terokkar Forest/0 70.32,84.58
|mapmarker Terokkar Forest/0 72.47,88.86
|mapmarker Terokkar Forest/0 74.76,88.58
|mapmarker Terokkar Forest/0 75.21,86.31
|mapmarker Terokkar Forest/0 73.34,86.31
|mapmarker Terokkar Forest/0 74.13,83.89
|mapmarker Terokkar Forest/0 74.19,83.91
|mapmarker Terokkar Forest/0 75.95,81.01
|mapmarker Terokkar Forest/0 69.49,78.77
|mapmarker Terokkar Forest/0 67.66,79.45
|mapmarker Terokkar Forest/0 69.92,74.73
|mapmarker Terokkar Forest/0 68.57,73.97
|mapmarker Terokkar Forest/0 71.29,82.32
|mapmarker Terokkar Forest/0 72.99,83.09
|only if haveq(11008) or completedq(11008)
step
label "Look_For_The_Prisoner"
talk Skyguard Prisoner##23383
|tip On the platform.
accept Escape from Skettis##11085 |goto Terokkar Forest/0 61.0,75.6
He Has Several Spawn Points: |notinsticky
|mapmarker Terokkar Forest/0 68.4,74.0
|mapmarker Terokkar Forest/0 75.0,86.5
step
label "Escort"
Escort the Skyguard Prisoner
|tip Follow the Skyguard Prisoner.
|tip Kill mobs that attack on the way to the bottom of the bridge.
Rescue the Skyguard Prisoner |q 11085/1
step
talk Sky Sergeant Doryn##23048
turnin Fires Over Skettis##11008 |goto Terokkar Forest 64.5,66.7
turnin Escape from Skettis##11085 |goto Terokkar Forest 64.5,66.7
|only if haveq(11008,11085) or completedq(11008,11085)
step
talk Sky Sergeant Vanderlip##23120
accept Bomb Them Again!##11023 |goto Blade's Edge Mountains/0 27.57,52.91
|only if completedq(11010,11102)
step
talk Skyguard Khatie##23335
accept Wrangle More Aether Rays!##11066 |goto Blade's Edge Mountains/0 27.95,51.45
|only if completedq(11065)
step
use the Skyguard Bombs##32456
|tip You must be mounted to use the bombs.
|tip Use them on Fel Cannonball Stacks.
|tip They are stacks of cannonballs with a green hue on the underside.
|tip Fel Cannons will try to shoot you down while flying.
|tip Mount up on the ground near a Fel Cannonball Stack and immediately use the bombs on the stack.
Destroy #15# Fel Cannonball Stacks |q 11023/1 |goto Blade's Edge Mountains/0 34.49,41.07
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
|only if haveq(11023) or completedq(11023)
step
kill Aether Ray##22181+
use the Wrangling Rope##32698
|tip Use it on weakened Aether Rays around this area.
|tip Reduce their health until you see a message indicating they can be wrangled.
Wrangle #5# Aether Rays |q 11066/1 |goto Blade's Edge Mountains/0 29.11,49.82
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
|only if haveq(11066) or completedq(11066)
step
talk Sky Sergeant Vanderlip##23120
turnin Bomb Them Again!##11023 |goto Blade's Edge Mountains/0 27.57,52.91
|only if haveq(11023) or completedq(11023)
step
talk Skyguard Khatie##23335
turnin Wrangle More Aether Rays!##11066 |goto Blade's Edge Mountains/0 27.95,51.45
|only if haveq(11066) or completedq(11066)
step
You Have Completed All Sha'tari Skyguard Daily Quests
|tip This guide will reset when more become available.
Wait for Daily Quests to Reset |complete not completedq(11008,11085,11023,11066) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Sha'tari Skyguard\\Sha'tari Skyguard Terokk Farming",{
author="support@zygorguides.com",
description="\nThis guide section will walk you through farming materials to summon and kill Terokk for repeatable reputation.",
condition_suggested=function() return completedq(11073) and rep("Sha'tari Skyguard") < Exalted end,
},[[
step
Complete the "Terokk's Downfall" Questline |complete completedq(11073) |or
|tip Use the {o}"Sha'tari Skyguard"{} reputation guide to accomplish this.
Click Here to Load the {o}"Sha'tari Skyguard"{} Reputation Guide |confirm |loadguide "Reputation Guides\\The Burning Crusade\\Sha'tari Skyguard" |or
step
label "Reset"
kill Skettis Wing Guard##21644, Skettis Windwalker##21649, Skettis Soulcaller##21911, Skettis Talonite##21650
|tip Arakkoas.
collect 6 Shadow Dust##32388 |goto Terokkar Forest/0 61.99,74.76 |n
|tip It takes 6 Shadow Dust to trade per 1 Elixir of Shadows.
|mapmarker Terokkar Forest/0 69.69,84.52
|mapmarker Terokkar Forest/0 70.16,79.66
|mapmarker Terokkar Forest/0 72.96,80.80
|mapmarker Terokkar Forest/0 75.18,81.18
|mapmarker Terokkar Forest/0 61.41,78.19
|mapmarker Terokkar Forest/0 69.19,74.85
|confirm
step
talk Severin##23042
accept More Shadow Dust##11006 |goto Terokkar Forest/0 64.05,66.88 |n
collect Elixir of Shadows##32446 |n
|confirm
step
use the Elixir of Shadows##32446
Gain the Elixir of Shadows Buff |havebuff Elixir of Shadows##37678
step
kill Time-Lost Skettis Worshipper##21763, kill Time-Lost Skettis Reaver##21651, kill Time-Lost Skettis High Priest##21787
collect 40 Time-Lost Scroll##32620 |goto Terokkar Forest 61.6,75.3 |n
|tip Gather them in intervals of 40.
|tip It takes 10 Time-Lost Scrolls to summon bosses to kill.
|tip You need to collect components from 4 different bosses.
|tip You can also buy them from the Auction House.
|mapmarker Terokkar Forest 69.5,85.5
|mapmarker Terokkar Forest 73.2,87.9
|mapmarker Terokkar Forest 75.2,81.3
|mapmarker Terokkar Forest 69.2,74.1
Click Here to Farm More Elixir of Shadows |confirm |next "Reset"
|confirm
step
click Skull Pile##185913
|tip This will consume 10 Time-Lost Scrolls.
Select _"<Call forth Gezzarak the Huntress.>"_ |gossip 36671
Select _"<Call forth Darkscreecher Akkarai.>"_ |gossip 36672
Select _"<Call forth Karrog.>"_ |gossip 36673
Select _"<Call forth Vakkiz the Windrager.>"_ |gossip 36674
kill Gezzarak the Huntress##23163, Darkscreecher Akkarai##23161, Karrog##23165, Vakkiz the Windrager##23204
|tip These enemies are intended for groups.
|mapmarker Terokkar Forest/0 70.07,79.43
|mapmarker Terokkar Forest/0 70.23,83.35
|mapmarker Terokkar Forest/0 73.53,80.70
collect Gezzarak's Claws##32716 |goto Terokkar Forest/0 69.66,74.70
|tip Loot it from Gezzarak the Huntress' corpse.
collect Akkarai's Talons##32715 |goto Terokkar Forest/0 69.66,74.70
|tip Loot it from Darkscreecher Akkarai's corpse.
collect Karrog's Spine##32717 |goto Terokkar Forest/0 69.66,74.70
|tip Loot it from Karrog's corpse.
collect Vakkiz's Scale##32718 |goto Terokkar Forest/0 69.66,74.70
|tip Loot it from Vakkiz the Windrager's corpse.
step
talk Hazzik##23306
|tip In a cage.
accept Tokens of the Descendants##11074 |goto Terokkar Forest/0 64.23,66.97
collect Time-Lost Offering##32720
step
click Skull Pile##185913
|tip This will consume 1 Time-Lost Offering.
Select _"<Call forth Terokk.>"_ |gossip 35384
kill Terokk##21838 |goto Terokkar Forest/0 66.21,77.48
|tip Intended for a group.
|tip When he becomes immune, walk him over the blue smoke.
|tip A meteor will come down and break his shield.
|tip
|confirm |next "Reset"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Shattrath Cooking Dailies",{
author="support@zygorguides.com",
description="\nThis guide will walk you through completing the Cooking daily quests "..
"in Shattrath city for Barrels of Fish and Crates of Meat.",
condition_suggested=function() return skill("Cooking") >= 275 and not completedq(11381,11379,11380,11377) end,
},[[
step
Reach 275 Cooking |complete skill("Cooking") >= 275
|tip Use the "Cooking (1-300)" profession guide to accomplish this.
step
label "Accept_Daily_Quest"
talk The Rokk##24393
You will only be able to accept one of these daily quests per day
accept Soup for the Soul##11381 |goto Shattrath City/0 61.66,15.63 |next "Soup_for_the_Soul" |or
accept Super Hot Stew##11379 |goto Shattrath City/0 61.66,15.63 |next "Super_Hot_Stew" |or
accept Manalicious##11380 |goto Shattrath City/0 61.66,15.63 |next "Manalicious" |or
accept Revenge is Tasty##11377 |goto Shattrath City/0 61.66,15.63 |next "Revenge_is_Tasty" |or
Accept the Daily Quest |complete false |or
step
label "Soup_for_the_Soul"
talk Uriku##20096
buy Recipe: Roasted Clefthoof##27691 |goto Nagrand 56.2,73.3 |q 11381 |or
'|learn Roasted Clefthoof##33287 |or
|only if haveq(11381) or completedq(11381)
|only if Alliance
step
talk Nula the Butcher##20097
buy Recipe: Roasted Clefthoof##27691 |goto Nagrand 58.0,35.6 |q 11381 |or
'|learn Roasted Clefthoof##33287 |or
|only if haveq(11381) or completedq(11381)
|only if Horde
step
use the Recipe: Roasted Clefthoof##27691
Learn the "Roasted Clefthoof" Recipe |learn Roasted Clefthoof##33287 |goto Nagrand 56.2,73.3 |q 11381
|only if haveq(11381) or completedq(11381)
step
Kill Clefthoof enemies around this area
collect 4 Clefthoof Meat##27678 |q 11381 |goto Nagrand 58.5,46.8
You can find more around [Nagrand 45.5,72.7]
|only if haveq(11381) or completedq(11381)
step
cast Basic Campfire##818
Cook 4 Roasted Clefthoof (open Cooking window)
collect 4 Roasted Clefthoof##27658 |goto Nagrand 25.9,59.4 |q 11381
|tip Stand next to your campfire.
|only if haveq(11381) or completedq(11381)
step
use the Cooking Pot##33851
|tip At the bonfire in the Ancestral Grounds in Nagrand.
Cook a Spiritual Soup |q 11381/1 |goto Nagrand 25.9,59.4
|only if haveq(11381) or completedq(11381)
step
label "Super_Hot_Stew"
talk Xerintha Ravenoak##20916
buy Recipe: Mok'Nathal Shortribs##31675 |goto Blade's Edge Mountains 62.5,40.3 |or
'|learn Mok'Nathal Shortribs##31672 |or
|only if haveq(11379) or completedq(11379)
|only if Horde
step
talk Sassa Weldwell##21113
buy Recipe: Mok'Nathal Shortribs##31675 |goto Blade's Edge Mountains 61.2,68.8 |or
'|learn Mok'Nathal Shortribs##31672 |or
|only if haveq(11379) or completedq(11379)
|only if Alliance
step
use the Recipe: Mok'Nathal Shortribs##31675
Learn the "Mok'Nathal Shortribs" Recipe |learn Mok'Nathal Shortribs##31672 |goto Blade's Edge Mountains 62.5,40.3 |q 11379
|only if haveq(11379) or completedq(11379)
step
talk Xerintha Ravenoak##20916
buy Recipe: Crunchy Serpent##31674 |goto Blade's Edge Mountains 62.5,40.3 |q 11379 |or
'|learn Crunchy Serpent##31673 |or
|only if haveq(11379) or completedq(11379)
|only if Horde
step
talk Sassa Weldwell##21113
buy Recipe: Crunchy Serpent##31674 |goto Blade's Edge Mountains 61.2,68.8 |q 11379 |or
'|learn Crunchy Serpent##31673 |or
|only if haveq(11379) or completedq(11379)
|only if Alliance
step
use the Recipe: Crunchy Serpent##31674
Learn the "Crunchy Serpent" Recipe |learn Crunchy Serpent##31673 |goto Blade's Edge Mountains 62.5,40.3 |q 11379
|only if haveq(11379) or completedq(11379)
step
Kill enemies around this area
|tip Daggermaw Blackhides and Bladespire Raptors drop ribs.
collect 4 Raptor Ribs##31670 |goto Blade's Edge Mountains 49.6,46.2 |q 11379
|only if haveq(11379) or completedq(11379)
step
Kill Scalewing enemies around this area
collect 1 Serpent Flesh##31671 |goto Blade's Edge Mountains 68.2,63.2 |q 11379
|only if haveq(11379) or completedq(11379)
step
cast Basic Campfire##818
Cook 2 Mok'Nathal Shortribs (open Cooking window)
collect 2 Mok'Nathal Shortribs##31672 |q 11379
|tip Stand next to your campfire.
|only if haveq(11379) or completedq(11379)
step
cast Basic Campfire##818
Cook 1 Crunchy Serpent (open Cooking window)
collect 1 Crunchy Serpent##31673 |q 11379
|tip Stand next to your campfire.
|only if haveq(11379) or completedq(11379)
step
kill Abyssal Flamebringer##19973
use the Cooking Pot##33852
|tip Use it next to the Abyssal Flamebringer corpse.
collect Demon Broiled Surprise##33848 |q 11379/1 |goto Blade's Edge Mountains 29.0,84.5
|only if haveq(11379) or completedq(11379)
step
label "Manalicious"
click Mana Berry Bush##186729+
|tip They look like green bushes with small red berries on the ground around this area.
collect 15 Mana Berry##33849 |q 11380/1 |goto Netherstorm 45.6,54.2
|only if haveq(11380) or completedq(11380)
step
label "Revenge_is_Tasty"
talk Innkeeper Grika##18957
buy Recipe: Warp Burger##27692 |goto Terokkar Forest 48.8,45.0 |q 11377 |or
'|learn Warp Burger##33288 |or
|only if haveq(11377) or completedq(11377)
|only if Horde
step
talk Supply Officer Mills
buy Recipe: Warp Burger##27692 |goto Terokkar Forest 55.73,53.04 |q 11377 |or
'|learn Warp Burger##33288 |or
|only if haveq(11377) or completedq(11377)
|only if Alliance
step
use the Recipe: Warp Burger##27692
Learn the "Warp Burger" Recipe |learn Warp Burger##33288 |q 11377 |goto Terokkar Forest 48.8,45.0
|only if haveq(11377) or completedq(11377)
step
kill Blackwind Warp Chaser##23219+
collect 3 Warped Flesh##27681 |goto Terokkar Forest 64.0,83.5 |q 11377
|only if haveq(11377) or completedq(11377)
step
kill Monstrous Kaliri##23051+
|tip They fly close to tree outposts and bridges. This is a BoP quest item.
collect Giant Kaliri Wing##33838 |goto Terokkar Forest 67.6,74.7 |q 11377
|only if haveq(11377) or completedq(11377)
step
cast Basic Campfire##818
Cook 3 Warp Burgers (open Cooking window)
collect 3 Warp Burger##27659
|tip Stand next to your campfire.
|only if haveq(11377) or completedq(11377)
step
use the Cooking Pot##33837
|tip Stand next to your campfire.
collect Kaliri Stew##43718 |q 11377/1 |goto Terokkar Forest 25.9,59.5
|only if haveq(11377) or completedq(11377)
step
talk The Rokk##24393
turnin Soup for the Soul##11381 |goto Shattrath City 61.8,15.6 |only if haveq(11381) or completedq(11381)
turnin Super Hot Stew##11379 |goto Shattrath City 61.8,15.6 |only if haveq(11379) or completedq(11379)
turnin Manalicious##11380 |goto Shattrath City 61.8,15.6 |only if haveq(11380) or completedq(11380)
turnin Revenge is Tasty##11377 |goto Shattrath City 61.8,15.6 |only if haveq(11377) or completedq(11377)
|only if haveq(11381,11379,11380,11377) or completedq(11381,11379,11380,11377)
step
You have completed the Shattrath Cooking daily quest.
|tip This guide will reset when another becomes available.
'|complete not completedq(11381,11379,11380,11377) |next "Accept_Daily_Quest"
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Daily Quests", {
author="support@zygorguides.com",
startlevel=70,
description="\nThis guide will walk you through completing the various daily quests for Netherwing reputation.",
condition_end=function() return rep("Netherwing") >= Exalted end,
},[[
step
Become an Ally of the Netherwing |complete completedq(11019)
|tip Complete the "Your Friend On The Inside" quest in Shadowmoon Valley.
|tip Use the "Netherwing" reputation guide to accomplish this.
step
label "Begin_Daily_Quests"
Proceeding |complete true |only if default
Complete the "Overseeing and You: Making the Right Choices" Quest |complete completedq(11054) |only if rep("Netherwing") >= Friendly and not completedq(11054)
|tip Use the "Netherwing" reputation guide to accomplish this. |only if rep("Netherwing") >= Friendly and not completedq(11054)
Complete the "Stand Tall, Captain!" Quest |complete completedq(11084) |only if rep("Netherwing") >= Honored and not completedq(11084)
|tip Use the "Netherwing" reputation guide to accomplish this. |only if rep("Netherwing") >= Honored and not completedq(11084)
Complete the "Commander Hobb" Quest |complete completedq(11095) |only if rep("Netherwing") >= Revered and rep("The Scryers") >= Friendly and not completedq(11095)
|tip Use the "Netherwing" reputation guide to accomplish this. |only if rep("Netherwing") >= Revered and rep("The Scryers") >= Friendly and not completedq(11095)
Complete the "Commander Arcus" Quest |complete completedq(11100) |only if rep("Netherwing") >= Revered and rep("The Aldor") >= Friendly and not completedq(11100)
|tip Use the "Netherwing" reputation guide to accomplish this. |only if rep("Netherwing") >= Revered and rep("The Aldor") >= Friendly and not completedq(11100)
step
talk Yarzill the Merc##23141
accept A Slow Death##11020 |goto Shadowmoon Valley/0 66.00,86.46
accept The Not-So-Friendly Skies##11035 |goto Shadowmoon Valley/0 66.00,86.46
step
talk Taskmaster Varkule Dragonbreath##23140
accept Netherwing Crystals##11015 |goto Shadowmoon Valley/0 66.12,86.36
accept Nethermine Flayer Hide##11016 |goto Shadowmoon Valley/0 66.12,86.36 |only if skill("Skinning") >= 350 |noautoaccept
accept Nethercite Ore##11018 |goto Shadowmoon Valley/0 66.12,86.36 |only if skill("Mining") >= 350 |noautoaccept
accept Netherdust Pollen##11017 |goto Shadowmoon Valley/0 66.12,86.36 |only if skill("Herbalism") >= 350 |noautoaccept
|tip You can always accept the "Netherwing Crystals" quest
|tip An additional quest is available if you have 350+ skill in Mining, Skinning, or Herbalism.
|tip You can only accept one additional quest, if you have multiple eligible professions.
step
talk Chief Overseer Mudlump##23291
accept The Booterang: A Cure For The Common Worthless Peon##11055 |goto Shadowmoon Valley/0 66.84,86.11
|only if rep("Netherwing") >= Friendly
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
accept Disrupting the Twilight Portal##11086 |goto Shadowmoon Valley/0 66.22,85.67
|only if rep("Netherwing") >= Honored
step
kill Felboar##21878, Netherskate##21901, Greater Felfire Diemetradon##21462, Felfire Diemetradon##21408, Mutant Horror##21305, Scorchshell Pincer##21864, Shadow Serpent##23020, Vilewing Chimaera##21879, Scorchshell Pincer##21864, Shadow Serpent##23020, Felfire Diemetradon##21408
collect 12 Fel Gland##32502 |q 11020 |goto Shadowmoon Valley/0 34.20,42.40
|tip Most animal enemies will drop them.
|mapmarker Shadowmoon Valley/0 28.20,42.40
|mapmarker Shadowmoon Valley/0 28.80,44.40
|mapmarker Shadowmoon Valley/0 30.60,43.20
|mapmarker Shadowmoon Valley/0 32.20,41.40
|mapmarker Shadowmoon Valley/0 32.20,44.80
|mapmarker Shadowmoon Valley/0 32.40,38.40
|mapmarker Shadowmoon Valley/0 34.20,39.40
|mapmarker Shadowmoon Valley/0 34.60,37.40
|mapmarker Shadowmoon Valley/0 35.20,45.40
|mapmarker Shadowmoon Valley/0 35.40,47.60
|mapmarker Shadowmoon Valley/0 36.00,40.40
|mapmarker Shadowmoon Valley/0 36.40,42.60
|mapmarker Shadowmoon Valley/0 37.60,45.60
|mapmarker Shadowmoon Valley/0 39.00,43.60
|mapmarker Shadowmoon Valley/0 40.80,42.40
|mapmarker Shadowmoon Valley/0 43.00,49.20
|mapmarker Shadowmoon Valley/0 44.40,51.60
|mapmarker Shadowmoon Valley/0 45.80,53.20
|mapmarker Shadowmoon Valley/0 46.40,55.60
|mapmarker Shadowmoon Valley/0 46.80,58.20
|mapmarker Shadowmoon Valley/0 61.43,43.80
|mapmarker Shadowmoon Valley/0 60.93,45.52
|mapmarker Shadowmoon Valley/0 61.17,48.24
|mapmarker Shadowmoon Valley/0 59.71,43.16
|mapmarker Shadowmoon Valley/0 58.66,42.46
|mapmarker Shadowmoon Valley/0 61.11,40.84
|mapmarker Shadowmoon Valley/0 62.67,45.99
|mapmarker Shadowmoon Valley/0 58.68,52.03
|mapmarker Shadowmoon Valley/0 57.09,53.51
|mapmarker Shadowmoon Valley/0 56.37,51.71
|mapmarker Shadowmoon Valley/0 57.30,51.84
|mapmarker Shadowmoon Valley/0 46.26,61.25
|mapmarker Shadowmoon Valley/0 45.22,60.55
|only if haveq(11020) or completedq(11020)
stickystart "Collect_Netherwing_Relics"
stickystart "Discipline_Dragonmaw_Peons"
stickystart "Collect_Netherdust_Pollen"
stickystart "Collect_Nethercite_Ore"
step
use Yarzill's Mutton##32503
|tip Use it next to groups of Dragonmaw Peons.
|tip Avoid Dragonmaw Ascendants.
Poison #12# Dragonmaw Peon Camps |q 11020/1 |goto Shadowmoon Valley/0 64.47,80.80
|mapmarker Shadowmoon Valley/0 63.96,81.90
|mapmarker Shadowmoon Valley/0 65.12,83.44
|mapmarker Shadowmoon Valley/0 65.54,82.54
|mapmarker Shadowmoon Valley/0 66.58,82.70
|mapmarker Shadowmoon Valley/0 67.30,82.07
|mapmarker Shadowmoon Valley/0 66.90,80.32
|mapmarker Shadowmoon Valley/0 67.61,80.19
|mapmarker Shadowmoon Valley/0 68.52,78.73
|mapmarker Shadowmoon Valley/0 68.94,79.90
|mapmarker Shadowmoon Valley/0 70.18,80.97
|mapmarker Shadowmoon Valley/0 68.63,82.60
|mapmarker Shadowmoon Valley/0 69.65,82.57
|mapmarker Shadowmoon Valley/0 70.72,82.53
|mapmarker Shadowmoon Valley/0 71.23,83.08
|mapmarker Shadowmoon Valley/0 71.75,82.62
|mapmarker Shadowmoon Valley/0 72.19,83.03
|mapmarker Shadowmoon Valley/0 72.80,82.67
|mapmarker Shadowmoon Valley/0 72.82,83.32
|mapmarker Shadowmoon Valley/0 73.39,83.12
|mapmarker Shadowmoon Valley/0 74.17,83.33
|mapmarker Shadowmoon Valley/0 74.60,82.74
|mapmarker Shadowmoon Valley/0 75.33,82.98
|mapmarker Shadowmoon Valley/0 76.55,84.51
|mapmarker Shadowmoon Valley/0 77.25,82.33
|mapmarker Shadowmoon Valley/0 77.75,82.83
|mapmarker Shadowmoon Valley/0 76.05,86.33
|mapmarker Shadowmoon Valley/0 75.77,87.26
|mapmarker Shadowmoon Valley/0 76.56,87.89
|mapmarker Shadowmoon Valley/0 77.60,88.01
|mapmarker Shadowmoon Valley/0 78.59,88.60
|mapmarker Shadowmoon Valley/0 78.55,87.09
|mapmarker Shadowmoon Valley/0 78.76,85.43
|mapmarker Shadowmoon Valley/0 78.27,84.43
|mapmarker Shadowmoon Valley/0 74.33,88.14
|mapmarker Shadowmoon Valley/0 73.91,88.56
|mapmarker Shadowmoon Valley/0 73.03,89.07
|mapmarker Shadowmoon Valley/0 72.05,89.38
|mapmarker Shadowmoon Valley/0 71.70,90.25
|mapmarker Shadowmoon Valley/0 70.80,90.33
|mapmarker Shadowmoon Valley/0 69.82,89.24
|mapmarker Shadowmoon Valley/0 69.71,88.20
|mapmarker Shadowmoon Valley/0 71.03,88.03
|mapmarker Shadowmoon Valley/0 68.26,86.97
|mapmarker Shadowmoon Valley/0 68.10,85.65
|mapmarker Shadowmoon Valley/0 68.41,84.51
|only if haveq(11020) or completedq(11020)
step
label "Discipline_Dragonmaw_Peons"
use the Booterang##32680
|tip Use it on Disobedient Dragonmaw Peons.
Discipline #20# Dragonmaw Peons |q 11055/1 |goto Shadowmoon Valley/0 64.47,80.80
|mapmarker Shadowmoon Valley/0 63.96,81.90
|mapmarker Shadowmoon Valley/0 65.12,83.44
|mapmarker Shadowmoon Valley/0 65.54,82.54
|mapmarker Shadowmoon Valley/0 66.58,82.70
|mapmarker Shadowmoon Valley/0 67.30,82.07
|mapmarker Shadowmoon Valley/0 66.90,80.32
|mapmarker Shadowmoon Valley/0 67.61,80.19
|mapmarker Shadowmoon Valley/0 68.52,78.73
|mapmarker Shadowmoon Valley/0 68.94,79.90
|mapmarker Shadowmoon Valley/0 70.18,80.97
|mapmarker Shadowmoon Valley/0 68.63,82.60
|mapmarker Shadowmoon Valley/0 69.65,82.57
|mapmarker Shadowmoon Valley/0 70.72,82.53
|mapmarker Shadowmoon Valley/0 71.23,83.08
|mapmarker Shadowmoon Valley/0 71.75,82.62
|mapmarker Shadowmoon Valley/0 72.19,83.03
|mapmarker Shadowmoon Valley/0 72.80,82.67
|mapmarker Shadowmoon Valley/0 72.82,83.32
|mapmarker Shadowmoon Valley/0 73.39,83.12
|mapmarker Shadowmoon Valley/0 74.17,83.33
|mapmarker Shadowmoon Valley/0 74.60,82.74
|mapmarker Shadowmoon Valley/0 75.33,82.98
|mapmarker Shadowmoon Valley/0 76.55,84.51
|mapmarker Shadowmoon Valley/0 77.25,82.33
|mapmarker Shadowmoon Valley/0 77.75,82.83
|mapmarker Shadowmoon Valley/0 76.05,86.33
|mapmarker Shadowmoon Valley/0 75.77,87.26
|mapmarker Shadowmoon Valley/0 76.56,87.89
|mapmarker Shadowmoon Valley/0 77.60,88.01
|mapmarker Shadowmoon Valley/0 78.59,88.60
|mapmarker Shadowmoon Valley/0 78.55,87.09
|mapmarker Shadowmoon Valley/0 78.76,85.43
|mapmarker Shadowmoon Valley/0 78.27,84.43
|mapmarker Shadowmoon Valley/0 74.33,88.14
|mapmarker Shadowmoon Valley/0 73.91,88.56
|mapmarker Shadowmoon Valley/0 73.03,89.07
|mapmarker Shadowmoon Valley/0 72.05,89.38
|mapmarker Shadowmoon Valley/0 71.70,90.25
|mapmarker Shadowmoon Valley/0 70.80,90.33
|mapmarker Shadowmoon Valley/0 69.82,89.24
|mapmarker Shadowmoon Valley/0 69.71,88.20
|mapmarker Shadowmoon Valley/0 71.03,88.03
|mapmarker Shadowmoon Valley/0 68.26,86.97
|mapmarker Shadowmoon Valley/0 68.10,85.65
|mapmarker Shadowmoon Valley/0 68.41,84.51
|only if haveq(11055) or completedq(11055)
step
label "Collect_Netherwing_Relics"
kill Dragonmaw Transporter##23188+
|tip They fly low to the ground near floating rocks.
collect 10 Netherwing Relic##32509 |q 11035/1 |goto Shadowmoon Valley/0 71.99,74.83
|mapmarker Shadowmoon Valley/0 71.04,81.50
|mapmarker Shadowmoon Valley/0 74.39,75.24
|mapmarker Shadowmoon Valley/0 72.54,82.11
|only if haveq(11035) or completedq(11035)
step
talk Commander Hobb##23434
accept The Deadliest Trap Ever Laid##11097 |goto Shadowmoon Valley/0 56.48,58.65
|only if rep("The Scryers") >= Friendly and rep("Netherwing") >= Revered
step
Follow Commander Hobb
|tip Protect him from Dragonmaw Skybreakers that descend from the sky.
|tip There will be several waves of enemies flying down towards you.
|tip Intended for a group.
kill Dragonmaw Skybreaker##23441
Defeat the Dragonmaw Forces |q 11097/1 |goto Shadowmoon Valley/0 56.48,58.65
|only if haveq(11097) or completedq(11097)
step
talk Commander Arcus##23452
accept The Deadliest Trap Ever Laid##11101 |goto Shadowmoon Valley/0 62.38,29.29
|tip This quest is intended for a group.
|only if rep("The Aldor") >= Friendly and rep("Netherwing") >= Revered
step
Follow Commander Arcus
|tip Protect him from Dragonmaw Skybreakers that descend from the sky.
|tip There will be several waves of enemies flying down towards you.
|tip Intended for a group.
kill Dragonmaw Skybreaker##23441
Defeat the Dragonmaw Forces |q 11101/1 |goto Shadowmoon Valley/0 64.45,31.30
|only if haveq(11101) or completedq(11101)
step
label "Collect_Netherdust_Pollen"
click Netherdust Bushs
collect 40 Netherdust Pollen##32468 |q 11017/1 |goto Shadowmoon Valley/0 69.32,82.39
|mapmarker Shadowmoon Valley/0 69.74,80.08
|mapmarker Shadowmoon Valley/0 72.62,80.29
|mapmarker Shadowmoon Valley/0 72.52,82.60
|mapmarker Shadowmoon Valley/0 74.76,83.26
|mapmarker Shadowmoon Valley/0 75.45,81.36
|mapmarker Shadowmoon Valley/0 77.12,83.42
|mapmarker Shadowmoon Valley/0 76.06,85.09
|mapmarker Shadowmoon Valley/0 76.06,88.13
|mapmarker Shadowmoon Valley/0 74.30,88.77
|mapmarker Shadowmoon Valley/0 72.09,88.85
|mapmarker Shadowmoon Valley/0 69.71,88.62
|mapmarker Shadowmoon Valley/0 67.92,87.02
|mapmarker Shadowmoon Valley/0 67.35,83.57
|mapmarker Shadowmoon Valley/0 68.01,79.46
|mapmarker Shadowmoon Valley/0 71.02,85.41
|mapmarker Shadowmoon Valley/0 73.66,85.70
|only if haveq(11017) or completedq(11017)
step
label "Collect_Nethercite_Ore"
click Nethercite Deposit
|tip These can also be found inside the mine.
collect 40 Nethercite Ore##32464 |q 11018/1  |goto Shadowmoon Valley/0 69.32,82.39
|mapmarker Shadowmoon Valley/0 69.74,80.08
|mapmarker Shadowmoon Valley/0 72.62,80.29
|mapmarker Shadowmoon Valley/0 72.52,82.60
|mapmarker Shadowmoon Valley/0 74.76,83.26
|mapmarker Shadowmoon Valley/0 75.45,81.36
|mapmarker Shadowmoon Valley/0 77.12,83.42
|mapmarker Shadowmoon Valley/0 76.06,85.09
|mapmarker Shadowmoon Valley/0 76.06,88.13
|mapmarker Shadowmoon Valley/0 74.30,88.77
|mapmarker Shadowmoon Valley/0 72.09,88.85
|mapmarker Shadowmoon Valley/0 69.71,88.62
|mapmarker Shadowmoon Valley/0 67.92,87.02
|mapmarker Shadowmoon Valley/0 67.35,83.57
|mapmarker Shadowmoon Valley/0 68.01,79.46
|mapmarker Shadowmoon Valley/0 71.02,85.41
|mapmarker Shadowmoon Valley/0 73.66,85.70
|only if haveq(11018) or completedq(11018)
step
talk Mistress of the Mines##23149
accept Picking Up The Pieces...##11076 |goto Shadowmoon Valley/0 63.06,87.74
|only if rep("Netherwing") >= Friendly
step
Enter the mine |goto Shadowmoon Valley/0 63.18,87.72 < 7
talk Dragonmaw Foreman##23376
|tip Walking around this area inside the mine.
accept Dragons are the Least of Our Problems##11077 |goto Shadowmoon Valley/0 64.15,87.46
|only if rep("Netherwing") >= Friendly
stickystart "Kill_Nethermine_Ravagers"
stickystart "Collect_Netherwing_Crystal"
stickystart "Collect_Nethermine_Flayer_Hides"
stickystart "Collect_Nethermind_Cargo"
step
Follow the path |goto Shadowmoon Valley/0 69.54,85.26 < 7		|walk
Continue following the path |goto Shadowmoon Valley/0 70.31,85.88 < 7	|walk
Cross the tracks |goto Shadowmoon Valley/0 71.18,84.48 < 7		|walk
kill 15 Nethermine Flayer##23169 |q 11077/1 |goto Shadowmoon Valley/0 71.76,82.98
|tip Inside the mine.
|mapmarker Shadowmoon Valley/0 74.75,86.26
|mapmarker Shadowmoon Valley/0 74.29,85.04
|mapmarker Shadowmoon Valley/0 73.84,85.81
|mapmarker Shadowmoon Valley/0 73.59,84.93
|mapmarker Shadowmoon Valley/0 73.86,83.76
|mapmarker Shadowmoon Valley/0 73.01,84.03
|mapmarker Shadowmoon Valley/0 72.52,82.81
|mapmarker Shadowmoon Valley/0 71.45,81.74
|mapmarker Shadowmoon Valley/0 70.90,82.39
|mapmarker Shadowmoon Valley/0 70.05,82.04
|mapmarker Shadowmoon Valley/0 69.21,81.96
|mapmarker Shadowmoon Valley/0 68.64,81.94
|mapmarker Shadowmoon Valley/0 68.27,82.47
|mapmarker Shadowmoon Valley/0 69.05,80.75
|mapmarker Shadowmoon Valley/0 68.32,80.38
|mapmarker Shadowmoon Valley/0 67.88,81.15
|mapmarker Shadowmoon Valley/0 67.30,80.90
|mapmarker Shadowmoon Valley/0 66.76,81.52
|mapmarker Shadowmoon Valley/0 66.26,81.09
|mapmarker Shadowmoon Valley/0 66.09,81.96
|mapmarker Shadowmoon Valley/0 65.45,82.48
|mapmarker Shadowmoon Valley/0 64.87,82.57
|mapmarker Shadowmoon Valley/0 64.51,83.51
|mapmarker Shadowmoon Valley/0 65.04,83.53
|only if haveq(11077) or completedq(11077)
step
label "Kill_Nethermine_Ravagers"
kill 5 Nethermine Ravager##23326 |q 11077/2 |goto Shadowmoon Valley/0 71.76,82.98
|tip Inside the mine.
|mapmarker Shadowmoon Valley/0 74.75,86.26
|mapmarker Shadowmoon Valley/0 74.29,85.04
|mapmarker Shadowmoon Valley/0 73.84,85.81
|mapmarker Shadowmoon Valley/0 73.59,84.93
|mapmarker Shadowmoon Valley/0 73.86,83.76
|mapmarker Shadowmoon Valley/0 73.01,84.03
|mapmarker Shadowmoon Valley/0 72.52,82.81
|mapmarker Shadowmoon Valley/0 71.45,81.74
|mapmarker Shadowmoon Valley/0 70.90,82.39
|mapmarker Shadowmoon Valley/0 70.05,82.04
|mapmarker Shadowmoon Valley/0 69.21,81.96
|mapmarker Shadowmoon Valley/0 68.64,81.94
|mapmarker Shadowmoon Valley/0 68.27,82.47
|mapmarker Shadowmoon Valley/0 69.05,80.75
|mapmarker Shadowmoon Valley/0 68.32,80.38
|mapmarker Shadowmoon Valley/0 67.88,81.15
|mapmarker Shadowmoon Valley/0 67.30,80.90
|mapmarker Shadowmoon Valley/0 66.76,81.52
|mapmarker Shadowmoon Valley/0 66.26,81.09
|mapmarker Shadowmoon Valley/0 66.09,81.96
|mapmarker Shadowmoon Valley/0 65.45,82.48
|mapmarker Shadowmoon Valley/0 64.87,82.57
|mapmarker Shadowmoon Valley/0 64.51,83.51
|mapmarker Shadowmoon Valley/0 65.04,83.53
|tip Inside the mine.
|only if haveq(11077) or completedq(11077)
step
label "Collect_Nethermind_Cargo"
click Nethermine Cargo+
|tip They look like carts full of ore and crystals inside the Netherwing Mines.
collect 15 Nethermine Cargo##32723 |q 11076/1 |goto Shadowmoon Valley 66.9,84.0
|mapmarker Shadowmoon Valley/0 65.08,86.17
|mapmarker Shadowmoon Valley/0 64.79,85.14
|mapmarker Shadowmoon Valley/0 65.47,85.09
|mapmarker Shadowmoon Valley/0 67.07,84.25
|mapmarker Shadowmoon Valley/0 67.34,82.90
|mapmarker Shadowmoon Valley/0 68.05,83.97
|mapmarker Shadowmoon Valley/0 69.04,84.14
|mapmarker Shadowmoon Valley/0 69.25,87.65
|mapmarker Shadowmoon Valley/0 69.85,88.17
|mapmarker Shadowmoon Valley/0 72.01,83.15
|mapmarker Shadowmoon Valley/0 73.04,83.92
|mapmarker Shadowmoon Valley/0 73.55,84.12
|mapmarker Shadowmoon Valley/0 73.93,83.17
|mapmarker Shadowmoon Valley/0 74.18,86.13
|mapmarker Shadowmoon Valley/0 74.08,87.05
|mapmarker Shadowmoon Valley/0 74.22,88.29
|mapmarker Shadowmoon Valley/0 74.26,88.83
|mapmarker Shadowmoon Valley/0 74.34,89.45
|mapmarker Shadowmoon Valley/0 73.25,89.30
|only if haveq(11076) or completedq(11076)
step
label "Collect_Netherwing_Crystal"
Enter the mine |goto Shadowmoon Valley/0 65.32,89.74
kill Black Blood of Draenor##23286, Nethermine Burster##23285
|tip Inside the mine.
|tip They can drop from Netherwing flayers, oozes, and Netherwing Rays.
collect 30 Netherwing Crystal##32427 |q 11015/1 |goto Shadowmoon Valley/0 64.91,85.45
|mapmarker Shadowmoon Valley/0 67.24,83.09
|mapmarker Shadowmoon Valley/0 68.77,84.37
|mapmarker Shadowmoon Valley/0 69.60,84.28
|mapmarker Shadowmoon Valley/0 69.89,86.46
|only if haveq(11015) or completedq(11015)
step
label "Collect_Nethermine_Flayer_Hides"
kill Nethermine Flayer##23169+
|tip Inside the mine.
|tip Skin their corpses.
collect 35 Nethermine Flayer Hide##32470 |q 11016/1 |goto Shadowmoon Valley 71.5,83.9
|only if haveq(11016) or completedq(11016)
step
talk Dragonmaw Foreman##23376
|tip Inside the mine.
turnin Dragons are the Least of Our Problems##11077 |goto Shadowmoon Valley/0 64.15,87.46
|only if haveq(11077) or completedq(11077)
step
Leave the mine |goto Shadowmoon Valley/0 63.18,87.72 < 7
talk Mistress of the Mines##23149
turnin Picking Up the Pieces...##11076 |goto Shadowmoon Valley/0 63.06,87.74
|only if haveq(11076) or completedq(11076)
step
kill Deathshadow Warlock##22363, Deathshadow Overlord##22393, Deathshadow Spellbinder##22342, Deathshadow Archon##22343, Deathshadow Acolyte##22341
|tip Watch for elites that partol around the area if you aren't grouped.
|tip They look like Ogres.
Slay #20# Deathshadow Agents |q 11086/1 |goto Nagrand/0 10.52,38.71
|mapmarker Nagrand/0 11.47,38.90
|mapmarker Nagrand/0 12.83,38.73
|mapmarker Nagrand/0 11.12,40.18
|mapmarker Nagrand/0 11.09,41.79
|mapmarker Nagrand/0 10.21,42.99
|mapmarker Nagrand/0 9.19,43.76
|mapmarker Nagrand/0 8.02,42.48
|mapmarker Nagrand/0 8.13,40.63
|only if haveq(11086) or completedq(11086)
step
talk Yarzill the Merc##23141
turnin A Slow Death##11020 |goto Shadowmoon Valley/0 66.00,86.46 |only if haveq(11020) or completedq(11020)
turnin The Not-So-Friendly Skies##11035 |goto Shadowmoon Valley/0 66.00,86.46 |only if haveq(11035) or completedq(11035)
|only if haveq(11020,11035) or completedq(11020,11035)
step
talk Taskmaster Varkule Dragonbreath##23140
turnin Netherwing Crystals##11015 |goto Shadowmoon Valley/0 66.12,86.36 |only if haveq(11015) or completedq(11015)
turnin Nethermine Flayer Hide##11016 |goto Shadowmoon Valley/0 66.12,86.36 |only if haveq(11016) or completedq(11016)
turnin Nethercite Ore##11018 |goto Shadowmoon Valley/0 66.12,86.36 |only if haveq(11018) or completedq(11018)
turnin Netherdust Pollen##11017 |goto Shadowmoon Valley/0 66.12,86.36 |only if haveq(11017) or completedq(11017)
|only if haveq(11015,11016,11018,11017) or completedq(11015,11016,11018,11017)
step
talk Chief Overseer Mudlump##23291
turnin The Booterang: A Cure For The Common Worthless Peon##11055 |goto Shadowmoon Valley/0 66.84,86.11
|only if haveq(11055) or completedq(11055)
step
talk Overlord Mor'ghor##23139
|tip Inside the building.
turnin Disrupting the Twilight Portal##11086 |goto Shadowmoon Valley/0 66.22,85.67 |only if haveq(11086) or completedq(11086)
turnin The Deadliest Trap Ever Laid##11097 |goto Shadowmoon Valley/0 66.22,85.67 |only if haveq(11097) or completedq(11097)
turnin The Deadliest Trap Ever Laid##11101 |goto Shadowmoon Valley/0 66.22,85.67 |only if haveq(11101) or completedq(11101)
|only if haveq(11086,11097,11101) or completedq(11086,11097,11101)
step
Wait for Daily Quests to Reset|complete not completedq(11077,11076,11086,11020,11035,11015,11016,11018,11017,11055,11086,11097,11101) |next "Begin_Daily_Quests"
|tip This guide will reset when more become available.
]])
ZygorGuidesViewer:RegisterGuide("Dailies Guides\\The Burning Crusade\\Netherwing\\Netherwing Eggs", {
author="support@zygorguides.com",
description="\nThis guide section will walk you through an optimized path of collecting Netherwing Eggs, which you can turn in for 250 Netherwing rep each. "..
"You must have completed the \"The Great Netherwing Egg Hunt\" quest to be able to collect and turn in the Netherwing Eggs.",
condition_end=function() return rep("Netherwing") >= Exalted end,
startlevel=70,
},[[
step
Complete the "The Great Netherwing Egg Hunt" Quest |complete completedq(11049)
|tip Use the "Netherwing" reputation guide to accomplish this.
step
label "Eggs"
click Netherwing Egg
|tip Small dark eggs with blue crystals.
|tip They spawn all over Netherwing Ledge.
|tip They can be gathered from the Herbs and Mining nodes on the Island.
|tip Enemies can also drop them.
|tip They can spawn inside of the mine.
|tip While at Dragonmaw Fortress, check inside of buildings along walls.
collect Netherwing Egg##32506 |goto Shadowmoon Valley/0 67.76,80.27 |n
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
|confirm
step
talk Yarzill the Merc##23141
accept Accepting All Eggs##11050 |goto Shadowmoon Valley/0 66.00,86.46 |n
Click Here to Return to Egg Farming |confirm |next "Eggs"
]])
