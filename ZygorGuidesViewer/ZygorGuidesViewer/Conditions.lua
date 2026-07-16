local ZGV = ZygorGuidesViewer
local Conditions = ZGV:RegisterModule("Conditions",{ compiled={}, skills={}, reputation={} })

local standings={ Hated=1,Hostile=2,Unfriendly=3,Neutral=4,Friendly=5,Honored=6,Revered=7,Exalted=8 }
for name,value in pairs(standings) do _G[name]=value end

local classGlobals={"DeathKnight","Druid","Hunter","Mage","Paladin","Priest","Rogue","Shaman","Warlock","Warrior"}
local raceGlobals={"Human","Dwarf","NightElf","Gnome","Draenei","Orc","Scourge","Undead","Tauren","Troll","BloodElf"}

local function questCall(method,id)
  local service=ZGV.Compat and ZGV.Compat.Quest
  if method=="IsActive" then method="IsOnQuest" end
  local fn=service and service[method]
  if type(fn)~="function" then return false end
  local ok,result=pcall(fn,service,id)
  if not ok then return false end
  if type(result)=="table" then return result.completed or result.active or result.value or result.ok and result.found end
  return result and true or false
end

function Conditions:RefreshIdentity()
  local _,classToken=UnitClass("player")
  local _,raceToken=UnitRace("player")
  local factionName=UnitFactionGroup and UnitFactionGroup("player") or ""
  self.classToken=classToken or ""
  self.raceToken=raceToken or ""
  self.className=(classToken or ""):gsub("_",""):lower()
  self.raceName=(raceToken or ""):gsub("_",""):lower()
  self.factionName=tostring(factionName or ""):lower()
  _G.level=UnitLevel("player") or 0
  _G.Alliance=self.factionName=="alliance"
  _G.Horde=self.factionName=="horde"
  for i=1,#classGlobals do _G[classGlobals[i]]=classGlobals[i]:lower()==self.className end
  for i=1,#raceGlobals do
    local token=raceGlobals[i]:lower()
    if token=="undead" then token="scourge" end
    _G[raceGlobals[i]]=token==self.raceName
  end
end

function Conditions:RaceClass(value)
  value=tostring(value or ""):gsub("[_%s%-]",""):lower()
  if value=="undead" then value="scourge" end
  return value==self.raceName or value==self.className or value==self.factionName or value==(self.raceName..self.className)
end

function Conditions:Faction(value)
  return tostring(value or ""):gsub("[_%s%-]",""):lower()==self.factionName
end

-- GetBindLocation is the authoritative 3.3.5a source for the Hearthstone's
-- destination. Return nil when the client cannot provide it so old clients do
-- not lose guide steps merely because the capability is unavailable.
function Conditions:Bound(name)
  if type(GetBindLocation)~="function" then return nil end
  local current=GetBindLocation("player")
  if not current or current=="" then current=GetBindLocation() end
  if not current or current=="" then return nil end
  local function compactLocation(value)
    return tostring(value or ""):lower():gsub("[^%a%d]","")
  end
  local wanted=compactLocation(name)
  if wanted=="" then return current end
  return compactLocation(current)==wanted
end

function Conditions:CompletedQuest(...)
  for i=1,select("#",...) do if questCall("IsCompleted",select(i,...)) then return true end end
  return false
end

function Conditions:CompletedAllQuests(...)
  for i=1,select("#",...) do
    if not questCall("IsCompleted",select(i,...)) then return false end
  end
  return true
end

function Conditions:CountCompletedQuests(...)
  local count=0
  for i=1,select("#",...) do if questCall("IsCompleted",select(i,...)) then count=count+1 end end
  return count
end

function Conditions:HaveQuest(id) return questCall("IsActive",id) end

function Conditions:HaveAllQuests(...)
  for i=1,select("#",...) do if not self:HaveQuest(select(i,...)) then return false end end
  return true
end

function Conditions:CountHaveQuests(...)
  local count=0
  for i=1,select("#",...) do if self:HaveQuest(select(i,...)) then count=count+1 end end
  return count
end

function Conditions:QuestReady(...)
  local service=ZGV.Compat and ZGV.Compat.Quest
  for i=1,select("#",...) do
    local entry=service and service.FindInLog and service:FindInLog(select(i,...))
    if entry and entry.isComplete then return true end
  end
  return false
end

function Conditions:AllQuestsReady(...)
  for i=1,select("#",...) do if not self:QuestReady(select(i,...)) then return false end end
  return true
