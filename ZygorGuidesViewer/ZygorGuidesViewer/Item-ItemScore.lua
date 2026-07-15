-- WotLK (3.3.5a) item evaluator.  The historic Gear Finder data files load
-- into ItemScore.Items, so keep this public contract even when a client has
-- not cached an item yet.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local ItemScore=ZGV:RegisterModule("ItemScore",{Items={},ItemCache={},Logs={}})
ZGV.ItemScore=ItemScore

local WOTLK_MAX_LEVEL=80
local slots={
  INVTYPE_HEAD={"HeadSlot"}, INVTYPE_NECK={"NeckSlot"}, INVTYPE_SHOULDER={"ShoulderSlot"},
  INVTYPE_CLOAK={"BackSlot"}, INVTYPE_CHEST={"ChestSlot"}, INVTYPE_ROBE={"ChestSlot"},
  INVTYPE_WRIST={"WristSlot"}, INVTYPE_HAND={"HandsSlot"}, INVTYPE_WAIST={"WaistSlot"},
  INVTYPE_LEGS={"LegsSlot"}, INVTYPE_FEET={"FeetSlot"}, INVTYPE_FINGER={"Finger0Slot","Finger1Slot"},
  INVTYPE_TRINKET={"Trinket0Slot","Trinket1Slot"}, INVTYPE_WEAPON={"MainHandSlot","SecondaryHandSlot"},
  INVTYPE_2HWEAPON={"MainHandSlot"}, INVTYPE_WEAPONMAINHAND={"MainHandSlot"},
  INVTYPE_WEAPONOFFHAND={"SecondaryHandSlot"}, INVTYPE_SHIELD={"SecondaryHandSlot"},
  INVTYPE_HOLDABLE={"SecondaryHandSlot"}, INVTYPE_RANGED={"RangedSlot"},
  INVTYPE_RANGEDRIGHT={"RangedSlot"}, INVTYPE_RELIC={"RangedSlot"},
}
ItemScore.possEquipSlots={}
for equipLocation in pairs(slots) do ItemScore.possEquipSlots[equipLocation]=true end

local accessory={INVTYPE_NECK=true,INVTYPE_CLOAK=true,INVTYPE_FINGER=true,INVTYPE_TRINKET=true}

-- Values are deliberately relative rather than simulation claims.  They
-- preserve the old addon's "find the clearly better levelling item" model,
-- while WotLK hit (8% physical / 17% spell) and expertise (26) caps are
-- treated as diminishing stats after their cap.
local physical={strength=1.00,agility=.92,stamina=.10,attack=.34,crit=.52,haste=.48,hit=.82,expertise=.80,armorpen=.58,dps=2.70}
local agilityPhysical={strength=.30,agility=1.00,stamina=.10,attack=.34,crit=.57,haste=.50,hit=.82,expertise=.80,armorpen=.62,dps=2.55}
local caster={intellect=.68,spirit=.16,stamina=.08,spell=1.00,crit=.45,haste=.55,hit=.92,mp5=.05}
local healer={intellect=.72,spirit=.52,stamina=.10,spell=1.00,crit=.26,haste=.58,mp5=.72}
local tank={strength=.36,agility=.26,stamina=1.00,defense=.78,dodge=.68,parry=.64,block=.34,blockvalue=.28,armor=.08,hit=.30,expertise=.32}
-- WoWSims Enhancement Shaman Stat Weights (the supplied 3.3.5a profile).
-- The client exposes one shared Hit/Crit/Haste Rating stat on items, so the
-- Enhancement rule deliberately uses the simulator's Melee axes for those
-- three fields; Spell Damage remains an independent item stat.
local enhancement={
  strength=1.10,agility=1.59,intellect=1.48,spell=1.13,attack=1.00,
  hit=1.38,crit=.81,haste=1.61,armorpen=.48,expertise=0,
  dps=5.21,mainhanddps=5.21,offhanddps=2.21,
}
local roleWeights={melee=physical,caster=caster,healer=healer,tank=tank}

local function clone(values)
  local result={}
  for key,value in pairs(values) do result[key]=value end
  return result
end

local function rule(role,armor,weapons,values,extra)
  local result={role=role,armor=armor,weapons=weapons,weights=clone(values),hitType=role=="caster" and "spell" or "melee"}
  if extra then for key,value in pairs(extra) do result[key]=value end end
  return result
end

local function weaponSet(...)
  local result={}
  for index=1,select("#",...) do result[select(index,...)]=true end
  return result
end

-- Weapon proficiency is a class rule in Wrath, not a role rule.  Sharing one
-- "caster" set made mages accept maces, priests accept swords, paladins accept
-- daggers/wands, and death knights accept bows and daggers.
local onehand=weaponSet("AXE","MACE","SWORD","DAGGER","FIST")
local warriorWeapons=weaponSet("AXE","TH_AXE","MACE","TH_MACE","SWORD","TH_SWORD","TH_POLE","TH_STAFF","DAGGER","FIST","BOW","GUN","XBOW","THROWN")
local deathKnightWeapons=weaponSet("AXE","TH_AXE","MACE","TH_MACE","SWORD","TH_SWORD","TH_POLE")
local druidWeapons=weaponSet("DAGGER","MACE","TH_MACE","TH_STAFF","TH_POLE","FIST")
local hunterWeapons=weaponSet("BOW","GUN","XBOW","THROWN","AXE","TH_AXE","SWORD","TH_SWORD","TH_POLE","DAGGER","FIST","TH_STAFF")
local mageWeapons=weaponSet("DAGGER","SWORD","TH_STAFF","WAND")
local paladinWeapons=weaponSet("AXE","TH_AXE","MACE","TH_MACE","SWORD","TH_SWORD","TH_POLE")
local priestWeapons=weaponSet("DAGGER","MACE","TH_STAFF","WAND")
local shamanWeapons=weaponSet("AXE","TH_AXE","MACE","TH_MACE","DAGGER","FIST","TH_STAFF")
local warlockWeapons=weaponSet("DAGGER","SWORD","TH_STAFF","WAND")

