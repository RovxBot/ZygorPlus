local repo=assert(arg[1],"repository root is required")

INVSLOT_MAINHAND=16; INVSLOT_OFFHAND=17; INVSLOT_RANGED=18
INVSLOT_HEAD=1; INVSLOT_NECK=2; INVSLOT_SHOULDER=3; INVSLOT_BACK=15
INVSLOT_CHEST=5; INVSLOT_WRIST=9; INVSLOT_HAND=10; INVSLOT_WAIST=6
INVSLOT_LEGS=7; INVSLOT_FEET=8; INVSLOT_FINGER1=11; INVSLOT_TRINKET1=13
IsAltKeyDown=function() return false end

local calls={}
local function hit(name) calls[name]=(calls[name] or 0)+1 end
local knownTaxi={}
local factionCache=function() return "root faction" end
local questSkip=function() return "root quest skip" end
local tracking={watched={}}
local previewShow=function() return "root preview" end
local scoreItem=function() return 42 end
local frame={hidden=false,shown=true}
function frame:Hide() self.hidden=true end
function frame:IsShown() return self.shown end

local Taxi={}
function Taxi:Startup(saved) hit("taxi_startup"); self.saved=saved; return true end

local Profession={recipe={spellID=100,name="Copper Bar"}}
function Profession:RefreshRecipes() hit("recipes"); return {[100]=self.recipe} end
function Profession:Find(skill) return skill=="Alchemy" and {name=skill} or nil end
function Profession:FindRecipe(spell) return tonumber(spell)==100 and self.recipe or nil end

local ItemScore={
  rules={WARRIOR={{role="melee",weights={strength=1,hit=.5}}}},
  GearFinder={},
  GetItemScore=scoreItem,
}
function ItemScore:SetFilters()
  hit("filters"); self.playerdualwield=true; self.playerdual2h=true
  return self.rules.WARRIOR[1]
end
function ItemScore:GetSlotCandidates(kind)
  hit("slot_candidates")
  if kind=="INVTYPE_WEAPON" then return {16,17} end
  return {16}
end

local GearFinder=ItemScore.GearFinder
function GearFinder:CreateFrame() hit("gear_create"); self.frame=frame; return frame end
function GearFinder:Show() hit("gear_show"); self.frame=frame; return frame end
function GearFinder:Render() hit("gear_render") end

local PointerMap={Instances={[33]={name="Shadowfang Keep"}},ShowPreview=previewShow}
function PointerMap:UpdateSettings() hit("preview_settings"); return true end
function PointerMap:OnEvent(event) calls.preview_event=event; return event end

local Navigation={mapPins={}}
function Navigation:EnsureMapPins(count)
  while #self.mapPins<count do self.mapPins[#self.mapPins+1]={index=#self.mapPins+1} end
end
function Navigation:ClearExternalMarkers(owner) calls.clear_owner=owner end
function Navigation:CreateMapPin() hit("map_pin") end
function Navigation:UpdateMapLines(points) calls.map_line_points=points end

local selectedGuide={title="Suggested"}
local Runtime={}
function Runtime:ChooseSuggestedGuide() hit("suggest"); return selectedGuide end
function Runtime:SelectGuide(guide,step) calls.selected={guide=guide,step=step}; return true end
function Runtime:GetStepState() return {complete=true,skipped=false,required=1} end
function Runtime:Tick() hit("runtime_tick") end

local ZGV={
  db={profile={gear={enabled=true},navigation={knownTaxi=knownTaxi}},char={SISquests={},SISguides={},SISdestination={},SISstarted=true}},
  Faction={CacheRepByID=factionCache},Goal={},QuestTracking=tracking,
  QuestDB={MaybeSkipThisGoal=questSkip},ItemScore=ItemScore,PointerMap=PointerMap,
  Professions={tradeskills={[171]={name="Alchemy"}}},Navigation=Navigation,Runtime=Runtime,
  Catalog={Get=function(_,value) return value=="Suggested" and selectedGuide or nil end},
  Chains={[3]=2,[2]=1},RevChains={[1]={2},[2]={3}},ChainsBreadcrumbs={},
  questsbyid={[77]={inlog=true,goals={{num=2,needed=5}}}},
  Compat={
    Taxi=Taxi,Profession=Profession,
    Quest={IsCompleted=function() return false end},
    Map={GetSelected=function() return {key="1:2",continent=1,zone=2} end},
  },
}
ZGV.QuestAutoAccept={Gossip=function() hit("gossip"); return true end}
function ZGV:QuestTracking_CacheQuestLog() hit("quest_cache"); return self.questsbyid end
function ZGV:RegisterModule() error("Code-TBC shim attempted duplicate module registration",2) end

ZygorGuidesViewer=ZGV
_G.ZygorGuidesViewer=ZGV

local directory=repo.."/ZygorGuidesViewer/ZygorGuidesViewer/Code-TBC/"
local files={
  "QuestTracking.lua","Faction.lua","Profession.lua","QuestAutoAccept.lua","QuestDB.lua","Goal.lua",
  "PointerMap.lua","Item-DataTables.lua","Item-ItemScore.lua","Item-GearFinder.lua","InitialFlightPaths.lua",
}
for _,name in ipairs(files) do
  local chunk,errorMessage=loadfile(directory..name)
  assert(chunk,errorMessage)
  local ok,runtimeError=pcall(chunk,"ZygorGuidesViewer",ZGV)
  assert(ok,name..": "..tostring(runtimeError))
end

