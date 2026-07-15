-- WotLK-safe WhoWhere port.  It preserves the Classic search/menu contract
-- and accepts complete NPC location datasets when present.  The compact port
-- also indexes known guide locations, so requests remain useful without a
-- retail LibRover dependency.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local WW=ZGV.WhoWhere or {Locations={}}
ZGV.WhoWhere=WW
WW.Locations=WW.Locations or {}
ZGV:RegisterModule("WhoWhere",WW)

local trades={"Alchemy","Blacksmithing","Cooking","Enchanting","Engineering","First Aid","Fishing","Herbalism","Jewelcrafting","Leatherworking","Mining","Skinning","Tailoring"}
local classes={"Druid","Hunter","Mage","Paladin","Priest","Rogue","Shaman","Warlock","Warrior"}
local aliases={Flightmaster="Flight master",Arrows="VendorArrows",Bullets="VendorBullets",Reagents="VendorReagent"}

function WW:SetupMenuArray()
  local function item(text,kind)
    return {text=text,type=kind or text,notCheckable=1,func=function() WW:FindNPC(kind or text) end}
  end
  local profession={}
  for _,name in ipairs(trades) do profession[#profession+1]=item(name,"Trainer"..name) end
  local classList={}
  for _,name in ipairs(classes) do classList[#classList+1]=item(name,"Class"..name) end
  self.Types={
    item("Auctioneer"),item("Banker"),item("Class Trainers",nil),item("Innkeeper"),item("Flightmaster"),
    item("Mailbox"),item("Profession Trainers",nil),item("Repair"),item("Stable Master"),item("Vendor"),
  }
  self.Types[3].nofunc=true; self.Types[3].hasArrow=true; self.Types[3].menuList=classList
  self.Types[6].func=function() WW:FindMailbox() end
  self.Types[7].nofunc=true; self.Types[7].hasArrow=true; self.Types[7].menuList=profession
  self.SpecialVendors={item("Any","Vendor"),item("Arrows"),item("Bullets"),item("Reagents")}
end

function WW:RegisterLocation(kind,location)
  if type(kind)~="string" or type(location)~="table" then return false end
  local map=location.mapKey or location.map or location.m
  if not map or not tonumber(location.x) or not tonumber(location.y) then return false end
  local list=self.Locations[kind] or {}; self.Locations[kind]=list
  list[#list+1]={mapKey=map,x=tonumber(location.x),y=tonumber(location.y),title=location.title or kind,npcID=location.npcID,walks=location.walks,region=location.region}
  return true
end

local function playerDistance(location)
  local destination={mapKey=location.mapKey,x=location.x,y=location.y}
  return ZGV.Navigation and ZGV.Navigation:GetDistance(destination) or nil
end

function WW:FindFromCurrentGuide(kind)
  local runtime=ZGV.Runtime
  local guide=runtime and runtime.currentGuide
  if not guide then return nil end
  local wanted=tostring(kind):lower():gsub("^trainer",""):gsub("^class","")
  for _,step in ipairs(guide.steps or {}) do
    for _,goal in ipairs(step.goals or {}) do
      local text=(goal.text or goal.npcName or ""):lower()
      local matches=text:find(wanted,1,true) or (kind=="Vendor" and goal.action=="vendor") or (kind:find("Trainer",1,true)==1 and goal.action=="trainer")
      if matches and goal.destination then
        return {mapKey=goal.destination.mapKey or goal.destination.map,x=goal.destination.x,y=goal.destination.y,title=goal.text,npcID=goal.npcID}
      end
    end
  end
end

function WW:FindNearest(kind)
  kind=aliases[kind] or kind
  local best,bestDistance,fallback
  for _,location in ipairs(self.Locations[kind] or {}) do
    fallback=fallback or location
    local distance=playerDistance(location)
    if distance and (not bestDistance or distance<bestDistance) then best,bestDistance=location,distance end
  end
  return best or fallback or self:FindFromCurrentGuide(kind)
end

function WW:SetWaypoint(map,x,y,target,w,region)
  if not ZGV.Pointer then return nil end
  local title=type(target)=="string" and target or ("Talk to "..tostring(target or "NPC"))
  if w then title=title.."\n"..(w=="1" and "(walks around this area)" or tostring(w)) end
  self.CurrentWay=ZGV.Pointer:SetWaypoint(map,x,y,{title=title,type="manual",cleartype=not (IsControlKeyDown and IsControlKeyDown()),onminimap="always",findpath=true,manualnpcid=target,waypoint_region=region},true)
  return self.CurrentWay
end

function WW:FindNPC(kind)
  kind=aliases[kind] or kind
  local location=self:FindNearest(kind)
  if not location then
    ZGV:Print("No known "..tostring(kind).." location in the installed WotLK data.")
    return false
  end
  local waypoint=self:SetWaypoint(location.mapKey,location.x,location.y,location.npcID or location.title or kind,location.walks,location.region)
  if waypoint then waypoint.title=location.title or kind; self.CurrentLocation=location end
  return waypoint
end
function WW:FindNPC_Direct(kind) return self:FindNPC(kind) end
function WW:FindNPC_Smart(kind) return self:FindNPC(kind) end
function WW:FindMailbox() return self:FindNPC("Mailbox") end

function WW:InteractionStart(_,kind)
  self.ActiveNPC=kind or (ZGV.GetUnitId and ZGV.GetUnitId("target"))
end
function WW:InteractionEnd()
  local point=self.CurrentWay
  local active=self.ActiveNPC; self.ActiveNPC=nil
  if point and active and point.manualnpcid and tostring(point.manualnpcid)==tostring(active) and ZGV.Pointer then
    ZGV.Pointer:ClearWaypoints("manual")
    ZGV:ShowWaypoints()
  end
end

function WW:ImportClassicData()
  if self._classicImported or type(ZGV._NPCData)~="table" then return false end
  local faction=UnitFactionGroup and UnitFactionGroup("player")
  local wanted=faction=="Alliance" and "A" or (faction=="Horde" and "H" or nil)
  local mapAPI=ZGV.Compat and ZGV.Compat.Map
  local function accept(side) return not side or side=="B" or not wanted or side==wanted end
  local function add(kind,id,raw)
    local side=raw:match("s([AHB])")
    local map,x,y=tonumber(raw:match("|m(%d+)")),tonumber(raw:match("|x([%d%.]+)")),tonumber(raw:match("|y([%d%.]+)"))
    local record=mapAPI and mapAPI:Resolve(map)
    if accept(side) and record and x and y then
      self:RegisterLocation(kind,{mapKey=record.key,x=x,y=y,npcID=tonumber(id),title=kind,walks=raw:match("|w([^|\n]+)")})
    end
  end
  for kind,blob in pairs(ZGV._NPCData) do
    for id,raw in tostring(blob):gmatch("(%d+)=([^\n]+)") do add(kind,id,raw) end
  end
  for raw in tostring(ZGV._MailboxData or ""):gmatch("([^\n]+)") do add("Mailbox","Mailbox",raw) end
  ZGV._NPCData=nil; ZGV._MailboxData=nil; self._classicImported=true
  return true
end

function WW:OnStartup()
  self:SetupMenuArray()
  self:ImportClassicData()
  -- Key hub mailboxes cover the normal WotLK travel loop.  Additional data
  -- can be registered by map/content packages through RegisterLocation.
  if not self._seeded then
    self._seeded=true
    for _,row in ipairs({
      {"Stormwind City",60.5,64.7,"Stormwind mailbox"},{"Orgrimmar",53.0,70.8,"Orgrimmar mailbox"},
      {"Dalaran",48.3,40.7,"Dalaran mailbox"},{"Ironforge",24.4,74.7,"Ironforge mailbox"},
      {"Undercity",64.7,48.5,"Undercity mailbox"},{"Shattrath City",56.3,81.7,"Shattrath mailbox"},
    }) do self:RegisterLocation("Mailbox",{mapKey=row[1],x=row[2],y=row[3],title=row[4]}) end
  end
  ZGV:AddEventHandler("GOSSIP_SHOW",function() WW:InteractionStart() end)
  ZGV:AddEventHandler("MERCHANT_SHOW",function() WW:InteractionStart() end)
  ZGV:AddEventHandler("TRAINER_SHOW",function() WW:InteractionStart() end)
  ZGV:AddEventHandler("MAIL_SHOW",function() WW:InteractionStart(nil,"Mailbox") end)
  for _,event in ipairs({"GOSSIP_CLOSED","MERCHANT_CLOSED","TRAINER_CLOSED","MAIL_CLOSED"}) do ZGV:AddEventHandler(event,function() WW:InteractionEnd() end) end
end
