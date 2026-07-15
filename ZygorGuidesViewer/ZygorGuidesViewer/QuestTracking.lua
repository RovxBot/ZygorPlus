-- Native WotLK quest-watch integration for the active modern guide step.
local addonName, addonNamespace = ...
local ZGV
if type(addonNamespace) == "table" then
  ZGV = addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV
end
if not ZGV then ZGV = _G.ZygorGuidesViewer end
if type(ZGV) ~= "table" then return end
local Tracking = ZGV:RegisterModule("QuestTracking", { watched = {}, pending = false })

local questActions = {
  accept = true,
  turnin = true,
  havequest = true,
  nothavequest = true,
  notcompleted = true,
  kill = true,
  collect = true,
  use = true,
  click = true,
  clicknpc = true,
  goal = true,
}

local function activeStep()
  local runtime = ZGV.Runtime
  local guide = runtime and runtime.currentGuide
  return guide and guide.steps[runtime.currentStep], runtime
end

function Tracking:CollectActiveQuestIDs()
  local step, runtime = activeStep()
  local ids, seen = {}, {}
  if not step then return ids end
  for index = 1, #step.goals do
    local goal = step.goals[index]
    local id = tonumber(goal.questID)
    if id and not seen[id] and questActions[goal.action] and runtime:IsGoalApplicable(goal) then
      local complete = runtime:IsGoalComplete(goal, runtime.currentStep, index)
      if not complete then
        ids[#ids + 1] = id
        seen[id] = true
      end
    end
  end
  return ids
end

function Tracking:Update()
  self.pending = false
  local profile = ZGV.db and ZGV.db.profile.tracking
  if not profile or not profile.enabled then return end
  local quest = ZGV.Compat and ZGV.Compat.Quest
  if not quest then return end

  local watched = {}
  local questieLoaded = ZGV.QuestieIntegration and ZGV.QuestieIntegration:OwnsQuestWatch()
  if questieLoaded==nil then
    questieLoaded = (_G.Questie ~= nil)
      or (type(IsAddOnLoaded) == "function" and (IsAddOnLoaded("Questie-335") or IsAddOnLoaded("Questie")))
  end
  for _, id in ipairs(self:CollectActiveQuestIDs()) do
    local active = quest:IsOnQuest(id)
    if active then
      watched[id] = true
      -- AddQuestWatch mutates the one Blizzard tracker shared by Questie and
      -- every other quest addon.  Leave it alone when Questie is present; the
      -- Zygor viewer already renders these objectives from its own cache.
      if profile.watchActive and not questieLoaded then quest:AddWatch(id) end
    end
  end
  self.watched = watched
  ZGV:Fire("ZGV_QUEST_TRACKING_UPDATED", watched)
end

function Tracking:QueueUpdate()
  if self.pending then return end
  self.pending = true
  if ZGV.Compat and ZGV.Compat.Timer then
    ZGV.Compat.Timer:After(.1, function() Tracking:Update() end)
  else
    self:Update()
  end
end

function Tracking:OnStartup()
  if ZGV.QuestTracking_CacheQuestLog then ZGV:QuestTracking_CacheQuestLog() end
  self:QueueUpdate()
end

function Tracking:OnEvent()
  if ZGV.QuestTracking_CacheQuestLog then ZGV:QuestTracking_CacheQuestLog() end
  self:QueueUpdate()
end

-- Legacy quest-cache API -------------------------------------------------------
-- Reuse Compat.Quest's WotLK log reader so all older callers see the familiar
-- ZGV.quests / questsbyid tables without reimplementing unsafe quest-log scans.
local function objective(entry)
  local result={}
  for index,value in ipairs(entry and entry.objectives or {}) do
    result[index]={item=value.description or value.text,num=value.current or (value.finished and value.required or 0),needed=value.required or 1,
      type=value.type,complete=value.finished and true or false,leaderboard=value.text}
  end
  return result
end
function ZGV:GetQuestLeaderBoards(index,questID)
  local entry=ZGV.Compat.Quest:GetLogEntry(tonumber(index),true)
  return objective(entry)
end
function ZGV:GetQuest(indexOrTitle)
  local entry=ZGV.Compat.Quest:FindInLog(indexOrTitle)
  if type(entry)=="table" and entry.index==nil then entry=entry[1] end
  return entry and entry.questID,entry and entry.title,entry and entry.isDaily
end
function ZGV:QuestTracking_CacheQuestLog()
  local snapshot=ZGV.Compat.Quest:RefreshLog()
  self.quests={}; self.questsbyid={}
  for _,entry in ipairs(snapshot.entries or {}) do
    if not entry.isHeader and entry.questID then
      local quest={title=entry.title,level=entry.level,complete=entry.isComplete,failed=entry.isFailed,daily=entry.isDaily,
        goals=objective(entry),id=entry.questID,index=entry.index,inlog=true}
      self.quests[#self.quests+1]=quest; self.questsbyid[quest.id]=quest
    end
  end
  self.dailyQuests=self.dailyQuests or {}; self.completedQuests=self.completedQuests or {}
  return self.quests
end
function ZGV:QuestTracking_ResetDailies(force)
  local seconds=GetQuestResetTime and GetQuestResetTime() or nil
  if force or (seconds and self.lastQuestReset and seconds>self.lastQuestReset) then
    for id in pairs(self.dailyQuests or {}) do self.completedQuests[id]=nil end
  end
  self.lastQuestReset=seconds; return seconds
end
function ZGV:QuestTracking_ResetDailyByTitle(title)
  local entry=ZGV.Compat.Quest:FindInLog(title); if entry and entry.questID then self.completedQuests[entry.questID]=nil end
end
function ZGV:NewQuestEvent(title,id) self:Fire("ZGV_NEW_QUEST",title,id) end
function ZGV:CompletedQuestEvent(title,id) self.completedQuests=self.completedQuests or {}; if id then self.completedQuests[id]=true end; self:Fire("ZGV_QUEST_COMPLETED",title,id) end
function ZGV:AbandonedQuestEvent(title,id) self:Fire("ZGV_QUEST_ABANDONED",title,id) end
function ZGV:LostQuestEvent(title,id) self:Fire("ZGV_QUEST_LOST",title,id) end
function ZGV:QUEST_LOG_UPDATE_QuestTracking() return self:QuestTracking_CacheQuestLog() end
function ZGV:CHAT_MSG_SYSTEM_QuestTracking() return self:QuestTracking_CacheQuestLog() end
function ZGV:QUEST_COMPLETE_QuestTracking() return self:QuestTracking_CacheQuestLog() end
-- Legacy hook entry points delegate to the confirmation-aware automation
-- recorder.  They remain available for older integrations without maintaining
-- a second, divergent pending-abandon state.
function ZGV.QuestTracking_hook_SetAbandonQuest()
  if ZGV.Automation and ZGV.Automation.CaptureAbandon then return ZGV.Automation:CaptureAbandon() end
end
function ZGV.QuestTracking_hook_AbandonQuest()
  if ZGV.Automation and ZGV.Automation.ConfirmAbandon then return ZGV.Automation:ConfirmAbandon() end
end
function ZGV:MarkUselessQuests()
  local relevant={}; local runtime=self.Runtime; local guide=runtime and runtime.currentGuide
  for _,step in ipairs(guide and guide.steps or {}) do for _,goal in ipairs(step.goals or {}) do if goal.questID then relevant[tonumber(goal.questID)]=true end end end
  local unused={}; for _,quest in ipairs(self.quests or {}) do if not relevant[quest.id] then unused[#unused+1]=quest end end
  self.uselessQuests=unused; return unused
end
function ZGV:AbandonUselessQuests()
  if not (self.db.profile.tracking and self.db.profile.tracking.autoAbandon) then return false,"disabled" end
  local unused=self:MarkUselessQuests(); local removed=0
  for _,quest in ipairs(unused) do
    if SelectQuestLogEntry and SetAbandonQuest and AbandonQuest then SelectQuestLogEntry(quest.index); SetAbandonQuest(); AbandonQuest(); removed=removed+1 end
  end
  return removed
end
function ZGV:ShowQuestCleanup()
  local unused=self:MarkUselessQuests()
  if #unused==0 then self:Print("No quests outside the current guide were found."); return 0 end
  self:Print(tostring(#unused).." quest"..(#unused==1 and " is" or "s are").." outside the current guide. Enable tracking.autoAbandon to remove them.")
  return #unused
end

local registered, registrationError = pcall(function()
  ZGV:RegisterCallback("ZGV_GUIDE_CHANGED", Tracking, "QueueUpdate")
  ZGV:RegisterCallback("ZGV_STEP_CHANGED", Tracking, "QueueUpdate")
  ZGV:RegisterCallback("ZGV_GOAL_UPDATED", Tracking, "QueueUpdate")
  -- QUEST_LOG_UPDATE is the portable authoritative refresh event for 3.3.5.
  ZGV:RegisterEvent("QUEST_LOG_UPDATE", Tracking, "OnEvent")
  ZGV:RegisterEvent("QUEST_COMPLETE", Tracking, "OnEvent")
  ZGV:RegisterEvent("CHAT_MSG_SYSTEM", Tracking, "OnEvent")
end)
if not registered and ZGV.LogError then
  ZGV:LogError("load: QuestTracking", registrationError)
end
