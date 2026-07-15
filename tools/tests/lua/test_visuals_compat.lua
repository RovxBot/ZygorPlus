local repo = assert(arg[1], "repository root required")

local selected, tooltipLink
UnitFactionGroup = function() return "Alliance" end
UnitClass = function() return "Mage", "MAGE" end

local function noop() end
local function newRegion(skipTexture)
  local region = { shown = true, scripts = {}, width = 300, height = 14, text = "" }
  function region:SetWidth(value) self.width = value end
  function region:GetWidth() return self.width end
  function region:SetHeight(value) self.height = value end
  function region:GetHeight() return self.height end
  function region:SetSize(width, height) self.width, self.height = width, height end
  function region:SetText(value) self.text = tostring(value or "") end
  function region:GetText() return self.text end
  function region:SetFont() end
  function region:GetStringHeight() return self.height end
  function region:SetJustifyH() end
  function region:SetWordWrap() end
  function region:SetPoint() end
  function region:ClearAllPoints() end
  function region:SetAllPoints() end
  function region:SetTexture(value) self.texture = value end
  function region:SetTexCoord() end
  function region:SetVertexColor() end
  function region:SetBackdropBorderColor() end
  function region:SetNormalBackdropColor() end
  function region:RegisterForClicks() end
  function region:SetScript(event, callback) self.scripts[event] = callback end
  function region:EnableMouse(value) self.mouse = value end
  function region:Show() self.shown = true end
  function region:Hide() self.shown = false end
  function region:CreateTexture() return newRegion(true) end
  function region:CreateFontString() return newRegion(true) end
  function region:GetFontString() self.fontString = self.fontString or newRegion(true); return self.fontString end
  if not skipTexture then region.tex = newRegion(true) end
  return region
end

CreateFrame = function() return newRegion() end
GameTooltip = {
  SetOwner = noop,
  SetHyperlink = function(_, link) tooltipLink = link end,
  SetText = noop,
  Show = noop,
  Hide = noop,
}

local guide = { id = "guide:test", title = "Leveling\\Test", name = "Test" }
ZygorGuidesViewer = {
  Font = "font.ttf", FontBold = "font-bold.ttf", SKINDIR = "Interface\\AddOns\\Zygor\\Skins\\",
  UI = { Create = function() return newRegion() end },
  Compat = {
    UI = { SetSize = function(_, frame, width, height) frame:SetSize(width, height) end },
    Item = { GetInfo = function(_, item) return { itemID = item, name = "Test Item", link = "|Hitem:100:0:0:0:0:0:0:0|h[Test Item]|h" } end },
  },
  Catalog = {
    sorted = { guide },
    Get = function(_, value) if value == guide.id or value == guide.title or value == guide then return guide end end,
  },
  Runtime = { SelectGuide = function(_, value) selected = value; return true end },
}

dofile(repo .. "/ZygorGuidesViewerNew/ZygorGuidesViewer/VisualsCompat.lua")
local Visuals = assert(ZygorGuidesViewer.Visuals)

assert(Visuals:CheckConditions({ faction = "A", class = "MAGE" }), "token class and faction condition")
assert(Visuals:CheckConditions({ class = "Mage" }), "localized class condition")
assert(not Visuals:CheckConditions({ faction = "H" }), "wrong faction rejected")
assert(not Visuals:CheckConditions({ class = "WARRIOR" }), "wrong class rejected")
assert(not Visuals:CheckConditions({ beta = true }), "beta content rejected by default")
ZygorGuidesViewer.BETA = true
assert(Visuals:CheckConditions({ beta = true }), "beta content accepted in beta mode")

local data = {
  { "generic", text = "Generic" },
  { "title", text = "**Title**" },
  { "banner", image = "banner.tga", height = 40 },
  { "text", text = "Body" },
  { "item", guide = guide.id, itemID = 100 },
  { "list", text = "List" },
  { "columns", count = 2, { "text", text = "Left" }, { "item", text = "Right", guide = guide.id } },
  { "content", text = "Content" },
  { "guideslist", text = "Guides", results = { guide }, columns = 1 },
  { "section", text = "Section" },
  { "roadmap_section", text = "Roadmap" },
  { "separator" },
}
local parent, renderer = Visuals:Render(data, 320)
assert(parent and renderer and #parent.Objects == #data, "all public visual types render recursively")
assert(data[5].object and data[5].object.scripts.OnClick, "guide item has click handler")
data[5].object.scripts.OnClick()
assert(selected == guide.id, "guide selection uses stable guide ID")
data[5].object.scripts.OnEnter(data[5].object)
assert(tooltipLink == "item:100", "item tooltip receives sanitized item hyperlink")

local serialized = assert(Visuals:GetAsString({
  { "title", text = "Welcome", faction = "A" },
  { "text", text = "Hidden", faction = "H" },
  { "columns", { "column" }, { "item", text = "Guide", guide = guide.id } },
  { "guideslist", text = "Browse", filters = { z = { "b", "a" }, a = "x" } },
}))
assert(serialized == "titleWelcome|ncolumnsitemGuideguide:test|nguideslistax,zb,aBrowse|n", "deterministic recursive serialization")

local rendered, problem = Visuals:Render({ { "unknown", text = "bad" } }, 100)
assert(rendered == false and problem:find("unknown element", 1, true), "unknown top-level elements fail closed")
local nested, nestedProblem = Visuals:Render({ { "columns", { "unknown" } } }, 100)
assert(nested == false and nestedProblem:find("unknown element", 1, true), "unknown nested elements fail closed")

print("visuals compatibility headless tests passed")
