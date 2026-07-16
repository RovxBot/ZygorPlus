local repo = assert(arg[1], "repository path required")
local addon = repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/"

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    error((message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

local modules = {}
ZygorGuidesViewer = {
  Modules = modules,
  Conditions = {},
  Compat = {},
  db = { profile = { questitemcache = {} }, char = {}, global = {} },
  SKINDIR = "",
}
ZGV = ZygorGuidesViewer

function ZGV:RegisterModule(name, module)
  module = module or {}
  modules[name] = module
  self[name] = module
  return module
end
local registeredEvents={}
function ZGV:RegisterEvent(event,owner,method) registeredEvents[event]={owner=owner,method=method} end
function ZGV:RegisterCallback() end
function ZGV:Fire() end
function ZGV:LogInfo() end
function ZGV:LogError() end
function UnitFactionGroup() return "Alliance" end
function GetTime() return 0 end

-- Catalog ordering: explicit folders win, while unlisted leveling leaves keep
-- their source registration order instead of being alphabetized by zone.
dofile(addon .. "Catalog.lua")
dofile(addon .. "GuideSorting.lua")

local Catalog = ZGV.Catalog
Catalog:Register("Titles\\Example", {}, "")
Catalog:Register("Leveling Guides\\The Burning Crusade (60-70)\\Hellfire Peninsula (60-61)", {}, "")
Catalog:Register("Leveling Guides\\Classic (11-60)\\Darkshore (11-14)", {}, "")
Catalog:Register("Leveling Guides\\Classic (11-60)\\Bloodmyst Isle (14-20)", {}, "")
Catalog:Register("Leveling Guides\\Classic (11-60)\\Darkshore (20-21)", {}, "")
Catalog:Register("Zygor's Alliance Leveling Guides\\Northrend (70-72)\\Borean Tundra (70-72)", {}, "")
Catalog:Register("Zygor's Alliance Dailies Guides\\Dalaran\\Cooking Dailies", {}, "")
Catalog:Register("Reputations Guides\\The Burning Crusade\\The Consortium", {}, "")
Catalog:Finalize()

local positions = {}
for index, guide in ipairs(Catalog.sorted) do positions[guide.title] = index end
assert(positions["Leveling Guides\\Classic (11-60)\\Darkshore (11-14)"]
  < positions["Leveling Guides\\The Burning Crusade (60-70)\\Hellfire Peninsula (60-61)"],
  "authored Classic folder order must beat registration order")
assert(positions["Leveling Guides\\Classic (11-60)\\Darkshore (11-14)"]
  < positions["Leveling Guides\\Classic (11-60)\\Bloodmyst Isle (14-20)"],
  "leveling leaves must retain progression registration order")
assert(positions["Leveling Guides\\Classic (11-60)\\Bloodmyst Isle (14-20)"]
  < positions["Leveling Guides\\Classic (11-60)\\Darkshore (20-21)"],
  "revisited zones must not be alphabetically grouped")
assert(positions["Leveling Guides\\Classic (11-60)\\Darkshore (20-21)"]
  < positions["Zygor's Alliance Leveling Guides\\Northrend (70-72)\\Borean Tundra (70-72)"],
  "Wrath continuation must follow the Anniversary leveling category")
assert(positions["Zygor's Alliance Leveling Guides\\Northrend (70-72)\\Borean Tundra (70-72)"]
  < positions["Titles\\Example"], "leveling categories must precede titles")
assertEqual(Catalog.byTitle["Zygor's Alliance Leveling Guides\\Northrend (70-72)\\Borean Tundra (70-72)"].menuTitle,
  "Leveling Guides\\Northrend (70-72)\\Borean Tundra (70-72)", "legacy leveling is folded into the shared menu")
assertEqual(Catalog.byTitle["Zygor's Alliance Dailies Guides\\Dalaran\\Cooking Dailies"].menuCategory,
  "Dailies Guides", "legacy dailies use the shared category")
assertEqual(Catalog.byTitle["Reputations Guides\\The Burning Crusade\\The Consortium"].menuCategory,
  "Reputation Guides", "plural reputation root is normalised")

-- Menu hierarchy: a correctly sorted flat catalog must not be flattened back
-- into one mixed list by the browser.  All Guides shows top-level folders,
-- and Leveling Guides shows its authored expansion folders in order.
ZGV.UI = { SetMode = function() end }
function ZGV:GetSkinData() return nil end
function ZGV:AddMessageHandler() end
dofile(addon .. "ModernGuideMenu.lua")
local Menu = ZGV.GuideMenu
local top = Menu:GetFolderResults("", false)
assertEqual(top[1].openPath, "Leveling Guides", "All Guides starts with the authored leveling folder")
assertEqual(top[2].openPath, "Dailies Guides", "legacy dailies share the common top-level folder")
for _,entry in ipairs(top) do
  assert(entry.openPath ~= "Zygor's Alliance Leveling Guides" and entry.openPath ~= "Zygor's Alliance Dailies Guides",
    "legacy faction folders must not appear as standalone menu categories")
end
local leveling = Menu:GetFolderResults("Leveling Guides", false)
assertEqual(leveling[1].openPath, "Leveling Guides\\Classic (11-60)", "Classic routes are a folder, not mixed leaves")
assertEqual(leveling[2].openPath, "Leveling Guides\\The Burning Crusade (60-70)", "Outland routes follow Classic")
local classic = Menu:GetFolderResults("Leveling Guides\\Classic (11-60)", true)
assert(classic[1].isParent and classic[1].openPath == "Leveling Guides", "nested folders expose a working parent breadcrumb")
assertEqual(classic[2].title, "Leveling Guides\\Classic (11-60)\\Darkshore (11-14)", "leaf order remains authored")

-- Runtime completion: the Classic parser emits a descriptive talk goal next
-- to the actual accept/turn-in goal.  A completed quest must advance that
-- step without requiring another NPC interaction.
local completed, log = {}, {}
ZGV.Compat.Quest = {
  IsCompleted = function(_, id) return completed[tonumber(id)] and true or false, true end,
  FindInLog = function(_, id) return log[tonumber(id)] end,
}
function ZGV.Conditions:Evaluate(expression)
  return expression == "true"
end
function ZGV.Conditions:ItemCount() return 0 end
local hasShadowyDisguise=false
function ZGV.Conditions:HaveBuff(value) return hasShadowyDisguise and (value==32756 or tostring(value):find("Shadowy Disguise",1,true)~=nil) end
local skillRanks,skillMaximums={},{}
function ZGV.Conditions:Skill(name) return skillRanks[tostring(name or ""):lower()] or 0 end
function ZGV.Conditions:SkillMax(name) return skillMaximums[tostring(name or ""):lower()] or 0 end
function ZGV.Conditions:Reputation() return 0 end
local bindLocation="Shattrath City"
function ZGV.Conditions:Bound(name)
  return tostring(name or ""):lower()==bindLocation:lower()
end

dofile(addon .. "Runtime.lua")
local Runtime = ZGV.Runtime
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }
assert(registeredEvents.SKILL_LINES_CHANGED and registeredEvents.TRADE_SKILL_UPDATE,
  "runtime watches profession changes from the 3.3.5a client")

-- Terokkar's disguise retry must remain on its visible `havebuff` objective
-- until the player has the actual aura.  This is the gate that previously
-- auto-ran through blank steps and jumped back to its retry label.
dofile(addon .. "Parser.lua")
local trainerGuide=assert(ZGV.Parser:ParseEntry({
  id="engineering-rank",title="Engineering rank",header={},raw=[[
step
Train Apprentice Engineering |skillmax Engineering,75 |goto Orgrimmar/0 76.18,25.18
step
Open Your Engineering Crafting Panel
]]
}))
local trainerGoal=trainerGuide.steps[1].goals[1]
assertEqual(trainerGoal.action,"skillmax","trainer rank is parsed as a profession-cap goal")
skillRanks.engineering,skillMaximums.engineering=75,0
assertEqual(Runtime:IsGoalComplete(trainerGoal,1,1),false,
  "current Engineering points do not falsely satisfy an untrained rank")
skillMaximums.engineering=75
local trainerComplete,trainerReason=Runtime:IsGoalComplete(trainerGoal,1,1)
assertEqual(trainerComplete,true,"Apprentice Engineering completes when its 75-point cap is trained")
assertEqual(trainerReason,"skillmax","trainer completion reports the profession-cap source")
Runtime.currentGuide,Runtime.currentStep=trainerGuide,1
Runtime.manual={}
Runtime.lastAdvance=GetTime()
Runtime:OnEvent("SKILL_LINES_CHANGED")
assertEqual(Runtime.currentStep,2,"training immediately advances to the next profession stage")
skillRanks.engineering,skillMaximums.engineering=0,0

-- A Hearthstone instruction is useful only when the character is actually
-- bound to the authored destination. Otherwise it must skip to the following
-- goal so regular route planning can direct the player there.
local hearthGuide=assert(ZGV.Parser:ParseEntry({
  id="hearth-runtime",title="Hearth runtime",header={},raw=[[
step
use Hearthstone##6948
Hearth to Thunderlord Stronghold |complete subzone("Thunderlord Stronghold") |q 10505
step
talk Gor'drek##21117 |goto Blade's Edge Mountains/0 52.32,57.75
]]
}))
assertEqual(hearthGuide.steps[1].hearthDestination,"Thunderlord Stronghold",
  "runtime receives the authored hearth destination")
Runtime.currentGuide,Runtime.currentStep=hearthGuide,1
Runtime.lastAdvance=0
assertEqual(Runtime:IsStepApplicable(hearthGuide.steps[1]),false,
  "Shattrath bind makes the Thunderlord hearth step inapplicable")
Runtime:Tick(true)
assertEqual(Runtime.currentStep,2,"mismatched hearth step advances to normal travel target")
bindLocation="Thunderlord Stronghold"
assertEqual(Runtime:IsStepApplicable(hearthGuide.steps[1]),true,
  "matching bind keeps the authored hearth instruction available")
bindLocation="Shattrath City"
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

-- A standalone no-hearth directive may itself be conditional, but that
-- condition must never make the preceding quest objective or its whole step
-- inapplicable. In Blade's Edge this previously skipped the unfinished
-- Bladespire half of quest 10544 as soon as the player left Bloodmaul.
local curseGuide=assert(ZGV.Parser:ParseEntry({
  id="curse-both-clans",title="A Curse Upon Both of Your Clans",header={},raw=[[
step
use Wicked Strong Fetish##30479
kill Bladespire Evil Spirit##21446+
Curse #5# Bladespire Hold Buildings |q 10544/1 |goto Blade's Edge Mountains/0 41.98,57.50
|nohearth |only if subzone("Southmaul Tower") or subzone("Bloodmaul Outpost") or subzone("Bloodmaul Ravine")
step
talk T'chali the Witch Doctor##21349
turnin A Curse Upon Both of Your Clans!##10544 |goto Blade's Edge Mountains/0 44.97,72.30
]]
}))
local curseStep=curseGuide.steps[1]
local curseObjective=curseStep.goals[#curseStep.goals]
assertEqual(curseStep.onlyIf,nil,"conditional no-hearth does not condition the quest step")
assertEqual(curseObjective.onlyIf,nil,"conditional no-hearth does not condition the quest objective")
assertEqual(curseStep.travelConfig.use_hearth,false,"standalone no-hearth still disables hearth routing")
assert(curseStep.travelConfig.noHearthIf and curseStep.travelConfig.noHearthIf:find("Bloodmaul Outpost",1,true),
  "the no-hearth condition remains available as travel metadata")
log[10544]={objectives={{finished=false,current=0,required=5}},complete=false}
Runtime.currentGuide=curseGuide
local curseState=Runtime:GetStepState(curseStep,1)
assertEqual(curseState.complete,false,"unfinished Bladespire buildings block automatic progression")
assertEqual(curseState.skipped,false,"leaving Bloodmaul does not skip the Bladespire objective")
log[10544]=nil
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

local shadowyGuide=assert(ZGV.Parser:ParseEntry({
  id="shadowy-runtime",title="Shadowy runtime",header={},raw=[[
step
label "Gain_Shadowy_Disguise"
talk Scout Neftis##18714
Select _"Scout Neftis, I need another disguise."_ |gossip 118185
Gain the Shadowy Disguise |havebuff Shadowy Disguise##32756 |goto Terokkar Forest/0 39.03,43.75 |q 10041
]]
}))
Runtime.currentGuide=shadowyGuide
local disguiseGoal=shadowyGuide.steps[1].goals[#shadowyGuide.steps[1].goals]
assertEqual(disguiseGoal.action,"havebuff","Terokkar prose becomes a buff objective")
assertEqual(disguiseGoal.haveBuff,32756,"Terokkar buff objective retains spell ID")
local disguiseStep=Runtime:GetStepState(shadowyGuide.steps[1],1)
assertEqual(disguiseStep.complete,false,"Terokkar disguise step waits for the active aura")
assertEqual(disguiseStep.required,1,"only the disguise aura gates the retry step")
hasShadowyDisguise=true
assertEqual(Runtime:IsGoalComplete(disguiseGoal,1,#shadowyGuide.steps[1].goals),true,"active disguise completes the direct objective")
disguiseStep=Runtime:GetStepState(shadowyGuide.steps[1],1)
assertEqual(disguiseStep.complete,true,"Terokkar disguise step completes once the aura is active")
hasShadowyDisguise=false
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

-- An authored city-gate coordinate is an approach hint.  The step completes
-- when the live navigation map says the player entered the city, regardless
-- of which entrance was used.
ZGV.Navigation = {
  IsArrived = function() return false end,
  IsMapTransitionComplete = function(_, transition)
    return transition and transition.kind == "enter" and transition.mapKey == "Stormwind City/0"
  end,
  SetWaypoint = function() return true end,
  ClearWaypoint = function() end,
}
local cityGuide=assert(ZGV.Parser:ParseEntry({
  id="city-transition",title="City transition",header={},raw=[[
step
Enter Stormwind City |goto Elwynn Forest 32.08,49.23 < 30
]],
}))
local cityGoal=cityGuide.steps[1].goals[1]
assertEqual(cityGoal.action,"goto","city gate instruction remains a navigation goal")
assertEqual(cityGoal.mapTransition.kind,"enter","city gate instruction records entry intent")
assertEqual(cityGoal.mapTransition.mapKey,"Stormwind City/0","city gate instruction records the city map")
Runtime.currentGuide=cityGuide
local cityState=Runtime:GetStepState(cityGuide.steps[1],1)
assertEqual(cityState.required,1,"city transition is a required, completable travel step")
assertEqual(cityState.complete,true,"alternate city entry completes the authored gate step")
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

-- A path-following step can contain several `goto` points. Reaching or
-- manually completing the current point must choose the next point without
-- requiring a guide-step change. Completing the final point manually must
-- then advance immediately and rebuild navigation for the following step.
local waypointHistory={}
local currentArrivalX
ZGV.Navigation={
  waypoint=nil,
  IsArrived=function(_,destination) return destination and destination.x==currentArrivalX end,
  IsMapTransitionComplete=function() return false end,
  SetWaypoint=function(self,destination,title)
    self.waypoint=destination
    waypointHistory[#waypointHistory+1]={destination=destination,title=title}
    return true
  end,
  ClearWaypoint=function(self) self.waypoint=nil end,
}
Runtime.manual={}
Runtime.arrivals={}
Runtime.waypointGoalKey=nil
Runtime.currentGuide={id="movement-path",title="Movement path",conditionIssues={},steps={
  {goals={
    {action="goto",text="Follow the path",destination={mapKey="Nagrand/0",x=.10,y=.10}},
    {action="goto",text="Follow the path up",destination={mapKey="Nagrand/0",x=.20,y=.20}},
  }},
  {goals={
    {action="talk",text="Talk to the quest giver",npcID=123,destination={mapKey="Nagrand/0",x=.30,y=.30}},
    {action="accept",text="Accept the next quest",questID=999,destination={mapKey="Nagrand/0",x=.30,y=.30}},
  }},
}}
Runtime.currentStep=1
Runtime.lastAdvance=0
Runtime:UpdateWaypoint()
assertEqual(waypointHistory[#waypointHistory].destination.x,.10,"first path point is selected")
currentArrivalX=.10
Runtime:Tick()
assertEqual(Runtime.currentStep,1,"reaching an intermediate path point keeps its guide step active")
assertEqual(waypointHistory[#waypointHistory].destination.x,.20,"arrival points navigation at the next path point")
currentArrivalX=nil
local firstComplete=Runtime:IsGoalComplete(Runtime.currentGuide.steps[1].goals[1],1,1)
assertEqual(firstComplete,true,"reached path point remains complete after the player moves away")
Runtime:UpdateWaypoint()
assertEqual(waypointHistory[#waypointHistory].destination.x,.20,"moving away does not reactivate the reached path point")
currentArrivalX=.20
Runtime:Tick(true)
assertEqual(Runtime.currentStep,2,"reaching the final path point advances immediately")
assertEqual(waypointHistory[#waypointHistory].destination.x,.30,"automatic path completion points to the next talk target")
assertEqual(waypointHistory[#waypointHistory].title,"Talk to the quest giver","automatic completion rebuilds the next goal title")

Runtime.manual={}
Runtime.arrivals={}
Runtime.waypointGoalKey=nil
Runtime.currentStep=1
currentArrivalX=nil
Runtime:UpdateWaypoint()
assert(Runtime:ActivateGoal(1,1),"manual completion accepts the first path point")
assertEqual(Runtime.currentStep,1,"manual intermediate completion keeps its guide step active")
assertEqual(waypointHistory[#waypointHistory].destination.x,.20,"manual completion points to the next path point")
assert(Runtime:ActivateGoal(1,2),"manual completion accepts the final path point")
assertEqual(Runtime.currentStep,2,"manual final path completion advances immediately")
assertEqual(waypointHistory[#waypointHistory].destination.x,.30,"manual final completion points to the next guide step")
assertEqual(waypointHistory[#waypointHistory].title,"Talk to the quest giver","manual completion rebuilds the next goal title")
ZGV.Navigation={
  IsArrived=function() return false end,
  IsMapTransitionComplete=function(_,transition)
    return transition and transition.kind=="enter" and transition.mapKey=="Stormwind City/0"
  end,
  SetWaypoint=function() return true end,
  ClearWaypoint=function() end,
}
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

-- Manual Next must honour conditional branch order instead of forcing the
-- first retry label.  A historical quest can be absent from both the log and
-- a private-server completion snapshot, so a non-active Terokkar quest takes
-- the hand-in continuation.
function ZGV.Conditions:Evaluate(expression)
  if expression=="havequest(10041) and not readyq(10041)" then return false end
  if expression=="readyq(10041) or not havequest(10041)" then return true end
  if expression=="not completedq(10041)" then return true end
  return expression=="true"
end
local terokkarBranch=assert(ZGV.Parser:ParseEntry({
  id="terokkar-branch",title="Terokkar branch",header={},raw=[[
step
label "Gain_Shadowy_Disguise"
step
'|complete havequest(10041) and not readyq(10041) |or |next "Gain_Shadowy_Disguise"
'|complete readyq(10041) or not havequest(10041) |or |next "Finished_Who_Are_They_Quest"
|only if not completedq(10041)
step
label "Finished_Who_Are_They_Quest"
]]
}))
Runtime.currentGuide,Runtime.currentStep=terokkarBranch,2
assert(Runtime:NextStep(true),"manual Next resolves the Terokkar branch")
assertEqual(Runtime.currentStep,3,"non-active completed quest advances to the hand-in step")
function ZGV.Conditions:Evaluate(expression) return expression == "true" end
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

completed[42] = true
local completedAcceptStep = { goals = {
  { action = "talk", npcID = 100, text = "Talk to Example" },
  { action = "accept", questID = 42, text = "Accept Example" },
} }
local state = Runtime:GetStepState(completedAcceptStep, 1)
assert(state.complete, "completed accept must not be blocked by its companion talk line")
assertEqual(state.required, 1, "bare talk is descriptive rather than a second requirement")
assertEqual(state.done, 1, "completed accept supplies the step completion")

local talkComplete, talkReason = Runtime:IsGoalComplete(completedAcceptStep.goals[1], 1, 1)
assertEqual(talkComplete, false, "bare talk does not invent historical completion")
assertEqual(talkReason, "not-completable", "bare talk uses the Classic descriptive contract")

completed[43] = true
local questTalk = { action = "talk", npcID = 101, questID = 43 }
local questTalkComplete, questTalkReason = Runtime:IsGoalComplete(questTalk, 2, 1)
assertEqual(questTalkComplete, true, "quest-bound talk skips after quest hand-in")
assertEqual(questTalkReason, "quest-completed", "quest-bound talk reports its completion source")

log[44] = { objectives = { { current = 1, required = 1, finished = true } } }
local objectiveTalk = { action = "talk", npcID = 102, questID = 44, objective = 1 }
local objectiveComplete, objectiveReason = Runtime:IsGoalComplete(objectiveTalk, 3, 1)
assertEqual(objectiveComplete, true, "quest-objective talk follows objective completion")
assertEqual(objectiveReason, "quest", "objective completion is attributed to the quest log")

-- A large group of Classic guide steps carries the objective on a final
-- prose/goal line, while its visible use/kill/collect/click instructions are
-- separate unbound actions.  Completing the real WotLK quest objective must
-- tick those companions and cannot leave an unmeasurable action blocking the
-- step (Terokkar's Rod of Purification and Veil Skith cages are examples).
log[10839] = { objectives = { { current = 1, required = 1, finished = true } } }
local darkstone = Runtime:GetStepState({ goals = {
  { action = "use", itemID = 31610, text = "Use Rod of Purification" },
  { action = "goal", questID = 10839, objective = 1, text = "Attempt to purify the Darkstone" },
} }, 31)
assertEqual(darkstone.goals[1].complete, true, "completed Darkstone objective ticks the Rod instruction")
assertEqual(darkstone.goals[1].reason, "step-objective", "Rod completion is sourced from its step objective")
assertEqual(darkstone.complete, true, "Rod instruction cannot block the completed Darkstone step")

log[10852] = { objectives = { { current = 12, required = 12, finished = true } } }
local rescue = Runtime:GetStepState({ goals = {
  { action = "kill", npcID = 18452, text = "Kill Skithian Dreadhawk", forceNoComplete = true },
  { action = "collect", itemID = 31655, text = "Collect Veil Skith Prison Key", forceNoComplete = true },
  { action = "click", objectID = 1787, text = "Click Veil Skith Cage" },
  { action = "goal", questID = 10852, objective = 1, text = "Rescue 12 Children" },
} }, 32)
for index = 1, 3 do
  assertEqual(rescue.goals[index].complete, true, "completed Rescue Children objective ticks companion " .. index)
  assertEqual(rescue.goals[index].reason, "step-objective", "Rescue Children companion uses its shared objective")
end
assertEqual(rescue.complete, true, "completed Rescue Children objective clears its entire step")

log[10853] = { objectives = { { current = 1, required = 1, finished = true } } }
log[10854] = { objectives = { { current = 1, required = 1, finished = true } } }
local multiObjective = Runtime:GetStepState({ goals = {
  { action = "use", itemID = 1, text = "Unbound action" },
  { action = "goal", questID = 10853, objective = 1 },
  { action = "goal", questID = 10854, objective = 1 },
} }, 33)
assertEqual(multiObjective.goals[1].complete, false, "multi-objective steps do not guess an unbound action's owner")

completed[45] = true
local conditionedQuestGoal = { action = "talk", npcID = 103, questID = 45, expression = "false" }
assert(Runtime:IsGoalComplete(conditionedQuestGoal, 4, 1),
  "attached completed quest falls through a currently-false secondary condition")

local talkOnly = Runtime:GetStepState({ goals = { { action = "talk", npcID = 104 } } }, 5)
assertEqual(talkOnly.complete, false, "a descriptive-only talk step remains visible for manual navigation")
assertEqual(talkOnly.required, 0, "a descriptive-only talk step is not an automatic gate")

completed[46] = true
local completedGossipStep = Runtime:GetStepState({ goals = {
  { action = "gossip", gossipText = "Tell me more" },
  { action = "turnin", questID = 46 },
} }, 6)
assert(completedGossipStep.complete, "passive gossip must not block a completed hand-in")
assertEqual(completedGossipStep.required, 1, "passive gossip is not an extra requirement")

-- 3.3.5a's completed-quest snapshot is asynchronous and can still be stale
-- immediately after GetQuestReward.  The real reward confirmation must tick
-- the active hand-in right away, while the hand-in remains a visible goal
-- before that confirmation.
completed[47] = nil
Runtime.currentGuide = { id = "turnin-reward", title = "Turn-in reward", conditionIssues = {}, steps = {
  { goals = {
    { action = "talk", npcID = 106, text = "Talk to the quest giver" },
    { action = "turnin", questID = 47, target = "Turn In Test", text = "Turn in Turn In Test" },
  } },
} }
Runtime.currentStep = 1
local handinDisplay = Runtime:GetDisplayGoals(1)
assertEqual(handinDisplay[2].goal.action, "turnin", "active hand-in is displayed before reward confirmation")
assertEqual(handinDisplay[2].state.complete, false, "unturned quest stays incomplete")
assert(Runtime:RememberTurnIn(47, "Turn In Test"), "reward pane identifies the active guide hand-in")
assert(Runtime:RecordTurnIn(nil, nil, "test reward"), "reward confirmation credits the active hand-in")
local rewardedHandin = Runtime:GetStepState(Runtime.currentGuide.steps[1], 1)
assertEqual(rewardedHandin.goals[2].complete, true, "rewarded hand-in is marked complete immediately")
assert(rewardedHandin.complete, "rewarded hand-in advances its guide step")

completed[48] = true
Runtime.currentGuide = { id = "repeatable-turnin", title = "Repeatable turn-in", conditionIssues = {} }
local repeatableDone = Runtime:IsGoalComplete({ action = "turnin", questID = 48, repeatable = true }, 1, 1)
assertEqual(repeatableDone, false, "completed history never skips a fresh repeatable hand-in")
Runtime.currentGuide = { id = "runtime-test", title = "Runtime test", conditionIssues = {} }

-- The public Goal model must expose the same passive status used by the
-- Classic viewer, rather than painting companion talk/gossip lines red.
dofile(addon .. "ModernModel.lua")
dofile(addon .. "Goal.lua")
local publicTalk = ZGV.Goal:New({ action = "talk", npcID = 104 })
local publicStep = { num = 7, goals = { publicTalk }, parentGuide = Runtime.currentGuide }
publicTalk.parentStep, publicTalk.num = publicStep, 1
assertEqual(publicTalk:IsCompleteable(), false, "public bare-talk goal is passive")
assertEqual(publicTalk:GetStatus(), "passive", "public bare-talk status matches Classic")

local publicQuestTalk = ZGV.Goal:New({ action = "talk", npcID = 105, questID = 43 })
publicQuestTalk.parentStep, publicQuestTalk.num = { num = 8, goals = { publicQuestTalk }, parentGuide = Runtime.currentGuide }, 1
assertEqual(publicQuestTalk:IsCompleteable(), true, "quest-bound talk remains completable")
assertEqual(publicQuestTalk:GetStatus(), "complete", "completed quest-bound talk renders complete")

local publicTransition = ZGV.Goal:New({ action = "text", mapTransition = { kind = "enter", mapKey = "Stormwind City/0" } })
publicTransition.parentStep, publicTransition.num = { num = 9, goals = { publicTransition }, parentGuide = Runtime.currentGuide }, 1
assertEqual(publicTransition:IsCompleteable(), true, "city transition prose is an actionable travel goal")
assertEqual(publicTransition:GetStatus(), "complete", "entered city renders the travel goal complete")

-- Item-Quest regression: Runtime.currentStep is an index, not a step table.
ZGV.ItemScore = {
  GetItemDetails = function() return nil end,
  Upgrades = { IsUpgrade = function() return false, nil, 0 end },
}
dofile(addon .. "Item-Quest.lua")
local QuestItem = ZGV.QuestItem
local guide = { steps = {
  { goals = {} },
  { goals = { { questID = 900 }, { action = "equip", itemID = 12345 } } },
} }
Runtime.currentGuide, Runtime.currentStep = guide, 2
local questID, itemID = QuestItem:TestCurStepForQuestItem()
assertEqual(questID, 900, "numeric currentStep resolves through currentGuide.steps")
assertEqual(itemID, 12345, "quest equipment is found on the resolved step")

local foundQuest, foundItem
function QuestItem:FoundQuestItemForCurStep(qid, iid) foundQuest, foundItem = qid, iid; return true end
QuestItem:OnStepChanged(guide, 2)
assertEqual(foundQuest, 900, "step-changed callback accepts the runtime guide/index tuple")
assertEqual(foundItem, 12345, "step-changed callback inspects the selected step table")

print("runtime quest completion and catalog sorting tests passed")
