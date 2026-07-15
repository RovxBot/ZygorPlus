-- WotLK-safe quest acceptance/turn-in controller.  Automation.lua owns the
-- base guide actions; this layer retains the richer Classic QuestAuto API,
-- decline lockout, retry handling, and reward-selection behavior.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local QuestAuto=ZGV:RegisterModule("QuestAuto",{lastDecline=0,lastAction=0})
ZGV.QuestAuto=QuestAuto
local excluded={[10552]=true,[10551]=true} -- Aldor/Scryer allegiance choice.

local function profile()
  local automation=ZGV.db and ZGV.db.profile and ZGV.db.profile.automation or {}
  return automation
end
local function questieAutomation()
  local adapter=ZGV.QuestieIntegration
  if adapter then
    local state=adapter:GetState()
    return state.autoAccept,state.autoComplete
  end
  local questie=rawget(_G,"Questie")
  local settings=questie and questie.db and questie.db.profile
  return settings and settings.autoaccept==true or false,
    settings and settings.autocomplete==true or false
end
local function currentGoals()
  local runtime=ZGV.Runtime
  local result={}
  if not runtime or not runtime.currentGuide then return result end
  for _,entry in ipairs(runtime.GetActiveSteps and runtime:GetActiveSteps() or {}) do
    for index,goal in ipairs(entry.step.goals or {}) do
      if runtime:IsGoalApplicable(goal) and not runtime:IsGoalComplete(goal,entry.index,index) then result[#result+1]=goal end
    end
  end
  return result
end
local function normaliseQuestTitle(value)
  return tostring(value or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$",""):lower()
end
local function questDialog()
  local service=ZGV.Compat and ZGV.Compat.Quest
  local dialog=service and service.GetDialog and service:GetDialog()
  if dialog then return tonumber(dialog.questID),dialog.title end
  return nil,type(GetTitleText)=="function" and GetTitleText() or nil
end
local function matchesQuest(goal,id,title)
  local goalID=tonumber(goal and (goal.questID or goal.questid))
  id=tonumber(id)
  if id and goalID then return id==goalID end
  local wanted=normaliseQuestTitle(title)
  if wanted=="" then return false end
  local candidate=goal and (goal.questTitle or goal.questtitle or goal.target or goal.sourceBody)
  if normaliseQuestTitle(candidate)==wanted then return true end
  local fallback=normaliseQuestTitle(goal and goal.text):gsub("^accept%s+",""):gsub("^turn in%s+","")
  return fallback==wanted
end
function QuestAuto:Debug(message,...) return ZGV:Debug("&qauto "..tostring(message),...) end
function QuestAuto:IsLockedOut()
  if type(IsAltKeyDown)=="function" and IsAltKeyDown() then return true end
  if self.lastDecline and time()-self.lastDecline<10 then return true end
  local now=GetTime()
  if self.lastAction and now-self.lastAction<.2 then return true end
  if ZGV.Automation and ZGV.Automation.lastAction and now-ZGV.Automation.lastAction<.2 then return true end
  local id=questDialog()
  return id and excluded[id] and true or false
end
function QuestAuto:CanAccept(goal,id,title)
  local any=goal and (goal.autoAcceptAny or goal.autoacceptany)
  local goalID=tonumber(goal and (goal.questID or goal.questid))
  if not goal or excluded[goalID] or (goal.action~="accept" and not any) or goal.noAutoAccept or goal.noautoaccept then return false end
  return matchesQuest(goal,id,title) or (id and type(any)=="table" and any[id])
end
function QuestAuto:CanTurnIn(goal,id,title)
  if not goal then return false end
  local any=goal.autoTurninAny or goal.autoturninany
  return (goal.action=="turnin" and matchesQuest(goal,id,title))
    or (id and type(any)=="table" and any[id])
end
function QuestAuto:FindGoal(kind,id,title)
  for _,goal in ipairs(currentGoals()) do
    if kind=="accept" and self:CanAccept(goal,id,title) then return goal end
    if kind=="turnin" and self:CanTurnIn(goal,id,title) then return goal end
  end
end
function QuestAuto:Accept()
  if type(QuestDetailAcceptButton_OnClick)=="function" then QuestDetailAcceptButton_OnClick()
  elseif type(AcceptQuest)=="function" then AcceptQuest() else return false end
  self.lastAction=GetTime(); return true
end
function QuestAuto:Gossip()
  local settings=profile()
  local allowed,reason=ZGV.QuestieIntegration and ZGV.QuestieIntegration:CanAutomate("gossip")
  local questieAccept,questieComplete=questieAutomation()
  -- Questie can select both available and active quests from the same gossip
  -- frame.  When either of its automation modes is explicitly enabled, leave
  -- that shared dialog to Questie instead of racing a second selection.
  if allowed==false or questieAccept or questieComplete then return false,reason or "questie_automation" end
  if self:IsLockedOut() or not settings.gossip then return false end
  local goals=currentGoals()
  local active={GetGossipActiveQuests and GetGossipActiveQuests() or nil}
  for index=1,(GetNumGossipActiveQuests and GetNumGossipActiveQuests() or 0) do
    local title=active[(index-1)*4+1]
    for _,goal in ipairs(goals) do
      if goal.action=="turnin" and not (goal.noAutoGossip or goal.noautogossip) and matchesQuest(goal,nil,title) then
        if SelectGossipActiveQuest then SelectGossipActiveQuest(index); self.lastAction=GetTime(); return true end
      end
    end
  end
  local available={GetGossipAvailableQuests and GetGossipAvailableQuests() or nil}
  for index=1,(GetNumGossipAvailableQuests and GetNumGossipAvailableQuests() or 0) do
    local title=available[(index-1)*5+1]
    for _,goal in ipairs(goals) do
      if not (goal.noAutoGossip or goal.noautogossip) and self:CanAccept(goal,nil,title) then
        if SelectGossipAvailableQuest then SelectGossipAvailableQuest(index); self.lastAction=GetTime(); return true end
      end
    end
  end
  return false
end
function QuestAuto:Greeting() return self:Gossip() end
function QuestAuto:Detail()
  local settings=profile(); local id,title=questDialog()
  local allowed,reason=ZGV.QuestieIntegration and ZGV.QuestieIntegration:CanAutomate("accept")
  local questieAccept=questieAutomation()
  if allowed==false or questieAccept then return false,reason or "questie_automation" end
  if self:IsLockedOut() or not settings.accept or not self:FindGoal("accept",id,title) then return false end
  return self:Accept()
end
function QuestAuto:Progress()
  local settings=profile(); local id,title=questDialog()
  local allowed,reason=ZGV.QuestieIntegration and ZGV.QuestieIntegration:CanAutomate("progress")
  local _,questieComplete=questieAutomation()
  if allowed==false or questieComplete then return false,reason or "questie_automation" end
  if self:IsLockedOut() or not settings.progress or not self:FindGoal("turnin",id,title) then return false end
  if type(IsQuestCompletable)=="function" and not IsQuestCompletable() then return false end
  if type(CompleteQuest)=="function" then CompleteQuest(); self.lastAction=GetTime(); return true end
  return false
end
function QuestAuto:Complete()
  local settings=profile(); local id,title=questDialog()
  local allowed,reason=ZGV.QuestieIntegration and ZGV.QuestieIntegration:CanAutomate("complete")
  local _,questieComplete=questieAutomation()
  if allowed==false or questieComplete then return false,reason or "questie_automation" end
  if self:IsLockedOut() or not settings.turnin or not self:FindGoal("turnin",id,title) then return false end
  local choices=type(GetNumQuestChoices)=="function" and GetNumQuestChoices() or 0
  local picker=ZGV.ItemScore and ZGV.ItemScore.QuestItem
  local choice,reason=picker and picker:GetQuestRewardIndex() or nil
  if picker and choice and choice>0 and settings.questRewardHint~=false then picker:ShowQuestRewardGlow(choice,reason) end
  if choices>1 and not settings.autoSelectReward then return false,"reward choice required" end
  if choices>0 and not choice then choice=1 end
  if type(GetQuestReward)=="function" then GetQuestReward(choice or 1); self.lastAction=GetTime(); return true end
  return false
end
function QuestAuto:Finished()
  local picker=ZGV.ItemScore and ZGV.ItemScore.QuestItem; if picker then picker:HideQuestRewardGlow() end
  ZGV.last_questgiver_id=ZGV.GetTargetId and ZGV.GetTargetId() or nil; ZGV.last_questgiver_time=GetTime()
end
function QuestAuto:Accepted() self:Finished() end
function QuestAuto:Retry()
  local settings=profile(); if not (settings.accept or settings.turnin or settings.questRewardHint) then return end
  if QuestFrameAcceptButton and QuestFrameAcceptButton:IsVisible() then return self:Detail() end
  if QuestFrameCompleteQuestButton and QuestFrameCompleteQuestButton:IsVisible() then return self:Complete() end
  if QuestFrameCompleteButton and QuestFrameCompleteButton:IsVisible() then return self:Progress() end
  if (GossipFrame and GossipFrame:IsVisible()) or (QuestFrame and QuestFrame:IsVisible()) then return self:Gossip() end
end
function QuestAuto:OnEvent(event)
  if event=="GOSSIP_SHOW" then return self:Gossip()
  elseif event=="QUEST_GREETING" then return self:Greeting()
  elseif event=="QUEST_DETAIL" then return self:Detail()
  elseif event=="QUEST_PROGRESS" then return self:Progress()
  elseif event=="QUEST_COMPLETE" then return self:Complete()
  elseif event=="QUEST_FINISHED" then return self:Finished()
  elseif event=="QUEST_ACCEPTED" then return self:Accepted() end
end
function QuestAuto:OnStartup()
  if type(hooksecurefunc)=="function" and type(DeclineQuest)=="function" then hooksecurefunc("DeclineQuest",function() QuestAuto.lastDecline=time() end) end
  if ZGV.Compat and ZGV.Compat.Timer then self.retryTicker=ZGV.Compat.Timer:NewTicker(1.5,function() QuestAuto:Retry() end) end
end
for _,event in ipairs({"GOSSIP_SHOW","QUEST_GREETING","QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE","QUEST_FINISHED","QUEST_ACCEPTED"}) do ZGV:RegisterEvent(event,QuestAuto,"OnEvent") end