assert(ZGV.Faction.CacheRepByID==factionCache,"Faction shim replaced the root implementation")
assert(ZGV.Faction.ReputationTypes.faction.standings[8].name=="Exalted")
assert(ZGV.GoalProto==ZGV.Goal,"GoalProto is not the root Goal model")
assert(ZGV.GOALTYPES.learnmount==ZGV.GOALTYPES.get and ZGV.GOALTYPES.earn==ZGV.GOALTYPES.get)
local current,required,remaining=ZGV.Goal.GetQuestGoalData(77,1,4)
assert(current==2 and required==4 and remaining==2,"legacy quest goal progress was not adapted")

assert(ZGV.InitialFlightPaths==Taxi and Taxi.saved==knownTaxi and calls.taxi_startup==1)
do
  local delayedTaxi={}
  function delayedTaxi:Startup(saved) self.saved=saved end
  local delayed={Compat={Taxi=delayedTaxi}}
  function delayed:RegisterCallback(event,callback) self.callbackEvent,self.callback=event,callback end
  local chunk=assert(loadfile(directory.."InitialFlightPaths.lua"))
  assert(pcall(chunk,"ZygorGuidesViewer",delayed))
  assert(delayed.callbackEvent=="ZGV_STARTED" and type(delayed.callback)=="function")
  local delayedKnown={Stormwind=true}
  delayed.db={profile={navigation={knownTaxi=delayedKnown}}}
  assert(delayed.callback()==true and delayedTaxi.saved==delayedKnown)
end
assert(ItemScore.GetItemScore==scoreItem,"ItemScore shim replaced scoring")
assert(ItemScore.KnownKeyWords.SPELL_POWER=="Spell Power")
assert(ItemScore.Item_Armor_Types[4]=="PLATE" and ItemScore.TypeToSlot.INVTYPE_RELIC==18)
assert(ItemScore.Item_Weapon_Types[18]=="CROSSBOW" and ItemScore.SkillNamesByID[226]=="CROSSBOW")
local dual,twoHand=ItemScore:SetDualWield()
assert(dual and twoHand and calls.filters==1)
local first,second,isTwoHand=ItemScore:GetValidSlots({type="INVTYPE_WEAPON"})
assert(first==16 and second==17 and not isTwoHand and calls.slot_candidates==1)
assert(ItemScore.Builds.WARRIOR[1]=="Melee" and ItemScore.Defaults.WARRIOR[1][1])

assert(GearFinder:Initialise()==frame and calls.gear_create==1)
assert(GearFinder:ShowFinder()==frame and calls.gear_show==1)
assert(GearFinder:IsEnabled()==true)
ZGV.db.profile.gear.enabled=false
assert(GearFinder:UpdateSystemTab()==false and frame.hidden,"disabled Gear Finder did not hide")

assert(PointerMap.ShowPreview==previewShow,"PointerMap shim replaced the preview implementation")
assert(PointerMap:ParsePoints()==PointerMap.Instances)
assert(PointerMap:GetIconFromPool().index==1)
assert(#PointerMap.IconPool==1)
assert(PointerMap:ShowLine(.1,.2,.3,.4)==true and #calls.map_line_points==2)
PointerMap:RemoveAllIcons(); assert(calls.clear_owner=="Code-TBC.PointerMap" and #PointerMap.IconPool==0)
assert(PointerMap:UpdateDevSettings()==true and calls.preview_settings==1)
assert(PointerMap.EventHandler(PointerMap,"PLAYER_STARTED_MOVING")=="PLAYER_STARTED_MOVING")

assert(ZGV:CacheRecipes_Queued()[100]==Profession.recipe and calls.recipes==1)
assert(ZGV:CacheRecipesCraft()[100]==Profession.recipe and calls.recipes==2)
assert(ZGV.Professions:GoalRecipe("Alchemy",100)==Profession.recipe)
assert(ZGV.Professions.LocaleSkills.Alchemy=="Alchemy" and ZGV.Professions.LocaleSkillsR.Alchemy==171)
ZGV:Profession_NEW_RECIPE_LEARNED(nil,100)
assert(ZGV.recentlyLearnedRecipes[100] and calls.recipes==3)

assert(ZGV:QuestAutoAccept_InGossip()==true and ZGV:QuestAutoTurnin_InGossip()==true and calls.gossip==2)
assert(ZGV.QuestDB.MaybeSkipThisGoal==questSkip,"QuestDB shim replaced root completion behavior")
local past=ZGV.QuestDB:GetChain(3)
assert(past[1] and past[2] and past[3],"prerequisite traversal is incomplete")
local seeded=ZGV.QuestDB:GetChain(3,nil,{[3]="guide"})
assert(seeded[3]=="guide","chain adapter overwrote caller annotations")
ZGV.ChainsBreadcrumbs[2]=true
local breadcrumb=ZGV.QuestDB:GetChain(2)
assert(not breadcrumb[2] and not breadcrumb[1],"breadcrumb should terminate prerequisite traversal")
ZGV.ChainsBreadcrumbs[2]=nil
local future=ZGV.QuestDB:GetChainFuture(1)
assert(future[1] and future[2] and future[3],"successor traversal is incomplete")
assert(ZGV.QuestDB:FindStartingPoint(nil,4)==true)
assert(calls.selected.guide==selectedGuide and calls.selected.step==4)
assert(ZGV.QuestDB:GetStepTag({num=1})=="Complete")
assert(ZGV.QuestDB:Cancel()==true and ZGV.db.char.SISstarted==nil and calls.runtime_tick==1)

assert(ZGV.CodeTBCCompat.QuestTracking==tracking,"QuestTracking root object was not retained")
for _,name in ipairs({"Faction","Goal","InitialFlightPaths","ItemDataTables","ItemScore","GearFinder","PointerMap","Profession","QuestAutoAccept","QuestDB","QuestTracking"}) do
  assert(ZGV.CodeTBCCompat[name],"missing Code-TBC facade marker: "..name)
end

print("Code-TBC mirror compatibility tests passed")
