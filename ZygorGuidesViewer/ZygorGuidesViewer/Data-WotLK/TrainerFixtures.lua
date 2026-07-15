-- WotLK trainer metadata used to identify every supported class and skill
-- line.  Spell ranks, prices, and availability are deliberately read from the
-- live 3.3.5 trainer window (the server is authoritative for those values).
local ZGV=ZygorGuidesViewer
if not ZGV then return end

ZGV.TrainerFixtures={
  classTokens={"DEATHKNIGHT","DRUID","HUNTER","MAGE","PALADIN","PRIEST","ROGUE","SHAMAN","WARLOCK","WARRIOR"},
  professionLines={
    {id=171,name="Alchemy"},{id=164,name="Blacksmithing"},{id=185,name="Cooking"},
    {id=333,name="Enchanting"},{id=202,name="Engineering"},{id=356,name="Fishing"},
    {id=182,name="Herbalism"},{id=773,name="Inscription"},{id=755,name="Jewelcrafting"},
    {id=165,name="Leatherworking"},{id=186,name="Mining"},{id=393,name="Skinning"},
    {id=197,name="Tailoring"},{id=129,name="First Aid"},
  },
  ranks={
    {name="Apprentice",cap=75},{name="Journeyman",cap=150},{name="Expert",cap=225},
    {name="Artisan",cap=300},{name="Master",cap=375},{name="Grand Master",cap=450},
  },
}