end

function Conditions:Skill(name)
  name=tostring(name or ""):lower()
  local service=ZGV.Compat and ZGV.Compat.Profession
  if service and type(service.GetSkill)=="function" then
    local ok,result=pcall(service.GetSkill,service,name)
    if ok and type(result)=="table" then return tonumber(result.rank or result.skillLevel or result.value) or 0 end
  end
  for index=1,(GetNumSkillLines and GetNumSkillLines() or 0) do
    local skillName,isHeader,_,rank=GetSkillLineInfo(index)
    if not isHeader and skillName and skillName:lower()==name then return tonumber(rank) or 0 end
  end
  return 0
end

-- `skillmax` is deliberately separate from `skill`: training Apprentice,
-- Journeyman, and later ranks changes a profession's cap without changing
-- its current value. The authored profession guides use it for exactly that
-- trainer-rank check (for example, Engineering 1/75 after Apprentice).
function Conditions:SkillMax(name)
  name=tostring(name or ""):lower()
  local service=ZGV.Compat and ZGV.Compat.Profession
  if service and type(service.GetSkill)=="function" then
    local ok,result=pcall(service.GetSkill,service,name)
    if ok and type(result)=="table" then
      return tonumber(result.maxSkillLevel or result.max or result.maximum) or 0
    end
  end
  for index=1,(GetNumSkillLines and GetNumSkillLines() or 0) do
    local skillName,isHeader,_,_,_,_,maximum=GetSkillLineInfo(index)
    if not isHeader and skillName and skillName:lower()==name then return tonumber(maximum) or 0 end
  end
  return 0
end

function Conditions:Reputation(name)
  if ZGV.Faction and ZGV.Faction.GetReputation then
    local rep=ZGV.Faction:GetReputation(name)
    if rep then return tonumber(rep.standing) or 0 end
  end
  name=tostring(name or ""):lower()
  for index=1,(GetNumFactions and GetNumFactions() or 0) do
    local factionName,_,standingID=GetFactionInfo(index)
    if factionName and factionName:lower()==name then return tonumber(standingID) or 0 end
  end
  return 0
end

function Conditions:ReputationValue(name,baseStanding)
  if ZGV.Faction and ZGV.Faction.GetReputation then
    local rep=ZGV.Faction:GetReputation(name)
    local requested=standings[tostring(baseStanding or ""):gsub("%s","")] or tonumber(baseStanding) or 0
    if rep then
      if (tonumber(rep.standing) or 0)<requested then return -99999 end
      if (tonumber(rep.standing) or 0)>requested then return 99999 end
      return (tonumber(rep.val) or 0)-(tonumber(rep.min) or 0)
    end
  end
  local wanted=tostring(name or ""):lower()
  local requested=standings[tostring(baseStanding or ""):gsub("%s","")] or tonumber(baseStanding) or 0
  for index=1,(GetNumFactions and GetNumFactions() or 0) do
    local factionName,_,standingID,bottom,_,earned=GetFactionInfo(index)
    if factionName and factionName:lower()==wanted then
      standingID=tonumber(standingID) or 0
      if standingID<requested then return -99999 end
      if standingID>requested then return 99999 end
      return (tonumber(earned) or 0)-(tonumber(bottom) or 0)
    end
  end
  return -99999
end

function Conditions:ItemCount(id,includeBank)
  local service=ZGV.Compat and ZGV.Compat.Item
  if service and type(service.GetCount)=="function" then
    local ok,result=pcall(service.GetCount,service,tonumber(id) or id,includeBank)
    if ok and type(result)=="table" then return tonumber(result.count) or 0 end
    if ok then return tonumber(result) or 0 end
  end
  return GetItemCount and GetItemCount(tonumber(id) or id,includeBank) or 0
end

function Conditions:KnownSpell(id)
  if IsSpellKnown then return IsSpellKnown(tonumber(id)) and true or false end
  local name=GetSpellInfo and GetSpellInfo(tonumber(id))
  return name and IsPlayerSpell and IsPlayerSpell(tonumber(id)) or false
end

function Conditions:KnownRecipe(id)
  return self:KnownSpell(id)
end

local weaponAliases={
  AXE="Axes", TH_AXE="Two-Handed Axes", MACE="Maces", TH_MACE="Two-Handed Maces",
  SWORD="Swords", TH_SWORD="Two-Handed Swords", DAGGER="Daggers", BOW="Bows",
  GUN="Guns", CROSSBOW="Crossbows", THROWN="Thrown", TH_STAFF="Staves",
  POLEARM="Polearms", FIST="Fist Weapons", WAND="Wands",
}
local function compact(value)
  return tostring(value or ""):gsub("[^%a%d]",""):lower()
