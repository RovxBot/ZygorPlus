-- Anniversary facade for the loaded WotLK reputation service.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local Faction=ZGV and ZGV.Faction
if type(Faction)~="table" then return end

-- Kept for debugging tools which inspected the Code-TBC table directly.
-- Reputation reads and updates remain owned by Faction.lua.
Faction.ReputationTypes=Faction.ReputationTypes or {
  faction={standings={
    {name="Hated",from=0,color="880000"},{name="Hostile",from=10000,color="ff0000"},
    {name="Unfriendly",from=20000,color="ff8800"},{name="Neutral",from=20000,color="ffff00"},
    {name="Friendly",from=20000,color="00ff00"},{name="Honored",from=20000,color="00ff88"},
    {name="Revered",from=20000,color="00ffff"},{name="Exalted",from=20000,color="cc88ff"},
  }},
}

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.Faction=Faction
