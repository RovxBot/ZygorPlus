-- Recursive build-12340 renderer for the Anniversary ZGV.Visuals data
-- contract.  It intentionally preserves the portable content vocabulary,
-- filtering, callbacks, guide selection, and deterministic serialization;
-- the source's unused retail product-editor chrome is not reproduced.
local ZGV = ZygorGuidesViewer
local UI = ZGV and ZGV.UI
if type(ZGV) ~= "table" or type(UI) ~= "table" then return end

local Visuals = ZGV.Visuals or {}
ZGV.Visuals = Visuals
Visuals.AsString = Visuals.AsString or {}

local KNOWN = {
  generic = true, title = true, banner = true, text = true, item = true,
  list = true, columns = true, content = true, guideslist = true,
  section = true, roadmap_section = true, separator = true,
}

local function playerFaction()
  local faction = type(UnitFactionGroup) == "function" and UnitFactionGroup("player") or ""
  return tostring(faction):sub(1, 1):upper()
end

local function playerClass()
  local localized, token
  if type(UnitClass) == "function" then localized, token = UnitClass("player") end
  return tostring(localized or ""), tostring(token or ""):upper()
end

function Visuals:CheckConditions(element)
  if type(element) ~= "table" then return false end
  if element.faction and tostring(element.faction):sub(1, 1):upper() ~= playerFaction() then return false end
  if element.beta and not ZGV.BETA then return false end
  if element.class then
    local localized, token = playerClass()
    local expected = tostring(element.class)
    if expected ~= localized and expected:upper() ~= token then return false end
  end
  return true
end

local function validate(data, path)
  if type(data) ~= "table" then return false, (path or "visuals") .. " must be a table" end
  for index, element in ipairs(data) do
    local here = (path or "visuals") .. "[" .. index .. "]"
    if type(element) ~= "table" then return false, here .. " must be a table" end
    local kind = element[1]
    if not KNOWN[kind] then return false, here .. " has unknown element " .. tostring(kind) end
    if kind == "columns" then
      for childIndex = 2, #element do
        local child = element[childIndex]
        if type(child) ~= "table" then return false, here .. "[" .. childIndex .. "] must be a table" end
        if child[1] ~= "column" then
          local childValid, childProblem = validate({ child }, here .. "[" .. childIndex .. "]")
          if not childValid then return false, childProblem end
        end
      end
    end
  end
  return true
end

local function colorText(value, muted)
  local text = tostring(value or "")
  if muted then
    text = text:gsub("%*%*([^*]+)%*%*", "|cffaaaaaa%1|r")
    text = text:gsub("==([^=]+)==", "|cffaaaaaa%1|r")
  else
    text = text:gsub("%*%*([^*]+)%*%*", "|cfffe6100%1|r")
    text = text:gsub("==([^=]+)==", "|cffbbbbbb%1|r")
  end
  return text
end

local function size(frame, width, height)
  if ZGV.Compat and ZGV.Compat.UI then ZGV.Compat.UI:SetSize(frame, width, height)
  else frame:SetWidth(width); frame:SetHeight(height) end
end

local function textHeight(label, fallback)
  local value = label and label.GetStringHeight and label:GetStringHeight()
  return math.max(1, tonumber(value) or fallback or 14)
end

local function elementSpace(renderer, element, fallback)
  return (tonumber(element.space) or fallback or 5) + (tonumber(renderer.EXTRASPACE) or 0)
end

local function bottomPadding(renderer, kind, fallback)
  local padding = renderer.BOTTOMPADDING or {}
  local value = padding[kind]
  if value == nil then value = fallback end
  return tonumber(value) or 0
end

local function guideFrom(value)
  if type(value) == "table" then value = value.id or value.title end
  return ZGV.Catalog and ZGV.Catalog:Get(value) or nil
end

local function guideKey(guide)
  return guide and (guide.id or guide.title) or nil
end

local function safeItemLink(value)
  if type(value) == "number" then return "item:" .. value end
  local text = tostring(value or "")
  return text:match("|H(item:%d+:[^|]*)|h") or text:match("^(item:%d+:[%-%d:]*)$") or text:match("^(item:%d+)$")
end

local function clickHandler(renderer, element)
  if type(element.onclick) == "function" then
    return function()
      element.onclick()
      if type(renderer.POSTCLICK) == "function" then renderer.POSTCLICK(element) end
    end
  end
  if element.guide then
    local guide = guideFrom(element.guide)
    local key = guideKey(guide)
    if key and ZGV.Runtime then
      return function()
        ZGV.Runtime:SelectGuide(key)
        if type(renderer.POSTCLICK) == "function" then renderer.POSTCLICK(element) end
      end
    end
  elseif element.folder and ZGV.GuideMenu then
    return function()
      ZGV.GuideMenu:Show(tostring(element.folder):gsub("\\$", ""))
      if type(renderer.POSTCLICK) == "function" then renderer.POSTCLICK(element) end
    end
  elseif element.featured and ZGV.GuideMenu then
    return function()
      if ZGV.GuideMenu.ShowFeatured then ZGV.GuideMenu:ShowFeatured(element.featured, element.section) end
      if type(renderer.POSTCLICK) == "function" then renderer.POSTCLICK(element) end
    end
  end