end

function Conditions:WeaponSkill(token)
  local wanted=weaponAliases[tostring(token or ""):upper()] or token
  wanted=compact(wanted)
  for index=1,(GetNumSkillLines and GetNumSkillLines() or 0) do
    local name,isHeader,_,rank=GetSkillLineInfo(index)
    if not isHeader and compact(name)==wanted then return tonumber(rank) or 0 end
  end
  return 0
end

function Conditions:WarlockPet(name)
  if not UnitExists or not UnitExists("pet") then return false end
  local wanted=tostring(name or ""):lower()
  local petName=UnitName and UnitName("pet") or ""
  local family=UnitCreatureFamily and UnitCreatureFamily("pet") or ""
  return tostring(petName):lower()==wanted or tostring(family):lower()==wanted
end

function Conditions:HeroicDungeon()
  if not GetInstanceInfo then return false end
  local _,instanceType,difficulty=GetInstanceInfo()
  return instanceType=="party" and (tonumber(difficulty)==2 or tonumber(difficulty)==23)
end

function Conditions:DiscountGold(faction, amount)
  amount=tonumber(amount) or 0
  local standing=self:Reputation(faction)
  -- The 3.3.5a city-vendor discount reaches 10% at Honored.  The guides use
  -- this predicate for riding and similar purchase branches.
  if standing>=6 then amount=math.ceil(amount*.9) end
  return (GetMoney and GetMoney() or 0)>=amount
end

function Conditions:Money()
  return GetMoney and GetMoney() or 0
end

function Conditions:HaveBuff(value)
  local raw=tostring(value or "")
  -- Guide tags commonly use the human-readable spell name plus its ID
  -- (`Shadowy Disguise##32756`).  UnitBuff returns only the localized name,
  -- so treating the entire tag as a name leaves the goal permanently false
  -- and can trap an automatic quest branch in a loop.
  local spellID=tonumber(raw) or tonumber(raw:match("^spell:(%d+)$")) or tonumber(raw:match("##(%d+)"))
  local taggedName=raw:gsub("##%d+.*$",""):gsub("^%s+",""):gsub("%s+$","")
  local wantedName=GetSpellInfo and spellID and GetSpellInfo(spellID) or taggedName
  for index=1,40 do
    local name=UnitBuff("player",index)
    if not name then break end
    if name==wantedName or name==taggedName or name==raw then return true end
  end
  return false
end

local safe={}
local function bind(name,method) safe[name]=function(...) return Conditions[method](Conditions,...) end end
bind("raceclass","RaceClass")
bind("completedq","CompletedQuest")
bind("completedallq","CompletedAllQuests")
bind("countcompletedq","CountCompletedQuests")
bind("havequest","HaveQuest")
bind("haveq","HaveQuest")
bind("haveallq","HaveAllQuests")
bind("counthaveq","CountHaveQuests")
bind("readyq","QuestReady")
bind("readyallq","AllQuestsReady")
bind("skill","Skill")
bind("skillmax","SkillMax")
bind("rep","Reputation")
bind("repval","ReputationValue")
bind("itemcount","ItemCount")
bind("knownspell","KnownSpell")
bind("knowspell","KnownSpell")
bind("knowsrecipe","KnownRecipe")
bind("weaponskill","WeaponSkill")
bind("warlockpet","WarlockPet")
bind("heroic_dung","HeroicDungeon")
bind("discountgold","DiscountGold")
bind("money","Money")
bind("havebuff","HaveBuff")
bind("hasbuff","HaveBuff")
bind("faction","Faction")
bind("bound","Bound")
bind("hearthbound","Bound")
safe.level=function() return UnitLevel("player") or 0 end
safe.isdead=function() return UnitIsDeadOrGhost("player") and true or false end
safe.ontaxi=function() return UnitOnTaxi and UnitOnTaxi("player") or false end
safe.offtaxi=function() return not safe.ontaxi() end
safe.indoors=function() return IsIndoors and IsIndoors() and true or false end
safe.outdoors=function() return IsOutdoors and IsOutdoors() and true or false end
safe.flying=function() return IsFlying and IsFlying() and true or false end
safe.iswalking=function() return not safe.flying() and not safe.ontaxi() end
safe.incombat=function() return UnitAffectingCombat and UnitAffectingCombat("player") and true or false end
safe.invehicle=function() return UnitInVehicle and UnitInVehicle("player") and true or false end
safe.outvehicle=function() return not safe.invehicle() end
safe.equipped=function(itemID)
  local service=ZGV.Compat and ZGV.Compat.Item
  local result=service and service.IsEquipped and service:IsEquipped(itemID)
  return type(result)=="table" and result.equipped or result and true or false
