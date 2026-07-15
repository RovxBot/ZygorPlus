local ZygorGuidesViewer=ZygorGuidesViewer
if not ZygorGuidesViewer then return end
if UnitFactionGroup("player")~="Horde" then return end
if ZGV:DoMutex("ReputationsHCLASSIC") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Bloodsail Buccaneers",{
},[[
step
_NOTE:_
About Bloodsail Buccaneers Reputation
|tip To {o}increase your reputation{} with the {o}Bloodsail Buccaneers{}, you {o}must be at War with Booty Bay{} and the {o}Steamwheedle Cartel{}.
|tip You can {o}increase your reputation{} with the {o}Steamwheedle Cartel{} afterwards, but it's a {o}long grind{}.
|tip Make sure you are {o}ready to be at war{} with the {o}goblins{} for some time.
|tip It takes around {o}2300 Booty Bay Guard kills{} to get enough rep to unlock the {o}Bloodsail Outfit and Admiral Hat{}, then {o}thousands more{} to regain {o}Booty Bay{} reputation.
Best Time to Grind
|tip If you are {o}not in a hurry{}, the {o}best time{} to grind this reputation is {o}New Year's Eve{}.
|tip The {o}Booty Bay goblins{} will be {o}drunk{} and {o}won't fight back{}.
Click Here to Continue |confirm
step
_NOTE:_
Go to War with Booty Bay
|tip Press {o}U{} to open your reputation panel.
|tip Select the {o}Booty Bay{} reputation, and mark the {o}At War{} checkbox.
Click Here to Continue |confirm
step
kill Booty Bay Bruiser##4624+
|tip This is the {o}safest location{} to grind if you are {o}solo{}.
|tip There are {o}4 patrolling guards{} that you can {o}kill one at a time{}.
|tip If you kill the {o}patrolling guards quickly{}, go inside the {o}Blacksmithing Houses{} and {o}attack civilians{} to {o}spawn more guards{}.
|tip To get the {o}Admiral's Hat{}, you must be {o}Hated with Booty Bay{}.
|tip You {o}can't keep{} both {o}reputations Friendly{} at the {o}same time{}.
Reach Hated Reputation with Booty Bay |complete rep('Booty Bay') == Hated |goto Stranglethorn Vale/0 28.77,74.70
Reach Friendly Reputation with the Bloodsail Buccaneers Faction |complete rep('Bloodsail Buccaneers') == Friendly |goto Stranglethorn Vale/0 28.77,74.70
step
talk "Pretty Boy" Duncan##2545
|tip He gets {o}killed for a quest{}.
|tip If he's {o}not here{}, wait for him to {o}respawn{}.
accept Avast Ye, Scallywag##1036 |goto Stranglethorn Vale/0 27.60,69.60
step
talk Fleet Master Firallon##2546
|tip Inside the ship, on the {o}middle floor{}.
|tip You must be {o}Hated with Booty Bay{}.
accept Dressing the Part##9272 |goto Stranglethorn Vale/0 30.60,90.60
turnin Avast Ye, Scallywag##1036 |goto Stranglethorn Vale/0 30.60,90.60
accept Avast Ye, Admiral!##4621 |goto Stranglethorn Vale/0 30.60,90.60
step
kill Baron Revilgaz##2496 |q 4621/1 |goto Stranglethorn Vale/0 27.12,76.97
kill Fleet Master Seahorn##2487 |q 4621/2 |goto Stranglethorn Vale/0 27.12,76.97
|tip On the {o}top floor{} of the building, {o}outside{} on the {o}balcony{}.
step
talk Fleet Master Firallon##2546
|tip Inside the ship, on the {o}middle floor{}.
turnin Avast Ye, Admiral!##4621 |goto Stranglethorn Vale/0 30.60,90.60
step
Congratulations!
|tip You {o}unlocked{} all of the {o}rewards{} for the {o}Bloodsail Buccaneer{} faction.
|tip There are {o}no rewards{} for reaching {o}Exalted{} reputation with the {o}Bloodsail Buccaneer{} faction.
|tip Click the {o}line below{} to begin {o}repairing{} your {o}reputaiton{} with the {o}Steamwheedle Cartel{}.
Load the Steamwheedle Cartel Guide |loadguide "Reputation\\Steamwheedle Cartel"
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Brood of Nozdormu",{
},[[
step
_NOTE:_
About Brood of Nozdormu Reputation
|tip This {o}reputation{} can be {o}earned{} by running the {o}Ahn'Qiraj raid (40 man){}.
Click Here to Continue |confirm
step
_Inside the Ahn'Qiraj Raid:_
Kill enemies throughout the raid
|tip You will {o}collect items{} that can be {o}turned in for Brood of Nozdormu reputation{}.
|tip {o}Don't turn them in{} until you reach {o}at least 2999/3000 Neutral{} reputation.
|tip {o}Killing enemies{} in the raid {o}gives reputation{} until that point, so it's best to {o}save the items{} until later.
collect Ancient Qiraji Artifact##21230+ |n
|tip {o}Any enemies{} can drop these.
collect Qiraji Lord's Insignia##21229+ |n
|tip {o}Bosses{} drop these.
Reach _2999/3000 Neutral_ Reputation with Brood of Nozdormu |complete repval('Brood of Nozdormu','Neutral') >= 2999
step
_Inside the Ahn'Qiraj Raid:_
use the Ancient Qiraji Artifact##21230+
|tip Accept the {o}Secrets of the Qiraji{} quest.
talk Andorgos##15502
|tip Turn in the {o}repeatable quest{}.
|tip {o}Repeat this process{} until you have no more {o}Ancient Qiraji Artifacts{}.
Click Here to Continue |confirm
|only if not rep('Brood of Nozdormu') == Exalted
step
talk Kandrostrasz##15503
accept Mortal Champions##8579
|only if not completedq(8579)
step
talk Kandrostrasz##15503
turnin Mortal Champions##8579
|only if not completedq(8579)
step
label "Collect_Rep_items"
_Inside the Ahn'Qiraj Raid:_
Kill enemies throughout the raid
|tip You will {o}collect items{} that can be {o}turned in for Brood of Nozdormu reputation{}.
collect Ancient Qiraji Artifact##21230+ |n
|tip {o}Any enemies{} can drop these.
collect Qiraji Lord's Insignia##21229+ |n
|tip {o}Bosses{} drop these.
Click Here to Continue |confirm
|only if not rep('Brood of Nozdormu') == Exalted
step
_Inside the Ahn'Qiraj Raid:_
use the Ancient Qiraji Artifact##21230+
|tip Accept the {o}Secrets of the Qiraji{} quest.
talk Andorgos##15502
|tip Turn in the {o}repeatable quest{}.
|tip {o}Repeat this process{} until you have no more {o}Ancient Qiraji Artifacts{}.
Click Here to Continue |confirm
|only if not rep('Brood of Nozdormu') == Exalted
step
talk Kandrostrasz##15503
|tip Accept and turn in the {o}Mortal Champions{} quest.
|tip This is a {o}repeatable quest{}.
|tip You {o}must have{} a {o}Qiraji Lord's Insignia{} item to be {o}able to complete{} this quest.
Click Here to Continue |confirm
|only if not rep('Brood of Nozdormu') == Exalted
step
Routing Guide	|complete rep('Brood of Nozdormu') < Exalted	|or	|next "Collect_Rep_items"
Routing Guide	|complete rep('Brood of Nozdormu') == Exalted	|or	|next "Exalted"
step
label "Exalted"
Reach Exalted Reputation with the Brood of Nozdormu Faction |complete rep('Brood of Nozdormu') == Exalted
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Cenarion Circle",{
},[[
_NOTE:_
About Cenarion Circle Reputation
|tip You can gain reputation {o}two ways{}.
|tip Killing enemies inside the {o}Ahn'Qiraj raid (20 man){} or killing {o}Twilight Cultists in Silithus{}.
|tip The {o}Ahn'Qiraj (20 man){} method takes roughly {o}3 months{} to reach {o}Exalted{}.
|tip The {o}Silithus method is much faster{}, and is the method this guide uses.
Click Here to Continue |confirm
step
Kill Twilight enemies around this area
|tip {o}Group up{} with nearby players, if you can, to {o}make the grind easier{}.
collect Encrypted Twilight Text##20404+ |n
|tip {o}Save{} any of these you find, you will {o}turn them in later{}.
Reach Honored Reputation with the Cenarion Circle Faction |complete rep("Cenarion Circle") >= Honored |goto Silithus/0 66.60,17.80
You can find more around: |notinsticky
[Silithus/0 26.80,34.60]
[Silithus/0 40.20,44.60]
[Silithus/0 20.40,85.60]
step
talk Bor Wildmane##15306
accept Secret Communication##8318 |goto Silithus 48.57,37.78
step
Kill Twilight enemies around this area
|tip {o}Group up{} with nearby players, if you can, to {o}make the grind easier{}.
collect 10 Encrypted Twilight Text##20404 |q 8318/1 |goto Silithus/0 66.60,17.80
You can find more around: |notinsticky
[Silithus/0 26.80,34.60]
[Silithus/0 40.20,44.60]
[Silithus/0 20.40,85.60]
step
talk Bor Wildmane##15306
turnin Secret Communication##8318 |goto Silithus 48.57,37.78
step
_NOTE:_
Complete Quests in Silithus
|tip At this point, {o}quests in Silithus{} are a {o}reliable source of reputation{}.
|tip Use the {o}Silithus leveing guide{} to accomplish this.
Click Here to Continue |confirm
|only if not rep('Cenarion Circle') == Exalted
step
Kill Twilight enemies around this area
|tip {o}Group up{} with nearby players, if you can, to {o}make the grind easier{}.
collect Encrypted Twilight Text##20404+ |n
|tip You can turn in {o}stacks of 10{} for reputation.
|tip Each {o}stack of 10{} is worth {o}100 reputation{} until Exalted. |only if not Human
|tip Each {o}stack of 10{} is worth {o}110 reputation{} until Exalted. |only if Human
|tip You can {o}buy these from the Auction House{}, if you {o}have gold{} and want to {o}save time{}.
Reach Exalted Reputation with the Cenarion Circle Faction |complete rep("Cenarion Circle") >= Exalted |goto Silithus/0 66.60,17.80
You can find more around: |notinsticky
[Silithus/0 26.80,34.60]
[Silithus/0 40.20,44.60]
[Silithus/0 20.40,85.60]
|tip
Turn in Encrypted Twilight Texts to Bor Wildmane at [Silithus 48.57,37.78]
|tip He offers an {o}Encrypted Twilight Texts{} quest that is {o}repeatable{}.
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Gelkis & Magram Centaur Clans",{
},[[
step
About Centaur Clans Reputation
|tip There are  {o}two centaur clans{} you can earn reputation with: {o}Gelkis Clan Centaur{} and {o}Magram Clan Centaur{}.
|tip You can only {o}earn reputation{} with {o}one clan at a time{}.
|tip The {o}maximum reputation{} with each is {o}Revered{}, and there are {o}no reputation rewards{}, so it's {o}personal preference{}.
Choose Your Clan
|tip Click the {o}line below{} for the {o}clan you want{} to earn reputation with.
Gelkis Clan Centaur	|confirm	|or	|next "Gelkis"
Magram Clan Centaur	|confirm	|or	|next "Magram"
step
label "Gelkis"
Kill Magram enemies around this area
|tip They look like {o}centaurs{}.
Reach _11999/20000 Honored_ Reputation with the Glekis Clan Centaur Faction |complete repval('Gelkis Clan Centaur', 'Honored') >= 11999 |goto Desolace/0 70.90,75.30
step
talk Captain Pentigast##5396
accept Strange Alliance##1382 |goto Desolace 66.66,10.93
|only if Alliance
step
talk Gurda Wildmane##5412
accept Gelkis Alliance##1368 |goto Desolace 56.29,59.68
|only if Horde
step
talk Uthek the Wise##5397
turnin Strange Alliance##1382 |goto Desolace 36.23,79.25	|only if Alliance
turnin Gelkis Alliance##1368 |goto Desolace 36.23,79.25		|only if Horde
|next "Revered"
step
label "Magram"
Kill Gelkis enemies around this area
|tip They look like {o}centaurs{}.
Reach _11999/20000 Honored_ Reputation with the Magram Clan Centaur Faction |complete repval('Magram Clan Centaur', 'Honored') >= 11999 |goto Desolace/0 37.40,85.30
step
talk Captain Pentigast##5396
accept Brutal Politics##1385 |goto Desolace 66.66,10.93
|only if Alliance
step
talk Gurda Wildmane##5412
accept Magram Alliance##1367 |goto Desolace 56.29,59.68
|only if Horde
step
talk Warug##5398
turnin Brutal Politics##1385 |goto Desolace 74.97,68.16		|only if Alliance
turnin Magram Alliance##1367 |goto Desolace 74.97,68.16		|only if Horde
|next "Revered"
step
label "Revered"
Reach Exalted Reputation with the Gelkis Clan Centaur Faction |complete rep('Gelkis Clan Centaur') == Revered |only if rep('Gelkis Clan Centaur') == Revered
Reach Exalted Reputation with the Magram Clan Centaur Faction |complete rep('Magram Clan Centaur') == Revered |only if rep('Magram Clan Centaur') == Revered
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Hydraxian Waterlords",{
},[[
step
_NOTE:_
Attune to Molten Core
|tip Use the {o}Blackrock Depths{} dungeon guide to accomplish this.
Click Here to Continue |confirm
step
_Inside the Molten Core Raid:_
Kill enemies throughout the raid
|tip Use the {o}Molten Core{} raid guide to accomplish this.
|tip You will have to {o}clear the raid many times{}.
|tip You can only become {o}Exalted{} by killing the {o}Golemagg the Incinerator{} or {o}Ragnaros{} bosses.
|tip Otherwise, the {o}max{} reputation is {o}20999/21000 Revered{}.
Reach Exalted Reputation with the Hydraxian Waterlords Faction |complete rep('Hydraxian Waterlords') == Exalted
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Ravenholdt",{
},[[
step
_NOTE:_
About Ravenholdt Reputation
|tip You will have to {o}kill around 4200 enemies{} to reach _11,999/12,000 Honored_ reputation.
|tip After that, you will need to {o}collect roughly 1200 Heavy Junkboxes{}.
|tip You will need a {o}Rogue{} to {o}help you{} collect the boxes. |only if not Rogue
|tip There are {o}no rewards{} for this reputation.
Click Here to Continue |confirm
step
Kill Syndicate enemies around this area
|tip They look like {o}humans{}.
Reach _11,999/12,000 Honored_  Reputation with the Ravenholdt Faction |complete repval('Ravenholdt','Honored') >= 11999  |goto Arathi Highlands 27.10,30.60
You can find more around [Arathi Highlands 19.50,61.50]
step
_Inside the Blackrock Spire Dungeon:_
Find a Rogue to Help You
|tip Find a {o}Rogue{} to {o}pickpocket enemies{} inside the {o}Blackrock Spire{} dungeon.
|tip The {o}Rogue{} can {o}give you the Heavy Junkboxes{} they pickpocket.
|tip You can also try to {o}purchase Heavy Junkboxes{} in major city {o}Trade Chat{}, paying either {o}by mail or in person{}.
|tip The {o}Heavy Junkboxes{} need {o}at least 1 item{} left in them to count.
collect Heavy Junkbox##16885+ |n
|tip Every 5 junkboxes you turn in, you get 75 repututation.
Collect Enough Heavy Junkboxes to Reach Exalted |repcollect Heavy Junkbox##16885,5,75,Ravenholdt,Exalted
|tip This step will complete {o}when you have enough{}.
step
talk Fahrad##6707
|tip Upstairs in the building, {o}outside on the balcony{}.
|tip Complete the {o}Junkboxes Needed{} quest {o}repeatedly{}.
Reach Exalted Reputation with the Ravenholdt Faction |complete rep("Ravenholdt") >= Exalted |goto Alterac Mountains 84.45,80.32
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Steamwheedle Cartel",{
},[[
step
talk Zorbin Fandazzle##14637
accept Zapped Giants##7003 |goto Feralas 44.81,43.42
step
use Zorbin's Ultra-Shrinker##18904
|tip Use it on {o}Wave Striders{}.
|tip They look like {o}tall green giants{} that walk {o}on the shore{} and {o}in the water{}.
|tip This {o}quest item{} only lasts for {o}2 hours{}.
|tip If you {o}need a new one{}, {o}abandon{} the quest and {o}accept it again{} from the {o}goblin{} in the {o}previous guide step{}.
|tip The {o}water elementals{} nearby are {o}immune to frost damage{}.	|only if hardcore
kill Zapped Wave Strider##14638+
collect 15 Miniaturization Residue##18956 |q 7003/1 |goto Feralas 44.38,50.11
You can find more around: |notinsticky
[Feralas 46.63,59.79]
[Feralas 45.36,67.94]
[Feralas 40.03,37.38]
[Feralas 36.09,33.74]
step
talk Zorbin Fandazzle##14637
turnin Zapped Giants##7003 |goto Feralas 44.81,43.42
step
label "Again_With_The_Zapped_Giants"
talk Zorbin Fandazzle##14637
accept Again With the Zapped Giants##7725 |goto Feralas 44.81,43.42
|only if not rep("Steamwheedle Cartel") == Exalted
step
use Zorbin's Ultra-Shrinker##18904
|tip Use it on {o}Wave Striders{}.
|tip They look like {o}tall green giants{} that walk {o}on the shore{} and {o}in the water{}.
|tip This {o}quest item{} only lasts for {o}2 hours{}.
|tip If you {o}need a new one{}, {o}abandon{} the quest and {o}accept it again{} from the {o}goblin{} in the {o}previous guide step{}.
|tip The {o}water elementals{} nearby are {o}immune to frost damage{}.	|only if hardcore
kill Zapped Wave Strider##14638+
collect 10 Miniaturization Residue##18956 |q 7725/1 |goto Feralas 44.38,50.11
You can find more around: |notinsticky
[Feralas 46.63,59.79]
[Feralas 45.36,67.94]
[Feralas 40.03,37.38]
[Feralas 36.09,33.74]
|only if not rep("Steamwheedle Cartel") == Exalted
step
talk Zorbin Fandazzle##14637
turnin Again With the Zapped Giants##7725 |goto Feralas 44.81,43.42
|only if not rep('Steamwheedle Cartel') == Exalted
step
Routing Guide	|complete rep('Steamwheedle Cartel') < Exalted	|or	|next "Again_With_The_Zapped_Giants"
Routing Guide	|complete rep('Steamwheedle Cartel') == Exalted	|or	|next "Exalted"
step
label "Exalted"
Reach Exalted Reputation with the Steamwheedle Cartel Faction |complete rep('Steamwheedle Cartel') == Exalted
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Timbermaw Hold",{
},[[
step
_NOTE:_
About Timbermaw Hold Reputation
|tip We recommend working on Wintersaber Trainers reputation first (or alongside Timbermaw Hold reputation).
|tip You need to {o}grind thousands of Furbolgs{} for {o}Wintersaber Trainers{} reputation, which will {o}naturally raise your Timbermaw Hold reputation{}.
Click Here to Continue |confirm
step
talk Grazle##11554
accept Timbermaw Ally##8460 |goto Felwood 50.93,85.01
stickystart "Kill_Deadwood_Pathfinders"
stickystart "Kill_Deadwood_Gardeners"
step
kill 6 Deadwood Warrior##7153 |q 8460/1 |goto Felwood 48.32,92.99
|tip Be careful of {o}enemies grouped in camps{}, they {o}may attack together{}.	|only if hardcore
|tip {o}Deadwood Gardeners{} may {o}reduce the healing on you{}.			|only if hardcore
|tip {o}Deadwood Pathfinders{} are {o}ranged attackers{}.				|only if hardcore
You can find more around: |notinsticky
[Felwood 46.51,88.13]
[Felwood 48.77,89.62]
step
label "Kill_Deadwood_Pathfinders"
kill 6 Deadwood Pathfinder##7155 |q 8460/2 |goto Felwood 48.32,92.99
|tip Be careful of {o}enemies grouped in camps{}, they {o}may attack together{}.	|only if hardcore |notinsticky
|tip {o}Deadwood Gardeners{} may {o}reduce the healing on you{}.			|only if hardcore |notinsticky
|tip {o}Deadwood Pathfinders{} are {o}ranged attackers{}.				|only if hardcore |notinsticky
You can find more around: |notinsticky
[Felwood 46.51,88.13]
[Felwood 48.77,89.62]
step
label "Kill_Deadwood_Gardeners"
kill 6 Deadwood Gardener##7154 |q 8460/3 |goto Felwood 48.32,92.99
|tip Be careful of {o}enemies grouped in camps{}, they {o}may attack together{}.	|only if hardcore |notinsticky
|tip {o}Deadwood Gardeners{} may {o}reduce the healing on you{}.			|only if hardcore |notinsticky
|tip {o}Deadwood Pathfinders{} are {o}ranged attackers{}.				|only if hardcore |notinsticky
You can find more around: |notinsticky
[Felwood 46.51,88.13]
[Felwood 48.77,89.62]
step
talk Grazle##11554
turnin Timbermaw Ally##8460 |goto Felwood 50.93,85.02
accept Speak to Nafien##8462 |goto Felwood 50.93,85.02
step
talk Nafien##15395
|tip Up on the cliff, follow the road.
turnin Speak to Nafien##8462 |goto Felwood 64.77,8.13
accept Deadwood of the North##8461 |goto Felwood 64.77,8.13
stickystart "Kill_Deadwood_Avengers"
stickystart "Kill_Deadwood_Shamans"
step
kill 6 Deadwood Den Watcher##7156 |q 8461/1 |goto Felwood 63.08,8.82
You can find more around: |notinsticky
[Felwood 60.37,8.40]
[Felwood 60.18,6.14]
[Felwood 62.67,12.48]
step
label "Kill_Deadwood_Avengers"
kill 6 Deadwood Avenger##7157 |q 8461/2 |goto Felwood 63.08,8.82
You can find more around: |notinsticky
[Felwood 60.37,8.40]
[Felwood 60.18,6.14]
[Felwood 62.67,12.48]
step
label "Kill_Deadwood_Shamans"
kill 6 Deadwood Shaman##7158 |q 8461/3 |goto Felwood 63.08,8.82
You can find more around: |notinsticky
[Felwood 60.37,8.40]
[Felwood 60.18,6.14]
[Felwood 62.67,12.48]
step
Kill Deadwood enemies around this area
|tip They look like {o}furbolgs{}.
Reach Unfriendly Reputation with the Timbermaw Hold Faction |complete rep('Timbermaw Hold') >= Unfriendly |goto Felwood/0 63.08,8.82
step
talk Nafien##15395
|tip Up on the cliff, follow the road.
|tip {o}Don't{} turn in any {o}Deadwood Headdress Feathers{} yet.
turnin Deadwood of the North##8461 |goto Felwood/0 64.77,8.13
accept Speak to Salfa##8465 |goto Felwood/0 64.77,8.13
step
Enter the tunnel to leave Felwood |goto Felwood 65.13,8.01 < 15 |only if walking |only if not zone("Winterspring")
Leave the tunnel to enter Winterspring |goto Felwood 68.40,5.84 < 15 |only if walking |only if not zone("Winterspring") |notravel
talk Salfa##11556
turnin Speak to Salfa##8465 |goto Winterspring 27.74,34.50
accept Winterfall Activity##8464 |goto Winterspring 27.74,34.50
stickystart "Kill_Winterfall_Ursas"
stickystart "Kill_Winterfall_Den_Watchers"
step
kill 8 Winterfall Shaman##7441 |q 8464/1 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.
step
label "Kill_Winterfall_Den_Watchers"
kill 8 Winterfall Den Watcher##7442 |q 8464/2 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.	|notinsticky
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.			|notinsticky
step
label "Kill_Winterfall_Ursas"
kill 8 Winterfall Ursa##7440 |q 8464/3 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.	|notinsticky
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.			|notinsticky
You may find more on top of the mountain ridge around [Winterspring 65.53,37.66]
step
talk Salfa##11556
turnin Winterfall Activity##8464 |goto Winterspring 27.74,34.50
step
use the Deadwood Ritual Totem##20741
accept Deadwood Ritual Totem##8470
|only if itemcount(20741) > 0
step
Enter the tunnel to leave Winterspring |goto Felwood 68.22,5.56 < 15 |only if walking |only if not zone("Felwood")
talk Kernda##11558
|tip He looks like a {o}grey furbolg{}.
|tip He walks around {o}inside the tunnel near this location{o} and the {o}tunnel leading north{}.
turnin Deadwood Ritual Totem##8470 |goto Felwood 65.37,2.42
|only if haveq(8470) or completedq(8470)
step
talk Nafien##15395
|tip Turn in any {o}Deadwood Headdress Feathers{} you have.
|tip He offers a {o}Feathers for Nafien{} quest that is {o}repeatable{}.
Turn In All of Your Deadwood Headdress Feathers |complete itemcount(21377) < 5
step
Kill Winterfall enemies around this area
|tip They look like {o}furbolgs{}.
collect Winterfall Spirit Beads##21383+ |n
|tip {o}Save{} any {o}Winterfall Spirit Beads{} you find.
|tip We will turn them in {o}after you reach Revered{} reputation.
Reach Revered Reputation with the Timbermaw Hold Faction |complete rep('Timbermaw Hold') >= Revered |goto Winterspring 67.30,36.36
You can find more around: |notinsticky
[Winterspring 40.56,43.08]
[Winterspring 31.54,37.12]
step
Kill Winterfall enemies around this area
|tip They look like {o}furbolgs{}.
collect Winterfall Spirit Beads##21383+ |n
|tip Every 5 beads you turn in, you get 50 repututation.
Collect Enough Winterfall Spirit Beads to Reach Exalted |repcollect Winterfall Spirit Beads##21383,5,50,Timbermaw Hold,Exalted |goto Winterspring 67.30,36.36
|tip This step will complete {o}when you have enough{}.
You can find more around: |notinsticky
[Winterspring 40.56,43.08]
[Winterspring 31.54,37.12]
step
talk Salfa##11556
|tip Turn in any {o}Winterfall Spirit Beads{} you have.
|tip He offers a {o}Beads for Salfa{} quest that is {o}repeatable{}.
Reach Exalted Reputation with the Timbermaw Hold Faction |complete rep("Timbermaw Hold") >= Exalted |goto Winterspring 27.74,34.50
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Thorium Brotherhood",{
},[[
step
_NOTE:_
About Thorium Brotherhood Reputation
|tip {o}Earning reputation{} with this faction can be {o}expensive{} or {o}very time consuming{}.
|tip {o}Most steps{} require use of the {o}Auction House{} or {o}grinding thousands of materials{}.
|tip {o}Honored to Exalted{} will need a {o}lot of gold{} or {o}help from a guild{}, as it requires {o}materials from Molten Core{}.
Click Here to Continue |confirm
step
talk Hansel Heavyhands##14627
accept Curse These Fat Fingers##7723 |goto Searing Gorge 38.57,27.80
accept Fiery Menace!##7724 |goto Searing Gorge 38.57,27.80
accept Incendosaurs? Whateverosaur is More Like It##7727 |goto Searing Gorge 38.57,27.80
step
talk Master Smith Burninate##14624
accept What the Flux?##7722 |goto Searing Gorge/0 38.77,28.50
step
click Wanted/Missing/Lost & Found##179827
accept STOLEN: Smithing Tuyere and Lookout's Spyglass##7728 |goto Searing Gorge 37.63,26.53
accept JOB OPPORTUNITY: Culling the Competition##7729 |goto Searing Gorge 37.63,26.53
stickystart "Collect_Smithing_Tuyere"
stickystart "Kill_Greater_Lava_Spiders"
stickystart "Kill_Heavy_War_Golems"
step
kill Dark Iron Lookout##8566+
|tip They are around the watch towers on the cliff surrounding the huge pit.
collect Lookout's Spyglass##18960 |q 7728/2 |goto Searing Gorge 33.03,53.44
You can find more around: |notinsticky
[Searing Gorge 35.40,59.82]
[Searing Gorge 43.47,63.52]
[Searing Gorge 52.47,57.97]
step
label "Collect_Smithing_Tuyere"
kill Dark Iron Steamsmith##5840+
|tip They have a roughly 5 minute respawn time.
|tip Work on the other quests around this area while waiting for them to respawn.
collect Smithing Tuyere##18959 |q 7728/1 |goto Searing Gorge 39.13,49.64
You can find more around [Searing Gorge 42.86,51.59]
step
label "Kill_Greater_Lava_Spiders"
kill 20 Greater Lava Spider##5858 |q 7724/1 |goto Searing Gorge 28.78,44.44
You can find more around: |notinsticky
[Searing Gorge 29.23,55.00]
[Searing Gorge 29.51,72.50]
step
label "Kill_Heavy_War_Golems"
kill 20 Heavy War Golem##5854 |q 7723/1	|goto Searing Gorge 32.42,49.43
You can find more around: |notinsticky
[Searing Gorge 37.02,42.98]
[Searing Gorge 47.99,38.64]
step
Jump down onto the metal walkway here |goto Searing Gorge 49.32,43.74 < 15 |only if walking
Enter the cave |goto Searing Gorge/0 49.58,45.49 < 15 |c
|only if not (subzone("The Slag Pit") and _G.IsIndoors())
step
Cross the bridge |goto Searing Gorge/0 44.45,37.35 < 20 |walk
click Secret Plans: Fiery Flux##179826
|tip It looks like an {o}unrolled scroll on a bench{}.
|tip Inside the cave.
|tip {o}Overseer Maltorius{} can be a {o}very deadly{} enemy, so you {o}may need help{} with this.
click Secret Plans: Fiery Flux##179826 |q 7722/1 |goto Searing Gorge/0 40.39,35.73
step
Jump down from the bridge inside the cave |goto Searing Gorge 47.73,41.92 < 15 |walk
kill 20 Incendosaur##9318 |q 7727/1 |goto Searing Gorge 51.73,37.16
|tip Inside the cave.
You can find more around: |notinsticky
[Searing Gorge 50.37,24.75]
[Searing Gorge 45.03,21.73]
step
Leave the cave |goto Searing Gorge 47.52,46.46 < 15 |walk |only if (subzone("The Slag Pit") and _G.IsIndoors())
talk Hansel Heavyhands##14627
turnin Curse These Fat Fingers##7723 |goto Searing Gorge 38.59,27.81
turnin Fiery Menace!##7724 |goto Searing Gorge 38.59,27.81
turnin Incendosaurs? Whateverosaur is More Like It##7727 |goto Searing Gorge 38.59,27.81
step
talk Taskmaster Scrange##14626
turnin STOLEN: Smithing Tuyere and Lookout's Spyglass##7728 |goto Searing Gorge 38.98,27.51
turnin JOB OPPORTUNITY: Culling the Competition##7729 |goto Searing Gorge 38.98,27.51
step
talk Master Smith Burninate##14624
turnin What the Flux?##7722 |goto Searing Gorge/0 38.77,28.50
step
Jump down onto the metal walkway here |goto Searing Gorge 49.32,43.74 < 15 |only if walking
Enter the cave |goto Searing Gorge/0 49.58,45.49 < 15 |c
|only if not (subzone("The Slag Pit") and _G.IsIndoors()) and rep('Thorium Brotherhood') < Friendly
step
Jump down from the bridge inside the cave |goto Searing Gorge 47.73,41.92 < 15 |walk
kill Incendosaur##9318+
|tip Inside the cave.
repcollect Incendosaur Scale##18944,2,25,Thorium Brotherhood,Friendly |goto Searing Gorge 51.73,37.16
|tip Inside the cave.
You can find more around: |notinsticky
[Searing Gorge 50.37,24.75]
[Searing Gorge 45.03,21.73]
|only if rep('Thorium Brotherhood') < Friendly
step
_NOTE:_
Farm or Buy Items
|tip You will be completing a {o}repeatable quest{} to reach {o}Friendly{} reputation.
|tip You will need to either {o}farm items{}, or {o}buy them from the Auction House{} to {o}save a lot of time{}.
Choose Which Item to Collect
|tip There are {o}3 options of items{} to {o}farm or buy{}.
|tip You {o}only need one{} of the items, so {o}pick the one{} you can get {o}cheapest and fastest{}.
|tip The items to choose from are:
repcollect Heavy Leather##4234,10,25,Thorium Brotherhood,Friendly	|or
repcollect Iron Bar##3575,4,25,Thorium Brotherhood,Friendly		|or
repcollect Kingsblood##3356,4,25,Thorium Brotherhood,Friendly		|or
|only if rep('Thorium Brotherhood') < Friendly
step
talk Master Smith Burninate##14624
|tip Buy the amount of {o}Coal{} you need to reach {o}Friendly{} reputation.
buy Coal##3857+ |n
repcollect Coal##3857,1,25,Thorium Brotherhood,Friendly |goto Searing Gorge 38.80,28.51
|only if rep('Thorium Brotherhood') < Friendly
step
talk Master Smith Burninate##14624
|tip Complete the {o}repeatable quest{} he offers that you {o}have the items for{}.
Reach Friendly Reputation with the Thorium Brotherhood Faction |complete rep ('Thorium Brotherhood') >= Friendly |goto Searing Gorge 38.80,28.51
step
repcollect Dark Iron Residue##18945,4,25,Thorium Brotherhood,Honored
|tip You can {o}collect{} these from {o}killing enemies{} in the {o}Blackrock Depths{} dungeon.
|tip You can also {o}buy it from the Auction House{}, and it's usually cheap{}.
|only if rep('Thorium Brotherhood') < Honored
step
talk Master Smith Burninate##14624
|tip Complete the {o}Gaining Acceptance{} quest {o}repeatedly{}.
Reach Honored Reputation with the Thorium Brotherhood Faction |complete rep ('Thorium Brotherhood') >= Honored |goto Searing Gorge 38.80,28.51
step
_NOTE:_
Farm or Buy Items
|tip You will be completing a {o}repeatable quest{} to reach {o}Exalted{} reputation.
|tip You will need to either {o}farm items{}, or {o}buy them from the Auction House{} to {o}save a lot of time{}.
Choose Which Item to Collect
|tip There are {o}5 options of items{} to {o}farm or buy{}.
|tip You {o}only need one{} of the items, so {o}pick the one{} you can get {o}cheapest and fastest{}.
|tip The items to choose from are:
repcollect Dark Iron Ore##11370,10,50,Thorium Brotherhood,Exalted		|or
repcollect Fiery Core##17010,1,200,Thorium Brotherhood,Exalted			|or
repcollect Lava Core##17011,1,200,Thorium Brotherhood,Exalted			|or
repcollect Blood of the Mountain##11382,1,200,Thorium Brotherhood,Exalted	|or
repcollect Core Leather##17012,2,150,Thorium Brotherhood,Exalted		|or
|only if rep('Thorium Brotherhood') < Exalted
step
_Inside the Blackrock Depths Dungeon:_
talk Lokhtos Darkbargainer##12944
|tip In the Grim Guzzler (bar area) inside {o}Blackrock Depths{}.
|tip Complete the {o}repeatable quest{} he offers that you {o}have the items for{}.
Reach Exalted Reputation with the Thorium Brotherhood Faction |complete rep ('Thorium Brotherhood') >= Exalted
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Wintersaber Trainers",{
},[[
step
_NOTE:_
About Wintersaber Trainers Reputation
|tip This is one of the {o}longest reputation grinds in the game{}, be prepared to {o}kill a lot of enemies{}.
Click Here to Continue |confirm
step
label "Accept_Frostsaber_Provisions"
talk Rivern Frostwind##10618
|tip On top of the huge rock.
accept Frostsaber Provisions##4970 |goto Winterspring 49.94,9.84
|tip You will complete this {o}quest repeatedly{} until you reach {o}1500/300 Neutral{} reputation.
|only if repval('Wintersaber Trainers','Neutral') < 1500
stickystart "Collect_Chillwind_Meat"
step
Kill Shardtooth enemies around this area
|tip They look like {o}bears{}.
|tip You can find them {o}all around this area{}.
collect 5 Shardtooth Meat##12622 |q 4970/1 |goto Winterspring 58.00,19.00
|tip We recommend being {o}solo{}, since the {o}item isn't shared{} amongst party members.
|only if haveq(4970)
step
label "Collect_Chillwind_Meat"
Kill Chillwind enemies around this area
|tip They look like {o}chimeras{}.
|tip You can find them {o}all around this area{}. |notinsticky
collect 5 Chillwind Meat##12623 |q 4970/2 |goto Winterspring 58.00,19.00
|tip We recommend being {o}solo{}, since the {o}item isn't shared{} amongst party members. |notinsticky
|only if haveq(4970)
step
talk Rivern Frostwind##10618
|tip On top of the huge rock.
turnin Frostsaber Provisions##4970 |goto Winterspring 49.94,9.84
|only if haveq(4970) or completedq(4970)
step
Routing Guide	|complete repval('Wintersaber Trainers','Neutral') < 1500	|or	|next "Accept_Frostsaber_Provisions"
Routing Guide	|complete repval('Wintersaber Trainers','Neutral') >= 1500	|or
step
talk Salfa##11556
accept Winterfall Activity##8464 |goto Winterspring 27.74,34.50
|only if rep('Wintersaber Trainers') < Exalted
stickystart "Kill_Winterfall_Ursas"
stickystart "Kill_Winterfall_Den_Watchers"
step
kill 8 Winterfall Shaman##7441 |q 8464/1 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.
|only if haveq(8464)
step
label "Kill_Winterfall_Den_Watchers"
kill 8 Winterfall Den Watcher##7442 |q 8464/2 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.	|notinsticky
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.			|notinsticky
|only if haveq(8464)
step
label "Kill_Winterfall_Ursas"
kill 8 Winterfall Ursa##7440 |q 8464/3 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.	|notinsticky
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.			|notinsticky
You may find more on top of the mountain ridge around [Winterspring 65.53,37.66]
|only if haveq(8464)
step
talk Salfa##11556
turnin Winterfall Activity##8464 |goto Winterspring 27.74,34.50
|only if haveq(8464) or completedq(8464)
step
label "Accept_Winterfall_Intrusion_Or_Rampaging_Giants"
talk Rivern Frostwind##10618
|tip On top of the huge rock.
|tip {o}Choose the quest{} you want to complete.
accept Winterfall Intrusion##5201	|goto Winterspring 49.94,9.84		|or	|next "Winterfall_Intrusion"
|tip This is the {o}best repeatable quest{} to do until {o}Exalted{}.
|tip It's {o}fast{}, can be done in a {o}group{}, makes a {o}lot of gold{}, and gets {o}Timbermaw Hold reputation{} at the same time.
|tip Save any {o}Winterfall Prayer Beads{} you find, to turn in later for {o}Timbermaw Hold{} reputation. |only if rep("Timbermaw Hold") < Exalted
accept Rampaging Giants##5981		|goto Winterspring 49.94,9.84		|or	|next "Rampaging_Giants"
|tip If {o}Winterfell Village{} has {o}too many players{} trying to kill the same enemies, it {o}may be better{} to accept this quest.
|tip This quest is {o}slower and less efficient{}, and should {o}only{} be done as a {o}backup{}.
|tip The {o}giants are elite{} and you {o}may need a group{}.
|only if rep('Wintersaber Trainers') < Exalted
stickystart "Kill_Winterfall_Ursa_5201"
step
label "Winterfall_Intrusion"
kill 8 Winterfall Shaman##7441 |q 5201/1 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.
|only if haveq(5201)
step
label "Kill_Winterfall_Ursa_5201"
kill 8 Winterfall Ursa##7440 |q 5201/2 |goto Winterspring 67.03,35.57
|tip They {o}share spawn points{} with the {o}other Winterfall enemies{}.	|notinsticky
|tip {o}Kill the other types{} also, to {o}get more to spawn{}.			|notinsticky
You may find more on top of the mountain ridge around [Winterspring 65.53,37.66]
|only if haveq(5201)
stickystart "Kill_Frostmaul_Preservers"
step
label "Rampaging_Giants"
kill 4 Frostmaul Giant##7428 |q 5981/1 |goto Winterspring 62.19,68.75
|tip They look like {o}rock giants{}.
|tip They can spawn {o}above and inside the canyon{}.
The path down into the canyon starts at [Winterspring 58.88,63.65]
|only if haveq(5981)
step
label "Kill_Frostmaul_Preservers"
kill 4 Frostmaul Preserver##7429 |q 5981/2 |goto Winterspring 62.19,68.75
|tip They look like {o}rock giants{}. |notinsticky
|tip They can spawn {o}above and inside the canyon{}. |notinsticky
The path down into the canyon starts at [Winterspring 58.88,63.65]
|only if haveq(5981)
step
label "Turnin_Quests"
talk Rivern Frostwind##10618
|tip On top of the huge rock.
turnin Winterfall Intrusion##5201 |goto Winterspring 49.94,9.84 |only if haveq(5201) or completedq(5201)
turnin Rampaging Giants##5981 |goto Winterspring 49.94,9.84 |only if haveq(5981) or completedq(5981)
|only if rep('Wintersaber Trainers') < Exalted
step
Routing Guide	|complete rep('Wintersaber Trainers') < Exalted		|or	|next "Accept_Winterfall_Intrusion_Or_Rampaging_Giants"
Routing Guide	|complete rep('Wintersaber Trainers') == Exalted	|or	|next "Exalted"
step
label "Exalted"
talk Rivern Frostwind##10618
|tip On top of the huge rock.
buy Reins of the Winterspring Frostsaber##13086 |goto Winterspring 49.94,9.84
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Darkspear Trolls",{
},[[
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
|tip You need to complete the {o}initial cloth quests{} to unlock the {o}repeatable Runecloth quest{}.
collect 60 Wool Cloth##2592		|q 7833		|future		|only if not completedq(7833)
collect 60 Silk Cloth##4306		|q 7834		|future		|only if not completedq(7834)
collect 60 Mageweave Cloth##4338	|q 7835		|future		|only if not completedq(7835)
collect 60 Runecloth##14047		|q 7836		|future		|only if not completedq(7836)
|only if not completedq(7833) and not completedq(7834) and not completedq(7835) and not completedq(7836)
step
talk Vehena##14727
|tip Inside the building.
accept A Donation of Wool##7833 |goto Orgrimmar 37.70,87.90 |instant
|only if not completedq(7833)
step
talk Vehena##14727
|tip Inside the building.
accept A Donation of Silk##7834 |goto Orgrimmar 37.70,87.90 |instant
|only if not completedq(7834)
step
talk Vehena##14727
|tip Inside the building.
accept A Donation of Mageweave##7835 |goto Orgrimmar 37.70,87.90 |instant
|only if not completedq(7835)
step
talk Vehena##14727
|tip Inside the building.
accept A Donation of Runecloth##7836 |goto Orgrimmar 37.70,87.90 |instant
|only if not completedq(7836)
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
repcollect Runecloth##14047,20,50,Darkspear Trolls,Exalted
|only if rep("Darkspear Trolls") < Exalted
step
talk Vehena##14727
|tip Inside the building.
|tip {o}Repeatedly complete the {o}Additional Runecloth{} quest.
Reach Exalted Reputation with the Darkspear Trolls Faction |complete rep("Darkspear Trolls") == Exalted |goto Orgrimmar 37.70,87.90
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Orgrimmar",{
},[[
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
|tip You need to complete the {o}initial cloth quests{} to unlock the {o}repeatable Runecloth quest{}.
collect 60 Wool Cloth##2592		|q 7826		|future		|only if not completedq(7826)
collect 60 Silk Cloth##4306		|q 7827		|future		|only if not completedq(7827)
collect 60 Mageweave Cloth##4338	|q 7831		|future		|only if not completedq(7831)
collect 60 Runecloth##14047		|q 7824		|future		|only if not completedq(7824)
|only if not completedq(7826) and not completedq(7827) and not completedq(7831) and not completedq(7824)
step
talk Rashona Straglash##14726
|tip Inside the building.
accept A Donation of Wool##7826 |goto Orgrimmar 63.60,51.23 |instant
|only if not completedq(7826)
step
talk Rashona Straglash##14726
|tip Inside the building.
accept A Donation of Silk##7827 |goto Orgrimmar 63.60,51.23 |instant
|only if not completedq(7827)
step
talk Rashona Straglash##14726
|tip Inside the building.
accept A Donation of Mageweave##7831 |goto Orgrimmar 63.60,51.23 |instant
|only if not completedq(7831)
step
talk Rashona Straglash##14726
|tip Inside the building.
accept A Donation of Runecloth##7824 |goto Orgrimmar 63.60,51.23 |instant
|only if not completedq(7824)
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
repcollect Runecloth##14047,20,50,Orgrimmar,Exalted
|only if rep("Orgrimmar") < Exalted
step
talk Rashona Straglash##14726
|tip Inside the building.
|tip {o}Repeatedly complete the {o}Additional Runecloth{} quest.
Reach Exalted Reputation with the Orgrimmar Faction |complete rep("Orgrimmar") == Exalted |goto Orgrimmar 63.60,51.23
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Thunder Bluff",{
},[[
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
|tip You need to complete the {o}initial cloth quests{} to unlock the {o}repeatable Runecloth quest{}.
collect 60 Wool Cloth##2592		|q 7820		|future		|only if not completedq(7820)
collect 60 Silk Cloth##4306		|q 7821		|future		|only if not completedq(7821)
collect 60 Mageweave Cloth##4338	|q 7822		|future		|only if not completedq(7822)
collect 60 Runecloth##14047		|q 7823		|future		|only if not completedq(7823)
|only if not completedq(7820) and not completedq(7821) and not completedq(7822) and not completedq(7823)
step
talk Rumstag Proudstrider##14728
|tip Inside the building.
accept A Donation of Wool##7820 |goto Thunder Bluff 43.05,42.72 |instant
|only if not completedq(7820)
step
talk Rumstag Proudstrider##14728
|tip Inside the building.
accept A Donation of Silk##7821 |goto Thunder Bluff 43.05,42.72 |instant
|only if not completedq(7821)
step
talk Rumstag Proudstrider##14728
|tip Inside the building.
accept A Donation of Mageweave##7822 |goto Thunder Bluff 43.05,42.72 |instant
|only if not completedq(7822)
step
talk Rumstag Proudstrider##14728
|tip Inside the building.
accept A Donation of Runecloth##7823 |goto Thunder Bluff 43.05,42.72 |instant
|only if not completedq(7823)
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
repcollect Runecloth##14047,20,50,Thunder Bluff,Exalted
|only if rep("Thunder Bluff") < Exalted
step
talk Rumstag Proudstrider##14728
|tip Inside the building.
|tip {o}Repeatedly complete the {o}Additional Runecloth{} quest.
Reach Exalted Reputation with the Thunder Bluff Faction |complete rep("Thunder Bluff") == Exalted |goto Thunder Bluff 43.05,42.72
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Undercity",{
},[[
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
|tip You need to complete the {o}initial cloth quests{} to unlock the {o}repeatable Runecloth quest{}.
collect 60 Wool Cloth##2592		|q 7813		|future		|only if not completedq(7813)
collect 60 Silk Cloth##4306		|q 7814		|future		|only if not completedq(7814)
collect 60 Mageweave Cloth##4338	|q 7817		|future		|only if not completedq(7817)
collect 60 Runecloth##14047		|q 7818		|future		|only if not completedq(7818)
|only if not completedq(7813) and not completedq(7814) and not completedq(7822) and not completedq(7818)
step
talk Ralston Farnsley##14729
accept A Donation of Wool##7813 |goto Undercity 71.66,29.23 |instant
|only if not completedq(7813)
step
talk Ralston Farnsley##14729
accept A Donation of Silk##7814 |goto Undercity 71.66,29.23 |instant
|only if not completedq(7814)
step
talk Ralston Farnsley##14729
accept A Donation of Mageweave##7817 |goto Undercity 71.66,29.23 |instant
|only if not completedq(7817)
step
talk Ralston Farnsley##14729
accept A Donation of Runecloth##7818 |goto Undercity 71.66,29.23 |instant
|only if not completedq(7818)
step
_NOTE:_
Farm or Buy Cloth
|tip {o}Farm{} the following {o}cloth{}, or purchase them from the {o}Auction House{}.
repcollect Runecloth##14047,20,50,Undercity,Exalted
|only if rep("Undercity") < Exalted
step
talk Ralston Farnsley##14729
|tip {o}Repeatedly complete the {o}Additional Runecloth{} quest.
Reach Exalted Reputation with the Undercity Faction |complete rep("Undercity") == Exalted |goto Undercity 71.66,29.23
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\Classic\\Argent Dawn",{
description="Temp",
},[[
step
It Is Advised to Have a Dedicated Group For This
|tip The best rep farm by far is doing Stratholme and Scholomance.
|tip If you don't, the reputation grind is basically just killing mobs for Scourgestones.
|tip 800 Minion's Scourgestones is by default 1,000 reputation.
|tip 400 Invader's Scorgestones is by default 1,000 reputation.
|tip 40 Corrupted Scourgestones is by default 1,000 reputation.
|tip Without a group, you will be grinding enemies in the Plaguelands zones for Minion and Invader stones.
|tip Corrupted stones only come from bosses in dungeons.
|tip It is also advised to save any quests from the Argent Dawn that you haven't completed until Revered.
|tip You gain reputation from killing enemies in Stratholme and Scholomance until Honored, so it is recommended to save your Scourgestones until Honored.
Click Here to Continue |confirm |or
'|complete rep("Argent Dawn") == Exalted |next "Finish" |or
step
talk Argent Officer Garush##10839
accept Argent Dawn Commission##5503 |goto Tirisfal Glades 83.19,68.45 |instant |or
'|complete rep("Argent Dawn") >= Friendly |or
step
Equip the Argent Dawn Commission
|tip Wearing it will allow Scourgestones to drop from undead enemies in Eastern/Westernplaguelands, Scholomance and Stratholme.
Trade Rates for Argent Valor Token:
|tip You need 20 Minion's Scourgestones for 1.
|tip Minion's Scourgestones drop from undead enemies level 50 and up.
|tip You need 10 Invader's Scourgestones for 1.
|tip Invader's Scourgestones drop from undead enemies level 53 and up.
|tip You need 1 Corruptor's Scourgestone for 1.
|tip Corruptor's Scourgestone drops from undead bosses, typically found in Scholomance and Stratholme.
Gain the Argent Dawn Commission Buff |havebuff Argent Dawn Commission##17670 |or
'|complete rep("Argent Dawn") >= Friendly |or
stickystart "Equip_The_Argent_Dawn_Commission"
step
Kill Undead enemies around this area
collect Minion's Scourgestones##12840 |n
|tip You need 20 Minion's Scourgestones per turn in.
collect Invader's Scourgestones##12841 |n
|tip You need 10 Invader's Scourgestones per turn in.
|tip Save any Scourgestones you collect for later.
Reach Friendly Reputation with the Argent Dawn |complete rep("Argent Dawn") == Friendly |goto Western Plaguelands/0 36.97,57.26
You Can Find More Around:
[Western Plaguelands/0 46.55,53.24]
|tip Enemies at the above coordinates tend to be around level 52-54.
[Western Plaguelands/0 52.84,66.29]
|tip Enemies at the above coordinates tend to be around level 54-56.
[Western Plaguelands/0 62.78,58.75]
|tip Enemies at the above coordinates tend to be around level 56-58.
step
Kill Undead enemies around this area
collect Minion's Scourgestones##12840 |n
|tip You need 20 Minion's Scourgestones per turn in.
collect Invader's Scourgestones##12841 |n
|tip You need 10 Invader's Scourgestones per turn in.
|tip Save any Scourgestones you collect for later.
Reach 3,000 Reputation into Friendly with the Argent Dawn |complete rep("Argent Dawn","Friendly") >= 3000 |goto Western Plaguelands/0 36.97,57.26
|tip Normal enemies stop giving reputation at this point.
You Can Find More Around:
[Western Plaguelands/0 46.55,53.24]
|tip Enemies at the above coordinates tend to be around level 52-54.
[Western Plaguelands/0 52.84,66.29]
|tip Enemies at the above coordinates tend to be around level 54-56.
[Western Plaguelands/0 62.78,58.75]
|tip Enemies at the above coordinates tend to be around level 56-58.
step
label "Honor_Loop_Pre_11999"
Kill Undead enemies around this area
collect Minion's Scourgestones##12840 |n
|tip You need 20 Minion's Scourgestones per turn in.
collect Invader's Scourgestones##12841 |n
|tip You need 10 Invader's Scourgestones per turn in.
Reach Honored Reputation with the Argent Dawn |complete rep("Argent Dawn") == Honored |goto Western Plaguelands/0 36.97,57.26 |or
You Can Find More Around:
[Western Plaguelands/0 46.55,53.24]
|tip Enemies at the above coordinates tend to be around level 52-54.
[Western Plaguelands/0 52.84,66.29]
|tip Enemies at the above coordinates tend to be around level 54-56.
[Western Plaguelands/0 62.78,58.75]
|tip Enemies at the above coordinates tend to be around level 56-58.
|tip If you have a group ready, you can also kill Elite Undead Enemies in the dungeons Scholomance and Stratholme for reputation.
Click Here When You're Ready to Turn-in |confirm |or
stickystop "Equip_The_Argent_Dawn_Commission"
step
talk Argent Officer Garush##10839
|tip Turn in all Scourgestone quests you can.
collect Argent Dawn Valor Token##12844 |n
use the Argent Dawn Valor Token##12844
|tip You'll get 25 rep per token.
Reach Honored Reputation with the Argent Dawn |complete rep("Argent Dawn") == Honored |goto Tirisfal Glades 83.19,68.45 |or
Click Here to Return to Farming |confirm |next "Honor_Loop_Pre_11999" |or
stickystart "Equip_The_Argent_Dawn_Commission"
step
label "Revered_Loop"
Kill Undead enemies around this area
collect Minion's Scourgestones##12840 |n
|tip You need 20 Minion's Scourgestones per turn in.
collect Invader's Scourgestones##12841 |n
|tip You need 10 Invader's Scourgestones per turn in.
Reach 11,999 Reputation into Honored with the Argent Dawn |complete rep("Argent Dawn","Honored") >= 11999 |goto Western Plaguelands/0 36.97,57.26 |or
|tip Elite enemies stop giving reputation at this point.
'|complete rep("Argent Dawn") == Revered |or
You Can Find More Around:
[Western Plaguelands/0 46.55,53.24]
|tip Enemies at the above coordinates tend to be around level 52-54.
[Western Plaguelands/0 52.84,66.29]
|tip Enemies at the above coordinates tend to be around level 54-56.
[Western Plaguelands/0 62.78,58.75]
|tip Enemies at the above coordinates tend to be around level 56-58.
|tip If you have a group ready, you can also kill Elite Undead Enemies in the dungeons Scholomance and Stratholme for reputation.
Click Here When You're Ready to Turn-in |confirm |or
stickystop "Equip_The_Argent_Dawn_Commission"
step
talk Argent Officer Garush##10839
|tip Turn in all Scourgestone quests you can.
collect Argent Dawn Valor Token##12844 |n
use the Argent Dawn Valor Token##12844
|tip You'll get 25 rep per token.
Reach Revered Reputation with the Argent Dawn |complete rep("Argent Dawn") == Revered |goto Tirisfal Glades 83.19,68.45 |or
Click Here to Return to Farming |confirm |next "Revered_Loop" |or
step
At This Point, Only Scourgestones and Bosses From Dungeons Award Reputation
|tip Without a group, you will be grinding Scourgestones.
Click Here To Continue |confirm |or
'|complete rep("Argent Dawn") == Exalted |next "Finish" |or
stickystart "Equip_The_Argent_Dawn_Commission"
step
label "Exalted_Loop"
Kill Undead enemies around this area
collect Minion's Scourgestones##12840 |n
|tip You need 20 Minion's Scourgestones per turn in.
collect Invader's Scourgestones##12841 |n
|tip You need 10 Invader's Scourgestones per turn in.
Reach 11,999 Reputation into Honored with the Argent Dawn |complete rep("Argent Dawn","Honored") >= 11999 |goto Western Plaguelands/0 36.97,57.26 |or
|tip Elite enemies stop giving reputation at this point.
'|complete rep("Argent Dawn") == Revered |or
You Can Find More Around:
[Western Plaguelands/0 46.55,53.24]
|tip Enemies at the above coordinates tend to be around level 52-54.
[Western Plaguelands/0 52.84,66.29]
|tip Enemies at the above coordinates tend to be around level 54-56.
[Western Plaguelands/0 62.78,58.75]
|tip Enemies at the above coordinates tend to be around level 56-58.
|tip If you have a group ready, enter Scholomance and Stratholme for Corrupted Scourgestones.
Reach Exalted Reputation with the Argent Dawn |complete rep("Argent Dawn") == Exalted |or
Click Here When You're Ready to Turn-in |confirm |or
stickystop "Equip_The_Argent_Dawn_Commission"
step
talk Argent Officer Garush##10839
|tip Turn in all Scourgestone quests you can.
collect Argent Dawn Valor Token##12844 |n
use the Argent Dawn Valor Token##12844
|tip You'll get 25 rep per token.
Reach Exalted Reputation with the Argent Dawn |complete rep("Argent Dawn") == Exalted |goto Tirisfal Glades 83.19,68.45 |or
Click Here to Return to Farming |confirm |next "Exalted_Loop" |or
step
label "Finish"
Congratulations!
You've Earned Exalted with the Argent Dawn Reputation
step
label "Equip_The_Argent_Dawn_Commission"
Equip the Argent Dawn Commission
|tip Wearing it will allow Scourgestones to drop from undead enemies in Eastern/Westernplaguelands, Scholomance and Stratholme.
Gain the Argent Dawn Commission Buff |havebuff Argent Dawn Commission##17670
]])
ZGV.BETASTART()
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Thrallmar",{
author="support@zygorguides.com",
startlevel=58,
endlevel=70,
},[[
step
"Hellfire Ramparts" and "The Blood Furnace" give rep up to 5999/6000 Friendly rep.
|tip For a full clear, Hellfire Ramparts will provide 633 reputation.
|tip For a full clear, the Blood Furnace will net 750 reputation.
|tip For optimal rep gains, it may be best to grind to 5999 Friendly before starting the Hellfire Peninsula leveling guide.
Reach 5,999 Into Honored Reputation with Thrallmar
|tip If you prefer to skip this, click the line below.
Click here to continue |confirm
step
Complete the "Hellfire Ramparts Quests" guide |complete countcompletedq(9588,9572) == 2 |future
step
Complete "The Blood Furnace Quests" guide |complete countcompletedq(9590,9608) == 2 |future
step
Complete the "Hellfire Peninsula" leveling guide
|tip Refer to the guide to accomplish this.
Click here to continue |confirm
step
ding 68
step
Complete the "Shattered Halls Quests" guide |q 9495 |future
step
Clear enemies within the Shattered Halls
|tip Full clears net around 1,600 reputation.
Reach Revered Reputation with Thrallmar |condition rep("Thrallmar")>=Revered
step
Run Heroic Hellfire Citadel Dungeons for reputation.
|tip A full clear of Heroic Hellfire Rampart nets roughly 2,500 reputation.
|tip A full clear of Heroic Blood Furnace nets roughly 2,700 reputation.
|tip A full clear of Heroic Shattered Halls nets roughly 2,900 reputation.
|tip A full clear of Normal Shattered Halls nets roughly 1,600 reputation.
Reach Exalted Reputation with Thrallmar |condition rep("Thrallmar")==Exalted
step
_Congratulations!_
You Earned Exalted Reputation with Thrallmar
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Cenarion Expedition",{
author="support@zygorguides.com",
startlevel=58,
endlevel=70,
},[[
step
ding 62
step
Kill enemies around this area
collect 240 Unidentified Plant Parts##24401 |goto Zangarmarsh/0 71.65,76.32
|tip You can also buy them from the Auction House.
|only if rep("Cenarion Expedition") <= Honored
step
talk Lauranna Thar'well##17909
accept Plants of Zangarmarsh##9802 |goto Zangarmarsh/0 80.32,64.17
step
Kill enemies around this area
collect 10 Unidentified Plant Parts##24401 |q 9802/1 |goto Zangarmarsh/0 71.65,76.32
step
talk Lauranna Thar'well##17909
turnin Plants of Zangarmarsh##9802 |goto Zangarmarsh/0 80.32,64.17
step
talk Lauranna Thar'well##17909
accept Identify Plant Parts##9784 |goto Zangarmarsh/0 80.32,64.17 |future
|tip This quest is repeatable until Honored.
|tip You can also run the Slave Pens and Underbog for reputation up until Honored.
Reach Honored with the Cenarion Expedition |condition rep("Cenarion Expedition")>=Honored
step
use the Package of Identified Plants##24402
use the Uncatalogued Species##24407
|tip This is contained in the Package of Identified Plants.
|tip There is a low chance of obtaining this item.
accept Uncatalogued Species##9875
step
talk Lauranna Thar'well##17909
turnin Uncatalogued Species##9875 |goto Zangarmarsh/0 80.32,64.17
step
Complete the "Slave Pens Quests" guide |q 9738 |future
step
Complete "The Underbog Quests" guide |complete countcompletedq(9738,9717,9719,9715) == 4 |future
step
ding 70
step
Complete the "Steamvaults Quests" guide |complete countcompletedq(9763,9764,10885) == 3 |future
step
Clear enemies within the Steamvaults
|tip Full clears net around 1,600 reputation.
Reach Revered Reputation with the Cenarion Expedition |condition rep("Cenarion Expedition")>=Revered
step
Run Heroic Coilfang Resevoir Dungeons for reputation.
|tip A full clear of Heroic Slave Pens nets roughly 2,750 reputation.
|tip A full clear of Underbog nets roughly 2,600 reputation.
|tip A full clear of Heroic Steamvaults nets roughly 2,600 reputation.
|tip A full clear of Normal Steamvaults nets roughly 1,600 reputation.
Reach Exalted Reputation with the Cenarion Expedition |condition rep("Cenarion Expedition")==Exalted
step
_Congratulations!_
You Earned Exalted Reputation with the Cenarion Expedition
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Lower City",{
author="support@zygorguides.com",
startlevel=58,
endlevel=70,
},[[
step
ding 64
step
Kill enemies around this area
collect 1080 Arakkoa Feather##25719 |goto Terokkar Forest/0 31.08,42.28
|tip You can also buy them from the Auction House.
|tip You will only need this many if you plan to run no instances.
|tip A full clear of Auchenai Crypts nets roughly 700 reputation.
|tip A full clear of Sethekk Halls nets roughly 1000 reputation.
|tip A full clear of Shadow Labyrinth nets roughly 1750 reputation.
|only if rep("Lower City") <= Honored
step
Run up the ramp |goto Shattrath City/0 56.45,16.27 < 7 |only if walking
talk Vekax##22429
|tip He walks around this area.
|tip Up on this wooden platform.
accept The Outcast's Plight##10917 |goto Shattrath City/0 52.01,18.10
step
Kill enemies around this area
collect 30 Arakkoa Feather##25719 |goto Terokkar Forest/0 31.08,42.28
step
Run up the ramp |goto Shattrath City/0 56.45,16.27 < 7 |only if walking
talk Vekax##22429
|tip He walks around this area.
|tip Up on this wooden platform.
turnin The Outcast's Plight##10917 |goto Shattrath City/0 52.01,18.10
step
Run up the ramp |goto Shattrath City/0 56.45,16.27 < 7 |only if walking
talk Vekax##22429
|tip He walks around this area.
|tip Up on this wooden platform.
accept More Feathers##10918 |goto Shattrath City/0 52.01,18.10
|tip This quest is repeatable until Honored.
|tip You can also run Auchenai Crypts, Sethekk Halls or Shadow Labyrunth for reputation up until Honored.
Reach Honored with the Lower City |condition rep("Lower City")>=Honored
step
Complete the "Auchenai Crypts Quests" guide |complete countcompletedq(10168,10164) == 2 |future
step
Complete the "Sethekk Halls Quests" guide |complete countcompletedq(10097,10098,10180) == 3 |future
step
Complete the "Shadow Labyrinth Quests" guide |complete countcompletedq(10666,10091,10095,9831,10649) == 5 |future
step
Clear enemies within the Shadow Labyrinth
|tip Full clears net around 2,000 reputation.
Reach Revered Reputation with the Lower City |condition rep("Lower City")>=Revered
step
Run Heroic Coilfang Resevoir Dungeons for reputation.
|tip A full clear of Heroic Auchenai Crpts nets roughly 2,000 reputation.
|tip A full clear of Heroic Sethekk Halls nets roughly 2,000 reputation.
|tip A full clear of Heroic Shadow Labyrinth nets roughly 2,700 reputation.
|tip A full clear of Normal Sethekk Halls nets roughly 1,000 reputation.
|tip A full clear of Normal Shadow Labyrinth nets roughly 1,700 reputation.
Reach Exalted Reputation with the Lower City |condition rep("Lower City")==Exalted
step
_Congratulations!_
You Earned Exalted Reputation with Lower City
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\The Sha'tar",{
author="support@zygorguides.com",
description="This guide will walk you through the quests granting reputation with The Sha'tar.",
startlevel=70,
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
talk Matron Celestine##18301
accept He Called Himself Altruis...##9983 |goto Nagrand/0 55.20,36.10
step
talk Jorin Deadeye##18106
accept The Impotent Leader##9888 |goto Nagrand/0 55.56,37.62
step
talk Kilrath##18273
turnin The Impotent Leader##9888 |goto Terokkar Forest/0 19.77,60.85
accept Don't Kill the Fat One##9889 |goto Terokkar Forest/0 19.77,60.85
stickystart "Slay_Boulderfist_Invaders"
step
kill Unkor the Ruthless##18262 |q 9889/2 |goto Terokkar Forest/0 20.06,63.23
|tip He will eventually submit.
step
label "Slay_Boulderfist_Invaders"
kill 10 Boulderfist Invader##18260 |q 9889/1 |goto Terokkar Forest/0 19.99,63.72
step
talk Unkor the Ruthless##18262
turnin Don't Kill the Fat One##9889 |goto Terokkar Forest/0 20.06,63.23
accept Success!##9890 |goto Terokkar Forest/0 20.06,63.23
step
talk Kilrath##18273
turnin Success!##9890 |goto Terokkar Forest/0 19.77,60.85
accept Because Kilrath is a Coward##9891 |goto Terokkar Forest/0 19.77,60.85
step
talk Jorin Deadeye##18106
turnin Because Kilrath is a Coward##9891 |goto Nagrand/0 55.56,37.62
accept Message in a Battle##9906 |goto Nagrand/0 55.56,37.62
stickystart "Slay_Boulder_Crushers"
step
kill 15 Boulderfist Mystic##17135 |q 9906/1 |goto Nagrand/0 73.41,70.20
step
label "Slay_Boulder_Crushers"
kill 15 Boulderfist Crusher##17134 |q 9906/2 |goto Nagrand/0 73.41,70.20
step
talk Jorin Deadeye##18106
turnin Message in a Battle##9906 |goto Nagrand/0 55.56,37.62
accept An Audacious Advance##9907 |goto Nagrand/0 55.56,37.62
stickystart "Slay_Boulderfist_Mages"
step
Follow the path down |goto Nagrand/0 40.18,27.78 < 15 |only if walking
kill 25 Boulderfist Warrior##17136 |q 9907/1 |goto Nagrand/0 40.76,31.58
|tip You can find more inside the nearby cave.
step
label "Slay_Boulderfist_Mages"
kill 25 Boulderfist Mage##17137 |q 9907/2 |goto Nagrand/0 40.76,31.58
|tip You can find more inside the nearby cave.
step
Kill enemies around this area
|tip The quest will show up once they are dead.
talk Mag'har Captive##18210 |goto Nagrand/0 31.33,44.12
accept The Totem of Kar'dash##9868 |goto Nagrand/0 31.32,44.13
step
Free the Mag'har Captive |q 9868/1 |goto Nagrand/0 31.73,38.74
step
talk Altruis the Sufferer##18417
turnin He Called Himself Altruis...##9983 |goto Nagrand/0 27.34,43.08 |only if haveq(9983) or completedq(9983)
accept Survey the Land##9991 |goto Nagrand/0 27.34,43.08
|tip Make sure you dismount before accepting this quest, or you will have to abandon it, and pick it back up.
step
Watch the dialogue as you fly
Survey the Forge Camps |q 9991/1
step
talk Altruis the Sufferer##18417
turnin Survey the Land##9991 |goto Nagrand/0 27.34,43.08
accept Buying Time##9999 |goto Nagrand/0 27.34,43.08
stickystart "Slay_Moarg_Engineers"
stickystart "Slay_Ganarg_Tinkerers"
step
kill 2 Felguard Legionnaire##17152+ |q 9999/1 |goto Nagrand/0 25.13,38.25
step
label "Slay_Moarg_Engineers"
kill 3 Mo'arg Engineer##16945+ |q 9999/2 |goto Nagrand/0 24.36,37.44
step
label "Slay_Ganarg_Tinkerers"
kill 8 Gan'arg Tinkerer##17151+ |q 9999/3 |goto Nagrand/0 25.07,37.72
step
talk Altruis the Sufferer##18417
turnin Buying Time##9999 |goto Nagrand/0 27.34,43.08
accept The Master Planner##10001 |goto Nagrand/0 27.34,43.08
step
kill Mo'arg Master Planner##18567
collect The Master Planner's Blueprints##25751 |q 10001/1 |goto Nagrand/0 23.60,34.66
step
talk Altruis the Sufferer##18417
turnin The Master Planner##10001 |goto Nagrand/0 27.34,43.08
accept Patience and Understanding##10004 |goto Nagrand/0 27.34,43.08
step
Enter the building |goto Shattrath City/0 74.05,32.84 < 7 |walk
talk Sal'salabim##18584
|tip Inside the building.
Select _"Altruis sent me. He said that you could help me."_
kill Sal'salabim##18584
Persuade Sal'salabim |q 10004/1 |goto Shattrath City/0 77.30,34.87
step
talk Sal'salabim##18584
|tip Inside the building.
turnin Patience and Understanding##10004 |goto Shattrath City/0 77.30,34.87
accept Crackin' Some Skulls##10009 |goto Shattrath City/0 77.30,34.87
step
talk Raliq the Drunk##18585
|tip Inside the building.
Select _"I have been sent by Sal'salabim to collect a debt that you owe. Pay up or I'm going to have to hurt you."_
kill Raliq the Drunk##18585
collect Raliq's Debt##25767 |q 10009/1 |goto Shattrath City/0 75.01,31.41
step
talk Coosh'coosh##18586
|tip He walks around this area.
Select _"I have been sent by Sal'salabim to collect a debt that you owe. Pay up or I'm going to have to hurt you."_
kill Coosh'coosh##18586
collect Coosh'coosh's Debt##25768 |q 10009/2 |goto Zangarmarsh/0 80.88,91.20
step
talk Floon##18588
|tip He walks around this area.
Select _"I have been sent by Sal'salabim to collect a debt that you owe. Pay up or I'm going to have to hurt you."_
kill Floon##18588
collect Floon's Debt##25769 |q 10009/3 |goto Terokkar Forest/0 27.43,58.18
step
Enter the building |goto Shattrath City/0 74.05,32.84 < 7 |walk
talk Sal'salabim##18584
|tip Inside the building.
turnin Crackin' Some Skulls##10009 |goto Shattrath City/0 77.30,34.87
accept It's Just That Easy?##10010 |goto Shattrath City/0 77.30,34.87
step
talk Altruis the Sufferer##18417
turnin It's Just That Easy?##10010 |goto Nagrand/0 27.34,43.08
accept Forge Camp: Annihilated##10011 |goto Nagrand/0 27.34,43.08
step
kill Demos Overseer of Hate##18535
collect Fel Cannon Activator##25770 |q 10011 |goto Nagrand/0 24.98,36.09
step
use Fel Cannon Activator##25770
Destroy Forge Camp: Hate |q 10011/1 |goto Nagrand/0 25.04,35.89
step
kill Xirkos, Overseer of Fear##18536
collect Fel Cannon Activator##25771 |q 10011 |goto Nagrand/0 19.60,51.12
step
use Fel Cannon Activator##25771
Destroy Forge Camp: Fear |q 10011/2 |goto Nagrand/0 19.34,50.86
step
talk Altruis the Sufferer##18417
turnin Forge Camp: Annihilated##10011 |goto Nagrand/0 27.34,43.08
step
talk Jorin Deadeye##18106
turnin An Audacious Advance##9907 |goto Nagrand/0 55.56,37.62
accept Diplomatic Measures##10107 |goto Nagrand/0 55.56,37.62
step
talk Garrosh##18063
turnin The Totem of Kar'dash##9868 |goto Nagrand/0 55.44,37.64
step
Follow the path up |goto Nagrand/0 73.84,68.07 < 10 |only if walking
talk Lantresor of the Blade##18261
Select _"I have killed many of your ogres, Lantresor. I have no fear."_
Hear the Story of the Blademaster |q 10107/1 |goto Nagrand/0 73.81,62.61
step
talk Lantresor of the Blade##18261
turnin Diplomatic Measures##10107 |goto Nagrand/0 73.81,62.61
accept Armaments for Deception##9928 |goto Nagrand/0 73.81,62.61
accept Ruthless Cunning##9927 |goto Nagrand/0 73.81,62.61
stickystart "Collect_Kilsorrow_Armaments"
step
Kill Kil'sorrow enemies around this area
use Warmaul Ogre Banner##25552
|tip Use it on their corpses.
Plant #20# Warmaul Ogre Banners |q 9927/1 |goto Nagrand/0 70.09,79.41
step
label "Collect_Kilsorrow_Armaments"
click Kil'sorrow Armaments##182355+
|tip They look like flat brown boxes with a red axe logo on them on the ground around this area.
collect 20 Kil'sorrow Armaments##25554 |q 9928/1 |goto Nagrand/0 70.26,80.00
step
Follow the path up |goto Nagrand/0 73.84,68.07 < 10 |only if walking
talk Lantresor of the Blade##18261
turnin Armaments for Deception##9928 |goto Nagrand/0 73.81,62.61
turnin Ruthless Cunning##9927 |goto Nagrand/0 73.81,62.61
accept Returning the Favor##9931 |goto Nagrand/0 73.81,62.61
accept Body of Evidence##9932 |goto Nagrand/0 73.81,62.61
step
Kill Warmaul enemies around this area
use Kil'sorrow Banner##25555
|tip Use it on their copses.
Plant #10# Kil'sorrow Banners |q 9931/1 |goto Nagrand/0 46.84,23.00
step
use Damp Woolen Blanket##25658
Defend the two Boulderfist Saboteurs that spawn
|tip They will walk around and plant bodies around this area.
Plant the Kil'sorrow Bodies |q 9932/1 |goto Nagrand/0 46.59,24.25
step
Follow the path up |goto Nagrand/0 73.84,68.07 < 10 |only if walking
talk Lantresor of the Blade##18261
turnin Returning the Favor##9931 |goto Nagrand/0 73.81,62.61
turnin Body of Evidence##9932 |goto Nagrand/0 73.81,62.61
accept Message to Garadar##9934 |goto Nagrand/0 73.81,62.61
step
talk Garrosh##18063
turnin Message to Garadar##9934 |goto Nagrand/0 55.44,37.64
accept A Visit With the Greatmother##10044 |goto Nagrand/0 55.44,37.64
step
talk Greatmother Geyah##18141
|tip Inside the building.
turnin A Visit With the Greatmother##10044 |goto Nagrand/0 56.70,34.31
accept Material Components##10045 |goto Nagrand/0 56.70,34.31
step
click Telaari Frond##182599
|tip It looks like a green bush along the cliff wall around this area.
collect Telaari Frond##25864 |q 10045/3 |goto Nagrand/0 59.14,55.52
step
click Olemba Root##182601
|tip It looks like a viny green plant near the base of trees around this area.
collect Olemba Root##25863 |q 10045/1 |goto Terokkar Forest/0 32.74,38.52
step
click Dragonspine##182606
|tip It looks like a red leafy plant next to the big spiky rock formations around this area.
collect Dragonspine##25865 |q 10045/4 |goto Blade's Edge Mountains/0 39.64,72.38
step
click Marshberry##182600
|tip It looks like a big red ball on the ground around this area.
collect Marshberry##25862 |q 10045/2 |goto Zangarmarsh/0 20.07,8.52
step
talk Greatmother Geyah##18141
|tip Inside the building.
turnin Material Components##10045 |goto Nagrand/0 56.70,34.31
accept To Meet Mother Kashur##10081 |goto Nagrand/0 56.70,34.31
|tip Walks all around Oshu'Gun, you'll probably have to look around.
step
talk Mother Kashur##18687
turnin To Meet Mother Kashur##10081 |goto Nagrand/0 26.07,60.60
accept The Agitated Ancestors##10082 |goto Nagrand/0 26.07,60.60
step
kill 8 Agitated Orc Spirit##18043 |q 10082/1 |goto Nagrand/0 26.51,60.10
step
talk Mother Kashur##18687
turnin The Agitated Ancestors##10082 |goto Nagrand/0 26.07,60.60
accept A Visit With The Ancestors##10085 |goto Nagrand/0 26.07,60.60
step
Visit Sunspring Post |q 10085/1 |goto Nagrand/0 31.68,43.81
step
Visit the Laughing Skull Clan Ruins |q 10085/2 |goto Nagrand/0 46.31,23.86
step
Visit Garadar |q 10085/3 |goto Nagrand/0 54.75,36.38
step
Visit the Bleeding Hollow Clan Ruins |q 10085/4 |goto Terokkar Forest/0 19.77,61.86
step
talk Mother Kashur##18687
turnin A Visit With The Ancestors##10085 |goto Nagrand/0 26.07,60.60
accept When Spirits Speak##10101 |goto Nagrand/0 26.07,60.60
step
Enter the cave |goto Nagrand/0 35.83,67.76 < 10 |walk
talk K'ure##17545
|tip Inside the cave.
turnin When Spirits Speak##10101 |goto Nagrand/0 35.48,77.84
accept A Secret Revealed##10102 |goto Nagrand/0 35.48,77.84
step
talk A'dal##18481
turnin A Secret Revealed##10102 |goto Shattrath City/0 53.99,44.76
accept Auchindoun...##10167 |goto Shattrath City/0 53.99,44.76
step
Enter the Auchenai Crypts
Click here to continue |confirm |q 10167 |future
step
Inside the Auchenai Crypts Dungeon:
kill Exarch Maladaar##18373 |q 10167/1
step
Inside the Auchenai Crypts Dungeon:
talk D'ore##19412
|tip It looks like a big white floating NPC that appears after you kill Exarch Maladaar.
|tip Inside the Auchenai Crypts dungeon.
turnin Auchindoun...##10167
accept What the Soul Sees##10168
step
Inside the Auchenai Crypts Dungeon:
click Soul Mirror##183441
|tip It looks like a big pink floating crystal near the wall where you fight Exarch Maladaar.
|tip Inside the Auchenai Crypts dungeon.
collect Soul Mirror##28283 |q 10168/2
step
Leave the Auchenai Crypts dungeon
clicknpc Ancient Orc Ancestor##18688+
|tip They are non-aggressive ghosts that walk around this area.
|tip They can be hard to see, use the command "/tar Ancient" to help find them.
use Soul Mirror##28283
kill 15 Darkened Spirit##19480+ |q 10168/1 |goto Nagrand/0 37.07,63.11
step
talk Mother Kashur##18687
turnin What the Soul Sees##10168 |goto Nagrand/0 26.07,60.60
step
ding 66
step
talk Ha'lei##19697
|tip Inside the building.
accept I See Dead Draenei##10227 |goto Terokkar Forest/0 35.09,65.09
step
talk Ramdor the Mad##19417
|tip Walks around this area.
turnin I See Dead Draenei##10227 |goto Terokkar Forest/0 35.10,66.34
accept Ezekiel##10228 |goto Terokkar Forest/0 35.10,66.34
step
talk Ezekiel##19715
|tip He walks around Shattrath City in a circle.
turnin Ezekiel##10228 |goto Shattrath City/0 59.70,36.29
accept What Book? I Don't See Any Book.##10231 |goto Shattrath City/0 59.70,36.29
step
talk "Dirty" Larry##19720
Select _"Ezekiel said that you might have a certain book... "_
Beat Down "Dirty" Larry and Get Information |q 10231/1 |goto Shattrath City/0 43.67,29.77
step
talk "Dirty" Larry##19720
turnin What Book? I Don't See Any Book.##10231 |goto Shattrath City/0 43.67,29.77
accept The Master's Grand Design?##10251 |goto Shattrath City/0 43.63,29.78
step
Enter the building |goto Nagrand/0 51.39,57.18 < 7 |walk
talk Nitrin the Learned##19844
|tip Inside the building.
turnin The Master's Grand Design?##10251 |goto Nagrand/0 51.82,56.85
accept Vision of the Dead##10252 |goto Nagrand/0 51.82,56.85
step
kill Aged Clefthoof##17133+
|tip You can find them all around this area.
collect Aged Clefthoof Blubber##28668 |q 10252/3 |goto Nagrand/0 37.89,60.68
step
kill Mountain Gronn##19201+
collect Mountain Gronn Eyeball##28665 |q 10252/1 |goto Nagrand/0 25.84,50.85
step
kill Greater Windroc##17129+
collect Flawless Greater Windroc Beak##28667 |q 10252/2 |goto Nagrand/0 30.9,32.9
You can find more around:
[Nagrand/0 33.25,26.30]
[Nagrand/0 35.91,28.69]
step
Enter the building |goto Nagrand/0 51.39,57.18 < 7 |walk
talk Nitrin the Learned##19844
|tip Inside the building.
turnin Vision of the Dead##10252 |goto Nagrand/0 51.82,56.85
accept Levixus the Soul Caller##10253 |goto Nagrand/0 51.82,56.85
step
_Destroy This Item:_
|tip Not needed.
trash Nitrin's Instructions##28664
|only if itemcount(28664) > 0
step
kill Levixus##19847
collect The Book of the Dead##28677 |q 10253/1 |goto Terokkar Forest/0 39.62,71.23
step
talk Ramdor the Mad##19417
|tip Walks around this area.
turnin Levixus the Soul Caller##10253 |goto Terokkar Forest/0 35.10,66.34
step
talk Oakun##22456
accept The Dread Relic##10877 |goto Terokkar Forest/0 31.07,76.54
step
talk Scout Navrin##22364
accept Taken in the Night##10873 |goto Terokkar Forest/0 31.45,75.67
step
click Massive Treasure Chest
|tip After you loot it, there will be a bunch of undead that spawn around you in a circle.
collect Dread Relic##31697 |q 10877/1 |goto Terokkar Forest/0 43.91,76.40
step
talk Vindicator Haylen##22462
accept For the Fallen##10920 |goto Terokkar Forest/0 49.71,76.18
step
kill 20 Dreadfang Widow##18467+ |q 10920/1 |goto Terokkar Forest/0 51.03,80.46
You can find more around [Terokkar Forest/0 54.98,60.07]
step
talk Vindicator Haylen##22462
turnin For the Fallen##10920 |goto Terokkar Forest/0 49.71,76.18
accept Terokkarantula##10921 |goto Terokkar Forest/0 49.71,76.18
step
kill Terokkarantula##20682 |q 10921/1 |goto Terokkar Forest/0 54.23,81.80
|tip You may need help with this.
step
talk Vindicator Haylen##22462
turnin Terokkarantula##10921 |goto Terokkar Forest/0 49.71,76.18
accept Return to Sha'tari Base Camp##10926 |goto Terokkar Forest/0 49.71,76.18
step
talk Oakun##22456
turnin The Dread Relic##10877 |goto Terokkar Forest/0 31.07,76.54
accept Evil Draws Near##10923 |goto Terokkar Forest/0 31.07,76.54
step
Kill Auchenai enemies around this area
collect 20 Doom Skull##31812 |q 10923 |goto Terokkar Forest/0 48.94,67.02
step
use the Dread Relic##31811
|tip Clear enemies around the area before you do.
kill Teribus the Cursed##22441 |q 10923/1 |goto Terokkar Forest/0 48.70,67.17
|tip You may need help with this.
step
talk Oakun##22456
turnin Evil Draws Near##10923 |goto Terokkar Forest/0 31.07,76.54
step
Complete the "Cipher of Damnation" questline |q 10588 |future
|tip Refer to the Cipher of Damnation guide to accomplish this.
step
talk Khadgar##18166
|tip Inside the building.
accept The Tempest Key##10883 |goto Shattrath City/0 54.76,44.33
step
talk A'dal##18481
|tip Inside the building.
turnin The Tempest Key##10883 |goto Shattrath City/0 53.97,44.75
accept Trial of the Naaru: Mercy##10884 |goto Shattrath City/0 53.97,44.75
accept Trial of the Naaru: Strength##10885 |goto Shattrath City/0 53.97,44.75
accept Trial of the Naaru: Tenacity##10886 |goto Shattrath City/0 53.97,44.75
step
Reach Revered with Thrallmar |complete rep('Thrallmar') >= Revered
|tip Refer to the Thrallmar reputation guide to accomplish this.
step
talk Quartermaster Urgronn##17585
buy Flamewrought Key##30637 |goto Hellfire Peninsula/0 54.90,37.80
step
Reach Revered with the Lower City |complete rep('Lower City') >= Revered
|tip Refer to the Lower City reputation guide to accomplish this.
step
talk Nakodu##21655
buy Auchenai Key##30633 |goto Shattrath City/0 61.99,68.84
step
Reach Revered with the Cenarion Expedition |complete rep('Cenarion Expedition') >= Revered
|tip Refer to the Cenarion Expedition reputation guide to accomplish this.
step
talk Fedryen Swiftspear##17904
buy Reservoir Key##30623 |goto Zangarmarsh/0 79.26,63.67
step
Run Tempest Keep Dungeons for reputation
|tip A full clear of the Mechanar nets roughly 1,600 reputation.
|tip A full clear of the Botanica nets roughly 2,200 reputation.
|tip A full clear of the Arcatraz nets roughly 1,800 reputation.
Reach Revered with The Sha'tar Expedition |complete rep("The Sha'tar") >=Revered
step
talk Almaador##21432
|tip Inside the building.
buy Warpforged Key##30634 |goto Shattrath City/0 51.00,41.71
step
Enter the Heroic Shattered Halls Dungeon
Click here to continue |confirm |q 10884 |future
step
Inside the Shattered Halls (Heroic) Dungeon:
kill Grand Warlock Nethekurse##16807
|tip IMPORTANT: After defeating the boss, you will have 55 minute buff.
|tip Your goal is to kill the Shattered Hand Executioner found behind the last boss of the dungeon before the timer runs out.
Gain the "Korgath's Executioner" Buff |havebuff 132338 |q 10884 |future
step
Inside the Shattered Halls (Heroic) Dungeon:
|tip REMEMBER: Your goal is to kill the Shattered Hand Executioner before the prisoners are executed.
kill Shattered Hand Executioner##17301
|tip Behind Warchief Kargath Bladefist.
collect Unused Axe of the Executioner##31716 |q 10884/1
step
Enter the Heroic Steamvault Dungeon
Click here to continue |confirm |q 10885 |future
step
Inside the Steamvalt (Heroic) Dungeon:
kill Warlord Kalithresh##17798
collect Kalithresh's Trident##31721 |q 10885/1
step
Enter the Heroic Shadow Labyrinth Dungeon
Click here to continue |confirm |q 10885 |future
step
Inside the Shadow Labyrinth (Heroic) Dungeon:
kill Murmur##18708
collect Murmur's Essence##31722 |q 10885/2
step
Enter The Arcatraz (Heroic) Dungeon
Click here to continue |confirm |q 10886 |future
step
Inside The Arcatraz (Heroic) Dungeon:
kill Harbinger Skyriss##20912
|tip Defeat Harbinger Skyriss and make sure Millhouse lives.
talk Millhouse Manastorm##20977
Rescue Millhouse Manastorm |q 10886/1
step
talk A'dal##18481
|tip Inside the building.
turnin Trial of the Naaru: Mercy##10884 |goto Shattrath City/0 53.97,44.75
turnin Trial of the Naaru: Strength##10885 |goto Shattrath City/0 53.97,44.75
turnin Trial of the Naaru: Tenacity##10886 |goto Shattrath City/0 53.97,44.75
step
talk Nether-Stalker Khay'ji##19880
accept Consortium Crystal Collection##10265 |goto Netherstorm/0 32.44,64.20
step
kill Pentatharon##20215
collect Arklon Crystal Artifact##28829 |q 10265/1 |goto Netherstorm/0 42.45,72.76
step
talk Nether-Stalker Khay'ji##19880
turnin Consortium Crystal Collection##10265 |goto Netherstorm/0 32.44,64.20
accept A Heap of Ethereals##10262 |goto Netherstorm/0 32.44,64.20
step
Kill Zaxxis enemies around this area
collect 10 Zaxxis Insignia##29209 |q 10262/1 |goto Netherstorm/0 30.34,74.98
step
talk Nether-Stalker Khay'ji##19880
turnin A Heap of Ethereals##10262 |goto Netherstorm/0 32.44,64.20
|tip "A Heap of Ethereals" becomes a daily after you turn the quest in.
accept Warp-Raider Nesaad##10205 |goto Netherstorm/0 32.44,64.20
step
kill Warp-Raider Nesaad##19641 |q 10205/1 |goto Netherstorm/0 28.27,79.60
step
talk Nether-Stalker Khay'ji##19880
turnin Warp-Raider Nesaad##10205 |goto Netherstorm/0 32.44,64.20
accept Request for Assistance##10266 |goto Netherstorm/0 32.44,64.20
step
talk Gahruj##20066
turnin Request for Assistance##10266 |goto Netherstorm/0 46.66,56.94
accept Rightful Repossession##10267 |goto Netherstorm/0 46.66,56.94
step
click Box Surveying Equipment##6881
|tip They look like grey metal boxes on the ground around this area.
collect 10 Box of Surveying Equipment##28913 |q 10267/1 |goto Netherstorm/0 57.6,63.9
step
talk Gahruj##20066
turnin Rightful Repossession##10267 |goto Netherstorm/0 46.66,56.94
accept An Audience with the Prince##10268 |goto Netherstorm/0 46.66,56.94
step
talk Image of Nexus-Prince Haramad##20084
|tip Inside the building.
turnin An Audience with the Prince##10268 |goto Netherstorm/0 45.87,35.97
accept Triangulation Point One##10269 |goto Netherstorm/0 45.87,35.97
step
use the Triangulation Device##28962
|tip A red arrow will appear and point to where you should go.
Discover the first triangulation point |q 10269/1 |goto Netherstorm/0 66.80,34.79
step
talk Dealer Hazzin##20092
turnin Triangulation Point One##10269 |ggoto Netherstorm/0 58.35,31.26
accept Triangulation Point Two##10275 |goto Netherstorm/0 58.35,31.26
step
use the Triangulation Device##29018
|tip A red arrow will appear and point to where you should go.
Discover the second triangulation point |q 10275/1 |goto Netherstorm/0 29.11,40.48
step
talk Wind Trader Tuluman##20112
turnin Triangulation Point Two##10275 |goto Netherstorm/0 34.62,37.95
accept Full Triangle##10276 |goto Netherstorm/0 34.62,37.95
step
kill Culuthas##20138
|tip You may need help with this.
collect Ata'mal Crystal##29026 |q 10276/1 |goto Netherstorm/0 53.51,21.54
step
talk Image of Nexus-Prince Haramad##20084
|tip Inside the building.
turnin Full Triangle##10276 |goto Netherstorm/0 45.87,35.97
accept Special Delivery to Shattrath City##10280 |goto Netherstorm/0 45.87,35.97
step
talk A'dal##18481
|tip Inside the building.
turnin Special Delivery to Shattrath City##10280 |goto Shattrath City/0 53.99,44.75
accept How to Break Into the Arcatraz##10704 |goto Shattrath City/0 53.99,44.75
step
Enter The Botanica (Heroic) Dungeon
Click here to continue |confirm |q 10704 |future
step
Inside The Botanica (Heroic) Dungeon:
kill Pathaleon the Calculator##19220
collect Bottom Shard of the Arcatraz Key##31086 |q 10704/2
step
Inside The Botanica (Heroic) Dungeon:
kill Warpsplinter##17977
collect Top Shard of the Arcatraz Key##31085 |q 10704/1
step
talk A'dal##18481
|tip Inside the building.
turnin How to Break Into the Arcatraz##10704 |goto Shattrath City/0 53.99,44.75
step
talk Arcanist Thelis##21955
|tip Inside the building.
accept Tablets of Baa'ri##10683 |goto Shadowmoon Valley/0 56.25,59.60
only if rep ('The Scryers') >= Neutral
step
click Baar'ri Tablet Fragment##6420
|tip On the ground around this area.
kill Ashtongue Worker##21455+
collect 12 Baa'ri Tablet Fragment##30596 |q 10683/1 |goto Shadowmoon Valley/0 59.84,36.36
only if rep ('The Scryers') >= Neutral
step
talk Arcanist Thelis##21955
|tip Inside the building.
turnin Tablets of Baa'ri##10683 |goto Shadowmoon Valley/0 56.25,59.60
accept Oronu the Elder##10684 |goto Shadowmoon Valley/0 56.25,59.60
only if rep ('The Scryers') >= Neutral
step
kill Oronu the Elder##21663
|tip Standing on the balcony.
collect Orders From Akama##30649 |q 10684/1 |goto Shadowmoon Valley/0 57.16,32.82
only if rep ('The Scryers') >= Neutral
step
talk Arcanist Thelis##21955
|tip Inside the building.
turnin Oronu the Elder##10684 |goto Shadowmoon Valley/0 56.25,59.60
accept The Ashtongue Corruptors##10685 |goto Shadowmoon Valley/0 56.25,59.60
only if rep ('The Scryers') >= Neutral
step
kill Corrupt Air Totem##21705
|tip Destroy them all to make Haalum vulnerable.
kill Haalum##21711
collect Haalum's Medallion Fragment##30691 |q 10685/2 |goto Shadowmoon Valley/0 57.08,73.64
only if rep ('The Scryers') >= Neutral
step
kill Corrupt Earth Totem##21704
|tip Destroy them all to make Eykenen vulnerable.
kill Eykenen##21709
collect Eykenen's Medallion Fragment##30692 |q 10685/1 |goto Shadowmoon Valley/0 51.18,52.83
only if rep ('The Scryers') >= Neutral
step
kill Corrupt Fire Totem##21703
|tip Destroy them all to make Uylaru vulnerable.
kill Uylaru##21710
collect Uylaru's Medallion Fragment##30694 |q 10685/4 |goto Shadowmoon Valley/0 48.29,39.56
only if rep ('The Scryers') >= Neutral
step
kill Corrupt Water Totem##21420
|tip Destroy them all to make Lakaan vulnerable.
kill Lakaan##21416
collect Lakaan's Medallion Fragment##30693 |q 10685/3 |goto Shadowmoon Valley/0 49.89,23.01
only if rep ('The Scryers') >= Neutral
step
talk Arcanist Thelis##21955
|tip Inside the building.
turnin The Ashtongue Corruptors##10685 |goto Shadowmoon Valley/0 56.3,59.6
accept The Warden's Cage##10686 |goto Shadowmoon Valley/0 56.3,59.6
only if rep ('The Scryers') >= Neutral
step
Follow the path down |goto Shadowmoon Valley/0 57.35,49.67 < 5 |walk
talk Sanoru##21826
|tip Downstairs.
turnin The Warden's Cage##10686 |goto Shadowmoon Valley/0 57.33,49.58
accept Proof of Allegiance##10622 |goto Shadowmoon Valley/0 57.33,49.58
only if rep ('The Scryers') >= Neutral
step
talk Anchorite Ceyla##21402
|tip Inside the building.
accept Tablets of Baa'ri##10568 |goto Shadowmoon Valley/0 62.58,28.37
only if rep ('The Aldor') >= Friendly
step
click Baar'ri Tablet Fragment##6420
|tip On the ground around this area.
kill Ashtongue Worker##21455+
collect 12 Baa'ri Tablet Fragment##30596 |q 10568/1 |goto Shadowmoon Valley/0 59.84,36.36
only if rep ('The Aldor') >= Friendly
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin Tablets of Baa'ri##10568 |goto Shadowmoon Valley/0 62.58,28.37
accept Oronu the Elder##10571 |goto Shadowmoon Valley/0 62.58,28.37
only if rep ('The Aldor') >= Friendly
step
kill Oronu the Elder##21663
|tip Standing on the balcony.
collect Orders From Akama##30649 |q 10571/1 |goto Shadowmoon Valley/0 57.16,32.82
only if rep ('The Aldor') >= Friendly
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin Oronu the Elder##10571 |goto Shadowmoon Valley/0 62.58,28.37
accept The Ashtongue Corruptors##10574 |goto Shadowmoon Valley/0 62.58,28.37
only if rep ('The Aldor') >= Friendly
step
kill Corrupt Water Totem##21420
|tip Destroy them all to make Lakaan vulnerable.
kill Lakaan##21416
collect Lakaan's Medallion Fragment##30693 |q 10574/3 |goto Shadowmoon Valley/0 49.89,23.01
only if rep ('The Aldor') >= Friendly
step
kill Corrupt Fire Totem##21703
|tip Destroy them all to make Uylaru vulnerable.
kill Uylaru##21710
collect Uylaru's Medallion Fragment##30694 |q 10574/4 |goto Shadowmoon Valley/0 48.29,39.56
only if rep ('The Aldor') >= Friendly
step
kill Corrupt Earth Totem##21704
|tip Destroy them all to make Eykenen vulnerable.
kill Eykenen##21709
collect Eykenen's Medallion Fragment##30692 |q 10574/1 |goto Shadowmoon Valley/0 51.18,52.83
only if rep ('The Aldor') >= Friendly
step
kill Corrupt Air Totem##21705
|tip Destroy them all to make Haalum vulnerable.
kill Haalum##21711
collect Haalum's Medallion Fragment##30691 |q 10574/2 |goto Shadowmoon Valley/0 57.08,73.64
only if rep ('The Aldor') >= Friendly
step
talk Anchorite Ceyla##21402
|tip Inside the building.
turnin The Ashtongue Corruptors##10574 |goto Shadowmoon Valley/0 62.58,28.37
accept The Warden's Cage##10575 |goto Shadowmoon Valley/0 62.58,28.37
only if rep ('The Aldor') >= Friendly
step
Follow the path down |goto Shadowmoon Valley/0 57.35,49.67 < 5 |walk
talk Sanoru##21826
|tip Downstairs.
turnin The Warden's Cage##10575 |goto Shadowmoon Valley/0 57.33,49.58
accept Proof of Allegiance##10622 |goto Shadowmoon Valley/0 57.33,49.58
only if rep ('The Aldor') >= Friendly
step
kill Zandras##21827 |q 10622/1 |goto Shadowmoon Valley/0 57.04,48.70
|tip he walks along the wall here.
step
Follow the path down |goto Shadowmoon Valley/0 57.35,49.67 < 5 |walk
talk Sanoru##21826
turnin Proof of Allegiance##10622 |goto Shadowmoon Valley/0 57.33,49.58
accept Akama##10628 |goto Shadowmoon Valley/0 57.33,49.58
step
Swim through the tunnel |goto Shadowmoon Valley/0 57.69,47.72 < 7
talk Akama##21700
|tip Inside the building.
turnin Akama##10628 |goto Shadowmoon Valley/0 58.11,48.19
accept Seer Udalo##10705 |goto Shadowmoon Valley/0 58.11,48.19
step
Enter The Arcatraz Dungeon
|tip It can be Normal or Heroic.
Click here to continue |confirm |q 10705 |future
step
Inside The Arcatraz Dungeon:
clicknpc Udalo##21962
|tip On the floor in the room before Harbinger Skyriss.
turnin Seer Udalo##10705
accept A Mysterious Portent##10706
step
Follow the path down |goto Shadowmoon Valley/0 57.35,49.67 < 5 |walk
Swim through the tunnel |goto Shadowmoon Valley/0 57.69,47.72 < 7
talk Akama##21700
|tip Inside the building.
turnin A Mysterious Portent##10706 |goto Shadowmoon Valley/0 58.11,48.19
accept The Ata'mal Terrace##10707 |goto Shadowmoon Valley/0 58.11,48.19
step
Swim through the tunnel |goto Shadowmoon Valley/0 57.71,48.54 < 7
kill Shadowmoon Soulstealer##22061+
|tip There will be 3 of them.
|tip Once you kill them, it will trigger an event.
|tip Kill the enemies that spawn.
|tip You may need help with this.
kill Shadowlord Deathwail##22006+
collect Heart of Fury##31307 |q 10707/1 |goto Shadowmoon Valley/0 71.60,35.51
step
Follow the path down |goto Shadowmoon Valley/0 57.35,49.67 < 5 |walk
Swim through the tunnel |goto Shadowmoon Valley/0 57.69,47.72 < 7
talk Akama##21700
|tip Inside the building.
turnin The Ata'mal Terrace##10707 |goto Shadowmoon Valley/0 58.11,48.19
accept Akama's Promise##11052 |goto Shadowmoon Valley/0 58.11,48.19
step
Swim through the tunnel |goto Shadowmoon Valley/0 57.71,48.54 < 7
kill Val'zareq the Conqueror##21979
|tip He patrols along the path of conquest with 4 adds.
|tip You may need help with this.
collect The Journal of Val'zareq##31345 |n
use The Journal of Val'zareq##31345
accept The Journal of Val'zareq: Portends of War##10793 |goto Shadowmoon Valley/0 51.05,58.85
step
click Crystal Prison##185126
turnin The Journal of Val'zareq: Portends of War##10793 |goto Shadowmoon Valley/0 51.40,72.80
accept Battle of the Crimson Watch##10781 |goto Shadowmoon Valley/0 51.40,72.80
step
Kill enemies around this area
|tip They will spawn in waves.
|tip You may need help with this.
Annihilate the Crimson Sigil Forces |q 11052/1
step
talk A'dal##18481
|tip Inside the building.
turnin Battle of the Crimson Watch##10781 |goto Shattrath City/0 53.99,44.75
turnin Akama's Promise##11052 |goto Shattrath City/0 53.99,44.75
step
Run Heroic Hellfire Citadel Dungeons for reputation.
|tip A full clear of Heroic Mechanar nets roughly 2,100 reputation.
|tip A full clear of Heroic Botanica nets roughly 3,200 reputation.
|tip A full clear of Heroic Arcatraz nets roughly 2,600 reputation.
|tip A full clear of Normal Mechanar nets roughly 1,600 reputation.
|tip A full clear of Normal Botanica nets roughly 2,200 reputation.
|tip A full clear of Normal Arcatraz nets roughly 1,800 reputation.
Reach Exalted Reputation with The Sha'tar |complete rep("The Sha'tar")==Exalted
step
label "exalted"
_Congratulations!_
You Earned Exalted Reputation with The Sha'tar
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Keepers of Time",{
author="support@zygorguides.com",
startlevel=60,
endlevel=70,
},[[
step
talk Steward of Time##20142
accept To The Master's Lair##10279 |goto Tanaris/0 66.02,49.70
step
talk Andormu##20130
turnin To The Master's Lair##10279 |goto Tanaris/0 58.43,54.28
accept The Caverns of Time##10277 |goto Tanaris/0 58.43,54.28
step
Follow the Custodian
|tip You can wait at Andormu while the Custodian explains.
Listen to the Caverns of Time Explanation |q 10277/1
step
talk Andormu##20130
turnin The Caverns of Time##10277 |goto Tanaris/0 58.43,54.28
accept Old Hillsbrad##10282 |goto Tanaris/0 58.43,54.28
step
Enter the Old Hillsbrad Foothills Dungeon
Click here to continue |confirm |q 29599 |future
step
Inside the Old Hillsbrad Dungeon:
talk Erozion##18723
|tip He is found outside the tunnel at the beginning of the dungeon.
turnin Old Hillsbrad##10282
accept Taretha's Diversion##10283
step
Inside the Old Hillsbrad Dungeon:
talk Brazen##18725
|tip He is next to Erozion.
Select _"I'm ready to go to Durnholde Keep."_
Fly with Brazen
confirm |q 10283
step
Inside the Old Hillsbrad Dungeon:
|tip After landing with Brazen, run northeast through the gate into Durnholde Keep.
|tip Before crossing the bridge, jump down to the area below.
click Barrel##182589+
|tip They look like small brown barrels inside the buildings around this area.
|tip There are five you must click, one in each of the buildings.
Set the Internment Lodges Ablaze |q 10283/1
step
Inside the Old Hillsbrad Dungeon:
talk Thrall##17876
|tip He is inside a prison cell inside Durnholde Keep.
|tip Make sure everyone in the group has turned in Taretha's Diversion before accepting Escape from Durnholde.
|tip Everyone will need to accept Escape from Durnholde at the same time or they won't be able to get it.
turnin Taretha's Diversion##10283
accept Escape from Durnholde##10284
step
Inside the Old Hillsbrad Dungeon:
Follow Thrall
|tip Follow and protect Thrall as he runs.
|tip Complete the dungeon and defeat the reminaing bosses.
kill Epoch Hunter##18096
|tip It is the last boss of the instance.
|tip Use the "Old Hillsbrad Foothills" dungeon guide to accomplish this.
Fulfill Thrall's Destiny |q 10284/1
step
Inside the Old Hillsbrad Dungeon:
Watch the dialogue
talk Erozion##18723
|tip He appears at the end of the dungeon after defeating the Epoch Hunter.
turnin Escape from Durnholde##10284
accept Return to Andormu##10285
step
talk Andormu##20130
|tip Inside the cave.
turnin Return to Andormu##10285 |goto Tanaris/0 58.43,54.28
accept The Black Morass##10296 |goto Tanaris/0 58.43,54.28
step
Enter the Black Morass Dungeon
Click here to continue |confirm
step
Inside The Black Morass Dungeon:
talk Sa'at##20201
turnin The Black Morass##10296
accept The Opening of the Dark Portal##10297
step
Inside The Black Morass Dungeon:
Follow and protect Medivh
Kill the enemies that attack
|tip Use "The Black Morass" dungeon guide to accomplish this.
Defend Medivh |q 10297/1
step
Inside The Black Morass Dungeon:
talk Sa'at##20201
turnin The Opening of the Dark Portal##10297
accept Hero of the Brood##10298
step
talk Andormu##20130
|tip Inside the cave.
turnin Hero of the Brood##10298 |goto Tanaris/0 58.43,54.28
step
Run Caverns of Time Dungeons for reputation.
|tip A full clear of Heroic Old Hillsbrad Foothills nets roughly 2,300 reputation.
|tip A full clear of Heroic Black Morass nets roughly 1,750 reputation.
|tip A full clear of Normal Old Hillsbrad Foothills nets roughly 1,000 reputation.
|tip A full clear of Normal Black Morass nets roughly 1,100 reputation.
Reach Exalted Reputation with the Keepers of Time |complete rep('Keepers of Time')==Exalted
step
_Congratulations!_
You Earned Exalted Reputation with The Keepers of Time
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\The Mag'har",{
author="support@zygorguides.com",
description="This guide will walk you through the quests granting reputation with The Mag'har.",
startlevel=70,
endlevel=70,
},[[
step
talk Nazgrel##3230
|tip Inside the building.
accept The Assassin##9400 |goto Hellfire Peninsula/0 55.02,35.95
step
Find Krun Spinebreaker |q 9400/1 |goto Hellfire Peninsula/0 33.61,43.52
step
talk Fel Orc Corpse##17062
turnin The Assassin##9400 |goto Hellfire Peninsula/0 33.6,43.6
accept A Strange Weapon##9401 |goto Hellfire Peninsula/0 33.6,43.6
step
talk Nazgrel##3230
|tip Inside the building.
turnin A Strange Weapon##9401 |goto Hellfire Peninsula/0 55.02,35.95
accept The Warchief's Mandate##9405 |goto Hellfire Peninsula/0 55.02,35.95
step
talk Far Seer Regulkut##16574
turnin The Warchief's Mandate##9405 |goto Hellfire Peninsula/0 54.23,37.90
accept A Spirit Guide##9410 |goto Hellfire Peninsula/0 54.23,37.90
step
use the Ancestral Spirit Wolf Totem##23669
|tip Use it at the corpse.
Follow the Ancestral Spirit Wolf |goto Hellfire Peninsula/0 33.62,43.52
|tip Stay close to the Ancestral Spirit Wolf.
Click here to continue |confirm |q 9410
step
talk Gorkan Bloodfist##16845
|tip Stay close to the Ancestral Spirit Wolf.
|tip If you don't you will have to escort the wolf to Gorkan again.
turnin A Spirit Guide##9410 |goto Hellfire Peninsula/0 32.00,27.79
accept The Mag'har##9406 |goto Hellfire Peninsula/0 32.00,27.79
step
talk Nazgrel##3230
|tip Inside the building.
turnin The Mag'har##9406 |goto Hellfire Peninsula/0 55.02,35.95
accept Messenger to Thrall##9438 |goto Hellfire Peninsula/0 55.02,35.95
step
talk Thrall##4949
|tip Inside the building.
turnin Messenger to Thrall##9438 |goto Orgrimmar/0 31.63,37.82
accept Envoy to the Mag'har##9441 |goto Orgrimmar/0 31.63,37.82
step
talk Gorkan Bloodfist##16845
|tip Stay close to the Ancestral Spirit Wolf.
|tip If you don't you will have to escort the wolf to Gorkan again.
turnin Envoy to the Mag'har##9441 |goto Hellfire Peninsula/0 32.00,27.79
step
talk Earthcaller Ryga##17123
accept A Debilitating Sickness##9442 |goto Hellfire Peninsula/0 32.09,28.36
step
Enter the cave |goto Hellfire Peninsula/0 34.13,63.27 < 10 |walk
click Drycap Mushroom
|tip They are on the ground all around the cave.
collect Drycap Mushroom##23753 |q 9442/1 |goto Hellfire Peninsula/0 33.77,65.12
step
talk Earthcaller Ryga##17123
turnin A Debilitating Sickness##9442 |goto Hellfire Peninsula/0 32.09,28.36
accept Administering the Salve##9447 |goto Hellfire Peninsula/0 32.09,28.36
step
clicknpc Debilitated Mag'har Grunt##16847
use the Healing Salve##23394
|tip Use it on the Debilitated Grunts around the area.
Heal #10 Debilitated Grunts|q 9447/1 |goto Hellfire Peninsula/0 35.92,28.20
step
talk Earthcaller Ryga##17123
turnin Administering the Salve##9447 |goto Hellfire Peninsula/0 32.09,28.36
step
Follow the path |goto Hellfire Peninsula/0 60.33,36.44 < 20 |only if walking
talk Warden Bullrok##18407
accept Proving Your Strength##10479 |goto Hellfire Peninsula/0 55.79,37.94
step
talk Jorin Deadeye##18106
accept The Impotent Leader##9888 |goto Nagrand/0 55.56,37.62
step
talk Matron Celestine##18301
accept He Called Himself Altruis##9983 |goto Nagrand/0 55.20,36.11
step
talk Kilrath##18273
turnin The Impotent Leader##9888 |goto Terokkar Forest/0 19.77,60.85
accept Don't Kill the Fat One##9889 |goto Terokkar Forest/0 19.77,60.85
stickystart "Slay_Boulderfist_Invaders"
step
kill Unkor the Ruthless##18262
Fight Unkor Until He Submits |q 9889/2 |goto Terokkar Forest/0 20.06,63.23
step
label "Slay_Boulderfist_Invaders"
kill 10 Boulderfist Invader##18260 |q 9889/1 |goto Terokkar Forest/0 19.99,63.72
step
label "Collect_Obsidian_Warbeads"
Kill Boulderfist enemies around this area
collect 10 Obsidian Warbeads##25433 |q 10479/1 |goto Terokkar Forest/0 73.06,70.27
step
talk Unkor the Ruthless##18262
turnin Don't Kill the Fat One##9889 |goto Terokkar Forest/0 20.06,63.23
accept Success!##9890 |goto Terokkar Forest/0 20.06,63.23
step
talk Kilrath##18273
turnin Success!##9890 |goto Terokkar Forest/0 19.77,60.85
accept Because Kilrath is a Coward##9891 |goto Terokkar Forest/0 19.77,60.85
step
talk Warden Bullrok##18407
turnin Proving Your Strength##10479 |goto Terokkar Forest/0 55.79,37.94
step
talk Jorin Deadeye##18106
turnin Because Kilrath is a Coward##9891 |goto Nagrand/0 55.56,37.62
accept Message in a Battle##9906 |goto Nagrand/0 55.56,37.62
stickystart "Slay_Boulder_Crushers"
step
kill 15 Boulderfist Mystic##17135 |q 9906/1 |goto Nagrand/0 73.41,70.20
step
label "Slay_Boulder_Crushers"
kill 15 Boulderfist Crusher##17134 |q 9906/2 |goto Nagrand/0 73.41,70.20
step
talk Jorin Deadeye##18106
turnin Message in a Battle##9906 |goto Nagrand/0 55.56,37.62
accept An Audacious Advance##9907 |goto Nagrand/0 55.56,37.62
step
stickystart "Slay_Boulderfist_Mages"
step
Follow the path down |goto Nagrand/0 40.18,27.78 < 15 |only if walking
kill 25 Boulderfist Warrior##17136 |q 9907/1 |goto Nagrand/0 40.76,31.58
|tip You can find more inside the nearby cave.
step
label "Slay_Boulderfist_Mages"
kill 25 Boulderfist Mage##17137 |q 9907/2 |goto Nagrand/0 40.76,31.58
|tip You can find more inside the nearby cave.
step
Kill enemies around this area
|tip The quest will show up once they are dead.
talk Mag'har Captive##18210 |goto Nagrand/0 31.33,44.12
accept The Totem of Kar'dash##9868 |goto Nagrand/0 31.32,44.13
step
Free the Mag'har Captive |q 9868/1 |goto Nagrand/0 31.73,38.74
step
talk Altruis the Sufferer##18417
turnin He Called Himself Altruis...##9983 |goto Nagrand/0 27.34,43.08 |only if haveq(9983) or completedq(9983)
accept Survey the Land##9991 |goto Nagrand/0 27.34,43.08
|tip Make sure you dismount before accepting this quest, or you will have to abandon it, and pick it back up.
step
Watch the dialogue as you fly
Survey the Forge Camps |q 9991/1
step
talk Altruis the Sufferer##18417
turnin Survey the Land##9991 |goto Nagrand/0 27.34,43.08
accept Buying Time##9999 |goto Nagrand/0 27.34,43.08
stickystart "Slay_Moarg_Engineers"
stickystart "Slay_Ganarg_Tinkerers"
step
kill 2 Felguard Legionnaire##17152+ |q 9999/1 |goto Nagrand/0 25.13,38.25
step
label "Slay_Moarg_Engineers"
kill 3 Mo'arg Engineer##16945+ |q 9999/2 |goto Nagrand/0 24.36,37.44
step
label "Slay_Ganarg_Tinkerers"
kill 8 Gan'arg Tinkerer##17151+ |q 9999/3 |goto Nagrand/0 25.07,37.72
step
talk Altruis the Sufferer##18417
turnin Buying Time##9999 |goto Nagrand/0 27.34,43.08
accept The Master Planner##10001 |goto Nagrand/0 27.34,43.08
step
kill Mo'arg Master Planner##18567
collect The Master Planner's Blueprints##25751 |q 10001/1 |goto Nagrand/0 23.60,34.66
step
talk Altruis the Sufferer##18417
turnin The Master Planner##10001 |goto Nagrand/0 27.34,43.08
accept Patience and Understanding##10004 |goto Nagrand/0 27.34,43.08
step
Enter the building |goto Shattrath City/0 74.05,32.84 < 7 |walk
talk Sal'salabim##18584
|tip Inside the building.
Select _"Altruis sent me. He said that you could help me."_
kill Sal'salabim##18584
Persuade Sal'salabim |q 10004/1 |goto Shattrath City/0 77.30,34.87
step
talk Sal'salabim##18584
|tip Inside the building.
turnin Patience and Understanding##10004 |goto Shattrath City/0 77.30,34.87
accept Crackin' Some Skulls##10009 |goto Shattrath City/0 77.30,34.87
step
talk Raliq the Drunk##18585
|tip Inside the building.
Select _"I have been sent by Sal'salabim to collect a debt that you owe. Pay up or I'm going to have to hurt you."_
kill Raliq the Drunk##18585
collect Raliq's Debt##25767 |q 10009/1 |goto Shattrath City/0 75.01,31.41
step
talk Coosh'coosh##18586
|tip He walks around this area.
Select _"I have been sent by Sal'salabim to collect a debt that you owe. Pay up or I'm going to have to hurt you."_
kill Coosh'coosh##18586
collect Coosh'coosh's Debt##25768 |q 10009/2 |goto Zangarmarsh/0 80.88,91.20
step
talk Floon##18588
|tip He walks around this area.
Select _"I have been sent by Sal'salabim to collect a debt that you owe. Pay up or I'm going to have to hurt you."_
kill Floon##18588
collect Floon's Debt##25769 |q 10009/3 |goto Terokkar Forest/0 27.43,58.18
step
Enter the building |goto Shattrath City/0 74.05,32.84 < 7 |walk
talk Sal'salabim##18584
|tip Inside the building.
turnin Crackin' Some Skulls##10009 |goto Shattrath City/0 77.30,34.87
accept It's Just That Easy?##10010 |goto Shattrath City/0 77.30,34.87
step
talk Altruis the Sufferer##18417
turnin It's Just That Easy?##10010 |goto Nagrand/0 27.34,43.08
accept Forge Camp: Annihilated##10011 |goto Nagrand/0 27.34,43.08
step
kill Demos Overseer of Hate##18535
collect Fel Cannon Activator##25770 |q 10011 |goto Nagrand/0 24.98,36.09
step
use the Fel Cannon Activator##25770
Destroy Forge Camp: Hate |q 10011/1 |goto Nagrand/0 25.04,35.89
step
kill Xirkos, Overseer of Fear##18536
collect Fel Cannon Activator##25771 |q 10011 |goto Nagrand/0 19.60,51.12
step
use the Fel Cannon Activator##25771
Destroy Forge Camp: Fear |q 10011/2 |goto Nagrand/0 19.34,50.86
step
talk Altruis the Sufferer##18417
turnin Forge Camp: Annihilated##10011 |goto Nagrand/0 27.34,43.08
step
talk Jorin Deadeye##18106
turnin An Audacious Advance##9907 |goto Nagrand/0 55.56,37.62
accept Diplomatic Measures##10107 |goto Nagrand/0 55.56,37.62
step
talk Garrosh##18063
turnin Murkblood Invaders##9872 |goto Nagrand/0 55.44,37.64
turnin The Totem of Kar'dash##9868 |goto Nagrand/0 55.44,37.64
step
Follow the path up |goto Nagrand/0 73.84,68.07 < 10 |only if walking
talk Lantresor of the Blade##18261
Select _"I have killed many of your ogres, Lantresor. I have no fear."_
Hear the Story of the Blademaster |q 10107/1 |goto Nagrand/0 73.81,62.61
step
talk Lantresor of the Blade##18261
turnin Diplomatic Measures##10107 |goto Nagrand/0 73.81,62.61
accept Armaments for Deception##9928 |goto Nagrand/0 73.81,62.61
accept Ruthless Cunning##9927 |goto Nagrand/0 73.81,62.61
stickystart "Collect_Kilsorrow_Armaments"
step
Kill Kil'sorrow enemies around this area
use the Warmaul Ogre Banner##25552
|tip Use it on their corpses.
Plant #20# Warmaul Ogre Banners |q 9927/1 |goto Nagrand/0 70.09,79.41
step
label "Collect_Kilsorrow_Armaments"
click Kil'sorrow Armaments##182355+
|tip They look like flat brown boxes with a red axe logo on them on the ground around this area.
collect 20 Kil'sorrow Armaments##25554 |q 9928/1 |goto Nagrand/0 70.26,80.00
step
Follow the path up |goto Nagrand/0 73.84,68.07 < 10 |only if walking
talk Lantresor of the Blade##18261
turnin Armaments for Deception##9928 |goto Nagrand/0 73.81,62.61
turnin Ruthless Cunning##9927 |goto Nagrand/0 73.81,62.61
accept Returning the Favor##9931 |goto Nagrand/0 73.81,62.61
accept Body of Evidence##9932 |goto Nagrand/0 73.81,62.61
step
Kill Warmaul enemies around this area
use the Kil'sorrow Banner##25555
|tip Use it on their copses.
Plant #10# Kil'sorrow Banners |q 9931/1 |goto Nagrand/0 46.84,23.00
step
use the Damp Woolen Blanket##25658
Defend the two Boulderfist Saboteurs that spawn
|tip They will walk around and plant bodies around this area.
Plant the Kil'sorrow Bodies |q 9932/1 |goto Nagrand/0 46.59,24.25
step
Follow the path up |goto Nagrand/0 73.84,68.07 < 10 |only if walking
talk Lantresor of the Blade##18261
turnin Returning the Favor##9931 |goto Nagrand/0 73.81,62.61
turnin Body of Evidence##9932 |goto Nagrand/0 73.81,62.61
accept Message to Garadar##9934 |goto Nagrand/0 73.81,62.61
step
talk Garrosh##18063
turnin Message to Garadar##9934 |goto Nagrand/0 55.44,37.64
accept A Visit With the Greatmother##10044 |goto Nagrand/0 55.44,37.64
step
talk Greatmother Geyah##18141
|tip Inside the building.
turnin A Visit With the Greatmother##10044 |goto Nagrand/0 56.70,34.31
accept Material Components##10045 |goto Nagrand/0 56.70,34.31
step
click Telaari Frond##182599
|tip It looks like a green bush along the cliff wall around this area.
collect Telaari Frond##25864 |q 10045/3 |goto Nagrand/0 59.14,55.52
step
click Olemba Root##182601
|tip It looks like a viny green plant near the base of trees around this area.
collect Olemba Root##25863 |q 10045/1 |goto Terokkar Forest/0 32.74,38.52
step
click Dragonspine##182606
|tip It looks like a red leafy plant next to the big spiky rock formations around this area.
collect Dragonspine##25865 |q 10045/4 |goto Blade's Edge Mountains/0 39.64,72.38
step
click Marshberry##182600
|tip It looks like a big red ball on the ground around this area.
collect Marshberry##25862 |q 10045/2 |goto Zangarmarsh/0 20.07,8.52
step
talk Greatmother Geyah##18141
|tip Inside the building.
|tip Walks all around Oshu'Gun, you'll probably have to look around.
turnin Material Components##10045 |goto Nagrand/0 56.70,34.31
accept To Meet Mother Kashur##10081 |goto Nagrand/0 56.70,34.31
step
talk Mother Kashur##18687
turnin To Meet Mother Kashur##10081 |goto Nagrand/0 26.07,60.60
accept The Agitated Ancestors##10082 |goto Nagrand/0 26.07,60.60
step
kill 8 Agitated Orc Spirit##18043 |q 10082/1 |goto Nagrand/0 26.51,60.10
step
talk Mother Kashur##18687
turnin The Agitated Ancestors##10082 |goto Nagrand/0 26.07,60.60
accept A Visit With The Ancestors##10085 |goto Nagrand/0 26.07,60.60
step
Visit Sunspring Post |q 10085/1 |goto Nagrand/0 31.68,43.81
step
Visit the Laughing Skull Clan Ruins |q 10085/2 |goto Nagrand/0 46.31,23.86
step
Visit Garadar |q 10085/3 |goto Nagrand/0 54.75,36.38
step
Visit the Bleeding Hollow Clan Ruins |q 10085/4 |goto Terokkar Forest/0 19.77,61.86
step
talk Mother Kashur##18687
turnin A Visit With The Ancestors##10085 |goto Nagrand/0 26.07,60.60
accept When Spirits Speak##10101 |goto Nagrand/0 26.07,60.60
step
Enter the cave |goto Nagrand/0 35.83,67.76 < 10 |walk
talk K'ure##17545
|tip Inside the cave.
turnin When Spirits Speak##10101 |goto Nagrand/0 35.48,77.84
accept A Secret Revealed##10102 |goto Nagrand/0 35.48,77.84
step
talk A'dal##18481
turnin A Secret Revealed##10102 |goto Shattrath City/0 53.99,44.76
accept Auchindoun...##10167 |goto Shattrath City/0 53.99,44.76
step
Inside the Auchenai Crypts Dungeon:
kill Exarch Maladaar##18373 |q 10167/1
|tip This is for the quest "Auchindoun...".
step
Inside the Auchenai Crypts Dungeon:
talk D'ore##19412
|tip It looks like a big white floating NPC that appears after you kill Exarch Maladaar.
|tip Inside the Auchenai Crypts dungeon.
turnin Auchindoun...##10167
accept What the Soul Sees##10168
step
Inside the Auchenai Crypts Dungeon:
click Soul Mirror##183441
|tip It looks like a big pink floating crystal near the wall where you fight Exarch Maladaar.
|tip Inside the Auchenai Crypts dungeon.
collect Soul Mirror##28283 |q 10168/2
step
Leave the Auchenai Crypts Dungeon |goto Auchenai Crypts/0 0.00,0.00 > 10 |c |noway |q 10168
step
clicknpc Ancient Orc Ancestor##18688+
|tip They are non-aggressive ghosts that walk around this area.
|tip They can be hard to see, use the command "/tar Ancient" to help find them.
use the Soul Mirror##28283
kill 15 Darkened Spirit##19480+ |q 10168/1 |goto Nagrand/0 37.07,63.11
step
talk Mother Kashur##18687
turnin What the Soul Sees##10168 |goto Nagrand/0 26.07,60.60
accept Return to the Greatmother##10170 |goto Nagrand/0 26.07,60.60
step
talk Greatmother Geyah##18141
|tip Inside the building.
|tip Walks all around Oshu'Gun, you'll probably have to look around.
turnin Return to the Greatmother##10170 |goto Nagrand/0 56.70,34.31
accept The Inconsolable Chieftain##10171 |goto Nagrand/0 56.70,34.31
step
talk Garrosh##18063
turnin The Inconsolable Chieftain##10171 |goto Nagrand/0 55.44,37.64
accept There Is No Hope##10172 |goto Nagrand/0 55.44,37.64
step
talk Greatmother Geyah##18141
|tip Inside the building.
Select _"Garrosh is beyond redemption, Greatmother. I fear that in helping the Mag'har, I have convinced Garrosh that he is unfit to lead."_
Speak with Greatmother Geyah |q 10172/1 |goto Nagrand/0 56.70,34.31
step
talk Garrosh##18063
turnin There Is No Hope##10172 |goto Nagrand/0 55.44,37.64
accept Thrall, Son of Durotan##10175 |goto Nagrand/0 55.44,37.64
step
talk Thrall##4949
|tip Inside the building.
turnin Thrall, Son of Durotan##10175 |goto Orgrimmar/0 31.63,37.82
accept Hero of the Mag'har##10212 |goto Orgrimmar/0 31.63,37.82
step
talk Greatmother Geyah##18141
|tip Inside the building.
turnin Hero of the Mag'har##10212 |goto Nagrand/0 56.70,34.31
step
Enter the building |goto Nagrand/0 56.39,35.33 < 15 |walk
talk Matron Drakia##18302
|tip She walks around this area.
|tip Inside the building.
accept Missing Mag'hari Procession##9944 |goto Nagrand/0 57.18,34.15
step
talk Elder Yorley##18414
turnin Missing Mag'hari Procession##9944 |goto Nagrand/0 32.31,36.15
accept War on the Warmaul##9945 |goto Nagrand/0 32.31,36.15
step
talk Saurfang the Younger##18229
accept Once Were Warriors##9865 |goto Nagrand/0 32.44,36.03
step
label "Kill_Warmaul_Brutes"
kill 15 Warmaul Brute##18065 |q 9945/1 |goto Nagrand/0 23.91,29.30
You can find more up the path that starts at [Nagrand/0 26.29,29.62]
step
label "Kill_Warmaul_Warlocks"
kill 15 Warmaul Warlock##18037 |q 9945/2 |goto Nagrand/0 23.91,29.30
You can find more up the path that starts at [Nagrand/0 26.29,29.62]
step
Follow the path down |goto Nagrand/0 27.14,30.20 < 20 |only if walking
talk Elder Yorley##18414
turnin War on the Warmaul##9945 |goto Nagrand/0 32.31,36.15
accept Cho'war the Pillager##9946 |goto Nagrand/0 32.31,36.15
step
Enter the cave |goto Nagrand/0 27.13,18.60 < 10
Follow the path |goto Nagrand/0 25.90,16.54 < 10 |walk
Continue following the path |goto Nagrand/0 27.01,13.43 < 10 |walk
Follow the path up |goto Nagrand/0 28.40,13.53 < 10 |walk
Enter the cave |goto Nagrand/0 27.52,11.31 < 10 |walk
Follow the path |goto Nagrand/0 26.22,14.11 < 10 |walk
Follow the path up |goto Nagrand/0 26.02,15.84 < 10
kill Cho'war the Pillager##18423
|tip Inside the cave.
|tip This enemy is elite and may require a group.
collect Head of Cho'war##25590 |q 9946/1 |goto Nagrand/0 25.91,13.78
step
Follow the path down |goto Nagrand/0 27.14,30.20 < 20 |only if walking
talk Elder Yorley##18414
turnin Cho'war the Pillager##9946 |goto Nagrand/0 32.31,36.15
step
label "Kill_Murkblood_Raiders"
kill 20 Murkblood Raider##18203 |q 9865/2 |goto Nagrand/0 32.23,42.34
step
label "Kill_Murkblood_Scaveners"
kill 40 Murkblood Scavenger##18207 |q 9865/1 |goto Nagrand/0 32.23,42.34
step
talk Saurfang the Younger##18229
turnin Once Were Warriors##9865 |goto Nagrand/0 32.44,36.03
accept He Will Walk The Earth...##9866 |goto Nagrand/0 32.44,36.03
step
talk Farseer Corhuk##18067
turnin He Will Walk The Earth...##9866 |goto Nagrand/0 54.80,39.86
step
talk Warden Bullrok##18407
|tip He walks around this area.
accept Wanted: Durn the Hungerer##9937 |goto Nagrand/0 55.8,37.8
step
map Nagrand/0
path	loop off; follow strictbounce
path	41.8,61.2	37.6,60.2	33.0,60.8	30.6,64.8	31.0,69.2
path	32.6,75.2	34.4,78.0	37.6,78.8	41.8,76.0	46.0,73.0
path	46.6,69.2	47.0,64.6	44.8,60.2
kill Durn The Hungerer##18411
|tip He patrols around Oshu'gun.
|tip This enemy is elite and may require a group.
Slay Durn The Hungerer |q 9937/1
step
talk Warden Bullrok##18407
|tip He walks around this area.
turnin Wanted: Durn the Hungerer##9937 |goto Nagrand/0 55.8,37.8
step
label "Collect_Obsidian_Warbeads"
Kill Boulderfist enemies around this area
collect Obsidian Warbeads##25433 |n |goto Nagrand/0 73.73,70.02
|tip Be careful not to accidentally sell these to a vendor.
You can find more around [Nagrand/0 75.30,63.65]
Click here to continue |confirm
step
talk Warden Moi'bff Jill##18408
|tip He walks around this area.
accept More Warbeads##10477 |goto Nagrand/0 54.74,70.87
Click here to go back to Obsidian Warbead farming |next "Collect_Obsidian_Warbeads" |or
Reach Exalted with the Kurenai |complete rep("The Mag'har")>=Exalted  |or
step
_Congratulations!_
You Earned Exalted with The Mag'har
]])
ZygorGuidesViewer:RegisterGuide("Reputation Guides\\The Burning Crusade\\Sporeggar",{
author="support@zygorguides.com",
startlevel=60,
endlevel=70,
},[[
step
talk Fahssn##17923
|tip He walks around this area.
accept The Sporelings' Plight##9739 |goto Zangarmarsh/0 18.96,63.45
accept Natural Enemies##9743 |goto Zangarmarsh/0 18.96,63.45
stickystart "Collect_Mature_Spore_Sacs"
step
Kill Starving enemies around this area
collect 6 Bog Lord Tendril##24291 |q 9743/1 |goto Zangarmarsh/0 15.90,60.51
step
label "Collect_Mature_Spore_Sacs"
click Mature Spore Sac##182069+
|tip They look like small puffy, balloon-shaped sacs on on the ground around this area.
collect 10 Mature Spore Sac##24290 |q 9739/1 |goto Zangarmarsh/0 15.90,60.51
step
talk Fahssn##17923
|tip He walks around this area.
turnin The Sporelings' Plight##9739 |goto Zangarmarsh/0 18.96,63.45
turnin Natural Enemies##9743 |goto Zangarmarsh/0 18.96,63.45
step
label "Collect_Spore_Sacs_Reach_Friendly"
click Mature Spore Sac##182069+
|tip They look like small puffy, balloon-shaped sacs on on the ground around this area.
collect Mature Spore Sac##24290 |n |goto Zangarmarsh/0 15.90,60.51
|tip Collect them in in stacks of 10.
Click here to turn them in |confirm
step
talk Fahssn##17923
|tip He walks around this area.
accept More Spore Sacs##9742 |goto Zangarmarsh/0 18.96,63.45 |only if rep('Sporeggar')<Friendly
Click here to continue farming |next "Collect_Spore_Sacs_Reach_Friendly" |confirm |only if rep('Sporeggar')<Friendly
Reach Friendly with Sporeggar |complete rep('Sporeggar')>=Friendly |next "Reached_Friendly_Reputation"
step
label "Reached_Friendly_Reputation"
talk Fahssn##17923
|tip He walks around this area.
accept Sporeggar##9919 |goto Zangarmarsh/0 18.96,63.45
step
Enter the building |goto Zangarmarsh/0 19.54,51.82 < 5 |walk
talk Msshi'fn##17924
|tip Inside the building.
turnin Sporeggar##9919 |goto Zangarmarsh/0 19.68,52.07
step
The fastest way to go reach Exalted is to farm The Underbog dungeon
|tip You can complete the dungeon once pery day on Heroic and as many times as you want on Normal.
Enter The Underbog
Click here to continue |confirm
only if rep('Sporeggar')<Exalted
step
label "Farm_Dungeon_Collect_Sanguine_Hibiscus"
Inside The Underbog Dungeon:
Kill everything in the dungeon
click Sanguine Hibiscus##183385+
|tip They look like small red flowery plants on the ground throughout the dungeon.
|tip They can also drop from creatures in the dungeon.
collect Sanguine Hibiscus##24246 |n
|tip Collect these and turn them in for more reputation after each run.
Click here to turn them in |confirm |only if rep('Sporeggar')<Exalted
step
talk Gzhun'tt##17856
accept Bring Me Another Shrubbery!##9714 |goto Zangarmarsh/0 31.48,65.21 |only if rep('Sporeggar')<Exalted
Click here to continue farming |next "Farm_Dungeon_Collect_Sanguine_Hibiscus" |confirm |only if rep('Sporeggar')<Exalted
|tip You can complete the dungeon once pery day on Heroic and as many times as you want on Normal.
Earn Exalted status with the Sporeggar |complete rep('Sporeggar')==Exalted |next "Reached_Exalted_Status"
step
label "Reached_Exalted_Status"
_Congratulations!_
You reached Exalted reputation with the "Sporeggar" faction.
]])
ZGV.BETAEND()