end

local function generic(renderer, element, parent)
  local object = UI:Create("Button", parent)
  if not object then return nil, "button factory unavailable" end
  object:SetNormalBackdropColor(0, 0, 0, 0); object:SetBackdropBorderColor(0, 0, 0, 0)
  object:RegisterForClicks("AnyUp")
  local handler = clickHandler(renderer, element)
  if handler then object:SetScript("OnClick", handler) else object:EnableMouse(false) end
  object.tooltip = element.tooltip
  object:SetScript("OnEnter", function(self)
    local itemLink = safeItemLink(element.itemLink or element.link or element.itemID or element.item)
    if itemLink and GameTooltip.SetHyperlink then
      GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetHyperlink(itemLink); GameTooltip:Show()
    elseif self.tooltip then
      GameTooltip:SetOwner(self, "ANCHOR_CURSOR"); GameTooltip:SetText(type(self.tooltip) == "function" and self.tooltip() or tostring(self.tooltip), nil, nil, nil, nil, true); GameTooltip:Show()
    end
  end)
  object:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return object
end

local function textRow(renderer, element, parent, width, kind, defaultSize, defaultSpace, wrap)
  local object, failure = generic(renderer, element, parent)
  if not object then return nil, 0, 0, failure end
  width = tonumber(element.width) or width or renderer.WIDTH
  object:SetWidth(width); object:SetText(colorText(element.text, element.muted)); object:SetFont(element.font or ZGV.Font, tonumber(element.fontsize) or defaultSize)
  local label = object:GetFontString(); label:SetJustifyH(element.center and "CENTER" or "LEFT"); label:SetWordWrap(wrap ~= false); label:SetWidth(width)
  local height = textHeight(label, defaultSize + 4) + bottomPadding(renderer, kind, kind == "item" and 10 or kind == "content" and 30 or kind == "section" and 10 or 0)
  object:SetHeight(height); object.ztype = kind
  local space = elementSpace(renderer, element, defaultSpace); object.space = space
  return object, height, space
end

local handlers = {}

handlers.generic = function(renderer, element, parent, width)
  element.text = element.text or ""
  return textRow(renderer, element, parent, width, "generic", 13, 5, true)
end
handlers.title = function(renderer, element, parent, width) return textRow(renderer, element, parent, width, "title", 18, 30, false) end
handlers.text = function(renderer, element, parent, width) return textRow(renderer, element, parent, width, "text", 13, 5, true) end
handlers.content = function(renderer, element, parent, width) return textRow(renderer, element, parent, width, "content", 16, 10, false) end
handlers.section = function(renderer, element, parent, width) return textRow(renderer, element, parent, width, "section", 14, 10, false) end
handlers.roadmap_section = function(renderer, element, parent, width)
  local object, height, space, failure = textRow(renderer, element, parent, width, "roadmap_section", 15, 10, false)
  if object then
    object.backicon = object:CreateTexture(nil, "ARTWORK"); object.backicon:SetTexture(ZGV.SKINDIR .. "titlebuttons"); size(object.backicon, 12, 12); object.backicon:SetPoint("LEFT", object, "LEFT", 0, 0)
  end
  return object, height, space, failure
end

handlers.banner = function(renderer, element, parent, width)
  local object, failure = generic(renderer, element, parent)
  if not object then return nil, 0, 0, failure end
  local height = (tonumber(element.height) or 109) + bottomPadding(renderer, "banner", 0)
  size(object, tonumber(element.width) or width or renderer.WIDTH, height)
  object:SetTexture(element.image or "Interface\\Buttons\\WHITE8X8")
  if element.top and element.bottom and element.left and element.right then object:SetTexCoord(element.top, element.bottom, element.left, element.right) end
  object.ztype = "banner"; local space = elementSpace(renderer, element, 5); object.space = space
  return object, height, space
end

local function guideLabel(element)
  local guide = guideFrom(element.guide)
  if guide then return element.text or guide.name or guide.title, false end
  if element.itemID or element.item or element.itemLink or element.link then
    local item = element.itemID or element.item or element.itemLink or element.link
    local info = ZGV.Compat and ZGV.Compat.Item and ZGV.Compat.Item:GetInfo(item)
    return element.text or (info and (info.link or info.name)) or tostring(item), false
  end
  return element.text or tostring(element.guide or element.folder or ""), element.guide ~= nil or element.folder ~= nil
