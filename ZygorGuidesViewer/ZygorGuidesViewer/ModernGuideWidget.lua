-- Floating compact objective widget, matching the modern widget interaction.
local addonName, addonNamespace = ...
local ZGV
if type(addonNamespace) == "table" then
  ZGV = addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV
end
if not ZGV then ZGV = _G.ZygorGuidesViewer end
if type(ZGV) ~= "table" then return end

local Widget = ZGV:RegisterModule("GuideWidget", { rows = {} })
local MAX_ROWS = 4

local function options()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.widgets.guide
end

local function skin(name, fallback)
  local value = ZGV.GetSkinData and ZGV:GetSkinData(name)
  return value ~= nil and value or fallback
end

local function makeText(parent, size)
  local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  local path, _, flags = GameFontNormal:GetFont()
  text:SetFont(path, size, flags)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("MIDDLE")
  return text
end

local function goalText(goal, state)
  local text = goal and (goal.text or goal.raw) or ""
  if state and type(state.current) == "number" and type(state.required) == "number" then
    text = text .. " |cffffd45a(" .. state.current .. "/" .. state.required .. ")|r"
  end
  return text
end

local stepIconColumns = {
  accept = 6, turnin = 6, havequest = 6, nothavequest = 6, notcompleted = 6,
  kill = 7, goal = 7, clicknpc = 7,
  collect = 8, buy = 8, create = 8, craft = 8, use = 8, equip = 8, trash = 8,
  talk = 13, gossip = 13, trainer = 13, vendor = 13, fly = 13, taxi = 13,
  ["goto"] = 14, map = 14, home = 14, portal = 14, teleport = 14,
  daily = 11, achieve = 9, ding = 9,
}

local function setStepIcon(texture, goal, complete)
  local column = complete and 3 or stepIconColumns[goal and goal.action] or 1
  texture:SetTexCoord((column - 1) / 32, column / 32, 0, 1)
  texture:SetVertexColor(complete and .2 or 1, complete and .9 or 1, complete and .3 or 1, 1)
end

function Widget:Create()
  if self.frame then return self.frame end
  local config = options()
  local frame = CreateFrame("Frame", "ZygorGuidesViewerGuideWidget", UIParent)
  frame:SetWidth(300)
  frame:SetHeight(48 + MAX_ROWS * 25)
  frame:SetPoint("CENTER", UIParent, "CENTER", config.x or 250, config.y or -130)
  frame:SetFrameStrata("HIGH")
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self)
    if not config.locked then self:StartMoving() end
  end)
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local px, py = UIParent:GetCenter()
    if x and px then config.x, config.y = math.floor(x - px + .5), math.floor(y - py + .5) end
  end)
  frame:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white", edgeSize = 1 })
  frame:Hide()
  self.frame = frame

  local title = makeText(frame, 12)
  title:SetPoint("TOPLEFT", frame, "TOPLEFT", 9, -7)
  title:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -27, -7)
  title:SetHeight(18)
  frame.title = title
  self.title = title

  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
  close:SetScale(.7)
  close:SetScript("OnClick", function() Widget:Hide() end)

  for index = 1, MAX_ROWS do
    local row = CreateFrame("Button", nil, frame)
    row:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -30 - (index - 1) * 25)
    row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -30 - (index - 1) * 25)
    row:SetHeight(23)
    row:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white" })
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("LEFT", row, "LEFT", 5, 0)
    icon:SetWidth(13)
    icon:SetHeight(13)
    icon:SetTexture(ZGV.SKINDIR .. "guideicons-small")
    row.icon = icon
    local text = makeText(row, 11)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetPoint("RIGHT", row, "RIGHT", -5, 0)
    row.text = text
    row:SetScript("OnClick", function(self)
      if self.goalIndex then ZGV.Runtime:ActivateGoal(self.stepIndex or ZGV.Runtime.currentStep, self.goalIndex) end
    end)
    row:SetScript("OnEnter", function(self)
      if self.goal and self.goal.GetTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.goal:GetTooltip(), 1, 1, 1, true)
        GameTooltip:Show()
      end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:Hide()
    self.rows[index] = row
  end
  self:ApplySkin()
  return frame
end

function Widget:ApplySkin()
  if not self.frame then return end
  self.frame:SetBackdrop(skin("WidgetBackdrop", skin("SmallOpaqueBackdrop", { bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white", edgeSize = 1 })))
  self.frame:SetBackdropColor(unpack(skin("WidgetBackdropColor", skin("SmallOpaqueBackdropColor", { .06, .06, .06, .94 }))))
  self.frame:SetBackdropBorderColor(unpack(skin("WidgetBackdropBorderColor", skin("SmallOpaqueBackdropBorderColor", { .2, .2, .2, 1 }))))
  for _, row in ipairs(self.rows) do
    row:SetBackdrop(skin("StepBackdrop", { bgFile = ZGV.SKINDIR .. "white" }))
    row:SetBackdropColor(unpack(skin("StepBackdropColor", { .12, .12, .12, 1 })))
    row.icon:SetTexture(skin("StepLineIcons", ZGV.SKINDIR .. "guideicons-small"))
  end
end

function Widget:Refresh()
  if not self.frame or not self.frame:IsShown() then return end
  local runtime = ZGV.Runtime
  local guide = runtime and runtime.currentGuide
  local step = guide and guide.steps[runtime.currentStep]
  if not step then
    self.title:SetText("No active guide")
    for _, row in ipairs(self.rows) do row:Hide() end
    return
  end
  self.title:SetText((guide.name or guide.title or "Guide") .. "  -  Step " .. runtime.currentStep)
  local rowIndex = 0
  for _,entry in ipairs(runtime:GetDisplayGoals(runtime.currentStep)) do
    if rowIndex>=MAX_ROWS then break end
    rowIndex = rowIndex + 1
    local row,goal,goalState=self.rows[rowIndex],entry.goal,entry.state
    local complete = goalState and goalState.complete
    row.goal,row.goalIndex,row.stepIndex=goal,entry.goalIndex,entry.stepIndex
    row.text:SetText((entry.sticky and "• " or "")..goalText(goal, goalState))
    setStepIcon(row.icon, goal, complete)
    row:SetBackdropColor(0, 0, 0, complete and .15 or .35)
    row:Show()
  end
  for index = rowIndex + 1, MAX_ROWS do self.rows[index]:Hide() end
end

function Widget:Show()
  self:Create()
  options().shown = true
  self.frame:Show()
  self:Refresh()
end

function Widget:Hide()
  if self.frame then self.frame:Hide() end
  options().shown = false
end

function Widget:Toggle()
  self:Create()
  if self.frame:IsShown() then self:Hide() else self:Show() end
end

function Widget:OnStartup()
  self:Create()
  if options().shown then self:Show() end
end

ZGV:RegisterCallback("ZGV_GUIDE_CHANGED", Widget, "Refresh")
ZGV:RegisterCallback("ZGV_STEP_CHANGED", Widget, "Refresh")
ZGV:RegisterCallback("ZGV_GOAL_UPDATED", Widget, "Refresh")
ZGV:AddMessageHandler("SKIN_UPDATED", function() Widget:ApplySkin() end)
