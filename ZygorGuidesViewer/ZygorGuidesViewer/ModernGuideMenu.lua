-- 3.3.5a recreation of the modern three-pane Guide Menu.  It uses the
-- current catalog/runtime but follows the modern menu's separate browser,
-- category navigation, search, details, favourite, and load interactions.
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
local UI = ZGV.UI
if type(UI) ~= "table" then return end

-- Match the modern guide menu's documented 825 x 630 three-column geometry:
-- a 222px category column, 382px result list and 219px details column.  The
-- prior 164/370/remainder split made categories cramped and the details pane
-- disproportionally wide compared with the reference viewer.
local RESULTS_PER_PAGE = 20
local CATEGORY_ROWS = 14
local BASE_CATEGORY_COUNT = 3
local SECTION_LABELS = {
  HOME = "Home", FEATURED = "Featured", CURRENT = "Current Guide", SUGGESTED = "Suggested",
  RECENT = "Recent Guides", FAVOURITES = "Favourites", ALL = "All Guides", SETTINGS = "Options",
}
local Menu = { section = "HOME", settingsCategory = "display", selected = nil, rows = {}, categories = {}, categoryPool = {}, resultOffset = 0, categoryOffset = 0 }
ZGV.GuideMenu = Menu

local function skin(name, fallback)
  local value = ZGV:GetSkinData(name)
  return value ~= nil and value or fallback
end

local function makeText(parent, size, r, g, b)
  local text = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  local path, _, flags = GameFontNormal:GetFont()
  text:SetFont(path, size, flags)
  text:SetJustifyH("LEFT"); text:SetJustifyV("MIDDLE")
  text:SetTextColor(r or 1, g or 1, b or 1, 1)
  return text
end

local function panel(frame, data, color, border)
  if data then frame:SetBackdrop(data) end
  if color then frame:SetBackdropColor(unpack(color)) end
  if border then frame:SetBackdropBorderColor(unpack(border)) end
end

local function trim(text, size)
  text = tostring(text or "")
  return #text > size and text:sub(1, size - 3) .. "..." or text
end

function Menu:SetRowAppearance(row, selected, hovered)
  if not row then return end
  local color = skin("SmallButtonBackdropColor", { .10, .10, .10, 1 })
  local border = skin("SmallButtonBackdropBorderColor", { .16, .16, .16, 1 })
  if selected then
    local accent = skin("GuideMenuGuideButtonDecorColor", { .95, .38, .10, 1 })
    row:SetBackdropColor(accent[1] or .95, accent[2] or .38, accent[3] or .10, .28)
    row:SetBackdropBorderColor(accent[1] or .95, accent[2] or .38, accent[3] or .10, .7)
  elseif hovered then
    row:SetBackdropColor(.28, .28, .28, .9)
    row:SetBackdropBorderColor(unpack(border))
  else
    row:SetBackdropColor(unpack(color))
    row:SetBackdropBorderColor(unpack(border))
  end
end

function Menu:SetSidebarAppearance(button, selected)
  if not button then return end
  local color = skin("SmallButtonBackdropColor", { .10, .10, .10, 1 })
  local border = skin("SmallButtonBackdropBorderColor", { .16, .16, .16, 1 })
  if selected then
    local accent = skin("GuideMenuGuideButtonDecorColor", { .95, .38, .10, 1 })
    button:SetBackdropColor(accent[1] or .95, accent[2] or .38, accent[3] or .10, .34)
    button:SetBackdropBorderColor(accent[1] or .95, accent[2] or .38, accent[3] or .10, .75)
  else
    button:SetBackdropColor(unpack(color))
    button:SetBackdropBorderColor(unpack(border))
  end
end

function Menu:SetHeaderTabAppearance(button, selected)
  if not button then return end
  local text = button.GetFontString and button:GetFontString()
  if text then text:SetTextColor(selected and 1 or .72, selected and 1 or .72, selected and 1 or .72, 1) end
  if button.decor then
    if selected then button.decor:Show() else button.decor:Hide() end
  end
end

