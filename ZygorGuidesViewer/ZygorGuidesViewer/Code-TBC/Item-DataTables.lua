-- Public Code-TBC item metadata derived for the root WotLK ItemScore engine.
-- No scorer or cache is created here: Item-ItemScore.lua remains authoritative.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local ItemScore=ZGV and ZGV.ItemScore
if type(ItemScore)~="table" then return end

local keywordLabels={
  STRENGTH="Strength",AGILITY="Agility",STAMINA="Stamina",INTELLECT="Intellect",SPIRIT="Spirit",
  ARMOR="Armor",ARMOR_PENETRATION_RATING="Armor Penetration",ATTACK_POWER="Attack Power",
  BLOCK_RATING="Block",BLOCK_VALUE="Block Value",CRIT_RATING="Critical Strike",DEFENSE_SKILL_RATING="Defense",
  DODGE_RATING="Dodge",EXPERTISE_RATING="Expertise",HASTE_RATING="Haste",HIT_RATING="Hit",
  MANA_REGENERATION="Mana Regeneration",PARRY_RATING="Parry",RANGED_ATTACK_POWER="Ranged Attack Power",
  SPELL_PENETRATION="Spell Penetration",SPELL_POWER="Spell Power",DAMAGE_PER_SECOND="Damage Per Second",
}

if type(ItemScore.Keywords)~="table" then
  ItemScore.Keywords={}
  for key,label in pairs(keywordLabels) do
    ItemScore.Keywords[#ItemScore.Keywords+1]={blizz=key,zgvdisplay=label}
  end
  table.sort(ItemScore.Keywords,function(left,right) return left.blizz<right.blizz end)
end
ItemScore.KnownKeyWords=ItemScore.KnownKeyWords or {}
for _,entry in ipairs(ItemScore.Keywords) do
  ItemScore.KnownKeyWords[entry.blizz]=ItemScore.KnownKeyWords[entry.blizz] or entry.zgvdisplay
end

ItemScore.ProtectedGear=ItemScore.ProtectedGear or {}
ItemScore.Unique_Equipped_Families=ItemScore.Unique_Equipped_Families or {}
ItemScore.FixedLevelHeirloom=ItemScore.FixedLevelHeirloom or {}
ItemScore.HeirloomBonuses=ItemScore.HeirloomBonuses or {}
ItemScore.GemStatsByExp=ItemScore.GemStatsByExp or {}
ItemScore.GemData=ItemScore.GemData or {}

ItemScore.Item_Weapon_Types=ItemScore.Item_Weapon_Types or {
  [0]="AXE",[1]="TH_AXE",[2]="BOW",[3]="GUN",[4]="MACE",[5]="TH_MACE",[6]="TH_POLE",
  [7]="SWORD",[8]="TH_SWORD",[9]="WARGLAIVE",[10]="TH_STAFF",[11]="DRUID_BEAR",[12]="DRUID_CAT",
  [13]="FIST",[14]="MISCWEAP",[15]="DAGGER",[16]="THROWN",[17]="SPEAR",
  [18]="CROSSBOW",[19]="WAND",[20]="FISHPOLE",
}
ItemScore.Item_Weapon_RangedTypes=ItemScore.Item_Weapon_RangedTypes or {
  [2]="BOW",[3]="GUN",[16]="THROWN",[18]="CROSSBOW",[19]="WAND",
}
ItemScore.Item_Armor_Types=ItemScore.Item_Armor_Types or {
  [0]="JEWELERY",[1]="CLOTH",[2]="LEATHER",[3]="MAIL",[4]="PLATE",[5]="COSMETIC",[6]="SHIELD",
}

local slot={
  main=_G.INVSLOT_MAINHAND or 16,off=_G.INVSLOT_OFFHAND or 17,ranged=_G.INVSLOT_RANGED or 18,
  head=_G.INVSLOT_HEAD or 1,neck=_G.INVSLOT_NECK or 2,shoulder=_G.INVSLOT_SHOULDER or 3,
  back=_G.INVSLOT_BACK or 15,chest=_G.INVSLOT_CHEST or 5,wrist=_G.INVSLOT_WRIST or 9,
  hand=_G.INVSLOT_HAND or 10,waist=_G.INVSLOT_WAIST or 6,legs=_G.INVSLOT_LEGS or 7,
  feet=_G.INVSLOT_FEET or 8,finger=_G.INVSLOT_FINGER1 or 11,trinket=_G.INVSLOT_TRINKET1 or 13,
}
ItemScore.TypeToSlot=ItemScore.TypeToSlot or {
  INVTYPE_WEAPON=slot.main,INVTYPE_WEAPONMAINHAND=slot.main,INVTYPE_2HWEAPON=slot.main,
  INVTYPE_WEAPONOFFHAND=slot.off,INVTYPE_SHIELD=slot.off,INVTYPE_HOLDABLE=slot.off,
  INVTYPE_THROWN=slot.ranged,INVTYPE_RANGED=slot.ranged,INVTYPE_RANGEDRIGHT=slot.ranged,INVTYPE_RELIC=slot.ranged,
  INVTYPE_HEAD=slot.head,INVTYPE_NECK=slot.neck,INVTYPE_SHOULDER=slot.shoulder,INVTYPE_CLOAK=slot.back,
  INVTYPE_CHEST=slot.chest,INVTYPE_ROBE=slot.chest,INVTYPE_WRIST=slot.wrist,INVTYPE_HAND=slot.hand,
  INVTYPE_WAIST=slot.waist,INVTYPE_LEGS=slot.legs,INVTYPE_FEET=slot.feet,
  INVTYPE_FINGER=slot.finger,INVTYPE_TRINKET=slot.trinket,
}

ItemScore.SkillNames=ItemScore.SkillNames or {
  DUALWIELD="Dual Wield",AXE="Axes",TH_AXE="Two-Handed Axes",BOW="Bows",CROSSBOW="Crossbows",
  DAGGER="Daggers",FIST="Fist Weapons",GUN="Guns",MACE="Maces",TH_MACE="Two-Handed Maces",
  TH_POLE="Polearms",TH_STAFF="Staves",SWORD="Swords",TH_SWORD="Two-Handed Swords",
  THROWN="Thrown",WAND="Wands",CLOTH="Cloth",LEATHER="Leather",MAIL="Mail",PLATE="Plate Mail",SHIELD="Shield",
}
ItemScore.SkillNamesRev=ItemScore.SkillNamesRev or {}
for key,name in pairs(ItemScore.SkillNames) do ItemScore.SkillNamesRev[name]=ItemScore.SkillNamesRev[name] or key end
ItemScore.SkillNamesByID=ItemScore.SkillNamesByID or {}
local skillIDs={
  DUALWIELD=118,AXE=44,TH_AXE=172,BOW=45,CROSSBOW=226,DAGGER=173,FIST=473,GUN=46,
  MACE=54,TH_MACE=160,TH_POLE=229,TH_STAFF=136,SWORD=43,TH_SWORD=55,THROWN=176,WAND=228,
  CLOTH=415,LEATHER=414,MAIL=413,PLATE=293,SHIELD=433,
}
for key,id in pairs(skillIDs) do ItemScore.SkillNamesByID[id]=ItemScore.SkillNamesByID[id] or key end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.ItemDataTables=ItemScore
