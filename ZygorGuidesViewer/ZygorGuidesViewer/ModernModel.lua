-- WotLK implementation of the modern Guide/Step/Goal public model.  This is
-- intentionally shaped after the current Classic viewer so its UI modules can
-- be ported without falling back to a second, simplified guide representation.
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
local Model = ZGV:RegisterModule("ModernModel", {})

local Guide = {}
local Step = {}
local Goal = {}
Guide.__index = Guide
Step.__index = Step
Goal.__index = Goal

local function runtime()
  return ZGV.Runtime
end

function Goal:New(data)
  data = data or {}
  return setmetatable(data, Goal)
end

function Goal:GetStatus()
  local active = self.parentStep and self.parentStep.parentGuide == runtime().currentGuide
  if not active then return "inactive" end
  return self:IsComplete() and "complete" or "incomplete"
end

function Goal:UpdateStatus()
  return self:GetStatus()
end

function Goal:IsVisible()
  return runtime():IsGoalApplicable(self)
end

function Goal:IsCompleteable()
  return not self.forceNoComplete and self.action ~= "text" and self.action ~= "label"
end

function Goal:IsComplete()
  if not self.parentStep then return false end
  local complete = runtime():IsGoalComplete(self, self.parentStep.num, self.num)
  return complete and true or false
end

function Goal:GetWaypoint()
  return self.destination
end

function Goal:GetText()
  return self.text or self.raw or ""
end

function Goal:GetTooltip()
  local lines = { self:GetText() }
  if self.destination then lines[#lines + 1] = "Waypoint: " .. tostring(self.destination.map or "unknown") end
  for index = 1, #(self.tips or {}) do lines[#lines + 1] = self.tips[index] end
  return table.concat(lines, "\n")
end

function Goal:IsActionable()
  return self.loadGuide ~= nil or self.nextGuide ~= nil or self.nextJump ~= nil or self.nextLabel ~= nil or self.itemID ~= nil or self:IsCompleteable()
end

function Goal:OnClick()
  if not self.parentStep then return false end
  return runtime():ActivateGoal(self.parentStep.num, self.num)
end

function Goal:GetDebugDump()
  return string.format("goal=%d action=%s complete=%s text=%s", self.num or 0, tostring(self.action), tostring(self:IsComplete()), self:GetText())
end

function Step:New(data)
  data = data or {}
  data.goals = data.goals or {}
  return setmetatable(data, Step)
end

function Step:IsComplete()
  local state = runtime():GetStepState(self, self.num)
  return state.complete and true or false
end

function Step:NeedsUpdating()
  return self.parentGuide == runtime().currentGuide
end

function Step:GetTitle()
  if self.comment and self.comment ~= "" then return self.comment end
  local first = self.goals and self.goals[1]
  return first and first:GetText() or "Step " .. tostring(self.num or 0)
end

function Step:GetWayTitle()
  local goal = self.goals and self.goals[1]
  return goal and goal:GetText() or self:GetTitle()
end

function Step:GetNext()
  local guide = self.parentGuide
  return guide and guide.steps[(self.num or 0) + 1] or nil
end

function Step:GetNextStep(label)
  local guide = self.parentGuide
  local index = guide and guide.labels and guide.labels[label]
  return index and guide.steps[index] or self:GetNext()
end

function Step:GetNextValidStep()
  return self:GetNext()
end

function Step:GetNextCompletableStep()
  local candidate = self:GetNext()
  while candidate and not candidate:IsComplete() do return candidate end
  return candidate
end

function Step:GetStepDisplayLabel()
  return tostring(self.num or 0)
end

function Step:GetDebugDump()
  return string.format("step=%d complete=%s goals=%d", self.num or 0, tostring(self:IsComplete()), #(self.goals or {}))
end

function Guide:New(title, header, data)
  return setmetatable({ title = title, header = header or {}, raw = data or "", steps = {}, labels = {} }, Guide)
end

function Guide:GetStatus(detailed)
  local completion = self:GetCompletion()
  if completion >= 1 then return "complete", detailed and completion or nil end
  return "incomplete", detailed and completion or nil
end

function Guide:GetCompletion()
  if #(self.steps or {}) == 0 then return 0 end
  local complete = 0
  for index = 1, #self.steps do if self.steps[index]:IsComplete() then complete = complete + 1 end end
  return complete / #self.steps
end

function Guide:GetCompletionText()
  return string.format("%d%%", math.floor(self:GetCompletion() * 100 + 0.5))
end

function Guide:Load(step)
  return runtime():SelectGuide(self, step)
end

function Guide:Unload()
  return true
end

function Guide:GetCurStep()
  if self ~= runtime().currentGuide then return nil end
  return self.steps[runtime().currentStep]
end

function Guide:GetStep(numberOrLabel)
  local index = type(numberOrLabel) == "string" and self.labels[numberOrLabel] or numberOrLabel
  return self.steps[tonumber(index) or 1]
end

function Guide:GetParentFolder()
  return self.path or ""
end

function Guide:ToggleFavourite()
  return runtime():ToggleFavorite(self)
end

function Guide:IsFavourite()
  return ZGV.db and ZGV.db.profile.favorites[self.id] and true or false
end

function Guide:tostring()
  return self.title
end

function Model:DecorateGuide(guide)
  if type(guide) ~= "table" or guide._modernModel then return guide end
  setmetatable(guide, Guide)
  guide._modernModel = true
  guide.num = guide.num or guide.registered
  if Guide.SyncLegacyFields then guide:SyncLegacyFields() end
  for stepIndex = 1, #(guide.steps or {}) do
    local step = guide.steps[stepIndex]
    setmetatable(step, Step)
    step.parentGuide = guide
    step.num = step.num or step.number or stepIndex
    step.number = step.num
    for goalIndex = 1, #(step.goals or {}) do
      local goal = step.goals[goalIndex]
      setmetatable(goal, Goal)
      goal.parentGuide = guide
      goal.parentStep = step
      goal.num = goal.num or goalIndex
      if Goal.SyncLegacyFields then Goal:SyncLegacyFields() end
    end
  end
  return guide
end

function Model:OnGuideChanged(guide)
  self:DecorateGuide(guide)
  ZGV.CurrentGuide = guide
  ZGV.CurrentStep = guide and guide.steps[runtime().currentStep] or nil
end

function Model:OnStartup()
  if runtime().currentGuide then self:OnGuideChanged(runtime().currentGuide) end
end

ZGV.Guide = Guide
ZGV.Step = Step
ZGV.Goal = Goal
ZGV:RegisterCallback("ZGV_GUIDE_CHANGED", Model, "OnGuideChanged")
