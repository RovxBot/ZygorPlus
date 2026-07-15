-- Reputation service for build 12340.  It keeps the familiar ZGV:GetReputation
-- and RepProto APIs while avoiding retail friendship/renown APIs unavailable
-- on the WotLK client.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Faction=ZGV:RegisterModule("Faction",{reputations={},byName={}})
local standingEnglish={"Hated","Hostile","Unfriendly","Neutral","Friendly","Honored","Revered","Exalted"}
local standingColors={"aa0000","ff0000","ff8800","ffff00","00ff00","00ff88","00ffff","cc88ff"}
local standingNumbers={}
for index,name in ipairs(standingEnglish) do standingNumbers[name:lower()]=index end

local standardRanges={
  [1]={-42000,-6000},[2]={-6000,-3000},[3]={-3000,0},[4]={0,3000},
  [5]={3000,9000},[6]={9000,21000},[7]={21000,42000},[8]={42000,42000},
}

local RepProto={}
Faction.RepProto=RepProto

local function standingName(index)
  return _G["FACTION_STANDING_LABEL"..tostring(index)] or standingEnglish[index] or "Unknown"
end

local function numberFor(value)
  if type(value)=="number" then return value end
  return standingNumbers[tostring(value or ""):lower()]
end

function RepProto:New(id,name)
  return setmetatable({id=id,name=name or "Unknown",standing=4,min=0,max=3000,val=0,progress=0}, {__index=RepProto})
end

function RepProto:GetStandingName(index) return standingName(index or self.standing) end
function RepProto:Current() return self:GetStandingName(self.standing) end
function RepProto:GetNextStanding() return math.min(8,(tonumber(self.standing) or 4)+1) end
function RepProto:Next() return self:GetStandingName(self:GetNextStanding()) end

function RepProto:CalcTo(standing)
  standing=numberFor(standing)
  if not standing or standing<=self.standing then return standing and 0 or nil end
  if standing-self.standing>1 then return nil,nil end
  return math.max(0,(self.max or self.val or 0)-(self.val or 0))
end

function RepProto:CalcTotalTo(standing)
  standing=numberFor(standing)
  if not standing or standing<=self.standing then return standing and 0 or nil end
  local total=math.max(0,(self.max or self.val)-(self.val or 0))
  for index=(self.standing or 4)+1,standing-1 do
    local range=standardRanges[index]
    if range then total=total+(range[2]-range[1]) end
  end
  return total
end

function RepProto:EqualOrAbove(standing)
  standing=numberFor(standing)
  return standing and self.standing>=standing or nil
end

function RepProto:Below(standing)
  standing=numberFor(standing)
  return standing and self.standing<standing or nil
end

function RepProto:GetFormattedStanding(standing)
  standing=numberFor(standing) or self.standing
  return "|cff"..(standingColors[standing] or "ffffff")..self:GetStandingName(standing).."|r"
end

function RepProto:Going(colour)
  if self.standing>=8 then return colour and self:GetFormattedStanding(8) or self:Current() end
  local percent=math.max(0,math.min(1,tonumber(self.progress) or 0))*100
  local nextName=colour and self:GetFormattedStanding(self:GetNextStanding()) or self:Next()
  return string.format("%.1f%% to %s",percent,nextName)
end

function RepProto:GetRawReputation()
  if GetFactionInfoByID and self.id then return {GetFactionInfoByID(self.id)} end
  return {self.name,nil,self.standing,self.min,self.max,self.val}
end

function RepProto:UpdateRep() return Faction:CacheRepByID(self.id) end

local function apply(rep,id,name,standing,minValue,maxValue,value)
  rep.id=id or rep.id
  rep.name=name or rep.name
  rep.standing=tonumber(standing) or rep.standing or 4
  rep.min=tonumber(minValue) or 0
  rep.max=tonumber(maxValue) or rep.min+1
  if rep.max==rep.min then rep.max=rep.min+1 end
  rep.val=tonumber(value) or rep.min
  rep.progress=math.max(0,math.min(1,(rep.val-rep.min)/(rep.max-rep.min)))
  return rep
end

function Faction:CacheRepByID(id)
  if not id or not GetFactionInfoByID then return nil end
  local name,_,standing,minValue,maxValue,value=GetFactionInfoByID(id)
  if not name then return nil end
  local rep=self.reputations[id] or RepProto:New(id,name)
  local oldValue,oldProgress=rep.val,rep.progress
  apply(rep,id,name,standing,minValue,maxValue,value)
  self.reputations[id]=rep
  self.byName[name:lower()]=rep
  if ZGV.db and ZGV.db.profile.faction.analyze and oldValue and oldValue~=rep.val then
    ZGV:Print(string.format("%s: %+d (%s)",rep.name,rep.val-oldValue,rep:Going(true)))
  end
  return rep
end

function Faction:CacheReputations()
  local seen={}
  local count=GetNumFactions and GetNumFactions() or 0
  for index=1,count do
    local name,_,standing,minValue,maxValue,value,_,_,header,_,hasRep=GetFactionInfo(index)
    if name and (not header or hasRep) then
      local rep=self.byName[name:lower()] or RepProto:New(nil,name)
      apply(rep,rep.id,name,standing,minValue,maxValue,value)
      self.byName[name:lower()]=rep
      if rep.id then self.reputations[rep.id]=rep end
      seen[name]=true
    end
  end
  return seen
end

function Faction:GetFakeRep(id,standing,minValue,maxValue,value,name)
  local rep=RepProto:New(id,name)
  return apply(rep,id,name,standing,minValue,maxValue,value)
end

function Faction:GetReputation(id)
  if type(id)=="number" then
    local fake=ZGV.db and ZGV.db.profile.faction.fake[id]
    if fake then return self:GetFakeRep(id,fake,nil,nil,nil) end
    return self:CacheRepByID(id) or self.reputations[id] or RepProto:New(id)
  end
  local name=tostring(id or "")
  local found=self.byName[name:lower()]
  if found then return found end
  self:CacheReputations()
  return self.byName[name:lower()] or RepProto:New(nil,name)
end

function Faction:OnEvent(event)
  if event=="UPDATE_FACTION" then
    self:CacheReputations()
    ZGV:Fire("ZGV_REPUTATION_UPDATED")
  end
end

function Faction:OnStartup()
  ZGV.StandingNamesEngRev=standingNumbers
  ZGV.StandingNames={}
  for index=1,8 do ZGV.StandingNames[index]=standingName(index) end
  self:CacheReputations()
end

function ZGV:GetReputation(id) return Faction:GetReputation(id) end
ZGV:RegisterEvent("UPDATE_FACTION",Faction,"OnEvent")