local rules={
  DEATHKNIGHT={
    rule("tank","PLATE",deathKnightWeapons,tank,{twoHand=true}),
    rule("melee","PLATE",deathKnightWeapons,physical,{twoHand=true,dualWield=true}),
    rule("melee","PLATE",deathKnightWeapons,physical,{twoHand=true}),
  },
  DRUID={
    rule("caster","LEATHER",druidWeapons,caster,{hitType="spell"}),
    rule("melee","LEATHER",druidWeapons,agilityPhysical,{twoHand=true}),
    rule("healer","LEATHER",druidWeapons,healer),
  },
  HUNTER={
    rule("melee","MAIL",hunterWeapons,agilityPhysical,{ranged=true}),
    rule("melee","MAIL",hunterWeapons,agilityPhysical,{ranged=true}),
    rule("melee","MAIL",hunterWeapons,agilityPhysical,{ranged=true}),
  },
  MAGE={rule("caster","CLOTH",mageWeapons,caster,{hitType="spell"}),rule("caster","CLOTH",mageWeapons,caster,{hitType="spell"}),rule("caster","CLOTH",mageWeapons,caster,{hitType="spell"})},
  PALADIN={
    rule("healer","PLATE",paladinWeapons,healer,{shield=true}),
    rule("tank","PLATE",paladinWeapons,tank,{shield=true}),
    rule("melee","PLATE",paladinWeapons,physical,{twoHand=true}),
  },
  PRIEST={
    rule("healer","CLOTH",priestWeapons,healer),
    rule("healer","CLOTH",priestWeapons,healer),
    rule("caster","CLOTH",priestWeapons,caster,{hitType="spell"}),
  },
  ROGUE={
    rule("melee","LEATHER",onehand,agilityPhysical,{dualWield=true}),
    rule("melee","LEATHER",onehand,agilityPhysical,{dualWield=true}),
    rule("melee","LEATHER",onehand,agilityPhysical,{dualWield=true}),
  },
  SHAMAN={
    rule("caster","MAIL",shamanWeapons,caster,{shield=true,hitType="spell"}),
    rule("melee","MAIL",shamanWeapons,enhancement,{dualWield=true}),
    rule("healer","MAIL",shamanWeapons,healer,{shield=true}),
  },
  WARLOCK={rule("caster","CLOTH",warlockWeapons,caster,{hitType="spell"}),rule("caster","CLOTH",warlockWeapons,caster,{hitType="spell"}),rule("caster","CLOTH",warlockWeapons,caster,{hitType="spell"})},
  WARRIOR={
    rule("melee","PLATE",warriorWeapons,physical,{twoHand=true}),
    rule("melee","PLATE",warriorWeapons,physical,{dualWield=true,twoHand=true,dual2h=true}),
    rule("tank","PLATE",warriorWeapons,tank,{shield=true}),
  },
}
ItemScore.rules=rules

local armorID={[1]="CLOTH",[2]="LEATHER",[3]="MAIL",[4]="PLATE",[6]="SHIELD"}
local weaponID={[0]="AXE",[1]="TH_AXE",[2]="BOW",[3]="GUN",[4]="MACE",[5]="TH_MACE",[6]="TH_POLE",[7]="SWORD",[8]="TH_SWORD",[10]="TH_STAFF",[11]="FIST",[15]="DAGGER",[16]="THROWN",[18]="XBOW",[19]="WAND",[20]="FISHPOLE"}
-- GetAuctionItemSubClasses omits obsolete/exotic DBC rows.  Its list index is
-- therefore not an ItemSubclassWeapon ID after two-handed swords.
local auctionWeaponSubclassID={0,1,2,3,4,5,6,7,8,10,13,14,15,16,18,19,20}
local auctionArmorSubclassID={0,1,2,3,4,6,7,8,9,10}
local statAliases={
  STRENGTH="strength",AGILITY="agility",STAMINA="stamina",INTELLECT="intellect",SPIRIT="spirit",
  ATTACK_POWER="attack",RANGED_ATTACK_POWER="attack",SPELL_POWER="spell",SPELL_DAMAGE_DONE="spell",SPELL_HEALING_DONE="spell",
  CRIT_RATING="crit",HASTE_RATING="haste",HIT_RATING="hit",EXPERTISE_RATING="expertise",ARMOR_PENETRATION_RATING="armorpen",
  DEFENSE_SKILL_RATING="defense",DODGE_RATING="dodge",PARRY_RATING="parry",BLOCK_RATING="block",BLOCK_VALUE="blockvalue",
  ARMOR="armor",MANA_REGENERATION="mp5",DAMAGE_PER_SECOND="dps",
}

