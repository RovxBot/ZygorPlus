-- 3.3.5a implementation of the modern Classic viewer shell.  Its visual
-- language, icon atlases, skin properties, and interaction model follow the
-- current Default skin while the compatibility layer supplies the older API.
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
local UI = ZGV.UI
if type(UI) ~= "table" then return end

local ROWS = 12
local VIEWER_LAYOUT_VERSION = 2
local MIN_VIEWER_WIDTH = 300
local DEFAULT_VIEWER_WIDTH = 340
local MIN_GUIDE_HEIGHT = 155
local MAX_GUIDE_HEIGHT = 720
local MAX_GUIDE_TABS = 4
local function skin(name, fallback)
  local value = UI.SkinData and UI.SkinData(name)
  return value ~= nil and value or fallback
end

local function font(frame, size, r, g, b)
  local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  local path, _, flags = GameFontNormal:GetFont()
  text:SetFont(path, size, flags)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("MIDDLE")
  text:SetTextColor(r or 1, g or 1, b or 1, 1)
  return text
end

local function trim(text, length)
  text = tostring(text or "")
  return #text > length and text:sub(1, length - 3) .. "..." or text
end

local function plainText(text)
  text = tostring(text or "")
  text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  text = text:gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1")
  return text
end

-- The Anniversary viewer is a compact, auto-height step card.  The previous
-- WotLK shell instead reserved ten fixed 31px rows inside a 420px frame; the
-- final rows were below the content viewport and short steps left a large
-- empty panel.  Keep the measurement deterministic so it can be exercised
-- without a live FrameXML renderer, then prefer GetStringHeight at render
-- time when the client can provide an exact value.
function UI:MeasureGoalRow(text, availableWidth)
  local charactersPerLine = math.max(24, math.floor((tonumber(availableWidth) or 280) / 6.2))
  local lines = 0
  for segment in (plainText(text) .. "\n"):gmatch("(.-)\n") do
    lines = lines + math.max(1, math.ceil(#segment / charactersPerLine))
  end
  return math.max(26, math.min(74, lines * 14 + 8))
end

function UI:CalculateGuideHeight(rowHeights)
  local height = 139 -- title, tabs, toolbar, waypoint, progress, and margins
  for index, rowHeight in ipairs(rowHeights or {}) do
    height = height + math.max(26, tonumber(rowHeight) or 26)
    if index > 1 then height = height + 2 end
  end
  return math.max(MIN_GUIDE_HEIGHT, math.min(MAX_GUIDE_HEIGHT, height))
end

function UI:GetGuideHeightLimit()
  local limit = MAX_GUIDE_HEIGHT
  local frame = self.frame
  if UIParent and UIParent.GetHeight and frame and frame.GetScale then
    local screenHeight = tonumber(UIParent:GetHeight())
    local scale = tonumber(frame:GetScale()) or 1
    if screenHeight and screenHeight > 0 and scale > 0 then
      limit = math.min(limit, math.floor(screenHeight / scale - 20))
    end
  end
  return math.max(MIN_GUIDE_HEIGHT, limit)
end

function UI:PrepareViewerLayout(viewer)
  -- Database defaults are merged into existing SavedVariables before the UI
  -- starts, so layoutVersion alone cannot distinguish a fresh profile from a
  -- profile that persisted the placeholder renderer's forced dimensions.
  if viewer.classicLayoutMigrated ~= true then
    -- 400x420 was not a user-selected Classic layout: it was the hard minimum
    -- imposed by the placeholder renderer and was consequently persisted for
    -- every profile that opened it.  Restore the intended compact default.
    if tonumber(viewer.width) == 400 and tonumber(viewer.height) == 420 then
      viewer.width = DEFAULT_VIEWER_WIDTH
      viewer.height = MIN_GUIDE_HEIGHT
    end
    if viewer.autoHeight == nil then viewer.autoHeight = true end
    viewer.classicLayoutMigrated = true
  end
  viewer.layoutVersion = VIEWER_LAYOUT_VERSION
  viewer.width = math.max(MIN_VIEWER_WIDTH, tonumber(viewer.width) or DEFAULT_VIEWER_WIDTH)
  viewer.height = math.max(MIN_GUIDE_HEIGHT, tonumber(viewer.height) or MIN_GUIDE_HEIGHT)
  return viewer
end

function UI:SetGuideFrameHeight(height)
  local frame = self.frame
  if not frame or not ZGV.db.profile.viewer.autoHeight then return end
  height = math.max(MIN_GUIDE_HEIGHT, math.min(self:GetGuideHeightLimit(), tonumber(height) or MIN_GUIDE_HEIGHT))
  if math.abs((frame:GetHeight() or 0) - height) < .5 then return end
  frame._layoutSizing = true
  frame:SetHeight(height)
  frame._layoutSizing = nil
  ZGV.db.profile.viewer.height = math.floor(height + .5)
end

function UI:SetTemporaryFrameHeight(height)
  local frame = self.frame
  if not frame then return end
  frame._layoutSizing = true
  frame:SetHeight(math.max(MIN_GUIDE_HEIGHT, tonumber(height) or 420))
  frame._layoutSizing = nil
end

local function goalText(goal, state)
  local text = goal and (goal.text or goal.raw) or ""
  if state and type(state.current) == "number" and type(state.required) == "number" then
    local color = state.complete and "|cff55dd55" or "|cffffd45a"
    text = text .. " " .. color .. "(" .. state.current .. "/" .. state.required .. ")|r"
  end
  return text
end

-- Columns are the modern StepLineIcons atlas (32 x 1).  Keeping this mapping
-- in the 3.3.5 renderer gives instructions the same visual language as the
-- current viewer instead of reducing every action to a generic dot.
local stepIconColumns = {
  accept = 5, havequest = 5, nothavequest = 5, notcompleted = 5,
  turnin = 6,
  kill = 7, ["from"] = 7,
  get = 8, collect = 8, goldcollect = 8, buy = 8, create = 8, craft = 8, use = 8, equip = 8, trash = 8,
  goal = 9, image = 9, achieve = 9, ding = 9,
  home = 10,
  fpath = 11, fly = 11, taxi = 11, daily = 11,
  ["goto"] = 12, map = 12, portal = 12, teleport = 12,
  talk = 13, gossip = 13, trainer = 13, vendor = 13, clicknpc = 13,
  ["next"] = 14, treasure = 15, rare = 16, loadguide = 18,
}
UI.StepIconColumns = stepIconColumns

local function setStepIcon(texture, goal, complete)
  if not texture then return end
  local column = complete and 3 or stepIconColumns[goal and goal.action] or 2
  texture:SetTexCoord((column - 1) / 32, column / 32, 0, 1)
  texture:SetVertexColor(complete and .2 or 1, complete and .9 or 1, complete and .3 or 1, 1)
end

local function backdrop(frame, definition, color, border)
  if definition then frame:SetBackdrop(definition) end
  if color then frame:SetBackdropColor(unpack(color)) end
  if border then frame:SetBackdropBorderColor(unpack(border)) end
end

local function modernButton(parent, key, callback)
  local button = CreateFrame("Button", nil, parent)
  button:SetWidth(22)
  button:SetHeight(22)
  button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
  button:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
  button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
  button:GetNormalTexture():SetVertexColor(1, 1, 1, 1)
  button:GetPushedTexture():SetVertexColor(0.65, 0.65, 0.65, 1)
  button:GetHighlightTexture():SetBlendMode("ADD")
  button:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.22)
  button:SetScript("OnClick", callback)
  button:SetScript("OnEnter", function(self)
    if self.tooltip then
      GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
      GameTooltip:SetText(self.tooltip)
      GameTooltip:Show()
    end
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  button.buttonKey = key
  return button
end

local function buildButtonSet(button, key)
  local atlas = skin("TitleButtons")
  local names = ZGV.ButtonSets and ZGV.ButtonSets.TitleButtons
  local icon = names and names[key]
  local slots = { SETTINGS = 5, CLOSE = 6, DOTS = 7, STEP_PREV = 9, STEP_NEXT = 10, LOADGUIDE = 11, BURGER = 17 }
  if icon and icon.AssignToButton then
    icon:AssignToButton(button)
  elseif atlas then
    ZGV.F.AssignButtonTexture(button, atlas, slots[key] or 1, 64)
  end
end

local function textButton(parent, text, callback)
  local button = CreateFrame("Button", nil, parent)
  button:SetHeight(24)
  button:SetNormalFontObject(GameFontHighlightSmall)
  button:SetHighlightFontObject(GameFontHighlightSmall)
  button:SetText(text)
  button:SetScript("OnClick", callback)
  button:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white", edgeSize = 1 })
  return button
end

function UI:ApplyModernSkin()
  self:ApplyMinimapSkin()
  local frame = self.frame
  if not frame or not frame.modern then return end
  local window = skin("WindowBackdrop", skin("Backdrop"))
  local windowColor = skin("WindowBackdropColor", { 0.07, 0.07, 0.07, 1 })
  local windowBorder = skin("WindowBackdropBorderColor", { 0.15, 0.15, 0.15, 1 })
  backdrop(frame, window, windowColor, windowBorder)
  backdrop(frame.bodyBack, skin("WindowBottomBackdrop", skin("StepBackdrop", skin("Backdrop"))), skin("WindowBottomBackdropColor", skin("StepBackdropColor", { 0.12, 0.12, 0.12, 1 })), skin("WindowBottomBackdropBorderColor", skin("StepBackdropBorderColor", { 0.12, 0.12, 0.12, 1 })))
  backdrop(frame.titleBar, skin("Backdrop"), skin("WindowBackdropColor", { 0, 0, 0, 0 }), skin("SystemBarBackdropBorderColor", { 0, 0, 0, 0 }))
  backdrop(frame.tabsBar, skin("TabBackdrop", skin("Backdrop")), skin("TabBackdropColor", { 0, 0, 0, 0 }), skin("TabsBorderColor", { 0, 0, 0, 0 }))
  backdrop(frame.controlBar, skin("Backdrop"), skin("SystemBarBackdropColor", { 0.15, 0.15, 0.15, 1 }), skin("SystemBarBackdropBorderColor", { 0, 0, 0, 0 }))
  frame.logo:SetTexture(skin("TitleLogo", ZGV.SKINDIR .. "zygorlogo"))
  local logoWidth, logoHeight = unpack(skin("TitleLogoSize", { 100, 25 }))
  frame.logo:SetWidth(logoWidth)
  frame.logo:SetHeight(logoHeight)
  for _, button in ipairs(frame.iconButtons) do buildButtonSet(button, button.buttonKey) end
  -- Toolbar controls are separate from the title-bar button collection.  They
  -- must be assigned explicitly; otherwise the 3.3.5 fallback WHITE8X8
  -- texture remains visible as the blank white squares seen in the viewer.
  for _, button in ipairs({ frame.actionPrevious, frame.actionNext, frame.favorite, frame.options }) do
    if button then buildButtonSet(button, button.buttonKey) end
  end
  for _, button in ipairs(frame.tabs) do
    local inactive = skin("TabsBackdropInactive", { 0.05, 0.05, 0.05, 1 })
    if button.decorLeft then
      local decor = skin("TabsDecor", ZGV.SKINDIR .. "Default\\Starlight\\viewer8-tabs")
      button.decorLeft:SetTexture(decor); button.decorMiddle:SetTexture(decor); button.decorRight:SetTexture(decor)
      button.decorLeft:SetVertexColor(unpack(inactive)); button.decorMiddle:SetVertexColor(unpack(inactive)); button.decorRight:SetVertexColor(unpack(inactive))
      button:SetBackdropColor(0, 0, 0, 0)
    else
      button:SetBackdropColor(unpack(inactive))
    end
    button:SetBackdropBorderColor(unpack(skin("TabsBorderColor", { 0, 0, 0, 0 })))
  end
  for _, row in ipairs(frame.goalRows) do
    backdrop(row, skin("StepBackdrop"), skin("StepBackdropColor", { 0.12, 0.12, 0.12, 1 }), skin("StepBackdropBorderColor", { 0.12, 0.12, 0.12, 1 }))
    row.icon:SetTexture(skin("StepLineIcons", ZGV.SKINDIR .. "guideicons-small"))
  end
  for _, row in ipairs(frame.listRows) do
    backdrop(row, skin("SmallButtonBackdrop", skin("StepBackdrop")), skin("SmallButtonBackdropColor", { .10, .10, .10, 1 }), skin("SmallButtonBackdropBorderColor", { .16, .16, .16, 1 }))
    row.icon:SetTexture(skin("GuideMenuSmallIcons", ZGV.SKINDIR .. "guideicons-small"))
  end
  for _, row in ipairs(frame.settingRows) do
    backdrop(row, skin("SmallButtonBackdrop", skin("StepBackdrop")), skin("SmallButtonBackdropColor", { .10, .10, .10, 1 }), skin("SmallButtonBackdropBorderColor", { .16, .16, .16, 1 }))
    row.icon:SetTexture(skin("StepLineIcons", ZGV.SKINDIR .. "guideicons-small"))
  end
  backdrop(frame.progressBack, skin("ProgressBarBackdrop"), skin("ProgressBarBackdropColor", { 0.2, 0.2, 0.2, 1 }), skin("ProgressBarBackdropBorderColor", { 0, 0, 0, 0 }))
  frame.progress:SetStatusBarTexture(skin("ProgressBarTextureFile", ZGV.SKINDIR .. "white"))
  frame.progress:SetStatusBarColor(unpack(skin("ProgressBarTextureColor", { 0, 0.8, 0.1, 1 })))
end

function UI:FindGuideTab(guide)
  if not guide then return nil end
  for index, tab in ipairs(self.openTabs or {}) do
    if tab.id == guide.id then return tab, index end
  end
end

function UI:EnsureGuideTab(guide)
  if not guide then return end
  self.openTabs = self.openTabs or {}
  local tab = self:FindGuideTab(guide)
  if not tab then
    if #self.openTabs >= MAX_GUIDE_TABS then table.remove(self.openTabs, 1) end
    tab = { id = guide.id, title = guide.name or guide.title, step = ZGV.Runtime.currentStep or 1 }
    self.openTabs[#self.openTabs + 1] = tab
  else
    tab.title = guide.name or guide.title
    tab.step = ZGV.Runtime.currentStep or tab.step or 1
  end
  self.activeTab = tab
end

function UI:UpdateGuideTabs()
  local frame = self.frame
  if not frame or not frame.tabs then return end
  local open = self.openTabs or {}
  local barWidth = tonumber(frame.tabsBar:GetWidth())
  if not barWidth or barWidth <= 0 then barWidth = tonumber(frame:GetWidth()) or DEFAULT_VIEWER_WIDTH end
  local available = math.max(64, barWidth - 10)
  local widthCap = #open > 0 and math.floor((available - math.max(0, #open - 1) * 2) / #open) or available
  for index, button in ipairs(frame.tabs) do
    local tab = open[index]
    if tab then
      button.tab = tab
      button:SetText(trim(tab.title, 13))
      button.tooltip = tab.title
      button:SetWidth(math.max(50, math.min(widthCap, 104, 26 + #trim(tab.title, 13) * 6)))
      local active = self.activeTab == tab
      button.active = active
      local tabColor = skin(active and "TabsBackdropActive" or "TabsBackdropInactive", active and { .15, .15, .15, 1 } or { .05, .05, .05, 1 })
      if button.decorLeft then
        button:SetBackdropColor(0, 0, 0, 0)
        button.decorLeft:SetVertexColor(unpack(tabColor)); button.decorMiddle:SetVertexColor(unpack(tabColor)); button.decorRight:SetVertexColor(unpack(tabColor))
      else
        button:SetBackdropColor(unpack(tabColor))
      end
      button:Show()
    else
      button.tab = nil
      button:Hide()
    end
  end
end

function UI:SelectGuideTab(tab)
  if not tab then return end
  if ZGV.Runtime:SelectGuide(tab.id, tab.step) then
    self.activeTab = self:FindGuideTab(ZGV.Runtime.currentGuide) or tab
    self:SetMode("guide")
  end
end

function UI:CloseGuideTab(tab)
  local _, index = self:FindGuideTab(tab)
  if not index then return end
  table.remove(self.openTabs, index)
  if ZGV.Runtime.currentGuide and ZGV.Runtime.currentGuide.id == tab.id then
    local replacement = self.openTabs[math.min(index, #self.openTabs)]
    if replacement then self:SelectGuideTab(replacement)
    else
      ZGV.Runtime.currentGuide = nil
      ZGV.db.profile.currentGuide = nil
      self.activeTab = nil
      self:Refresh()
    end
  else
    self:UpdateGuideTabs()
  end
end

function UI:CreateFrame()
  if self.frame and self.frame.modern then return self.frame end
  local viewer = self:PrepareViewerLayout(ZGV.db.profile.viewer)
  -- Keep the public frame name used by the Anniversary skin and integrations;
  -- only its implementation is WotLK-native.
  local frame = CreateFrame("Frame", "ZygorGuidesViewerFrame", UIParent)
  frame.modern = true
  frame:SetWidth(viewer.width)
  frame:SetHeight(viewer.height)
  frame:SetScale(viewer.scale or 1)
  frame:SetPoint("CENTER", UIParent, "CENTER", viewer.x or -260, viewer.y or 40)
  frame:SetFrameStrata("MEDIUM")
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:SetResizable(true)
  frame:SetMinResize(MIN_VIEWER_WIDTH, MIN_GUIDE_HEIGHT)
  frame:EnableMouse(true)
  frame:EnableMouseWheel(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self)
    if not ZGV.db.profile.viewer.locked then self:StartMoving() end
  end)
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local px, py = UIParent:GetCenter()
    local current = ZGV.db.profile.viewer
    if x and px then current.x = math.floor(x - px + 0.5) end
    if y and py then current.y = math.floor(y - py + 0.5) end
  end)
  frame:SetScript("OnMouseWheel", function(_, delta)
    if UI.mode == "guide" then UI:ScrollGoals(delta)
    elseif UI.mode == "browse" then UI.listPage = math.max(1, UI.listPage - delta); UI:Refresh() end
  end)
  frame:SetScript("OnHide", function()
    ZGV.db.profile.viewer.shown = false
    if UI.viewerActions then UI.viewerActions:Hide() end
  end)
  frame:SetScript("OnSizeChanged", function(self, width, height)
    if self._constructing or self._sizing or self._layoutSizing then return end
    local current = ZGV.db.profile.viewer
    current.width = math.floor(width + .5)
    current.height = math.floor(height + .5)
  end)

  local function finishSizing()
    frame:StopMovingOrSizing()
    frame._sizing = nil
    local current = ZGV.db.profile.viewer
    current.width = math.floor(frame:GetWidth() + .5)
    current.height = math.floor(frame:GetHeight() + .5)
    UI:Refresh()
  end

  local function addResizer(direction)
    local handle = CreateFrame("Frame", nil, frame)
    if direction == "LEFT" then
      handle:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, -30); handle:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -2, 10); handle:SetWidth(5)
    elseif direction == "RIGHT" then
      handle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, -30); handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, 10); handle:SetWidth(5)
    elseif direction == "BOTTOM" then
      handle:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, -2); handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, -2); handle:SetHeight(5)
    elseif direction == "BOTTOMLEFT" then
      handle:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -2, -2); handle:SetWidth(10); handle:SetHeight(10)
    else
      handle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -2); handle:SetWidth(10); handle:SetHeight(10)
    end
    handle:SetFrameLevel((frame:GetFrameLevel() or 1) + 8)
    handle:EnableMouse(true)
    handle:SetScript("OnMouseDown", function()
      local current = ZGV.db.profile.viewer
      if not current.locked then
        if direction:find("BOTTOM", 1, true) then current.autoHeight = false end
        frame._sizing = true
        frame:StartSizing(direction)
      end
    end)
    handle:SetScript("OnMouseUp", finishSizing)
    return handle
  end
  -- The five handles mirror the Default skin's left, right, bottom, and
  -- lower-corner resizers without requiring modern XML mixin templates.
  frame.resizers = {
    addResizer("LEFT"), addResizer("RIGHT"), addResizer("BOTTOM"),
    addResizer("BOTTOMLEFT"), addResizer("BOTTOMRIGHT"),
  }
  frame._constructing = nil

  -- The source outer rounded backdrop is intentionally transparent in the
  -- Starlight skin.  Its separate Back frame supplies the visible step-card
  -- fill; omitting it made the WotLK viewer appear as disconnected controls.
  local bodyBack = CreateFrame("Frame", nil, frame)
  bodyBack:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -30)
  bodyBack:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  bodyBack:SetFrameLevel(frame:GetFrameLevel())
  frame.bodyBack = bodyBack

  local titleBar = CreateFrame("Frame", nil, frame)
  titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  titleBar:SetHeight(30)
  titleBar:EnableMouse(true)
  titleBar:RegisterForDrag("LeftButton")
  titleBar:SetScript("OnDragStart", frame:GetScript("OnDragStart"))
  titleBar:SetScript("OnDragStop", frame:GetScript("OnDragStop"))
  frame.titleBar = titleBar
  local logo = titleBar:CreateTexture(nil, "ARTWORK")
  logo:SetPoint("CENTER", titleBar, "CENTER", 0, -1)
  frame.logo = logo
  local guideName = font(titleBar, 11, 1, 1, 1)
  guideName:SetPoint("LEFT", titleBar, "LEFT", 32, 0)
  guideName:SetPoint("RIGHT", titleBar, "RIGHT", -55, 0)
  guideName:Hide()
  frame.guideName = guideName
  frame.iconButtons = {}
  local burger = modernButton(titleBar, "BURGER", function() UI:ShowGuideMenu() end)
  burger:SetWidth(20); burger:SetHeight(20); burger:SetPoint("LEFT", titleBar, "LEFT", 7, 0); burger.tooltip = "Guide menu"
  local close = modernButton(titleBar, "CLOSE", function() frame:Hide() end)
  close:SetWidth(20); close:SetHeight(20); close:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0); close.tooltip = "Close"
  frame.iconButtons[1], frame.iconButtons[2] = burger, close

  local tabsBar = CreateFrame("Frame", nil, frame)
  tabsBar:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -1)
  tabsBar:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, -1)
  tabsBar:SetHeight(22)
  frame.tabsBar = tabsBar
  frame.tabs = {}
  local previous
  for index = 1, MAX_GUIDE_TABS do
    local tab = textButton(tabsBar, "", function(self, mouseButton)
      if mouseButton == "RightButton" then UI:CloseGuideTab(self.tab) else UI:SelectGuideTab(self.tab) end
    end)
    tab:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    tab:SetScript("OnEnter", function(self)
      if self.tooltip then GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT"); GameTooltip:SetText(self.tooltip); GameTooltip:AddLine("Right-click to close this guide tab.", .7, .7, .7); GameTooltip:Show() end
    end)
    tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
    tab:SetHeight(20)
    tab:SetWidth(70)
    local decorFile = skin("TabsDecor", ZGV.SKINDIR .. "Default\\Starlight\\viewer8-tabs")
    if decorFile then
      local decorWidth = tonumber(skin("TabsDecorWidth", 8)) or 8
      local left = tab:CreateTexture(nil, "BACKGROUND")
      left:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, 0); left:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0); left:SetWidth(decorWidth); left:SetTexture(decorFile); left:SetTexCoord(0, .25, 0, 1)
      local right = tab:CreateTexture(nil, "BACKGROUND")
      right:SetPoint("TOPRIGHT", tab, "TOPRIGHT", 0, 0); right:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 0, 0); right:SetWidth(decorWidth); right:SetTexture(decorFile); right:SetTexCoord(.5, .75, 0, 1)
      local middle = tab:CreateTexture(nil, "BACKGROUND")
      middle:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0); middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0); middle:SetTexture(decorFile); middle:SetTexCoord(.25, .5, 0, 1)
      tab.decorLeft, tab.decorMiddle, tab.decorRight = left, middle, right
    end
    if previous then tab:SetPoint("LEFT", previous, "RIGHT", 2, 0) else tab:SetPoint("LEFT", tabsBar, "LEFT", 5, 0) end
    previous = tab
    frame.tabs[index] = tab
    tab:Hide()
  end

  local control = CreateFrame("Frame", nil, frame)
  control:SetPoint("TOPLEFT", tabsBar, "BOTTOMLEFT", 0, -1)
  control:SetPoint("TOPRIGHT", tabsBar, "BOTTOMRIGHT", 0, -1)
  control:SetHeight(25)
  frame.controlBar = control
  local prev = modernButton(control, "STEP_PREV", function() ZGV.Runtime:PreviousStep() end)
  prev:SetWidth(18); prev:SetHeight(18); prev:SetPoint("LEFT", control, "LEFT", 7, 0); prev.tooltip = "Previous step"; frame.actionPrevious = prev
  local stepNum = font(control, 12, 1, 1, 1)
  stepNum:SetPoint("LEFT", prev, "RIGHT", 1, 0); stepNum:SetWidth(58); stepNum:SetHeight(20); stepNum:SetJustifyH("CENTER"); frame.stepNum = stepNum
  local next = modernButton(control, "STEP_NEXT", function() ZGV.Runtime:NextStep(true) end)
  next:SetWidth(18); next:SetHeight(18); next:SetPoint("LEFT", stepNum, "RIGHT", 1, 0); next.tooltip = "Next step"; frame.actionNext = next
  local options = modernButton(control, "DOTS", function() UI:ToggleViewerActions() end)
  options:SetWidth(20); options:SetHeight(20); options:SetPoint("RIGHT", control, "RIGHT", -7, 0); options.tooltip = "Viewer actions"; frame.options = options
  local favorite = modernButton(control, "LOADGUIDE", function()
    if ZGV.Runtime.currentGuide then ZGV.Runtime:ToggleFavorite(ZGV.Runtime.currentGuide); UI:Refresh() end
  end)
  favorite:SetWidth(20); favorite:SetHeight(20); favorite:SetPoint("RIGHT", options, "LEFT", -4, 0); favorite.tooltip = "Favourite guide"; frame.favorite = favorite

  local content = CreateFrame("Frame", nil, frame)
  content:SetPoint("TOPLEFT", control, "BOTTOMLEFT", 7, -3)
  content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 12)
  frame.content = content
  local heading = font(content, 15, 1, 1, 1)
  heading:SetPoint("TOPLEFT", content, "TOPLEFT", 7, -3)
  heading:SetPoint("TOPRIGHT", content, "TOPRIGHT", -7, -3)
  heading:SetHeight(22)
  frame.heading = heading
  local subheading = font(content, 10, 0.7, 0.7, 0.7)
  subheading:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -1)
  subheading:SetPoint("TOPRIGHT", heading, "BOTTOMRIGHT", 0, -1)
  subheading:SetHeight(16)
  frame.subheading = subheading
  local progressBack = CreateFrame("Frame", nil, content)
  progressBack:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 5, 0)
  progressBack:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -5, 0)
  progressBack:SetHeight(10)
  frame.progressBack = progressBack
  local progress = CreateFrame("StatusBar", nil, progressBack)
  progress:SetPoint("TOPLEFT", progressBack, "TOPLEFT", 1, -1)
  progress:SetPoint("BOTTOMRIGHT", progressBack, "BOTTOMRIGHT", -1, 1)
  progress:SetMinMaxValues(0, 1)
  progress:SetValue(0)
  frame.progress = progress
  local progressText = font(progressBack, 9, 1, 1, 1)
  progressText:SetAllPoints(progressBack)
  progressText:SetJustifyH("CENTER")
  frame.progressText = progressText
  local waypoint = font(content, 10, 0.85, 0.85, 0.55)
  waypoint:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -2)
  waypoint:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, -2)
  waypoint:SetHeight(16)
  frame.waypoint = waypoint

  local search = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
  search:SetAutoFocus(false)
  search:SetHeight(22)
  search:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -48)
  search:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, -48)
  search:SetScript("OnTextChanged", function() if UI.mode == "browse" then UI.listPage = 1; UI:Refresh() end end)
  search:SetScript("OnEnterPressed", function(self)
    local matches = ZGV.Catalog:Find(self:GetText() or "")
    if #matches == 1 then ZGV.Runtime:SelectGuide(matches[1]); UI:SetMode("guide") end
    self:ClearFocus()
  end)
  frame.search = search

  frame.goalRows, frame.listRows, frame.settingRows = {}, {}, {}
  local function row(parent, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetPoint("LEFT", parent, "LEFT", 0, 0)
    button:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    button:SetHeight(height)
    button:EnableMouse(true)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 6, -5)
    icon:SetWidth(14); icon:SetHeight(14)
    button.icon = icon
    local label = font(button, 12, 1, 1, 1)
    label:SetPoint("TOPLEFT", button, "TOPLEFT", 24, -4)
    label:SetPoint("TOPRIGHT", button, "TOPRIGHT", -6, -4)
    label:SetHeight(height)
    label:SetJustifyV("TOP")
    if label.SetWordWrap then label:SetWordWrap(true) end
    button.label = label
    button:SetScript("OnEnter", function(self)
      if self.tooltip then GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetText(self.tooltip, 1, 1, 1, true); GameTooltip:Show() end
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return button
  end
  for index = 1, ROWS do
    local goal = row(content, 28)
    goal:SetScript("OnClick", function(self)
      if self.goalIndex then ZGV.Runtime:ActivateGoal(self.stepIndex or ZGV.Runtime.currentStep, self.goalIndex); UI:Refresh() end
    end)
    frame.goalRows[index] = goal
    local list = row(content, 28)
    list:SetScript("OnClick", function(self)
      if self.guide then ZGV.Runtime:SelectGuide(self.guide); UI:SetMode("guide") end
    end)
    frame.listRows[index] = list
    local setting = row(content, 28)
    setting:SetScript("OnClick", function(self) if self.settingAction then self.settingAction(); UI:Refresh() end end)
    frame.settingRows[index] = setting
  end

  self.frame = frame
  ZGV.Frame = frame
  self:ApplyModernSkin()
  frame:Hide()
  return frame
end

function UI:HideContent()
  for index = 1, ROWS do self.frame.goalRows[index]:Hide(); self.frame.listRows[index]:Hide(); self.frame.settingRows[index]:Hide() end
  self.frame.search:Hide()
  self.frame.progressBack:Hide(); self.frame.progressText:Hide(); self.frame.waypoint:Hide()
end

function UI:LayoutRows(rows, startY, heights)
  local previous
  for index, row in ipairs(rows or {}) do
    if row:IsShown() then
      row:ClearAllPoints()
      row:SetPoint("LEFT", self.frame.content, "LEFT", 0, 0)
      row:SetPoint("RIGHT", self.frame.content, "RIGHT", 0, 0)
      if previous then row:SetPoint("TOP", previous, "BOTTOM", 0, -2)
      else row:SetPoint("TOP", self.frame.content, "TOP", 0, startY or -2) end
      row:SetHeight(heights and heights[index] or 28)
      previous = row
    end
  end
end

function UI:SetGoalRowAppearance(row, state)
  local base = skin("StepBackdropColor", { .12, .12, .12, 1 })
  if state and state.complete then
    row:SetBackdropColor(.08, .30, .10, .72)
  elseif state and type(state.current) == "number" and type(state.required) == "number" and state.current > 0 then
    local ratio = math.max(0, math.min(1, state.current / math.max(1, state.required)))
    row:SetBackdropColor(.28 + ratio * .12, .19 + ratio * .08, .07, .78)
  else
    row:SetBackdropColor(unpack(base))
  end
end

function UI:RenderGuide()
  local frame, runtime = self.frame, ZGV.Runtime
  local guide = runtime.currentGuide
  self:HideContent()
  frame.heading:Hide(); frame.subheading:Hide()
  if not guide then
    frame.heading:Show(); frame.subheading:Show()
    frame.heading:SetText("No guide selected")
    frame.subheading:SetText("Open Guides to choose a guide.")
    frame.guideName:SetText("Zygor Guides")
    self:SetGuideFrameHeight(MIN_GUIDE_HEIGHT)
    return
  end
  frame.progressBack:Show(); frame.progressText:Show(); frame.waypoint:Show()
  self:EnsureGuideTab(guide)
  self:UpdateGuideTabs()
  local stepIndex, step = runtime.currentStep, guide.steps[runtime.currentStep]
  local state = step and runtime:GetStepState(step, stepIndex) or { required = 0, done = 0, goals = {} }
  frame.guideName:SetText(trim(guide.name or guide.title, 38))
  frame.heading:SetText(trim(guide.name or guide.title, 56))
  frame.subheading:SetText("Step " .. stepIndex .. " of " .. #guide.steps)
  frame.stepNum:SetText(stepIndex .. " / " .. #guide.steps)
  local ratio = state.required > 0 and state.done / state.required or 0
  frame.progress:SetValue(ratio)
  frame.progressText:SetText(state.done .. " / " .. state.required)
  local arrow = self.arrowState or (ZGV.Navigation and ZGV.Navigation:GetArrowState())
  local instructions=ZGV.Navigation and ZGV.Navigation:GetRouteInstructions() or {}
  local navigationText
  for _,instruction in ipairs(instructions) do
    if instruction.active then navigationText=instruction.text break end
  end
  frame.waypoint:SetText(arrow and arrow.visible and trim(navigationText or ("Go to "..(arrow.title or "waypoint")), math.max(42, math.floor((frame:GetWidth() or DEFAULT_VIEWER_WIDTH) / 6))) or "No waypoint set")
  local displayGoals=runtime:GetDisplayGoals(stepIndex)
  local rowLimit = math.max(1, math.min(ROWS, tonumber(ZGV.db.profile.viewer.rows) or 7))
  local previousVisible = math.max(1, math.min(rowLimit, tonumber(self.visibleGoalRows) or rowLimit))
  self.goalOffset = math.max(0, math.min(self.goalOffset or 0, math.max(0, #displayGoals - previousVisible)))
  local rowHeights = {}
  local usedHeight = 0
  local heightLimit = self:GetGuideHeightLimit()
  if not ZGV.db.profile.viewer.autoHeight then heightLimit = math.min(heightLimit, frame:GetHeight() or heightLimit) end
  local availableHeight = math.max(26, heightLimit - 139)
  for rowIndex = 1, rowLimit do
    local entry=displayGoals[rowIndex + self.goalOffset]
    if entry then
      local row = frame.goalRows[rowIndex]
      local goal,goalState=entry.goal,entry.state
      local complete = goalState and goalState.complete
      row.goalIndex,row.stepIndex = entry.goalIndex,entry.stepIndex
      local text = (entry.sticky and "• " or "")..goalText(goal, goalState)
      row.label:SetText(text)
      row.tooltip = goal.GetTooltip and goal:GetTooltip() or goal.text
      setStepIcon(row.icon, goal, complete)
      self:SetGoalRowAppearance(row, goalState)
      row:Show()
      local measured = self:MeasureGoalRow(text, (frame:GetWidth() or DEFAULT_VIEWER_WIDTH) - 38)
      if row.label.GetStringHeight then
        row.label:SetHeight(300)
        local exact = tonumber(row.label:GetStringHeight())
        if exact and exact > 0 then measured = math.max(26, math.min(74, math.ceil(exact) + 8)) end
      end
      local nextHeight = usedHeight + measured + (rowIndex > 1 and 2 or 0)
      if rowIndex > 1 and nextHeight > availableHeight then
        row:Hide()
        break
      end
      usedHeight = nextHeight
      row.label:SetHeight(measured - 8)
      rowHeights[rowIndex] = measured
    end
  end
  self.visibleGoalRows = math.max(1, #rowHeights)
  self:LayoutRows(frame.goalRows, -21, rowHeights)
  self:SetGuideFrameHeight(self:CalculateGuideHeight(rowHeights))
  ZGV.Compat.UI:SetEnabled(frame.actionPrevious,stepIndex > 1)
  ZGV.Compat.UI:SetEnabled(frame.actionNext,stepIndex < #guide.steps or guide.next ~= nil)
end

function UI:GetListResults()
  if self.mode == "browse" then return ZGV.Catalog:Find(self.frame.search:GetText() or "") end
  local results, seen = {}, {}
  if self.mode == "favorites" then
    for _, guide in ipairs(ZGV.Catalog.sorted) do if ZGV.db.profile.favorites[guide.id] then results[#results + 1] = guide end end
  else
    for _, entry in ipairs(ZGV.db.profile.history) do
      local guide = ZGV.Catalog:Get(type(entry) == "table" and entry.id or entry)
      if guide and not seen[guide.id] then results[#results + 1] = guide; seen[guide.id] = true end
    end
  end
  return results
end

function UI:RenderList()
  local frame = self.frame
  self:HideContent()
  frame.heading:Show(); frame.subheading:Show()
  if self.mode == "browse" then frame.search:Show() end
  local results = self:GetListResults()
  local pages = math.max(1, math.ceil(#results / ROWS))
  self.listPage = math.max(1, math.min(self.listPage or 1, pages))
  frame.guideName:SetText("Guide Browser")
  frame.heading:SetText(self.mode == "browse" and "Guide Browser" or self.mode == "history" and "Recent Guides" or "Favourite Guides")
  frame.subheading:SetText(#results .. " guides — mouse wheel changes page")
  local first = (self.listPage - 1) * ROWS + 1
  for rowIndex = 1, ROWS do
    local guide = results[first + rowIndex - 1]
    if guide then
      local row = frame.listRows[rowIndex]
      row.guide = guide
      row.label:SetText(trim((guide.path ~= "" and guide.path .. "  •  " or "") .. (guide.name or guide.title), 74))
      row.tooltip = guide.title or guide.name
      row.icon:SetTexCoord(.25, .5, 0, .5)
      row.icon:SetVertexColor(1, 1, 1, 1)
      row:Show()
    end
  end
  self:LayoutRows(frame.listRows, self.mode == "browse" and -76 or -48)
  self:SetTemporaryFrameHeight(500)
end

function UI:RenderSettings()
  local frame, profile = self.frame, ZGV.db.profile
  self:HideContent(); frame.guideName:SetText("Viewer Settings"); frame.heading:SetText("Viewer Settings"); frame.subheading:SetText("Settings are saved for this profile.")
  frame.heading:Show(); frame.subheading:Show()
  local settings = {
    { "Automatic quest acceptance", profile.automation, "accept" }, { "Automatic turn-ins", profile.automation, "turnin" },
    { "Automatic guide progress", profile.automation, "progress" }, { "Toast notifications", profile.notifications, "toast" }, { "Waypoint helper", profile.arrow, "shown" },
    { "Guide action bar", profile.actionbar, "enabled" }, { "Lock viewer position", profile.viewer, "locked" }, { "Glass skin", profile, "opacitytoggle" },
  }
  for index, setting in ipairs(settings) do
    local row = frame.settingRows[index]
    row.label:SetText(setting[1] .. ": " .. (setting[2][setting[3]] and "ON" or "OFF"))
    row.icon:SetTexCoord(0, 0.03125, 0, 1)
    row.settingAction = function()
      setting[2][setting[3]] = not setting[2][setting[3]]
      if setting[3] == "opacitytoggle" then
        local style = (profile.skinstyle or "starlight"):gsub("%-glass$", "")
        if profile.opacitytoggle then style = style .. "-glass" end
        ZGV:SetSkin(profile.skin, style)
      end
    end
    row:Show()
  end
  self:LayoutRows(frame.settingRows, -48)
  self:SetTemporaryFrameHeight(390)
end

function UI:RenderReport()
  local frame = self.frame
  self:HideContent(); frame.guideName:SetText("Diagnostics"); frame.heading:SetText("Diagnostics"); frame.subheading:SetText("Runtime and compatibility report")
  frame.heading:Show(); frame.subheading:Show()
  local index = 0
  for line in ZGV:GetDiagnosticsText():gmatch("[^\n]+") do
    index = index + 1; if index > ROWS then break end
    local row = frame.settingRows[index]
    row.label:SetText(trim(line, 82)); row.settingAction = nil; row:Show()
  end
  self:LayoutRows(frame.settingRows, -48)
  self:SetTemporaryFrameHeight(500)
end

function UI:ScrollGoals(delta)
  local step = ZGV.Runtime.currentGuide and ZGV.Runtime.currentGuide.steps[ZGV.Runtime.currentStep]
  if not step then return end
  local displayGoals=ZGV.Runtime:GetDisplayGoals(ZGV.Runtime.currentStep)
  local rowLimit = math.max(1, math.min(ROWS, tonumber(ZGV.db.profile.viewer.rows) or 7))
  local visibleRows = math.max(1, math.min(rowLimit, tonumber(self.visibleGoalRows) or rowLimit))
  self.goalOffset = math.max(0, math.min(math.max(0, #displayGoals - visibleRows), (self.goalOffset or 0) - (delta or 0)))
  self:RenderGuide()
end

function UI:Refresh()
  if not self.frame then return end
  if self.mode == "guide" then self:UpdateGuideTabs() end
  if self.mode == "guide" then self:RenderGuide()
  elseif self.mode == "browse" or self.mode == "history" or self.mode == "favorites" then self:RenderList()
  elseif self.mode == "settings" then self:RenderSettings() else self:RenderReport() end
end

function UI:SetMode(mode)
  self:CreateFrame(); self.mode = mode or "guide"; self.goalOffset = 0
  if self.viewerActions then self.viewerActions:Hide() end
  if self.mode == "browse" then self.listPage = 1 end
  if self.mode == "guide" and not ZGV.db.profile.viewer.autoHeight then
    self:SetTemporaryFrameHeight(ZGV.db.profile.viewer.height)
  end
  self.frame:Show(); ZGV.db.profile.viewer.shown = true; self:Refresh()
end

function UI:ShowViewer() self:SetMode("guide") end
function UI:ShowGuideMenu() self:SetMode("browse") end

-- The dots control in the modern viewer is a contextual action menu.  It is
-- deliberately separate from settings: settings belong in the Guide Menu so
-- guide browsing does not replace the active guide view.
function UI:CreateViewerActions()
  if self.viewerActions then return self.viewerActions end
  local actions = CreateFrame("Frame", "ZygorGuidesViewerActions", UIParent)
  actions:SetWidth(205); actions:SetHeight(190)
  actions:SetFrameStrata("DIALOG"); actions:SetToplevel(true); actions:EnableMouse(true)
  backdrop(actions, skin("WindowBackdrop", skin("Backdrop")), skin("WindowBackdropColor", { .07, .07, .07, 1 }), skin("WindowBackdropBorderColor", { .15, .15, .15, 1 }))
  local title = font(actions, 12, 1, 1, 1)
  title:SetPoint("TOPLEFT", actions, "TOPLEFT", 10, -8); title:SetText("Viewer Actions"); title:SetHeight(18)
  local close = modernButton(actions, "CLOSE", function() actions:Hide() end)
  close:SetPoint("TOPRIGHT", actions, "TOPRIGHT", -4, -4)
  close.tooltip="Close Viewer Actions"
  buildButtonSet(close, "CLOSE")
  actions.close=close
  local entries = {
    { "Open Guide Menu", function() actions:Hide(); UI:ShowGuideMenu() end },
    { "Settings", function() actions:Hide(); UI:ShowGuideMenu("SETTINGS") end },
    { "Dashboard Widgets", function() actions:Hide(); if ZGV.Widgets then ZGV.Widgets:ShowConfig() end end },
    { "Reset Current Guide", function() actions:Hide(); ZGV.Runtime:ResetCurrentGuide(); UI:Refresh() end },
    { "Diagnostics", function() actions:Hide(); UI:SetMode("report") end },
  }
  for index, entry in ipairs(entries) do
    local button = textButton(actions, entry[1], entry[2])
    button:SetPoint("TOPLEFT", actions, "TOPLEFT", 9, -30 - (index - 1) * 29)
    button:SetPoint("TOPRIGHT", actions, "TOPRIGHT", -9, -30 - (index - 1) * 29)
    local normal=skin("SmallButtonBackdropColor",{.10,.10,.10,1})
    local border=skin("SmallButtonBackdropBorderColor",{.16,.16,.16,1})
    backdrop(button,skin("SmallButtonBackdrop",skin("Backdrop")),normal,border)
    button:SetScript("OnEnter",function(self)
      self:SetBackdropColor(.28,.28,.28,.9)
    end)
    button:SetScript("OnLeave",function(self)
      self:SetBackdropColor(unpack(normal))
      self:SetBackdropBorderColor(unpack(border))
    end)
  end
  actions:Hide(); self.viewerActions = actions
  return actions
end

function UI:ToggleViewerActions()
  local actions = self:CreateViewerActions()
  if actions:IsShown() then actions:Hide(); return end
  local anchor = self.frame and self.frame.titleBar
  actions:ClearAllPoints()
  actions:SetPoint("TOPRIGHT", anchor or UIParent, "BOTTOMRIGHT", 0, -3)
  actions:Show()
end
function UI:ShowOptions() self:ShowGuideMenu("SETTINGS") end
function UI:ShowReport() self:SetMode("report") end
function UI:Toggle() if self:CreateFrame():IsShown() then self.frame:Hide() else self:ShowViewer() end end

-- Replaces the legacy book icon with the circular, stateful icon used by the
-- current Classic viewer.  The implementation deliberately stays within the
-- 3.3.5 frame API instead of requiring the modern XML mixin/template system.
function UI:CreateMinimapButton()
  if self.minimapButton or not Minimap then return self.minimapButton end
  local options = ZGV.db.profile.minimap
  local button = CreateFrame("Button", "ZygorGuidesViewerMapIcon", Minimap)
  button:SetWidth(32); button:SetHeight(32); button:SetFrameStrata("MEDIUM"); button:SetClampedToScreen(true)
  button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", options.x or -3, options.y or -2)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp"); button:RegisterForDrag("LeftButton"); button:SetMovable(true)
  button:SetNormalTexture("Interface\\Buttons\\WHITE8X8")
  button:SetPushedTexture("Interface\\Buttons\\WHITE8X8")
  button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
  local normal, pushed, highlight = button:GetNormalTexture(), button:GetPushedTexture(), button:GetHighlightTexture()
  normal:SetWidth(21); normal:SetHeight(21); normal:SetPoint("CENTER", button, "CENTER", 1, 0)
  pushed:SetWidth(21); pushed:SetHeight(21); pushed:SetPoint("CENTER", button, "CENTER", 1, 0)
  highlight:SetWidth(21); highlight:SetHeight(21); highlight:SetPoint("CENTER", button, "CENTER", 1, 0); highlight:SetBlendMode("ADD")
  local spinner = button:CreateTexture(nil, "OVERLAY")
  spinner:SetAllPoints(button); spinner:SetTexture(ZGV.SKINDIR .. "loading"); spinner:Hide(); button.spinner = spinner
  button:SetScript("OnClick", function()
    GameTooltip:Hide()
    UI:Toggle()
  end)
  button:SetScript("OnDragStart", function(self)
    self.dragging = true; self:StartMoving()
  end)
  button:SetScript("OnDragStop", function(self)
    self.dragging = nil; self:StopMovingOrSizing()
    local x, y = self:GetCenter(); local minX, minY = Minimap:GetCenter()
    if x and minX then
      options.x = math.floor(x - minX + .5)
      options.y = math.floor(y - minY + .5)
      self:ClearAllPoints(); self:SetPoint("CENTER", Minimap, "CENTER", options.x, options.y)
    end
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT"); GameTooltip:SetText("Zygor Guides")
    GameTooltip:AddLine("Click to show or hide the viewer.", .8, .8, .8); GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  self.minimapButton = button
  self:ApplyMinimapSkin()
  return button
end

function UI:ApplyMinimapSkin()
  local button = self.minimapButton
  if not button then return end
  local buttonSet = ZGV.ButtonSets and ZGV.ButtonSets.Minimap
  local icon = buttonSet and buttonSet.NORMAL
  if icon and icon.AssignToButton then
    icon:AssignToButton(button)
  elseif ZGV.F and ZGV.F.AssignButtonTexture then
    -- This is also the exact fallback used by the Classic reference viewer.
    ZGV.F.AssignButtonTexture(button, ZGV.SKINDIR .. "minimap-icon", 1, 2)
  end
end

function UI:OnStartup()
  self:CreateFrame(); self:CreateMinimapButton(); self:CreateArrow(); self:UpdateArrow(ZGV.Navigation and ZGV.Navigation:GetArrowState())
  if ZGV.db.profile.viewer.shown ~= false then self:ShowViewer() end
end

ZGV:AddMessageHandler("SKIN_UPDATED", function() UI:ApplyModernSkin(); UI:Refresh() end)
