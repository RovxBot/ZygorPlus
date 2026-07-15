ZGV.Gold.guides_loaded=true
if ZGV:DoMutex("GoldFarmC") then return end
ZygorGuidesViewer.GuideMenuTier = "CLA"
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Clefthoof Meat",{
meta={goldtype="route",levelreq={63}},
items={{27678,132}},
maps={"Nagrand"},
},[[
step
label "Start_Farming_Clefthoof_Meat"
map Nagrand/0
path follow smart; loop on; ants curved; dist 30
path	58.45,67.47	59.46,65.82	59.28,64.08	58.44,62.74	58.67,61.45
path	59.38,59.90	60.48,59.79	62.75,57.86	61.61,56.14	61.66,52.97
path	60.11,50.39	60.05,49.15	60.95,47.36	62.22,43.24	62.00,41.81
path	61.69,39.46	64.80,41.04	66.76,40.95	68.57,40.24	70.65,40.99
path	71.34,41.19	72.39,41.99	72.38,43.99	71.76,44.60	71.09,45.01
path	70.33,46.05	70.04,47.30	69.80,48.58	69.83,49.92	69.28,51.30
path	69.39,53.83	69.19,55.50	69.64,57.19	70.39,58.90	70.22,61.14
path	69.42,62.04	68.09,61.87	66.96,62.66	66.80,63.77	67.01,64.56
path	67.27,67.06	67.34,69.40	67.04,70.88	66.79,72.54	66.80,73.78
path	66.50,75.31	65.60,75.46	64.52,75.39	63.35,74.82	62.19,74.59
path	61.40,74.21	60.51,72.36	59.17,71.67	58.46,69.38
Kill Clefthoof enemies around this area
|goldcollect Clefthoof Meat##27678
|goldtracker
Click Here to Sell Clefthoof Meat |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Clefthoof Meat |confirm |next "Start_Farming_Clefthoof_Meat"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Ravager Flesh",{
meta={goldtype="route",levelreq={58}},
items={{27674,124}},
maps={"Hellfire Peninsula"},
},[[
step
label "Start_Farming_Ravager_Flesh"
map Hellfire Peninsula/0
path follow smart; loop off; ants curved; dist 30
path	11.99,54.70	11.02,54.63	10.11,53.01	9.12,51.76	7.40,49.89
path	7.82,49.71	8.95,49.91	9.61,49.40	11.37,48.08	12.38,47.51
path	11.70,51.10	12.48,51.64	12.89,53.00
Kill Razorfang, Thornfang, and Quillfang enemies along the path
|goldcollect Ravager Flesh##27674
|goldtracker
Click Here to Sell Ravager Flesh |confirm |next "Sell_Ravager_Flesh"
'|goto Hellfire Peninsula/0 12.89,53.00 < 25 |c |noway |or
step
map Hellfire Peninsula/0
path follow smart; loop off; ants curved; dist 30
path	22.12,60.36	22.60,61.73	22.21,63.14	21.82,64.65	22.25,66.44
path	22.56,67.91	22.79,69.19	24.04,69.01
Kill Razorfang, Thornfang, and Quillfang enemies along the path
|goldcollect Ravager Flesh##27674
|goldtracker
Click Here to Sell Ravager Flesh |confirm |next "Sell_Ravager_Flesh"
'|goto Hellfire Peninsula/0 24.04,69.01 < 25 |c |noway |or
step
map Hellfire Peninsula/0
path follow smart; loop off; ants curved; dist 30
path	32.45,91.83	33.79,91.14	34.99,90.66	36.06,90.40	37.14,89.48
path	38.07,88.64	39.28,87.54	40.25,85.99	41.32,84.26	42.22,83.00
Kill Razorfang, Thornfang, and Quillfang enemies along the path
|goldcollect Ravager Flesh##27674
|goldtracker
Click Here to Sell Ravager Flesh |confirm
'|goto Hellfire Peninsula/0 42.22,83.00 < 25 |c |noway |next "Start_Farming_Ravager_Flesh" |or
step
label "Sell_Ravager_Flesh"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Ravager Flesh |confirm |next "Start_Farming_Ravager_Flesh"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Bat Flesh, Crunchy Spider Leg",{
meta={goldtype="route",levelreq={15}},
items={{27669,96},{22644,91}},
maps={"Ghostlands"},
},[[
step
label "Start_Farming_Bat_Flesh"
map Ghostlands/0
path follow smart; loop on; ants curved; dist 30
path	40.53,66.35	40.83,70.18	40.57,72.68	38.84,72.10	37.18,69.79
path	34.71,68.90	33.08,66.46	32.19,64.27	34.19,62.61	33.92,58.51
path	31.76,53.44	29.94,52.32	29.11,52.58	28.13,52.99	26.72,52.73
path	25.32,51.78	24.85,49.40	25.12,46.91	24.62,44.93	24.38,43.25
path	24.48,41.68	24.29,39.91	25.65,39.62	27.34,38.74	27.99,39.65
path	28.81,41.11	29.73,39.07	30.40,36.94	31.25,36.31	32.28,38.14
path	33.83,38.87	35.33,40.52	37.74,41.01	40.04,41.51	41.88,41.97
path	43.87,43.04	45.57,44.20	45.96,45.70	45.18,47.38	44.27,50.14
path	44.68,51.59	43.91,55.55	43.46,58.84	43.22,62.21	42.62,65.23
Kill Bat and Spindleweb enemies along the path
|goldcollect Bat Flesh##27669
|goldcollect Crunchy Spider Leg##22644
|goldtracker
Click Here to Sell Materials |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Materials |confirm |next "Start_Farming_Bat_Flesh"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Bear Flank",{
meta={goldtype="route",levelreq={48}},
items={{35562,52}},
maps={"Western Plaguelands"},
},[[
step
label "Start_Farming_Bear_Flank"
map Western Plaguelands/0
path follow smart; loop on; ants curved; dist 30
path	36.80,66.75	35.58,66.64	34.26,65.87	33.43,64.40	32.63,62.94
path	31.98,62.09	30.91,61.07	30.26,59.86	30.13,58.83	30.62,57.41
path	31.20,56.87	32.04,57.09	32.93,57.52	33.71,58.12	34.33,59.41
path	34.32,60.78	34.13,61.80	34.90,62.71	35.63,63.27	36.53,64.01
path	37.07,64.94	37.16,66.00	36.78,67.39	36.27,67.25	35.42,66.33
Kill Black Bear enemies around this area
|goldcollect Bear Flank##35562
|goldtracker
Click Here to Sell Bear Flanks |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Bear Flanks |confirm |next "Start_Farming_Bear_Flank"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Buzzard Meat",{
meta={goldtype="route",levelreq={60}},
items={{27671,114}},
maps={"Hellfire Peninsula"},
},[[
step
label "Start_Farming_Buzzard_Meat"
Kill Bonestripper enemies around this area
|goldcollect Buzzard Meat##27671 |goto Hellfire Peninsula/0 61.91,67.95
|goldtracker
You can find more around:
[Hellfire Peninsula/0 29.16,54.47]
[Hellfire Peninsula/0 20.70,52.31]
[Hellfire Peninsula/0 24.86,45.43]
[Hellfire Peninsula/0 31.72,35.43]
Click Here to Sell Buzzard Meat |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Buzzard Meat |confirm |next "Start_Farming_Buzzard_Meat"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Chunk o' Basilisk",{
meta={goldtype="route",levelreq={62}},
items={{27677,164}},
maps={"Zangarmarsh"},
},[[
step
label "Start_Farming_Chunk_o_Basilisk"
map Zangarmarsh/0
path follow smart; loop off; ants curved; dist 30
path	74.34,28.90	76.41,29.92	78.43,29.84	80.62,29.39	82.47,28.94
path	84.11,28.57	85.76,28.36	87.19,27.88	87.92,29.78	87.92,33.15
path	88.03,36.74
Kill Marshrock enemies around this area
|goldcollect Chunk o' Basilisk##27677
|goldtracker
Click Here to Sell Chunks o' Basilisk |confirm |next "Sell_Chunk_o_Basilisk"
'|goto Zangarmarsh/0 88.03,36.74 < 30 |c |noway |or
step
map Zangarmarsh/0
path follow smart; loop off; ants curved; dist 30
path	88.03,36.74	87.92,33.15	87.92,29.78	87.19,27.88	85.76,28.36
path	84.11,28.57	82.47,28.94	80.62,29.39	78.43,29.84	76.41,29.92
path	74.34,28.90
Kill Marshrock enemies around this area
|goldcollect Chunk o' Basilisk##27677
|goldtracker
Click Here to Sell Chunks o' Basilisk |confirm |next "Sell_Chunk_o_Basilisk"
'|goto Zangarmarsh/0 74.34,28.90 < 30 |c |noway |next "Start_Farming_Chunk_o_Basilisk" |or
step
label "Sell_Chunk_o_Basilisk"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Chunks o' Basilisk |confirm |next "Start_Farming_Chunk_o_Basilisk"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Netherweave Cloth, Jaggal Clam Meat, Jaggal Pearl, Fish Oil, Shiny Fish Scales, Unidentified Plant Parts",{
meta={goldtype="route",levelreq={62}},
items={{21877,202},{24477,98},{24478,8},{17058,88},{17057,72},{24401,78}},
maps={"Zangarmarsh"},
},[[
step
label "Start_Farming_Jaggal_Clam_Meat"
Kill Bloodscale enemies around this area
collect Jaggal Clam##24476 |n
|tip The best place for these is farming The Slave Pens dungeon.
use Jaggal Clam##24476
|goldcollect Netherweave Cloth##21877 |goto Zangarmarsh/0 26.92,39.35
|goldcollect Jaggal Clam Meat##24477 |goto Zangarmarsh/0 26.92,39.35
|goldcollect Jaggal Pearl##24478 |goto Zangarmarsh/0 26.92,39.35
|goldcollect Fish Oil##17058 |goto Zangarmarsh/0 26.92,39.35
|goldcollect Shiny Fish Scales##17057 |goto Zangarmarsh/0 26.92,39.35
|goldcollect Unidentified Plant Parts##24401 |goto Zangarmarsh/0 26.92,39.35
|goldtracker
Click Here to Sell Materials |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Materials |confirm |next "Start_Farming_Jaggal_Clam_Meat"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Raptor Ribs",{
meta={goldtype="route",levelreq={64}},
items={{31670,92}},
maps={"Blade's Edge Mountains"},
},[[
step
label "Start_Farming_Raptor_Ribs"
map Blade's Edge Mountains/0
path follow smart; loop off; ants curved; dist 30
path	75.24,23.15	73.88,24.99	73.46,26.32	72.65,27.28	71.85,29.01
path	71.31,31.09	71.04,33.60	71.15,35.63	71.35,37.49	71.18,40.71
path	70.78,43.76	69.47,45.25	68.05,47.25	67.84,47.58	66.49,49.20
path	64.96,50.60	63.68,51.31	63.78,52.45	64.64,54.36	65.43,55.15
path	66.46,56.39	67.08,57.74	67.78,59.22	68.25,61.91	68.35,63.37
path	68.81,64.87	68.53,65.95	68.51,69.49
Kill Daggermaw and Lashtail enemies around this area
|goldcollect Raptor Ribs##31670 |or
|goldtracker |or
Click Here to Sell Raptor Ribs |confirm |next "Sell_Raptor_Ribs" |or
'|goto Blade's Edge Mountains/0 68.51,69.49 < 30 |c |noway |or
step
map Blade's Edge Mountains/0
path follow smart; loop off; ants curved; dist 30
path	68.51,69.49	68.53,65.95	68.81,64.87	68.35,63.37	68.25,61.91
path	67.78,59.22	67.08,57.74	66.46,56.39	65.43,55.15	64.64,54.36
path	63.78,52.45	63.68,51.31	64.96,50.60	66.49,49.20	67.84,47.58
path	68.05,47.25	69.47,45.25	70.78,43.76	71.18,40.71	71.35,37.49
path	71.15,35.63	71.04,33.60	71.31,31.09	71.85,29.01	72.65,27.28
path	73.46,26.32	73.88,24.99	75.24,23.15
Kill Daggermaw and Lashtail enemies around this area
|goldcollect Raptor Ribs##31670 |or
|goldtracker |or
Click Here to Sell Raptor Ribs |confirm |next "Sell_Raptor_Ribs" |or
'|goto Blade's Edge Mountains/0 75.24,23.15 < 30 |c |noway |next "Start_Farming_Raptor_Ribs" |or
step
label "Sell_Raptor_Ribs"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Raptor Ribs |confirm |next "Start_Farming_Raptor_Ribs"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Serpent Flesh",{
meta={goldtype="route",levelreq={64}},
items={{31671,46}},
maps={"Blade's Edge Mountains"},
},[[
step
label "Start_Farming_Serpent_Flesh"
map Blade's Edge Mountains/0
path follow smart; loop off; ants curved; dist 30
path	75.24,23.15	73.88,24.99	73.46,26.32	72.65,27.28	71.85,29.01
path	71.31,31.09	71.04,33.60	71.15,35.63	71.35,37.49	71.18,40.71
path	70.78,43.76	69.47,45.25	68.05,47.25	67.84,47.58	66.49,49.20
path	64.96,50.60	63.68,51.31	63.78,52.45	64.64,54.36	65.43,55.15
path	66.46,56.39	67.08,57.74	67.78,59.22	68.25,61.91	68.35,63.37
path	68.81,64.87	68.53,65.95	68.51,69.49
Kill Scalewing enemies around this area
|goldcollect Serpent Flesh##31671 |or
|goldtracker |or
Click Here to Sell Serpent Flesh |confirm |next "Sell_Serpent_Flesh" |or
'|goto Blade's Edge Mountains/0 68.51,69.49 < 30 |c |noway |or
step
map Blade's Edge Mountains/0
path follow smart; loop off; ants curved; dist 30
path	68.51,69.49	68.53,65.95	68.81,64.87	68.35,63.37	68.25,61.91
path	67.78,59.22	67.08,57.74	66.46,56.39	65.43,55.15	64.64,54.36
path	63.78,52.45	63.68,51.31	64.96,50.60	66.49,49.20	67.84,47.58
path	68.05,47.25	69.47,45.25	70.78,43.76	71.18,40.71	71.35,37.49
path	71.15,35.63	71.04,33.60	71.31,31.09	71.85,29.01	72.65,27.28
path	73.46,26.32	73.88,24.99	75.24,23.15
Kill Scalewing enemies around this area
|goldcollect Serpent Flesh##31671 |or
|goldtracker |or
Click Here to Sell Serpent Flesh |confirm |next "Sell_Serpent_Flesh" |or
'|goto Blade's Edge Mountains/0 75.24,23.15 < 30 |c |noway |next "Start_Farming_Serpent_Flesh" |or
step
label "Sell_Serpent_Flesh"
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Serpent Flesh |confirm |next "Start_Farming_Serpent_Flesh"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Talbuk Venison",{
meta={goldtype="route",levelreq={63}},
items={{27682,141}},
maps={"Nagrand"},
},[[
step
label "Start_Farming_Talbuk_Venison"
map Nagrand/0
path follow smart; loop on; ants curved; dist 30
path	58.45,67.47	59.46,65.82	59.28,64.08	58.44,62.74	58.67,61.45
path	59.38,59.90	60.48,59.79	62.75,57.86	61.61,56.14	61.66,52.97
path	60.11,50.39	60.05,49.15	60.95,47.36	62.22,43.24	62.00,41.81
path	61.69,39.46	64.80,41.04	66.76,40.95	68.57,40.24	70.65,40.99
path	71.34,41.19	72.39,41.99	72.38,43.99	71.76,44.60	71.09,45.01
path	70.33,46.05	70.04,47.30	69.80,48.58	69.83,49.92	69.28,51.30
path	69.39,53.83	69.19,55.50	69.64,57.19	70.39,58.90	70.22,61.14
path	69.42,62.04	68.09,61.87	66.96,62.66	66.80,63.77	67.01,64.56
path	67.27,67.06	67.34,69.40	67.04,70.88	66.79,72.54	66.80,73.78
path	66.50,75.31	65.60,75.46	64.52,75.39	63.35,74.82	62.19,74.59
path	61.40,74.21	60.51,72.36	59.17,71.67	58.46,69.38
Kill Talbuk enemies around this area
|goldcollect Talbuk Venison##27682
|goldtracker
Click Here to Sell Talbuk Venison |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Talbuk Venison |confirm |next "Start_Farming_Talbuk_Venison"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Warped Flesh",{
meta={goldtype="route",levelreq={62}},
items={{27681,104}},
maps={"Terokkar Forest"},
},[[
step
label "Start_Farming_Warped_Flesh"
map Terokkar Forest/0
path follow smart; loop on; ants curved; dist 30
path	59.59,49.54	59.65,48.37	59.41,47.25	58.99,46.28	58.50,45.39
path	57.90,44.76	57.18,43.95	56.84,43.13	56.14,42.55	55.56,41.51
path	55.48,40.53	55.57,39.33	55.32,38.38	55.25,37.11	55.19,35.86
path	55.41,34.98	55.94,34.37	56.30,33.13	57.61,32.39	58.54,31.61
path	59.68,31.15	60.97,30.39	62.24,30.51	63.31,31.03	64.49,31.48
path	65.61,32.16	66.88,32.68	68.19,33.22	68.50,34.23	68.02,35.84
path	66.65,35.82	65.98,36.47	64.64,35.75	62.90,35.26	62.08,35.51
path	61.30,36.73	60.98,38.58	60.84,40.23	61.19,41.87	61.17,43.04
path	60.95,45.16	60.68,46.73	59.72,48.94
kill Warp Stalker##18464+
|tip They will periodically go invisible for a brief period of time.
|goldcollect Warped Flesh##27681
|goldtracker
Click Here to Sell Warped Flesh |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Warped Flesh |confirm |next "Start_Farming_Warped_Flesh"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Strange Spores, Fertile Spores, Unidentified Plant Parts",{
meta={goldtype="route",levelreq={62}},
items={{27676,104},{24449,84},{24401,64}},
maps={"Zangarmarsh"},
},[[
step
label "Start_Farming_Strange_Spores"
map Zangarmarsh/0
path follow smart; loop on; ants curved; dist 30
path	24.68,19.60	24.27,21.11	24.58,22.87	23.82,24.56	23.41,25.90
path	22.15,26.32	21.60,27.69	21.15,29.84	20.42,31.99	19.76,33.52
path	19.05,35.92	17.80,37.43	17.03,38.40	16.25,39.71	15.61,41.17
path	15.83,43.73	16.50,45.80	17.54,47.38	17.92,48.48	19.37,50.63
path	20.86,52.30	21.67,53.32	22.26,54.62	21.88,56.22	20.80,57.68
path	19.55,58.15	18.02,57.33	17.39,57.71	16.31,57.45	14.44,57.45
path	12.19,57.04	11.76,56.66	10.82,54.91	9.79,52.11	10.09,48.34
path	11.30,44.83	13.25,42.72	13.96,39.92	15.16,38.32	16.23,35.68
path	16.43,33.10	16.46,30.82	16.45,29.63	17.28,28.04	17.15,26.34
path	15.87,26.15	15.41,24.00	15.80,21.84	16.06,19.31	16.88,17.10
path	18.57,17.31
kill Greater Sporebat##18129+
kill Marsh Walker##18135+
|goldcollect Strange Spores##27676
|goldcollect Fertile Spores##24449
|goldcollect Unidentified Plant Parts##24401
|goldtracker
Click Here to Sell Strange Spores |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Strange Spores |confirm |next "Start_Farming_Strange_Spores"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Moongraze Stag Tenderloin",{
meta={goldtype="route",levelreq={4}},
items={{23676,330}},
maps={"Azuremyst Isle"},
},[[
step
label "Start_Farming_Moongraze_Stag_Tenderloin"
map Azuremyst Isle/0
path follow smart; loop on; ants curved; dist 30
path	55.31,50.08	55.15,51.44	56.78,55.40	57.55,57.15	57.91,59.56
path	56.39,61.11	54.11,62.47	52.98,63.99	52.13,62.82	51.40,61.14
path	50.34,59.58	48.99,59.01	47.55,57.68	46.61,56.91	45.43,56.92
path	45.54,58.37	45.73,60.95	45.82,62.01	45.59,63.99	45.22,65.99
path	44.26,66.95	42.74,67.69	41.90,69.19	40.50,70.23	40.38,67.23
path	40.28,63.98	40.34,60.36	40.63,58.14	39.31,56.95	37.83,56.34
path	36.83,56.83	35.68,58.36	34.57,58.61	34.40,59.69	32.85,60.18
path	31.55,60.50	28.63,59.88	28.19,56.95	29.24,54.16	29.98,52.40
path	31.14,50.56	32.71,50.63	33.49,53.02	34.03,55.80	34.94,56.58
path	36.39,55.04	37.08,54.22	38.74,53.14	38.95,52.25	39.83,50.04
path	41.10,48.48	42.19,46.43	43.86,44.15	44.39,41.75	45.66,39.56
path	47.40,38.46	49.32,35.97	50.40,35.47	53.31,36.27	55.86,38.52
path	57.82,39.79	58.17,42.94	56.97,45.43	56.65,48.29
Kill Moongraze enemies along the path
|goldcollect Moongraze Stag Tenderloin##23676
|goldtracker
Click Here to Sell Moongraze Stag Tenderloins |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Moongraze Stag Tenderloins |confirm |next "Start_Farming_Moongraze_Stag_Tenderloin"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Lynx Meat",{
meta={goldtype="route",levelreq={4}},
items={{27668,164}},
maps={"Eversong Woods"},
},[[
step
label "Start_Farming_Lynx_Meat"
map Eversong Woods/0
path follow smart; loop on; ants curved; dist 30
path	42.67,69.53	41.06,70.55	39.80,71.87	39.25,73.69	38.26,74.58
path	37.21,73.96	36.11,73.59	34.88,74.11	33.88,74.18	32.70,72.35
path	31.06,72.01	28.80,70.59	27.27,67.95	26.86,63.75	27.18,59.79
path	28.22,57.16	29.35,55.95	30.26,54.48	31.44,53.09	32.81,54.10
path	34.06,55.12	35.19,55.45	36.83,56.78	37.47,58.98	36.31,61.65
path	37.08,63.47	38.40,63.76	39.78,63.68	41.04,62.25	42.82,61.82
path	44.44,62.83	45.33,62.77	45.90,62.43	46.67,63.06	46.37,64.50
path	46.20,66.14	46.46,67.55	45.63,68.10	44.47,67.36	43.92,69.23
kill Springpaw Stalker##15651+
|goldcollect Lynx Meat##27668
|goldtracker
Click Here to Sell Lynx Meat |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Lynx Meat |confirm |next "Start_Farming_Lynx_Meat"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Sunfury Signet, Arcane Tome, Netherweave Cloth",{
meta={goldtype="route",levelreq={70}},
items={{30810,100},{29739,12},{21877,236}},
maps={"Shadowmoon Valley"},
},[[
step
label "Start_Farming_Sunfury_Signets"
Kill Eclipsion enemies around this area
|tip Sunfury Signets and Arcane Tomes can also be farmed in The Mechanar, The Arcatraz, and The Botanica dungeons.
|goldcollect Sunfury Signet##30810 |goto Shadowmoon Valley/0 46.36,68.84
|goldcollect Arcane Tome##29739 |goto Shadowmoon Valley/0 46.36,68.84
|goldcollect Netherweave Cloth##21877 |goto Shadowmoon Valley/0 46.36,68.84
|goldtracker
Click Here to Sell Materials |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Materials |confirm |next "Start_Farming_Sunfury_Signets"
]])
ZygorGuidesViewer:RegisterGuide("GOLD\\Farming\\Mark of Kil'jaeden, Fel Armament, Netherweave Cloth, Mote of Shadow",{
meta={goldtype="route",levelreq={70}},
items={{30809,104},{29740,12},{21877,188},{22577,86}},
maps={"Blade's Edge Mountains"},
},[[
step
label "Start_Farming_Fel_Armaments"
Kill Death enemies around this area
|tip Mark of Sargeras and Fel Armaments can also be farmed in The Mechanar, The Arcatraz, and the Shadow Labyrinth dungeons.
|goldcollect Mark of Sargeras##30809 |goto Blade's Edge Mountains/0 64.03,67.14
|goldcollect Fel Armament##29740 |goto Blade's Edge Mountains/0 64.03,67.14
|goldcollect Netherweave Cloth##21877 |goto Blade's Edge Mountains/0 64.03,67.14
|goldcollect Mote of Shadow##22577 |goto Blade's Edge Mountains/0 64.03,67.14
|goldtracker
Click Here to Sell Materials |confirm
step
talk Auctioneer Thathung##8673 |goto Orgrimmar/0 55.69,62.85 |only if Horde
talk Auctioneer Redmuse##8720 |goto Ironforge/0 24.25,74.54 |only if Alliance
|tip List the items you want to sell on the Auction House.
|tip
_Want to Farm More?_
Click Here to Farm Materials |confirm |next "Start_Farming_Fel_Armaments"
]])