-- Keep the editable list explicit and ordered.  It deliberately contains
-- every stat that the WotLK scorer understands, so custom profiles can value
-- unusual hybrid stats without silently accepting a misspelled key.
ItemScore.CustomWeightOrder={
  "strength","agility","stamina","intellect","spirit","attack","spell","crit","haste","hit",
  "expertise","armorpen","defense","dodge","parry","block","blockvalue","armor","mp5","dps","mainhanddps","offhanddps",
}
ItemScore.CustomWeightLabels={
  strength="Strength",agility="Agility",stamina="Stamina",intellect="Intellect",spirit="Spirit",
  attack="Attack Power",spell="Spell Power",crit="Critical Strike Rating",haste="Haste Rating",hit="Hit Rating",
  expertise="Expertise Rating",armorpen="Armor Penetration Rating",defense="Defense Rating",dodge="Dodge Rating",parry="Parry Rating",
  block="Block Rating",blockvalue="Block Value",armor="Armor",mp5="Mana per 5 sec",dps="Weapon DPS (fallback)",
  mainhanddps="Main Hand DPS",offhanddps="Off Hand DPS",
}
local editableWeight={}
for _,stat in ipairs(ItemScore.CustomWeightOrder) do editableWeight[stat]=true end

-- WoWSims presents separate Spell and Melee rows where 3.3.5a item links
-- expose one shared combat-rating stat.  Keep compact internal names, while
-- accepting WoWSims labels and the usual short forms at the editor/import
-- boundary.
local weightAliases={
  str="strength",strength="strength",agi="agility",agility="agility",sta="stamina",stamina="stamina",
  int="intellect",intellect="intellect",spi="spirit",spirit="spirit",ap="attack",attack="attack",attackpower="attack",
  sp="spell",spell="spell",spelldmg="spell",spelldamage="spell",spellpower="spell",crit="crit",critrating="crit",criticalstrike="crit",criticalstrikerating="crit",
  spellcrit="crit",spellcritrating="crit",meleecrit="crit",meleecritrating="crit",
  haste="haste",hasterating="haste",spellhaste="haste",spellhasterating="haste",meleehaste="haste",meleehasterating="haste",
  hit="hit",hitrating="hit",spellhit="hit",spellhitrating="hit",meleehit="hit",meleehitrating="hit",expertise="expertise",expertiserating="expertise",
  arp="armorpen",armorpen="armorpen",armorpenetration="armorpen",armorpenetrationrating="armorpen",
  def="defense",defense="defense",defenserating="defense",dodge="dodge",dodgerating="dodge",parry="parry",parryrating="parry",
  block="block",blockrating="block",blockvalue="blockvalue",armor="armor",mp5="mp5",manaper5="mp5",manaper5sec="mp5",
  dps="dps",weapondps="dps",weapondamagepersecond="dps",mhdps="mainhanddps",mainhanddps="mainhanddps",mainhandweapondps="mainhanddps",
  ohdps="offhanddps",offhanddps="offhanddps",
}

local function weightStat(stat)
  local normalized=tostring(stat or ""):lower():gsub("[^%a%d]","")
  if editableWeight[normalized] then return normalized end
  return weightAliases[normalized]
end

local ratingAxis={
  spellhit="spell",spellhitrating="spell",spellcrit="spell",spellcritrating="spell",spellhaste="spell",spellhasterating="spell",
  meleehit="melee",meleehitrating="melee",meleecrit="melee",meleecritrating="melee",meleehaste="melee",meleehasterating="melee",
}

local function weightRatingAxis(stat)
  local normalized=tostring(stat or ""):lower():gsub("[^%a%d]","")
  return ratingAxis[normalized]
end

ItemScore.WoWSimsPresets={
  SHAMAN_ENHANCEMENT={
    title="WoWSims Enhancement Shaman",
    class="SHAMAN",spec=2,role="melee",
    weights=enhancement,
  },
}

local function escapePattern(value)
  return tostring(value or ""):gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])","%%%1"):gsub("%s+","%%s+")
end

local NUMBER_TOKEN="\001"
local TEXT_TOKEN="\002"
local function tooltipTemplatePattern(template)
  if type(template)~="string" or template=="" then return nil end
  local pattern=template
  pattern=pattern:gsub("%%%d+%$[-+ #0]*%d*%.?%d*[diufg]",NUMBER_TOKEN)
  pattern=pattern:gsub("%%[-+ #0]*%d*%.?%d*[diufg]",NUMBER_TOKEN)
  pattern=pattern:gsub("%%%d+%$s",TEXT_TOKEN):gsub("%%s",TEXT_TOKEN)
  pattern=escapePattern(pattern)
  pattern=pattern:gsub(NUMBER_TOKEN,"([%%d%%.,]+)"):gsub(TEXT_TOKEN,".-")
  return "^%s*"..pattern.."%s*$"
end

local function decimalNumber(value)
  value=tostring(value or ""):gsub("%s","")
  if value:find(",",1,true) and not value:find("%.") then value=value:gsub(",",".")
  else value=value:gsub(",","") end
  return tonumber(value)
end

local function integerNumber(value)
  -- string.gsub returns both the cleaned text and its replacement count in
  -- Lua 5.1.  Passing it directly to tonumber therefore treats that count as
  -- a numeric base, which is invalid for most tooltip strings.
  local cleaned=tostring(value or ""):gsub("[^%d%-]","")
  return tonumber(cleaned)
end

