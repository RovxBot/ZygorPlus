-- WotLK pointer compatibility facade.  Navigation owns rendering and route
-- selection in this port; Pointer retains the public waypoint API consumed by
-- older guide modules and third-party snippets.
local ZGV=ZygorGuidesViewer
if not ZGV or not ZGV.Compat or not ZGV.Navigation then return end

local Pointer=ZGV:RegisterModule("Pointer",{waypoints={},pointsets={},ready=false})
ZGV.Pointer=Pointer
Pointer.Icons={
  none="none",greendotbig="manual",graydot="marker",crosshair="player",
  ant="route",ant_taxi="route",ant_ship="route",ant_portal="route",
  rare="rare",treasure="treasure",
}

local Map=ZGV.Compat.Map

local function copy(source)
  local target={}
  for key,value in pairs(source or {}) do target[key]=value end
  return target
end

local function normalizeCoordinate(value)
  value=tonumber(value)
  if not value then return nil end
  return value>1 and value/100 or value
end

local function selectedRecord()
  local state=Map:GetSelected()
  return state and state.key and Map:Resolve(state.key)
end

function Pointer:ResolveMap(map,zone)
  if type(map)=="table" then
    return Map:Resolve(map.mapKey or map.key or map.map or map.m or map)
  end
  local record=Map:Resolve(map)
  if record then return record end
  if map~=nil and zone~=nil and type(Map._ResolveLegacyZoneKey)=="function" then
    local key=Map:_ResolveLegacyZoneKey(map,zone,0)
    if key then return Map:Resolve(key) end
  end
  if type(map)=="string" then
    local wanted=map:lower():gsub("^%s+",""):gsub("%s+$","")
    for _,candidate in pairs(Map:GetRegistry()) do
      if type(candidate)=="table" and tostring(candidate.name or ""):lower()==wanted then return candidate end
    end
  end
  return map==nil and selectedRecord() or nil
end

function Pointer:ToNavigationPoint(waypoint)
  local record=self:ResolveMap(waypoint.mapKey or waypoint.m or waypoint.map,waypoint.z)
  if not record then return nil end
  local resolved=ZGV.Navigation:ResolveTarget({mapKey=record.key,x=waypoint.x,y=waypoint.y,title=waypoint.title})
  if not resolved then return nil end
  resolved.kind=waypoint.type=="manual" and "manual" or (waypoint.type=="poi" and "poi" or "marker")
  resolved.poiType=waypoint.poiType
  resolved.onminimap=waypoint.onminimap==true or waypoint.onminimap=="always" or waypoint.onminimap=="zone"
  resolved.onClick=waypoint.onClick and function(_,button) return waypoint.onClick(waypoint,button) end or nil
  resolved.waypoint=waypoint
  return resolved
end

