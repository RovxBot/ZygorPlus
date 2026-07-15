local ZGV = ZygorGuidesViewer
local Catalog = ZGV:RegisterModule("Catalog",{
  guides={}, byTitle={}, byID={}, includes={}, finalized=false, sorted={},
  sortOrder={}, sortSequences={}, pathOrder={}, nextPathOrder=0,
  nextRegistration=0,
})

local function trim(text)
  local value=tostring(text or ""):gsub("^%s+",""):gsub("%s+$","")
  return value
end
local function stableID(title)
  local normalized=title:lower():gsub("[^%w]+","_"):gsub("^_+",""):gsub("_+$","")
  local checksum=5381
  for i=1,#title do checksum=(checksum*33+title:byte(i))%2147483647 end
  return "guide:"..normalized..":"..tostring(checksum)
end

local function pathSegments(value)
  local values={}
  for segment in tostring(value or ""):gmatch("[^\\]+") do values[#values+1]=segment end
  return values
end

-- Keep guide IDs and loadguide targets on their authored titles, but present
-- old WotLK pack roots inside the modern Classic menu hierarchy.  The
-- original packs predate the shared category tree and therefore register
-- separate faction-specific top-level folders.
local function menuTitleFor(title)
  -- Lua patterns do not support `|` alternation; the faction is intentionally
  -- matched as a word because both Alliance and Horde use the same menu root.
  local kind,tail=title:match("^Zygor's%s+%a+%s+(Leveling Guides)\\(.+)$")
  if kind then return "Leveling Guides\\"..tail end
  kind,tail=title:match("^Zygor's%s+%a+%s+(Dailies Guides)\\(.+)$")
  if kind then return "Dailies Guides\\"..tail end
  if title:match("^Reputations Guides\\") then
    return "Reputation Guides\\"..title:sub(#"Reputations Guides\\"+1)
  end
  return title
end

-- The Classic catalog creates its folder tree in registration order.  Keep
-- the first-seen ordinal of every path node so a flat catalog can reproduce
-- that hierarchy without alphabetically regrouping a leveling route.
function Catalog:RememberPath(title)
  local prefix=""
  for _,segment in ipairs(pathSegments(title)) do
    prefix=prefix=="" and segment or (prefix.."\\"..segment)
    local key=prefix:lower()
    if self.pathOrder[key]==nil then
      self.nextPathOrder=(self.nextPathOrder or 0)+1
      self.pathOrder[key]=self.nextPathOrder
    end
  end
end

local function normalizeHeader(header)
  if type(header)=="table" then return header end
  local result={}
  if type(header)~="string" then return result end
  for line in header:gmatch("[^\r\n]+") do
    local key,value=line:match("^%s*([%w_]+)%s+(.+)%s*$")
    if key then
      if value=="true" then value=true elseif value=="false" then value=false
      elseif tonumber(value) then value=tonumber(value) end
      result[key]=value
    end
  end
  return result
end

function Catalog:Register(title,header,data)
  title=trim(title)
  if title=="" then error("guide title is empty",2) end
  if data==nil and type(header)=="string" then data,header=header,{} end
  header=normalizeHeader(header)
  if type(data)~="string" then error("guide '"..title.."' has no DSL body",2) end
  local package=ZGV.ContentPackages and ZGV.CurrentContentPackage and ZGV.ContentPackages[ZGV.CurrentContentPackage]
  local source=ZGV._registrationSource or (package and package.source) or ZGV.CurrentContentPackage or "bundled"
  local priority=ZGV._registrationPriority or (package and package.priority) or (source:find("Anniversary") and 100 or 10)
  local existing=self.byTitle[title]
  if existing and existing.priority>priority then return existing end
  if existing then
    for i=1,#self.guides do if self.guides[i]==existing then table.remove(self.guides,i) break end end
    self.byID[existing.id]=nil
  end
  self.nextRegistration=(self.nextRegistration or 0)+1
  local guide={
    id=stableID(title), title=title, header=header, raw=data, source=source, priority=priority,
    menuTier=ZGV.GuideMenuTier, package=ZGV.CurrentContentPackage, beta=ZGV.BETAguides,
    registered=self.nextRegistration, parsed=false,
  }
  guide.name=title:match("([^\\]+)$") or title
  guide.path=title:match("^(.*)\\[^\\]+$") or ""
  guide.category=title:match("^([^\\]+)") or title
  guide.menuTitle=menuTitleFor(title)
  guide.menuName=guide.menuTitle:match("([^\\]+)$") or guide.menuTitle
  guide.menuPath=guide.menuTitle:match("^(.*)\\[^\\]+$") or ""
  guide.menuCategory=guide.menuTitle:match("^([^\\]+)") or guide.menuTitle
  -- The original Guide prototype exposes these names.  Keeping them on the
  -- unparsed catalog entry means menu/search code receives the same shape
  -- before it asks the parser to construct the step objects.
  guide.title_short=guide.name
  guide.guidepath=guide.path
  guide.headerdata=header
  guide.type=guide.category:upper():gsub("[^%w]","")
  self.guides[#self.guides+1]=guide
  self:RememberPath(guide.menuTitle)
  self.byTitle[title]=guide
  self.byID[guide.id]=guide
  self.finalized=false
  return guide
end

function Catalog:RegisterInclude(name,data)
  name=trim(name):gsub('^"',''):gsub('"$','')
  if name=="" or type(data)~="string" then error("invalid include",2) end
  self.includes[name]=data
end

function Catalog:Get(idOrTitle)
  if type(idOrTitle)=="table" then return idOrTitle end
  return self.byID[idOrTitle] or self.byTitle[idOrTitle]
end

function Catalog:Find(text)
  text=trim(text):lower()
  local result={}
  for i=1,#self.sorted do
    local guide=self.sorted[i]
    if text=="" or guide.title:lower():find(text,1,true) or guide.menuTitle:lower():find(text,1,true) then result[#result+1]=guide end
  end
  return result
end

function Catalog:Count() return #self.guides end

-- GuideSorting.lua registers ordered sibling names exactly like the Classic
-- viewer.  A sequence is intentionally additive: later content packages can
-- specify a folder list without having to know every pre-existing category.
function Catalog:RegisterGuideSorting(names)
  if type(names)~="table" then return end
  self.sortSequences[#self.sortSequences+1]=names
  for index,name in ipairs(names) do
    local key=tostring(name):lower()
    -- Match the source viewer: later, more specific lists replace an earlier
    -- ordinal for the same label.
    self.sortOrder[key]=index
  end
  self.finalized=false
end

function ZGV:RegisterGuideSorting(names) return Catalog:RegisterGuideSorting(names) end

function Catalog:Finalize()
  self.sorted={}
  for i=1,#self.guides do self.sorted[i]=self.guides[i] end
  table.sort(self.sorted,function(a,b)
    local aa,bb=pathSegments(a.menuTitle or a.title),pathSegments(b.menuTitle or b.title)
    local leftPrefix,rightPrefix="",""
    for index=1,math.max(#aa,#bb) do
      local left,right=aa[index],bb[index]
      if left==nil then return true elseif right==nil then return false end
      local leftKey,rightKey=left:lower(),right:lower()
      leftPrefix=leftPrefix=="" and leftKey or (leftPrefix.."\\"..leftKey)
      rightPrefix=rightPrefix=="" and rightKey or (rightPrefix.."\\"..rightKey)
      if leftKey~=rightKey then
        -- Registered sorting only wins when both siblings occur in the same
        -- authored sequence.  Otherwise Classic falls back to first-seen
        -- group/guide order, which is essential for 11-60 and 60-70 routes.
        local leftSort,rightSort=self.sortOrder[leftKey],self.sortOrder[rightKey]
        if leftSort and rightSort and leftSort~=rightSort then return leftSort<rightSort end
        local leftSeen=self.pathOrder[leftPrefix] or a.registered or 0
        local rightSeen=self.pathOrder[rightPrefix] or b.registered or 0
        if leftSeen~=rightSeen then return leftSeen<rightSeen end
        return leftKey<rightKey
      end
    end
    if (a.registered or 0)~=(b.registered or 0) then return (a.registered or 0)<(b.registered or 0) end
    return a.id<b.id
  end)
  self.finalized=true
  ZGV:Fire("ZGV_CATALOG_FINALIZED",self)
end

function ZGV:RegisterGuide(title,header,data) return Catalog:Register(title,header,data) end
function ZGV:RegisterInclude(name,data) return Catalog:RegisterInclude(name,data) end
function ZGV:GetGuideByTitle(title) return Catalog.byTitle[title] end
function ZGV:GetGuideByID(id) return Catalog.byID[id] end