local damagePattern=tooltipTemplatePattern(_G.DAMAGE_TEMPLATE)
local schoolDamagePattern=tooltipTemplatePattern(_G.DAMAGE_TEMPLATE_WITH_SCHOOL)
local dpsPattern=tooltipTemplatePattern(_G.DPS_TEMPLATE)
local speedPattern
if type(_G.WEAPON_SPEED)=="string" then
  speedPattern=tooltipTemplatePattern(_G.WEAPON_SPEED)
  if not _G.WEAPON_SPEED:find("%%") then
    speedPattern="^%s*"..escapePattern(_G.WEAPON_SPEED).."%s+([%d%.,]+)%s*$"
  end
end

local function weaponTooltipStats(link)
  local tooltip=ZGV.Compat and ZGV.Compat.Tooltip
  local scan=tooltip and tooltip:ScanItem(link)
  local lines=scan and scan.lines or {}
  local low,high,speed,dps
  local function parse(text)
    if type(text)~="string" then return end
    local first,second
    if damagePattern then first,second=text:match(damagePattern) end
    if not first and schoolDamagePattern then first,second=text:match(schoolDamagePattern) end
    if first and second then low,high=integerNumber(first),integerNumber(second) end
    if not speed and speedPattern then speed=decimalNumber(text:match(speedPattern)) end
    if not dps and dpsPattern then dps=decimalNumber(text:match(dpsPattern)) end
  end
  for _,line in ipairs(lines) do parse(line.left) parse(line.right) end
  if not dps and low and high and speed and speed>0 then dps=(low+high)/2/speed end
  return dps,low,high,speed,scan and scan.ready or false
end

local function normalized(value)
  value=tostring(value or ""):upper():gsub("ITEM_MOD_",""):gsub("_SHORT$",""):gsub("_NAME$","")
  return value
end

local function itemID(item)
  return type(item)=="number" and item or (type(item)=="string" and tonumber(item:match("item:(%d+)")))
end

local function itemMetadata(link,info)
  local classID,subclassID
  if type(GetItemInfoInstant)=="function" then
    local _,_,_,_,_,foundClass,foundSubclass=GetItemInfoInstant(link)
    classID,subclassID=tonumber(foundClass),tonumber(foundSubclass)
  end
  if not classID then
    if _G.WEAPON and info.className==_G.WEAPON then classID=2
    elseif _G.ARMOR and info.className==_G.ARMOR then classID=4 end
  end
  -- GetItemInfoInstant is absent on a few 3.3.5a-derived clients.  The
  -- auction class lists are localized by Blizzard, so this fallback remains
  -- locale-safe instead of comparing English class strings.
  if not subclassID and type(GetAuctionItemClasses)=="function" and type(GetAuctionItemSubClasses)=="function" then
    local classes={GetAuctionItemClasses()}
    local auctionClass=classID==2 and 1 or classID==4 and 2 or nil
    if not auctionClass then
      for index,name in ipairs(classes) do if name==info.className then auctionClass=index break end end
    end
    if auctionClass==1 then classID=2 elseif auctionClass==2 then classID=4 end
    if auctionClass then
      local subclasses={GetAuctionItemSubClasses(auctionClass)}
      for index,name in ipairs(subclasses) do
        if name==info.subclassName then
          subclassID=auctionClass==1 and auctionWeaponSubclassID[index] or auctionArmorSubclassID[index]
          break
        end
      end
    end
  end
  return classID,subclassID
end

