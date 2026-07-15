-- WotLK renderer for the modern Starlight pointer.  It consumes the native
-- Navigation state but uses the upstream pointer's sprite sheets and layout.
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
local UI = ZGV.UI
if type(UI) ~= "table" then return end

local ROOT = ZGV.ARROWSDIR .. "Starlight\\"
local SPECIALS = {
  arrived = { 1, 1 }, waiting = { 1, 2 }, upstairs = { 2, 1 }, downstairs = { 2, 2 },
  error = { 3, 1 }, unreachable = { 4, 1 }, route = { 5, 1 }, taxi = { 5, 1 }, ship = { 6, 1 },
}

local function setSpecial(texture, name)
  local icon = SPECIALS[name] or SPECIALS.waiting
  local left, top = (icon[1] - 1) / 8, (icon[2] - 1) / 2
  texture:SetTexture(ROOT .. "specials")
  texture:SetTexCoord(left, left + 1 / 8, top, top + 1 / 2)
end

local function setDirection(texture, relative)
  -- Starlight contains 150 half-circle sprites.  The original viewer creates
  -- its other 148 directions by walking backwards through the atlas with a
  -- horizontal mirror.  Treating those 150 images as a whole circle was why
  -- directions on the rear half of the compass were visibly wrong.
  local degrees = (relative or 0) * 180 / math.pi
  while degrees < 0 do degrees = degrees + 360 end
  while degrees >= 360 do degrees = degrees - 360 end
  local sequence = math.floor(degrees / (360 / 298) + .5) + 1
  if sequence > 298 then sequence = 298 end
  local mirrored = sequence > 150
  local sprite = mirrored and (300 - sequence) or sequence
  local column, row = (sprite - 1) % 10, math.floor((sprite - 1) / 10)
  texture:SetTexture(ROOT .. "arrow")
  local left, right, top, bottom = column / 10, (column + 1) / 10, row / 15, (row + 1) / 15
  if mirrored then left, right = right, left end
  texture:SetTexCoord(left, right, top, bottom)
end

local function trim(text, limit)
  text = tostring(text or "")
  return #text > limit and text:sub(1, limit - 3) .. "..." or text
end

local function routeSummary()
  local navigation = ZGV.Navigation
  local instructions = navigation and navigation:GetRouteInstructions() or {}
  local lines = {}
  for _, instruction in ipairs(instructions) do
    if not instruction.complete and #lines < 3 then
      local prefix = instruction.active and "|cffffa800›|r " or "|cffaaaaaa•|r "
      lines[#lines + 1] = prefix .. trim(instruction.text, 34)
    end
  end
  return table.concat(lines, "\n")
end

function UI:CreateArrow()
  if self.arrow and self.arrow.modernArrow then return self.arrow end
  local options = ZGV.db.profile.arrow
  local frame = CreateFrame("Button", "ZygorGuidesViewerPointer", UIParent)
  frame.modernArrow = true
  frame:SetWidth(122); frame:SetHeight(118)
  frame:SetScale(options.scale or 1)
  frame:SetPoint("CENTER", UIParent, "CENTER", options.x or 0, options.y or -120)
  frame:SetFrameStrata("HIGH")
  frame:SetToplevel(true); frame:SetClampedToScreen(true); frame:SetMovable(true)
  frame:EnableMouse(true); frame:EnableMouseWheel(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) if not InCombatLockdown() then self:StartMoving() end end)
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter(); local px, py = UIParent:GetCenter()
    local current = ZGV.db and ZGV.db.profile and ZGV.db.profile.arrow
    if current and x and px then current.x = math.floor(x - px + 0.5) end
    if current and y and py then current.y = math.floor(y - py + 0.5) end
  end)
  frame:SetScript("OnMouseWheel", function(self, delta)
    if IsControlKeyDown and IsControlKeyDown() then
      local current = ZGV.db and ZGV.db.profile and ZGV.db.profile.arrow
      if not current then return end
      current.scale = math.max(0.8, math.min(1.6, (current.scale or 1) + (delta > 0 and 0.1 or -0.1)))
      self:SetScale(current.scale)
    end
  end)
  frame:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
      local current = ZGV.db and ZGV.db.profile and ZGV.db.profile.arrow
      if current then current.shown = false end
      frame:Hide()
    else UI:Toggle() end
  end)
  local arrow = frame:CreateTexture(nil, "ARTWORK")
  arrow:SetWidth(102); arrow:SetHeight(68); arrow:SetPoint("TOP", frame, "TOP", 0, -2)
  frame.arrow = arrow
  local special = frame:CreateTexture(nil, "ARTWORK")
  special:SetWidth(50); special:SetHeight(50); special:SetPoint("TOP", frame, "TOP", 0, -8); special:Hide()
  frame.special = special
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  title:SetPoint("TOP", arrow, "BOTTOM", 0, 2); title:SetWidth(220); title:SetHeight(14); title:SetJustifyH("CENTER")
  title:SetFont(GameFontNormal:GetFont(), 10); frame.title = title
  local description = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  description:SetPoint("TOP", title, "BOTTOM", 0, -1); description:SetWidth(220); description:SetHeight(18); description:SetJustifyH("CENTER")
  description:SetFont(GameFontNormal:GetFont(), 10); frame.description = description
  local route = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  route:SetPoint("TOP", description, "BOTTOM", 0, -1); route:SetWidth(220); route:SetHeight(38)
  route:SetJustifyH("CENTER"); route:SetJustifyV("TOP"); route:SetFont(GameFontNormal:GetFont(), 10)
  frame.route = route
  frame:Hide()
  self.arrow = frame
  return frame
end

function UI:UpdateArrow(state)
  self.arrowState = state
  local arrow = self:CreateArrow()
  local options = ZGV.db.profile.arrow
  if not options.shown or not state or not state.visible then arrow:Hide(); return end
  arrow.title:SetText(state.title or "Zygor waypoint")
  local summary = routeSummary()
  arrow.route:SetText(summary)
  if summary ~= "" then arrow.route:Show(); arrow:SetHeight(142) else arrow.route:Hide(); arrow:SetHeight(118) end
  if state.status == "direct" then
    arrow.special:Hide(); arrow.arrow:Show(); setDirection(arrow.arrow, state.relative)
    local distance = type(state.distance) == "number" and string.format("%.0f yards", state.distance) or ""
    arrow.description:SetText(distance)
  else
    arrow.arrow:Hide(); arrow.special:Show(); setSpecial(arrow.special, state.status)
    local labels = { arrived = "You have arrived", route = "Route available", unreachable = "Waypoint on another map", none = "No waypoint" }
    arrow.description:SetText(labels[state.status] or "Finding route")
  end
  arrow:Show()
end

function UI:OnStartup()
  self:CreateFrame(); self:CreateMinimapButton(); self:CreateArrow(); self:UpdateArrow(ZGV.Navigation and ZGV.Navigation:GetArrowState())
  if ZGV.db.profile.viewer.shown ~= false then self:ShowViewer() end
end
