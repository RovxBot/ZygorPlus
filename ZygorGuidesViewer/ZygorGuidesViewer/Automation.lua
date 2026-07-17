local ZGV=ZygorGuidesViewer
local Automation=ZGV:RegisterModule("Automation",{abandoned={},lastAction=0})

local function currentStep()
  local runtime=ZGV.Runtime
  return runtime.currentGuide and runtime.currentGuide.steps[runtime.currentStep],runtime
end

local function normaliseQuestTitle(value)
  return tostring(value or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$",""):lower()
end

local function questGoalMatches(goal,questID,questTitle)
  local goalID=tonumber(goal and (goal.questID or goal.questid))
  questID=tonumber(questID)
  if questID and goalID then return questID==goalID end
  local wanted=normaliseQuestTitle(questTitle)
  if wanted=="" then return false end
  local candidate=goal and (goal.questTitle or goal.questtitle or goal.target or goal.sourceBody)
  if normaliseQuestTitle(candidate)==wanted then return true end
  local fallback=normaliseQuestTitle(goal and goal.text):gsub("^accept%s+",""):gsub("^turn in%s+","")
  return fallback==wanted
end

local function currentQuestIdentity()
  local service=ZGV.Compat and ZGV.Compat.Quest
  local dialog=service and service.GetDialog and service:GetDialog()
  if dialog then return dialog.questID,dialog.title end
  return nil,type(GetTitleText)=="function" and GetTitleText() or nil
end

function Automation:FindGoal(action,questID,questTitle)
  local step,runtime=currentStep()
  if not step then return nil end
  local matchQuest=action=="accept" or action=="turnin"
  for index=1,#step.goals do
    local goal=step.goals[index]
    if (not action or goal.action==action) and runtime:IsGoalApplicable(goal)
      and (not matchQuest or questGoalMatches(goal,questID,questTitle)) then
      return goal,index
    end
  end
end

function Automation:Notify(message,kind)
  ZGV:Fire("ZGV_NOTIFICATION",{message=message,kind=kind or "info",time=time()})
  ZGV:Print(message)
end

function Automation:QuestDetail()
  if not ZGV.db.profile.automation.accept then return end
  if ZGV.QuestieIntegration and not ZGV.QuestieIntegration:CanAutomate("accept") then return end
  local questID,questTitle=currentQuestIdentity()
  local goal=self:FindGoal("accept",questID,questTitle)
  if goal and AcceptQuest then
    AcceptQuest()
    self.lastAction=GetTime()
  end
end

function Automation:QuestProgress()
  if not ZGV.db.profile.automation.progress then return end
  if ZGV.QuestieIntegration and not ZGV.QuestieIntegration:CanAutomate("progress") then return end
  local questID,questTitle=currentQuestIdentity()
  local goal=self:FindGoal("turnin",questID,questTitle)
  if goal and IsQuestCompletable and IsQuestCompletable() and CompleteQuest then
    CompleteQuest()
    self.lastAction=GetTime()
  end
end

function Automation:QuestComplete()
  if not ZGV.db.profile.automation.turnin then return end
  if ZGV.QuestieIntegration and not ZGV.QuestieIntegration:CanAutomate("complete") then return end
  local questID,questTitle=currentQuestIdentity()
  local goal=self:FindGoal("turnin",questID,questTitle)
  if not goal then return end
  local choices=GetNumQuestChoices and GetNumQuestChoices() or 0
  if choices==0 and GetQuestReward then
    GetQuestReward()
    self.lastAction=GetTime()
  else
    self:Notify(ZGV.L.REWARD_CHOICE,"reward")
  end
end

local function plainGossipText(text)
  return tostring(text or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("_",""):gsub("^%s+",""):gsub("%s+$","")
end

function Automation:GossipShow()
  if not ZGV.db.profile.automation.gossip then return end
  if ZGV.QuestieIntegration and not ZGV.QuestieIntegration:CanAutomate("gossip") then return end
  local step,runtime=currentStep()
  if not step then return end
  for index=1,#step.goals do
    local goal=step.goals[index]
    local complete=runtime:IsGoalComplete(goal,runtime.currentStep,index)
    if not complete and runtime:IsGoalApplicable(goal) then
      local result
      if goal.action=="gossip" and goal.gossipText then
        result=ZGV.Compat.Gossip:SelectOption({text=plainGossipText(goal.gossipText),caseInsensitive=true})
      elseif goal.action=="accept" then
        local title=goal.text:gsub("^Accept%s+","")
        result=ZGV.Compat.Gossip:SelectQuest("available",{questID=goal.questID,title=title,caseInsensitive=true})
      elseif goal.action=="turnin" then
        local title=goal.text:gsub("^Turn in%s+","")
        result=ZGV.Compat.Gossip:SelectQuest("active",{questID=goal.questID,title=title,caseInsensitive=true})
      end
      if result then
        if result.ok then runtime.manual[runtime:ManualKey(runtime.currentStep,index)]=true
        elseif result.code=="ambiguous" then self:Notify(ZGV.L.GOSSIP_AMBIGUOUS,"warning") end
        return
      end
    end
  end
end

function Automation:ExecuteBundledScript(goal)
  local script=goal and (goal.script or goal.autoscript)
  if not script then return false end
  local source=ZGV.Runtime.currentGuide and ZGV.Runtime.currentGuide.source or ""
  local trusted=source~="user" or (ZGV.db.global.trustedUserScripts and true or false)
  if not trusted then return false,"untrusted" end
  script=script:gsub("%s+$","")
  if script=="VehicleExit()" and type(VehicleExit)=="function" then
    local ok=pcall(VehicleExit)
    return ok
  end
  local emote=script:match('^DoEmote%("([A-Z]+)"%)$')
  if emote and type(DoEmote)=="function" then DoEmote(emote) return true end
  ZGV:LogError("guide script","Unsupported bundled action: "..script)
  return false,"unsupported"
end

function Automation:ConfigureActionButton(goal)
  -- ModernActionBar owns the one authoritative secure quest-action surface.
  -- The old automation button duplicated item actions at UIParent center and
  -- displayed the complete actionbar sprite sheet as a striped square.
  if ZGV.ActionBar and type(ZGV.ActionBar.Refresh)=="function" then
    return ZGV.ActionBar:Refresh()
  end
  return false,"actionbar-unavailable"
end

function Automation:RefreshActionButton()
  return self:ConfigureActionButton(self:FindGoal())
end

function Automation:CaptureAbandon()
  local name=GetAbandonQuestName and GetAbandonQuestName()
  if name then
    local questID
    local selected=GetQuestLogSelection and GetQuestLogSelection()
    local service=ZGV.Compat and ZGV.Compat.Quest
    local entry=selected and selected>0 and service and service.GetLogEntry and service:GetLogEntry(selected,false)
    if entry then questID=entry.questID end
    self.pendingAbandon={name=name,questID=questID,time=time()}
  end
end

function Automation:ConfirmAbandon()
  local pending=self.pendingAbandon
  self.pendingAbandon=nil
  if not pending then return false end
  local record={name=pending.name,questID=pending.questID,time=pending.time or time()}
  self.abandoned[#self.abandoned+1]=record
  ZGV.db.char.abandoned=self.abandoned
  if type(ZGV.AbandonedQuestEvent)=="function" then
    ZGV:AbandonedQuestEvent(record.name,record.questID)
  end
  return true
end

function Automation:OnStartup()
  self.abandoned=ZGV.db.char.abandoned or {}
  if type(hooksecurefunc)=="function" and type(SetAbandonQuest)=="function" then
    hooksecurefunc("SetAbandonQuest",function() Automation:CaptureAbandon() end)
  end
  if type(hooksecurefunc)=="function" and type(AbandonQuest)=="function" then
    -- SetAbandonQuest merely opens the confirmation dialog.  Persist only
    -- after the confirmed AbandonQuest call, so cancelling the dialog is safe.
    hooksecurefunc("AbandonQuest",function() Automation:ConfirmAbandon() end)
  end
  -- ModernActionBar registers the guide/step callbacks. Keeping a second set
  -- here would rebuild the same protected buttons twice for every change.
  self:RefreshActionButton()
end

function Automation:OnEvent(event)
  if ZGV.QuestAuto then return end
  if event=="QUEST_DETAIL" then self:QuestDetail()
  elseif event=="QUEST_PROGRESS" then self:QuestProgress()
  elseif event=="QUEST_COMPLETE" then self:QuestComplete()
  elseif event=="GOSSIP_SHOW" then self:GossipShow() end
end

for _,event in ipairs({"QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE","GOSSIP_SHOW"}) do
  ZGV:RegisterEvent(event,Automation,"OnEvent")
end

local originalActivate=ZGV.Runtime.ActivateGoal
function ZGV.Runtime:ActivateGoal(stepIndex,goalIndex)
  local step=self.currentGuide and self.currentGuide.steps[stepIndex]
  local goal=step and step.goals[goalIndex]
  if goal and (goal.script or goal.autoscript) then
    local done=Automation:ExecuteBundledScript(goal)
    if done then self.manual[self:ManualKey(stepIndex,goalIndex)]=true return true end
  end
  return originalActivate(self,stepIndex,goalIndex)
end
