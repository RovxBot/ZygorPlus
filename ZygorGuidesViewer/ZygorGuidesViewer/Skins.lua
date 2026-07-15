-- 3.3.5a skin registry for the unmodified modern Default style definitions.
-- Keep this intentionally small: it must initialize before the style files
-- and before any optional modern subsystem exists.
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" then return end
ZGV.SKINSDIR = ZGV.SKINSDIR or ZGV.SKINDIR or (ZGV.DIR and (ZGV.DIR .. "\\Skins\\"))

local Skins = { skins = {}, defaultSkin = "default" }
ZGV.Skins = Skins

local function getStyleValue(style, property)
  local current = style
  while current do
    local value = rawget(current, property)
    if value ~= nil then return value end
    current = rawget(current, "inheritedStyle")
  end
end

function Skins:AddSkin(id, name)
  local skin = { id = id, name = name, styles = {}, defaultStyle = nil }
  function skin:GetDir()
    local root = ZGV.SKINSDIR or ZGV.SKINDIR or (ZGV.DIR .. "\\Skins\\")
    return root .. self.id .. "\\"
  end
  function skin:AddStyle(styleID, styleName, inheritedID)
    local style = { id = styleID, name = styleName, skin = self, inheritedStyle = self.styles[inheritedID] }
    function style:GetDir()
      return self.skin:GetDir() .. self.id .. "\\"
    end
    function style:GetProp(property, ...)
      local value = getStyleValue(self, property)
      return type(value) == "function" and value(...) or value
    end
    self.styles[styleID] = style
    self.defaultStyle = self.defaultStyle or styleID
    return style
  end
  function skin:GetStyle(styleID)
    return self.styles[styleID or self.defaultStyle]
  end
  self.skins[id] = skin
  self.defaultSkin = self.defaultSkin or id
  return skin
end

function Skins:GetSkin(id)
  return self.skins[id or self.defaultSkin]
end

-- The upstream Default/Skin.lua normally registers this before it loads its
-- individual styles.  The 3.3 viewer creates its frame in Lua instead, so
-- establish the same skin identity here before Starlight/Stealth execute.
Skins.default=Skins:AddSkin("default", "Default")

function ZGV:GetSkinData(property, ...)
  local style = self.CurrentSkinStyle
  return style and style:GetProp(property, ...) or nil
end

ZGV.UI = ZGV.UI or {}
ZGV.UI.SkinData = function(property, ...)
  return ZGV:GetSkinData(property, ...)
end

-- The current Default skin stores title controls in a 64-column, four-row
-- atlas.  The original 3.3.5 addon did not need this abstraction, but the
-- modern viewer uses it for every chrome control.  Keep the small compatible
-- version here so every skin change rebuilds real normal/pressed/hover/
-- disabled button regions instead of falling back to white placeholders.
ZGV.ButtonSets = ZGV.ButtonSets or {}

local titleButtonNumbers = {
  QUESTION = 1, NOTIFICATIONS = 2, LOCK_OFF = 3, LOCK_ON = 4,
  SETTINGS = 5, CLOSE = 6, DOTS = 7, FRAME = 8,
  STEP_PREV = 9, STEP_NEXT = 10, LOADGUIDE = 11, QUESTCLEANUP = 12,
  MORETABS = 13, STEPREPORT = 14, BUGREPORT = 15, LIST = 16,
  BURGER = 17, INFO = 18, DROPDOWN = 19, SMALLX = 20,
  INLINETRAVEL = 21, GOLDGUIDE = 22, ADDGUIDE = 23, SHARE = 24,
  MAPMARKER = 25, CHANGEGUIDE = 26, RIGHTRIGHT = 27, PLUS = 28,
  MINUS = 29, RELOAD = 30, FLASH = 31, SEARCH = 32,
  TRAINER = 33, FINDNPC = 34, RESIZE = 35, DRAG = 36,
  VISIBLE = 37, INVISIBLE = 38, BROOM = 39, WIDGETS = 40,
  WAND = 41, BAGMANY = 42, BAGONE = 43, BAGLIST = 44, VIEWER = 45,
}

local function ensureButtonRegion(button, getter, setter)
  local region = getter and getter(button)
  if not region and setter then
    setter(button, "Interface\\Buttons\\WHITE8X8")
    region = getter(button)
  end
  return region
end

