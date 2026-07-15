local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if UnitFactionGroup("player")~="Horde" then return end
if ZGV:DoMutex("TitlesHCLASSIC") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("Titles\\Burning Crusade Titles\\Dungeons & Raids\\Champion of the Naaru",{
author="support@zygorguides.com",
description="\nThis guide will walk you through obtaining the \"Champion of the Naaru\" title.",
playertitle=53,
startlevel=68,
},[[
step
Reach Level 68 |ding 68
|tip Use leveling guides to accomplish this.
|tip Level 70 is optimal to start this guide.
step
talk Earthmender Sophurus##21937
accept The Hand of Gul'Dan##10680 |goto Shadowmoon Valley/0 36.37,56.95
|only if Alliance
step
talk Earthmender Splinthoof##21938
accept The Hand of Gul'Dan##10681 |goto Shadowmoon Valley/0 28.48,26.58
|only if Horde
step
talk Earthmender Torlok##21024
turnin The Hand of Gul'Dan##10680 |goto Shadowmoon Valley/0 42.18,45.06 |only if Alliance
turnin The Hand of Gul'Dan##10681 |goto Shadowmoon Valley/0 42.18,45.06 |only if Horde
accept Enraged Spirits of Fire and Earth##10458 |goto Shadowmoon Valley/0 42.18,45.06
stickystart "Capture_8_Fiery_Souls"
step
use the Totem of Spirits##30094
kill Enraged Earth Spirit##21050+
|tip Kill them near the totem you placed.
Capture #8# Earthen Souls |q 10458/1 |goto Shadowmoon Valley/0 43.62,47.81
step
label "Capture_8_Fiery_Souls"
use the Totem of Spirits##30094
kill Enraged Fire Spirit##21061+
|tip Kill them near the totem you placed.
Capture #8# Fiery Souls |q 10458/2 |goto Shadowmoon Valley/0 49.48,51.33
step
talk Earthmender Torlok##21024
turnin Enraged Spirits of Fire and Earth##10458 |goto Shadowmoon Valley/0 42.18,45.06
accept Enraged Spirits of Water##10480 |goto Shadowmoon Valley/0 42.18,45.06
step
use the Totem of Spirits##30094
kill Enraged Water Spirit##21059+
|tip Kill them near the totem you placed.
Capture #5# Watery Souls |q 10480/1 |goto Shadowmoon Valley/0 45.56,27.31
step
talk Earthmender Torlok##21024
turnin Enraged Spirits of Water##10480 |goto Shadowmoon Valley/0 42.18,45.06
accept Enraged Spirits of Air##10481 |goto Shadowmoon Valley/0 42.18,45.06
step
use the Totem of Spirits##30094
kill Enraged Air Spirit##21060+
|tip Kill them near the totem you placed.
Capture #10# Airy Souls |q 10481/1 |goto Shadowmoon Valley/0 67.03,23.21
You can find more around [Shadowmoon Valley/0 60.92,22.22]
step
talk Earthmender Torlok##21024
turnin Enraged Spirits of Air##10481 |goto Shadowmoon Valley/0 42.18,45.06
accept Oronok Torn-Heart##10513 |goto Shadowmoon Valley/0 42.18,45.06
step
talk Oronok Torn-heart##21183
turnin Oronok Torn-Heart##10513 |goto Shadowmoon Valley/0 53.92,23.53
accept I Was A Lot Of Things...##10514 |goto Shadowmoon Valley/0 53.92,23.53
step
use Oronok's Boar Whistle##30462
|tip Blow the whistle near tubers.
|tip Don't blow the whistle near the tuber unless a boar is in ear-shot, otherwise the tuber will vanish.
collect 10 Shadowmoon Tuber##30356 |q 10514/1 |goto Shadowmoon Valley/0 53,16
step
talk Oronok Torn-heart##21183
turnin I Was A Lot Of Things...##10514 |goto Shadowmoon Valley/0 53.92,23.53
accept A Lesson Learned##10515 |goto Shadowmoon Valley/0 53.92,23.53
step
click Ravenous Flayer Egg##184684+
|tip They look like a spiked brown egg with a green mist coming off from them.
Destroy #10# Ravenous Flayer Eggs |q 10515/1 |goto Shadowmoon Valley/0 57.0,18.0
step
talk Oronok Torn-heart##21183
turnin A Lesson Learned##10515 |goto Shadowmoon Valley/0 53.92,23.53
accept The Cipher of Damnation - Truth and History##10519 |goto Shadowmoon Valley/0 53.92,23.53
step
talk Oronok Torn-heart##21183
Select _"I am ready to hear your story. Oronok."_
Listen to Oronok's Story |q 10519/1 |goto Shadowmoon Valley/0 53.92,23.53
step
talk Oronok Torn-Heart##21183
turnin The Cipher of Damnation - Truth and History##10519 |goto Shadowmoon Valley/0 53.92,23.53
accept Grom'tor, Son of Oronok##10521 |goto Shadowmoon Valley/0 53.92,23.53
accept Ar'tor, Son of Oronok##10527 |goto Shadowmoon Valley/0 53.92,23.53
accept Borak, Son of Oronok##10546 |goto Shadowmoon Valley/0 53.92,23.53
step
talk Grom'tor, Son of Oronok##21291
|tip He walks around the area.
turnin Grom'tor, Son of Oronok##10521 |goto Shadowmoon Valley/0 44.63,23.66
accept The Cipher of Damnation - Grom'tor's Charge##10522 |goto Shadowmoon Valley/0 44.63,23.66
step
Kill Coilskar enemies around this area
collect Coilskar Chest Key##30426+ |n
|tip Collect keys and open chests until you find the First Fragment.
click Coilskar Chest##184716+
|tip They look like stone chests on the ground around this area.
collect 1 First Fragment of the Cipher of Damnation##30428 |q 10522/1 |goto Shadowmoon Valley/0 44.6,23.6
step
talk Grom'tor, Son of Oronok##21291
turnin The Cipher of Damnation - Grom'tor's Charge##10522 |goto Shadowmoon Valley/0 44.63,23.66
accept The Cipher of Damnation - The First Fragment Recovered##10523 |goto Shadowmoon Valley/0 44.63,23.66
step
talk Ar'tor, Son of Oronok##21292
turnin Ar'tor, Son of Oronok##10527 |goto Shadowmoon Valley/0 29.64,50.40
accept Demonic Crystal Prisons##10528 |goto Shadowmoon Valley/0 29.64,50.40
step
kill Painmistress Gabrissa##21309
collect 1 Crystalline Key##30442 |q 10528/1 |goto Shadowmoon Valley/0 28.03,47.65
step
talk Ar'tor, Son of Oronok##21292
turnin Demonic Crystal Prisons##10528 |goto Shadowmoon Valley/0 29.64,50.40
step
talk Spirit of Ar'tor##21318
accept Lohn'goron, Bow of the Torn-heart##10537 |goto Shadowmoon Valley/0 29.53,50.56
step
Kill Illidari enemies around this area
collect 1 Lohn'goron, Bow of the Torn-heart##30451 |q 10537/1 |goto Shadowmoon Valley/0 29.65,50.44
step
talk Spirit of Ar'tor##21318
turnin Lohn'goron, Bow of the Torn-heart##10537 |goto Shadowmoon Valley/0 29.53,50.56
accept The Cipher of Damnation - Ar'tor's Charge##10540 |goto Shadowmoon Valley/0 29.53,50.56
step
kill Veneratus the Many##20427
collect 1 Second Fragment of the Cipher of Damnation##30453 |q 10540/1 |goto Shadowmoon Valley/0 31.52,55.43
step
talk Spirit of Ar'tor##21318
turnin The Cipher of Damnation - Ar'tor's Charge##10540 |goto Shadowmoon Valley/0 29.53,50.56
accept The Cipher of Damnation - The Second Fragment Recovered##10541 |goto Shadowmoon Valley/0 29.53,50.56
step
talk Borak, Son of Oronok##21293
turnin Borak, Son of Oronok##10546 |goto Shadowmoon Valley/0 47.56,57.18
accept Of Thistleheads and Eggs...##10547 |goto Shadowmoon Valley/0 47.56,57.18
step
click Rotten Arakkoa Eggs##30500+
|tip They look like pink eggs with green mist around them on the ground around this area.
collect 1 Rotten Arakkoa Egg##30500 |q 10547/1 |goto Shadowmoon Valley/0 45.5,57.5
step
talk Tobias the Filth Gorger##21411
turnin Of Thistleheads and Eggs...##10547 |goto Shattrath City/0 63.95,70.02
accept The Bundle of Bloodthistle##10550 |goto Shattrath City/0 63.95,70.02
step
talk Borak, Son of Oronok##21293
turnin The Bundle of Bloodthistle##10550 |goto Shadowmoon Valley/0 47.56,57.18
accept To Catch A Thistlehead##10570 |goto Shadowmoon Valley/0 47.56,57.18
step
use the Bundle of Bloodthistle##30501
|tip Plant the bundle near the east side of the bridge.
|tip Hide until he dismisses his escort, Blood Lord Zarath.
kill Envoy Icarius##21409
collect 1 Stormrage Missive##30617 |q 10570/1 |goto Shadowmoon Valley/0 48.94,57.50
step
talk Borak, Son of Oronok##21293
turnin To Catch A Thistlehead##10570 |goto Shadowmoon Valley/0 47.56,57.18
accept The Shadowmoon Shuffle##10576 |goto Shadowmoon Valley/0 47.56,57.18
step
Kill Eclipsion enemies around this area
collect 6 Eclipsion Armor##30640 |q 10576/1 |goto Shadowmoon Valley/0 49.27,58.97
step
talk Borak, Son of Oronok##21293
turnin The Shadowmoon Shuffle##10576 |goto Shadowmoon Valley/0 47.56,57.18
accept What Illidan Wants, Illidan Gets...##10577 |goto Shadowmoon Valley/0 47.56,57.18
step
use the Blood Elf Disguise##30639
Gain the "Blood Elf Illusion" Buff |havebuff spell:37096 |q 10577
step
talk Grand Commander Ruusk##20563
|tip Enter Eclipse Point. Once inside, use the disguise to cloak yourself.
|tip Watch out for the dragonhawks as they see through the disguise.
|tip You must be wearing the blood elf disguise.
Select _"I bring word from Lord Illidan."_
Deliver Illidan's Message |q 10577/1 |goto Shadowmoon Valley/0 46.4,71.8
step
talk Borak, Son of Oronok##21293
turnin What Illidan Wants, Illidan Gets...##10577 |goto Shadowmoon Valley/0 47.56,57.18
accept The Cipher of Damnation - Borak's Charge##10578 |goto Shadowmoon Valley/0 47.56,57.18
step
Follow the path down |goto Shadowmoon Valley/0 58.78,55.40 < 30
Follow the path |goto Shadowmoon Valley/0 63.00,57.39 < 30
Continue following the path |goto Shadowmoon Valley/0 65.36,59.78 < 30
kill Ruul the Darkener##21315
|tip He lands here and rides up to the fortress.
|tip After each trip he despawns and has a 5 minute timer before he restarts his loop.
|tip This enemy is elite and may require a group of up to four people.
collect Third Fragment of the Cipher of Damnation##30645 |q 10578/1 |goto Shadowmoon Valley/0 66.44,60.10
step
talk Borak, Son of Oronok##21293
turnin The Cipher of Damnation - Borak's Charge##10578 |goto Shadowmoon Valley/0 47.56,57.18
accept The Cipher of Damnation - The Third Fragment Recovered##10579 |goto Shadowmoon Valley/0 47.56,57.18
step
talk Oronok Torn-heart##21183
turnin The Cipher of Damnation - The First Fragment Recovered##10523 |goto Shadowmoon Valley/0 53.92,23.53
turnin The Cipher of Damnation - The Second Fragment Recovered##10541 |goto Shadowmoon Valley/0 53.92,23.53
turnin The Cipher of Damnation - The Third Fragment Recovered##10579 |goto Shadowmoon Valley/0 53.92,23.53
accept The Cipher of Damnation##10588 |goto Shadowmoon Valley/0 53.92,23.53
step
use The Cipher of Damnation##30657
|tip Near the altar.
|tip This enemy is elite and may require a group of up to five people.
talk Oronok Torn-heart##21183
Select _"I am ready. Oronok. Let us destroy Cyrukh and free the elements!"_
kill Cyrukh the Firelord##21181 |q 10588/1 |goto Shadowmoon Valley/0 43.25,44.83
step
talk Earthmender Torlok##21024
turnin The Cipher of Damnation##10588 |goto Shadowmoon Valley/0 42.18,45.06
step
Reach Level 70 |ding 70
|tip Use leveling guides to accomplish this.
step
talk A'dal##18481
accept Trial of the Naaru: Mercy##10884 |goto Shattrath City/0 53.99,44.77
accept Trial of the Naaru: Strength##10885 |goto Shattrath City/0 53.99,44.77
accept Trial of Naaru: Tenacity##10886 |goto Shattrath City/0 53.99,44.77
step
kill Shattered Hand Executioner##17301
|tip After Warchief Kargath Bladefist in The Shattered Halls dungeon on heroic difficulty.
|tip It must be killed within 55 minutes of passing Grand Warlock Nethekurse's room.
collect 1 Unused Axe of the Excutioner##31716 |q 10884/1
step
kill Warlord Kalithresh##17798
|tip Warlord Kalithresh is the final boss of The Steamvault dungeon.
|tip This must be completed on heroic difficulty.
collect 1 Kalithresh's Trident##31721 |q 10885/1
step
kill Murmur##18708
|tip Murmur is the final boss of the Shadow Labyrinth dungeon.
|tip This must be completed on heroic difficulty.
collect 1 Murmur's Essense##31722 |q 10885/2
step
Rescue Millhouse Manastorm |q 10886/1
|tip Protect Millhouse Manastorm during the boss encounter in The Arcatraz dungeon.
|tip This must be completed on heroic difficulty.
step
talk A'dal##18481
turnin Trial of the Naaru: Mercy##10884 |goto Shattrath City/0 53.99,44.77
turnin Trial of the Naaru: Strength##10885 |goto Shattrath City/0 53.99,44.77
turnin Trial of Naaru: Tenacity##10886 |goto Shattrath City/0 53.99,44.77
accept Trial of the Naaru: Magtheridon##10888 |goto Shattrath City/0 53.99,44.77
step
kill Magtheridon##17257 |q 10888/1
|tip Inside the Magtheridon's Lair raid.
step
talk A'dal##18481
turnin Trial of the Naaru: Magtheridon##10888 |goto Shattrath City/0 53.99,44.77
step
_Congratulations!_
You Earned the "Champion of the Naaru" Title.
]])
ZygorGuidesViewer:RegisterGuide("Titles\\Burning Crusade Titles\\Dungeons & Raids\\Hand of A'dal",{
author="support@zygorguides.com",
description="\nThis guide will walk you through obtaining the \"Hand of A'dal\" title.",
playertitle=64,
startlevel=70,
},[[
step
talk Soridormi##19935
|tip She walks around the Caverns of Time.
accept The Vials of Eternity##10445 |goto Tanaris/0 60.55,54.67
step
talk Haggard War Veteran##19684
|tip He walks back and forth across the bridge.
accept A'dal##10210 |goto Shattrath City/0 60.48,16.40
step
talk A'dal##18481
turnin A'dal##10210 |goto Shattrath City/0 53.99,44.77
step
talk Khadgar##18166
accept City of Light##10211 |goto Shattrath City/0 54.75,44.32
step
Follow Khadgar's Servant
|tip He will show you around the city.
turnin City of Light##10211 |goto Shattrath City/0 54.75,44.32
step
talk Khadgar##18166
|tip Inside the building.
|tip You will only be able to complete one of these quests.
accept Allegiance to the Aldor##10551 |goto Shattrath City/0 54.75,44.32 |or |noautoaccept
|tip You will become aligned with the Aldor faction by completing this quest.
accept Allegiance to the Scryers##10552 |goto Shattrath City/0 54.75,44.32 |or |noautoaccept
|tip You will become aligned with the Scryers faction by completing this quest.
step
talk Anchorite Ceyla##21402
|tip She is inside the tallest building.
accept Tablets of Baa'ri##10568 |goto Shadowmoon Valley/0 62.58,28.38
|only if rep("The Aldor") >= Neutral
step
kill Ashtongue Worker##21455+
collect 12 Baa'ri Tablet Fragment##30596 |q 10568/1 |goto Shadowmoon Valley/0 61.01,38.57
|only if rep("The Aldor") >= Neutral
step
talk Anchorite Ceyla##21402
|tip She is inside the tallest building.
turnin Tablets of Baa'ri##10568 |goto Shadowmoon Valley/0 62.58,28.38
accept Oronu the Elder##10571 |goto Shadowmoon Valley/0 62.58,28.38
|only if rep("The Aldor") >= Neutral
step
kill Oronu the Elder##21663
|tip He is on the balcony.
collect 1 Orders from Akama##30649 |q 10571/1 |goto Shadowmoon Valley/0 57.20,32.88
|only if rep("The Aldor") >= Neutral
step
talk Anchorite Ceyla##21402
|tip She is inside the tallest building.
turnin Oronu the Elder##10571 |goto Shadowmoon Valley/0 62.58,28.38
accept The Ashtongue Corruptors##10574 |goto Shadowmoon Valley/0 62.58,28.38
|only if rep("The Aldor") >= Neutral
step
kill Lakaan##21416
collect 1 Lakaan's Medallion Fragment##30693 |q 10574/3 |goto Shadowmoon Valley/0 49.87,23.03
|only if rep("The Aldor") >= Neutral
step
kill Uylaru##21710
collect 1 Uylaru's Medallion Fragment##30694 |q 10574/4 |goto Shadowmoon Valley/0 48.25,39.62
|only if rep("The Aldor") >= Neutral
step
kill Eykenen##21709
collect 1 Eykenen's Medallion Fragment##30692 |q 10574/1 |goto Shadowmoon Valley/0 51.19,52.79
|only if rep("The Aldor") >= Neutral
step
kill Haalum##21711
collect 1 Haalum's Medallion Fragment##30691 |q 10574/2 |goto Shadowmoon Valley/0 57.07,73.62
|only if rep("The Aldor") >= Neutral
step
talk Anchorite Ceyla##21402
|tip She is inside the tallest building.
turnin The Ashtongue Corruptors##10574 |goto Shadowmoon Valley/0 62.58,28.38
accept The Warden's Cage##10575 |goto Shadowmoon Valley/0 62.58,28.38
|only if rep("The Aldor") >= Neutral
step
talk Sanoru##21826
|tip Enter the warden's cage, follow ramp down.
turnin The Warden's Cage##10575 |goto Shadowmoon Valley/0 57.33,49.58
accept Proof of Allegiance##10622 |goto Shadowmoon Valley/0 57.33,49.58
|only if rep("The Aldor") >= Neutral
step
talk Arcanist Thelis##21955
accept Tablets of Baa'ri##10683 |goto Shadowmoon Valley/0 56.29,59.51
|only if rep("The Scryers") >= Neutral
step
kill Ashtongue Worker##21455+
collect 12 Baa'ri Tablet Fragment##30596 |q 10683/1 |goto Shadowmoon Valley/0 61.01,38.57
|only if rep("The Scryers") >= Neutral
step
talk Arcanist Thelis##21955
turnin Tablets of Baa'ri##10683 |goto Shadowmoon Valley/0 56.29,59.51
accept Oronu the Elder##10684 |goto Shadowmoon Valley/0 56.29,59.51
|only if rep("The Scryers") >= Neutral
step
kill Oronu the Elder##21663
|tip He is on the balcony.
collect 1 Orders from Akama##30649 |q 10684/1 |goto Shadowmoon Valley/0 57.20,32.88
|only if rep("The Scryers") >= Neutral
step
talk Arcanist Thelis##21955
turnin Oronu the Elder##10684 |goto Shadowmoon Valley/0 56.29,59.51
accept The Ashtongue Corruptors##10685 |goto Shadowmoon Valley/0 56.29,59.51
|only if rep("The Scryers") >= Neutral
step
kill Haalum##21711
collect 1 Haalum's Medallion Fragment##30691 |q 10685/2 |goto Shadowmoon Valley/0 57.07,73.62
|only if rep("The Scryers") >= Neutral
step
kill Eykenen##21709
collect 1 Eykenen's Medallion Fragment##30692 |q 10685/1 |goto Shadowmoon Valley/0 51.19,52.79
|only if rep("The Scryers") >= Neutral
step
kill Uylaru##21710
collect 1 Uylaru's Medallion Fragment##30694 |q 10685/4 |goto Shadowmoon Valley/0 48.25,39.62
|only if rep("The Scryers") >= Neutral
step
kill Lakaan##21416
collect 1 Lakaan's Medallion Fragment##30693 |q 10685/3 |goto Shadowmoon Valley/0 49.87,23.03
|only if rep("The Scryers") >= Neutral
step
talk Arcanist Thelis##21955
turnin The Ashtongue Corruptors##10685 |goto Shadowmoon Valley/0 56.29,59.51
accept The Warden's Cage##10686 |goto Shadowmoon Valley/0 56.29,59.51
|only if rep("The Scryers") >= Neutral
step
talk Sanoru##21826
|tip Enter the warden's cage and follow the ramp down.
turnin The Warden's Cage##10686 |goto Shadowmoon Valley/0 57.33,49.58
accept Proof of Allegiance##10622 |goto Shadowmoon Valley/0 57.33,49.58
|only if rep("The Scryers") >= Neutral
step
kill Zandras##21827 |q 10622/1 |goto Shadowmoon Valley/0 57.06,48.66
step
Run down the ramp |goto Shadowmoon Valley/0 57.34,49.66 < 7 |walk
talk Sanoru##21826
|tip Enter the warden's cage and follow the ramp down.
turnin Proof of Allegiance##10622 |goto Shadowmoon Valley/0 57.33,49.58
accept Akama##10628 |goto Shadowmoon Valley/0 57.32,49.58
step
Swim under the water |goto Shadowmoon Valley/0 57.73,48.00 < 7 |walk
talk Akama##21700
|tip He is inside the hidden chamber in the Warden's Cage.
|tip Follow the hallway to the first corridor on the right.
|tip Swim down the passage and exit out the water on the other side.
turnin Akama##10628 |goto Shadowmoon Valley/0 58.11,48.18
accept Seer Udalo##10705 |goto Shadowmoon Valley/0 58.11,48.18
step
talk Udalo##21962
|tip He's dead before the last boss's room in The Arcatraz dungeon.
turnin Seer Udalo##10705
accept A Mysterious Portent##10706
step
Run down the ramp |goto Shadowmoon Valley/0 57.34,49.66 < 7 |walk
Swim under the water |goto Shadowmoon Valley/0 57.73,48.00 < 7 |walk
talk Akama##21700
|tip He is inside the hidden chamber in the Warden's Cage.
|tip Follow the hallway to the first corridor on the right.
|tip Swim down the passage and exit out the water on the other side.
turnin A Mysterious Portent##10706 |goto Shadowmoon Valley/0 58.11,48.18
accept The Ata'mal Terrace##10707 |goto Shadowmoon Valley/0 58.11,48.18
step
kill Shadowlord Deathwail##22006
|tip This enemy is elite and may require a group of up to five people.
|tip He is flying above this area.
collect 1 Heart of Fury##31307 |q 10707/1 |goto Shadowmoon Valley/0 71.40,35.40
step
Run down the ramp |goto Shadowmoon Valley/0 57.34,49.66 < 7 |walk
Swim under the water |goto Shadowmoon Valley/0 57.73,48.00 < 7 |walk
talk Akama##21700
|tip He is inside the hidden chamber in the Warden's Cage.
|tip Follow the hallway to the first corridor on the right.
|tip Swim down the passage and exit out the water on the other side.
turnin The Ata'mal Terrace##10707 |goto Shadowmoon Valley/0 58.11,48.18
accept Akama's Promise##10708 |goto Shadowmoon Valley/0 58.11,48.18
step
talk A'dal##18481
turnin Akama's Promise##10708 |goto Shattrath City/0 53.99,44.77
step
talk Seer Olum##22820
|tip Inside Fathom-Lord Karathress's room of Serpentshrine Cavern.
|tip After you kill Fathom-Lord Karathress, Seer Olum will exit from the cage.
accept The Secret Compromised##10944
step
kill Lady Vashj##21212
|tip The final boss of the Serpentshrine Cavern raid.
collect 1 Vashj's Vial Remnant##29906 |q 10445/1
step
Run down the ramp |goto Shadowmoon Valley/0 57.34,49.66 < 7 |walk
Swim under the water |goto Shadowmoon Valley/0 57.73,48.00 < 7 |walk
talk Akama##21700
|tip He is inside the hidden chamber in the Warden's Cage.
|tip Follow the hallway to the first corridor on the right.
|tip Swim down the passage and exit out the water on the other side.
turnin The Secret Compromised##10944 |goto Shadowmoon Valley/0 58.11,48.18
accept Ruse of the Ashtongue##10946 |goto Shadowmoon Valley/0 58.11,48.18
step
use the Ashtongue Cowl##31946
|tip Use it inside the Tempest Keep raid before engaging Al'ar.
Gain the "Ashtongue Ruse" Buff |havebuff spell:39527 |q 10946
step
kill 1 Al'ar##19514 |q 10946/1
|tip The first boss inside the Tempest Keep raid.
|tip You must have the "Ashtongue Ruse" buff to complete this.
step
kill Kael'thas Sunstrider##19622
|tip The final boss of the Tempest Keep raid.
collect 1 Kael's Vial Remnant##29905 |q 10445/2
step
Run down the ramp |goto Shadowmoon Valley/0 57.34,49.66 < 7 |walk
Swim under the water |goto Shadowmoon Valley/0 57.73,48.00 < 7 |walk
talk Akama##21700
|tip He is inside the hidden chamber in the Warden's Cage.
|tip Follow the hallway to the first corridor on the right.
|tip Swim down the passage and exit out the water on the other side.
turnin Ruse of the Ashtongue##10946 |goto Shadowmoon Valley/0 58.11,48.18
accept An Artifact From the Past##10947 |goto Shadowmoon Valley/0 58.11,48.18
step
kill Rage Winterchill##17767
|tip Inside the Battle for Mount Hyjal raid.
collect 1 Time-Phased Phylactery##32459 |q 10947/1
step
Run down the ramp |goto Shadowmoon Valley/0 57.34,49.66 < 7 |walk
Swim under the water |goto Shadowmoon Valley/0 57.73,48.00 < 7 |walk
talk Akama##21700
|tip He is inside the hidden chamber in the Warden's Cage.
|tip Follow the hallway to the first corridor on the right.
|tip Swim down the passage and exit out the water on the other side.
turnin An Artifact From the Past##10947 |goto Shadowmoon Valley/0 58.11,48.18
accept The Hostage Soul##10948 |goto Shadowmoon Valley/0 58.11,48.18
step
talk A'dal##18481
turnin The Hostage Soul##10948 |goto Shattrath City/0 53.99,44.77
accept Entry Into the Black Temple##10949 Shattrath City/0 53.99,44.77
step
talk Xi'ri##18528
turnin Entry Into the Black Temple##10949 |goto Shadowmoon Valley/0 65.34,44.00
step
talk Xi'ri##18528
accept A Distraction for Akama##10985 |goto Shadowmoon Valley/0 65.34,44.00
step
talk Xi'ri##18528
Select _"I am ready to join your forces in battle Xi'ri."_
Watch the dialogue
|tip Follow Akama when he appears and help him.
|tip It may take 5-10 minutes for Akama to start.
Help Akama and Maiev Enter the Black Temple |q 10985/1 |goto Shadowmoon Valley/0 65.34,44.00
step
talk Xi'ri##18528
turnin A Distraction for Akama##10985 |goto Shadowmoon Valley/0 65.34,44.00
step
talk Soridormi##19935
|tip She walks around the Caverns of Time.
turnin The Vials of Eternity##10445 |goto Tanaris/0 60.55,54.67
step
_Congratulations!_
You Earned the "Hand of A'dal" Title.
]])
ZygorGuidesViewer:RegisterGuide("Titles\\Burning Crusade Titles\\Reputation\\of the Shattered Sun",{
author="support@zygorguides.com",
description="\nThis guide will walk you through obtaining the \"of the Shattered Sun\" title.",
playertitle=63,
startlevel=70,
},[[
step
Reach Exalted with the Shattered Sun Offensive |complete rep("Shattered Sun Offensive") >= Exalted
|tip Use the Shattered Sun Offensive daily quest guides to accomplish this.
|tip You can also run Magisters' Terrace.
step
Earn 1,000 Gold |complete _G.GetMoney() >= 10000000
|tip This title must be purchased for 1,000 gold.
step
Run up the ramp |goto Isle of Quel'Danas/0 52.10,32.23 < 20 |only if walking
talk Anchorite Kairthos##25163
|tip At the top of the building.
accept A Magnanimous Benefactor##11549 |goto Isle of Quel'Danas/0 51.18,33.13
step
talk Anchorite Kairthos##25163
|tip At the top of the building.
turnin A Magnanimous Benefactor##11549 |goto Isle of Quel'Danas/0 51.18,33.13
]])
