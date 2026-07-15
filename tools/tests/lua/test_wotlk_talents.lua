local repo = assert(arg[1], "repository path is required")
local addon = repo .. "/ZygorGuidesViewerNew/ZygorGuidesViewer/"

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2) end
end
local function assertContains(values, fragment, label)
  for _,value in ipairs(values or {}) do if tostring(value):find(fragment,1,true) then return end end
  error(label .. ": missing issue containing " .. fragment, 2)
end

local modules = {}
ZygorGuidesViewer = {
  Compat = {},
  Data = { datasets = {} },
  db = { profile = { talent = { selected = {} }, gear = {} } },
}
function ZygorGuidesViewer.Data:Register(name, version, records, provenance)
  self[name] = records
  self.datasets[name] = { version=version, records=records, provenance=provenance }
end
function ZygorGuidesViewer:RegisterModule(name, module) modules[name]=module self[name]=module return module end
function ZygorGuidesViewer:RegisterEvent() end
function ZygorGuidesViewer:Fire() end

local playerTalents, petTalents = {}, {}
local linkIDs = { player = {}, pet = {} }
local function addTalent(target, links, tab, index, name, maxRank, tier, talentID, prerequisiteTab, prerequisiteIndex)
  target[#target+1] = {
    tab=tab,index=index,name=name,maxRank=maxRank,tier=tier,column=1,rank=0,meetsPrerequisite=true,
    prerequisiteTab=prerequisiteTab,prerequisiteIndex=prerequisiteIndex,
  }
  links[tab..":"..index] = talentID
end
addTalent(playerTalents,linkIDs.player,1,1,"Foundation",5,1,1001)
addTalent(playerTalents,linkIDs.player,1,2,"Tier Two",5,2,1002,1,1)
for index=3,17 do addTalent(playerTalents,linkIDs.player,1,index,"Foundation "..index,5,1,1000+index) end
addTalent(petTalents,linkIDs.pet,1,1,"Pet Foundation",3,1,2001)
addTalent(petTalents,linkIDs.pet,1,2,"Pet Tier Two",3,2,2002,1,1)
for index=3,8 do addTalent(petTalents,linkIDs.pet,1,index,"Pet Foundation "..index,3,1,2000+index) end

local talentService = {}
local unspentPoints,activeGroup = 0,1
function talentService:GetTrees(isPet)
  return {{talents=isPet and petTalents or playerTalents}}
end
function talentService:GetInfo(tab,index,isPet)
  for _,info in ipairs(isPet and petTalents or playerTalents) do
    if info.tab==tab and info.index==index then return info end
  end
end
function talentService:GetActiveGroup() return activeGroup end
function talentService:GetUnspentPoints() return unspentPoints end
function talentService:GetTab() return nil end
function talentService:Learn() return {ok=true} end
ZygorGuidesViewer.Compat.Talent = talentService
ZygorGuidesViewer.Compat.Item = {}
ZygorGuidesViewer.Compat.UI = {}

local itemTalentMode = false
local activeTalentID, activeTalentRank = nil, 0
function GetTalentLink(tab,index,inspect,isPet)
  local id
  if itemTalentMode then id=activeTalentID
  else id=linkIDs[isPet and "pet" or "player"][tab..":"..index] end
  return id and ("|Htalent:"..id.."|h[test]|h") or nil
end
function UnitClass() return "Mage","MAGE" end
function UnitLevel() return 80 end
function GetInventorySlotInfo(name) return ({MainHandSlot=16,SecondaryHandSlot=17,RangedSlot=18})[name] end

dofile(addon .. "Data-WotLK/TalentIDs.lua")
assertEqual(ZygorGuidesViewer.Data.talentIDs.SHAMAN["dual wield"],1690,"3.3.5 Shaman Dual Wield Talent.dbc ID")
assertEqual(ZygorGuidesViewer.Data.talentIDs.WARRIOR["titan's grip"],1867,"3.3.5 Titan's Grip Talent.dbc ID")
dofile(addon .. "Talent.lua")
local Talent=ZygorGuidesViewer.Talent