function Menu:ApplySkin()
  if not self.frame then return end
  panel(self.frame, skin("GuideMenuBackdrop", skin("WindowBackdrop")), skin("GuideMenuBackdropColor", { .07, .07, .07, 1 }), skin("GuideMenuBackdropBorderColor", { .07, .07, .07, 1 }))
  panel(self.header, skin("Backdrop"), skin("SystemBarBackdropColor", { .15, .15, .15, 1 }), skin("SystemBarBackdropBorderColor", { 0, 0, 0, 0 }))
  panel(self.sidebar, skin("GuideMenuMenuBackground", skin("Backdrop")), skin("GuideMenuMenuBackgroundColor", { .11, .11, .11, 1 }), skin("GuideMenuMenuBackdropBorderColor", { .11, .11, .11, 1 }))
  panel(self.listPane, skin("GuideMenuContentBackdrop", skin("Backdrop")), skin("GuideMenuContentBackdropColor", { .12, .12, .12, 1 }), skin("GuideMenuContentBackdropBorderColor", { .12, .12, .12, 1 }))
  panel(self.detailPane, skin("GuideMenuDetailsBackdrop", skin("Backdrop")), skin("GuideMenuDetailsBackdropColor", { .16, .16, .16, 1 }), skin("GuideMenuDetailsBackdropBorderColor", { .16, .16, .16, 1 }))
  self.logo:SetTexture(skin("TitleLogo", ZGV.SKINDIR .. "zygorlogo"))
  local itemBackdrop = skin("SmallButtonBackdrop", skin("GuideMenuContentBackdrop", skin("Backdrop")))
  local itemColor = skin("SmallButtonBackdropColor", { .12, .12, .12, 1 })
  local itemBorder = skin("SmallButtonBackdropBorderColor", { .16, .16, .16, 1 })
  for _, item in ipairs(self.rows or {}) do
    panel(item, itemBackdrop, itemColor, itemBorder)
    item.icon:SetTexture(skin("GuideMenuSmallIcons", ZGV.SKINDIR .. "guideicons-small"))
    item.star:SetTexture(skin("GuideMenuSmallIcons", ZGV.SKINDIR .. "guideicons-small"))
  end
  for _, button in ipairs(self.categories or {}) do
    panel(button, itemBackdrop, itemColor, itemBorder)
  end
  for _, button in ipairs(self.headerTabs or {}) do
    if button.decor then button.decor:SetTexture(ZGV.SKINDIR .. "white") end
    self:SetHeaderTabAppearance(button, button.section == self.section)
  end
end

