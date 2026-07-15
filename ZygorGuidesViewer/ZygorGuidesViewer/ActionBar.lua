-- Source-name compatibility facade for the WotLK secure action bar.
--
-- ModernActionBar.lua owns the implementation.  Keeping this file thin is
-- important: build 12340 protected buttons must continue to use Blizzard's
-- SecureActionButtonTemplate OnClick handler and the modern combat queue.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" or type(ZGV.ActionBar) ~= "table" then return end

local ActionBar = ZGV.ActionBar
local modernCreate = ActionBar.Create

-- The Classic viewer exposed both Frame and frame.  The WotLK engine keeps
-- frame internally, so mirror the public field whenever creation succeeds.
if type(modernCreate) == "function" then
  function ActionBar:Create(...)
    local frame = modernCreate(self, ...)
    if frame then self.Frame = frame end
    return frame
  end
end
ActionBar.Frame = ActionBar.Frame or ActionBar.frame

function ActionBar:IsExpandingRight()
  local profile = ZGV.db and ZGV.db.profile and ZGV.db.profile.actionbar
  return not profile or profile.direction == 2
end

function ActionBar:ShowTooltip()
  if not GameTooltip then return end
  local owner = self.Frame or self.frame or UIParent
  GameTooltip:SetOwner(owner, "ANCHOR_BOTTOMLEFT")
  GameTooltip:SetText("Zygor Action Bar")
  GameTooltip:AddLine("Buttons follow the actionable goals in the current guide step.", .7, .7, .7, true)
  GameTooltip:Show()
end

-- Retained for source callers that used the old frame OnUpdate function.
-- The modern engine is event driven, so a queued refresh is the equivalent.
function ActionBar.Frame_OnUpdate()
  if type(ActionBar.Refresh) == "function" then return ActionBar:Refresh() end
end

-- The source implementation created a button as a side effect of SetButton.
-- ModernActionBar builds the complete secure set atomically; return the
-- corresponding live button after asking that engine to refresh it.
function ActionBar:SetButton(_, _, _, counter)
  if type(self.Refresh) == "function" then self:Refresh() end
  return self.buttons and self.buttons[tonumber(counter) or 1] or nil
end

function ActionBar:CreateGoaltype(goal)
  local runtime = ZGV.Runtime
  if not runtime or type(runtime.ActivateGoal) ~= "function" then return false end
  if type(goal) == "number" then
    return runtime:ActivateGoal(runtime.currentStep, goal)
  end
  local entries = type(runtime.GetDisplayGoals) == "function" and runtime:GetDisplayGoals(runtime.currentStep) or {}
  for _, entry in ipairs(entries) do
    if entry.goal == goal then return runtime:ActivateGoal(entry.stepIndex, entry.goalIndex) end
  end
  return false
end

-- These mixin names were public in the source ActionBar template.  Target XML
-- no longer instantiates that retail-era overlay, but retaining the methods
-- keeps optional source integrations harmless and routes cooldown work back to
-- the secure engine.
ZygorActionButtonOverlay_Mixin = ZygorActionButtonOverlay_Mixin or {}
function ZygorActionButtonOverlay_Mixin:OnEnter()
  if not GameTooltip then return end
  GameTooltip:SetOwner(self, "ANCHOR_TOP")
  GameTooltip:SetText(self.tooltip or "Zygor guide action")
  GameTooltip:Show()
end
function ZygorActionButtonOverlay_Mixin:OnLeave()
  if GameTooltip then GameTooltip:Hide() end
end
function ZygorActionButtonOverlay_Mixin:Setup(button, _, tooltip, btype, _, object)
  self.button, self.tooltip, self.btype, self.object = button, tooltip, btype, object
  return self
end
function ZygorActionButtonOverlay_Mixin:UpdateCooldown()
  if type(ActionBar.Refresh) == "function" then return ActionBar:Refresh() end
end
function ZygorActionButtonOverlay_Mixin:Reset()
  self.button, self.tooltip, self.btype, self.object = nil, nil, nil, nil
end