-- PLAYER_LOGIN can arrive before build 12340 has populated GetTalentInfo.
-- Initialization must defer without poisoning the compile cache, then choose a
-- build as soon as PLAYER_TALENT_UPDATE makes the same API data available.
local savedPlayerTalents=playerTalents
playerTalents={}
Talent:RegisterBuild("MAGE","Deferred (1/0/0)",{{1,1}})
Talent:OnStartup()
assertEqual(Talent.dataReady,nil,"startup waits for unavailable talent tables")
assertEqual(Talent.waitingForData,true,"startup records deferred talent initialization")
playerTalents=savedPlayerTalents
Talent:OnEvent("PLAYER_TALENT_UPDATE")
assertEqual(Talent.dataReady,true,"talent update retries deferred initialization")
assertEqual(Talent:GetSelected(false).title,"Deferred (1/0/0)","deferred initialization selects the build")
Talent.builds={}
Talent.byClass={}
Talent.selected=nil
Talent.selectedByContext={}
Talent.compiled={}
Talent.dataReady=nil
Talent.waitingForData=nil
Talent.validationLogged=nil

local function coordinates(index,count)
  local result={}
  for _=1,count do result[#result+1]={1,index} end
  return result
end
local function compile(class,title,raw)
  local build=Talent:RegisterBuild(class,title,raw)
  return assert(Talent:Compile(build))
end

local validRaw=coordinates(1,5)
validRaw[#validRaw+1]={1,2}
local validResult=compile("MAGE","Valid (6/0/0)",validRaw)
assertEqual(validResult.valid,true,"valid player prerequisite order")
assertEqual(validResult.sequence[6].prerequisiteTab,1,"player prerequisite tab captured")
assertEqual(validResult.sequence[6].prerequisiteIndex,1,"player prerequisite index captured")
assertEqual(validResult.sequence[6].prerequisiteMaxRank,5,"player prerequisite max rank captured")

unspentPoints=3
local suggestionState=Talent:GetSuggestionState(validResult.build)
assertEqual(suggestionState.code,"GREEN","empty on-build talent tree is healthy")
assertEqual(#suggestionState.suggestions,3,"advisor exposes one suggestion per unspent point")
assertEqual(suggestionState.suggestions[1].name,"Foundation","advisor preserves authored point order")
playerTalents[1].rank=5
playerTalents[2].rank=1
unspentPoints=0
suggestionState=Talent:GetSuggestionState(validResult.build)
assertEqual(suggestionState.complete,true,"advisor recognizes a completed build")
assertEqual(suggestionState.code,"GREEN","completed build remains healthy")
playerTalents[1].rank=0
playerTalents[2].rank=1
suggestionState=Talent:GetSuggestionState(validResult.build)
assertEqual(suggestionState.outOfOrder,true,"later planned points are detected as out of order")
assertEqual(suggestionState.code,"YELLOW","recoverable out-of-order build is yellow")
playerTalents[3].rank=1
suggestionState=Talent:GetSuggestionState(validResult.build)
assertEqual(suggestionState.wrong,1,"off-build ranks are counted")
assertEqual(suggestionState.code,"RED","off-build point marks the build red")
for _,info in ipairs(playerTalents) do info.rank=0 end
unspentPoints=0

local prerequisiteWrongOrder=coordinates(3,5)
prerequisiteWrongOrder[#prerequisiteWrongOrder+1]={1,2}
for _,point in ipairs(coordinates(1,5)) do prerequisiteWrongOrder[#prerequisiteWrongOrder+1]=point end
local prerequisiteWrongResult=compile("MAGE","Prerequisite Wrong Order (11/0/0)",prerequisiteWrongOrder)
assertEqual(prerequisiteWrongResult.valid,false,"player prerequisite wrong order rejected")
assertContains(prerequisiteWrongResult.issues,"talent prerequisite unavailable at point 6","player prerequisite diagnostic")

local overrank=compile("MAGE","Overrank (6/0/0)",coordinates(1,6))
assertEqual(overrank.valid,false,"overrank rejected")
assertContains(overrank.issues,"over rank cap","overrank diagnostic")

local tierEarly={{1,2}}
for _,point in ipairs(coordinates(1,5)) do tierEarly[#tierEarly+1]=point end
local tierResult=compile("MAGE","Tier Early (6/0/0)",tierEarly)
assertEqual(tierResult.valid,false,"tier-too-early rejected")
assertContains(tierResult.issues,"tier unavailable at point 1","tier diagnostic")

-- Imported legacy text describes the final rank allocation, not the order in
-- which those ranks must be learned.  It remains a valid template and plans
-- the available prerequisite first.
unspentPoints=1
local legacyDisplay=compile("MAGE","Legacy Display (6/0/0)","1 Tier Two\n5 Foundation")
assertEqual(legacyDisplay.valid,true,"legacy display-order text remains usable")
assert(#legacyDisplay.warnings>0,"legacy display order records a non-fatal diagnostic")
local legacyNext=assert(Talent:GetNextPoint(legacyDisplay.build))
assertEqual(legacyNext.name,"Foundation","advisor plans an unlocked legacy prerequisite")
local anniversarySignature=Talent:RegisterBuild("MAGE","Anniversary Signature (5/0/0)",42,"5/5 Foundation")
local anniversaryResult=assert(Talent:Compile(anniversarySignature))
assertEqual(anniversarySignature.statweights,42,"Anniversary stat weights do not displace build data")
assertEqual(anniversaryResult.valid,true,"Anniversary registration signature remains a usable WotLK build")
unspentPoints=0

local mismatch=compile("MAGE","Mismatch (4/0/0)",coordinates(1,5))
assertEqual(mismatch.valid,false,"title mismatch rejected")
assertContains(mismatch.issues,"point total does not match title","title diagnostic")

local playerLimit={}
for index=1,17 do
  if index~=2 and #playerLimit<72 then
    for _=1,5 do if #playerLimit<72 then playerLimit[#playerLimit+1]={1,index} end end
  end
end
local playerLimitResult=compile("MAGE","Player Limit",playerLimit)
assertEqual(playerLimitResult.valid,false,"player point limit rejected")
assertContains(playerLimitResult.issues,"too many talent points: 72/71","player limit diagnostic")

local petValid=coordinates(1,3)
petValid[#petValid+1]={1,2}
local petValidResult=compile("PET FEROCITY","Pet Valid",petValid)
assertEqual(petValidResult.valid,true,"valid pet prerequisite order")
assertEqual(petValidResult.sequence[4].prerequisiteMaxRank,3,"pet prerequisite max rank captured")
local petPrerequisiteWrongOrder=coordinates(3,3)
petPrerequisiteWrongOrder[#petPrerequisiteWrongOrder+1]={1,2}
for _,point in ipairs(coordinates(1,3)) do petPrerequisiteWrongOrder[#petPrerequisiteWrongOrder+1]=point end
local petPrerequisiteWrongResult=compile("PET FEROCITY","Pet Prerequisite Wrong Order",petPrerequisiteWrongOrder)
assertEqual(petPrerequisiteWrongResult.valid,false,"pet prerequisite wrong order rejected")
assertContains(petPrerequisiteWrongResult.issues,"talent prerequisite unavailable at point 4","pet prerequisite diagnostic")
local petLimit={}
for index=1,7 do for _=1,3 do petLimit[#petLimit+1]={1,index} end end
local petLimitResult=compile("PET FEROCITY","Pet Limit",petLimit)
assertEqual(petLimitResult.valid,false,"pet point limit rejected")
assertContains(petLimitResult.issues,"too many talent points: 21/20","pet limit diagnostic")

playerTalents={{tab=2,index=1,name="Doble empuñadura",maxRank=1,tier=1,column=1,rank=0,meetsPrerequisite=true}}
linkIDs.player={ ["2:1"]=1690 }
Talent.compiled={}
local localized=Talent:RegisterBuild("SHAMAN","Localized (1/0/0)","Unknown alias|Dual Wield")
assertEqual(assert(Talent:Compile(localized)).valid,true,"English alternative resolves to localized live talent by ID")
playerTalents[1].meetsPrerequisite=false
local blockedPoint,blockedReason=Talent:GetNextPoint(localized)
assertEqual(blockedPoint,nil,"live unmet prerequisite suppresses next-point recommendation")
assertEqual(blockedReason,"prerequisite unavailable: Doble empuñadura","live unmet prerequisite diagnostic")
playerTalents[1].meetsPrerequisite=true
assert(Talent:GetNextPoint(localized),"live met prerequisite restores next-point recommendation")

-- Item-score weapon slot behavior uses the same live Talent.dbc IDs.
itemTalentMode=true
function talentService:GetTrees()
  return {{talents={{tab=1,index=1,name="localized",rank=activeTalentRank,maxRank=1,tier=1,column=1}}}}
end
ZygorGuidesViewer.Compat.Tooltip=nil
ZygorGuidesViewer.Debug=nil
function ZygorGuidesViewer.Compat.Item:GetInfo() return {ready=false} end
function ZygorGuidesViewer.Compat.Item:GetStats() return {stats={}} end
DAMAGE_TEMPLATE="%d - %d Damage"
DAMAGE_TEMPLATE_WITH_SCHOOL="%d - %d %s Damage"
WEAPON_SPEED="Speed"
DPS_TEMPLATE="(%.1f damage per second)"
dofile(addon .. "Item-ItemScore.lua")
local ItemScore=ZygorGuidesViewer.ItemScore

activeTalentID,activeTalentRank=1690,0
ItemScore:SetFilters("SHAMAN",2,80)
assertEqual(ItemScore.playerdualwield,false,"Enhancement before Dual Wield")
assertEqual(#ItemScore:GetSlotCandidates("INVTYPE_WEAPON"),1,"Enhancement main-hand candidates before Dual Wield")
local weapon={itemid=1,equipslot="INVTYPE_WEAPON",classID=2,subclassID=0,reqlevel=1,stats={ITEM_MOD_AGILITY_SHORT=10},ilevel=10}
local score,code=ItemScore:GetItemScore(weapon,"INVTYPE_WEAPONOFFHAND")
assertEqual(score,-1,"Enhancement offhand score before Dual Wield")
assertEqual(code,"dual_wield_unavailable","Enhancement offhand rejection code")

activeTalentRank=1
ItemScore:SetFilters("SHAMAN",2,80)
assertEqual(ItemScore.playerdualwield,true,"Enhancement after Dual Wield")
assertEqual(#ItemScore:GetSlotCandidates("INVTYPE_WEAPON"),2,"Enhancement offhand candidates after Dual Wield")
assert(ItemScore:GetItemScore(weapon,"INVTYPE_WEAPONOFFHAND")>0,"Enhancement offhand scores after Dual Wield")

activeTalentID,activeTalentRank=1867,0
ItemScore:SetFilters("WARRIOR",2,80)
assertEqual(ItemScore.playerdual2h,false,"Fury before Titan's Grip")
assertEqual(#ItemScore:GetSlotCandidates("INVTYPE_2HWEAPON"),1,"Fury 2H candidates before Titan's Grip")
activeTalentRank=1
ItemScore:SetFilters("WARRIOR",2,80)
assertEqual(ItemScore.playerdual2h,true,"Fury after Titan's Grip")
assertEqual(#ItemScore:GetSlotCandidates("INVTYPE_2HWEAPON"),2,"Fury 2H candidates after Titan's Grip")

-- Saved custom weights are a profile override, not a mutation of the shared
-- WotLK class tables.  Clearing an override restores the selected role rule.
assert(ItemScore:SetCustomWeight("agility",2.345),"custom stat weight saves")
assertEqual(ItemScore:GetCustomWeight("agility"),2.345,"custom stat weight round-trips")
assertEqual(ItemScore:GetRule().weights.agility,2.345,"custom stat weight affects live scoring")
local imported,count=ItemScore:ImportCustomWeights("Hit Rating=1.8; Agility: 1.25")
assertEqual(imported,true,"custom stat weights import")
assertEqual(count,2,"custom stat-weight import counts recognised values")
assertEqual(ItemScore:GetCustomWeight("Hit Rating"),1.8,"stat alias resolves")
assertEqual(ItemScore:GetCustomWeight("agility"),1.25,"custom import replaces the active profile value")
assertEqual(ItemScore:GetDefaultWeight("Agility"),.92,"default weight remains inspectable")
assert(not ItemScore:SetCustomWeight("not-a-stat",1),"unknown stat is rejected")
assert(not ItemScore:SetCustomWeight("agility",101),"unsafe stat weight is rejected")
assert(ItemScore:ResetCustomWeights(),"custom stat weights reset")
assertEqual(ItemScore:GetCustomWeight("agility"),nil,"reset clears saved override")
assert(ItemScore:GetRule().weights.agility~=2.345,"reset restores WotLK role weight")

-- WoWSims exposes Enhancement's spell and melee rating axes separately.  The
-- client exposes shared rating stats, so the melee values drive this melee
-- build while Spell Damage and distinct main/off-hand DPS stay independent.
ItemScore:SetFilters("SHAMAN",2,80)
assertEqual(ItemScore:GetDefaultWeight("Agility"),1.59,"Enhancement uses supplied WoWSims agility weight")
assertEqual(ItemScore:GetDefaultWeight("Main Hand DPS"),5.21,"Enhancement exposes WoWSims main-hand DPS")
assertEqual(ItemScore:GetDefaultWeight("Off Hand DPS"),2.21,"Enhancement exposes WoWSims off-hand DPS")
assertEqual(ItemScore:GetRule().hitType,"melee","Enhancement uses the melee hit cap")
local applied,preset=ItemScore:ApplyWoWSimsPreset()
assertEqual(applied,true,"Enhancement WoWSims preset applies")
assertEqual(preset,"WoWSims Enhancement Shaman","Enhancement preset identifies its simulator source")
assertEqual(ItemScore:GetEffectiveWeight("Melee Haste"),1.61,"preset retains melee haste")
assertEqual(ItemScore:GetEffectiveWeight("Off Hand DPS"),2.21,"preset retains off-hand DPS")
local simImported,simCount=ItemScore:ImportCustomWeights([[
Strength=1.10; Agility=1.59; Intellect=1.48; Spell Dmg=1.13; Spell Hit=0.00;
Spell Crit=0.91; Spell Haste=0.37; Attack Power=1.00; Melee Hit=1.38;
Melee Crit=0.81; Melee Haste=1.61; Armor Pen=0.48; Expertise=0.00;
Main Hand DPS=5.21; Off Hand DPS=2.21
]])
assertEqual(simImported,true,"WoWSims Enhancement text imports")
assertEqual(simCount,12,"WoWSims import selects the melee rating axis for Enhancement")
assertEqual(ItemScore:GetCustomWeight("Hit Rating"),1.38,"Melee Hit supersedes Spell Hit for Enhancement")
assertEqual(ItemScore:GetCustomWeight("Critical Strike Rating"),.81,"Melee Crit supersedes Spell Crit for Enhancement")
assertEqual(ItemScore:GetCustomWeight("Haste Rating"),1.61,"Melee Haste supersedes Spell Haste for Enhancement")
assertEqual(ItemScore:GetCustomWeight("Off Hand DPS"),2.21,"WoWSims off-hand DPS imports independently")
local dpsItem={stats={DAMAGE_PER_SECOND=10}}
assertEqual(ItemScore:ScoreItemStats(dpsItem,"INVTYPE_WEAPONMAINHAND"),52.1,"main-hand items use main-hand DPS EP")
assertEqual(ItemScore:ScoreItemStats(dpsItem,"INVTYPE_WEAPONOFFHAND"),22.1,"off-hand items use off-hand DPS EP")

print("WotLK talent and weapon tests passed")