end

handlers.item = function(renderer, element, parent, width)
  local display, muted = guideLabel(element); element.text = display; element.muted = element.muted or muted
  local object, height, space, failure = textRow(renderer, element, parent, width, "item", 13, 5, not renderer.NOWORDWRAP)
  if object then
    object.tex:Show(); object.tex:ClearAllPoints(); object.tex:SetPoint("LEFT", object, "LEFT", 3, 0); size(object.tex, 14, 14)
    object.tex:SetTexture(element.icon or "Interface\\Buttons\\UI-RadioButton")
  end
  return object, height, space, failure
end
handlers.list = function(renderer, element, parent, width)
  local display, muted = guideLabel(element); element.text = display; element.muted = element.muted or muted
  return textRow(renderer, element, parent, width, "list", 13, 5, not renderer.NOWORDWRAP)
end

handlers.separator = function(renderer, element, parent, width)
  local object = CreateFrame("Frame", nil, parent); size(object, tonumber(element.width) or width or renderer.WIDTH, 1)
  object.line = object:CreateTexture(nil, "ARTWORK"); object.line:SetAllPoints(object); object.line:SetTexture(ZGV.SKINDIR .. "white"); object.line:SetVertexColor(.21, .21, .21, 1)
  object.ztype = "separator"; local space = elementSpace(renderer, element, 15); object.space = space
  return object, 1, space
end

local function place(parent, objects, firstAnchor, topLeft)
  local previous
  for _, entry in ipairs(objects) do
    local object, space = entry.object, entry.space
    object:ClearAllPoints()
    if previous then object:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -space)
    elseif firstAnchor then object:SetPoint(unpack(firstAnchor))
    else
      local left, top = 10, -5
      if topLeft then left, top = tonumber(topLeft[1]) or left, tonumber(topLeft[2]) or top end
      object:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)
    end
    previous = object
  end
end

