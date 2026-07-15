-- WotLK LFD dungeon metadata cache.  It intentionally uses only build-12340
-- APIs and the port's canonical map registry.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Dungeons=ZGV:RegisterModule("Dungeons",{byID={},DungeonNamesToMapNames={Deadmines="The Deadmines"}})
local Proto={}

function Proto:GetName(heroic)
  if heroic==nil then heroic=self.heroic end
  if heroic==nil then return self.name end
  return heroic and ("Heroic "..self.name) or ("Normal "..self.name)
end

local function mapKey(name)
  name=Dungeons.DungeonNamesToMapNames[name] or name
  return ZGV.CanonicalMapKey and ZGV:CanonicalMapKey(name,0) or name
end

function Dungeons:Build(id)
  if type(id)~="number" or not GetLFGDungeonInfo then return nil end
  local name,typeID,subtypeID,minLevel,maxLevel,recLevel,minRecLevel,maxRecLevel,expansion,groupID,texture,difficulty,maxPlayers,description,isHoliday=GetLFGDungeonInfo(id)
  if not name or typeID==4 then return nil end
  local dungeon=setmetatable({
    id=id,name=name,typeID=typeID,subtypeID=subtypeID,minLevel=minLevel,maxLevel=maxLevel,
    recommendedLevel=recLevel,minRecommendedLevel=minRecLevel,maxRecommendedLevel=maxRecLevel,
    expansionLevel=expansion,groupID=groupID,texture=texture,difficulty=difficulty,
    heroic=(tonumber(difficulty) or 0)>1,maxPlayers=maxPlayers,description=description,isHoliday=isHoliday,
    map=mapKey(name),
  },{__index=Proto})
  self.byID[id]=dungeon
  return dungeon
end

function Dungeons:Get(id)
  if self.byID[id] then return self.byID[id] end
  local dungeon=self:Build(id)
  if dungeon and GetLFDLockInfo then
    local _,code,itemLevel=GetLFDLockInfo(id,1)
    dungeon.minItemLevel=code==4 and tonumber(itemLevel) or 0
  end
  return dungeon
end

function Dungeons:GetByMapAndHeroic(map,heroic)
  for _,dungeon in pairs(self.byID) do if dungeon.map==map and dungeon.heroic==heroic then return dungeon end end
end

function Dungeons:GetCurrent()
  if not GetInstanceInfo then return nil end
  local name,typeName,difficulty=GetInstanceInfo()
  if not name or typeName=="none" then return nil end
  local heroic=tonumber(difficulty) and tonumber(difficulty)>1
  for _,dungeon in pairs(self.byID) do if dungeon.name==name and dungeon.heroic==heroic then return dungeon end end
end

function Dungeons:RefreshLocks()
  for id,dungeon in pairs(self.byID) do
    if GetLFDLockInfo then
      local _,code,itemLevel=GetLFDLockInfo(id,1)
      dungeon.minItemLevel=code==4 and tonumber(itemLevel) or 0
    end
  end
end

function Dungeons:OnStartup()
  self.Faction=UnitFactionGroup and UnitFactionGroup("player") or nil
  self.CurrentExpansion=(GetServerExpansionLevel and GetServerExpansionLevel()) or 2
  self.MaxLevelForLatestExpansion=(GetMaxLevelForExpansionLevel and GetMaxLevelForExpansionLevel(self.CurrentExpansion)) or 80
  self.maxlevel=self.MaxLevelForLatestExpansion
  for id=1,1000 do self:Build(id) end
  self:RefreshLocks()
end

function Dungeons:OnEvent(event)
  if event=="LFG_LOCK_INFO_RECEIVED" then self:RefreshLocks() end
end

ZGV:RegisterEvent("LFG_LOCK_INFO_RECEIVED",Dungeons,"OnEvent")
ZGV.UTILS=ZGV.UTILS or {}
ZGV.UTILS.Dungeons={GetDungeonsByName=function()
  local result={}
  for _,dungeon in pairs(Dungeons.byID) do result[dungeon.name]=dungeon end
  return result
end}
