ZGV.Gold.guides_loaded=true
if ZGV:DoMutex("GoldGathC") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Barbed Gill Trout, Spotted Feltail, Zangarian Sporefish",{
meta={goldtype="route",skillreq={fishing=305},levelreq={60}},
items={{27422,212},{27425,44},{27429,56}},
maps={"Zangarmarsh"},
},[[
step
Equip a Fishing Pole |equipped Fishing Pole##6256 |or
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
'|equipped Strong Fishing Pole##6365 |or
'|equipped Blump Family Fishing Pole##12225 |or
'|equipped Arcanite Fishing Pole##19970 |or
'|equipped Darkwood Fishing Pole##6366 |or
'|equipped Big Iron Fishing Pole##6367 |or
'|equipped Nat Pagle's Extreme Angler FC-5000##19022 |or
'|equipped Seth's Graphite Fishing Pole##25978 |or
step
label "Start_Farming_Fish"
cast Fishing##33095
|tip Fish in the water.
|tip You must have a Fishing Pole equipped to fish.
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
|goldcollect Barbed Gill Trout##27422 |goto Zangarmarsh/0 78.95,71.48
|goldcollect Spotted Feltail##27425 |goto Zangarmarsh/0 78.95,71.48
|goldcollect Zangarian Sporefish##27429 |goto Zangarmarsh/0 78.95,71.48
|goldtracker
Click Here to Sell Fish |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Fish |confirm |next "Start_Farming_Fish"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Furious Crawdad, Golden Darter",{
meta={goldtype="route",skillreq={fishing=430},levelreq={70}},
items={{27439,92},{27438,36}},
maps={"Terokkar Forest"},
},[[
step
Equip a Fishing Pole |equipped Fishing Pole##6256 |or
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
'|equipped Strong Fishing Pole##6365 |or
'|equipped Blump Family Fishing Pole##12225 |or
'|equipped Arcanite Fishing Pole##19970 |or
'|equipped Darkwood Fishing Pole##6366 |or
'|equipped Big Iron Fishing Pole##6367 |or
'|equipped Nat Pagle's Extreme Angler FC-5000##19022 |or
'|equipped Seth's Graphite Fishing Pole##25978 |or
step
label "Start_Farming_Furious_Crawdad"
map Terokkar Forest/0
path follow smart; loop off; ants curved; dist 30
path	45.14,40.51	47.04,40.58	48.00,40.31	49.49,38.17	53.27,41.35
path	55.55,45.31	58.31,48.49	60.07,49.77	61.32,54.09	60.24,58.34
path	59.59,60.78	59.18,63.24	60.50,68.35	61.30,71.46	62.40,71.65
path	63.49,73.35	63.38,75.85	63.64,78.75	64.59,82.30	66.72,83.02
path	68.04,82.73	68.64,80.39	68.11,77.15	66.71,74.38
cast Fishing##33095
|tip Fish in Highland Mixed Schools.
|tip You must have a Fishing Pole equipped to fish.
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
|tip When flying near Stonebreaker Hold, don't get too close or you will be shot down. |only if Alliance
|tip When flying near Allerian Stronghold, don't get too close or you will be shot down. |only if Horde
|goldcollect Furious Crawdad##27439
|goldcollect Golden Darter##27438
|goldtracker
Click Here to Sell Furious Crawdad |confirm |next "Sell_Furious_Crawdad"
'|goto Terokkar Forest/0 66.71,74.38 < 30 |c |noway |or
step
map Terokkar Forest/0
path follow smart; loop off; ants curved; dist 30
path	66.71,74.38	68.11,77.15	68.64,80.39	68.04,82.73	66.72,83.02
path	64.59,82.30	63.64,78.75	63.38,75.85	63.49,73.35	62.40,71.65
path	61.30,71.46	60.50,68.35	59.18,63.24	59.59,60.78	60.24,58.34
path	61.32,54.09	60.07,49.77	58.31,48.49	55.55,45.31	53.27,41.35
path	49.49,38.17	48.00,40.31	47.04,40.58	45.14,40.51
cast Fishing##33095
|tip Fish in Highland Mixed Schools.
|tip You must have a Fishing Pole equipped to fish.
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
|tip When flying near Stonebreaker Hold, don't get too close or you will be shot down. |only if Alliance
|tip When flying near Allerian Stronghold, don't get too close or you will be shot down. |only if Horde
|goldcollect Furious Crawdad##27439
|goldcollect Golden Darter##27438
|goldtracker
Click Here to Sell Furious Crawdad |confirm |next "Sell_Furious_Crawdad"
'|goto Terokkar Forest/0 45.14,40.51 < 30 |c |noway |next "Start_Farming_Furious_Crawdad" |or
step
label "Sell_Furious_Crawdad"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Furious Crawdad |confirm |next "Start_Farming_Furious_Crawdad"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Bloodfin Catfish, Crescent-Tail Skullfish",{
meta={goldtype="route",skillreq={fishing=300},levelreq={60}},
items={{33823,68},{33824,64},{27422,132}},
maps={"Deadwind Pass"},
},[[
step
Equip a Fishing Pole |equipped Fishing Pole##6256 |or
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
'|equipped Strong Fishing Pole##6365 |or
'|equipped Blump Family Fishing Pole##12225 |or
'|equipped Arcanite Fishing Pole##19970 |or
'|equipped Darkwood Fishing Pole##6366 |or
'|equipped Big Iron Fishing Pole##6367 |or
'|equipped Nat Pagle's Extreme Angler FC-5000##19022 |or
'|equipped Seth's Graphite Fishing Pole##25978 |or
step
label "Start_Farming_Bloodfin_Catfish"
cast Fishing##33095
|tip Fish in the water.
|tip You must have a Fishing Pole equipped to fish.
|tip A Fishing Pole can be purchased near most Fishing profession trainers.
|goldcollect Bloodfin Catfish##33823 |goto Deadwind Pass/0 52.79,73.82
|goldcollect Crescent-Tail Skullfish##33824 |goto Deadwind Pass/0 52.79,73.82
|goldcollect Barbed Gill Trout##27422 |goto Deadwind Pass/0 52.79,73.82
|goldtracker
Click Here to Sell Fish |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Fish |confirm |next "Start_Farming_Bloodfin_Catfish"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Felweed",{
meta={goldtype="route",skillreq={herbalism=300},levelreq={61}},
items={{22785,232},{13464,44},{13463,52},{13465,26},{22575,10}},
maps={"Terokkar Forest"},
},[[
step
label "Start_Farming_Felweed"
map Terokkar Forest/0
path follow smart; loop on; ants curved
path	31.60,45.71	32.29,42.68	32.86,38.44	32.61,35.72	34.85,34.70
path	36.60,32.54	36.98,30.09	38.61,28.59	39.20,26.76	40.64,25.10
path	41.40,22.16	43.06,19.91	43.81,17.68	43.32,15.01	43.95,12.48
path	45.94,12.75	48.58,14.35	50.45,17.02	49.36,20.09	49.79,22.32
path	50.98,24.83	53.08,25.59	55.63,25.32	58.26,25.33	59.93,23.87
path	61.12,26.59	62.13,28.15	63.46,29.60	65.02,31.32	67.13,31.63
path	69.82,31.74	69.61,35.63	68.73,39.39	69.79,42.02	70.46,45.89
path	70.51,48.71	68.94,53.17	68.11,54.89	65.38,54.27	63.87,51.31
path	61.59,50.51	59.04,49.28	56.48,46.30	53.96,42.43	54.33,38.20
path	53.25,35.66	50.24,35.67	48.92,34.53	46.58,34.04	43.68,34.49
path	40.40,35.76	38.35,36.51	36.62,38.18	36.01,39.93	36.50,42.94
path	35.72,43.53	33.66,44.98
click Felweed##181270+
|tip Gather Felweed along the path.
|goldcollect Felweed##22785
|goldcollect Golden Sansam##13464
|goldcollect Dreamfoil##13463
|goldcollect Mountain Silversage##13465
|goldcollect Mote of Life##22575
|goldtracker
Click Here to Sell Felweed |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Felweed |confirm |next "Start_Farming_Felweed"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Ancient Lichen",{
meta={goldtype="route",skillreq={herbalism=340},levelreq={61}},
items={{22790,32}},
maps={"Zangarmarsh"},
},[[
step
label "Start_Farming_Ancient_Lichen"
map Zangarmarsh/0
path	follow smart; ants curved; dist 20
path	82.27,44.23	79.64,39.75	79.46,36.87	81.08,33.72	83.18,34.79
path	84.92,37.43	85.23,40.76
Kill Withered enemies around this area
|tip Gather their corpses with Herbalism.
|tip These can be farmed more effectively from Slave Pens, Underbog and Steamvaults with stealth or a group.
|goldcollect Ancient Lichen##22790
|goldtracker
Click Here to Sell Ancient Lichen |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Ancient Lichen |confirm |next "Start_Farming_Ancient_Lichen"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Dreaming Glory",{
meta={goldtype="route",skillreq={herbalism=315},levelreq={63}},
items={{22786,142},{22785,64},{22575,41},{22793,9},{22794,3}},
maps={"Terokkar Forest"},
},[[
step
label "Start_Farming_Dreaming_Glory"
map Terokkar Forest/0
path follow smart; loop on; ants curved
path	31.60,45.71	32.29,42.68	32.86,38.44	32.61,35.72	34.85,34.70
path	36.60,32.54	36.98,30.09	38.61,28.59	39.20,26.76	40.64,25.10
path	41.40,22.16	43.06,19.91	43.81,17.68	43.32,15.01	43.95,12.48
path	45.94,12.75	48.58,14.35	50.45,17.02	49.36,20.09	49.79,22.32
path	50.98,24.83	53.08,25.59	55.63,25.32	58.26,25.33	59.93,23.87
path	61.12,26.59	62.13,28.15	63.46,29.60	65.02,31.32	67.13,31.63
path	69.82,31.74	69.61,35.63	68.73,39.39	69.79,42.02	70.46,45.89
path	70.51,48.71	68.94,53.17	68.11,54.89	65.38,54.27	63.87,51.31
path	61.59,50.51	59.04,49.28	56.48,46.30	53.96,42.43	54.33,38.20
path	53.25,35.66	50.24,35.67	48.92,34.53	46.58,34.04	43.68,34.49
path	40.40,35.76	38.35,36.51	36.62,38.18	36.01,39.93	36.50,42.94
path	35.72,43.53	33.66,44.98
click Dreaming Glory##181271+
|tip Gather Dreaming Glory along the path.
|goldcollect Dreaming Glory##22786
|goldcollect Felweed##22785
|goldcollect Mote of Life##22575
|goldcollect Mana Thistle##22793
|goldcollect Fel Lotus##22794
|goldtracker
Click Here to Sell Dreaming Glory |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Dreaming Glory |confirm |next "Start_Farming_Dreaming_Glory"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Nightmare Vine, Fel Lotus",{
meta={goldtype="route",skillreq={herbalism=365},levelreq={67}},
items={{22792,146},{22794,3},{22785,98},{22789,31},{22786,28}},
maps={"Shadowmoon Valley"},
},[[
step
label "Start_Farming_Fel_Lotus"
map Shadowmoon Valley/0
path	follow smart; loop on; ants curved; dist 20
path	42.51,59.05	43.42,65.13	43.35,72.41	47.71,69.62	47.32,51.73
path	51.52,59.03	51.41,66.46	56.94,73.92	61.24,68.15	57.83,57.26
path	62.03,56.22	65.24,61.52	70.61,60.71	68.51,58.02	67.94,47.22
path	72.11,47.51	71.52,40.81	66.32,39.32	58.53,45.31	49.95,33.91
path	53.12,33.55	59.63,37.35	67.13,28.91	66.02,21.82	58.01,23.62
path	55.63,16.84	52.52,15.62	52.51,21.61	45.53,15.13	42.32,38.24
path	38.31,32.18	31.21,34.61	24.92,29.64	22.04,34.71	22.04,40.81
path	29.72,47.82	27.23,52.63	31.63,53.82
click Nightmare Vine##181280+
|tip Gather Nightmare Vine along the path.
|tip Fel Lotus is gathered from any herb farmed in the Outland.
|goldcollect Nightmare Vine##22792
|goldcollect Fel Lotus##22794
|goldcollect Felweed##22785
|goldcollect Terocone##22789
|goldcollect Dreaming Glory##22786
|goldtracker
Click Here to Sell Fel Lotus |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Fel Lotus |confirm |next "Start_Farming_Fel_Lotus"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Mana Thistle",{
meta={goldtype="route",skillreq={herbalism=375},levelreq={63}},
items={{22793,69},{22786,78},{22575,15}},
maps={"Terokkar Forest","Shadowmoon Valley"},
},[[
step
label "Start_Farming_Mana_Thistle"
map Terokkar Forest/0
path	follow smart; loop on; ants curved; dist 20
path	27.11,10.51	22.10,6.50	20.21,14.21	23.90,10.50
click Mana Thistle##181281+
|tip Gather Mana Thistle along the path.
|tip Mana Thistle is a rare herb, so pick nearby herbs to make it possibly spawn.
|goldcollect Mana Thistle##22793
|goldcollect Dreaming Glory##22786
|goldcollect Mote of Life##22575
|goldtracker
Click Here to Sell Mana Thistle |confirm |next "Sell_Mana_Thistle"
'||goto Terokkar Forest/0 23.90,10.50 < 30 |noway |c |or
step
map Terokkar Forest/0
path	follow smart; loop on; ants curved; dist 20
path	62.42,73.60	65.70,79.21	68.72,85.72	72.21,88.52	74.91,87.50
path	72.31,82.01	69.31,74.60	62.41,73.60
click Mana Thistle##181281+
|tip Gather Mana Thistle along the path.
|tip Mana Thistle is a rare herb, so pick nearby herbs to make it possibly spawn.
|goldcollect Mana Thistle##22793
|goldcollect Dreaming Glory##22786
|goldcollect Mote of Life##22575
|goldtracker
Click Here to Sell Mana Thistle |confirm |next "Sell_Mana_Thistle"
'|goto Terokkar Forest/0 62.41,73.60 < 30 |noway |c |or
step
map Shadowmoon Valley/0
path	follow smart; loop on; ants curved; dist 20
path	65.81,80.63	70.21,79.12	74.31,80.80	79.20,87.53	77.51,88.40
path	74.32,88.92	71.12,88.31	68.33,87.51	70.21,83.92	72.02,85.91
path	74.60,86.41
click Mana Thistle##181281+
|tip Gather Mana Thistle along the path.
|tip Mana Thistle is a rare herb, so pick nearby herbs to make it possibly spawn.
|goldcollect Mana Thistle##22793
|goldcollect Dreaming Glory##22786
|goldcollect Mote of Life##22575
|goldtracker
Click Here to Sell Mana Thistle |confirm |next "Sell_Mana_Thistle"
'|goto Shadowmoon Valley/0 74.60,86.41 < 30 |noway |c |next "Start_Farming_Mana_Thistle" |or
step
label "Sell_Mana_Thistle"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Mana Thistle |confirm |next "Start_Farming_Mana_Thistle"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Netherbloom",{
meta={goldtype="route",skillreq={herbalism=350},levelreq={65}},
items={{22791,175},{22786,62},{22576,22},{22794,5},{22575,7}},
maps={"Netherstorm"},
},[[
step
label "Start_Farming_Netherbloom"
map Netherstorm/0
path follow smart; loop on; ants curved
path	40.24,77.20	35.96,77.64	33.57,77.45	32.69,76.46	29.37,79.43
path	26.96,78.02	25.18,76.67	22.65,76.95	21.15,76.56	20.31,74.78
path	19.80,71.91	19.08,69.17	20.47,66.62	22.14,66.23	24.65,65.10
path	27.12,60.26	25.78,57.60	24.23,55.80	25.51,54.63	28.56,54.51
path	31.15,52.38	29.62,43.63	27.59,44.60	25.41,44.20	22.98,42.42
path	23.01,39.51	24.33,37.29	25.59,34.57	28.07,36.77	29.58,40.32
path	31.85,40.98	36.24,37.50	34.06,33.89	33.35,29.83	33.90,25.46
path	35.11,23.24	35.65,19.13	37.78,16.74	39.58,16.09	42.42,14.81
path	44.23,11.72	45.11,9.32	45.88,7.67	46.97,9.19	48.22,13.84
path	50.05,15.38	50.32,17.83	53.22,17.87	55.50,17.51	55.81,20.17
path	56.92,23.83	54.87,25.87	52.51,26.14	50.65,26.43	48.19,27.46
path	47.13,31.47	47.76,34.54	49.01,37.61	54.64,32.59	56.67,31.80
path	58.36,31.54	60.65,30.28	62.49,30.31	65.43,30.84	67.85,32.79
path	68.63,35.87	70.41,36.32	72.66,35.05	73.97,35.64	73.61,37.25
path	73.81,39.22	73.42,40.88	72.18,43.37	70.07,44.56	68.89,46.88
path	66.51,48.70	64.20,50.40	61.71,50.31	59.22,50.15	57.37,48.48
path	56.39,46.25	54.77,43.82	53.12,41.66	49.55,46.57	49.57,50.00
path	50.42,52.90	51.84,54.87	53.70,56.61	56.10,56.66	57.95,57.14
path	59.94,58.21	62.03,58.25	64.36,58.34	66.65,58.84	67.89,61.91
path	66.70,65.88	64.15,67.93	62.18,68.23	61.37,64.52	60.24,63.12
path	57.94,63.05	57.36,65.05	56.29,67.80	52.89,68.59	51.27,70.71
path	51.54,75.15	54.25,76.46	57.15,77.98	59.64,78.82	62.25,79.25
path	60.11,81.86	60.14,84.60	59.80,87.70	58.69,89.60	56.55,89.08
path	54.83,88.42	52.69,86.63	50.15,86.35	48.74,85.68	46.78,84.05
path	45.54,79.03	43.73,76.27
click Netherbloom##181279+
|tip Gather Netherbloom along the path.
|goldcollect Netherbloom##22791
|goldcollect Dreaming Glory##22786
|goldcollect Mote of Mana##22576
|goldcollect Fel Lotus##22794
|goldcollect Mote of Life##22575
|goldtracker
Click Here to Sell Netherbloom |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Netherbloom |confirm |next "Start_Farming_Netherbloom"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Ragveil",{
meta={goldtype="route",skillreq={herbalism=325},levelreq={61}},
items={{22787,172},{22785,35},{22786,12},{24401,41},{13464,38},{13463,42},{22575,32}},
maps={"Zangarmarsh"},
},[[
step
label "Start_Farming_Ragveil"
map Zangarmarsh/0
path follow smart; loop on; ants curved
path	83.47,41.87	84.20,37.59	81.81,33.16	77.86,33.21	75.68,34.01
path	73.86,38.51	70.74,40.47	68.52,41.50	65.65,39.18	62.93,38.46
path	60.95,37.98	58.10,35.36	55.37,35.42	53.23,34.98	50.96,33.65
path	48.21,33.08	44.78,31.79	42.54,31.68	40.63,33.89	38.56,33.56
path	36.66,32.68	34.77,29.60	33.26,26.30	29.50,24.65	26.55,23.37
path	24.63,23.97	21.65,27.24	18.44,29.85	17.29,33.67	17.04,36.75
path	14.23,41.57	16.46,46.13	17.31,50.06	16.84,53.47	17.92,56.63
path	15.63,58.80	12.99,59.63	13.11,63.17	16.33,63.54	19.08,61.78
path	22.78,58.64	25.41,57.72	27.03,57.93	28.53,61.81	30.87,61.91
path	33.55,65.37	35.31,64.62	38.20,64.75	41.54,64.06	42.44,62.80
path	45.31,63.25	47.33,62.29	49.64,63.31	52.00,66.07	53.50,67.63
path	55.24,67.25	57.43,68.85	59.99,68.42	62.10,69.89	64.46,71.61
path	66.43,73.47	66.45,77.16	67.51,80.44	68.34,84.46	71.72,85.54
path	73.36,85.21	76.07,84.45	78.24,85.58	80.78,86.39	82.03,87.58
path	85.17,86.99	86.08,83.78	84.64,81.04	82.88,78.84	82.18,76.32
path	82.33,72.85	80.95,70.67	78.39,67.26	77.98,62.18	78.15,60.45
path	78.17,59.21	78.92,56.99	81.39,54.58	82.91,52.12	82.36,49.38
path	82.90,46.26
click Ragveil##181275+
|tip Gather Ragveil along the path.
|goldcollect Ragveil##22787
|goldcollect Felweed##22785
|goldcollect Dreaming Glory##22786
|goldcollect Unidentified Plant Parts##24401
|goldcollect Golden Sansam##13464
|goldcollect Dreamfoil##13463
|goldcollect Mote of Life##22575
|goldtracker
Click Here to Sell Ragveil |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Ragveil |confirm |next "Start_Farming_Ragveil"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Terocone",{
meta={goldtype="route",skillreq={herbalism=325},levelreq={63}},
items={{22789,181},{22785,74},{22786,19},{22575,44}},
maps={"Terokkar Forest"},
},[[
step
label "Start_Farming_Terocone"
map Terokkar Forest/0
path follow smart; loop on; ants curved
path	31.60,45.71	32.29,42.68	32.86,38.44	32.61,35.72	34.85,34.70
path	36.60,32.54	36.98,30.09	38.61,28.59	39.20,26.76	40.64,25.10
path	41.40,22.16	43.06,19.91	43.81,17.68	43.32,15.01	43.95,12.48
path	45.94,12.75	48.58,14.35	50.45,17.02	49.36,20.09	49.79,22.32
path	50.98,24.83	53.08,25.59	55.63,25.32	58.26,25.33	59.93,23.87
path	61.12,26.59	62.13,28.15	63.46,29.60	65.02,31.32	67.13,31.63
path	69.82,31.74	69.61,35.63	68.73,39.39	69.79,42.02	70.46,45.89
path	70.51,48.71	68.94,53.17	68.11,54.89	65.38,54.27	63.87,51.31
path	61.59,50.51	59.04,49.28	56.48,46.30	53.96,42.43	54.33,38.20
path	53.25,35.66	50.24,35.67	48.92,34.53	46.58,34.04	43.68,34.49
path	40.40,35.76	38.35,36.51	36.62,38.18	36.01,39.93	36.50,42.94
path	35.72,43.53	33.66,44.98
click Terocone##181277+
|tip Gather Terocone along the path.
|goldcollect 200 Terocone##22789
|goldcollect 100 Felweed##22785
|goldcollect 28 Dreaming Glory##22786
|goldcollect 52 Mote of Life##22575
|goldtracker
Click Here to Sell Terocone |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Terocone |confirm |next "Start_Farming_Terocone"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Adamantite Ore, Eternium Ore",{
meta={goldtype="route",skillreq={Mining=325},levelreq={60}},
items={{23425,196},{23427,14},{22573,96},{22574,20}},
maps={"Nagrand"},
},[[
step
label "Start_Farming_Adamantite_Ore"
map Nagrand/0
path follow smart; loop on; ants curved; dist 30
path	49.90,71.01	48.62,71.28	48.51,75.60	46.76,77.91	42.77,74.39
path	42.08,76.76	41.94,80.24	41.11,84.55	38.45,83.23	36.21,82.30
path	33.57,82.12	31.13,80.54	28.19,78.49	27.67,72.30	28.58,69.31
path	28.20,63.62	27.06,62.92	26.75,57.07	23.44,56.18	20.07,55.07
path	19.35,47.46	20.31,41.40	21.27,38.46	23.05,33.49	26.76,32.99
path	31.77,28.76	31.71,24.26	30.40,20.66	35.78,15.50	36.87,18.62
path	39.06,20.24	41.69,21.71	42.81,19.43	50.53,20.11	54.00,21.00
path	56.63,24.36	60.66,33.11	64.21,35.14	66.06,36.31	66.14,32.27
path	67.70,35.36	70.24,37.57	74.08,37.81	72.33,43.08	73.43,46.30
path	73.01,50.47	72.77,56.93	74.94,58.55	71.99,61.95	72.67,64.73
path	72.21,67.00	71.71,71.30	72.96,76.49	70.91,75.13	68.49,75.92
path	66.66,79.00	63.17,76.97	61.93,79.13	58.74,80.27	56.19,79.78
path	54.59,81.99	51.75,79.79	49.42,82.67	47.62,81.24	48.39,79.11
click Adamantite Deposit##181556+
|tip They look like light blue mineral clusters around this path.
click Rich Adamantite Deposit##181569+
|tip They look like dark blue mineral clusters around this path.
|tip Enter caves along the path.
|tip Make sure you enable "Find Minerals" in the tracking menu on the minimap.
|goldcollect Adamantite Ore##23425
|goldcollect Eternium Ore##23427
|goldcollect Mote of Earth##22573
|goldcollect Fel Iron Ore##23424
|goldcollect Mote of Fire##22574
|goldtracker
Click Here to Sell Adamantite Ore |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Adamantite Ore |confirm |next "Start_Farming_Adamantite_Ore"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Adamantite Ore, Eternium Ore, Khorium Ore",{
meta={goldtype="route",skillreq={Mining=375},levelreq={60}},
items={{23425,196},{23427,16},{22573,104},{22574,24},{23426,26}},
maps={"Nagrand"},
},[[
step
label "Start_Farming_Adamantite_Ore"
map Nagrand/0
path follow smart; loop on; ants curved; dist 30
path	49.90,71.01	48.62,71.28	48.51,75.60	46.76,77.91	42.77,74.39
path	42.08,76.76	41.94,80.24	41.11,84.55	38.45,83.23	36.21,82.30
path	33.57,82.12	31.13,80.54	28.19,78.49	27.67,72.30	28.58,69.31
path	28.20,63.62	27.06,62.92	26.75,57.07	23.44,56.18	20.07,55.07
path	19.35,47.46	20.31,41.40	21.27,38.46	23.05,33.49	26.76,32.99
path	31.77,28.76	31.71,24.26	30.40,20.66	35.78,15.50	36.87,18.62
path	39.06,20.24	41.69,21.71	42.81,19.43	50.53,20.11	54.00,21.00
path	56.63,24.36	60.66,33.11	64.21,35.14	66.06,36.31	66.14,32.27
path	67.70,35.36	70.24,37.57	74.08,37.81	72.33,43.08	73.43,46.30
path	73.01,50.47	72.77,56.93	74.94,58.55	71.99,61.95	72.67,64.73
path	72.21,67.00	71.71,71.30	72.96,76.49	70.91,75.13	68.49,75.92
path	66.66,79.00	63.17,76.97	61.93,79.13	58.74,80.27	56.19,79.78
path	54.59,81.99	51.75,79.79	49.42,82.67	47.62,81.24	48.39,79.11
click Adamantite Deposit##181556+
|tip They look like light blue mineral clusters around this path.
click Rich Adamantite Deposit##181569+
|tip They look like dark blue mineral clusters around this path.
|tip Enter caves along the path.
|tip Make sure you enable "Find Minerals" in the tracking menu on the minimap.
|goldcollect Adamantite Ore##23425
|goldcollect Eternium Ore##23427
|goldcollect Mote of Earth##22573
|goldcollect Fel Iron Ore##23424
|goldcollect Mote of Fire##22574
|goldcollect Khorium Ore##23426
|goldtracker
Click Here to Sell Adamantite Ore |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Adamantite Ore |confirm |next "Start_Farming_Adamantite_Ore"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Fel Iron Ore, Eternium Ore",{
meta={goldtype="route",skillreq={Mining=300},levelreq={60}},
items={{23424,284},{22573,64},{22574,56},{23427,4}},
maps={"Hellfire Peninsula"},
},[[
step
label "Start_Farming_Fel_Iron_Ore"
map Hellfire Peninsula/0
path	65.97,48.02	69.02,46.87	70.80,50.94	70.25,54.41	70.27,59.32
path	72.23,60.13	74.08,63.37	76.97,62.92	78.97,66.32	78.85,70.21
path	79.70,74.48	80.75,77.99	77.91,75.80	77.13,73.33	76.82,69.54
path	75.53,67.17	71.66,67.33	69.41,67.29	68.38,60.74	65.36,60.83
path	65.69,64.45	63.25,69.06	62.72,72.99	62.49,79.96	58.89,76.64
path	57.05,73.97	57.06,81.30	56.40,82.14	55.54,83.79	52.24,83.83
path	49.82,83.52	46.85,84.82	42.98,79.36	42.26,76.62	44.54,73.42
path	47.44,71.34	50.85,69.85	47.41,66.63	44.75,68.48	45.62,61.55
path	47.89,59.49	49.89,56.45	49.95,61.42	51.38,61.68	52.93,58.38
path	55.41,56.25	56.22,53.50	58.62,52.98	62.69,50.44
click Fel Iron Deposit##181555+
|tip They look like green mineral clusters around this path.
|tip Enter caves along the path.
|tip Make sure you enable "Find Minerals" in the tracking menu on the minimap.
|goldcollect Fel Iron Ore##23424
|goldcollect Mote of Earth##22573
|goldcollect Mote of Fire##22574
|goldcollect Eternium Ore##23427
|goldtracker
Click Here to Sell Fel Iron Ore |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Fel Iron Ore |confirm |next "Start_Farming_Fel_Iron_Ore"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Knothide Leather",{
meta={goldtype="route",skillreq={Skinning=335},levelreq={65}},
items={{21887,94},{25649,210}},
maps={"Netherstorm"},
},[[
step
label "Start_Farming_Knothide_Leather"
map Netherstorm/0
path follow smart; loop on; ants curved; dist 30
path	43.61,57.06	45.22,57.65	47.41,56.58	48.25,54.31	48.18,51.86
path	46.52,51.17	45.58,49.75	43.63,50.57	43.29,52.27	43.66,54.99
path	44.85,56.21
Kill enemies around this area
|tip Only non-flying Beast enemies will be skinnable.
|tip Skin their corpses.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Knothide Leather |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Knothide Leather |confirm |next "Start_Farming_Knothide_Leather"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Thick Clefthoof Leather",{
meta={goldtype="route",skillreq={Skinning=310},levelreq={62}},
items={{25708,72},{21887,72},{25649,156}},
maps={"Nagrand"},
},[[
step
label "Start_Farming_Thick_Clefthoof_Leather"
map Nagrand/0
path follow smart; loop on; ants curved; dist 30
path	44.28,26.55	43.25,29.59	45.88,33.29	47.54,38.47	50.14,51.61
path	52.51,54.52	54.09,50.75	54.25,48.06	55.98,45.01	51.01,39.01
path	50.63,31.76	46.12,27.60
Kill Clefthoof enemies around this area
|tip Skin their corpses.
|goldcollect Thick Clefthoof Leather##25708
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Thick Clefthoof Leather |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Thick Clefthoof Leather |confirm |next "Start_Farming_Thick_Clefthoof_Leather"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Fel Hide",{
meta={goldtype="route",skillreq={Skinning=335},levelreq={65}},
items={{25707,32},{21887,60},{25649,272}},
maps={"Netherstorm"},
},[[
step
label "Start_Farming_Fel_Hide"
map Netherstorm/0
path follow smart; loop on; ants curved; dist 30
path	55.33,60.50	58.09,60.46	58.98,58.47	61.66,59.15	63.22,59.54
path	65.48,61.63	66.93,63.05	63.63,64.45	61.98,62.72
kill Warp Chaser##18884+
|tip Skin their corpses.
|goldcollect Fel Hide##25707
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|tip They have a low drop rate.
|goldtracker
Click Here to Sell Fel Hide |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Fel Hide |confirm |next "Start_Farming_Fel_Hide"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Fel Scales",{
meta={goldtype="route",skillreq={Skinning=295},levelreq={58}},
items={{25700,48},{21887,90},{25649,136}},
maps={"Hellfire Peninsula"},
},[[
step
label "Start_Farming_Fel_Scales"
map Hellfire Peninsula/0
path follow smart; loop off; ants curved; dist 30
path	11.99,54.70	11.02,54.63	10.11,53.01	9.12,51.76	7.40,49.89
path	7.82,49.71	8.95,49.91	9.61,49.40	11.37,48.08	12.38,47.51
path	11.70,51.10	12.48,51.64	12.89,53.00
Kill Razorfang, Thornfang, and Quillfang enemies along the path
|tip Skin their corpses.
|goldcollect Fel Scales##25700
|tip They have a low drop rate.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Fel Scales |confirm |next "Sell_Fel_Scales"
'|goto Hellfire Peninsula/0 12.89,53.00 < 25 |c |noway |or
step
map Hellfire Peninsula/0
path follow smart; loop off; ants curved; dist 30
path	22.12,60.36	22.60,61.73	22.21,63.14	21.82,64.65	22.25,66.44
path	22.56,67.91	22.79,69.19	24.04,69.01
Kill Razorfang, Thornfang, and Quillfang enemies along the path
|tip Skin their corpses.
|goldcollect Fel Scales##25700
|tip They have a low drop rate.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Fel Scales |confirm |next "Sell_Fel_Scales"
'|goto Hellfire Peninsula/0 24.04,69.01 < 25 |c |noway |or
step
map Hellfire Peninsula/0
path follow smart; loop off; ants curved; dist 30
path	32.45,91.83	33.79,91.14	34.99,90.66	36.06,90.40	37.14,89.48
path	38.07,88.64	39.28,87.54	40.25,85.99	41.32,84.26	42.22,83.00
Kill Razorfang, Thornfang, and Quillfang enemies along the path
|tip Skin their corpses.
|goldcollect Fel Scales##25700
|tip They have a low drop rate.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Fel Scales |confirm
'|goto Hellfire Peninsula/0 42.22,83.00 < 25 |c |noway |next "Start_Farming_Fel_Scales" |or
step
label "Sell_Fel_Scales"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Fel Scales |confirm |next "Start_Farming_Fel_Scales"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Nether Dragonscale",{
meta={goldtype="route",skillreq={Skinning=330},levelreq={65}},
items={{29548,72},{21887,80},{25649,146}},
maps={"Blade's Edge Mountains"},
},[[
step
label "Start_Farming_Nether_Dragonscale"
map Blade's Edge Mountains/0
path follow smart; loop on; ants curved; dist 30
path	60.26,73.31	60.57,74.53	61.37,75.60	62.11,76.26	62.42,76.84
path	62.96,76.79	63.12,76.30	63.59,76.03	64.01,76.05	64.34,75.75
path	64.86,75.75	65.24,75.75	65.91,75.52	66.63,75.09	67.21,74.57
path	68.26,75.98	67.85,76.60	67.08,76.99	66.34,77.52	65.61,77.93
path	64.80,77.96	64.18,77.82	63.42,78.28	62.54,78.67	61.76,78.97
path	60.85,79.22	60.31,79.29	59.99,78.45	59.61,77.13	59.15,76.20
path	58.91,75.00	58.97,71.42
Kill Nether enemies around this area
|tip Skin their corpses.
|goldcollect Nether Dragonscale##29548
|tip They have a low drop rate.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Nether Dragonscales |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Nether Dragonscales |confirm |next "Start_Farming_Nether_Dragonscale"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Wind Scales",{
meta={goldtype="route",skillreq={Skinning=335},levelreq={68}},
items={{29547,39},{21887,88},{25649,188}},
maps={"Shadowmoon Valley"},
},[[
step
label "Start_Farming_Wind_Scales"
map Shadowmoon Valley/0
path follow smart; loop on; ants curved; dist 30
path	51.41,60.67	50.94,61.54	50.01,62.38	49.05,64.07	48.50,65.32
path	48.15,66.69	47.98,68.01	47.43,68.53	46.59,69.02	46.56,70.31
path	45.98,71.11	45.27,70.66	44.57,70.08	44.10,69.14	44.12,67.74
path	44.36,66.30	44.94,64.50	45.93,64.34	46.68,63.83	47.50,63.16
path	48.16,62.04	48.59,61.00	50.07,59.97
kill Eclipsion Dragonhawk##20502+
|tip Skin their corpses.
|goldcollect Wind Scales##29547
|tip They have a low drop rate.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Wind Scales |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Wind Scales |confirm |next "Start_Farming_Wind_Scales"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Gathering\\Cobra Scales",{
meta={goldtype="route",skillreq={Skinning=345},levelreq={70}},
items={{29539,12},{21887,84},{25649,141}},
maps={"Nagrand"},
},[[
step
label "Start_Farming_Cobra_Scales"
map Nagrand/0
path follow smart; loop off; ants curved; dist 30
path	18.01,38.64	19.04,37.86	19.06,36.64	19.25,35.69	20.02,35.31
path	19.99,34.69	19.56,33.70	18.80,33.09	17.97,33.44	17.51,34.01
path	15.63,34.46	14.73,34.52	14.03,35.10	13.33,35.70	12.49,36.56
path	12.49,37.51	11.91,39.12	11.00,40.08	10.15,40.92	9.39,41.92
path	8.71,42.91
kill Twilight Serpent##23026+
|tip Skin their corpses.
|tip Avoid elite enemies along the path.
|goldcollect Cobra Scales##29539
|tip They have a very low drop rate.
|goldcollect Knothide Leather##21887
|goldcollect Knothide Leather Scraps##25649
|goldtracker
Click Here to Sell Cobra Scales |confirm |next "Sell_Cobra_Scales"
'|goto Nagrand/0 8.71,42.91 < 30 |c |noway |or
step
map Nagrand/0
path follow smart; loop off; ants curved; dist 30
path	8.71,42.91	9.39,41.92	10.15,40.92	11.00,40.08	11.91,39.12
path	12.49,37.51	12.49,36.56	13.33,35.70	14.03,35.10	14.73,34.52
path	15.63,34.46	17.51,34.01	17.97,33.44	18.80,33.09	19.56,33.70
path	19.99,34.69	20.02,35.31	19.25,35.69	19.06,36.64	19.04,37.86
path	18.01,38.64
kill Twilight Serpent##23026+
|tip Skin their corpses.
|tip Avoid elite enemies along the path.
|goldcollect Cobra Scales##29539
|tip They have a low drop rate.
|goldtracker
Click Here to Sell Cobra Scales |confirm |next "Sell_Cobra_Scales"
'|goto Nagrand/0 18.01,38.64 < 30 |c |noway |next "Start_Farming_Cobra_Scales" |or
step
label "Sell_Cobra_Scales"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Cobra Scales |confirm |next "Start_Farming_Cobra_Scales"
]])