local function createButtonSet(file, numbers, count, defaultName)
  local set = { file = file, count = count, default = defaultName }
  local padding = 1 / 16
  for name, number in pairs(numbers) do
    local icon = { n = number }
    local states = {}
    for state = 1, 4 do
      states[state] = {
        (number - 1) / count + padding / count,
        number / count - padding / count,
        (state - 1) / 4 + padding / 4,
        state / 4 - padding / 4,
      }
    end
    icon.texcoords = states
    function icon:AssignToTexture(region)
      if not region then return end
      region:SetTexture(file)
      region:SetTexCoord(unpack(states[1]))
    end
    function icon:AssignToButton(button)
      if not button then return end
      local normal = ensureButtonRegion(button, button.GetNormalTexture, button.SetNormalTexture)
      local pushed = ensureButtonRegion(button, button.GetPushedTexture, button.SetPushedTexture)
      local highlight = ensureButtonRegion(button, button.GetHighlightTexture, button.SetHighlightTexture)
      local disabled = ensureButtonRegion(button, button.GetDisabledTexture, button.SetDisabledTexture)
      if normal then normal:SetTexture(file); normal:SetTexCoord(unpack(states[1])) end
      if pushed then pushed:SetTexture(file); pushed:SetTexCoord(unpack(states[2])) end
      if highlight then highlight:SetTexture(file); highlight:SetTexCoord(unpack(states[3])); highlight:SetBlendMode("ADD") end
      if disabled then disabled:SetTexture(file); disabled:SetTexCoord(unpack(states[4])) end
    end
    set[name] = icon
  end
  return setmetatable(set, { __index = function(self, _)
    return rawget(self, self.default)
  end })
end

function ZGV.ButtonSets:Create()
  self.TitleButtons = createButtonSet(ZGV:GetSkinData("TitleButtons") or (ZGV.SKINDIR .. "titlebuttons"), titleButtonNumbers, 64, "QUESTION")
  -- The map button uses its own two-column, four-state atlas.  It must not
  -- borrow zglogo: that was only the XML placeholder in older viewers and is
  -- why the rebuilt viewer showed the wrong minimap artwork after startup.
  self.Minimap = createButtonSet(ZGV.SKINDIR .. "minimap-icon", { NORMAL = 1, ACTIVE = 2 }, 2, "NORMAL")
end

-- The modern Default skin still exposes named icon atlases to menus, tabs,
-- notifications and compatibility widgets.  Recreate the Classic IconSets
-- contract with real texture assignment rather than placeholder regions.
ZGV.IconSets=ZGV.IconSets or {}
local function createIconSet(file,columns,rows,entries,default)
  local set={file=file,cols=columns,rows=rows,default=default}
  for name,definition in pairs(entries) do
    local column,row=definition[1],definition[2]
    local icon={column=column,row=row,label=definition.label}
    function icon:AssignToTexture(texture)
      if not texture then return end
      texture:SetTexture(file)
      texture:SetTexCoord((column-1)/columns,column/columns,(row-1)/rows,row/rows)
    end
    function icon:GetFontString(width,height,x,y,r,g,b)
      return "|T"..file..":"..tostring(height or width or 14)..":"..tostring(width or 14)..":"..tostring(x or 0)..":"..tostring(y or 0)..":"..tostring(columns)..":"..tostring(rows)..":"..tostring(column-1)..":"..tostring(column)..":"..tostring(row-1)..":"..tostring(row).."|t"
    end
    set[name]=icon
  end
  return setmetatable(set,{__index=function(self,key) return rawget(self,self.default) end})
end
function ZGV.IconSets:Create()
  local style=ZGV.CurrentSkinStyle
  local path=function(property,fallback) return style and style:GetProp(property) or fallback end
  self.TabsIcons=createIconSet(path("TabsIcons",ZGV.SKINDIR.."guideicons-big"),8,4,{
    LEVELING={1,1,label="Leveling"},EVENTS={2,1,label="Events"},DAILIES={3,1,label="Dailies"},LOREMASTER={4,1,label="Loremaster"},
    GOLD={1,2,label="Gold"},PROFESSIONS={2,2,label="Professions"},PETSMOUNTS={3,2,label="Pets & Mounts"},ACHIEVEMENTS={4,2,label="Achievements"},
    TITLES={1,3,label="Titles"},REPUTATIONS={2,3,label="Reputations"},DUNGEONS={4,3,label="Dungeons"},GEAR={1,4,label="Gear"},SHARED={2,4,label="Shared"},QUESTS={3,4,label="Quests"},FAVOURITES={4,4,label="Favourites"},
  },"LEVELING")
  self.GuideIconsSmall=createIconSet(path("GuideMenuSmallIcons",ZGV.SKINDIR.."guideicons-small"),4,2,{FOLDER={1,1},GUIDE={2,1},EXCLAMATION={3,1},STAR={1,2},QUEST={2,2}},"GUIDE")
  self.StepLineIcons=createIconSet(path("StepLineIcons",ZGV.SKINDIR.."guideicons-small"),32,1,{DOT={1,1},BIGDOT={2,1},CHECK={3,1},INACTIVEDOT={4,1},EXCLAMATION={5,1},QUEST={6,1},MOB={7,1},LOOT={8,1},STAR={9,1},TALK={13,1},NAVIGATION={14,1},TREASURE={15,1},RAREMOB={16,1},IMAGE={17,1},ARROW={18,1}},"DOT")
  self.NotificationIcons=createIconSet(ZGV.SKINDIR.."icons-notificationcenter",32,1,{ZYGOR={8,1},GEAR={5,1},GOLD={6,1},DUNGEON={9,1},ORIENTATION={8,1},SKILL={8,1}},"ZYGOR")
