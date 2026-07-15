-- Anniversary Goal entry points backed by the root WotLK model/runtime.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local Goal=ZGV and (ZGV.GoalProto or ZGV.Goal)
if type(Goal)~="table" then return end

ZGV.GoalProto=Goal

-- The Anniversary parser exposed these aliases through GOALTYPES.  The WotLK
-- parser does not consume GOALTYPES, but older integrations still inspect it.
ZGV.GOALTYPES=ZGV.GOALTYPES or {}
ZGV.GOALTYPES.get=ZGV.GOALTYPES.get or {}
ZGV.GOALTYPES.learnmount=ZGV.GOALTYPES.learnmount or ZGV.GOALTYPES.get
ZGV.GOALTYPES.learnpet=ZGV.GOALTYPES.learnpet or ZGV.GOALTYPES.get
ZGV.GOALTYPES.earn=ZGV.GOALTYPES.earn or ZGV.GOALTYPES.get

if type(Goal.GetQuestGoalData)~="function" then
  function Goal.GetQuestGoalData(questID,objectiveIndex,count)
    questID,objectiveIndex=tonumber(questID),tonumber(objectiveIndex)
    if not questID or not objectiveIndex then return nil end
    if type(ZGV.QuestTracking_CacheQuestLog)=="function" and not (ZGV.questsbyid and ZGV.questsbyid[questID]) then
      ZGV:QuestTracking_CacheQuestLog("Code-TBC Goal adapter")
    end
    local quest=ZGV.questsbyid and ZGV.questsbyid[questID]
    local objective=quest and quest.goals and quest.goals[objectiveIndex]
    if not objective then return nil end
    local current=tonumber(objective.num) or 0
    local required=math.min(tonumber(count) or math.huge,tonumber(objective.needed) or math.huge)
    if required==math.huge then required=tonumber(count) or 1 end
    return current,required,math.max(0,required-current)
  end
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.Goal=Goal
