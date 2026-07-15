local ZGV = ZygorGuidesViewer
local Runtime = ZGV:RegisterModule("Runtime",{
  currentGuide=nil,currentStep=1,manual={},killCounts={},collectionBaselines={},talked={},gossiped={},interacted={},discoveries={},autoHistory={},lastAdvance=0,autoAdvanceDelay=0.65,
})

local function questEntry(id)
  local service=ZGV.Compat and ZGV.Compat.Quest
  return service and service.FindInLog and service:FindInLog(tonumber(id))
end

local function questCompleted(id)
  local service=ZGV.Compat and ZGV.Compat.Quest
  if not service or not service.IsCompleted then return false,false end
  local done,known=service:IsCompleted(tonumber(id))
  return done,known
end

local function normalizeQuestTitle(value)
  return tostring(value or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","")
    :gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$",""):lower()
end

local function matchesTurnInGoal(goal,questID,questTitle)
  if not goal or goal.action~="turnin" then return false end
  local wantedID,goalID=tonumber(questID),tonumber(goal.questID or goal.questid)
  if wantedID and goalID then return wantedID==goalID end
  local wanted=normalizeQuestTitle(questTitle)
  if wanted=="" then return false end
  local candidate=goal.questTitle or goal.questtitle or goal.target or goal.sourceBody
  if normalizeQuestTitle(candidate)==wanted then return true end
  local fallback=normalizeQuestTitle(goal.text):gsub("^turn in%s+","")
  return fallback==wanted
end

local function itemCount(id)
  return ZGV.Conditions and ZGV.Conditions:ItemCount(id,true) or 0
end

local function questObjective(goal)
  if not goal or not goal.questID then return nil end
  local entry=questEntry(goal.questID)
  if not entry or not entry.objectives then return nil end
  if goal.objective and entry.objectives[goal.objective] then return entry.objectives[goal.objective] end
  -- A guide that has one objective need not spell out "|q id/1".  Do not
  -- guess when there are multiple objectives: a false positive is worse than
  -- displaying no numeric progress.
  if #entry.objectives==1 then return entry.objectives[1] end
end

function Runtime:ManualKey(stepIndex,goalIndex)
  return (self.currentGuide and self.currentGuide.id or "none")..":"..tostring(stepIndex)..":"..tostring(goalIndex)
end

function Runtime:UsesCollectionBaseline(goal)
  if not goal or goal.questID or goal.objective or goal.allowExistingItems or goal.allowexistingitems then return false end
  return goal.action=="collect" or goal.action=="buy" or goal.action=="create"
    or goal.action=="craft" or goal.action=="repcollect"
end

function Runtime:GetCollectionBaseline(goal,stepIndex,goalIndex,current)
  local key=self:ManualKey(stepIndex,goalIndex)
  local baseline=self.collectionBaselines[key]
  if baseline==nil then
    baseline=tonumber(current) or 0
    self.collectionBaselines[key]=baseline
    ZGV:LogInfo("progress","collection baseline "..key.."="..tostring(baseline))
  end
  return tonumber(baseline) or 0
end

function Runtime:GetGoalProgress(goal,stepIndex,goalIndex)
  if not goal then return nil end
  local action=goal.action
  local objective=questObjective(goal)
  -- `|q id/objective` is a completion source attached to the whole goal, not
  -- just to kill/collect verbs.  Classic guides also attach it to prose,
  -- buffs and scripted interactions; those goals must follow the quest-log
  -- objective and become obsolete once that objective is already complete.
  if objective then
    local required=tonumber(objective.required) or tonumber(goal.count) or 1
    local current=tonumber(objective.current)
    if current==nil then current=objective.finished and required or 0 end
    return {current=math.min(current,required),required=required,complete=objective.finished or current>=required,source="quest"}
  end
  if (action=="get" or action=="collect" or action=="buy" or action=="create" or action=="craft" or action=="repcollect" or action=="goldcollect") and goal.itemID then
    local required=tonumber(goal.count) or 1
    local current=itemCount(goal.itemID)
    if stepIndex and goalIndex and self:UsesCollectionBaseline(goal) then
      current=math.max(0,current-self:GetCollectionBaseline(goal,stepIndex,goalIndex,current))
    end
    return {current=math.min(current,required),required=required,complete=current>=required,source="items"}
  end
  if action=="kill" and goal.npcID and goal.count and stepIndex and goalIndex then
    local required=tonumber(goal.count) or 1
    local current=tonumber(self.killCounts[self:ManualKey(stepIndex,goalIndex)]) or 0
    return {current=math.min(current,required),required=required,complete=current>=required,source="combat"}
  end
  if (action=="goldcollect" or (action=="earn" and not goal.currencyID)) and not goal.itemID and goal.count then
    local required=tonumber(goal.count) or 1
    local current=type(GetMoney)=="function" and GetMoney() or 0
    return {current=math.min(current,required),required=required,complete=current>=required,source="money"}
  end
  if (action=="ding" or action=="level" or action=="grind") and goal.level then
    local required=tonumber(goal.level) or 1
    local current=type(UnitLevel)=="function" and UnitLevel("player") or 0
    return {current=math.min(current,required),required=required,complete=current>=required,source="level"}
  end
  if action=="earn" and goal.currencyID and type(GetCurrencyInfo)=="function" then
    local _,current=GetCurrencyInfo(tonumber(goal.currencyID))
    local required=tonumber(goal.count) or 1
    return {current=math.min(tonumber(current) or 0,required),required=required,complete=(tonumber(current) or 0)>=required,source="currency"}
  end
  if (action=="trash" or action=="bank") and goal.itemID then
    local current=itemCount(goal.itemID)
    return {current=current>0 and 0 or 1,required=1,complete=current==0,source=action}
  end
  return nil
end

function Runtime:IsGoalApplicable(goal)
  if not goal or not goal.onlyIf or goal.onlyIf=="" then return true end
  local result,err=ZGV.Conditions:Evaluate(goal.onlyIf,self.currentGuide)
  if err then
    self.currentGuide.conditionIssues=self.currentGuide.conditionIssues or {}
    if not self.currentGuide.conditionIssues[goal.onlyIf] then
      self.currentGuide.conditionIssues[goal.onlyIf]=err
      ZGV:LogError("condition "..self.currentGuide.title,goal.onlyIf..": "..tostring(err))
    end
  end
  return result
end

-- `|only` on its own source line applies to the entire step, rather than the
-- goal above it.  Keep this separate from goal visibility so alternate
-- class/race branches disappear atomically and cannot leave a talk or gossip
-- objective behind to block the guide.
function Runtime:IsStepApplicable(step)
  if not step or not step.onlyIf or step.onlyIf=="" then return true end
  local result,err=ZGV.Conditions:Evaluate(step.onlyIf,self.currentGuide)
  if err then
    self.currentGuide.conditionIssues=self.currentGuide.conditionIssues or {}
    local key="step:"..step.onlyIf
    if not self.currentGuide.conditionIssues[key] then
      self.currentGuide.conditionIssues[key]=err
      ZGV:LogError("step condition "..self.currentGuide.title,step.onlyIf..": "..tostring(err))
    end
  end
  return result
end

function Runtime:IsGoalComplete(goal,stepIndex,goalIndex)
  if not self:IsGoalApplicable(goal) then return true,"not-applicable" end
  if goal.forceComplete then return true,"forced" end
  -- Future goals document work needed later in a guide.  They must never
  -- become a hard gate for the current route.
  if goal.future then return true,"future" end
  if self.manual[self:ManualKey(stepIndex,goalIndex)] then return true,"manual" end
  -- `|n` is an authored tracking/display objective.  It stays visible (and
  -- may still show counters) but is not a required step gate, matching the
  -- Classic Goal:IsCompleteable contract.
  if goal.forceNoComplete then return false,"not-completable" end
  local action=goal.action
  local conditionPending=false
  if goal.expression then
    local result=ZGV.Conditions:Evaluate(goal.expression,self.currentGuide)
    if result then return true,"condition" end
    -- The Classic fall-through contract lets an attached quest/objective
    -- complete a goal even when its secondary condition is currently false.
    conditionPending=true
  end
  if action=="accept" then
    local done=questCompleted(goal.questID)
    local repeatable=goal.repeatable or goal.repeatableQuest or goal.repeatablequest
    return (done and not repeatable) or questEntry(goal.questID)~=nil,"quest"
  elseif action=="turnin" or action=="turninany" or action=="notcompleted" then
    local done,known=questCompleted(goal.questID)
    if action=="notcompleted" then return known and not done,"quest" end
    -- A repeatable turn-in may legitimately appear in the completed-quest
    -- history from an earlier cycle.  It is complete only after this guide
    -- instance receives its explicit reward confirmation (the manual check
    -- above), never merely because the quest was once completed.
    if goal.repeatable or goal.repeatableQuest or goal.repeatablequest then done=false end
    return done,"quest"
  elseif action=="havequest" then
    return questEntry(goal.questID)~=nil,"quest"
  elseif action=="nothavequest" or action=="noquest" or action=="abandon" then
    return questEntry(goal.questID)==nil,"quest"
  end

  -- In the source Goal prototype, every non-accept/turn-in goal carrying
  -- `|q` first checks the attached quest.  This is what makes instructions
  -- such as "Talk to ..." or "Gain the buff" disappear when their related
  -- quest/objective was completed before the guide reached the step.
  if goal.questID then
    local done=questCompleted(goal.questID)
    if done then return true,"quest-completed" end
    if goal.objective then
      local progress=self:GetGoalProgress(goal,stepIndex,goalIndex)
      if progress then return progress.complete,progress.source end
    end
  end
  if conditionPending then return false,"condition" end
  if goal.confirm then return false,"confirmation" end

  if action=="kill" or action=="goal" or action=="click" or action=="clicknpc"
      or action=="avoid" or action=="get" or action=="collect" or action=="buy" or action=="create" or action=="craft" or action=="use"
      or action=="repcollect" or action=="goldcollect" or action=="earn" or action=="grind" or action=="level" or action=="trash" or action=="bank" then
    local progress=self:GetGoalProgress(goal,stepIndex,goalIndex)
    if progress then return progress.complete,progress.source end
    if action=="avoid" then return false,"not-completable" end
  elseif action=="equip" and goal.itemID then
    local service=ZGV.Compat and ZGV.Compat.Item
    local result=service and service.IsEquipped and service:IsEquipped(goal.itemID)
    if type(result)=="table" then return result.equipped,"equipment" end
    return result and true or false,"equipment"
  elseif action=="unequip" and goal.itemID then
    local service=ZGV.Compat and ZGV.Compat.Item
    local result=service and service.IsEquipped and service:IsEquipped(goal.itemID)
    if type(result)=="table" then return not result.equipped,"equipment" end
    return not result,"equipment"
  elseif action=="ding" then
    return (UnitLevel("player") or 0)>=(goal.level or 0),"level"
  -- A destination is navigation metadata on many real objectives (talk,
  -- collect, buff, etc.), not the objective's completion condition.  Treat
  -- only an explicit `goto` goal as arrival-complete; otherwise a buff goal
  -- such as Terokkar's Shadowy Disguise never reaches its own aura check.
  elseif action=="goto" then
    if goal.mapTransition and ZGV.Navigation and ZGV.Navigation.IsMapTransitionComplete then
      return ZGV.Navigation:IsMapTransitionComplete(goal.mapTransition),"map-transition"
    end
    if ZGV.Navigation then return ZGV.Navigation:IsArrived(goal.destination),"position" end
  elseif action=="skill" or action=="reachskill" or action=="skillmax" then
    return ZGV.Conditions:Skill(goal.skillName)>=(goal.skillRank or 1),"skill"
  elseif action=="havebuff" then
    return ZGV.Conditions:HaveBuff(goal.haveBuff or (goal.modifiers and goal.modifiers.haveBuff) or goal.spellID or goal.objectID),"buff"
  elseif action=="nobuff" then
    return not ZGV.Conditions:HaveBuff(goal.noBuff or (goal.modifiers and goal.modifiers.noBuff) or goal.spellID or goal.objectID),"buff"
  elseif (action=="rep" or action=="repcollect") and goal.repFaction then
    local standing=ZGV.Conditions:Reputation(goal.repFaction)
    local wanted=tonumber(goal.repStanding) or ({Hated=1,Hostile=2,Unfriendly=3,Neutral=4,Friendly=5,Honored=6,Revered=7,Exalted=8})[tostring(goal.repStanding)] or 0
    return standing>=wanted,"reputation"
  elseif action=="achieve" and goal.achievementID and GetAchievementInfo then
    local _,_,_,completed=GetAchievementInfo(goal.achievementID)
    return completed and true or false,"achievement"
  elseif action=="talk" then
    -- A bare talk line is the visible NPC instruction paired with a real
    -- accept/turn-in/objective goal.  Classic marks it non-completable, so it
    -- cannot hold the step open after that quest goal is already satisfied.
    -- Explicit manual completion is handled above, and quest-bound talk
    -- goals have already gone through the attached-quest fall-through.
    return false,"not-completable"
  elseif action=="gossip" then
    return false,"not-completable"
  elseif action=="vendor" or action=="trainer" then
    return self.interacted[self:ManualKey(stepIndex,goalIndex)] and true or false,"interaction"
  elseif action=="taxi" or action=="fly" then
    return self.interacted[self:ManualKey(stepIndex,goalIndex)] and true or false,"travel"
  elseif action=="home" then
    local wanted=tostring(goal.homeName or goal.target or goal.sourceBody or ""):lower()
    local bound=type(GetBindLocation)=="function" and GetBindLocation("player") or ""
    return tostring(bound):lower()==wanted,"home"
  elseif action=="hearth" then
    local wanted=tostring(goal.hearthZone or goal.target or goal.sourceBody or ""):lower()
    local zone=type(GetZoneText)=="function" and GetZoneText() or ""
    local subzone=type(GetSubZoneText)=="function" and GetSubZoneText() or ""
    return tostring(zone):lower()==wanted or tostring(subzone):lower()==wanted,"hearth"
  elseif action=="discover" then
    return self.discoveries[self:ManualKey(stepIndex,goalIndex)] and true or false,"discover"
  elseif action=="learn" or action=="learnspell" or action=="learnpetspell" then
    local spell=goal.spellID or goal.targetID
    return type(IsSpellKnown)=="function" and IsSpellKnown(tonumber(spell)) or false,"spell"
  elseif action=="cast" then
    -- A bare spell cast has no reliable historical event payload on 3.3.5a;
    -- it remains a click-to-confirm instruction, as in the Classic viewer.
    return self.manual[self:ManualKey(stepIndex,goalIndex)] and true or false,"cast"
  elseif action=="petaction" then
    local slot=ZGV.FindPetActionInfo and ZGV.FindPetActionInfo(goal)
    return slot~=nil,"petaction"
  elseif action=="invehicle" then
    return type(UnitInVehicle)=="function" and UnitInVehicle("player") or false,"vehicle"
  elseif action=="outvehicle" then
    return not (type(UnitInVehicle)=="function" and UnitInVehicle("player")),"vehicle"
  elseif action=="ontaxi" then
    return type(UnitOnTaxi)=="function" and UnitOnTaxi("player") or false,"taxi"
  elseif action=="offtaxi" then
    return not (type(UnitOnTaxi)=="function" and UnitOnTaxi("player")),"taxi"
  elseif action=="subzone" then
    return tostring(GetSubZoneText and GetSubZoneText() or ""):lower()==tostring(goal.target or goal.sourceBody or ""):lower(),"subzone"
  elseif action=="playertitle" and IsTitleKnown then
    return IsTitleKnown(tonumber(goal.targetID or goal.titleID)),"title"
  elseif action=="itemset" and type(goal.items)=="table" then
    local service=ZGV.Compat and ZGV.Compat.Item
    for _,itemID in ipairs(goal.items) do
      local result=service and service.IsEquipped and service:IsEquipped(itemID)
      if type(result)=="table" then result=result.equipped end
      if not result then return false,"equipment" end
    end
    return true,"equipment"
  elseif action=="text" and goal.mapTransition and ZGV.Navigation and ZGV.Navigation.IsMapTransitionComplete then
    return ZGV.Navigation:IsMapTransitionComplete(goal.mapTransition),"map-transition"
  elseif action=="text" or action=="map" or action=="label" or action=="info" or action=="image" or action=="webheader" or action=="webinfo" or action=="webimage" then
    return true,"informational"
  end
  return false,"pending"
end

function Runtime:GetStepState(step,index)
  if not step then return {complete=false,required=0,done=0} end
  if not self:IsStepApplicable(step) then
    return {complete=true,required=0,done=0,goals={},skipped=true,notApplicable=true}
  end
  local state={complete=true,required=0,done=0,goals={},skipped=false}
  local orRequired,orDone,orNeeded=0,0,1
  local skippedGoals,activeGoals=0,0
  for goalIndex=1,#step.goals do
    local goal=step.goals[goalIndex]
    local complete,reason=self:IsGoalComplete(goal,index,goalIndex)
    local progress=self:GetGoalProgress(goal,index,goalIndex)
    state.goals[goalIndex]={
      complete=complete,reason=reason,
      current=progress and progress.current or nil,
      required=progress and progress.required or nil,
      progressSource=progress and progress.source or nil,
    }
  end

  -- Classic guide authors commonly write one real `|q quest/objective` line
  -- after a small group of supporting instructions.  For example, Terokkar
  -- lists “Use Rod of Purification” followed by the actual Darkstone quest
  -- objective, and separately lists kill/key/cage instructions followed by
  -- “Rescue 12 Children”.  Those supporting lines are not independently
  -- measurable on 3.3.5a.  Once the *single explicit quest objective* in a
  -- step is complete, mark its unbound action companions complete too.  This
  -- preserves multi-objective steps (which receive no inference) and lets
  -- the viewer both tick the instructions and advance smoothly.
  local completedObjective,objectiveCount
  for goalIndex,goal in ipairs(step.goals) do
    if goal.questID and goal.objective then
      objectiveCount=(objectiveCount or 0)+1
      if state.goals[goalIndex].complete then completedObjective=goalIndex end
    end
  end
  if objectiveCount==1 and completedObjective then
    local companionActions={
      talk=true,gossip=true,vendor=true,trainer=true,use=true,click=true,clicknpc=true,
      kill=true,get=true,collect=true,buy=true,create=true,craft=true,cast=true,
      havebuff=true,nobuff=true,
    }
    for goalIndex,goal in ipairs(step.goals) do
      local goalState=state.goals[goalIndex]
      if not goalState.complete and not goal.questID and companionActions[goal.action] then
        goalState.complete=true
        goalState.reason="step-objective"
        goalState.objectiveGoal=completedObjective
      end
    end
  end

  -- Count after the objective bridge has been applied so an unbound `use` or
  -- `click` cannot keep a completed quest objective from advancing its step.
  for goalIndex=1,#step.goals do
    local goal=step.goals[goalIndex]
    local goalState=state.goals[goalIndex]
    local complete,reason=goalState.complete,goalState.reason
    local skipped=reason=="not-applicable" or reason=="future"
    local informational=reason=="informational" or reason=="not-completable"
    if skipped then
      skippedGoals=skippedGoals+1
    elseif goal.orGoal then
      activeGoals=activeGoals+1
      orRequired=orRequired+1
      if complete then orDone=orDone+1 end
      orNeeded=math.max(orNeeded,tonumber(goal.orGoal) or 1)
    elseif not informational then
      activeGoals=activeGoals+1
      state.required=state.required+1
      if complete then state.done=state.done+1 else state.complete=false end
    end
  end
  if orRequired>0 then
    state.required=state.required+1
    if orDone>=orNeeded then state.done=state.done+1 else state.complete=false end
  end
  if state.required==0 then
    -- An entirely inapplicable/future step is skipped automatically.  A
    -- descriptive text-only step remains visible so guide prose is not raced
    -- through by the ticker.
    state.complete=#step.goals>0 and skippedGoals>0 and activeGoals==0
    state.skipped=state.complete
  end
  return state
end

-- Sticky directives name a future step that should be displayed while the
-- current step is focused.  Their completion is independent: a sticky may be
-- finished at any point, but never prevents the main step advancing.
function Runtime:GetStickySteps(stepIndex)
  local guide=self.currentGuide
  local step=guide and guide.steps[stepIndex or self.currentStep]
  local results={}
  if not step or not step.stickies then return results end
  local currentIndex=stepIndex or self.currentStep
  for _,sticky in ipairs(step.stickies) do
    local stickyIndex=sticky.number
    if stickyIndex and stickyIndex>currentIndex and self:IsStepApplicable(sticky) then
      local state=self:GetStepState(sticky,stickyIndex)
      if not state.complete then
        results[#results+1]={step=sticky,index=stickyIndex,state=state}
      end
    end
  end
  return results
end

-- Viewers consume this flattened form so the focused step and its current
-- stickies use the same rows, icons, click handling and numeric progress.
function Runtime:GetDisplayGoals(stepIndex)
  local guide=self.currentGuide
  local index=stepIndex or self.currentStep
  local step=guide and guide.steps[index]
  local results={}
  if not step or not self:IsStepApplicable(step) then return results end
  local state=self:GetStepState(step,index)
  for goalIndex,goal in ipairs(step.goals) do
    if self:IsGoalApplicable(goal) then
      results[#results+1]={goal=goal,stepIndex=index,goalIndex=goalIndex,state=state.goals[goalIndex]}
    end
  end
  for _,sticky in ipairs(self:GetStickySteps(index)) do
    for goalIndex,goal in ipairs(sticky.step.goals) do
      if self:IsGoalApplicable(goal) then
        results[#results+1]={
          goal=goal,stepIndex=sticky.index,goalIndex=goalIndex,
          state=sticky.state.goals[goalIndex],sticky=true,
        }
      end
    end
  end
  return results
end

function Runtime:GetActiveSteps()
  local guide=self.currentGuide
  local results={}
  local step=guide and guide.steps[self.currentStep]
  if step and self:IsStepApplicable(step) then results[#results+1]={step=step,index=self.currentStep} end
  for _,sticky in ipairs(self:GetStickySteps(self.currentStep)) do
    results[#results+1]={step=sticky.step,index=sticky.index,sticky=true}
  end
  return results
end

-- A retry branch must remain paused until the player has done something that
-- materially changes it.  Position/arrival state is deliberately excluded:
-- it is refreshed frequently and was falsely interpreted as progress,
-- recreating authored retry loops every ticker pass.
function Runtime:GetProgressFingerprint(step,index)
  local parts={}
  if not step then return "" end
  if step.onlyIf and step.onlyIf~="" then
    parts[#parts+1]="step="..(self:IsStepApplicable(step) and "applicable" or "skipped")
  end
  for goalIndex=1,#step.goals do
    local goal=step.goals[goalIndex]
    local part={tostring(goalIndex),goal.action or "text"}
    if goal.onlyIf and goal.onlyIf~="" then
      part[#part+1]=self:IsGoalApplicable(goal) and "applicable" or "skipped"
    end
    if goal.questID then
      local entry=questEntry(goal.questID)
      local done,known=questCompleted(goal.questID)
      local objective=questObjective(goal)
      part[#part+1]="q="..tostring(goal.questID)..":"..(entry and "open" or "none")..":"..(done and "done" or "pending")..":"..(known and "known" or "unknown")
      if objective then
        part[#part+1]="objective="..tostring(objective.current or 0).."/"..tostring(objective.required or 0)..":"..(objective.finished and "done" or "pending")
      end
    end
    if goal.itemID then part[#part+1]="item="..tostring(goal.itemID)..":"..tostring(itemCount(goal.itemID)) end
    if goal.action=="havebuff" then
      local buff=goal.haveBuff or (goal.modifiers and goal.modifiers.haveBuff) or goal.spellID or goal.objectID
      part[#part+1]="buff="..(ZGV.Conditions:HaveBuff(buff) and "yes" or "no")
    elseif goal.action=="nobuff" then
      local buff=goal.noBuff or (goal.modifiers and goal.modifiers.noBuff) or goal.spellID or goal.objectID
      part[#part+1]="nobuff="..(ZGV.Conditions:HaveBuff(buff) and "present" or "absent")
    elseif goal.action=="talk" then
      part[#part+1]="talk="..(self.talked[self:ManualKey(index,goalIndex)] and "yes" or "no")
    elseif goal.action=="gossip" then
      part[#part+1]="gossip="..(self.gossiped[self:ManualKey(index,goalIndex)] and "yes" or "no")
    end
    if goal.expression then
      local result=ZGV.Conditions:Evaluate(goal.expression,self.currentGuide)
      part[#part+1]="expression="..(result and "yes" or "no")
    end
    parts[#parts+1]=table.concat(part,"|")
  end
  return table.concat(parts,";")
end

function Runtime:RefreshBlockedProgress(event)
  local blocked=self.autoAdvanceBlocked
  if not blocked or not self.currentGuide or blocked.guide~=self.currentGuide.id or blocked.step~=self.currentStep then return false end
  local fingerprint=self:GetProgressFingerprint(self.currentGuide.steps[self.currentStep],self.currentStep)
  if fingerprint~=blocked.fingerprint then
    self.autoAdvanceBlocked=nil
    ZGV:LogInfo("guide loop","progress event "..tostring(event).." released retry step "..tostring(self.currentStep))
    return true
  end
  return false
end

function Runtime:ResolveGuide(value)
  local guide=ZGV.Catalog:Get(value)
  if guide then return guide end
  value=tostring(value or ""):lower()
  local exactName
  for i=1,#ZGV.Catalog.sorted do
    local candidate=ZGV.Catalog.sorted[i]
    if candidate.name:lower()==value then return candidate end
    if candidate.title:lower():find(value,1,true) then exactName=exactName or candidate end
  end
  return exactName
end

-- Resolve the complete Classic `|next` grammar.  Labels are intentionally
-- allowed to repeat: unsigned jumps choose the closest occurrence, while
-- +label/-label select the next/previous occurrence.  Numeric jumps are
-- absolute without a sign and relative with one (for example, +1).
function Runtime:ResolveStepJump(guide,origin,jump)
  if not guide or jump==nil then return nil end
  jump=tostring(jump)
  if jump=="" then jump="+1" end
  if jump:match("^%d+$") then return tonumber(jump) end

  local sign=jump:sub(1,1)
  if sign~="+" and sign~="-" then sign=nil else jump=jump:sub(2) end
  if jump:match("^%d+$") then
    local offset=tonumber(jump) or 0
    return (tonumber(origin) or 0)+(sign=="-" and -offset or offset)
  end

  local entries=guide.labelSteps and guide.labelSteps[jump]
  if not entries and guide.labels and guide.labels[jump] then entries={guide.labels[jump]} end
  if not entries then return nil end
  local previous,nextStep
  origin=tonumber(origin) or 0
  for _,number in ipairs(entries) do
    if number<origin then previous=number end
    if number>origin and not nextStep then nextStep=number end
  end
  if sign=="+" then return nextStep end
  if sign=="-" then return previous end
  if not nextStep or (previous and origin-previous<nextStep-origin) then return previous end
  return nextStep
end

function Runtime:AddHistory(guide)
  local history=ZGV.db.profile.history
  for i=#history,1,-1 do
    local value=type(history[i])=="table" and history[i].id or history[i]
    if value==guide.id or value==guide.title then table.remove(history,i) end
  end
  table.insert(history,1,{id=guide.id,title=guide.title,time=time()})
  while #history>50 do table.remove(history) end
end

function Runtime:SelectGuide(value,step)
  local guide=self:ResolveGuide(value)
  if not guide then ZGV:Print("Guide not found: "..tostring(value)) return false end
  local parsed,err=ZGV.Parser:ParseGuide(guide)
  if not parsed then ZGV:LogError("guide parse",err) return false end
  self.currentGuide=parsed
  local selected=tonumber(step) or self:ResolveStepJump(parsed,0,step) or 1
  self.currentStep=math.max(1,math.min(selected,#parsed.steps))
  self.autoHistory={[(parsed.id or "guide")..":"..tostring(self.currentStep)]=1}
  self.autoAdvanceBlocked=nil
  ZGV.db.profile.currentGuide=parsed.id
  ZGV.db.profile.currentStep=self.currentStep
  self:AddHistory(parsed)
  ZGV:LogInfo("guide","selected "..tostring(parsed.title).." step "..tostring(self.currentStep))
  local stats=parsed.parseStats
  if stats and (stats.stickyStarts>0 or stats.stickyReferences>0) then
    ZGV:LogInfo("guide parser",tostring(parsed.title).." stickies "
      ..tostring(stats.resolvedStickies).."/"..tostring(stats.stickyReferences)
      .." starts="..tostring(stats.stickyStarts).." unclosed="..tostring(stats.unclosedStickies))
  end
  if parsed.parseIssues and #parsed.parseIssues>0 then
    ZGV:LogError("guide parser "..tostring(parsed.title),table.concat(parsed.parseIssues,"; "))
  end
  self:UpdateWaypoint()
  ZGV:Fire("ZGV_GUIDE_CHANGED",parsed,self.currentStep)
  return true
end

function Runtime:SetStep(index,manual,loopGuard)
  if not self.currentGuide then return false end
  index=math.max(1,math.min(tonumber(index) or 1,#self.currentGuide.steps))
  if index==self.currentStep then return true end
  if manual and not loopGuard then
    self.autoHistory={[(self.currentGuide.id or "guide")..":"..tostring(index)]=1}
    self.autoAdvanceBlocked=nil
  elseif not manual then
    local key=(self.currentGuide.id or "guide")..":"..tostring(index)
    self.autoHistory=self.autoHistory or {}
    self.autoHistory[key]=(self.autoHistory[key] or 0)+1
    if self.autoHistory[key]>1 then
      -- A branch has returned to a step that the automatic runner already
      -- traversed without any new player progress.  Focus the retry step but
      -- pause there; this turns an infinite 88→92 loop into a usable retry.
      ZGV:LogInfo("guide loop","automatic cycle detected at step "..tostring(index).."; retry paused for objective progress")
      return self:SetStep(index,true,true)
    end
  end
  self.currentStep=index
  ZGV.db.profile.currentStep=index
  self.lastAdvance=GetTime()
  ZGV:LogInfo("guide","step "..tostring(index)..(manual and " (manual)" or " (automatic)"))
  self:UpdateWaypoint()
  if loopGuard then
    -- Snapshot the destination after its conditions and current objectives
    -- have resolved.  A zero baseline caused already-complete retry steps to
    -- immediately re-enter the same loop on the following ticker pass.
    local state=self:GetStepState(self.currentGuide.steps[index],index)
    self.autoAdvanceBlocked={
      guide=self.currentGuide.id,step=index,done=state.done,required=state.required,
      fingerprint=self:GetProgressFingerprint(self.currentGuide.steps[index],index),
    }
  end
  ZGV:Fire("ZGV_STEP_CHANGED",self.currentGuide,index,manual)
  if ZGV.Sync then ZGV.Sync:BroadcastProgress() end
  return true
end

function Runtime:NextStep(manual)
  if not self.currentGuide then return false end
  local step=self.currentGuide.steps[self.currentStep]
  if step then
    for goalIndex=1,#step.goals do
      local goal=step.goals[goalIndex]
      if goal.nextJump or goal.nextLabel then
        local complete=self:IsGoalComplete(goal,self.currentStep,goalIndex)
        local destination=self:ResolveStepJump(self.currentGuide,self.currentStep,goal.nextJump or goal.nextLabel)
        -- Manual Next means "continue".  It must not force the first
        -- conditional retry target when that condition is false.
        if complete then
          if destination then return self:SetStep(destination,manual) end
        end
      end
      if goal.nextGuide then
        local complete=self:IsGoalComplete(goal,self.currentStep,goalIndex)
        if complete then return self:SelectGuide(goal.nextGuide,goal.nextGuideStep) end
      end
      if goal.loadGuide and manual then return self:SelectGuide(goal.loadGuide,goal.loadGuideStep) end
    end
  end
  if self.currentStep<#self.currentGuide.steps then return self:SetStep(self.currentStep+1,manual) end
  local nextGuide=self.currentGuide.next
  if nextGuide and ZGV.Catalog:Get(nextGuide) then return self:SelectGuide(nextGuide,self.currentGuide.nextStep) end
  ZGV:Fire("ZGV_GUIDE_COMPLETE",self.currentGuide)
  return false
end

function Runtime:PreviousStep()
  if self.currentGuide and self.currentStep>1 then return self:SetStep(self.currentStep-1,true) end
  return false
end

function Runtime:ResetCurrentGuide()
  if not self.currentGuide then return end
  local prefix=self.currentGuide.id..":"
  for key in pairs(self.manual) do if key:sub(1,#prefix)==prefix then self.manual[key]=nil end end
  for key in pairs(self.killCounts) do if key:sub(1,#prefix)==prefix then self.killCounts[key]=nil end end
  for key in pairs(self.collectionBaselines) do if key:sub(1,#prefix)==prefix then self.collectionBaselines[key]=nil end end
  for key in pairs(self.talked) do if key:sub(1,#prefix)==prefix then self.talked[key]=nil end end
  for key in pairs(self.gossiped) do if key:sub(1,#prefix)==prefix then self.gossiped[key]=nil end end
  for key in pairs(self.interacted) do if key:sub(1,#prefix)==prefix then self.interacted[key]=nil end end
  for key in pairs(self.discoveries) do if key:sub(1,#prefix)==prefix then self.discoveries[key]=nil end end
  self:SetStep(1,true)
end

function Runtime:ActivateGoal(stepIndex,goalIndex)
  local guide=self.currentGuide
  local step=guide and guide.steps[stepIndex]
  local goal=step and step.goals[goalIndex]
  if not goal then return false end
  self.autoAdvanceBlocked=nil
  if goal.loadGuide then return self:SelectGuide(goal.loadGuide,goal.loadGuideStep) end
  if goal.nextGuide then return self:SelectGuide(goal.nextGuide,goal.nextGuideStep) end
  if goal.nextJump or goal.nextLabel then
    local destination=self:ResolveStepJump(guide,stepIndex,goal.nextJump or goal.nextLabel)
    if destination then return self:SetStep(destination,true) end
  end
  if goal.itemID and (goal.action=="use" or goal.modifiers.useItem) and ZGV.Inventory then
    local used=ZGV.Inventory:UseItem(goal.itemID)
    if used then return true end
  end
  self.manual[self:ManualKey(stepIndex,goalIndex)]=true
  ZGV:Fire("ZGV_GOAL_UPDATED",guide,stepIndex,goalIndex)
  return true
end

function Runtime:UpdateWaypoint()
  if not ZGV.Navigation then return end
  local step=self.currentGuide and self.currentGuide.steps[self.currentStep]
  local destination,title
  if step and self:IsStepApplicable(step) then
    for i=1,#step.goals do
      local goal=step.goals[i]
      if goal.destination and self:IsGoalApplicable(goal) and not self:IsGoalComplete(goal,self.currentStep,i) then
        destination=goal.destination
        title=goal.text
        break
      end
    end
  end
  if destination then ZGV.Navigation:SetWaypoint(destination,title,step.markers)
  else ZGV.Navigation:ClearWaypoint() end
end

function Runtime:ToggleFavorite(guide)
  guide=self:ResolveGuide(guide)
  if not guide then return end
  local favorites=ZGV.db.profile.favorites
  favorites[guide.id]=not favorites[guide.id] or nil
  ZGV:Fire("ZGV_FAVORITES_CHANGED",guide)
end

function Runtime:ChooseSuggestedGuide()
  for i=1,#ZGV.Catalog.sorted do
    local guide=ZGV.Catalog.sorted[i]
    if not guide.beta and ZGV.Conditions:EvaluateHeader(guide,"condition_visible",true)
      and ZGV.Conditions:EvaluateHeader(guide,"condition_suggested",false) then return guide end
  end
  for i=1,#ZGV.Catalog.sorted do
    local guide=ZGV.Catalog.sorted[i]
    if guide.category:lower():find("level") and not guide.beta and ZGV.Conditions:EvaluateHeader(guide,"condition_visible",true) then return guide end
  end
  return ZGV.Catalog.sorted[1]
end

function Runtime:Tick()
  if not self.currentGuide then return end
  local state=self:GetStepState(self.currentGuide.steps[self.currentStep],self.currentStep)
  ZGV:Fire("ZGV_RUNTIME_TICK",state)
  local blocked=self.autoAdvanceBlocked
  if blocked and blocked.guide==self.currentGuide.id and blocked.step==self.currentStep then
    -- Do not release this guard from a timer-derived state change.  It is
    -- released by a quest/inventory/aura event whose progress fingerprint has
    -- actually changed, or immediately by real kill/talk/gossip credit.
    return
  end
  if state.complete and GetTime()-self.lastAdvance>=self.autoAdvanceDelay then
    self.lastAdvance=GetTime()
    self:NextStep(false)
  end
end

local function npcIDFromGUID(guid)
  if type(guid)~="string" then return nil end
  -- Accept both the post-Cataclysm dash form used by some private-client
  -- backports and build-12340's hexadecimal GUID representation.
  return tonumber(guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-"))
    or tonumber(guid:match("^Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-"))
    or tonumber(guid:sub(7,10),16)
end

local function combatGUIDs(...)
  local timestamp,subevent,third,fourth,fifth,sixth,seventh,eighth,ninth,tenth,eleventh=...
  -- 3.3.5a does not include hideCaster or raid flags.  Accept both layouts so
  -- this stays correct on private-client variants that backport the newer one.
  if type(third)=="boolean" then return timestamp,subevent,fourth,eighth end
  return timestamp,subevent,third,sixth
end

function Runtime:CreditKill(npcID,destGUID,source)
  local now=GetTime and GetTime() or 0
  self.recentKills=self.recentKills or {}
  if destGUID and self.recentKills[destGUID] and now-self.recentKills[destGUID]<2 then return false end
  if destGUID then self.recentKills[destGUID]=now end
  local guide=self.currentGuide
  if not npcID or not guide then return false end
  local changed=false
  for _,entry in ipairs(self:GetActiveSteps()) do
    for goalIndex,goal in ipairs(entry.step.goals) do
      if goal.action=="kill" and tonumber(goal.npcID)==npcID and goal.count and self:IsGoalApplicable(goal) then
        local key=self:ManualKey(entry.index,goalIndex)
        local required=tonumber(goal.count) or 1
        self.killCounts[key]=math.min(required,(tonumber(self.killCounts[key]) or 0)+1)
        changed=true
      end
    end
  end
  if changed then
    self.autoAdvanceBlocked=nil
    ZGV:Fire("ZGV_GOAL_UPDATED",guide,self.currentStep)
    ZGV:LogInfo("progress","kill credit for npc "..tostring(npcID).." via "..tostring(source))
  end
  return changed
end

function Runtime:RecordKillFromCombatLog(...)
  local timestamp,subevent,sourceGUID,destGUID=combatGUIDs(...)
  if not subevent then return end
  local playerGUID=UnitGUID and UnitGUID("player")
  local petGUID=UnitGUID and UnitGUID("pet")
  local isPlayer=sourceGUID and (sourceGUID==playerGUID or sourceGUID==petGUID)
  self.damageTargets=self.damageTargets or {}
  if isPlayer and (subevent=="SWING_DAMAGE" or subevent=="RANGE_DAMAGE" or subevent=="SPELL_DAMAGE" or subevent=="SPELL_PERIODIC_DAMAGE") then
    self.damageTargets[destGUID]=GetTime and GetTime() or 0
    return
  end
  if subevent=="PARTY_KILL" and isPlayer then
    return self:CreditKill(npcIDFromGUID(destGUID),destGUID,"party_kill")
  end
  -- Some 3.3.5 forks omit PARTY_KILL for pet/ranged kills.  UNIT_DIED can be
  -- credited only when the player or pet damaged that exact GUID recently.
  if subevent=="UNIT_DIED" and destGUID then
    local damagedAt=self.damageTargets[destGUID]
    local now=GetTime and GetTime() or 0
    if damagedAt and now-damagedAt<=12 then
      self.damageTargets[destGUID]=nil
      return self:CreditKill(npcIDFromGUID(destGUID),destGUID,"unit_died")
    end
  end
end

function Runtime:RecordTalk(event)
  local guide=self.currentGuide
  if not guide then return end
  -- The unit remains selected while the gossip, quest or merchant panel is
  -- opening.  Mouseover is a useful fallback for click-to-interact users.
  local npcID=npcIDFromGUID(UnitGUID and UnitGUID("target"))
    or npcIDFromGUID(UnitGUID and UnitGUID("mouseover"))
  if not npcID then return end
  local changed=false
  for _,entry in ipairs(self:GetActiveSteps()) do
    for goalIndex,goal in ipairs(entry.step.goals) do
      if goal.action=="talk" and tonumber(goal.npcID)==npcID and self:IsGoalApplicable(goal) then
        local key=self:ManualKey(entry.index,goalIndex)
        if not self.talked[key] then
          self.talked[key]={npcID=npcID,event=event,time=time()}
          changed=true
        end
      end
      if (goal.action=="vendor" or goal.action=="trainer") and tonumber(goal.npcID)==npcID and self:IsGoalApplicable(goal) then
        local key=self:ManualKey(entry.index,goalIndex)
        if not self.interacted[key] then
          self.interacted[key]={npcID=npcID,event=event,time=time()}
          changed=true
        end
      end
    end
  end
  if changed then
    self.autoAdvanceBlocked=nil
    ZGV:LogInfo("progress","talk credit for npc "..tostring(npcID).." via "..tostring(event))
    ZGV:Fire("ZGV_GOAL_UPDATED",guide,self.currentStep)
  end
end

function Runtime:RecordTravel(event)
  local guide=self.currentGuide
  if not guide then return end
  local changed=false
  for _,entry in ipairs(self:GetActiveSteps()) do
    for goalIndex,goal in ipairs(entry.step.goals) do
      if (goal.action=="taxi" or goal.action=="fly") and self:IsGoalApplicable(goal) then
        local key=self:ManualKey(entry.index,goalIndex)
        if not self.interacted[key] then self.interacted[key]={event=event,time=time()}; changed=true end
      end
    end
  end
  if changed then self.autoAdvanceBlocked=nil; ZGV:Fire("ZGV_GOAL_UPDATED",guide,self.currentStep) end
end

function Runtime:RecordDiscovery(first,second)
  local guide=self.currentGuide
  local errorType,message
  if type(first)=="number" and type(second)=="string" then errorType,message=first,second
  elseif type(first)=="string" then message=first
  elseif type(second)=="string" then message=second end
  if errorType and tonumber(errorType) and tonumber(errorType)~=396 then return end
  if not guide or type(message)~="string" then return end
  local normalized=message:lower()
  local changed=false
  for _,entry in ipairs(self:GetActiveSteps()) do
    for goalIndex,goal in ipairs(entry.step.goals) do
      local zone=tostring(goal.discoverZone or goal.target or ""):lower()
      if goal.action=="discover" and zone~="" and normalized:find(zone,1,true) and self:IsGoalApplicable(goal) then
        local key=self:ManualKey(entry.index,goalIndex)
        if not self.discoveries[key] then self.discoveries[key]={message=message,time=time()}; changed=true end
      end
    end
  end
  if changed then self.autoAdvanceBlocked=nil; ZGV:Fire("ZGV_GOAL_UPDATED",guide,self.currentStep) end
end

local function normalizedGossip(text)
  return tostring(text or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("[_\"']",""):gsub("%s+"," "):lower():gsub("^%s+",""):gsub("%s+$","")
end

function Runtime:RecordGossip(index)
  local guide=self.currentGuide
  if not guide then return end
  local npcID=npcIDFromGUID(UnitGUID and UnitGUID("target"))
  if not npcID then return end
  local selected
  if GetGossipOptions and index then selected=select((tonumber(index)-1)*2+1,GetGossipOptions()) end
  selected=normalizedGossip(selected)
  local changed=false
  for _,entry in ipairs(self:GetActiveSteps()) do
    for goalIndex,goal in ipairs(entry.step.goals) do
      if goal.action=="gossip" and self:IsGoalApplicable(goal)
        and (not goal.npcID or tonumber(goal.npcID)==npcID) then
        local expected=normalizedGossip(goal.gossipText)
        if expected=="" or selected=="" or expected:find(selected,1,true) or selected:find(expected,1,true) then
          local key=self:ManualKey(entry.index,goalIndex)
          if not self.gossiped[key] then
            self.gossiped[key]={npcID=npcID,index=index,time=time()}
            changed=true
          end
        end
      end
    end
  end
  if changed then
    self.autoAdvanceBlocked=nil
    ZGV:LogInfo("progress","gossip credit for npc "..tostring(npcID).." option "..tostring(index))
    ZGV:Fire("ZGV_GOAL_UPDATED",guide,self.currentStep)
  end
end

function Runtime:GetQuestDialogIdentity()
  local service=ZGV.Compat and ZGV.Compat.Quest
  local dialog=service and service.GetDialog and service:GetDialog()
  if dialog then return tonumber(dialog.questID),dialog.title end
  -- Quest IDs are read through Compat.Quest so the Runtime layer never calls
  -- a client-variant dialog API directly.  The title fallback is enough for
  -- exact matching on stripped-down UI packs that omit that service method.
  return nil,type(GetTitleText)=="function" and GetTitleText() or nil
end

function Runtime:FindActiveTurnIns(questID,questTitle)
  local results={}
  for _,entry in ipairs(self:GetActiveSteps()) do
    for goalIndex,goal in ipairs(entry.step.goals or {}) do
      if self:IsGoalApplicable(goal) and matchesTurnInGoal(goal,questID,questTitle) then
        results[#results+1]={stepIndex=entry.index,goalIndex=goalIndex,goal=goal}
      end
    end
  end
  return results
end

-- QUEST_COMPLETE opens the reward pane but does not itself mean the player
-- has handed a quest in: they can still close the pane or select a reward.
-- Keep the identity only long enough for the exact GetQuestReward hook below.
function Runtime:RememberTurnIn(questID,questTitle)
  if not questID then
    local dialogID,dialogTitle=self:GetQuestDialogIdentity()
    questID=dialogID
    questTitle=questTitle or dialogTitle
  end
  local matches=self:FindActiveTurnIns(questID,questTitle)
  if #matches==0 then self.pendingTurnIn=nil return false end
  self.pendingTurnIn={questID=tonumber(questID),title=questTitle,matches=matches,at=GetTime()}
  return true
end

-- GetQuestReward is the authoritative local signal that the reward was
-- accepted.  Recording it here covers both a manual hand-in and the addon’s
-- optional automatic hand-in, without guessing from QUEST_PROGRESS or from a
-- stale completed-quest snapshot.
function Runtime:RecordTurnIn(questID,questTitle,source)
  local pending=self.pendingTurnIn
  if not questID and pending then questID=pending.questID end
  if not questTitle and pending then questTitle=pending.title end
  if not questID and not questTitle then questID,questTitle=self:GetQuestDialogIdentity() end
  local matches=pending and pending.matches or self:FindActiveTurnIns(questID,questTitle)
  if not matches or #matches==0 then return false end
  local changed=false
  for _,match in ipairs(matches) do
    local key=self:ManualKey(match.stepIndex,match.goalIndex)
    if not self.manual[key] then self.manual[key]={source=source or "quest-reward",time=GetTime()}; changed=true end
  end
  local id=tonumber(questID)
  -- Preserve a local completion fact until the asynchronous 3.3.5 completed
  -- quest query catches up.  Repeatable goals deliberately ignore history in
  -- IsGoalComplete, so this cannot skip a later repeatable turn-in.
  if id then
    ZGV.completedQuests=ZGV.completedQuests or {}
    ZGV.completedQuests[id]=true
    local quest=ZGV.Compat and ZGV.Compat.Quest
    if quest and quest.MarkCompleted then quest:MarkCompleted(id,"turnin") end
  end
  self.pendingTurnIn=nil
  if changed then
    self.autoAdvanceBlocked=nil
    ZGV:LogInfo("progress","turn-in credit for quest "..tostring(id or questTitle or "unknown"))
    ZGV:Fire("ZGV_GOAL_UPDATED",self.currentGuide,self.currentStep)
  end
  return changed
end

function Runtime:OnEvent(event,...)
  if not self.currentGuide then return end
  local unit=...
  if event=="COMBAT_LOG_EVENT_UNFILTERED" then self:RecordKillFromCombatLog(...) end
  if event=="GOSSIP_SHOW" or event=="QUEST_GREETING" or event=="QUEST_DETAIL"
    or event=="QUEST_PROGRESS" or event=="QUEST_COMPLETE" or event=="MERCHANT_SHOW"
    or event=="TRAINER_SHOW" or event=="TAXIMAP_OPENED" then
    self:RecordTalk(event)
  end
  if event=="TAXIMAP_OPENED" then self:RecordTravel(event) end
  if event=="UI_INFO_MESSAGE" then self:RecordDiscovery(...) end
  if event=="QUEST_COMPLETE" then self:RememberTurnIn() end
  if event=="QUEST_FINISHED" then self.pendingTurnIn=nil end
  if event=="QUEST_LOG_UPDATE" or event=="BAG_UPDATE" or event=="PLAYER_LEVEL_UP"
    or event=="UNIT_INVENTORY_CHANGED" or event=="ACHIEVEMENT_EARNED"
    or (event=="UNIT_AURA" and unit=="player") then
    self:RefreshBlockedProgress(event)
  end
  ZGV:Fire("ZGV_GOAL_UPDATED",self.currentGuide,self.currentStep)
end

function Runtime:OnStartup()
  self.killCounts=ZGV.db.char.killProgress or self.killCounts or {}
  ZGV.db.char.killProgress=self.killCounts
  self.collectionBaselines=ZGV.db.char.collectionBaselines or self.collectionBaselines or {}
  ZGV.db.char.collectionBaselines=self.collectionBaselines
  self.talked=ZGV.db.char.talkProgress or self.talked or {}
  ZGV.db.char.talkProgress=self.talked
  self.gossiped=ZGV.db.char.gossipProgress or self.gossiped or {}
  ZGV.db.char.gossipProgress=self.gossiped
  self.interacted=ZGV.db.char.interactionProgress or self.interacted or {}
  ZGV.db.char.interactionProgress=self.interacted
  self.discoveries=ZGV.db.char.discoveryProgress or self.discoveries or {}
  ZGV.db.char.discoveryProgress=self.discoveries
  if not self.gossipHooked and type(hooksecurefunc)=="function" and type(SelectGossipOption)=="function" then
    hooksecurefunc("SelectGossipOption",function(index) Runtime:RecordGossip(index) end)
    self.gossipHooked=true
  end
  if not self.rewardHooked and type(hooksecurefunc)=="function" and type(GetQuestReward)=="function" then
    hooksecurefunc("GetQuestReward",function() Runtime:RecordTurnIn(nil,nil,"GetQuestReward") end)
    self.rewardHooked=true
  end
  local quest=ZGV.Compat and ZGV.Compat.Quest
  if quest then quest:RefreshLog() quest:RefreshCompleted(false) end
  local saved=ZGV.db.profile.currentGuide
  if saved and not self:SelectGuide(saved,ZGV.db.profile.currentStep) then
    local migration=ZGV.db.root.migration
    migration.unmappedGuides[#migration.unmappedGuides+1]=saved
  end
  if not self.currentGuide then
    local suggested=self:ChooseSuggestedGuide()
    if suggested then self:SelectGuide(suggested,1) end
  end
  if ZGV.Compat and ZGV.Compat.Timer then
    self.ticker=ZGV.Compat.Timer:NewTicker(0.35,function() Runtime:Tick() end)
  end
end

for _,event in ipairs({"QUEST_LOG_UPDATE","BAG_UPDATE","PLAYER_LEVEL_UP","UNIT_INVENTORY_CHANGED","ACHIEVEMENT_EARNED","UNIT_AURA","PLAYER_DEAD","PLAYER_UNGHOST","COMBAT_LOG_EVENT_UNFILTERED","GOSSIP_SHOW","QUEST_GREETING","QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE","QUEST_FINISHED","MERCHANT_SHOW","TRAINER_SHOW","TAXIMAP_OPENED","UI_INFO_MESSAGE"}) do
  ZGV:RegisterEvent(event,Runtime,"OnEvent")
end

function ZGV:MagicKey()
  if not Runtime.currentGuide then return end
  for _,entry in ipairs(Runtime:GetDisplayGoals(Runtime.currentStep)) do
    if not (entry.state and entry.state.complete) then
      return Runtime:ActivateGoal(entry.stepIndex,entry.goalIndex)
    end
  end
  Runtime:NextStep(true)
end