end

function Skins:AddStyleToBlizzardScrollBar(scrollbar)
  if not scrollbar or not scrollbar.ThumbTexture then return end
  local texture=ZGV:GetSkinData("ScrollBarTexture")
  local color=ZGV:GetSkinData("ScrollBarColor") or {1,1,1,1}
  if not texture then return end
  local function decoration(point)
    local region=scrollbar:CreateTexture(nil,"ARTWORK",nil,1)
    region:SetTexture(texture); region:SetVertexColor(unpack(color)); region:SetWidth(11); region:SetHeight(ZGV:GetSkinData("ScrollBarDecorHeight") or 5); region:SetPoint(point,scrollbar.ThumbTexture,point)
    return region
  end
  scrollbar.thumb_top=scrollbar.thumb_top or decoration("TOP")
  scrollbar.thumb_bottom=scrollbar.thumb_bottom or decoration("BOTTOM")
  scrollbar.ThumbTexture:SetAlpha(0)
  if scrollbar.ScrollUpButton then ZGV.F.AssignButtonTexture(scrollbar.ScrollUpButton,ZGV:GetSkinData("ScrollBarArrowsTexture"),1,2) end
  if scrollbar.ScrollDownButton then ZGV.F.AssignButtonTexture(scrollbar.ScrollDownButton,ZGV:GetSkinData("ScrollBarArrowsTexture"),2,2) end
end

function ZGV:AddSkin(id,name) return Skins:AddSkin(id,name) end
ZGV.SkinProto=ZGV.SkinProto or {}
ZGV.StyleProto=ZGV.StyleProto or {}
function ZGV.SkinProto:New(data)
  data=data or {}; return Skins:AddSkin(data.id or "skin",data.name or "Skin")
end
function ZGV.StyleProto:New(data)
  data=data or {}; local skin=Skins:GetSkin(data.skin or Skins.defaultSkin); return skin and skin:AddStyle(data.id or "style",data.name or "Style",data.inherit)
end
function ZGV:GetSkinPath(skinID,styleID)
  local skin=Skins:GetSkin(skinID or (self.db and self.db.profile.skin))
  local style=skin and skin:GetStyle(styleID or (self.db and self.db.profile.skinstyle))
  return style and style:GetDir() or (self.SKINDIR or "")
end

function ZGV:SetSkin(skinID, styleID)
  if styleID=="glass" then styleID="starlight" end
  local skin = Skins:GetSkin(skinID)
  local style = skin and skin:GetStyle(styleID)
  if not style and skin then style=skin:GetStyle(skin.defaultStyle) end
  if not style then return false end
  if self.db and self.db.profile then
    self.db.profile.skin = skin.id
    self.db.profile.skinstyle = style.id
  end
  self.CurrentSkin, self.CurrentSkinStyle = skin, style
  self.SkinDir, self.StyleDir = skin:GetDir(), style:GetDir()
  if self.ButtonSets and self.ButtonSets.Create then self.ButtonSets:Create() end
  if self.IconSets and self.IconSets.Create then self.IconSets:Create() end
  self:SendMessage("SKIN_UPDATED", skin, style)
  return true
end

ZGV:RegisterCallback("ZGV_STARTED", function()
  local profile = ZGV.db and ZGV.db.profile or {}
  local style = profile.skinstyle or "starlight"
  if profile.opacitytoggle and not style:find("%-glass$") then style = style .. "-glass" end
  if not ZGV:SetSkin(profile.skin or "default", style) then ZGV:SetSkin("default", "starlight") end
end)
