local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if UnitFactionGroup("player")~="Alliance" then return end
if ZGV:DoMutex("EventsA") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("Events Guides\\Brewfest\\Brewfest Quests",{
author="support@zygorguides.com",
condition_end=function() return completedq(12491) end,
description="\nThis guide section will walk you through completing the quests for the Brewfest event.",
},[[
step
talk Ipfelkofer Ironkeg##24710
accept Welcome to Brewfest!##11442 |goto Dun Morogh/0 48.01,39.83
step
talk Boxey Boltspinner##27215
accept Chug and Chuck!##12022 |goto Dun Morogh/0 47.56,39.84
step
click Alcohol-Free Brewfest Sampler##186189+
|tip They look like mugs of beer on the small tables inside this tent.
collect Alcohol-Free Brewfest Sampler##33096 |n
use the Alcohol-Free Brewfest Sampler##33096
|tip Face yourself towards the Self-Turning and Oscillating Utility Target behind the tent.
Hit the S.T.O.U.T. #5# Times |q 12022/1 |goto Dun Morogh/0 47.62,39.66
step
talk Boxey Boltspinner##27215
turnin Chug and Chuck!##12022 |goto Dun Morogh/0 47.56,39.84
step
talk Neill Ramstein##23558
accept Now This is Ram Racing... Almost.##11318 |goto Dun Morogh/0 46.57,40.30
step
As you run around on the ram:
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip You have to use the Ram Racing Reins to make it run at certain speeds for 8 seconds.
|tip To make the ram Trot for 8 seconds, use the Giddyup! ability every 2 seconds or so.
Maintain a Trot for 8 seconds |q 11318/1
step
As you run around on the ram:
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip You have to use the Ram Racing Reins to make it run at certain speeds for 8 seconds.
|tip To make the ram Canter for 8 seconds, use the Ram Racing Reins a little more often than when you made the ram Trot.
Maintain a Canter for 8 seconds |q 11318/2
step
As you run around on the ram:
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip You have to use the Ram Racing Reins to make it run at certain speeds for 8 seconds.
|tip To make the ram Gallop, just spam the Ram Racing Reins.
Maintain a Gallop for 8 seconds |q 11318/3
step
Stop Riding the Ram |nobuff spell:43883 |q 11318
|tip Right-click the "Ramstein's Swift Work Ram" buff on your buff bar.
step
talk Neill Ramstein##23558
turnin Now This is Ram Racing... Almost.##11318 |goto Dun Morogh/0 46.57,40.30
accept There and Back Again##11122 |goto Dun Morogh/0 46.57,40.30
step
map Dun Morogh/0
path follow strictbounce; loop off; ants curved; dist 25
path	46.43,40.40	46.33,41.36	47.10,43.16	47.55,44.45	47.20,45.05
path	46.46,47.95	47.11,49.23	46.78,49.95	46.36,51.05	46.38,53.16
path	46.35,53.79
Follow the waypoint path:
use the Ram Racing Reins##33306
|tip Alternate between Canter and Gallop as needed to keep your fatigue below 100 between buckets.
|tip Ride over buckets of apples to refresh your Ram's fatigue level.
Flynn Firebrew will throw you a keg when you get close
Once you have a keg, run back and turn it in to Pol Amberstill
|tip Just get near him and you will throw the keg to him.
Deliver 3 Kegs in Under 4 Minutes |q 11122/1
|tip If you lose your ram, return to Neill Ramstein to acquire another.
step
Stop Riding the Ram |nobuff spell:43880 |q 11122
|tip Right-click the "Ramstein's Swift Work Ram" buff on your buff bar.
step
talk Neill Ramstein##23558
turnin There and Back Again##11122 |goto Dun Morogh/0 46.57,40.30
step
talk Pol Amberstill##24468
accept Say, There Wouldn't Happen to be a Souvenir This Year, Would There?##12193 |goto Dun Morogh/0 46.43,40.31
step
talk Belbi Quikswitch##23710
turnin Say, There Wouldn't Happen to be a Souvenir This Year, Would There?##12193 |goto Dun Morogh/0 49.27,39.59
step
Reach Level 65 |ding 65
|tip Coren Direbrew is level 73 elite.
step
talk Darna Honeybock##27584
accept Save Brewfest!##12318 |goto Dun Morogh/0 45.86,52.69
|tip This quest is elite and will require a group.
step
Enter the Blackrock Depths Dungeon with your Group |goto Blackrock Depths/0 0,0 |q 12062 |future
step
talk Brewfest Spy##26719
|tip After defeating the Dark Iron ambush, interact with the Mole Machine Consoles at the beginning of the dungeon.
|tip Inside the Grim Guzzler in the Blackrock Depths dungeon.
turnin Save Brewfest!##12318
accept Insult Coren Direbrew##12062
|tip This quest is elite and will require a group.
step
talk Coren Direbrew##23872
|tip Inside the Grim Guzzler in the Blackrock Depths dungeon.
turnin Insult Coren Direbrew##12062
|tip This quest is elite and will require a group.
step
kill Coren Direbrew##23872
|tip Form a group and travel to the Blackrock Depths dungeon.
|tip Someone with the daily quest "Insult Coren Direbrew" can talk to him to make him hostile.
|tip This quest is available in the Grim Guzzler in Blackrock Depths.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Brewfest\\Brewfest Dailies",{
author="support@zygorguides.com",
description="\nThis guide section will walk you through completing the daily quests for the Brewfest event.",
},[[
step
Complete the "Brewfest Quests" Guide |complete completedq(12193)
|tip Complete the "Say, There Wouldn't Happen to be a Souvenir This Year, Would There?" quest.
step
label "Begin_Dailies"
talk Becan Barleybrew##23627
accept Bark for the Barleybrews!##11293 |goto Dun Morogh/0 49.01,39.81 |or
talk Daran Thunderbrew##23628
accept Bark for the Thunderbrews!##11294 |goto Dun Morogh/0 56.00,38.06 |or
|tip You will only be able to accept one of these quests per day.
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
Ride your ram into Ironforge |goto Ironforge/0 15.98,84.87 < 30 |c |q 11293
|only if haveq(11293)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
Ride your ram into Ironforge |goto Dun Morogh/0 60.60,33.17 |noway |c |q 11294
|only if haveq(11294)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark Outside the Bank |q 11293/1 |goto Ironforge/0 31.76,66.83
|only if haveq(11293)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark in the Military Ward |q 11293/2 |goto Ironforge/0 61.12,80.00
|only if haveq(11293)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark in the Hall of Explorers |q 11293/3 |goto Ironforge/0 65.54,24.24
|only if haveq(11293)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark in the Mystic Ward |q 11293/4 |goto Ironforge/0 29.46,14.44
|only if haveq(11293)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark Outside the Bank |q 11294/1 |goto Ironforge/0 31.76,66.83
|only if haveq(11294)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark in the Military Ward |q 11294/2 |goto Ironforge/0 61.12,80.00
|only if haveq(11294)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark in the Hall of Explorers |q 11294/3 |goto Ironforge/0 65.54,24.24
|only if haveq(11294)
step
use the Ram Racing Reins##33306
|tip The ram runs slow by default.
|tip Keep a Trot pace most of the time and only Canter occasionally.
|tip Your ram will become exhausted if you go too fast.
|tip Ride around the outer ring of Ironforge.
Bark in the Mystic Ward |q 11294/4 |goto Ironforge/0 29.46,14.44
|only if haveq(11294)
step
Stop Riding the Ram |nobuff spell:43883
|tip Right-click the "Rental Racing Ram" buff on your buff bar.
step
talk Becan Barleybrew##23627
turnin Bark for the Barleybrews!##11293 |goto Dun Morogh/0 49.01,39.81
|only if haveq(11293)
step
talk Daran Thunderbrew##23628
turnin Bark for the Thunderbrews!##11294 |goto Dun Morogh/0 56.58,36.91
|only if haveq(11294)
step
Wait for the Dark Iron Defense event to start
|tip You have to defend the three kegs at these locations in order to complete it.
click Complimentary Brewfest Sampler##186189+
use the Alcohol-Free Brewfest Sampler##33096
|tip Use it to throw it at the Dark Iron Dwarves and the Mole Machines around this area.
click Dark Iron Mole Machine Wreckage##189989
|tip It looks like a big metal gear laying on ground in the middle of the festival.
|tip It appears after the Dark Iron dwarves attack the Brewfest festival, so you may have to wait for it to appear.
accept This One Time, When I Was Drunk...##12020 |goto Dun Morogh/0 48.69,39.13
step
talk Bizzle Quicklift##27216
turnin This One Time, When I Was Drunk...##12020 |goto Dun Morogh/0 45.25,17.33
step
Reach Level 65 |ding 65 |or
|tip Coren Direbrew is level 73 elite.
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
talk Darna Honeybock##27584
accept Save Brewfest!##12318 |goto Dun Morogh/0 45.86,52.69 |or
|tip This quest is elite and will require a group.
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
Enter the Blackrock Depths Dungeon with your Group |goto Blackrock Depths/0 0,0 |q 12062 |future |or
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
talk Brewfest Spy##26719
|tip After defeating the Dark Iron ambush, interact with the Mole Machine Consoles at the beginning of the dungeon.
|tip Inside the Grim Guzzler in the Blackrock Depths dungeon.
turnin Save Brewfest!##12318 |or
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
talk Brewfest Spy##26719
|tip Inside the Grim Guzzler in the Blackrock Depths dungeon.
accept Insult Coren Direbrew##12062 |or
|tip This quest is elite and will require a group.
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
talk Coren Direbrew##23872
|tip Inside the Grim Guzzler in the Blackrock Depths dungeon.
turnin Insult Coren Direbrew##12062 |or
|tip This quest is elite and will require a group.
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
kill Coren Direbrew##23872
|tip Form a group and travel to the Blackrock Depths dungeon.
|tip Someone with the daily quest "Insult Coren Direbrew" can talk to him to make him hostile.
|tip This quest is available in the Grim Guzzler in Blackrock Depths.
Click Here to Continue |confirm |or
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies" |or
step
You have completed the available daily quests
|tip This guide will reset when more become available.
'|complete not completedq(11293,11294,12020) |next "Begin_Dailies"
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Children's Week\\Children's Week Main Questline",{
author="support@zygorguides.com",
description="This guide will walk you through the quests for the \"Children's Week\" event.",
condition_end=function() return completedq(171) end,
},[[
step
talk Orphan Matron Nightingale##14450
Select _"Well what do you know, this is Children's Week! What can I do to help?"_
accept Children's Week##1468 |goto Stormwind City 47.35,38.19
step
talk Emmithue Smails##14481
buy 1 Tigule and Foror's Strawberry Ice Cream##7228 |goto Stormwind City 53.79,65.38 |q 4822 |future
step
use the Human Orphan Whistle##18598
_Next to you:_
talk Human Orphan##14305
turnin Children's Week##1468
accept The Bough of the Eternals##1479
accept The Stonewrought Dam##1558
accept Spooky Lighthouse##1687
step
use the Human Orphan Whistle##18598
Go to the Westfall Lighthouse |q 1687/1 |goto Westfall 30.52,85.82
step
use the Human Orphan Whistle##18598
Go to the Top of the Stonewrought Dam |q 1558/1 |goto Loch Modan 48.26,14.11
step
use the Human Orphan Whistle##18598
Go to the Bank in Darnassus |q 1479/1 |goto Darnassus 41.04,42.91
step
use the Human Orphan Whistle##18598
_Next to you:_
talk Human Orphan##14305
turnin The Bough of the Eternals##1479
turnin The Stonewrought Dam##1558
turnin Spooky Lighthouse##1687
accept You Scream, I Scream...##4822
accept Jaina's Autograph##558
step
Enter the building |goto Dustwallow Marsh 65.74,48.63 < 10 |walk
talk Lady Jaina Proudmoore##4968
|tip Inside at the top of the tower.
|tip She walks around the area.
Select _"Lady Jaina, this may sound like an odd request..."_
collect Jaina's Autograph##18642 |goto Dustwallow Marsh 66.25,49.04 |q 558
step
use the Human Orphan Whistle##18598
_Next to you:_
talk Human Orphan##14305
turnin You Scream, I Scream...##4822
turnin Jaina's Autograph##558
accept A Warden of the Alliance##171
step
talk Orphan Matron Nightingale##14450
turnin A Warden of the Alliance##171 |goto Stormwind City 47.35,38.19
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Sayge's Fortunes (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nReceive a stat buff and have your fortune told by Sayge at the Darkmoon Faire.",
model={491},
},[[
step
label "Choose_Fortune"
Choose the buff you would like to receive:
|tip The buff lasts for two hours.
|tip You can have your fortune told every four hours.
|tip NOTE: You will not be able to receive the written fortune and potential quest without an open inventory slot.
+10% Agility |confirm |next "Agility_Buff"
+10% Intelligence |confirm |next "Intelligence_Buff"
+10% Spirit |confirm |next "Spirit_Buff"
+10% Stamina |confirm |next "Stamina_Buff"
+10% Strength |confirm |next "Strength_Buff"
+10% Armor |confirm |next "Armor_Buff"
+25 All Resistances |confirm |next "Resistance_Buff"
+10% Damage |confirm |next "Damage_Buff"
step
label "Agility_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I confiscate the corn he has stolen, warn him that stealing is a path towards doom and destruction, but I let him go to return to his family."_
Select _"I would create some surreptitious means to keep my brother out of the order."_
Gain the "Sayge's Dark Fortune of Agility" Buff |havebuff spell:23736 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Intelligence_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I turn over the man to my liege for punishment, as he has broken the law of the land and it is my sworn duty to enforce it."_
Select _"I quietly ignore the insult."_
Gain the "Sayge's Dark Fortune of Intelligence" Buff |havebuff spell:23766 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Spirit_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I turn over the man to my liege for punishment, as he has broken the law of the land and it is my sworn duty to enforce it."_
Select _"I confront the ruler on his malicious behavior, upholding my liege's honor at the risk of any future diplomacy."_
Gain the "Sayge's Dark Fortune of Spirit" Buff |havebuff spell:23738 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Stamina_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I confiscate the corn he has stolen, warn him that stealing is a path towards doom and destruction, but I let him go to return to his family."_
Select _"I would speak against my brother joining the order, rushing a permanent breech in our relationship."_
Gain the "Sayge's Dark Fortune of Stamina" Buff |havebuff spell:23737 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Strength_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I confiscate the corn he has stolen, warn him that stealing is a path towards doom and destruction, but I let him go to return to his family."_
Select _"I would speak for my brother joining the order, potentially risking the safety of the order."_
Gain the "Sayge's Dark Fortune of Strength" Buff |havebuff spell:23735 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Armor_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I slay the man on the spot as my liege would expect me to do, as he is nothing more than a thief and a liar."_
Select _"I risk my own life and free him so that he may prove his innocence."_
Gain the "Sayge's Dark Fortune of Armor" Buff |havebuff spell:23767 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Resistance_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I slay the man on the spot as my liege would expect me to do, as he is nothing more than a thief and a liar."_
Select _"I execute him as per my liege's instructions, but doing so in as painless of a way as possible."_
Gain the "Sayge's Dark Fortune of Resistance" Buff |havebuff spell:23769 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Damage_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I slay the man on the spot as my liege would expect me to do, as he is nothing more than a thief and a liar."_
Select _"I execute him as per my liege's instructions, and do it in such a manner that he suffers painfully before he dies as retribution for his crimes against my people."_
Gain the "Sayge's Dark Fortune of Damage" Buff |havebuff spell:23768 |goto Elwynn Forest 42.12,69.00 |next "Use_Darkmoon_Faire_Fortune"
step
label "Use_Darkmoon_Faire_Fortune"
talk Sayge##14822
Select _"I'd love to get one of those written fortunes you mentioned!"_
collect 1 Darkmoon Faire Fortune##19422 |goto Elwynn Forest 42.12,69.00
step
use the Darkmoon Faire Fortune##19422
Obtain Your Fortune |condition itemcount(19422) == 0
step
label "Fortune_Told"
You have received your fortune
|tip You can have your fortune told every four hours.
Click Here to Choose Another Fortune |confirm |next "Choose_Fortune" |or
'|condition itemcount(19423) == 1 and not completedq(7937) and level >= 10 |next "Fortune_Awaits_Eastvale" |or
'|condition itemcount(19424) == 1 and not completedq(7938) and level >= 10 |next "Fortune_Awaits_Deadmines" |or
'|condition itemcount(19443) == 1 and not completedq(7944) and level >= 10 |next "Fortune_Awaits_Wailing_Caverns" |or
'|condition itemcount(19452) == 1 and not completedq(7945) and level >= 10 |next "Fortune_Awaits_Palemane_Rock" |or
step
label "Fortune_Awaits_Eastvale"
use Sayge's Fortune #23##19423
accept Your Fortune Awaits You...##7937
step
click Mysterious Eastvale Haystack
turnin Your Fortune Awaits You...##7937 |goto Elwynn Forest 84.79,64.37 |next "Fortune_Told"
step
label "Fortune_Awaits_Deadmines"
use Sayge's Fortune #24##19424
accept Your Fortune Awaits You...##7938
step
click Mysterious Deadmines Chest
|tip Just inside The Deadmines instance before you reach the first Miner.
|tip It may take a minute or two to appear.
turnin Your Fortune Awaits You...##7938 |next "Fortune_Told"
step
label "Fortune_Awaits_Wailing_Caverns"
use Sayge's Fortune #25##19443
accept Your Fortune Awaits You...##7944
step
click Mysterious Wailing Caverns Chest
|tip Just inside the Wailing Caverns instance after the Disciple of Naralex.
|tip It may take a minute or two to appear.
turnin Your Fortune Awaits You...##7944 |next "Fortune_Told"
step
label "Fortune_Awaits_Palemane_Rock"
use Sayge's Fortune #27##19452
accept Your Fortune Awaits You...##7945
step
click Mysterious Tree Stump
turnin Your Fortune Awaits You...##7945 |goto Mulgore 34.99,61.56 |next "Fortune_Told"
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Chronos Turn-Ins (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nExchange various Leatherworking crafted items with Chronos for prize tickets at the Darkmoon Faire.",
model={14875},
},[[
step
collect 3 Embossed Leather Boots##2309 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept Carnival Boots##7881 |goto Elwynn Forest 43.57,70.86 |or
|tip Each turnin requires 3 Embossed Leather Boots and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
collect 3 Toughened Leather Armor##2314 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept Carnival Jerkins##7882 |goto Elwynn Forest 43.57,70.86 |or
|tip Each turnin requires 3 Toughened Leather Armors and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
collect 3 Barbaric Harness##5739 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept The World's Largest Gnome!##7883 |goto Elwynn Forest 43.57,70.86 |or
|tip Each turnin requires 3 Barbaric Harnesses and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
collect 1 Turtle Scale Leggings##8185 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept Crocolisk Boy and the Bearded Murloc##7884 |goto Elwynn Forest 43.57,70.86 |or
|tip Each turnin requires 1 Turtle Scale Leggings and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
collect 8 Rugged Armor Kit##15564 |q 7885 |future
|tip Create them with Leatherworking or purchase them from the Auction House.
step
talk Chronos##14833
accept Armor Kits##7885 |goto Elwynn Forest 43.57,70.86
step
collect 8 Rugged Armor Kit##15564 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept More Armor Kits##7941 |goto Elwynn Forest 43.57,70.86 |or
|tip From this point on, you can continue turning in Rugged Armor Kits.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 8 Rugged Armor Kits and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Kerri Hicks Turn-Ins (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nExchange various Blacksmithing crafted items with Kerri Hicks for prize tickets at the Darkmoon Faire.",
model={14876},
},[[
step
collect 10 Coarse Weightstone##3240 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Coarse Weightstone##7889 |goto Elwynn Forest 40.48,69.93 |or
|tip Each turnin requires 10 Coarse Weightstones and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
collect 7 Heavy Grinding Stone##3486 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Heavy Grinding Stone##7890 |goto Elwynn Forest 40.48,69.93 |or
|tip Each turnin requires 7 Heavy Grinding Stones and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
collect 3 Green Iron Bracers##3835 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Green Iron Bracers##7891 |goto Elwynn Forest 40.48,69.93 |or
|tip Each turnin requires 3 Green Iron Bracers and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
collect 1 Big Black Mace##7945 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Big Black Mace##7892 |goto Elwynn Forest 40.48,69.93 |or
|tip Each turnin requires 1 Big Black Mace and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
collect 8 Dense Grinding Stone##12644 |q 7893 |future
|tip Create them with Blacksmithing or purchase them from the Auction House.
step
talk Kerri Hicks##14832
accept Rituals of Strength##7893 |goto Elwynn Forest 40.48,69.93
step
collect 8 Dense Grinding Stone##12644 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept More Dense Grinding Stones##7939 |goto Elwynn Forest 40.48,69.93 |or
|tip From this point on, you can continue turning in Dense Grinding Stones.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 8 Dense Grinding Stones and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Rinling Turn-Ins (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nExchange various Engineering crafted items with Rinling for prize tickets at the Darkmoon Faire.",
model={14877},
},[[
step
collect 5 Copper Modulator##4363 |n
|tip Create them with Engineering or purchase them from the Auction House.
|tip They also have a small chance to drop from mobs in the Gnomeregan dungeon.
talk Rinling##14841
accept Copper Modulator##7894 |goto Elwynn Forest 41.71,70.72 |or
|tip Each turnin requires 5 Copper Modulators and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
collect 7 Whirring Bronze Gizmo##4375 |n
|tip Create them with Engineering or purchase them from the Auction House.
talk Rinling##14841
accept Whirring Bronze Gizmo##7895 |goto Elwynn Forest 41.71,70.72 |or
|tip Each turnin requires 7 Whirring Bronze Gizmos and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
collect 36 Green Firework##9313 |n
|tip Create them with Engineering or purchase them from the Auction House.
|tip They can also be purchased from any Holiday Fireworks Vendor on July 4th.
talk Rinling##14841
accept Green Fireworks##7896 |goto Elwynn Forest 41.71,70.72 |or
|tip Each turnin requires 36 Green Fireworks and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
collect 6 Mechanical Repair Kit##11590 |n
|tip Create them with Engineering or purchase them from the Auction House.
talk Rinling##14841
accept Mechanical Repair Kits##7897 |goto Elwynn Forest 41.71,70.72 |or
|tip Each turnin requires 6 Mechanical Repair Kits and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
collect 6 Thorium Widget##15994 |q 7898 |future
|tip Create them with Engineering or purchase them from the Auction House.
step
talk Rinling##14841
accept Thorium Widget##7898 |goto Elwynn Forest 41.71,70.72
step
collect 6 Thorium Widget##15994 |n
|tip Create them with Engineering or purchase them from the Auction House.
talk Rinling##14841
accept More Thorium Widgets##7942 |goto Elwynn Forest 41.71,70.72 |or
|tip From this point on, you can continue turning in Thorium Widgets.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 6 Thorium Widgets and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Yebb Neblegear Turn-Ins (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nExchange various Farmed items with Yebb Neblegear for prize tickets at the Darkmoon Faire.",
model={14856},
},[[
step
Kill Savannah enemies around this area
|tip You can find them all over around Crossroads and to its northern area.
collect 5 Small Furry Paw##5134 |goto The Barrens 50.21,21.82 |n
talk Yebb Neblegear##14829
accept Small Furry Paws##7899 |goto Elwynn Forest 40.17,69.53 |or
|tip Each turnin requires 5 Small Furry Paws and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
Kill Ashenvale Bear enemies around this area
|tip You can find them all over between Raynewood Retreat and Splintertree post.
|tip You can also find them east of Satyrn.
collect 5 Torn Bear Pelt##11407 |goto Ashenvale 66.01,60.42 |n
You can find more around [Ashenvale 83.81,47.40]
talk Yebb Neblegear##14829
accept Torn Bear Pelts##7900 |goto Elwynn Forest 40.17,69.53 |or
|tip Each turnin requires 5 Torn Bear Pelts and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
Kill Crag Coyote enemies around this area
|tip You can find the all over central and western Badlands.
collect 5 Soft Bushy Tail##4582 |goto Badlands 34.41,65.63 |n
You can find more around [Badlands 57.00,58.62]
talk Yebb Neblegear##14829
accept Soft Bushy Tails##7901 |goto Elwynn Forest 40.17,69.53 |or
|tip Each turnin requires 5 Soft Bushy Tails and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
Kill Northspring enemies around this area
collect 5 Vibrant Plume##5117 |goto Feralas 40.00,12.61 |n
talk Yebb Neblegear##14829
accept Vibrant Plumes##7902 |goto Elwynn Forest 40.17,69.53 |or
|tip Each turnin requires 5 Vibrant Plumes and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
Kill Stonelash enemies around this area
|tip You can find them all over central and southern Silithus.
collect 10 Glowing Scorpid Blood##19933 |goto Silithus 44.81,54.50 |q 8222 |future
step
talk Yebb Neblegear##14829
accept Glowing Scorpid Blood##8222 |goto Elwynn Forest 40.17,69.53
step
Kill Stonelash enemies around this area
|tip You can find them all over central and southern Silithus.
collect 10 Glowing Scorpid Blood##19933 |goto Silithus 44.81,54.50 |n
talk Yebb Neblegear##14829
accept More Glowing Scorpid Blood##8223 |goto Elwynn Forest 40.17,69.53
|tip From this point on, you can continue turning in Glowing Scorpid Blood.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 10 Glowing Scorpid Blood and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Spawn of Jubjub (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nCollect a couple of Dark Iron Ale Mugs from the Grim Guzzler tavern in Blackrock Depths "..
"and offer them to Morja at the Darkmoon Faire to receive your very own Jubjub companion pet.",
condition_end=function() return completedq(7946) end,
model={14938},
},[[
step
click Dark Iron Ale Mug##165738
|tip They look like small mugs of ale on tables around the Grim Guzzler tavern in Blackrock Depths.
|tip Clicking two of them is safe but clicking more will anger the bar patrons.
collect 2 Dark Iron Ale Mug##11325 |q 7946 |future
|tip They can also be purchased from Plugger Spazzring in the Grim Guzzler.
|tip They can be purchased from the Auction House if you are lucky enough to find them.
step
use the Dark Iron Ale Mug##11325
|tip Place it at Morja's feet.
|tip Be sure you only use one; you will need the other one to turn in the quest.
Wait for Jubjub the frog to hop over to the mug
|tip This may take a couple of minutes.
talk Morja##14871
accept Spawn of Jubjub##7946 |goto Elwynn Forest 43.33,70.29
|tip This quest will be available after Jubjub appears.
step
use the Unhatched Jubling Egg##19462
|tip It will take seven days for the egg to mature enough to hatch.
collect 1 A Jubling's Tiny Home##19450
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Wood Frog (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nCatch Flik as he runs all over the Darkmoon Faire grounds and purchase his limited supply "..
"Wood Frog Box for 1 gold.",
model={901},
},[[
step
talk Flik##14860
|tip He's a little Orc boy running fast all over the Darkmoon Faire grounds.
|tip You will have to be quick to catch him.
|tip Talking to him will stop him for a short period of time.
buy 1 Wood Frog Box##11027 |goto Elwynn Forest 42.59,70.30
|tip This item costs 1 gold and has a limited quantity of 1.
|tip It respawns in approximately 20 minutes.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Elwynn Forest\\Tree Frog (Elwynn Forest)",{
author="support@zygorguides.com",
description="\nCatch Flik as he runs all over the Darkmoon Faire grounds and purchase his "..
"Tree Frog Box for 1 gold.",
model={6295},
},[[
step
talk Flik##14860
|tip He's a little Orc boy running fast all over the Darkmoon Faire grounds.
|tip You will have to be quick to catch him.
|tip Talking to him will stop him for a short period of time.
buy 1 Tree Frog Box##11026 |goto Elwynn Forest 42.59,70.30
|tip This item costs 1 gold.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Sayge's Fortunes (Mulgore)",{
author="support@zygorguides.com",
description="\nReceive a stat buff and have your fortune told by Sayge at the Darkmoon Faire.",
model={491},
},[[
step
label "Choose_Fortune"
Choose the buff you would like to receive:
|tip The buff lasts for two hours.
|tip You can have your fortune told every four hours.
|tip NOTE: You will not be able to receive the written fortune and potential quest without an open inventory slot.
+10% Agility |confirm |next "Agility_Buff"
+10% Intelligence |confirm |next "Intelligence_Buff"
+10% Spirit |confirm |next "Spirit_Buff"
+10% Stamina |confirm |next "Stamina_Buff"
+10% Strength |confirm |next "Strength_Buff"
+10% Armor |confirm |next "Armor_Buff"
+25 All Resistances |confirm |next "Resistance_Buff"
+10% Damage |confirm |next "Damage_Buff"
step
label "Agility_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I confiscate the corn he has stolen, warn him that stealing is a path towards doom and destruction, but I let him go to return to his family."_
Select _"I would create some surreptitious means to keep my brother out of the order."_
Gain the "Sayge's Dark Fortune of Agility" Buff |havebuff spell:23736 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Intelligence_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I turn over the man to my liege for punishment, as he has broken the law of the land and it is my sworn duty to enforce it."_
Select _"I quietly ignore the insult."_
Gain the "Sayge's Dark Fortune of Intelligence" Buff |havebuff spell:23766 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Spirit_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I turn over the man to my liege for punishment, as he has broken the law of the land and it is my sworn duty to enforce it."_
Select _"I confront the ruler on his malicious behavior, upholding my liege's honor at the risk of any future diplomacy."_
Gain the "Sayge's Dark Fortune of Spirit" Buff |havebuff spell:23738 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Stamina_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I confiscate the corn he has stolen, warn him that stealing is a path towards doom and destruction, but I let him go to return to his family."_
Select _"I would speak against my brother joining the order, rushing a permanent breech in our relationship."_
Gain the "Sayge's Dark Fortune of Stamina" Buff |havebuff spell:23737 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Strength_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I confiscate the corn he has stolen, warn him that stealing is a path towards doom and destruction, but I let him go to return to his family."_
Select _"I would speak for my brother joining the order, potentially risking the safety of the order."_
Gain the "Sayge's Dark Fortune of Strength" Buff |havebuff spell:23735 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Armor_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I slay the man on the spot as my liege would expect me to do, as he is nothing more than a thief and a liar."_
Select _"I risk my own life and free him so that he may prove his innocence."_
Gain the "Sayge's Dark Fortune of Armor" Buff |havebuff spell:23767 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Resistance_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I slay the man on the spot as my liege would expect me to do, as he is nothing more than a thief and a liar."_
Select _"I execute him as per my liege's instructions, but doing so in as painless of a way as possible."_
Gain the "Sayge's Dark Fortune of Resistance" Buff |havebuff spell:23769 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Damage_Buff"
talk Sayge##14822
Choose _"I am ready to discover where my fortune lies!"_
Select _"I slay the man on the spot as my liege would expect me to do, as he is nothing more than a thief and a liar."_
Select _"I execute him as per my liege's instructions, and do it in such a manner that he suffers painfully before he dies as retribution for his crimes against my people."_
Gain the "Sayge's Dark Fortune of Damage" Buff |havebuff spell:23768 |goto Mulgore 36.92,38.37 |next "Use_Darkmoon_Faire_Fortune"
step
label "Use_Darkmoon_Faire_Fortune"
talk Sayge##14822
Select _"I'd love to get one of those written fortunes you mentioned!"_
collect 1 Darkmoon Faire Fortune##19422 |goto Mulgore 36.92,38.37
step
use the Darkmoon Faire Fortune##19422
Obtain Your Fortune |condition itemcount(19422) == 0
step
label "Fortune_Told"
You have received your fortune
|tip You can have your fortune told every four hours.
Click Here to Choose Another Fortune |confirm |next "Choose_Fortune" |or
'|condition itemcount(19423) == 1 and not completedq(7937) and level >= 10 |next "Fortune_Awaits_Eastvale" |or
'|condition itemcount(19424) == 1 and not completedq(7938) and level >= 10 |next "Fortune_Awaits_Deadmines" |or
'|condition itemcount(19443) == 1 and not completedq(7944) and level >= 10 |next "Fortune_Awaits_Wailing_Caverns" |or
'|condition itemcount(19452) == 1 and not completedq(7945) and level >= 10 |next "Fortune_Awaits_Palemane_Rock" |or
step
label "Fortune_Awaits_Eastvale"
use Sayge's Fortune #23##19423
accept Your Fortune Awaits You...##7937
step
click Mysterious Eastvale Haystack
turnin Your Fortune Awaits You...##7937 |goto Elwynn Forest 84.79,64.37 |next "Fortune_Told"
step
label "Fortune_Awaits_Deadmines"
use Sayge's Fortune #24##19424
accept Your Fortune Awaits You...##7938
step
click Mysterious Deadmines Chest
|tip Just inside The Deadmines instance before you reach the first Miner.
|tip It may take a minute or two to appear.
turnin Your Fortune Awaits You...##7938 |next "Fortune_Told"
step
label "Fortune_Awaits_Wailing_Caverns"
use Sayge's Fortune #25##19443
accept Your Fortune Awaits You...##7944
step
click Mysterious Wailing Caverns Chest
|tip Just inside the Wailing Caverns instance after the Disciple of Naralex.
|tip It may take a minute or two to appear.
turnin Your Fortune Awaits You...##7944 |next "Fortune_Told"
step
label "Fortune_Awaits_Palemane_Rock"
use Sayge's Fortune #27##19452
accept Your Fortune Awaits You...##7945
step
click Mysterious Tree Stump
turnin Your Fortune Awaits You...##7945 |goto Mulgore 34.99,61.56 |next "Fortune_Told"
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Chronos Turn-Ins (Mulgore)",{
author="support@zygorguides.com",
description="\nExchange various Leatherworking crafted items with Chronos for prize tickets at the Darkmoon Faire.",
model={14875},
},[[
step
collect 3 Embossed Leather Boots##2309 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept Carnival Boots##7881 |goto Mulgore 36.15,35.18 |or
|tip Each turnin requires 3 Embossed Leather Boots and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
collect 3 Toughened Leather Armor##2314 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept Carnival Jerkins##7882 |goto Mulgore 36.15,35.18 |or
|tip Each turnin requires 3 Toughened Leather Armors and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
collect 3 Barbaric Harness##5739 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept The World's Largest Gnome!##7883 |goto Mulgore 36.15,35.18 |or
|tip Each turnin requires 3 Barbaric Harnesses and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
collect 1 Turtle Scale Leggings##8185 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept Crocolisk Boy and the Bearded Murloc##7884 |goto Mulgore 36.15,35.18 |or
|tip Each turnin requires 1 Turtle Scale Leggings and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
collect 8 Rugged Armor Kit##15564 |q 7885 |future
|tip Create them with Leatherworking or purchase them from the Auction House.
step
talk Chronos##14833
accept Armor Kits##7885 |goto Mulgore 36.15,35.18
step
collect 8 Rugged Armor Kit##15564 |n
|tip Create them with Leatherworking or purchase them from the Auction House.
talk Chronos##14833
accept More Armor Kits##7941 |goto Mulgore 36.15,35.18 |or
|tip From this point on, you can continue turning in Rugged Armor Kits.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 8 Rugged Armor Kits and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Kerri Hicks Turn-Ins (Mulgore)",{
author="support@zygorguides.com",
description="\nExchange various Blacksmithing crafted items with Kerri Hicks for prize tickets at the Darkmoon Faire.",
model={14876},
},[[
step
collect 10 Coarse Weightstone##3240 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Coarse Weightstone##7889 |goto Mulgore 37.87,39.83 |or
|tip Each turnin requires 10 Coarse Weightstones and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
collect 7 Heavy Grinding Stone##3486 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Heavy Grinding Stone##7890 |goto Mulgore 37.87,39.83 |or
|tip Each turnin requires 7 Heavy Grinding Stones and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
collect 3 Green Iron Bracers##3835 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Green Iron Bracers##7891 |goto Mulgore 37.87,39.83 |or
|tip Each turnin requires 3 Green Iron Bracers and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
collect 1 Big Black Mace##7945 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept Big Black Mace##7892 |goto Mulgore 37.87,39.83 |or
|tip Each turnin requires 1 Big Black Mace and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
collect 8 Dense Grinding Stone##12644 |q 7893 |future
|tip Create them with Blacksmithing or purchase them from the Auction House.
step
talk Kerri Hicks##14832
accept Rituals of Strength##7893 |goto Mulgore 37.87,39.83
step
collect 8 Dense Grinding Stone##12644 |n
|tip Create them with Blacksmithing or purchase them from the Auction House.
talk Kerri Hicks##14832
accept More Dense Grinding Stones##7939 |goto Mulgore 37.87,39.83 |or
|tip From this point on, you can continue turning in Dense Grinding Stones.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 8 Dense Grinding Stones and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Rinling Turn-Ins (Mulgore)",{
author="support@zygorguides.com",
description="\nExchange various Engineering crafted items with Rinling for prize tickets at the Darkmoon Faire.",
model={14877},
},[[
step
collect 5 Copper Modulator##4363 |n
|tip Create them with Engineering or purchase them from the Auction House.
|tip They also have a small chance to drop from mobs in the Gnomeregan dungeon.
talk Rinling##14841
accept Copper Modulator##7894 |goto Mulgore 37.12,37.31 |or
|tip Each turnin requires 5 Copper Modulators and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
collect 7 Whirring Bronze Gizmo##4375 |n
|tip Create them with Engineering or purchase them from the Auction House.
talk Rinling##14841
accept Whirring Bronze Gizmo##7895 |goto Mulgore 37.12,37.31 |or
|tip Each turnin requires 7 Whirring Bronze Gizmos and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
collect 36 Green Firework##9313 |n
|tip Create them with Engineering or purchase them from the Auction House.
|tip They can also be purchased from any Holiday Fireworks Vendor on July 4th.
talk Rinling##14841
accept Green Fireworks##7896 |goto Mulgore 37.12,37.31 |or
|tip Each turnin requires 36 Green Fireworks and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
collect 6 Mechanical Repair Kit##11590 |n
|tip Create them with Engineering or purchase them from the Auction House.
talk Rinling##14841
accept Mechanical Repair Kits##7897 |goto Mulgore 37.12,37.31 |or
|tip Each turnin requires 6 Mechanical Repair Kits and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
collect 6 Thorium Widget##15994 |q 7898 |future
|tip Create them with Engineering or purchase them from the Auction House.
step
talk Rinling##14841
accept Thorium Widget##7898 |goto Mulgore 37.12,37.31
step
collect 6 Thorium Widget##15994 |n
|tip Create them with Engineering or purchase them from the Auction House.
talk Rinling##14841
accept More Thorium Widgets##7942 |goto Mulgore 37.12,37.31 |or
|tip From this point on, you can continue turning in Thorium Widgets.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 6 Thorium Widgets and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Yebb Neblegear Turn-Ins (Mulgore)",{
author="support@zygorguides.com",
description="\nExchange various Farmed items with Yebb Neblegear for prize tickets at the Darkmoon Faire.",
model={14856},
},[[
step
Kill Savannah enemies around this area
|tip You can find them all over around Crossroads and to its northern area.
collect 5 Small Furry Paw##5134 |goto The Barrens 50.21,21.82 |n
talk Yebb Neblegear##14829
accept Small Furry Paws##7899 |goto Mulgore 37.54,39.63 |or
|tip Each turnin requires 5 Small Furry Paws and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 1 Darkmoon Faire Prize Ticket.
|tip You can turn this quest in until you reach 500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 500 |or
step
Reach Level 10 |ding 10
|tip Use the leveling guides to accomplish this.
step
Kill Ashenvale Bear enemies around this area
|tip You can find them all over between Raynewood Retreat and Splintertree post.
|tip You can also find them east of Satyrn.
collect 5 Torn Bear Pelt##11407 |goto Ashenvale 66.01,60.42 |n
You can find more around [Ashenvale 83.81,47.40]
talk Yebb Neblegear##14829
accept Torn Bear Pelts##7900 |goto Mulgore 37.54,39.63 |or
|tip Each turnin requires 5 Torn Bear Pelts and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 4 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,100 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1100 |or
step
Reach Level 20 |ding 20
|tip Use the leveling guides to accomplish this.
step
Kill Crag Coyote enemies around this area
|tip You can find the all over central and western Badlands.
collect 5 Soft Bushy Tail##4582 |goto Badlands 34.41,65.63 |n
You can find more around [Badlands 57.00,58.62]
talk Yebb Neblegear##14829
accept Soft Bushy Tails##7901 |goto Mulgore 37.54,39.63 |or
|tip Each turnin requires 5 Soft Bushy Tails and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 8 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 1,700 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 1700 |or
step
Reach Level 30 |ding 30
|tip Use the leveling guides to accomplish this.
step
Kill Northspring enemies around this area
collect 5 Vibrant Plume##5117 |goto Feralas 40.00,12.61 |n
talk Yebb Neblegear##14829
accept Vibrant Plumes##7902 |goto Mulgore 37.54,39.63 |or
|tip Each turnin requires 5 Vibrant Plumes and grants 100 reputation with the Darkmoon Faire.
|tip Each of these turnins will award 12 Darkmoon Faire Prize Tickets.
|tip You can turn this quest in until you reach 2,500 Neutral reputation.
'|condition repval('Darkmoon Faire','Neutral') >= 2500 |or
step
Reach Level 40 |ding 40
|tip Use the leveling guides to accomplish this.
step
Kill Stonelash enemies around this area
|tip You can find them all over central and southern Silithus.
collect 10 Glowing Scorpid Blood##19933 |goto Silithus 44.81,54.50 |q 8222 |future
step
talk Yebb Neblegear##14829
accept Glowing Scorpid Blood##8222 |goto Mulgore 37.54,39.63
step
Kill Stonelash enemies around this area
|tip You can find them all over central and southern Silithus.
collect 10 Glowing Scorpid Blood##19933 |goto Silithus 44.81,54.50 |n
talk Yebb Neblegear##14829
accept More Glowing Scorpid Blood##8223 |goto Mulgore 37.54,39.63
|tip From this point on, you can continue turning in Glowing Scorpid Blood.
|tip Each of these turnins will award 20 Darkmoon Faire Prize Tickets.
|tip Each turnin requires 10 Glowing Scorpid Blood and grants 100 reputation with the Darkmoon Faire.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Spawn of Jubjub (Mulgore)",{
author="support@zygorguides.com",
description="\nCollect a couple of Dark Iron Ale Mugs from the Grim Guzzler tavern in Blackrock Depths "..
"and offer them to Morja at the Darkmoon Faire to receive your very own Jubjub companion pet.",
condition_end=function() return completedq(7946) end,
model={14938},
},[[
step
click Dark Iron Ale Mug##165738
|tip They look like small mugs of ale on tables around the Grim Guzzler tavern in Blackrock Depths.
|tip Clicking two of them is safe but clicking more will anger the bar patrons.
collect 2 Dark Iron Ale Mug##11325 |q 7946 |future
|tip They can also be purchased from Plugger Spazzring in the Grim Guzzler.
|tip They can be purchased from the Auction House if you are lucky enough to find them.
step
use the Dark Iron Ale Mug##11325
|tip Place it at Morja's feet.
|tip Be sure you only use one; you will need the other one to turn in the quest.
Wait for Jubjub the frog to hop over to the mug
|tip This may take a couple of minutes.
talk Morja##14871
accept Spawn of Jubjub##7946 |goto Mulgore 35.87,35.24
|tip This quest will be available after Jubjub appears.
step
use the Unhatched Jubling Egg##19462
|tip It will take seven days for the egg to mature enough to hatch.
collect 1 A Jubling's Tiny Home##19450
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Wood Frog (Mulgore)",{
author="support@zygorguides.com",
description="\nCatch Flik as he runs all over the Darkmoon Faire grounds and purchase his limited supply "..
"Wood Frog Box for 1 gold.",
model={901},
},[[
step
talk Flik##14860
|tip He's a little Orc boy running fast all over the Darkmoon Faire grounds.
|tip You will have to be quick to catch him.
|tip Talking to him will stop him for a short period of time.
buy 1 Wood Frog Box##11027 |goto Mulgore 36.72,37.36
|tip This item costs 1 gold and has a limited quantity of 1.
|tip It respawns in approximately 20 minutes.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Darkmoon Faire\\Mulgore\\Tree Frog (Mulgore)",{
author="support@zygorguides.com",
description="\nCatch Flik as he runs all over the Darkmoon Faire grounds and purchase his "..
"Tree Frog Box for 1 gold.",
model={6295},
},[[
step
talk Flik##14860
|tip He's a little Orc boy running fast all over the Darkmoon Faire grounds.
|tip You will have to be quick to catch him.
|tip Talking to him will stop him for a short period of time.
buy 1 Tree Frog Box##11026 |goto Mulgore 36.72,37.36
|tip This item costs 1 gold.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Hallow's End\\Hallow's End Quests",{
author="support@zygorguides.com",
condition_end=function() return completedq(8373) end,
description="\nComplete the quests \"Hallow's End Treats for Jesper!\" and \"The Power of Pine\" for the Hallow's End event.",
},[[
step
Reach Level 10 |ding 10
|tip You must be at least level 10 to be able to accept these quests.
|tip Use the Leveling guides to accomplish this.
step
Enter the building |goto Stormwind City 47.40,37.30 < 5 |walk
talk Jesper##15310
|tip Inside the building.
accept Hallow's End Treats for Jesper!##8311 |goto Stormwind City 47.63,35.32
step
Enter the building |goto Stormwind City 53.39,64.96 < 5 |walk
talk Innkeeper Allison##6740
|tip Inside the building.
accept Flexing for Nougat##8356 |goto Stormwind City 52.61,65.71 |condition completedq(8311) or completedq(8356)
step
clicknpc Innkeeper Allison##6740
|tip Inside the building.
|tip Target Innkeeper Allison and type "/flex" into your chat to perform the Flex emote.
Flex for Inkeeper Allison |q 8356/1 |goto Stormwind City 52.61,65.71 |condition completedq(8311) or completedq("8356/1")
'|script DoEmote("FLEX")
step
talk Innkeeper Allison##6740
|tip Inside the building.
turnin Flexing for Nougat##8356 |goto Stormwind City 52.61,65.71 |condition completedq(8311) or completedq(8356)
collect Stormwind Nougat##20492 |q 8311/1
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12336 |goto Stormwind City/0 52.78,65.79
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
Enter the building |goto Ironforge 20.57,53.22 < 5 |walk
talk Innkeeper Firebrew##5111
|tip Inside the building.
accept Chicken Clucking for a Mint##8353 |goto Ironforge 18.16,51.44 |condition completedq(8311) or completedq(8353)
step
clicknpc Innkeeper Firebrew##5111
|tip Inside the building.
|tip Target Innkeeper Firebrew and type "/chicken" into your chat to perform the Chicken emote.
Cluck Like a Chicken for Innkeeper Firebrew |q 8353/1 |goto Ironforge 18.16,51.44 |condition completedq(8311) or completedq("8353/1")
'|script DoEmote("CHICKEN")
step
talk Innkeeper Firebrew##5111
|tip Inside the building.
turnin Chicken Clucking for a Mint##8353 |goto Ironforge 18.16,51.44 |condition completedq(8311) or completedq(8353)
collect Ironforge Mint##20490 |q 8311/3
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12335 |goto Ironforge/0 18.36,50.94
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
talk Talvash del Kissel##6826
accept Incoming Gumdrop##8355 |goto Ironforge/0 36.38,3.62 |condition completedq(8311) or completedq(8355)
step
clicknpc Talvash del Kissel##6826
|tip Target Talvash del Kissel and type "/train" into your chat to perform the Train emote.
Do the "Train" for Talvash |q 8355/1 |goto Ironforge/0 36.38,3.62 |condition completedq(8311) or completedq("8355/1")
'|script DoEmote("TRAIN")
step
talk Talvash del Kissel##6826
turnin Incoming Gumdrop##8355 |goto Ironforge/0 36.38,3.62 |condition completedq(8311) or completedq(8355)
collect Gnomeregan Gumdrop##20494 |q 8311/2
step
talk Innkeeper Saelienne##6735
accept Dancing for Marzipan##8357 |goto Darnassus 67.42,15.65 |condition completedq(8311) or completedq(8357)
step
clicknpc Innkeeper Saelienne##6735
|tip Target Innkeeper Saelienne and type "/dance" into your chat to perform the Dance emote.
Dance for Inkeeper Saelienne |q 8357/1 |goto Darnassus 67.42,15.65 |condition completedq(8311) or completedq("8357/1")
'|script DoEmote("DANCE")
step
talk Innkeeper Saelienne##6735
turnin Dancing for Marzipan##8357 |goto Darnassus 67.42,15.65 |condition completedq(8311) or completedq(8357)
collect Darnassus Marzipan##20496 |q 8311/4
step
click Candy Bucket##208144
accept Cnady Bucket##12334 |goto Darnassus/0 67.45,16.04
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
Enter the building |goto Stormwind City 47.40,37.30 < 5 |walk
talk Jesper##15310
|tip Inside the building.
turnin Hallow's End Treats for Jesper!##8311 |goto Stormwind City 47.63,35.32
step
Reach Level 25 |ding 25
|tip You must be at least level 25 to be able to accept this quest.
|tip Use the Leveling guides to accomplish this.
step
talk Sergeant Hartman##15199
accept The Power of Pine##8373 |goto Hillsbrad Foothills 50.00,57.34
step
use Stink Bomb Cleaner##20604
|tip Use it next to a stink bomb placed by a Horde player.
|tip They look like small metal objects surrounded by orange smoke on the ground around Southshore.
|tip Run around Southshore and look for them, they will most likely be near the outskirts of the town.
Clean Up a Stink Bomb in Southshore |q 8373/1 |goto Hillsbrad Foothills 48.61,57.82
step
talk Sergeant Hartman##15199
turnin The Power of Pine##8373 |goto Hillsbrad Foothills 50.00,57.34
step
_Congratulations!_
You Completed the "Hallow's End" Event
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Hallow's End\\Hallow's End Daily Quests",{
author="support@zygorguides.com",
description="\nPut out fires in Razor Hill and kill the Headless Horseman.",
},[[
step
label "Begin_Dailies"
talk Human Commoner##18927
accept Costumed Orphan Matron##11356 |goto Stormwind City/0 54.25,64.34
step
talk Costumed Orphan Matron##24519
turnin Costumed Orphan Matron##11356 |goto Elwynn Forest/0 42.62,64.39
step
talk Masked Orphan Matron##23973
accept Stop the Fires!##11131 |goto Elwynn Forest/0 52.57,41.20 |or
accept "Let the Fires Come!"##12135 |goto Elwynn Forest/0 52.57,41.20 |or
|tip You will only be able to accept one of these quests.
|tip The quest offered depends on whether Goldshire is under attack or not.
step
click Water Barrel |goto Elwynn Forest/0 52.55,41.30
|tip Click the Water Barrel to pick up a bucket of water.
collect Water Bucket##32971 |n
use the Water Bucket##32971
|tip Throw the buckets at the fires on top of buildings around this area.
Put Out the Fires |q 11131/1 |goto Elwynn Forest/0 52.41,42.42
|only if haveq(11131) or completedq(11131)
step
click Water Barrel |goto Elwynn Forest/0 52.55,41.30
|tip Click the Water Barrel to pick up a bucket of water.
collect Water Bucket##32971 |n
use the Water Bucket##32971
|tip Throw the buckets at the fires on top of buildings around this area.
Put Out the Fires |q 12135/1 |goto Elwynn Forest/0 52.41,42.42
|only if haveq(12135) or completedq(12135)
step
talk Masked Orphan Matron##23973
turnin Stop the Fires!##11131 |goto Elwynn Forest/0 52.57,41.20 |only if haveq(11131) or completedq(11131) |or
turnin "Let the Fires Come!"##12135 |goto Elwynn Forest/0 52.57,41.20 |only if haveq(12135) or completedq(12135) |or
step
talk Large Jack-O'-Lantern
accept Smash the Pumpkin##12133 |goto Elwynn Forest/0 42.39,65.87
|tip This will only be available after the Headless Horseman is defeated.
step
Reach Level 65 |ding 65 |or
|tip You must be at least level 65 to be able to kill the Headless Horseman.
|tip Use the Leveling guides to accomplish this.
'|complete not completedq(11131,12135,11404) |next "Begin_Dailies" |or
step
click Pumpkin Shrine
|tip It's in the courtyard of the Scarlet Monastery Graveyard dungeon.
|tip You will need a full group for this.
accept Call the Headless Horseman##11404 |or
'|complete not completedq(11131,12135,11404) |next "Begin_Dailies" |or
step
click Loosely Turned Soil
|tip In front of the crypt behind the Pumpkin Shine.
kill Headless Horseman##23682
|tip He will fly down shortly after disturbing the soil.
|tip When he reaches 1% health, his head will fly off.
|tip Burn the head down to make it rejoin his body.
|tip You will need to do this twice.
|tip After the second time, he will start spawning 4 pumpkins every 30 seconds.
|tip Group them up and AoE them down.
|tip Kill his head the third time it separates to defeat him.
confirm |or
'|complete not completedq(11131,12135,11404) |next "Begin_Dailies" |or
step
click Pumpkin Shrine
turnin Call the Headless Horseman##11404 |or
'|complete not completedq(11131,12135,11404) |next "Begin_Dailies" |or
step
You have completed the availble daily quests for Hallow's End
|tip This guide will reset when more become available.
'|complete not completedq(11131,12135,11404) |next "Begin_Dailies" |or
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Hallow's End\\Hallow's End Candy Buckets",{
author="support@zygorguides.com",
description="\nVisit innkeeper candy buckets in Eastern Kingdoms, Kalimdor, and Outland "..
"for tasty treats.",
},[[
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12336 |goto Stormwind City/0 52.78,65.79
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12286 |goto Elwynn Forest/0 43.74,65.88
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12340 |goto Westfall/0 52.91,53.74
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12344 |goto Duskwood/0 73.79,44.25
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12397 |goto Stranglethorn Vale/0 27.06,77.27
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12396 |goto The Barrens/0 62.07,39.41
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12349 |goto Dustwallow Marsh/0 66.60,45.28
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12398 |goto Dustwallow Marsh/0 41.86,74.09
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12348 |goto Desolace/0 66.33,6.59
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12345 |goto Ashenvale/0 37.01,49.26
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
accept Candy Bucket##12338 |goto Darkshore/0 37.04,44.04
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
accept Cnady Bucket##12334 |goto Darnassus/0 67.45,16.04
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12331 |goto Teldrassil/0 55.62,59.85
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12337 |goto The Exodar/0 59.23,18.48
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12333 |goto Azuremyst Isle/0 48.49,49.05
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12341 |goto Bloodmyst Isle/0 55.69,59.96
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12343 |goto Wetlands/0 10.83,60.99
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12339 |goto Dun Morogh/0 47.37,52.44
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12335 |goto Ironforge/0 18.36,50.94
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip It's Inside the building.
accept Candy Bucket##12351 |goto The Hinterlands/0 14.11,41.52
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12346 |goto Hillsbrad Foothills/0 51.14,59.02
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket
|tip Inside the building.
accept Candy Bucket##12342 |goto Redridge Mountains/0 27.08,44.91
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12352 |goto Hellfire Peninsula/0 54.27,63.66
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12353 |goto Hellfire Peninsula/0 23.42,36.38
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12404 |goto Shattrath City/0 56.31,81.95
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
only if rep ('The Scryers')>=Neutral
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12404 |goto Shattrath City/0 28.23,49.07
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
only if rep ('The Aldor')>=Neutral
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12356 |goto Terokkar Forest/0 56.60,53.22
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip It's inside the inn back in the corner.
accept Candy Bucket##12360 |goto Shadowmoon Valley/0 37.01,58.29
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12409 |goto Shadowmoon Valley/0 56.37,59.82
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
only if rep ('The Scryers')>=Neutral
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12409 |goto Shadowmoon Valley/0 61.00,28.17
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
only if rep ('The Aldor')>=Neutral
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12357 |goto Nagrand/0 54.19,75.88
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12403 |goto Zangarmarsh/0 78.45,62.88
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
Visit the Candy Bucket in Zangarmarsh, Cenarion Refuge
step
click Candy Bucket##208144
|tip It's inside the inn atop the giant mushroom.
accept Candy Bucket##12354 |goto Zangarmarsh/0 67.16,48.94
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
Visit the Candy Bucket in Zangarmarsh, Telredor
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12355 |goto Zangarmarsh/0 41.90,26.17
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12358 |goto Blade's Edge Mountains/0 35.83,63.74
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
Visit the Candy Bucket in Blade's Edge Mountains, Sylvanaar
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12359 |goto Blade's Edge Mountains/0 61.05,68.08
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12406 |goto Blade's Edge Mountains/0 62.90,38.33
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
Visit the Candy Bucket in Blade's Edge Mountains, Evergrove
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12407 |goto Netherstorm/0 32.02,64.44
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
step
click Candy Bucket##208144
|tip Inside the building.
accept Candy Bucket##12408 |goto Netherstorm/0 43.31,36.10
|tip If you cannot complete this quest because of a "Duplicate item found" message, open the Handful of Treats item in your bags and take out the contents.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Harvest Festival\\Harvest Festival Quest",{
author="support@zygorguides.com",
condition_end=function() return completedq(8149) end,
description="\nComplete the quest \"Honoring a Hero\" for the Harvest Festival event.",
},[[
step
Reach Level 30 |ding 30
|tip You must be at least level 30 to be able to accept the quest.
|tip Use the Leveling guides to accomplish this.
step
_Note:_
|tip While you can accept this quest at level 30, you must go to an area with level 50-52 enemies.
|tip If you are not high enough level to kill enemies of that level, try to find someone to help you.
Click Here to Continue |confirm |q 8149 |future
step
talk Wagner Hammerstrike##15011
accept Honoring a Hero##8149 |goto Dun Morogh 52.60,36.03
step
Follow the path |goto Western Plaguelands 46.61,81.31 < 15 |only if walking
Follow the path up |goto Western Plaguelands 51.62,79.94 < 20 |only if walking
Enter the building |goto Western Plaguelands 52.07,83.22 < 10 |walk
use Uther's Tribute##19850
|tip Inside the building.
Place a Tribute at Uther's Tomb |q 8149/1 |goto Western Plaguelands 52.14,83.57
step
Follow the path |goto Western Plaguelands 46.61,81.31 < 15 |only if walking
talk Wagner Hammerstrike##15011
turnin Honoring a Hero##8149 |goto Dun Morogh 52.60,36.03
step
_Congratulations!_
You Completed the "Harvest Festival" Event
|tip You can now use the food at the Harvest Festival table.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Feast of Winter Veil\\Feast of Winter Veil Quest",{
author="support@zygorguides.com",
description="This guide will walk you through the quests for the \"Feast of Winter Veil\" event.",
},[[
step
Reach Level 10 |ding 10
|tip You must be at least this level to be able to accept the quest.
|tip Use the Leveling guides to accomplish this.
step
talk Goli Krumn##1365
accept The Reason for the Season##7062 |goto Ironforge 30.27,59.39
step
talk Historian Karnik##2916
|tip Inside the building.
turnin The Reason for the Season##7062 |goto Ironforge 77.54,11.82
accept The Feast of Winter Veil##7063 |goto Ironforge 77.54,11.82
step
Follow the path |goto Ironforge 44.60,49.49 < 7 |walk
talk King Magni Bronzebeard##2784
|tip Inside the building.
turnin The Feast of Winter Veil##7063 |goto Ironforge 39.09,56.20
step
talk Wulmort Jinglepocket##13433
accept Greatfather Winter is Here!##7022 |goto Ironforge 33.70,67.23
step
talk Greatfather Winter##13444
turnin Greatfather Winter is Here!##7022 |goto Ironforge 33.20,65.41
accept Treats for Greatfather Winter##7025 |goto Ironforge 33.20,65.41
step
Run up the stairs |goto Ironforge 57.50,37.46 < 7 |only if walking
Enter the building |goto Ironforge 59.41,37.77 < 5 |walk
talk Daryl Riknussun##5159
|tip Inside the building.
Learn Apprentice Cooking |skillmax Cooking,75 |goto Ironforge 60.08,36.43
step
talk Wulmort Jinglepocket##13433
buy Recipe: Gingerbread Cookie##17200 |n
use the Recipe: Gingerbread Cookie##17200
learn Gingerbread Cookie##21143 |goto Ironforge 33.70,67.23
step
collect 5 Small Egg##6889 |q 7025
|tip Search the guide menu and use the farming guide to accomplish this.
|tip You can also buy them from the Auction House.
step
talk Wulmort Jinglepocket##13433
buy 5 Holiday Spices##17194 |goto Ironforge 33.70,67.23 |q 7025
step
Open Your Cooking Crafting Panel:
|tip Stand next to the Dwarven Brazier.
_<Create 5 Gingerbread Cookies>_
collect 5 Gingerbread Cookie##17197 |q 7025/1 |goto Ironforge 33.36,65.52
step
Enter the building |goto Ironforge 20.63,53.23 < 5 |walk
talk Gwenna Firebrew##5112
|tip Inside the building.
buy Ice Cold Milk##1179 |q 7025/2 |goto Ironforge 18.64,51.76
step
talk Greatfather Winter##13444
turnin Treats for Greatfather Winter##7025 |goto Ironforge 33.20,65.41
|tip After you turn in this quest, you can then repeat it to get more gifts to open.
step
Reach Level 30 |ding 30
|tip You must be at least this level to be able to accept the quest.
|tip Use the Leveling guides to accomplish this.
step
talk Wulmort Jinglepocket##13433
accept Stolen Winter Veil Treats##7042 |goto Ironforge 33.70,67.23
step
Follow the path up |goto Hillsbrad Foothills 47.00,26.73 < 30 |only if walking
Follow the path |goto Alterac Mountains 41.83,77.11 < 20 |only if walking
talk Strange Snowman##13636
turnin Stolen Winter Veil Treats##7042 |goto Alterac Mountains 35.44,72.46
accept You're a Mean One...##7043 |goto Alterac Mountains 35.44,72.46
step
kill The Abominable Greench##13602
|tip He looks like a level 36 elite yeti.
|tip If you have trouble, try to find someone to help you.
|tip He can spawn in random places around the "Growless Cave" area.
|tip When he spawns, you will see a red yelled message in your chat.
|tip Just wait around nearby in this area until he spawns.
collect Stolen Treats##17662 |q 7043/1 |goto Alterac Mountains 40.80,67.77
step
talk Wulmort Jinglepocket##13433
turnin You're a Mean One...##7043 |goto Ironforge 33.70,67.23
accept A Smokywood Pastures Thank You!##7045 |goto Ironforge 33.70,67.23
step
talk Greatfather Winter##13444
turnin A Smokywood Pastures Thank You!##7045 |goto Ironforge 33.20,65.41
step
Reach Level 40 |ding 40
|tip You must be at least this level to be able to accept the quest.
|tip Use the Leveling guides to accomplish this.
step
talk Wulmort Jinglepocket##13433
accept Metzen the Reindeer##8762 |goto Ironforge 33.70,67.23
step
use the Smokywood Satchel##21315
collect Pouch of Reindeer Dust##21211 |q 8762/2
step
Enter the tunnel |goto Tanaris 68.61,41.45 < 10 |only if walking
Leave the tunnel |goto Tanaris 69.81,42.48 < 10 |only if walking
Follow the path |goto Tanaris 73.18,45.56 < 15 |only if walking
talk Metzen the Reindeer##15664
|tip Inside the building.
Choose _"Sprinkle some of the reindeer dust onto Metzen."_
Find Metzen the Reindeer and Rescue Him |q 8762/1 |goto Tanaris 73.35,48.07
step
talk Wulmort Jinglepocket##13433
turnin Metzen the Reindeer##8762 |goto Ironforge 33.70,67.23
step
_Congratulations!_
You Completed the "Feast of Winter Veil" Event
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Lunar Festival\\Lunar Festival Main Questline",{
author="support@zygorguides.com",
description="This guide will walk you through the quests for the \"Lunar Festival\" event.",
condition_end=function() return completedq(8862) end,
},[[
step
talk Lunar Festival Emissary##15892
accept The Lunar Festival##8870 |goto Ironforge 30.9,61.6
step
talk Lunar Festival Harbinger##15895
turnin The Lunar Festival##8870 |goto Ironforge 28.8,16.2
accept Lunar Fireworks##8867 |goto Ironforge 28.8,16.2
step
talk Lunar Festival Vendor##15898
buy 8 Small Blue Rocket##21558 |goto Ironforge 29.9,14.2 |q 8867
buy 2 Blue Rocket Cluster##21571 |goto Ironforge 29.9,14.2 |q 8867
stickystart "Fire_Lunar_Fireworks_Clusters"
step
use the Small Blue Rocket##21558
Fire #8# Lunar Fireworks |q 8867/1 |goto Ironforge 30.6,17.8
step
label "Fire_Lunar_Fireworks_Clusters"
use the Blue Rocket Cluster##21571
Fire #2# Lunar Fireworks Clusters |q 8867/2 |goto Ironforge 30.6,17.8
step
talk Lunar Festival Harbinger##15895
turnin Lunar Fireworks##8867 |goto Ironforge 28.9,16.2
accept Valadar Starsong##8883 |goto Ironforge 28.9,16.2
step
use the Lunar Festival Invitation##21711 |goto Ironforge 30.6,17.8
Use the Lunar Festival Invitation While Standing in the Beam of Light |goto Moonglade |noway |c |q 8883
step
talk Valadar Starsong##15864
turnin Valadar Starsong##8883 |goto Moonglade 53.65,35.26
step
collect 16 Coin of Ancestry##21100
|tip These are awarded by talking to elders around Kalimdor and Eastern Kingdoms.
|tip Use the "Lunar Festival Optimized Elders Path" event guide to collect them.
step
talk Valadar Starsong##15864
accept Festive Lunar Dresses##8864 |goto Moonglade 53.65,35.26
accept Festive Lunar Pant Suits##8865 |goto Moonglade 53.65,35.26
accept Festival Dumplings##8863 |goto Moonglade 53.65,35.26
accept Elune's Candle##8862 |goto Moonglade 53.65,35.26
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Lunar Festival\\Lunar Festival Optimized Elders Path",{
author="support@zygorguides.com",
description="This guide will walk you through an optimized path, honoring the elders for the \"Lunar Festival\" event.",
},[[
step
Follow the path |goto Western Plaguelands/0 68.61,80.10 < 20 |only if walking
Run up the stairs |goto Western Plaguelands/0 69.94,74.03 < 7 |only if walking
Enter the building |goto Eastern Kingdoms/0 50.94,36.51 < 15 |walk
Run up the stairs |goto Eastern Kingdoms/0 50.86,36.40 < 5 ||walk
talk Elder Moonstrike##15594
|tip Upstairs on the outer wall of the building.
accept Moonstrike the Elder##8714 |goto Eastern Kingdoms/0 50.88,36.52
step
Jump down here |goto Eastern Kingdoms/0 50.86,36.51 < 7 |walk
Jump Off the Wall |goto Western Plaguelands/0 68.76,73.60 < 500 |c |noway |q 8722 |future
step
talk Elder Meadowrun##15602
accept Meadowrun the Elder##8722 |goto Western Plaguelands/0 65.97,47.82
step
talk Elder Graveborn##15568
accept Graveborn the Elder##8652 |goto Tirisfal Glades/0 61.87,53.85
step
talk Elder Darkcore##15564
|tip Inside the entrance to Undercity.
accept Darkcore the Elder##8648 |goto Undercity/0 66.62,38.19
step
talk Elder Obsidian##15561
accept Obsidian the Elder##8645 |goto Silverpine Forest/0 44.98,41.15
step
talk Elder Snowcrown##15566
accept Snowcrown the Elder##8650 |goto Eastern Plaguelands/0 81.51,60.52
step
talk Elder Windrun##15592
|tip Inside the tower.
accept Windrun the Elder##8688 |goto Eastern Plaguelands/0 39.69,75.39
step
talk Elder Highpeak
accept Highpeak the Elder##8643 |goto The Hinterlands/0 49.99,48.04
step
talk Elder Silvervein##15558
accept Silvervein the Elder##8642 |goto Loch Modan/0 33.32,46.55
step
talk Elder Bronzebeard##15871
accept Bronzebeard the Elder##8866 |goto Ironforge/0 29.19,17.03
step
talk Elder Goldwell##15569
accept Goldwell the Elder##8653 |goto Dun Morogh/0 46.82,51.61
step
talk Elder Ironband##15567
accept Ironband the Elder##8651 |goto Searing Gorge/0 21.29,79.12
step
talk Elder Dawnstrider##15585
accept Dawnstrider the Elder##8683 |goto Burning Steppes/0 64.46,24.04
step
Cross the bridge |goto Burning Steppes/0 76.07,38.04 < 7 |only if walking
talk Elder Rumblerock##15557
accept Rumblerock the Elder##8636 |goto Burning Steppes/0 82.20,46.47
step
talk Elder Hammershout##15562
accept Hammershout the Elder##8646 |goto Stormwind City/0 21.43,53.91
step
talk Elder Stormbrow##15565
accept Stormbrow the Elder##8649 |goto Elwynn Forest/0 39.79,63.67
step
talk Elder Bellowrage##15563
accept Bellowrage the Elder##8647 |goto Blasted Lands/0 57.91,54.87
step
talk Elder Skychaser##15577
accept Skychaser the Elder##8675 |goto Westfall/0 56.64,47.09
step
talk Elder Starglade##15596
accept Starglade the Elder##8716 |goto Stranglethorn Vale/0 53.11,18.46
step
talk Elder Winterhoof##15576
|tip On top of the bank.
accept Winterhoof the Elder##8674 |goto Stranglethorn Vale/0 26.46,76.53
step
talk Elder Windtotem##15582
accept Windtotem the Elder##8680 |goto The Barrens/0 62.65,36.74
step
talk Elder Runetotem##15572
accept Runetotem the Elder##8670 |goto Durotar/0 53.23,43.65
step
talk Elder Darkhorn##15579
accept Darkhorn the Elder##8677 |goto Orgrimmar/0 41.14,33.85
step
talk Elder Moonwarden##15597
accept Moonwarden the Elder##8717 |goto The Barrens/0 51.40,30.68
step
talk Elder High Mountain##15588
accept High Mountain the Elder##8686 |goto The Barrens/0 45.11,57.88
step
talk Elder Bloodhoof##15575
accept Bloodhoof the Elder##8673 |goto Mulgore/0 48.40,53.44
step
Ride the elevator up |goto Thunder Bluff/0 31.76,65.80
talk Elder Ezra Wheathoof##15580
accept Wheathoof the Elder##8678 |goto Thunder Bluff/0 72.98,23.38
step
talk Elder Skyseer##15584
accept Skyseer the Elder##8682 |goto Thousand Needles/0 45.42,50.08
step
talk Elder Morningdew##15604
accept Morningdew the Elder##8724 |goto Thousand Needles/0 79.19,77.05
step
talk Elder Dreamseer##15586
accept Dreamseer the Elder##8684 |goto Tanaris/0 51.46,27.85
step
talk Elder Ragetotem##15573
accept Ragetotem the Elder##8671 |goto Tanaris/0 36.30,80.53
step
talk Elder Thunderhorn##15583
accept Thunderhorn the Elder##8681 |goto Un'Goro Crater/0 50.37,76.16
step
talk Elder Bladesing##15599
accept Bladesing the Elder##8719 |goto Silithus/0 48.97,37.65
step
talk Elder Primestone##15570
accept Primestone the Elder##8654 |goto Silithus/0 23.09,11.84
step
talk Elder Mistwalker##15587
|tip Down in the pit.
accept Mistwalker the Elder##8685 |goto Feralas/0 62.56,31.08
step
talk Elder Grimtotem##15581
accept Grimtotem the Elder##8679 |goto Feralas/0 76.71,37.89
step
talk Elder Skygleam##15600
accept Skygleam the Elder##8720 |goto Azshara/0 72.53,85.07
step
talk Elder Stonespire##15574
accept Stonespire the Elder##8672 |goto Winterspring/0 61.45,37.76
step
talk Elder Brightspear##15606
accept Brightspear the Elder##8726 |goto Winterspring/0 55.62,43.66
step
talk Elder Nightwind##15603
accept Nightwind the Elder##8723 |goto Felwood/0 37.72,53.01
step
talk Elder Riversong##15605
accept Riversong the Elder##8725 |goto Ashenvale/0 35.54,48.91
step
talk Elder Starweave##15601
accept Starweave the Elder##8721 |goto Darkshore/0 36.81,46.75
step
talk Elder Bladeswift##15598
accept Bladeswift the Elder##8718 |goto Darnassus/0 33.48,14.29
step
talk Elder Bladeleaf##15595
accept Bladeleaf the Elder##8715 |goto Teldrassil/0 57.34,60.80
step
talk Elder Wildmane##15578
|tip She is located inside Zul'Farak near the pool that spawns Gaz'Rilla.
|tip You will need to run this dungeon with a group.
accept Wildmane the Elder##8676
step
talk Elder Splitrock##15556
|tip He is located inside Mauradon near the east exit beyond Rotgrip.
|tip He is at the top of a path at the end of the tunnel.
|tip You will need to run this dungeon with a group.
accept Splitrock the Elder##8635
step
talk Elder Starsong##15593
|tip Take the path on the left after entering Sunken Temple.
|tip Go up the spiral staircase and go left again to the large round room.
|tip The elder is in the rear of the alcove on the left.
|tip You will need to run this dungeon with a group.
accept Starsong the Elder##8713
step
talk Elder Morndeep##15549
|tip He is located in the middle of the Ring of Law in Blackrock Depths.
|tip Talking to him will start the event.
|tip You will need to run this dungeon with a group.
accept Morndeep the Elder##8619
step
talk Elder Stonefort##15560
|tip He is located on the left side after crossing the first rope brige in Hordemar City on the way to Omokk in Lower Blackrock Spire.
|tip You will need to run this dungeon with a group.
accept Stonefort the Elder##8644
step
talk Elder Farwhisper##15607
|tip He is located in Stratholme on the Service Entrance (Scarlet) side.
|tip Go left after entering the instance and through the plague rat gate and he will be on the right side.
|tip You will need to run this dungeon with a group.
accept Farwhisper the Elder##8727
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Love is in the Air\\Love is in the Air Quests",{
author="support@zygorguides.com",
description="\nThis guide will assist you in completing the quests for the \"Love is in the Air\" event.",
condition_end=function() return completedq(9029) end,
},[[
step
talk Aristan Mottar##16105
accept Dangerous Love##8903 |goto Stormwind City 54.60,65.29
step
talk Innkeeper Allison##6740
|tip Inside the building.
buy 1 Love Token##21815 |goto Stormwind City 52.62,65.70 |q 8903
buy 1 Cologne Bottle##21833 |goto Stormwind City 52.62,65.70 |q 8903
buy 1 Perfume Bottle##21829 |goto Stormwind City 52.62,65.70 |q 8903
step
use the Cologne Bottle##21833
use the Perfume Bottle##21829
Apply Perfume or Cologne |condition hasbuff("spell:26681") or hasbuff("spell:26682") |q 8903
|tip Perfume allows you to give Love Tokens to male NPCs.
|tip Cologne allows you to give Love Tokens to female NPCs.
step
Talk to NPCs
|tip Talk to those with a heart above their head.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Stormwind##21975
use the Pledge of Friendship: Stormwind##22178
collect 1 Stormwind Guard's Card##22143 |q 8903
step
talk Aristan Mottar##16105
turnin Dangerous Love##8903 |goto Stormwind City 54.60,65.29
accept Artisan's Hunch##9024 |goto Stormwind City 54.60,65.29
step
talk Morgan Pestle##279
|tip Inside the building.
turnin Artisan's Hunch##9024 |goto Stormwind City 56.20,64.58
accept Morgan's Discovery##9025 |goto Stormwind City 56.20,64.58
step
talk Aristan Mottar##16105
turnin Morgan's Discovery##9025 |goto Stormwind City 54.60,65.29
accept Tracing the Source##9026 |goto Stormwind City 54.60,65.29
step
talk Innkeeper Allison##6740
|tip Inside the building.
turnin Tracing the Source##9026 |goto Stormwind City 52.62,65.70
accept Tracing the Source##9027 |goto Stormwind City 52.62,65.70
step
talk Evert Sorisam##16106
|tip Inside the building.
turnin Tracing the Source##9027 |goto Stormwind City 39.83,46.97
accept The Source Revealed##9028 |goto Stormwind City 39.83,46.97
step
Follow the path up |goto Hillsbrad Foothills 75.5,24.0
Enter the cave |goto Hillsbrad Foothills 77.7,19.4
Run up the hill |goto Alterac Mountains 84.3,84.3
Follow the path up |goto Alterac Mountains 86.1,25.3
talk Apothecary Staffron Lerent##16107
turnin The Source Revealed##9028 |goto Alterac Mountains 89.5,75.5
step
click Fragrant Cauldron
accept A Bubbling Cauldron##9029 |goto Alterac Mountains 89.6,75.7
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Love is in the Air\\Gift Giving",{
author="support@zygorguides.com",
description="\nThis guide will assist you in completing the \"Gift Giving\" quest for the \"Love is in the Air\" event.",
},[[
step
label "Begin_Guide"
talk Innkeeper Allison##6740
|tip Inside the building.
buy 10 Love Token##21815 |goto Stormwind City 52.62,65.70
buy 1 Cologne Bottle##21833 |goto Stormwind City 52.62,65.70
buy 1 Perfume Bottle##21829 |goto Stormwind City 52.62,65.70
step
label "Apply_Perfume_or_Cologne_Stormwind"
use the Cologne Bottle##21833
use the Perfume Bottle##21829
Apply Perfume or Cologne |condition hasbuff("spell:26681") or hasbuff("spell:26682")
|tip Perfume allows you to give Love Tokens to male NPCs.
|tip Cologne allows you to give Love Tokens to female NPCs.
step
Talk to Stormwind City NPCs
|tip Talk to guards around Stormwind who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Stormwind##21975
use the Pledge of Friendship: Stormwind##22178
collect 5 Pledge of Loyalty: Stormwind##22117 |goto Stormwind City 55.91,61.93 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22117) < 5 |next "Apply_Perfume_or_Cologne_Stormwind" |or
step
Talk to Stormwind City NPCs
|tip Talk to guards around Stormwind who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Stormwind##21975
use the Pledge of Friendship: Stormwind##22178
collect 5 Stormwind Guard's Card##22143 |goto Stormwind City 55.91,61.93 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22143) < 5 |next "Apply_Perfume_or_Cologne_Stormwind" |or
step
Talk to non-guard NPCs
|tip Talk to NPCs who aren't guards around Stormwind who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
Select _"Here, I'd like to give you this token of my love."_
use the Gift of Adoration: Stormwind##21981 |only if not hasbuff("spell:26680")
use the Gift of Friendship: Stormwind##22170 |only not hasbuff("spell:26680")
collect 5 Homemade Bread##22176 |goto Stormwind City 55.91,61.93 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22176) < 5 |next "Apply_Perfume_or_Cologne_Stormwind" |or
step
use the Pledge of Loyalty: Stormwind##22117
collect 1 Stormwind Pledge Collection##22285
step
use the Stormwind Guard's Card##22143
collect 1 Bundle of Cards##22284
step
use the Homemade Bread##22176
collect 1 Sack of Homemade Bread##22283
step
use the Stormwind Pledge Collection##22285
collect 1 Stormwind Gift Collection##22131
step
label "Apply_Perfume_or_Cologne_Ironforge"
use the Cologne Bottle##21833
use the Perfume Bottle##21829
Apply Perfume or Cologne |condition hasbuff("spell:26681") or hasbuff("spell:26682")
|tip Perfume allows you to give Love Tokens to male NPCs.
|tip Cologne allows you to give Love Tokens to female NPCs.
step
Talk to Ironforge guard NPCs
|tip Talk to guards around Ironforge who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
|tip Nearly all Ironforge guards are male, so Perfume works best for this.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Ironforge##22154
use the Pledge of Friendship: Ironforge##22160
collect 5 Pledge of Loyalty: Ironforge##22119 |goto Ironforge 30.63,66.72 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22119) < 5 |next "Apply_Perfume_or_Cologne_Ironforge" |or
step
Talk to Ironforge guard NPCs
|tip Talk to guards around Ironforge who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
|tip Nearly all Ironforge guards are male, so Perfume works best for this.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Ironforge##22154
use the Pledge of Friendship: Ironforge##22160
collect 5 Ironforge Guard's Card##22141 |goto Ironforge 30.63,66.72 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22141) < 5 |next "Apply_Perfume_or_Cologne_Ironforge" |or
step
Talk to non-guard NPCs
|tip Talk to NPCs who aren't guards around Ironforge who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
Select _"Here, I'd like to give you this token of my love."_
use the Gift of Adoration: Ironforge##21980
use the Gift of Friendship: Ironforge##22168
collect 5 Dwarven Homebrew##22173 |goto Ironforge 30.63,66.72 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22173) < 5 |next "Apply_Perfume_or_Cologne_Ironforge" |or
step
use the Pledge of Loyalty: Ironforge##22119
collect 1 Ironforge Pledge Collection##22286
step
use the Ironforge Guard's Card##22141
collect 1 Parcel of Cards##22287
step
use the Dwarven Homebrew##22173
collect 1 Case of Homebrew##22288
step
use the Ironforge Pledge Collection##22286
collect 1 Ironforge Gift Collection##22132
step
label "Apply_Perfume_or_Cologne_Darnassus"
use the Cologne Bottle##21833
use the Perfume Bottle##21829
Apply Perfume or Cologne |condition hasbuff("spell:26681") or hasbuff("spell:26682")
|tip Perfume allows you to give Love Tokens to male NPCs.
|tip Cologne allows you to give Love Tokens to female NPCs.
step
Talk to Darnassus guard NPCs
|tip Talk to guards around Darnassus who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
|tip Nearly all Darnassus guards are female, so Cologne works best for this.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Darnassus##22155
use the Pledge of Friendship: Darnassus##22159
collect 5 Pledge of Loyalty: Darnassus##22120 |goto Darnassus 43.11,41.20 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22120) < 5 |next "Apply_Perfume_or_Cologne_Darnassus" |or
step
Talk to Darnassus guard NPCs
|tip Talk to guards around Darnassus who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
|tip Nearly all Darnassus guards are female, so Cologne works best for this.
Select _"Here, I'd like to give you this token of my love."_
use the Pledge of Adoration: Darnassus##22155
use the Pledge of Friendship: Darnassus##22159
collect 5 Sentinel's Card##22140 |goto Darnassus 43.11,41.20 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (22140) < 5 |next "Apply_Perfume_or_Cologne_Darnassus" |or
step
Talk to non-guard NPCs
|tip Talk to NPCs who aren't guards around Darnassus who have hearts over their heads.
|tip If you run out of Love Tokens, talk to the nearest Innkeeper to purchase more.
Select _"Here, I'd like to give you this token of my love."_
use the Gift of Adoration: Darnassus##21980
use the Gift of Friendship: Darnassus##22168
collect 5 Handmade Woodcraft##21960 |goto Darnassus 43.11,41.20 |or
'|condition not hasbuff("spell:26681") and not hasbuff("spell:26682") and itemcount (21960) < 5 |next "Apply_Perfume_or_Cologne_Darnassus" |or
step
use the Pledge of Loyalty: Darnassus##22120
collect 1 Darnassus Pledge Collection##22290
step
use the Sentinel's Card##22140
collect 1 Stack of Cards##22289
step
use the Handmade Woodcraft##21960
collect 1 Box of Woodcrafts##22291
step
use the Darnassus Pledge Collection##22290
collect 1 Darnassus Gift Collection##22133
step
use the Stormwind Gift Collection##22131
collect 1 Alliance Gift Collection##22262
step
Choose the faction leader you would like to vote for:
|tip Turning in this quest in a capital city votes for that leader.
Bolvar Fordragon |confirm |next "Bolvar_Fordragon"
Magni Bronzebeard |confirm |next "Vote_Magni_Bronzebeard"
Tyrande Whisperwind |confirm |next "Tyrande_Whisperwind"
step
label "Bolvar_Fordragon"
talk Kwee Q. Peddlefeet##16075
accept Gift Giving##8993 |goto Stormwind City 78.67,17.45 |next "Final_Step"
step
label "Vote_Magni_Bronzebeard"
talk Kwee Q. Peddlefeet##16075
accept Gift Giving##8993 |goto Ironforge 40.30,56.59 |next "Final_Step"
step
label "Tyrande_Whisperwind"
Enter the building |goto Darnassus 39.03,77.23 < 15 |walk
Run up the ramp |goto Darnassus 40.49,91.59 < 15 |walk
talk Kwee Q. Peddlefeet##16075
|tip Upstairs inside the building.
accept Gift Giving##8993 |goto Darnassus 38.11,80.50 |next "Final_Step"
step
label "Final_Step"
You completed the Gift Giving quest
Click Here to Complete it Again |confirm |next "Begin_Guide"
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Midsummer Fire Festival\\Midsummer Fire Festival Quests",{
author="support@zygorguides.com",
condition_end=function() return completedq(11972) end,
description="\nComplete the following Midsummer Fire Festival event quests:\n\nPlaying with Fire\n"..
"Honor the Flame\nTorch Tossing\nTorch Catching\nIncense for the Festival Scorchlings\n"..
"Unusual Activity\nAn Innocent Disguise\nInform the Elder\nAhune, the Frost Lord\n"..
"Ahune is Here!\nSummon Ahune\n\n"..
"|cffff0000NOTE:|r You will need to be at least level 60 to fully complete this guide.",
},[[
step
talk Festival Loremaster##16817
accept Incense for the Summer Scorchlings##11964 |goto Stormwind City/0 38.58,61.84
step
talk Earthen Ring Elder##26221
accept Unusual Activity##11886 |goto Stormwind City/0 38.29,61.86
step
talk Master Fire Eater##25975
accept Torch Tossing##11731 |goto Stormwind City/0 39.36,62.18
step
use the Practice Torches##34862
|tip Throw them at the Torch Target Braziers nearby.
|tip You must throw the torches at the correct braziers.
|tip Throw the torches at the Torch Target Braziers when they have a floating red arrow point down above them.
|tip You will have 40 seconds to complete this before the quest fails.
|tip If you fail the quest, accept it again from the Master Fire Eater.
Hit 8 Braziers |q 11731/1 |goto Stormwind City/0 39.09,60.47
step
talk Master Fire Eater##25975
turnin Torch Tossing##11731 |goto Stormwind City/0 39.36,62.18
accept Torch Catching##11657 |goto Stormwind City/0 39.36,62.18
step
use the Unlit Torches##34833
|tip As soon as you light the torch, it will fly in the air.
|tip There will be a small round shadow on the ground indicating where the torch is flying.
|tip Follow that shadow and catch the torch.
|tip When you catch the torch, it will be thrown in the air again.
|tip Follow the shadow again and catch the torch.
|tip Do this until you've caught the torch 4 times in a row without it hitting the ground.
Catch 4 Torches in a Row |q 11657/1 |goto Stormwind City/0 39.09,60.47
step
talk Master Fire Eater##25975
turnin Torch Catching##11657 |goto Stormwind City/0 39.36,62.18
step
talk Summer Scorchling##26401
|tip Under the tent.
turnin Incense for the Summer Scorchlings##11964 |goto Elwynn Forest/0 43.49,62.50
step
talk Elwynn Forest Flame Warden##25898
|tip Under the tent.
accept Honor the Flame##11816 |goto Elwynn Forest/0 43.47,62.63
step
talk Fire Eater##25962
accept Playing with Fire##11882 |goto Elwynn Forest/0 43.69,62.23
step
talk Master Fire Eater##25975
turnin Playing with Fire##11882 |goto Stormwind City/0 39.36,62.18
step
Kill Twilight enemies around this area
collect Twilight Correspondence##35277 |q 11886/1 |goto Ashenvale/0 14.75,19.33
step
use the Totemic Beacon##35828
Watch the dialogue
_Next to you:_
talk Earthen Ring Guide##25324
turnin Unusual Activity##11886 |goto Ashenvale/0 14.49,19.22
accept An Innocent Disguise##11891 |goto Ashenvale/0 14.49,19.22
step
use the Orb of the Crawler##35237
Gain the Crab Disguise Buff |havebuff spell:46337 |q 11891 |goto Ashenvale/0 9.37,12.71
step
Watch the dialogue
Listen to the Plan of the Twilight Cultists |q 11891/1 |goto Ashenvale/0 9.07,12.41
step
use the Totemic Beacon##35828
Watch the dialogue
_Next to you:_
talk Earthen Ring Guide##25324
turnin An Innocent Disguise##11891 |goto Ashenvale/0 9.37,12.71
accept Inform the Elder##12012 |goto Ashenvale/0 9.37,12.71
step
talk Earthen Ring Elder##26221
turnin Inform the Elder##12012 |goto Stormwind City/0 38.30,61.83
accept Ahune, the Frost Lord##11955 |goto Stormwind City/0 38.30,61.83
step
talk Numa Cloudsister##25710
|tip Numa can be found inside The Slave Pens dungeon on any difficulty.
|tip She is at the beginning of the dungeon as you zone in.
|tip Ahune is level 73 elite and will require a group to kill.
turnin Ahune, the Frost Lord##11955 |goto Zangarmarsh/0 48.92,35.74
accept Ahune is Here!##11696 |goto Zangarmarsh/0 48.92,35.74
step
talk Luma Skymother##25697
|tip Luma can be found inside The Slave Pens dungeon on any difficulty.
|tip She is near the beginning of the dungeon before Mennu the Betrayer.
turnin Ahune is Here!##11696
accept Summon Ahune##11691
step
click Ice Stone
|tip The Ice Stone can be found inside The Slave Pens dungeon on any difficulty.
|tip It is near the beginning of the dungeon before Mennu the Betrayer.
turnin Summon Ahune##11691
|tip Turning in this quest will summon Ahune.
|tip Ahune will immediately attack.
step
kill Ahune##25740
|tip You will need a group for this.
click Ice Chest
|tip It spawns after he dies.
collect Shards of Ahune##35723 |q 11972 |future
step
use the Shards of Ahune##35723
accept Shards of Ahune##11972
step
talk Luma Skymother##25697
|tip Luma can be found inside The Slave Pens dungeon on any difficulty.
|tip She is near the beginning of the dungeon before Mennu the Betrayer.
turnin Shards of Ahune##11972
step
_Congratulations!_
You Completed the "Midsummer Fire Festival Quests" Guide.
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Midsummer Fire Festival\\Midsummer Fire Festival Dailies",{
author="support@zygorguides.com",
description="This guide will walk you through completing the Midsummer Fire Festival Dailies.",
},[[
step
Complete the "Midsummer Fire Festival Quests" Event Guide |complete completedq(12012)
step
label "Begin_Daily_Quests"
talk Master Fire Eater##25975
accept More Torch Tossing##11921 |goto Stormwind City/0 39.36,62.18
step
use the Practice Torches##34862
|tip Throw them at the Torch Target Braziers nearby.
|tip You must throw the torches at the correct braziers.
|tip Throw the torches at the Torch Target Braziers when they have a floating red arrow point down above them.
|tip You will have 40 seconds to complete this before the quest fails.
|tip If you fail, return to the Master Flame Eater to start again.
Hit 20 Braziers |q 11921/1 |goto Stormwind City/0 39.09,60.47
step
talk Master Fire Eater##25975
turnin More Torch Tossing##11921 |goto Stormwind City/0 39.36,62.18
step
talk Master Fire Eater##25975
accept More Torch Catching##11924 |goto Stormwind City/0 39.36,62.18
step
use the Unlit Torches##34833
|tip As soon as you light the torch, it will fly in the air.
|tip There will be a small round shadow on the ground indicating where the torch is flying.
|tip Follow that shadow and catch the torch.
|tip When you catch the torch, it will be thrown in the air again.
|tip Follow the shadow again and catch the torch.
|tip Do this until you've caught the torch 10 times in a row without it hitting the ground.
Catch 10 Torches in a Row |q 11924/1 |goto Stormwind City/0 39.09,60.47
step
talk Master Fire Eater##25975
turnin More Torch Catching##11924 |goto Stormwind City/0 39.36,62.18
step
talk Earthen Ring Elder##26221
accept Striking Back##11917 |goto Stormwind City/0 38.30,61.83 |only if level >= 22 and level <= 31
accept Striking Back##11947 |goto Stormwind City/0 38.30,61.83 |only if level >= 32 and level <= 42
accept Striking Back##11948 |goto Stormwind City/0 38.30,61.83 |only if level >= 43 and level <= 50
accept Striking Back##11952 |goto Stormwind City/0 38.30,61.83 |only if level >= 51 and level <= 59
accept Striking Back##11953 |goto Stormwind City/0 38.30,61.83 |only if level >= 60 and level <= 63
accept Striking Back##11954 |goto Stormwind City/0 38.30,61.83 |only if level >= 64
step
click Ice Stone##188149
|tip Inside the cave.
Choose _"Lay your hand on the stone"_
kill Frostwave Lieutenant##26116 |q 11917/1 |goto Ashenvale/0 9.62,12.20
|only if haveq(11917)
step
click Ice Stone##188149
Choose _"Lay your hand on the stone"_
kill Hailstone Lieutenant##26178 |q 11947/1 |goto Desolace/0 40.35,30.27
|only if haveq(11947)
step
click Ice Stone##188149
Choose _"Lay your hand on the stone"_
kill Glacial Lieutenant##26215 |q 11953/1 |goto Silithus/0 68.88,20.44
|only if haveq(11953)
step
click Ice Stone##188149
Choose _"Lay your hand on the stone"_
kill Chillwind Lieutenant##26204 |q 11948/1 |goto Stranglethorn Vale/0 21.30,23.37
|only if haveq(11948)
step
Enter the cave |goto Searing Gorge/0 21.83,36.18 < 20 |walk
click Ice Stone##188149
Choose _"Lay your hand on the stone"_
kill Frigid Lieutenant##26214 |q 11952/1 |goto Searing Gorge/0 16.02,36.86
|only if haveq(11952)
step
click Ice Stone##188149
Choose _"Lay your hand on the stone"_
kill Glacial Templar##26216 |q 11954/1 |goto Hellfire Peninsula/0 85.64,47.09
|only if haveq(11954)
step
talk Earthen Ring Elder##26221
turnin Striking Back##11917 |goto Stormwind City/0 38.30,61.83 |only if haveq(11917) or completedq(11917)
turnin Striking Back##11947 |goto Stormwind City/0 38.30,61.83 |only if haveq(11947) or completedq(11947)
turnin Striking Back##11948 |goto Stormwind City/0 38.30,61.83 |only if haveq(11948) or completedq(11948)
turnin Striking Back##11952 |goto Stormwind City/0 38.30,61.83 |only if haveq(11952) or completedq(11952)
turnin Striking Back##11953 |goto Stormwind City/0 38.30,61.83 |only if haveq(11953) or completedq(11953)
turnin Striking Back##11954 |goto Stormwind City/0 38.30,61.83 |only if haveq(11954) or completedq(11954)
step
You have completed all available dailies
|tip This guide will reset when more become available.
'|complete not completedq(11921,11924,11917,11947,11948,11952,11953,11954) |next "Begin_Daily_Quests"
]])
ZygorGuidesViewer:RegisterGuide("Events Guides\\Midsummer Fire Festival\\Midsummer Fire Festival Bonfires",{
author="support@zygorguides.com",
description="This guide will walk you through collecting the Midsummer Fire Festival Bonfires.",
},[[
step
talk Elwynn Forest Flame Warden##25898
accept Honor the Flame##11816 |goto Elwynn Forest/0 43.47,62.63
step
talk Stranglethorn Vale Flame Warden##25915
accept Honor the Flame##11832 |goto Stranglethorn Vale/0 33.90,73.52
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11801 |goto Stranglethorn Vale/0 33.04,75.38
step
talk Flame Warden##25890
accept Honor the Flame##11808 |goto Blasted Lands/0 59.28,17.01
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11781 |goto Swamp of Sorrows/0 46.91,46.31
step
talk Duskwood Flame Warden##25896
accept Honor the Flame##11814 |goto Duskwood/0 73.69,54.61
step
talk Westfall Flame Warden##25910
accept Honor the Flame##11583 |goto Westfall/0 55.92,53.48
step
talk Redridge Flame Warden##25904
accept Honor the Flame##11822 |goto Redridge Mountains/0 25.23,58.96
step
talk Burning Steppes Flame Warden##25892
accept Honor the Flame##11810 |goto Burning Steppes/0 80.30,62.89
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11768 |goto Burning Steppes/0 62.20,29.13
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11766 |goto Badlands/0 4.79,49.37
step
talk Loch Modan Flame Warden##25902
accept Honor the Flame##11820 |goto Loch Modan/0 32.56,40.95
step
talk Dun Morogh Flame Warden##25895
accept Honor the Flame##11813 |goto Dun Morogh/0 46.69,46.94
step
talk Wetlands Flame Warden##25911
accept Honor the Flame##11828 |goto Wetlands/0 13.46,47.07
step
talk Arathi Flame Warden##25887
accept Honor the Flame##11804 |goto Arathi Highlands/0 50.02,44.83
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11764 |goto Arathi Highlands/0 73.90,41.75
step
talk Hillsbrad Flame Warden##25901
accept Honor the Flame##11819 |goto Hillsbrad Foothills/0 50.43,47.58
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11776 |goto Hillsbrad Foothills/0 58.29,25.06
step
talk Western Plaguelands Flame Warden##25909
accept Honor the Flame##11827 |goto Western Plaguelands/0 43.46,82.33
step
talk The Hinterlands Flame Warden##25908
accept Honor the Flame##11826 |goto The Hinterlands/0 14.34,50.07
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11784 |goto The Hinterlands/0 76.63,74.45
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11580 |goto Silverpine Forest/0 49.63,38.68
step
click Flame of Undercity##181335
|tip It is recommended that you be level capped when attempting to complete this guide step.
|tip You will enter the opposing faction's capital city.
collect Flame of Undercity##23181 |goto Undercity/0 67.58,8.77 |q 9326 |future
step
use the Flame of Undercity##23181
accept Stealing Undercity's Flame##9326
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11786 |goto Tirisfal Glades/0 57.04,51.84
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11774 |goto Ghostlands/0 46.98,26.04
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11772 |goto Eversong Woods/0 46.43,50.41
step
click Flame of Silvermoon##188129
|tip It is recommended that you be level capped when attempting to complete this guide step.
|tip You will enter the opposing faction's capital city.
collect Flame of Silvermoon##35568 |goto Silvermoon City/0 69.67,42.74 |q 11935 |future
step
use the Flame of Silvermoon##35568
accept Stealing Silvermoon's Flame##11935
step
talk Darkshore Flame Warden##25893
accept Honor the Flame##11811 |goto Darkshore/0 36.96,46.17
step
talk Teldrassil Flame Warden##25906
accept Honor the Flame##11824 |goto Teldrassil/0 55.06,60.41
step
talk Azuremyst Isle Flame Warden##25888
accept Honor the Flame##11806 |goto Azuremyst Isle/0 44.48,52.50
step
talk Bloodmyst Isle Flame Warden##25891
accept Honor the Flame##11809 |goto Bloodmyst Isle/0 55.83,67.88
step
talk Winterspring Flame Warden##25917
accept Honor the Flame##11834 |goto Winterspring/0 62.55,35.43
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Descrate this Fire!##11803 |goto Winterspring/0 59.89,35.38
step
talk Ashenvale Flame Warden##25883
accept Honor the Flame##11805 |goto Ashenvale/0 37.78,54.73
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11765 |goto Ashenvale/0 70.0,69.2
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11783 |goto The Barrens/0 52.17,27.85
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11770 |goto Durotar/0 52.02,47.10
step
click Flame of Orgrimmar##181336
|tip It is recommended that you be level capped when attempting to complete this guide step.
|tip You will enter the opposing faction's capital city.
collect Flame of Orgrimmar##23179 |goto Orgrimmar/0 46.81,38.20 |q 9324 |future
step
use the Flame of Orgrimmar##23179
accept Stealing Orgrimmar's Flame##9324
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11780 |goto Stonetalon Mountains/0 50.60,60.27
step
talk Desolace Flame Warden##25894
accept Honor the Flame##11812 |goto Desolace/0 66.12,17.09
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11769 |goto Desolace/0 26.26,77.23
step
talk Feralas Flame Warden##25899
accept Honor the Flame##11817 |goto Feralas/0 28.19,43.80
The boat to Sardor Isle can be found at [Feralas/0 43.34,42.75]
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11773 |goto Feralas/0 72.47,47.70
The boat to the mainland can be found at [Feralas/0 31.03,39.86]
step
talk Silithus Flame Warden##25914
accept Honor the Flame##11831 |goto Silithus/0 57.47,35.24
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11800 |goto Silithus/0 46.40,44.77
step
talk Tanaris Flame Warden##25916
accept Honor the Flame##11833 |goto Tanaris/0 52.76,29.37
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11802 |goto Tanaris/0 49.77,27.10
step
click Horde Bonfire##187973
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11785 |goto Thousand Needles/0 42.49,52.89
step
talk Dustwallow Marsh Flame Warden##25897
accept Honor the Flame##11815 |goto Dustwallow Marsh/0 61.82,40.46
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11771 |goto Dustwallow Marsh/0 33.28,30.87
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11777 |goto Mulgore/0 52.11,59.98
step
click Flame of Thunder Bluff##181337
|tip It is recommended that you be level capped when attempting to complete this guide step.
|tip You will enter the opposing faction's capital city.
collect Flame of Thunder Bluff##23180 |goto Thunder Bluff/0 21.48,26.01 |q 9325 |future
step
use the Flame of Thunder Bluff##23180
accept Stealing Thunder Bluff's Flame##9325
step
talk Festival Loremaster##16817
turnin Stealing Orgrimmar's Flame##9324 |goto Ironforge/0 63.80,25.31 |only if haveq(9324) or completedq(9324)
turnin Stealing Thunder Bluff's Flame##9325 |goto Ironforge/0 63.80,25.31 |only if haveq(9325) or completedq(9325)
turnin Stealing the Undercity's Flame##9326 |goto Ironforge/0 63.80,25.31 |only if haveq(9326) or completedq(9326)
turnin Stealing Silvermoon's Flame##11935 |goto Ironforge/0 63.80,25.31 |only if haveq(11935) or completedq(11935)
accept A Thief's Reward##9365 |goto Ironforge/0 63.80,25.31 |only if completedallq(9324,9325,9326,11935)
|only if haveq(9324,9325,9326,11935) or completedq(9324,9325,9326,11935)
step
talk Hellfire Peninsula Flame Warden##25900
accept Honor the Flame##11818 |goto Hellfire Peninsula/0 62.17,58.29
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11775 |goto Hellfire Peninsula/0 57.19,41.92
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11799 |goto Netherstorm/0 32.26,68.35
step
talk Netherstorm Flame Warden##25913
accept Honor the Flame##11830 |goto Netherstorm/0 31.21,62.66
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11767 |goto Blade's Edge Mountains/0 49.94,59.00
step
talk Blade's Edge Flame Warden##25889
accept Honor the Flame##11807 |goto Blade's Edge Mountains/0 41.57,65.90
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11787 |goto Zangarmarsh/0 35.52,51.79
step
talk Zangarmarsh Flame Warden##25912
accept Honor the Flame##11829 |goto Zangarmarsh/0 68.79,51.95
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11778 |goto Nagrand/0 51.08,33.94
step
talk Nagrand Flame Warden##25903
accept Honor the Flame##11821 |goto Nagrand/0 49.61,69.47
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11782 |goto Terokkar Forest/0 52.01,43.22
step
talk Terokkar Forest Flame Warden##25907
accept Honor the Flame##11825 |goto Terokkar Forest/0 54.1,55.5
step
click Horde Bonfire##194039
|tip Completing this will flag you for PvP combat for five minutes.
accept Desecrate this Fire!##11779 |goto Shadowmoon Valley/0 33.54,30.32
step
talk Shadowmoon Valley Flame Warden##25905
accept Honor the Flame##11823 |goto Shadowmoon Valley/0 39.63,54.63
]])