local function row(parent, y)
  local button = CreateFrame("Button", nil, parent)
  button:SetPoint("TOPLEFT", parent, "TOPLEFT", 7, y)
  button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -7, y)
  button:SetHeight(25)
  button:SetBackdrop({ bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white", edgeSize = 1 })
  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetPoint("LEFT", button, "LEFT", 5, 0); icon:SetWidth(15); icon:SetHeight(15)
  icon:SetTexture(skin("GuideMenuSmallIcons", ZGV.SKINDIR .. "guideicons-small"))
  button.icon = icon
  local name = makeText(button, 11, 1, 1, 1)
  name:SetPoint("LEFT", icon, "RIGHT", 5, 0); name:SetPoint("RIGHT", button, "RIGHT", -22, 0); name:SetHeight(25)
  button.name = name
  local value = makeText(button, 11, .95, .72, .25)
  value:SetPoint("RIGHT", button, "RIGHT", -8, 0); value:SetWidth(132); value:SetHeight(25); value:SetJustifyH("RIGHT"); value:Hide()
  button.value = value
  local star = button:CreateTexture(nil, "ARTWORK")
  star:SetPoint("RIGHT", button, "RIGHT", -5, 0); star:SetWidth(14); star:SetHeight(14)
  -- STAR is column one, row two of the 4 x 2 GuideIconsSmall atlas.
  star:SetTexture(skin("GuideMenuSmallIcons", ZGV.SKINDIR .. "guideicons-small")); star:SetTexCoord(0, .25, .5, 1)
  button.star = star
  button:SetScript("OnEnter", function(self)
    if self.guide then
      Menu:SetRowAppearance(self, self.guide == Menu.selected, true)
    elseif self.option then
      Menu:SetRowAppearance(self, false, true)
      if GameTooltip and self.tooltip and self.tooltip ~= "" then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.option.label or "Option", 1, 1, 1)
        GameTooltip:AddLine(self.tooltip, .85, .85, .85, true)
        GameTooltip:Show()
      end
    end
  end)
  button:SetScript("OnLeave", function(self)
    -- `nil == nil` was marking every setting row as the selected guide once
    -- the cursor left it, leaving the orange hover state stuck on screen.
    if self.guide or self.option then Menu:SetRowAppearance(self, self.guide and self.guide == Menu.selected or false, false) end
    if GameTooltip then GameTooltip:Hide() end
  end)
  return button
end

function Menu:Create()
  if self.frame then return self.frame end
  -- Catalog and skin callbacks can be delivered while the viewer is starting.
  -- Do not let one refresh a partially constructed menu.
  self._creating = true
  local frame = CreateFrame("Frame", "ZygorGuidesViewerGuideMenu", UIParent)
  frame:SetWidth(825); frame:SetHeight(630); frame:SetPoint("CENTER", UIParent)
  frame:SetFrameStrata("DIALOG"); frame:SetToplevel(true); frame:SetClampedToScreen(true); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  frame:Hide(); self.frame = frame

  local header = CreateFrame("Frame", nil, frame)
  header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0); header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0); header:SetHeight(40)
  self.header = header
  local logo = header:CreateTexture(nil, "ARTWORK"); logo:SetPoint("LEFT", header, "LEFT", 12, 0); logo:SetWidth(100); logo:SetHeight(25); self.logo = logo
  local title = makeText(header, 15, 1, 1, 1); title:SetPoint("LEFT", logo, "RIGHT", 10, 0); title:SetText("Guide Menu"); title:SetHeight(30); self.title = title
  local close = CreateFrame("Button", nil, header, "UIPanelCloseButton"); close:SetPoint("RIGHT", header, "RIGHT", 0, 0); close:SetScript("OnClick", function() frame:Hide() end)
  self.headerTabs = {}
  local previousTab = title
  for _, entry in ipairs({ { "HOME", "Home", 46 }, { "FEATURED", "Featured", 58 }, { "CURRENT", "Current", 56 }, { "RECENT", "Recent", 54 }, { "SETTINGS", "Options", 58 } }) do
    local tab = CreateFrame("Button", nil, header)
    tab:SetWidth(entry[3]); tab:SetHeight(24); tab:SetPoint("LEFT", previousTab, "RIGHT", 14, 0)
    tab:SetNormalFontObject(GameFontHighlightSmall); tab:SetHighlightFontObject(GameFontHighlightSmall); tab:SetText(entry[2])
    local tabText = tab.GetFontString and tab:GetFontString()
    if tabText then tabText:SetJustifyH("CENTER") end
    local decor = tab:CreateTexture(nil, "ARTWORK")
    decor:SetPoint("TOPLEFT", tab, "BOTTOMLEFT", 2, 1); decor:SetPoint("TOPRIGHT", tab, "BOTTOMRIGHT", -2, 1); decor:SetHeight(2)
    tab.decor = decor; tab.section = entry[1]
    tab:SetScript("OnClick", function(self) Menu.section = self.section; Menu.selected = nil; Menu.resultOffset = 0; Menu:Refresh() end)
    self.headerTabs[#self.headerTabs + 1] = tab
    previousTab = tab
  end

  local sidebar = CreateFrame("Frame", nil, frame)
  sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0); sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0); sidebar:SetWidth(222); self.sidebar = sidebar
  local listPane = CreateFrame("Frame", nil, frame)
  listPane:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", -1, 0); listPane:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMRIGHT", -1, 0); listPane:SetWidth(382); self.listPane = listPane
  local detailPane = CreateFrame("Frame", nil, frame)
  detailPane:SetPoint("TOPLEFT", listPane, "TOPRIGHT", 0, 0); detailPane:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0); self.detailPane = detailPane
  local detailImage = detailPane:CreateTexture(nil, "ARTWORK")
  detailImage:SetPoint("TOPLEFT", detailPane, "TOPLEFT", 1, -1); detailImage:SetPoint("TOPRIGHT", detailPane, "TOPRIGHT", -1, -1); detailImage:SetHeight(139)
  detailImage:SetTexture(ZGV.SKINDIR .. "menu_noimage"); detailImage:SetTexCoord(0, 220 / 256, 0, 139 / 256); self.detailImage = detailImage
  -- The reference places the mascot in ARTWORK.  BACKGROUND can end up below
  -- a textured backdrop in 3.3.5a, making it look missing or washed out.
  local detailMascot = detailPane:CreateTexture(nil, "ARTWORK")
  detailMascot:SetPoint("BOTTOMLEFT", detailPane, "BOTTOMLEFT", 1, 1); detailMascot:SetPoint("BOTTOMRIGHT", detailPane, "BOTTOMRIGHT", -1, 1); detailMascot:SetHeight(190)
  detailMascot:SetTexture(ZGV.SKINDIR .. "menu_mascot"); detailMascot:SetTexCoord(0, 220 / 256, 0, 289 / 512); self.detailMascot = detailMascot

  local search = CreateFrame("EditBox", nil, sidebar, "InputBoxTemplate")
  search:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 16, -10); search:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -16, -10); search:SetHeight(22); search:SetAutoFocus(false)
  search:SetScript("OnTextChanged", function()
    if Menu.section == "SEARCH" or search:GetText() ~= "" then
      Menu.section = "SEARCH"; Menu.selected = nil; Menu.resultOffset = 0; Menu:Refresh()
    end
  end)
  search:SetScript("OnEscapePressed", function(self)
    self:SetText(""); self:ClearFocus(); Menu.section = "HOME"; Menu.resultOffset = 0; Menu:Refresh()
  end); self.search = search
  local listTitle = makeText(listPane, 13, 1, 1, 1); listTitle:SetPoint("TOPLEFT", listPane, "TOPLEFT", 10, -10); listTitle:SetPoint("TOPRIGHT", listPane, "TOPRIGHT", -62, -10); listTitle:SetHeight(18); self.listTitle = listTitle
  listPane:EnableMouseWheel(true)
  listPane:SetScript("OnMouseWheel", function(_, delta) Menu:ScrollResults(-delta) end)
  for index = 1, RESULTS_PER_PAGE do
    local item = row(listPane, -34 - (index - 1) * 25)
    item:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    item:SetScript("OnClick", function(self, mouseButton)
      if self.option and ZGV.Options then
        local reverse = mouseButton == "RightButton" or (type(IsShiftKeyDown) == "function" and IsShiftKeyDown())
        ZGV.Options:Activate(self.option, reverse)
        Menu:Refresh()
      elseif self.guide and self.guide.isFolder then Menu:OpenFolder(self.guide)
      elseif self.guide then Menu:Select(self.guide) end
    end)
    self.rows[index] = item
  end
  local function listScroll(label, offset)
    local button = CreateFrame("Button", nil, listPane, "UIPanelButtonTemplate")
    button:SetPoint("TOPRIGHT", listPane, "TOPRIGHT", offset, -6); button:SetWidth(21); button:SetHeight(21); button:SetText(label)
    return button
  end
  self.listUp = listScroll("^", -34); self.listUp:SetScript("OnClick", function() Menu:ScrollResults(-RESULTS_PER_PAGE) end)
  self.listDown = listScroll("v", -9); self.listDown:SetScript("OnClick", function() Menu:ScrollResults(RESULTS_PER_PAGE) end)

  local detailTitle = makeText(detailPane, 15, 1, 1, 1); detailTitle:SetPoint("TOPLEFT", detailImage, "BOTTOMLEFT", 13, -10); detailTitle:SetPoint("TOPRIGHT", detailPane, "TOPRIGHT", -14, -10); detailTitle:SetHeight(24); self.detailTitle = detailTitle
  local detailPath = makeText(detailPane, 10, .75, .75, .75); detailPath:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -1); detailPath:SetPoint("TOPRIGHT", detailTitle, "BOTTOMRIGHT", 0, -1); detailPath:SetHeight(30); detailPath:SetJustifyV("TOP"); self.detailPath = detailPath
  local completion = makeText(detailPane, 11, .9, .9, .6); completion:SetPoint("TOPLEFT", detailPath, "BOTTOMLEFT", 0, -12); completion:SetHeight(18); self.completion = completion
  local description = makeText(detailPane, 11, .88, .88, .88); description:SetPoint("TOPLEFT", completion, "BOTTOMLEFT", 0, -8); description:SetPoint("TOPRIGHT", detailPane, "TOPRIGHT", -14, -8); description:SetHeight(130); description:SetJustifyV("TOP"); self.description = description
  local function action(text, y, callback)
    local button = CreateFrame("Button", nil, detailPane, "UIPanelButtonTemplate")
    button:SetPoint("BOTTOMLEFT", detailPane, "BOTTOMLEFT", 14, y); button:SetWidth(130); button:SetHeight(25); button:SetText(text); button:SetScript("OnClick", callback); return button
  end
  self.loadButton = action("Load Guide", 18, function() Menu:LoadSelected() end)
  self.favoriteButton = action("Favourite", 48, function() Menu:ToggleFavourite() end)

  self:AddSidebarButton("ALL", "All Guides", 42)
  self:AddSidebarButton("SUGGESTED", "Suggested", 72)
  self:AddSidebarButton("FAVOURITES", "Favourites", 102)
  self.categoryStart = 142
  sidebar:EnableMouseWheel(true)
  sidebar:SetScript("OnMouseWheel", function(_, delta) Menu:ScrollCategories(-delta) end)
  local function categoryScroll(label, offset)
    local button = CreateFrame("Button", nil, sidebar, "UIPanelButtonTemplate")
    button:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", offset, 8); button:SetWidth(23); button:SetHeight(21); button:SetText(label)
    return button
  end
  self.categoryUp = categoryScroll("^", -35); self.categoryUp:SetScript("OnClick", function() Menu:ScrollCategories(-CATEGORY_ROWS) end)
  self.categoryDown = categoryScroll("v", -9); self.categoryDown:SetScript("OnClick", function() Menu:ScrollCategories(CATEGORY_ROWS) end)
  self:ApplySkin()
  self._creating = nil
  return frame