local renderSequence
renderSequence = function(renderer, data, parent, width, firstAnchor, topLeft)
  local entries, height = {}, 0
  for index, element in ipairs(data) do
    if renderer:CheckConditions(element) then
      local handler = handlers[element[1]]
      local object, objectHeight, space, failure = handler(renderer, element, parent, width)
      if failure then return nil, 0, failure end
      if object then
        element.object = object; object:Show(); entries[#entries + 1] = { object = object, space = space or 0 }
        height = height + (objectHeight or 0) + (space or 0)
      end
    end
  end
  place(parent, entries, firstAnchor, topLeft)
  return entries, height
end

handlers.columns = function(renderer, element, parent, width)
  width = tonumber(element.width) or width or renderer.WIDTH
  local object = CreateFrame("Frame", nil, parent); object.Columns = {}; object.ztype = "columns"
  local groups, explicit, current = {}, false
  for index = 2, #element do
    local child = element[index]
    if child[1] == "column" then explicit = true; current = {}; groups[#groups + 1] = current
    elseif renderer:CheckConditions(child) then
      if not current then current = {}; groups[1] = current end
      current[#current + 1] = child
    end
  end
  if not explicit then
    local flat = groups[1] or {}; groups = {}; local count = math.max(1, math.min(tonumber(element.count) or 2, #flat > 0 and #flat or 1))
    for index = 1, count do groups[index] = {} end
    for index, child in ipairs(flat) do groups[(index - 1) % count + 1][#groups[(index - 1) % count + 1] + 1] = child end
  end
  if #groups == 0 then groups[1] = {} end
  local columnWidth = math.floor((width - 5 * (#groups - 1)) / #groups); local maxHeight = 1
  for index, children in ipairs(groups) do
    local column = CreateFrame("Frame", nil, object); column.Elements = {}; column:SetWidth(columnWidth)
    if index == 1 then column:SetPoint("TOPLEFT", object, "TOPLEFT", 0, 0) else column:SetPoint("TOPLEFT", object.Columns[index - 1], "TOPRIGHT", 5, 0) end
    object.Columns[index] = column
    local entries, height, failure = renderSequence(renderer, children, column, columnWidth, nil, { 0, 0 })
    if failure then return nil, 0, 0, failure end
    column.Elements = entries or {}; column:SetHeight(math.max(1, height)); maxHeight = math.max(maxHeight, height)
  end
  size(object, width, maxHeight + bottomPadding(renderer, "columns", 0)); local space = elementSpace(renderer, element, 5); object.space = space
  return object, object:GetHeight(), space
end

local function filteredGuides(element)
  if type(element.results) == "table" then return element.results end
  local result = {}
  local function contains(actual, expected)
    expected = tostring(expected):lower()
    if type(actual) == "table" then
      for _, value in pairs(actual) do if tostring(value):lower() == expected then return true end end
      return false
    end
    return tostring(actual):lower() == expected
  end
  local function matches(guide)
    for key, expected in pairs(element.filters or {}) do
      local actual = guide[key] or (guide.header and guide.header[key])
      if actual == nil then return false end
      if expected ~= "*" then
        if type(expected) == "table" then
          local andMode = expected[1] == "AND"; local matched = andMode
          for index, value in ipairs(expected) do
            if index > 1 or not andMode then
              if andMode then matched = matched and contains(actual, value) else matched = matched or contains(actual, value) end
            end
          end
          if not matched then return false end
        elseif not contains(actual, expected) then return false end
      end
    end
    return true
  end
  for _, guide in ipairs(ZGV.Catalog and ZGV.Catalog.sorted or {}) do
    local pathOK = not element.path or tostring(guide.title or ""):lower():find(tostring(element.path):lower(), 1, true)
    local visible = not ZGV.Conditions or ZGV.Conditions:EvaluateHeader(guide, "condition_visible", true)
    if pathOK and visible and matches(guide) then result[#result + 1] = guide end
  end
  return result
end

handlers.guideslist = function(renderer, element, parent, width)
  local columns = { "columns", count = tonumber(element.columns) or 2, width = element.width }
  local count = 0
  for _, value in ipairs(filteredGuides(element)) do
    local guide = type(value) == "table" and (value.id and value or guideFrom(value[1] or value.guide or value.title)) or guideFrom(value)
    if guide then columns[#columns + 1] = { "item", text = guide.name or guide.title, guide = guide.id or guide.title }; count = count + 1 end
    local limit = tonumber(element.limit)
    if limit and count >= limit then break end
  end
  local object, height, space, failure = handlers.columns(renderer, columns, parent, width)
  if object then object.ztype = "guideslist" end
  return object, height, space, failure
end

function Visuals:Render(data, width, parent, config)
  local valid, problem = validate(data)
  if not valid then return false, problem end
  local renderer = setmetatable({}, { __index = Visuals })
  renderer.WIDTH = tonumber(width) or (parent and parent.GetWidth and parent:GetWidth()) or 300
  renderer.PARENT = parent or CreateFrame("Frame")
  renderer.PARENT:SetWidth(renderer.WIDTH)
  for key, value in pairs(config or {}) do renderer[key] = value end
  renderer.BOTTOMPADDING = renderer.BOTTOMPADDING or { item = 10, content = 30, section = 10 }
  renderer.PARENT.Objects = {}
  local entries, height, failure = renderSequence(renderer, data, renderer.PARENT, renderer.WIDTH, renderer.FIRSTANCHOR, renderer.TOPLEFT)
  if failure then return false, failure end
  for _, entry in ipairs(entries or {}) do renderer.PARENT.Objects[#renderer.PARENT.Objects + 1] = entry.object end
  renderer.PARENT:SetHeight(math.max(1, height or 0))
  return renderer.PARENT, renderer
end

local function target(element)
  return tostring(element.guide or element.folder or element.featured or "")
end
for _, kind in ipairs({ "title", "banner", "text", "item", "list", "content", "section", "roadmap_section" }) do
  Visuals.AsString[kind] = function(element)
    local body = kind == "banner" and element.image or element.text
    return kind .. tostring(body or "") .. target(element)
  end
end
Visuals.AsString.generic = function() return "" end
Visuals.AsString.separator = function() return "" end
Visuals.AsString.columns = function(element)
  local output = "columns" .. tostring(element.text or "")
  for index = 2, #element do
    local child = element[index]
    if child[1] ~= "column" and Visuals:CheckConditions(child) and Visuals.AsString[child[1]] then output = output .. Visuals.AsString[child[1]](child) end
  end
  return output .. target(element)
end
Visuals.AsString.guideslist = function(element)
  local values = {}
  for key, value in pairs(element.filters or {}) do
    if type(value) == "table" then value = table.concat(value, ",") end
    values[#values + 1] = tostring(key) .. tostring(value)
  end
  table.sort(values)
  return "guideslist" .. tostring(element.content or "") .. table.concat(values, ",") .. tostring(element.text or "") .. target(element)
end

function Visuals:GetAsString(data)
  local valid, problem = validate(data)
  if not valid then return nil, problem end
  local output = {}
  for _, element in ipairs(data) do
    if self:CheckConditions(element) then output[#output + 1] = Visuals.AsString[element[1]](element) end
  end
  return table.concat(output, "|n") .. (#output > 0 and "|n" or "")
end

Visuals.KnownTypes = KNOWN