function Pointer:SyncMarkers()
  local markers={}
  for _,waypoint in ipairs(self.waypoints) do
    local point=self:ToNavigationPoint(waypoint)
    if point then markers[#markers+1]=point end
  end
  ZGV.Navigation:SetExternalMarkers("pointer",markers)
end

local function unpackArguments(a,b,c,d,e)
  -- Anniversary shape: (map,x,y,data,arrow).  Original WotLK shape:
  -- (continent,zone,x,y,data).  Retain both while keeping one marker model.
  if type(d)=="table" or type(d)=="boolean" or d==nil then return a,nil,b,c,d,e end
  return nil,b,c,d,e,true,a
end

function Pointer:SetWaypoint(a,b,c,d,e)
  local map,legacyZone,x,y,data,arrow,legacyContinent=unpackArguments(a,b,c,d,e)
  data=copy(data)
  local record=self:ResolveMap(map,legacyZone)
  if not record and legacyContinent then record=self:ResolveMap(legacyContinent,legacyZone) end
  x,y=normalizeCoordinate(x),normalizeCoordinate(y)
  if not record or not x or not y or x<0 or x>1 or y<0 or y>1 then return nil,"invalid waypoint" end
  data.type=data.type or "way"
  if data.cleartype then self:ClearWaypoints(data.type) end
  local legacy=record.legacy or {}
  local waypoint={
    mapKey=record.key,m=record.key,map=record.key,c=legacy.continent,z=legacy.zone,
    x=x,y=y,f=record.floor or legacy.floor or 0,
    title=data.maplabel or data.title or data.arrowtitle or (record.name.." "..string.format("%.1f, %.1f",x*100,y*100)),
    type=data.type,goal=data.goal or (data.parentStep and data or nil),storedData=data.storedData or data,
    onClick=data.OnClick or data.onClick,onminimap=data.onminimap,poiType=data.poiType or data.type,
    persistent=data.persistent,findpath=data.findpath,waypoint_region=data.waypoint_region,
  }
  for key,value in pairs(data) do if waypoint[key]==nil then waypoint[key]=value end end
  self.waypoints[#self.waypoints+1]=waypoint
  if waypoint.type=="manual" then self.nummanual=(self.nummanual or 0)+1 end
  self:SyncMarkers()
  if arrow==nil then arrow=true end
  if arrow and waypoint.type~="poi" and waypoint.type~="ant" then self:ShowArrow(waypoint) end
  ZGV:Fire("ZGV_POINTER_WAYPOINT_ADDED",waypoint)
  return waypoint
end

function Pointer:RemoveWaypoint(waypoint)
  local index=type(waypoint)=="number" and waypoint or nil
  if not index then for i,point in ipairs(self.waypoints) do if point==waypoint then index=i break end end end
  if not index then return false end
  local removed=table.remove(self.waypoints,index)
  if removed.type=="manual" then self.nummanual=math.max(0,(self.nummanual or 1)-1) end
  if self.DestinationWaypoint==removed then self:HideArrow() end
  self:SyncMarkers()
  ZGV:Fire("ZGV_POINTER_WAYPOINT_REMOVED",removed)
  return true
end

function Pointer:ClearWaypoints(waytype)
  local count=0
  for index=#self.waypoints,1,-1 do
    if not waytype or self.waypoints[index].type==waytype then self:RemoveWaypoint(index); count=count+1 end
  end
  return count
end

function Pointer:ShowArrow(waypoint)
  if not waypoint then return false end
  if waypoint.type~="manual" and waypoint.type~="corpse" then self:ClearWaypoints("manual") end
  local destination=self:ToNavigationPoint(waypoint)
  if not destination then return false,"unresolved map" end
  self.DestinationWaypoint=waypoint
  self.current_waypoint=waypoint
  self.ArrowFrame=(ZGV.UI and ZGV.UI.arrow) or self.ArrowFrame
  if self.ArrowFrame then self.ArrowFrame.waypoint=waypoint end
  local ok=ZGV.Navigation:SetWaypoint(destination,waypoint.title)
  ZGV:Fire("ZGV_POINTER_ARROW_CHANGED",waypoint)
  return ok
end

function Pointer:HideArrow()
  self.DestinationWaypoint=nil self.current_waypoint=nil
  if self.ArrowFrame then self.ArrowFrame.waypoint=nil end
  ZGV.Navigation:ClearWaypoint()
  ZGV:Fire("ZGV_POINTER_ARROW_CHANGED",nil)
end

function Pointer:GetWaypointByGoal(goal)
  for _,waypoint in ipairs(self.waypoints) do if waypoint.goal==goal then return waypoint end end
end

function Pointer:SetWaypointToGoal(goal)
  if not goal then return nil end
  local waypoint=self:GetWaypointByGoal(goal)
  if not waypoint and goal.x and goal.y then waypoint=self:SetWaypoint(goal.map or goal.m,goal.x,goal.y,goal,true) end
  if waypoint then self:ShowArrow(waypoint) end
  return waypoint
end

function Pointer:FindTravelPath(waypoint)
  waypoint=waypoint or self.DestinationWaypoint
  if not waypoint then return nil end
  if self.DestinationWaypoint~=waypoint then self:ShowArrow(waypoint) end
  return ZGV.Navigation.route
end

function Pointer:ShowSet(waypath,name,callback)
  name=tostring(name or "default")
  self:ClearSet(name,"keeparrow")
  local set={name=name,waypoints={}}
  self.pointsets[name]=set
  local coordinates=(waypath and (waypath.coords or waypath.points)) or {}
  for _,point in ipairs(coordinates) do
    local data=copy(point)
    data.type=data.type or (waypath and waypath.type) or "way"
    data.onminimap=data.onminimap or (data.type=="poi" and "zone" or nil)
    data.storedData=data.storedData or point
    local waypoint=self:SetWaypoint(point.mapKey or point.map or point.m,point.x,point.y,data,false)
    if waypoint then set.waypoints[#set.waypoints+1]=waypoint end
  end
  if type(callback)=="function" then callback(set) end
  return set
end

function Pointer:Thread_ShowSet(waypath,name,callback) return self:ShowSet(waypath,name,callback) end

function Pointer:ClearSet(name,keepArrow)
  local set=self.pointsets[tostring(name or "default")]
  if not set then return 0 end
  local count=0
  for _,waypoint in ipairs(copy(set.waypoints)) do
    if keepArrow and waypoint==self.DestinationWaypoint then
    else if self:RemoveWaypoint(waypoint) then count=count+1 end end
  end
  self.pointsets[tostring(name or "default")]=nil
  return count
end

function Pointer:ClearSets(keepArrow)
  local count=0
  for name in pairs(self.pointsets) do count=count+self:ClearSet(name,keepArrow) end
  return count
end

function Pointer:FormatDistance(distance)
  distance=tonumber(distance) or 0
  if ZGV.db and ZGV.db.profile.pointer and ZGV.db.profile.pointer.meters then return string.format("%.0f m",distance*.9144) end
  return string.format("%.0f yd",distance)
end
ZGV.FormatDistance=function(distance) return Pointer:FormatDistance(distance) end

function Pointer:SetArrowSkin(name)
  if ZGV.db and ZGV.db.profile.arrow then ZGV.db.profile.arrow.theme=name or "Starlight" end
  if ZGV.UI and ZGV.UI.UpdateArrow then ZGV.UI:UpdateArrow(ZGV.Navigation:GetArrowState()) end
end
function Pointer:GetArrowSkin() return ZGV.db and ZGV.db.profile.arrow and ZGV.db.profile.arrow.theme or "Starlight" end

function Pointer:SetWaypointByCommandLine(input,justparse)
  input=tostring(input or "")
  local map,floor,x,y=input:match("^(.-)%s*/%s*(%d+)%s+([%d%.]+)[ ,;:]+([%d%.]+)$")
  if not map then map,x,y=input:match("^(.-)%s+([%d%.]+)[ ,;:]+([%d%.]+)$") end
  if not x then x,y=input:match("^([%d%.]+)[ ,;:]+([%d%.]+)$") end
  if not map and not x and input~="" then map=input end
  local aliases={SW="Stormwind City",IF="Ironforge",ORG="Orgrimmar",UC="Undercity",ELWYNN="Elwynn Forest",STORMWIND="Stormwind City"}
  if map then map=aliases[map:upper()] or map end
  local record=self:ResolveMap(map)
  if not record and not map then record=selectedRecord() end
  if not record then if not justparse then ZGV:Print("Unknown map: "..tostring(map)) end return nil end
  x,y=tonumber(x) or 50,tonumber(y) or 50
  if justparse then return record.key,x,y end
  return self:SetWaypoint(record.key,x,y,{type="manual",cleartype=true,onminimap="always",findpath=true},true)
end

function Pointer:DoCorpseCheck()
  if not (ZGV.db and ZGV.db.profile.pointer and ZGV.db.profile.pointer.autoCorpse) then return end
  if not UnitIsDeadOrGhost or not UnitIsDeadOrGhost("player") or not GetCorpseMapPosition then return end
  local state=Map:CaptureState()
  if SetMapToCurrentZone then pcall(SetMapToCurrentZone) end
  local x,y=GetCorpseMapPosition()
  local selected=Map:GetSelected()
  Map:RestoreState(state)
  if x and y and (x>0 or y>0) and selected.key then
    self:ClearWaypoints("corpse")
    self:SetWaypoint(selected.key,x,y,{type="corpse",title="Your corpse",onminimap="always",cleartype=true},true)
  end
end

function Pointer:ApplyOptions()
  local profile=ZGV.db and ZGV.db.profile and ZGV.db.profile.pointer
  if not profile then return end
  for _,waypoint in ipairs(self.waypoints) do
    if waypoint.type=="poi" then waypoint.onminimap=profile.showMinimap and "zone" or nil end
  end
  self:SyncMarkers()
  if ZGV.UI and ZGV.UI.UpdateArrow then ZGV.UI:UpdateArrow(ZGV.Navigation:GetArrowState()) end
end

function Pointer:OnStartup()
  self.ready=true
  self.ArrowFrame=(ZGV.UI and ZGV.UI.arrow) or nil
  self:ApplyOptions()
end

function Pointer:OnCorpseEvent() self:DoCorpseCheck() end
ZGV:RegisterEvent("PLAYER_DEAD",Pointer,"OnCorpseEvent")
ZGV:RegisterEvent("PLAYER_ALIVE",Pointer,"OnCorpseEvent")
ZGV:RegisterEvent("PLAYER_UNGHOST",Pointer,"OnCorpseEvent")
