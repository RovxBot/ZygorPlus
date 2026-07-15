-- Classic ShowWaypoints facade over the WotLK Navigation/Pointer renderer.
-- It keeps named point sets, inline-travel paths, manual points, and the
-- public entry point used by guides and WhoWhere without importing LibRover's
-- retail-only runtime.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Waypoints = ZGV.Waypoints or {}
ZGV.Waypoints = Waypoints

local function visible(goal)
  if type(goal)~="table" then return false end
  if type(goal.IsVisible)=="function" then
    local ok,result=pcall(goal.IsVisible,goal)
    if ok then return result end
  end
  return goal.hidden~=true and goal.force_noway~=true
end

local function destination(goal)
  if type(goal)~="table" then return nil end
  if goal.destination then return goal.destination end
  if goal.mapKey or goal.map or goal.m then
    return {mapKey=goal.mapKey or goal.map or goal.m,map=goal.map or goal.m,x=goal.x,y=goal.y,title=goal.text}
  end
end

function Waypoints:GetFocusedStep()
  local runtime=ZGV.Runtime
  return runtime and runtime.currentGuide and runtime.currentGuide.steps[runtime.currentStep]
end

function Waypoints:Clear()
  if ZGV.Pointer then
    ZGV.Pointer:ClearWaypoints("way")
    ZGV.Pointer:ClearSet("route")
    ZGV.Pointer:ClearSet("farm")
    ZGV.Pointer:ClearSet("path")
  end
  -- Do not clear Navigation directly: a manual/corpse pointer is intentionally
  -- independent of guide waypoints and must survive a guide refresh.
end

function Waypoints:BuildPath(step)
  local source=step and step.waypath
  if source and (source.coords or source.points) then return source end
  local coordinates={}
  for _,goal in ipairs(step and step.goals or {}) do
    local point=destination(goal)
    if point and visible(goal) and goal.action=="goto" then
      coordinates[#coordinates+1]={mapKey=point.mapKey or point.map,map=point.map,x=point.x,y=point.y,title=goal.text,goal=goal}
    end
  end
  return #coordinates>1 and {coords=coordinates,loop=false,type="way"} or nil
end

function Waypoints:Show(command, step)
  self:Clear()
  if command=="clear" then return false end
  step=step or self:GetFocusedStep()
  if not step or not ZGV.Pointer then return false end

  local path=self:BuildPath(step)
  if path then ZGV.Pointer:ShowSet(path,path.loop and "farm" or "path") end
  local points={}
  for _,goal in ipairs(step.goals or {}) do
    local point=destination(goal)
    if point and visible(goal) and goal.action~="mapmarker" then
      points[#points+1]={
        mapKey=point.mapKey or point.map,map=point.map,x=point.x,y=point.y,title=goal.text,
        goal=goal,type="way",onminimap=goal.onminimap,
      }
    end
    for _,extra in ipairs(goal.ways or {}) do points[#points+1]=extra end
  end
  local arrow
  for _,point in ipairs(points) do
    local waypoint=ZGV.Pointer:SetWaypoint(point.mapKey or point.map or point.m,point.x,point.y,point,false)
    if waypoint and not arrow then arrow=waypoint end
  end
  if arrow then ZGV.Pointer:ShowArrow(arrow) elseif path and path.coords and path.coords[1] then ZGV.Pointer:SetWaypointToGoal(path.coords[1]) end
  return arrow or path
end

function ZGV:ShowWaypoints(command)
  return Waypoints:Show(command)
end