function ItemScore.strip_link(link)
  return tostring(link or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
end

function ItemScore:GetSpec()
  local talent=ZGV.Compat and ZGV.Compat.Talent
  local best,bestPoints=1,-1
  if talent and talent.GetTab then
    local group=talent:GetActiveGroup(false)
    for tab=1,3 do
      local tree=talent:GetTab(tab,false,group)
      local points=tree and tonumber(tree.pointsSpent) or 0
      if points>bestPoints then best,bestPoints=tab,points end
    end
  end
  return best
end

function ItemScore:HasTalentID(talentID)
  talentID=tonumber(talentID)
  local talent=ZGV.Compat and ZGV.Compat.Talent
  if not talentID or not talent then return false end
  if type(TalentFrame_LoadUI)=="function" then pcall(TalentFrame_LoadUI) end
  for _,tree in ipairs(talent:GetTrees(false)) do
    for _,info in ipairs(tree.talents or {}) do
      local link=GetTalentLink and GetTalentLink(info.tab,info.index,false,false)
      local id=link and tonumber(link:match("talent:(%d+)"))
      if id==talentID then return (tonumber(info.rank) or 0)>0 end
    end
  end
  return false
end

local function talentIDFor(class,name)
  local classData=ZGV.Data and ZGV.Data.talentIDs and ZGV.Data.talentIDs[class]
  if not classData then return nil end
  local normalized=tostring(name or ""):lower():gsub("^%s+",""):gsub("%s+$",""):gsub("%s+"," ")
  if classData[normalized] then return classData[normalized] end
  if classData[name] then return classData[name] end
  for talentName,talentID in pairs(classData) do
    local key=tostring(talentName):lower():gsub("^%s+",""):gsub("%s+$",""):gsub("%s+"," ")
    if key==normalized then return talentID end
  end
end

function ItemScore:SetFilters(playerclass,playerspec,playerlevel)
  self.playerclass=playerclass or (select(2,UnitClass("player"))) or "WARRIOR"
  self.playerspec=tonumber(playerspec) or self:GetSpec() or 1
  self.playerlevel=tonumber(playerlevel) or (UnitLevel and UnitLevel("player")) or 1
  self.ActiveRuleSet=(rules[self.playerclass] and rules[self.playerclass][self.playerspec]) or (rules[self.playerclass] and rules[self.playerclass][1])
  self.curRuleSet=self.ActiveRuleSet
  local selected=ZGV.db and ZGV.db.profile and ZGV.db.profile.gear and ZGV.db.profile.gear.role
  if self.ActiveRuleSet and selected and ({melee=true,caster=true,healer=true,tank=true})[selected] then
    local base=self.curRuleSet
    self.ActiveRuleSet={
      role=selected,armor=base.armor,weapons=base.weapons,weights=clone(roleWeights[selected]),
      shield=base.shield,dualWield=base.dualWield,twoHand=base.twoHand,dual2h=base.dual2h,
      ranged=base.ranged,hitType=selected==base.role and base.hitType or (selected=="caster" and "spell" or "melee"),
    }
  end
  -- Preserve this before applying an override so the editor can accurately
  -- show the active WotLK default beside the user's own value.
  self.BaseRuleSet=self.ActiveRuleSet
  local customWeights=self:GetCustomWeights(false)
  if self.ActiveRuleSet and type(customWeights)=="table" then
    -- Never alter the shared class rules: a saved override belongs to this
    -- character profile and must be reversible by clearing the edit box.
    local customRule={}
    for key,value in pairs(self.ActiveRuleSet) do customRule[key]=value end
    customRule.weights=clone(self.ActiveRuleSet.weights or {})
    for stat,value in pairs(customWeights) do
      local weight=tonumber(value)
      if editableWeight[stat] and weight and weight>=0 and weight<=100 then customRule.weights[stat]=weight end
    end
    self.ActiveRuleSet=customRule
  end
  self.playerdualwield=self.ActiveRuleSet and self.ActiveRuleSet.dualWield or false
  if self.playerdualwield and self.playerclass=="SHAMAN" and self.playerspec==2 then
    self.playerdualwield=self:HasTalentID(talentIDFor("SHAMAN","Dual Wield"))
  end
  local titanGripID=talentIDFor("WARRIOR","Titan's Grip")
  self.playerdual2h=self.ActiveRuleSet and self.ActiveRuleSet.dual2h and self:HasTalentID(titanGripID) or false
  ZGV:Fire("ZGV_ITEM_SCORE_RULES_CHANGED",self.ActiveRuleSet)
  return self.ActiveRuleSet
end

function ItemScore:GetRule()
  return self.ActiveRuleSet or self:SetFilters()
end

function ItemScore:GetCustomWeightKey()
  local class=self.playerclass or (select(2,UnitClass("player"))) or "WARRIOR"
  local spec=tonumber(self.playerspec) or self:GetSpec() or 1
  local active=self.BaseRuleSet or self.ActiveRuleSet
  local role=active and active.role or "melee"
  return table.concat({class,spec,role},":")
end

function ItemScore:GetCustomWeights(create)
  if not self.ActiveRuleSet then self:SetFilters() end
  local gear=ZGV.db and ZGV.db.profile and ZGV.db.profile.gear
  if not gear then return nil end
  gear.customWeights=gear.customWeights or {}
  local all=gear.customWeights
  -- Migrate the brief flat-table format used by the first WotLK port.  It is
  -- safe to do lazily because the current class/spec/role is already known.
  local legacy={}
  for stat in pairs(editableWeight) do
    if tonumber(all[stat])~=nil then legacy[stat]=all[stat] end
  end
  if next(legacy) then
    local key=self:GetCustomWeightKey()
    local scoped=type(all[key])=="table" and all[key] or {}
    for stat,value in pairs(legacy) do scoped[stat]=value all[stat]=nil end
    all[key]=scoped
  end
  local key=self:GetCustomWeightKey()
  if type(all[key])~="table" and create then all[key]={} end
  return type(all[key])=="table" and all[key] or nil
end

function ItemScore:GetCustomWeight(stat)
  stat=weightStat(stat)
  if not stat then return nil end
  local weights=self:GetCustomWeights(false)
  return weights and tonumber(weights[stat]) or nil
end

function ItemScore:GetDefaultWeight(stat)
  stat=weightStat(stat)
  if not stat then return nil end
  local base=self.BaseRuleSet or self:GetRule()
  if not base or not base.weights then return nil end
  local value=base.weights[stat]
  if value==nil and (stat=="mainhanddps" or stat=="offhanddps") then value=base.weights.dps end
  return tonumber(value)
end

function ItemScore:GetEffectiveWeight(stat)
  stat=weightStat(stat)
  if not stat then return nil end
  local rule=self:GetRule()
  if not rule or not rule.weights then return nil end
  local value=rule.weights[stat]
  if value==nil and (stat=="mainhanddps" or stat=="offhanddps") then value=rule.weights.dps end
  return tonumber(value)
end

function ItemScore:GetWoWSimsPreset()
  local base=self.BaseRuleSet or self:GetRule()
  for _,preset in pairs(self.WoWSimsPresets or {}) do
    if self.playerclass==preset.class and tonumber(self.playerspec)==tonumber(preset.spec)
      and base and base.role==preset.role then return preset end
  end
end

function ItemScore:ApplyWoWSimsPreset()
  local preset=self:GetWoWSimsPreset()
  if not preset then return false,"no WoWSims preset is available for this class, specialization, and role" end
  local weights=self:GetCustomWeights(true)
  if not weights then return false,"profile unavailable" end
  -- A simulator preset is an exact profile, not a partial adjustment to a
  -- previous hand-edited setup.  Zero omitted stats so old custom entries
  -- cannot silently leak into the selected WoWSims profile.
  for stat in pairs(editableWeight) do weights[stat]=0 end
  for stat,value in pairs(preset.weights) do weights[stat]=value end
  self:SetFilters(self.playerclass,self.playerspec,self.playerlevel)
  return true,preset.title
end

function ItemScore:SetCustomWeight(stat,value)
  stat=weightStat(stat)
  if not stat then return false,"unknown stat" end
  local weights=self:GetCustomWeights(true)
  if not weights then return false,"profile unavailable" end
  if value==nil or tostring(value):match("^%s*$") then
    weights[stat]=nil
  else
    local text=tostring(value):gsub(",",".")
    local weight=tonumber(text)
    if not weight or weight<0 or weight>100 then return false,"weight must be between 0 and 100" end
    weights[stat]=math.floor(weight*1000+.5)/1000
  end
  self:SetFilters(self.playerclass,self.playerspec,self.playerlevel)
  return true
end

function ItemScore:ImportCustomWeights(text)
  local weights=self:GetCustomWeights(true)
  if not weights then return false,"profile unavailable" end
  local changed=0
  for entry in tostring(text or ""):gmatch("[^,;\r\n]+") do
    local name,value=entry:match("^%s*(.-)%s*[:=]%s*([%d%.,]+)%s*$")
    if not name then name,value=entry:match("^%s*(.-)%s+([%d%.,]+)%s*$") end
    local stat=weightStat(name)
    local axis=weightRatingAxis(name)
    local base=self.BaseRuleSet or self:GetRule()
    local usesSpellRatings=base and (base.role=="caster" or base.role=="healer") or false
    -- Item links contain one shared Hit/Crit/Haste Rating.  When a WoWSims
    -- export contains both axes, choose the axis appropriate to this profile
    -- instead of letting paste order decide the scored value.
    if axis and ((axis=="spell")~=usesSpellRatings) then stat=nil end
    local numberText=value and tostring(value):gsub(",",".")
    local numeric=numberText and tonumber(numberText)
    if stat and numeric and numeric>=0 and numeric<=100 then
      weights[stat]=math.floor(numeric*1000+.5)/1000
      changed=changed+1
    end
  end
  if changed==0 then return false,"no recognised WoWSims stat weights found" end
  self:SetFilters(self.playerclass,self.playerspec,self.playerlevel)
  return true,changed
end

function ItemScore:ResetCustomWeights()
  local weights=self:GetCustomWeights(false)
  if not weights then return false,"profile unavailable" end
  for stat in pairs(weights) do weights[stat]=nil end
  self:SetFilters(self.playerclass,self.playerspec,self.playerlevel)
  return true
end

function ItemScore:GetItemDetails(item,itemlink)
  local id=itemID(item) or itemID(itemlink)
  local link=itemlink or (type(item)=="string" and item) or id
  if not id then return nil,"invalid_item" end
  local key=self.strip_link(link)
  local cached=self.ItemCache[key] or self.ItemCache[id]
  local info=ZGV.Compat.Item:GetInfo(link)
  if not info.ready then return nil,"not_ready" end
  local stats=ZGV.Compat.Item:GetStats(link).stats or {}
  local classID,subclassID=itemMetadata(link,info)
  local details=cached or {}
  details.itemid=id
  details.itemlink=info.itemLink or link
  details.itemlinkfull=details.itemlink
  details.name=info.name
  details.quality=info.quality or 0
  details.ilevel=info.itemLevel or 0
  details.reqlevel=info.requiredLevel or 0
  details.class=info.className
  details.subclass=info.subclassName
  details.classID=classID
  details.subclassID=subclassID
  details.equipslot=info.equipLocation
  details.texture=info.texture
  details.vendorprice=info.vendorPrice or 0
  details.stats=stats
  details.twohander=details.equipslot=="INVTYPE_2HWEAPON"
  if classID==2 and not details.weaponTooltipScanned then
    local dps,low,high,speed,ready=weaponTooltipStats(details.itemlink)
    if ready then
      details.weaponTooltipScanned=true
      details.weaponDPS=dps
      details.weaponDamageMin=low
      details.weaponDamageMax=high
      details.weaponSpeed=speed
    end
  end
  if details.weaponDPS then details.stats.DAMAGE_PER_SECOND=details.weaponDPS end
  self.ItemCache[key]=details
  self.ItemCache[id]=details
  return details
end

function ItemScore:GetItemStatsWithTooltip(item,itemlink)
  return self:GetItemDetails(item,itemlink)
end

function ItemScore:GetItemSlot(equipslot)
  local candidates=slots[equipslot]
  if not candidates then return nil end
  return candidates[1],candidates[2]
end

function ItemScore:GetSlotCandidates(equipslot)
  local result={}
  local slotNames=slots[equipslot] or {}
  if equipslot=="INVTYPE_2HWEAPON" and self.playerdual2h then slotNames={"MainHandSlot","SecondaryHandSlot"} end
  if equipslot=="INVTYPE_WEAPON" and not self.playerdualwield then slotNames={"MainHandSlot"} end
  for _,name in ipairs(slotNames) do
    local slot=GetInventorySlotInfo and GetInventorySlotInfo(name)
    if slot then result[#result+1]=slot end
  end
  return result
end

function ItemScore:GetItemInSlot(equipslot)
  local first,second=self:GetSlotCandidates(equipslot)[1],self:GetSlotCandidates(equipslot)[2]
  local one=first and GetInventoryItemID and GetInventoryItemID("player",first)
  local two=second and GetInventoryItemID and GetInventoryItemID("player",second)
  return one,two
end

function ItemScore:GetItemByType(equipslot)
  local candidates=self:GetSlotCandidates(equipslot)
  local one=candidates[1] and GetInventoryItemLink and GetInventoryItemLink("player",candidates[1])
  local two=candidates[2] and GetInventoryItemLink and GetInventoryItemLink("player",candidates[2])
  return one,two
end

function ItemScore:GetCommonInvType(equipslot)
  if equipslot=="INVTYPE_ROBE" then return "INVTYPE_CHEST" end
  if equipslot=="INVTYPE_RANGED" or equipslot=="INVTYPE_RANGEDRIGHT" then return "INVTYPE_RANGED" end
  if equipslot=="INVTYPE_WEAPON" then return "INVTYPE_WEAPONMAINHAND","INVTYPE_WEAPONOFFHAND" end
  return equipslot
end

local function itemKind(item)
  if item.classID==4 then return "armor",armorID[item.subclassID] end
  if item.classID==2 then return "weapon",weaponID[item.subclassID] end
  local class=normalized(item.class)
  local subclass=normalized(item.subclass)
  if class=="ARMOR" then
    if subclass:find("CLOTH") then return "armor","CLOTH" end
    if subclass:find("LEATHER") then return "armor","LEATHER" end
    if subclass:find("MAIL") then return "armor","MAIL" end
    if subclass:find("PLATE") then return "armor","PLATE" end
    if subclass:find("SHIELD") then return "armor","SHIELD" end
    return "armor","MISCARM"
  end
  if class=="WEAPON" then
    if subclass:find("TWO.HANDED AXE") then return "weapon","TH_AXE" end
    if subclass:find("TWO.HANDED MACE") then return "weapon","TH_MACE" end
    if subclass:find("TWO.HANDED SWORD") then return "weapon","TH_SWORD" end
    if subclass:find("POLEARM") then return "weapon","TH_POLE" end
    if subclass:find("STAFF") then return "weapon","TH_STAFF" end
    if subclass:find("CROSSBOW") then return "weapon","XBOW" end
    if subclass:find("DAGGER") then return "weapon","DAGGER" end
    if subclass:find("WAND") then return "weapon","WAND" end
    if subclass:find("THROWN") then return "weapon","THROWN" end
    if subclass:find("BOW") then return "weapon","BOW" end
    if subclass:find("GUN") then return "weapon","GUN" end
    if subclass:find("FIST") then return "weapon","FIST" end
    if subclass:find("AXE") then return "weapon","AXE" end
    if subclass:find("MACE") then return "weapon","MACE" end
    if subclass:find("SWORD") then return "weapon","SWORD" end
  end
end

local armorRank={CLOTH=1,LEATHER=2,MAIL=3,PLATE=4}
local function maximumArmor(class,level)
  level=tonumber(level) or 1
  if class=="DEATHKNIGHT" then return "PLATE" end
  if class=="WARRIOR" or class=="PALADIN" then return level>=40 and "PLATE" or "MAIL" end
  if class=="HUNTER" or class=="SHAMAN" then return level>=40 and "MAIL" or "LEATHER" end
  if class=="DRUID" or class=="ROGUE" then return "LEATHER" end
  return "CLOTH"
end

local relicClass={[7]="PALADIN",[8]="DRUID",[9]="SHAMAN",[10]="DEATHKNIGHT"}

function ItemScore:CanEquipItem(item,allowbad)
  local details=type(item)=="table" and item or self:GetItemDetails(item)
  local active=self:GetRule()
  if not details or not active then return "REJECT","not_ready","item or scoring rule is unavailable" end
  if not self.possEquipSlots[details.equipslot] then return "REJECT","bad_slot","not an equippable gear slot" end
  if details.reqlevel>(self.playerlevel or 1) and not allowbad then return "REJECT","level_requirement","requires level "..details.reqlevel end
  if accessory[details.equipslot] then return 1 end
  if details.equipslot=="INVTYPE_RELIC" then
    local requiredClass=relicClass[details.subclassID]
    if requiredClass and requiredClass==self.playerclass then return 1 end
    return "REJECT","not_for_you",requiredClass and ("relic requires "..requiredClass) or "unknown relic class"
  end
  local kind,subclass=itemKind(details)
  if details.equipslot=="INVTYPE_SHIELD" then
    if active.shield then return 1 end
    return "REJECT","not_for_you","this build does not use shields"
  end
  if details.equipslot=="INVTYPE_HOLDABLE" then
    return (active.role=="caster" or active.role=="healer") and 1 or .40
  end
  if kind=="weapon" then
    if subclass and active.weapons[subclass] then return 1 end
    return "REJECT","not_for_you","weapon type is not usable by this build"
  end
  if kind=="armor" then
    local best=maximumArmor(self.playerclass,self.playerlevel)
    local itemRank,maxRank=armorRank[subclass],armorRank[best]
    if itemRank and maxRank and itemRank>maxRank then return "REJECT","not_for_you","armor class is not usable by this class" end
    if subclass==best then return 1 end
    if itemRank then return (self.playerlevel or 1)<40 and .85 or .45 end
    return "REJECT","not_for_you","armor type is not appropriate for this build"
  end
  return "REJECT","bad_item","unknown equipment class"
end

local function combatRating(category)
  return category and GetCombatRating and tonumber(GetCombatRating(category)) or 0
end

function ItemScore:GetStatCap(stat,active)
  if (self.playerlevel or 1)<WOTLK_MAX_LEVEL then return nil,0 end
  if stat=="hit" then
    if active.hitType=="spell" then return 445.9,combatRating(CR_HIT_SPELL) end
    if active.ranged then return 262.3,combatRating(CR_HIT_RANGED) end
    return 262.3,combatRating(CR_HIT_MELEE)
  end
  if stat=="expertise" then return 214.0,combatRating(CR_EXPERTISE) end
  if stat=="armorpen" then return 1400,combatRating(CR_ARMOR_PENETRATION) end
  if stat=="defense" then return 689,combatRating(CR_DEFENSE_SKILL) end
end

local function cappedWeight(score,stat,value,weight,active)
  local cap,current=score:GetStatCap(stat,active)
  if not cap then return weight end
  if current>=cap then return weight*.12 end
  if current+value<=cap then return weight end
  local below=math.max(0,cap-current)
  return weight*((below/value)+((value-below)/value)*.12)
end

function ItemScore:IsOffHandScoreSlot(slot)
  if slot=="INVTYPE_WEAPONOFFHAND" or slot=="SecondaryHandSlot" then return true end
  local offhand=GetInventorySlotInfo and GetInventorySlotInfo("SecondaryHandSlot")
  return offhand and tonumber(slot)==tonumber(offhand) or false
end

function ItemScore:ScoreItemStats(item,invslot,itemlink,verbose)
  local details=type(item)=="table" and item or self:GetItemDetails(item,itemlink)
  local active=self:GetRule()
  if not details or not active then return -1,"not_ready","item or scoring rule is unavailable" end
  local score=0
  for raw,value in pairs(details.stats or {}) do
    value=tonumber(value) or 0
    local stat=statAliases[normalized(raw)]
    if stat and value~=0 then
      local weightStat=stat
      if stat=="dps" then weightStat=self:IsOffHandScoreSlot(invslot) and "offhanddps" or "mainhanddps" end
      local weight=active.weights[weightStat]
      if weight==nil and stat=="dps" then weight=active.weights.dps end
      weight=weight or 0
      if weight>0 then score=score+value*cappedWeight(self,stat,value,weight,active) end
    elseif tostring(raw):find("EMPTY_SOCKET") then
      -- A levelling-safe approximation: sockets count, but can never outweigh
      -- the base item when no gem data has been cached.
      score=score+value*math.max(4,(details.ilevel or 0)*.08)
    end
  end
  return score
end

function ItemScore:GetItemScore(item,invslot,itemlink,allowbad,verbose,scoreSlot)
  local details=type(item)=="table" and item or self:GetItemDetails(item,itemlink)
  local active=self:GetRule()
  if not details then return -1,"not_ready","item information is not cached" end
  if invslot and invslot~=details.equipslot then
    local compatible=(invslot=="INVTYPE_CHEST" and details.equipslot=="INVTYPE_ROBE")
      or (invslot=="INVTYPE_WEAPONMAINHAND" and (details.equipslot=="INVTYPE_WEAPON" or details.equipslot=="INVTYPE_RANGED" or details.equipslot=="INVTYPE_RANGEDRIGHT"))
      or (invslot=="INVTYPE_WEAPONOFFHAND" and details.equipslot=="INVTYPE_WEAPON")
    if not compatible then return -1,"bad_slot","item is not for the requested slot" end
  end
  if invslot=="INVTYPE_WEAPONOFFHAND" and details.equipslot=="INVTYPE_WEAPON" and not self.playerdualwield then
    return -1,"dual_wield_unavailable","this build has not learned Dual Wield"
  end
  local multiplier,code,reason=self:CanEquipItem(details,allowbad)
  if multiplier=="REJECT" then return -1,code,reason end
  local score,statCode,statReason=self:ScoreItemStats(details,scoreSlot or invslot,itemlink,verbose)
  if score<0 then return score,statCode,statReason end
  -- Item level is intentionally a tie-breaker, not a replacement for stats.
  score=score+(details.ilevel or 0)*.12
  score=score*(multiplier or 1)
  details.score=score
  details.valid=true
  return score,"ok","scored for "..tostring(active and active.role or "build")
end

function ItemScore:CanUseUniqueItem() return true end

function ItemScore:ValidDungeonItem(itemid)
  local finder=self.GearFinder
  local entry=finder and finder.items_in_guides and finder.items_in_guides[tonumber(itemid)]
  if not entry then return -1,"not_in_guides","item is not in the loaded dungeon tables" end
  local dungeon=ZGV.Dungeons and ZGV.Dungeons:Get(entry.dungeon or entry.dungeonmap)
  if dungeon and dungeon.minLevel and dungeon.minLevel>(self.playerlevel or 1) then
    return -1,"level_requirement","requires level "..dungeon.minLevel,"level",dungeon.minLevel
  end
  return 0,"ok","available"
end

function ItemScore:Debug(message,...)
  if ZGV.Debug then ZGV:Debug("&itemscore "..tostring(message),...) end
end

function ItemScore:OnEvent()
  self:SetFilters()
  if ZGV.GearAdvisor then ZGV.GearAdvisor:QueueRefresh() end
end

function ItemScore:OnStartup() self:SetFilters() end

for _,event in ipairs({"PLAYER_ENTERING_WORLD","PLAYER_LEVEL_UP","ACTIVE_TALENT_GROUP_CHANGED","CHARACTER_POINTS_CHANGED","PLAYER_EQUIPMENT_CHANGED"}) do
  ZGV:RegisterEvent(event,ItemScore,"OnEvent")
end