end

function Menu:AddSidebarButton(section, label, y)
  local button = table.remove(self.categoryPool)
  if not button then button = CreateFrame("Button", nil, self.sidebar) end
  button:ClearAllPoints()
  button:SetPoint("TOPLEFT", self.sidebar, "TOPLEFT", 9, -y); button:SetPoint("TOPRIGHT", self.sidebar, "TOPRIGHT", -9, -y); button:SetHeight(25)
  panel(button, skin("SmallButtonBackdrop", skin("GuideMenuMenuBackground", skin("Backdrop"))), skin("SmallButtonBackdropColor", { .10, .10, .10, 1 }), skin("SmallButtonBackdropBorderColor", { .16, .16, .16, 1 }))
  button:SetNormalFontObject(GameFontHighlightSmall); button:SetHighlightFontObject(GameFontHighlightSmall); button:SetText(label)
  -- Buttons do not expose FontString alignment methods in the 3.3.5 client.
  -- Apply the alignment to their label instead, as the modern UI does.
  local text = button.GetFontString and button:GetFontString()
  if text then text:SetJustifyH("LEFT") end
  button:SetScript("OnClick", function()
    local optionGroup = tostring(section):match("^OPTION:(.+)$")
    if optionGroup then
      Menu.section = "SETTINGS"
      Menu.settingsCategory = optionGroup
    else
      Menu.section = section
    end
    Menu.selected = nil; Menu.resultOffset = 0; Menu:Refresh()
  end)
  button.section = section; self.categories[#self.categories + 1] = button
  return button
end

function Menu:BuildCategoryButtons()
  if not self.frame or self._creating or not self.categoryStart then return end
  while #self.categories > BASE_CATEGORY_COUNT do
    local button = table.remove(self.categories)
    button:Hide()
    self.categoryPool[#self.categoryPool + 1] = button
  end

  if self.section == "SETTINGS" then
    for index = 1, BASE_CATEGORY_COUNT do if self.categories[index] then self.categories[index]:Hide() end end
    self.categoryNames = {}
    self.categoryOffset = 0
    local groups = ZGV.Options and ZGV.Options:GetGroups() or {}
    for index, group in ipairs(groups) do
      local button = self:AddSidebarButton("OPTION:" .. group.id, group.label, 12 + (index - 1) * 28)
      button:Show()
    end
    if self.categoryUp then self.categoryUp:Hide() end
    if self.categoryDown then self.categoryDown:Hide() end
    return
  end

  for index = 1, BASE_CATEGORY_COUNT do if self.categories[index] then self.categories[index]:Show() end end
  if self.categoryUp then self.categoryUp:Show() end
  if self.categoryDown then self.categoryDown:Show() end
  local known, ordered = {}, {}
  for _, guide in ipairs(ZGV.Catalog.sorted or {}) do
    local category = guide.menuCategory or guide.category or "Other"
    if not known[category] then known[category] = true; ordered[#ordered + 1] = category end
  end
  -- Catalog.sorted already contains the authored Classic category order.
  -- Sorting this list alphabetically recreated the exact menu disorder the
  -- hierarchy sorter had just corrected.
  self.categoryNames = ordered
  self.categoryOffset = math.max(0, math.min(self.categoryOffset or 0, math.max(0, #ordered - CATEGORY_ROWS)))
  for index = 1, math.min(CATEGORY_ROWS, #ordered - self.categoryOffset) do
    local category = ordered[index + self.categoryOffset]
    local button = self:AddSidebarButton("CATEGORY:" .. category, category, self.categoryStart + (index - 1) * 25)
    button:Show()
  end
  if self.categoryUp then ZGV.Compat.UI:SetEnabled(self.categoryUp,self.categoryOffset > 0) end
  if self.categoryDown then ZGV.Compat.UI:SetEnabled(self.categoryDown,self.categoryOffset < math.max(0, #ordered - CATEGORY_ROWS)) end
end

function Menu:SetPaneMode(settings)
  if settings then
    self.search:Hide()
    self.listPane:SetWidth(603)
    self.detailPane:Hide()
    self.listPane:EnableMouseWheel(false)
  else
    self.search:Show()
    self.listPane:SetWidth(382)
    self.detailPane:Show()
    self.listPane:EnableMouseWheel(true)
  end
end

function Menu:ScrollResults(amount)
  local count = #(self:GetResults() or {})
  self.resultOffset = math.max(0, math.min(math.max(0, count - RESULTS_PER_PAGE), (self.resultOffset or 0) + (amount or 0)))
  self:Refresh()
end

function Menu:ScrollCategories(amount)
  local count = #(self.categoryNames or {})
  self.categoryOffset = math.max(0, math.min(math.max(0, count - CATEGORY_ROWS), (self.categoryOffset or 0) + (amount or 0)))
  self:Refresh()
end

local function folderEntry(path, parent)
  local name = path:match("([^\\]+)$") or path
  return {
    id = "folder:" .. path:lower(), title = path, name = parent and ("..  " .. name) or name,
    path = path:match("^(.*)\\[^\\]+$") or "", category = path:match("^([^\\]+)") or path,
    isFolder = true, isParent = parent and true or false,
  }
end

function Menu:GetFolderResults(path, includeParent)
  path = tostring(path or "")
  local results, folders = {}, {}
  if includeParent and path ~= "" then
    local parent = path:match("^(.*)\\[^\\]+$") or ""
    results[#results + 1] = folderEntry(parent ~= "" and parent or "All Guides", true)
    results[#results].openPath = parent
  end
  local prefix = path ~= "" and (path .. "\\") or ""
  for _, guide in ipairs(ZGV.Catalog.sorted or {}) do
    local title = tostring(guide.menuTitle or guide.title or "")
    if prefix == "" or title:sub(1, #prefix) == prefix then
      local remainder = prefix == "" and title or title:sub(#prefix + 1)
      local child = remainder:match("^([^\\]+)\\")
      if child then
        local fullPath = prefix .. child
        if not folders[fullPath] then
          folders[fullPath] = true
          local entry = folderEntry(fullPath)
          entry.openPath = fullPath
          results[#results + 1] = entry
        end
      elseif remainder ~= "" then
        results[#results + 1] = guide
      end
    end
  end
  return results
end

function Menu:OpenFolder(folder)
  local path = type(folder) == "table" and folder.openPath or tostring(folder or "")
  if path == "" then
    self.section = "ALL"
  elseif not path:find("\\", 1, true) then
    self.section = "CATEGORY:" .. path
  else
    self.section = "FOLDER:" .. path
  end
  self.selected = nil
  self.resultOffset = 0
  self:Refresh()
end

function Menu:GetResults()
  local all = ZGV.Catalog.sorted
  local results = {}
  if self.section == "SETTINGS" then
    return results
  elseif self.section == "ALL" then
    return self:GetFolderResults("", false)
  elseif self.section:match("^CATEGORY:") then
    return self:GetFolderResults(self.section:match("^CATEGORY:(.+)$"), false)
  elseif self.section:match("^FOLDER:") then
    return self:GetFolderResults(self.section:match("^FOLDER:(.+)$"), true)
  elseif self.section == "RECENT" then
    local seen = {}
    for _, entry in ipairs(ZGV.db.profile.history) do
      local guide = ZGV.Catalog:Get(type(entry) == "table" and entry.id or entry)
      if guide and not seen[guide.id] then results[#results + 1] = guide; seen[guide.id] = true end
    end
  elseif self.section == "FAVOURITES" then
    for _, guide in ipairs(all) do if ZGV.db.profile.favorites[guide.id] then results[#results + 1] = guide end end
  elseif self.section == "CURRENT" then
    local current = ZGV.Runtime.currentGuide
    if current then results[#results + 1] = current end
  elseif self.section == "FEATURED" or self.section == "SUGGESTED" then
    local suggested = ZGV.Runtime:ChooseSuggestedGuide()
    if suggested then results[#results + 1] = suggested end
    for _, guide in ipairs(all) do
      if guide ~= suggested and (guide.menuCategory or guide.category or ""):lower():find("level", 1, true) then results[#results + 1] = guide end
    end
  elseif self.section == "HOME" then
    local current = ZGV.Runtime.currentGuide
    if current then results[#results + 1] = current end
    local suggested = ZGV.Runtime:ChooseSuggestedGuide()
    if suggested and suggested ~= current then results[#results + 1] = suggested end
  else
    local query = self.search:GetText():lower()
    for _, guide in ipairs(all) do
      local searchable = table.concat({ guide.title or "", guide.name or "", guide.path or "", guide.category or "", guide.menuTitle or "", guide.menuName or "", guide.menuPath or "", guide.menuCategory or "" }, " "):lower()
      if query == "" or searchable:find(query, 1, true) then results[#results + 1] = guide end
    end
  end
  return results
end

function Menu:Select(guide)
  self.selected = guide
  self:RenderDetails()
  for _, rowFrame in ipairs(self.rows) do self:SetRowAppearance(rowFrame, rowFrame.guide == guide, false) end
end

function Menu:RenderDetails()
  local guide = self.selected
  if not guide then
    self.detailImage:SetTexture(ZGV.SKINDIR .. "menu_noguide"); self.detailImage:SetTexCoord(0, 220 / 256, 0, 139 / 256); self.detailMascot:Show()
    self.loadButton:Show(); self.favoriteButton:Show()
    self.detailTitle:SetText("Select a guide")
    self.detailPath:SetText("Browse installed guide categories or search by title, zone, dungeon, profession, or quest.")
    self.completion:SetText(""); self.description:SetText(""); self.loadButton:SetText("Load Guide"); self.loadButton:Disable(); self.favoriteButton:Disable(); return
  end
  if guide.isFolder then
    self.detailImage:SetTexture(ZGV.SKINDIR .. "menu_noguide"); self.detailImage:SetTexCoord(0, 220 / 256, 0, 139 / 256); self.detailMascot:Show()
    self.detailTitle:SetText(guide.name or "Guide folder")
    self.detailPath:SetText(guide.openPath or guide.title or "")
    self.completion:SetText(guide.isParent and "Return to the previous folder" or "Guide category")
    self.description:SetText("Open this folder to browse its guides in the authored Classic leveling and content order.")
    self.loadButton:SetText("Open Folder"); self.loadButton:Enable(); self.loadButton:Show()
    self.favoriteButton:Hide()
    return
  end
  if type(guide.image) == "string" and guide.image ~= "" then
    self.detailImage:SetTexture(guide.image); self.detailImage:SetTexCoord(0, 1, 0, 1)
  else
    self.detailImage:SetTexture(ZGV.SKINDIR .. "menu_noimage"); self.detailImage:SetTexCoord(0, 220 / 256, 0, 139 / 256)
  end
  self.detailMascot:Show()
  self.loadButton:Show(); self.favoriteButton:Show()
  self.loadButton:SetText("Load Guide")
  self.detailTitle:SetText(guide.menuName or guide.name or guide.title)
  self.detailPath:SetText(guide.menuPath or guide.path or "")
  local parsed = guide._modernModel and guide or (ZGV.Runtime.currentGuide == guide and guide)
  local completion = parsed and parsed.GetCompletionText and parsed:GetCompletionText() or "Not yet loaded"
  self.completion:SetText("Progress: " .. completion)
  self.description:SetText("Source: " .. tostring(guide.source or "bundled") .. "\nCategory: " .. tostring(guide.menuCategory or guide.category or "") .. "\n\nLoad this guide to view its steps and navigation objectives.")
  self.loadButton:Enable(); self.favoriteButton:Enable()
  self.favoriteButton:SetText(ZGV.db.profile.favorites[guide.id] and "Unfavourite" or "Favourite")
end

function Menu:RenderSettings()
  if not ZGV.Options then return end
  ZGV.Options:EnsureDefaults()
  local group = ZGV.Options:GetGroup(self.settingsCategory) or ZGV.Options:GetGroups()[1]
  if not group then return end
  self.settingsCategory = group.id
  self.listTitle:SetText(group.label .. (group.description and "  |cffaaaaaa" .. group.description .. "|r" or ""))
  self.selected = nil
  for _, button in ipairs(self.categories) do
    local selected = button.section == "OPTION:" .. group.id
    local text = button.GetFontString and button:GetFontString()
    if text then text:SetTextColor(selected and 1 or .72, selected and 1 or .72, selected and 1 or .72, 1) end
    self:SetSidebarAppearance(button, selected)
  end
  for _, button in ipairs(self.headerTabs or {}) do self:SetHeaderTabAppearance(button, button.section == self.section) end
  for index, rowFrame in ipairs(self.rows) do
    local option = group.options[index]
    rowFrame.guide = nil; rowFrame.settingAction = nil; rowFrame.star:Hide()
    if option then
      rowFrame.option = option
      rowFrame.name:ClearAllPoints()
      rowFrame.name:SetPoint("LEFT", rowFrame.icon, "RIGHT", 7, 0)
      rowFrame.name:SetPoint("RIGHT", rowFrame, "RIGHT", -154, 0)
      rowFrame.name:SetText(option.label)
      rowFrame.value:SetText(ZGV.Options:GetValueText(option))
      rowFrame.value:SetTextColor(option.type == "toggle" and (ZGV.Options:GetValue(option) and .35 or 1) or .95, option.type == "toggle" and (ZGV.Options:GetValue(option) and 1 or .35) or .72, .25, 1)
      rowFrame.value:Show()
      rowFrame.icon:SetTexCoord(0, .25, .5, 1)
      rowFrame.tooltip = option.description or (option.type == "range" or option.type == "select") and "Left-click for the next value; right-click for the previous value." or "Click to change this option."
      self:SetRowAppearance(rowFrame, false, false); rowFrame:Show()
    else
      rowFrame.option = nil; rowFrame.tooltip = nil; rowFrame.value:Hide(); rowFrame:Hide()
    end
  end
  if self.listUp then self.listUp:Hide() end
  if self.listDown then self.listDown:Hide() end
end

function Menu:Refresh()
  if self._creating then return end
  self:Create()
  if self._creating then return end
  self:SetPaneMode(self.section == "SETTINGS")
  self:BuildCategoryButtons()
  if self.section == "SETTINGS" then self:RenderSettings(); return end
  if self.listUp then self.listUp:Show() end
  if self.listDown then self.listDown:Show() end
  local results = self:GetResults()
  self.resultOffset = math.max(0, math.min(self.resultOffset or 0, math.max(0, #results - RESULTS_PER_PAGE)))
  local first = self.resultOffset + 1
  local last = math.min(#results, self.resultOffset + RESULTS_PER_PAGE)
  local sectionTitle = self.section == "SEARCH" and "Search Results" or SECTION_LABELS[self.section] or self.section:gsub("^CATEGORY:", "")
  if self.section:match("^FOLDER:") then sectionTitle = self.section:match("^FOLDER:(.+)$") end
  self.listTitle:SetText(sectionTitle .. " (" .. #results .. ")" .. (#results > RESULTS_PER_PAGE and " " .. first .. "-" .. last or ""))
  if self.listUp then ZGV.Compat.UI:SetEnabled(self.listUp,self.resultOffset > 0) end
  if self.listDown then ZGV.Compat.UI:SetEnabled(self.listDown,self.resultOffset < math.max(0, #results - RESULTS_PER_PAGE)) end
  for _, button in ipairs(self.categories) do
    local activeCategory = self.section:match("^FOLDER:([^\\]+)")
    local selected = button.section == self.section or (activeCategory and button.section == "CATEGORY:" .. activeCategory)
    local text = button.GetFontString and button:GetFontString()
    if text then text:SetTextColor(selected and 1 or .72, selected and 1 or .72, selected and 1 or .72, 1) end
    self:SetSidebarAppearance(button, selected)
  end
  for _, button in ipairs(self.headerTabs or {}) do self:SetHeaderTabAppearance(button, button.section == self.section) end
  for index, item in ipairs(self.rows) do
    local guide = results[index + self.resultOffset]
    item.guide = guide
    item.settingAction = nil; item.option = nil; item.tooltip = nil; item.value:Hide()
    item.name:ClearAllPoints()
    item.name:SetPoint("LEFT", item.icon, "RIGHT", 5, 0); item.name:SetPoint("RIGHT", item, "RIGHT", -22, 0)
    if guide then
      item.name:SetText(trim(guide.menuName or guide.name or guide.title, 48))
      if not guide.isFolder and ZGV.db.profile.favorites[guide.id] then item.star:Show() else item.star:Hide() end
      if guide.isFolder then item.icon:SetTexCoord(.25, .5, 0, .5)
      else
        local path=guide.menuPath or guide.path or ""
        item.icon:SetTexCoord(path ~= "" and 0 or .25, path ~= "" and .25 or .5, 0, .5)
      end
      self:SetRowAppearance(item, guide == self.selected, false); item:Show()
    else item:Hide() end
  end
  if self.selected and not ZGV.Catalog:Get(self.selected) then self.selected = nil end
  if not self.selected and results[1] then self:Select(results[1]) else self:RenderDetails() end
end

function Menu:ToggleFavourite()
  if not self.selected or self.selected.isFolder then return end
  ZGV.Runtime:ToggleFavorite(self.selected)
  self:Refresh()
end

function Menu:LoadSelected()
  if not self.selected then return end
  if self.selected.isFolder then return self:OpenFolder(self.selected) end
  if ZGV.Runtime:SelectGuide(self.selected) then self.frame:Hide(); UI:ShowViewer() end
end

function Menu:Show(section)
  self:Create()
  if section then
    local requested = tostring(section)
    local optionGroup = requested:match("^SETTINGS:(.+)$") or requested:match("^OPTIONS:(.+)$")
    local normalized = requested:upper()
    if optionGroup then
      self.settingsCategory = optionGroup:lower()
      self.section = "SETTINGS"
    elseif normalized == "SETTINGS" or normalized == "OPTIONS" then
      self.section = "SETTINGS"
    elseif ZGV.Options and ZGV.Options:GetGroup(requested) then
      self.settingsCategory = ZGV.Options:GetGroup(requested).id
      self.section = "SETTINGS"
    else
      self.section = requested
    end
    self.resultOffset = 0
  end
  self.section = self.section or "HOME"; self.frame:Show(); self:Refresh()
end

function UI:ShowGuideMenu(section)
  return Menu:Show(section)
end

function UI:ShowOptions(section)
  return Menu:Show(section and ("SETTINGS:" .. tostring(section)) or "SETTINGS")
end

local baseSetMode = UI.SetMode
function UI:SetMode(mode)
  if mode == "browse" then return self:ShowGuideMenu() end
  return baseSetMode(self, mode)
end

ZGV:AddMessageHandler("SKIN_UPDATED", function() Menu:ApplySkin(); Menu:Refresh() end)
ZGV:RegisterCallback("ZGV_CATALOG_FINALIZED", Menu, "BuildCategoryButtons")
ZGV:RegisterCallback("ZGV_FAVORITES_CHANGED", Menu, "Refresh")
