local repo = assert(arg[1], "repository path is required")
local addon = repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/"

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2) end
end

local events = {}
local activeGoal
local dialogID, dialogTitle
local calls = {accept=0,progress=0,complete=0,gossipAvailable=0,gossipActive=0}

ZygorGuidesViewer = {
  db = {profile={automation={accept=true,progress=true,turnin=true,gossip=true,autoSelectReward=false,questRewardHint=true}}},
  Compat = {Quest={}},
  Runtime = {currentGuide={}},
}
ZGV = ZygorGuidesViewer
function ZGV:RegisterModule(name,module) self[name]=module return module end
function ZGV:RegisterEvent(event,owner,method) events[event]={owner=owner,method=method} end
function ZGV:Debug() end
function ZGV.Compat.Quest:GetDialog() return {questID=dialogID,title=dialogTitle} end
function ZGV.Runtime:GetActiveSteps() return {{index=1,step={goals={activeGoal}}}} end
function ZGV.Runtime:IsGoalApplicable() return true end
function ZGV.Runtime:IsGoalComplete() return false end

function time() return 100 end
function GetTime() return 100 end
function IsAltKeyDown() return false end
function IsQuestCompletable() return true end
function GetNumQuestChoices() return 0 end
function AcceptQuest() calls.accept=calls.accept+1 end
function CompleteQuest() calls.progress=calls.progress+1 end
function GetQuestReward() calls.complete=calls.complete+1 end
function GetNumGossipAvailableQuests() return 1 end
function GetGossipAvailableQuests() return "Accept Test",80,false,false,false end
function SelectGossipAvailableQuest() calls.gossipAvailable=calls.gossipAvailable+1 end
function GetNumGossipActiveQuests() return 1 end
function GetGossipActiveQuests() return "Turn In Test",80,false,true end
function SelectGossipActiveQuest() calls.gossipActive=calls.gossipActive+1 end

dofile(addon .. "QuestAutoAccept.lua")
local QuestAuto = assert(ZGV.QuestAuto)

local function reset(goal,id,title)
  activeGoal=goal
  dialogID,dialogTitle=id,title
  QuestAuto.lastAction=0
  QuestAuto.lastDecline=0
end

local acceptGoal={action="accept",questID=101,questTitle="Accept Test",text="Accept Accept Test"}
local turninGoal={action="turnin",questID=202,questTitle="Turn In Test",text="Turn in Turn In Test"}

Questie={db={profile={autoaccept=true,autocomplete=false}}}
reset(acceptGoal,101,"Accept Test")
local ok,reason=QuestAuto:Detail()
assertEqual(ok,false,"Questie autoaccept suppresses Zygor detail")
assertEqual(reason,"questie_automation","accept suppression reason")
assertEqual(calls.accept,0,"suppressed AcceptQuest count")

reset(turninGoal,202,"Turn In Test")
assertEqual(QuestAuto:Progress(),true,"Questie autoaccept does not suppress Zygor progress")
assertEqual(calls.progress,1,"progress runs when Questie autocomplete is false")
reset(turninGoal,202,"Turn In Test")
assertEqual(QuestAuto:Complete(),true,"Questie autoaccept does not suppress Zygor completion")
assertEqual(calls.complete,1,"turn-in runs when Questie autocomplete is false")

reset(acceptGoal,101,"Accept Test")
ok,reason=QuestAuto:Gossip()
assertEqual(ok,false,"Questie autoaccept suppresses shared gossip")
assertEqual(reason,"questie_automation","gossip accept suppression reason")
assertEqual(calls.gossipAvailable,0,"suppressed available gossip selection")

Questie.db.profile.autoaccept=false
Questie.db.profile.autocomplete=true
reset(acceptGoal,101,"Accept Test")
assertEqual(QuestAuto:Detail(),true,"Questie autocomplete does not suppress Zygor accept")
assertEqual(calls.accept,1,"accept resumes when Questie autoaccept is false")

reset(turninGoal,202,"Turn In Test")
ok,reason=QuestAuto:Progress()
assertEqual(ok,false,"Questie autocomplete suppresses Zygor progress")
assertEqual(reason,"questie_automation","progress suppression reason")
assertEqual(calls.progress,1,"suppressed CompleteQuest count")
reset(turninGoal,202,"Turn In Test")
ok,reason=QuestAuto:Complete()
assertEqual(ok,false,"Questie autocomplete suppresses Zygor completion")
assertEqual(reason,"questie_automation","completion suppression reason")
assertEqual(calls.complete,1,"suppressed GetQuestReward count")

reset(turninGoal,202,"Turn In Test")
ok,reason=QuestAuto:Gossip()
assertEqual(ok,false,"Questie autocomplete suppresses shared gossip")
assertEqual(reason,"questie_automation","gossip completion suppression reason")
assertEqual(calls.gossipActive,0,"suppressed active gossip selection")

Questie.db.profile.autocomplete=false
reset(acceptGoal,101,"Accept Test")
assertEqual(QuestAuto:Detail(),true,"Zygor accept resumes with Questie automation disabled")
assertEqual(calls.accept,2,"resumed AcceptQuest count")
reset(turninGoal,202,"Turn In Test")
assertEqual(QuestAuto:Progress(),true,"Zygor progress resumes with Questie automation disabled")
assertEqual(calls.progress,2,"resumed CompleteQuest count")
reset(turninGoal,202,"Turn In Test")
assertEqual(QuestAuto:Complete(),true,"Zygor completion resumes with Questie automation disabled")
assertEqual(calls.complete,2,"resumed GetQuestReward count")
reset(acceptGoal,101,"Accept Test")
assertEqual(QuestAuto:Gossip(),true,"Zygor available gossip resumes with Questie automation disabled")
assertEqual(calls.gossipAvailable,1,"resumed available gossip selection")
reset(turninGoal,202,"Turn In Test")
assertEqual(QuestAuto:Gossip(),true,"Zygor active gossip resumes with Questie automation disabled")
assertEqual(calls.gossipActive,1,"resumed active gossip selection")

Questie=nil
reset(acceptGoal,101,"Accept Test")
assertEqual(QuestAuto:Detail(),true,"missing Questie does not suppress Zygor")
assertEqual(calls.accept,3,"missing Questie AcceptQuest count")

print("Questie automation coexistence tests passed")
