-- Complete the legacy Step prototype on top of ModernModel/Runtime.  The
-- underlying parser remains the single source of truth; these methods restore
-- public behavior expected by migrated guide and UI code.
local ZGV=ZygorGuidesViewer
if not ZGV or not ZGV.Step then return end
local Step=ZGV.Step
local Runtime=ZGV.Runtime

function Step:RaceClassMatch(value) return not value or (ZGV.RaceClassMatch and ZGV:RaceClassMatch(value)) or true end
function Step:AreRequirementsMet()
  if self.requirement then
    local matched=false
    for _,value in pairs(self.requirement) do if self:RaceClassMatch(value) then matched=true break end end
    if not matched then return false end
  end
  if self.condition_visible and ZGV.Conditions then return ZGV.Conditions:Evaluate(self.condition_visible,self.parentGuide) and true or false end
  return Runtime:IsStepApplicable(self)
end
function Step:PrepareCompletion()
  for _,goal in ipairs(self.goals or {}) do if type(goal.Prepare)=="function" then pcall(goal.Prepare,goal) end end
end
function Step:Translate() return false,false end -- all target guide text is parsed before display.
function Step:IsDynamic()
  for _,goal in ipairs(self.goals or {}) do if goal.dynamicwaypoint or goal.dynamic then return true end end
  return false
end
function Step:IsAuxiliary()
  for _,goal in ipairs(self.goals or {}) do
    if goal.questID or goal.action=="accept" or goal.action=="turnin" or goal.action=="kill" or goal.action=="collect" then return false end
  end
  return true
end
function Step:IsObsolete()
  if not self:AreRequirementsMet() then return true end
  local state=Runtime:GetStepState(self,self.num)
  return state.complete and true or false
end
function Step:IsAuxiliarySkippable()
  return self:IsAuxiliary() and (self:IsComplete() or self:IsObsolete())
end
function Step:GetWayTitle()
  for _,goal in ipairs(self.goals or {}) do if goal.destination then return goal.text or self:GetTitle() end end
  return self:GetTitle()
end
function Step:OnEnter()
  if self.parentGuide==Runtime.currentGuide and self.num==Runtime.currentStep then Runtime:UpdateWaypoint() end
end
function Step:OnLeave() end
function Step:GetJumpDestination(label)
  return Runtime:ResolveStepJump(self.parentGuide,self.num,label)
end
function Step:GetNextStep()
  local guide=self.parentGuide
  if guide and self.num<#guide.steps then return guide.steps[self.num+1] end
  if guide and guide.next and ZGV.Catalog then
    local nextGuide=ZGV.Catalog:Get(guide.next)
    if nextGuide then
      local parsed=ZGV.Parser:ParseGuide(nextGuide)
      return parsed and parsed.steps[1] or nil
    end
  end
end
function Step:GetNextValidStep()
  local candidate=self:GetNextStep()
  while candidate and not candidate:AreRequirementsMet() do candidate=candidate:GetNextStep() end
  return candidate
end
function Step:GetNextCompletableStep()
  local candidate=self:GetNextValidStep()
  while candidate and candidate:IsComplete() do candidate=candidate:GetNextValidStep() end
  return candidate
end
function Step:CheckVisitedGotos()
  local changed=false
  for _,goal in ipairs(self.goals or {}) do if goal.CheckVisited and goal:CheckVisited() then changed=true end end
  return changed
end
function Step:IsCurrentlySticky()
  local current=Runtime.currentGuide and Runtime.currentGuide.steps[Runtime.currentStep]
  for _,sticky in ipairs(current and current.stickies or {}) do if sticky==self then return true end end
  return false
end
function Step:CanBeSticky() return self.isSticky and true or false end
function Step:ShareToChat(channel)
  local lines={self:GetTitle()}
  for _,goal in ipairs(self.goals or {}) do lines[#lines+1]=goal.text or goal.raw or "" end
  local text=table.concat(lines," - ")
  if SendChatMessage and channel then SendChatMessage(text,channel) else ZGV:Print(text) end
  return text
end
function Step:ResetCurrentWaypoint() if self.parentGuide==Runtime.currentGuide then Runtime:UpdateWaypoint() end end
function Step:SelectClosestWaypoint()
  for _,goal in ipairs(self.goals or {}) do if goal.destination and ZGV.Navigation then ZGV.Navigation:SetWaypoint(goal.destination,goal.text); return goal end end
end
function Step:CycleWaypoint(delta)
  local points={}; for _,goal in ipairs(self.goals or {}) do if goal.destination then points[#points+1]=goal end end
  if #points==0 then return nil end
  self.current_waypoint_goal_num=((self.current_waypoint_goal_num or 0)+(delta or 1)-1)%#points+1
  return self:CycleWaypointTo(self.current_waypoint_goal_num)
end
function Step:CycleWaypointTo(number)
  local goal=self.goals and self.goals[tonumber(number)]
  if goal and goal.destination and ZGV.Pointer then ZGV.Pointer:SetWaypointToGoal(goal) end
  self.current_waypoint_goal_num=tonumber(number); return self.current_waypoint_goal_num,goal
end
function Step:CycleWaypointFrom(number) return self:CycleWaypoint((tonumber(number) or 1)-1) end
function Step:GetStepDisplayLabel() return self.label or tostring(self.num or self.number or 0) end
function Step:GetDebugDump()
  local state=Runtime:GetStepState(self,self.num)
  return string.format("step=%s label=%s complete=%s goals=%d",tostring(self.num),tostring(self.label or ""),tostring(state.complete),#(self.goals or {}))
end

local Bootstrap=ZGV:RegisterModule("StepCompat",{})
function Bootstrap:OnStartup() end