end
local function matchesZone(current, wanted)
  if wanted==nil or wanted=="" then return current end
  return tostring(current or ""):lower()==tostring(wanted):lower()
end
safe.zone=function(wanted) return matchesZone(GetRealZoneText and GetRealZoneText() or "",wanted) end
safe.subzone=function(wanted) return matchesZone(GetSubZoneText and GetSubZoneText() or "",wanted) end
safe.math=math safe.string=string safe.tonumber=tonumber safe.tostring=tostring safe.type=type

for name,value in pairs(standings) do safe[name]=value end

function Conditions:Environment()
  local env={}
  for key,value in pairs(safe) do env[key]=value end
  env.level=UnitLevel("player") or 0
  env.Alliance=self.factionName=="alliance"
  env.Horde=self.factionName=="horde"
  -- In the guide grammar `default` selects the primary authored branch.  It
  -- is deliberately true unless an alternative condition hides that branch.
  env.default=true
  -- These are bare values (rather than calls) in a sizeable part of the
  -- bundled guide corpus.  Keep them current each time an expression runs.
  env.walking=safe.iswalking()
  env.flying=safe.flying()
  env.incombat=safe.incombat()
  env.indoors_state=safe.indoors()
  -- Explicitly restore the callable predicates after populating scalar guide
  -- aliases.  Some bundled guide headers use both `indoors` and `indoors()`;
  -- the latter must never resolve to a stale boolean from a prior evaluation.
  env.indoors=safe.indoors
  env.outdoors=safe.outdoors
  env.zone=safe.zone
  env.subzone=safe.subzone
  for i=1,#classGlobals do env[classGlobals[i]]=_G[classGlobals[i]] end
  for i=1,#raceGlobals do env[raceGlobals[i]]=_G[raceGlobals[i]] end
  return setmetatable(env,{__index=function() return false end})
end

function Conditions:Evaluate(expression,guide)
  if expression==nil or expression=="" then return true end
  if type(expression)=="boolean" then return expression end
  expression=tostring(expression)
  if expression:find("[;{}]") or expression:find("_G",1,true) or expression:find("getfenv",1,true) or expression:find("setfenv",1,true) then return false,"unsafe expression" end
  local compiled=self.compiled[expression]
  if not compiled then
    local loader,err=loadstring("return ("..expression..")","ZGV condition")
    if not loader then return false,err end
    compiled=loader
    self.compiled[expression]=compiled
  end
  setfenv(compiled,self:Environment())
  local ok,result=pcall(compiled)
  if not ok then return false,result end
  return result and true or false
end

function Conditions:EvaluateHeader(guide,key,default)
  local condition=guide and guide.header and guide.header[key]
  if condition==nil then return default end
  if type(condition)=="function" then
    self:RefreshIdentity()
    local ok,result=pcall(condition)
    if not ok then ZGV:LogError("guide condition "..guide.title,result) return default end
    return result and true or false
  end
  return self:Evaluate(condition,guide)
end

function Conditions:OnStartup() self:RefreshIdentity() end
ZGV:RegisterEvent("PLAYER_LEVEL_UP",Conditions,function(self) self:RefreshIdentity() end)
ZGV:RegisterEvent("PLAYER_ENTERING_WORLD",Conditions,function(self) self:RefreshIdentity() end)

_G.raceclass=function(...) return Conditions:RaceClass(...) end
_G.completedq=function(...) return Conditions:CompletedQuest(...) end
_G.havequest=function(...) return Conditions:HaveQuest(...) end
_G.skill=function(...) return Conditions:Skill(...) end
_G.skillmax=function(...) return Conditions:SkillMax(...) end
_G.rep=function(...) return Conditions:Reputation(...) end
_G.itemcount=function(...) return Conditions:ItemCount(...) end
_G.knownspell=function(...) return Conditions:KnownSpell(...) end
_G.havebuff=function(...) return Conditions:HaveBuff(...) end
_G.hasbuff=function(...) return Conditions:HaveBuff(...) end
