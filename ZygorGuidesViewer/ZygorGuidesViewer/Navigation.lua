local ZGV=ZygorGuidesViewer
local Navigation=ZGV:RegisterModule("Navigation",{waypoint=nil,route=nil,routeIndex=1,mapPin=nil,mapPins={},minimapPins={},mapLines={},mapPulseLines={},mapLineSegments={},minimapLines={},minimapPulseLines={},markers={},externalMarkers={},zoneCache={}})

local huge=math.huge
local function navigationEnabled()
  return not (ZGV.db and ZGV.db.profile and ZGV.db.profile.navigation and ZGV.db.profile.navigation.enabled==false)
end

local function pointerOption(name)
  local pointer=ZGV.db and ZGV.db.profile and ZGV.db.profile.pointer
  return not pointer or pointer[name]~=false
end

local atan2=math.atan2 or function(y,x)
  -- Lua 5.1 has no two-argument atan fallback.  Preserve the quadrant so a
  -- client without math.atan2 cannot flip the pointer when crossing west.
  if x>0 then return math.atan(y/x) end
  if x<0 and y>=0 then return math.atan(y/x)+math.pi end
  if x<0 and y<0 then return math.atan(y/x)-math.pi end
  if y>0 then return math.pi/2 end
  if y<0 then return -math.pi/2 end
  return 0
end

function Navigation:ResolveTarget(destination)
  if type(destination)~="table" or not destination.mapKey then return nil end
  local record=ZGV.Compat.Map:Resolve(destination.mapKey)
  if not record then return nil end
  local legacy=record.legacy or record
  local zone=legacy.zone or self.zoneCache[destination.mapKey]
  if not zone and legacy.continent and legacy.mapFile then
    ZGV.Compat.Map:WithPreservedState(function()
      local result=ZGV.Compat.Map:Select(record)
      if result and result.ok then zone=result.legacyZone self.zoneCache[destination.mapKey]=zone end
    end)
  end
  return {
    key=destination.mapKey,mapKey=destination.mapKey,x=destination.x,y=destination.y,
    continent=legacy.continent,zone=zone,floor=record.floor or legacy.floor or 0,
    title=destination.title,
  }
end

function Navigation:SetWaypoint(destination,title,markers)
  local target=self:ResolveTarget(destination)
  if not target then
    self.waypoint={destination=destination,title=title,status="unresolved"}
    ZGV:Fire("ZGV_WAYPOINT_CHANGED",self.waypoint)
    return false
  end
  target.title=title or destination.title or destination.map
  self.waypoint=target
  self.markers={}
  for _,marker in ipairs(markers or {}) do
    local resolved=self:ResolveTarget(marker)
    if resolved and (resolved.key~=target.key or resolved.x~=target.x or resolved.y~=target.y) then
      resolved.title=marker.title or marker.map or "Guide location"
      self.markers[#self.markers+1]=resolved
    end
  end
  self.route=self:FindRoute(nil,target)
  self.routeIndex=1
  self:RefreshRouteProgress()
  ZGV:LogInfo("navigation","waypoint "..tostring(target.title)..(self.route and " (route found)" or " (direct)"))
  self:AddTomTom(target)
  self:UpdateMapPin()
  ZGV:Fire("ZGV_WAYPOINT_CHANGED",target)
  return true
end

function Navigation:ClearWaypoint()
  self.waypoint=nil self.route=nil self.routeIndex=1
  self.markers={}
  for _,pin in ipairs(self.mapPins or {}) do pin:Hide() end
  for _,line in ipairs(self.mapLines or {}) do line:Hide() end
  for _,line in ipairs(self.mapPulseLines or {}) do line:Hide() end
  self.mapLineSegments={}
  local astrolabe=_G.Astrolabe
  for _,line in ipairs(self.minimapLines or {}) do
    line:Hide()
  end
  for _,line in ipairs(self.minimapPulseLines or {}) do line:Hide() end
  for _,pin in ipairs(self.minimapPins or {}) do
    if astrolabe and type(astrolabe.RemoveIconFromMinimap)=="function" then pcall(astrolabe.RemoveIconFromMinimap,astrolabe,pin) end
    pin:Hide()
  end
  -- External POI/manual marker owners outlive a guide destination.  Redraw
  -- them after releasing the route so clearing an arrow never clears the
  -- world-map POI layer as a side effect.
  if next(self.externalMarkers or {}) then self:UpdateMapPin() end
  ZGV:Fire("ZGV_WAYPOINT_CHANGED",nil)
end

function Navigation:GetDistance(destination)
  local target=destination==self.waypoint and destination or self:ResolveTarget(destination)
  if not target or not target.x or not target.y then return nil end
  local player=ZGV.Compat.Map:GetPlayerPosition("player")
  if not player or not player.valid then return nil end
  local result=ZGV.Compat.Map:GetDistance(player,target)
  if not result.ok then return nil,result.code end
  -- Only measured game-yard distances may cross this public boundary.  A
  -- same-map normalised fallback can still carry a useful bearing in result,
  -- but must never look like yards to arrival checks or UI consumers.
  local distance=result.distanceKnown==true and type(result.distance)=="number" and result.distance or nil
  return distance,result,player,target
end

function Navigation:IsArrived(destination)
  local distance,result=self:GetDistance(destination)
  return type(result)=="table" and result.distanceKnown==true and type(distance)=="number"
    and distance<=(ZGV.db and ZGV.db.profile.arrow.arrival or 15) or false
end

function Navigation:IsMapTransitionComplete(transition)
  if type(transition)~="table" or not transition.mapKey then return false end
  local player=ZGV.Compat.Map:GetPlayerPosition("player")
  if not player or not player.valid or not player.key then return false end
  if transition.kind=="enter" then return player.key==transition.mapKey end
  if transition.kind=="leave" then return player.key~=transition.mapKey end
  return false
end

function Navigation:GetNavigationTarget()
  local entry=self.route and self.route.path and self.route.path[self.routeIndex or 1]
  if entry and entry.node then
    return self:ResolveTarget({
      mapKey=entry.node.mapKey,x=entry.node.x,y=entry.node.y,title=entry.node.title,
    }),entry
  end
  return self.waypoint,nil
end

local transportModes={taxi=true,boat=true,zeppelin=true,portal=true,teleport=true,enter=true,leave=true,cross=true}

-- A route can name one exact gate while the player reaches the destination
-- map through another valid entrance.  Once the client reports the new map,
-- the transition is complete regardless of which authored border coordinate
-- was crossed.  Rebuild the remainder from the live location so the next
-- instruction follows the entrance actually used instead of sending the
-- player back to the original gate.
function Navigation:GetTransportArrivalIndex(player)
  if not player or not player.key or not self.route or not self.route.path then return nil end
  for index=self.routeIndex or 1,#self.route.path do
    local entry=self.route.path[index]
    if entry and entry.node and entry.node.mapKey==player.key and transportModes[entry.mode] then
      return index
    end
  end
  return nil
end

function Navigation:RefreshRouteProgress()
  if not self.route or not self.route.path then return false end
  local changed=false
  local player=ZGV.Compat.Map:GetPlayerPosition("player")
  local arrivedByTransport=self:GetTransportArrivalIndex(player)
  if arrivedByTransport then
    local previous=self.routeIndex
    -- FindRoute reads the current live location when passed no source.  Use
    -- the captured player position instead, which avoids a selected-world-map
    -- update choosing a stale map during this transition.
    self.route=self:FindRoute(player,self.waypoint)
    self.routeIndex=1
    changed=true
    ZGV:LogInfo("navigation","route transport leg "..tostring(arrivedByTransport).." reached; replanned from "..tostring(player.key).." (was leg "..tostring(previous)..")")
    if not self.route or not self.route.path then return changed end
  end
  while self.routeIndex and self.routeIndex<=#self.route.path do
    local target=self:GetNavigationTarget()
    if not target or not self:IsArrived(target) then break end
    self.routeIndex=self.routeIndex+1
    changed=true
    ZGV:LogInfo("navigation","route leg "..tostring(self.routeIndex-1).." reached")
  end
  return changed
end

function Navigation:GetRouteInstructions()
  local instructions={}
  local route=self.route
  local function instructionText(mode,destination)
    destination=tostring(destination or "the next route point")
    -- Guide-authored movement labels already contain their verb (for example
    -- "Run up the ramp").  Prefixing them produced the visible "Run to Run
    -- up the ramp" duplication in the pointer.
    if mode=="walk" and destination:lower():match("^(run|ride|go|enter|leave|follow|climb|take|use|continue)%s") then return destination end
    local verb={
      walk="Run to ",taxi="Fly to ",boat="Take the boat to ",zeppelin="Take the zeppelin to ",
      portal="Use the portal to ",teleport="Use the teleport to ",enter="Enter ",leave="Leave ",cross="Enter ",
    }
    return (verb[mode] or "Travel to ")..destination
  end
  if route and route.path then
    for index,entry in ipairs(route.path) do
      local node=entry.node or {}
      local destination=entry.label or node.title or "the next route point"
      local mode=entry.mode or "walk"
      instructions[#instructions+1]={
        index=index,complete=index<(self.routeIndex or 1),active=index==(self.routeIndex or 1),
        mode=mode,text=instructionText(mode,destination),target=node,
      }
    end
  end
  if self.waypoint then
    instructions[#instructions+1]={
      index=#instructions+1,complete=(self.routeIndex or 1)>#instructions+1,
      active=(self.routeIndex or 1)>=(#instructions+1),mode="walk",
      text=instructionText("walk",self.waypoint.title or "the guide destination"),target=self.waypoint,
    }
  end
  return instructions
end

function Navigation:GetArrowState()
  if not navigationEnabled() then return {visible=false,status="disabled"} end
  if not self.waypoint then return {visible=false,status="none"} end
  self:RefreshRouteProgress()
  local target,entry=self:GetNavigationTarget()
  local distance,result=self:GetDistance(target)
  if type(result)~="table" or type(result.xDelta)~="number" or type(result.yDelta)~="number" then
    return {visible=true,status=self.route and "route" or "unreachable",title=(target and target.title) or self.waypoint.title,route=self.route,routeIndex=self.routeIndex}
  end
  local direction=atan2(result.xDelta or 0,-(result.yDelta or 0))
  -- Astrolabe's direction helper reflects this vector before subtracting
  -- player facing.  ComputeDistance gives raw deltas, so preserve that
  -- convention here; without the reflection east and west were reversed.
  direction=-direction
  while direction<0 do direction=direction+math.pi*2 end
  local facing=GetPlayerFacing and GetPlayerFacing() or 0
  local relative=direction-facing
  while relative>math.pi do relative=relative-math.pi*2 end
  while relative<-math.pi do relative=relative+math.pi*2 end
  local distanceKnown=result.distanceKnown==true and type(distance)=="number"
  local arrived=distanceKnown and distance<=(ZGV.db and ZGV.db.profile.arrow.arrival or 15)
  return {
    visible=true,status=arrived and "arrived" or "direct",
    distance=distanceKnown and distance or nil,distanceKnown=distanceKnown,
    direction=direction,relative=relative,title=(target and target.title) or self.waypoint.title,route=self.route,routeIndex=self.routeIndex,routeEntry=entry,
  }
end

function Navigation:AddTomTom(target)
  if not navigationEnabled() or not ZGV.db or not ZGV.db.profile.navigation.useTomTom or not TomTom or not target.zone then return end
  if type(TomTom.AddZWaypoint)=="function" then
    pcall(TomTom.AddZWaypoint,TomTom,target.continent,target.zone,target.x,target.y,target.title or "Zygor waypoint")
  elseif type(TomTom.AddWaypoint)=="function" then
    pcall(TomTom.AddWaypoint,TomTom,target.continent,target.zone,target.x,target.y,{title=target.title or "Zygor waypoint"})
  end
end

local function mapIconTexture()
  -- mapicons belongs to a skin style, rather than the global Skins directory.
  -- The old placeholder poirandomgreen texture was intentionally generic and
  -- could never match the guide viewer's selected skin.
  return (ZGV.StyleDir or ZGV.SKINDIR) .. "mapicons"
end

local function applyPinAppearance(pin, point, minimap)
  if not pin or not pin.texture then return end
  local kind = point and point.kind or "marker"
  local left, right, top, bottom = 0, .5, 0, .5
  local size = minimap and 18 or 30
  local r, g, b, a = 254 / 255, 97 / 255, 0, 1
  if kind == "player" then
    -- crosshair: right half of the top row in the upstream mapicons atlas.
    left, right, top, bottom = .5, 1, 0, .5
    size = minimap and 16 or 24
    r, g, b, a = 1, 1, 1, .8
  elseif kind == "route" then
    -- Route nodes use the small "ant" marker.  Travel modes are tinted the
    -- same way as the current Pointer implementation.
    size = minimap and 14 or 18
    r, g, b, a = 1, 1, 1, .8
    if point.routeMode == "taxi" then r, g, b = .4, 1, 0
    elseif point.routeMode == "boat" or point.routeMode == "zeppelin" then r, g, b = 0, .7, 1
    elseif point.routeMode == "portal" or point.routeMode == "teleport" then r, g, b = .8, .3, 1 end
  elseif kind == "poi" then
    -- POIs share the stable legacy atlas with guide markers.  Their colour,
    -- rather than a retail pin mixin, communicates rare/treasure state.
    size = minimap and 15 or 21
    if point.poiType == "rare" then r, g, b = 1, .25, .25 else r, g, b = 1, .82, .15 end
    if point.selected then r, g, b, size = .35, 1, .35, size+3 end
  elseif kind == "manual" then
    size = minimap and 16 or 22
    r, g, b = .35, 1, .35
  end
  pin:SetWidth(size); pin:SetHeight(size)
  pin.texture:SetTexture(mapIconTexture())
  pin.texture:SetTexCoord(left, right, top, bottom)
  pin.texture:SetVertexColor(r, g, b, a)
end

local function createPin(parent, size)
  local pin=CreateFrame("Button",nil,parent)
  pin:SetWidth(size) pin:SetHeight(size)
  -- Mapster/ElvUI put their route and quest layers well above the legacy map
  -- detail frame.  Keep guide pins above those integrations without touching
  -- either addon's frames.
  pin:SetFrameLevel((parent:GetFrameLevel() or 1)+100)
  local texture=pin:CreateTexture(nil,"OVERLAY")
  texture:SetAllPoints(pin)
  pin.texture=texture
  pin:SetScript("OnEnter",function(self)
    if self.point and GameTooltip then
      GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
      local poi=self.point.poi
      if not (poi and ZGV.Poi and ZGV.Poi.PopulateTooltip and ZGV.Poi:PopulateTooltip(GameTooltip,poi)) then
        GameTooltip:SetText(self.point.title or "Zygor waypoint")
      end
      GameTooltip:Show()
    end
  end)
  pin:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
  pin:SetScript("OnClick",function(self,button)
    if self.point and type(self.point.onClick)=="function" then
      local ok,errorMessage=pcall(self.point.onClick,self.point,button)
      if not ok then ZGV:LogError("navigation","marker click failed: "..tostring(errorMessage)) end
    end
  end)
  pin:RegisterForClicks("LeftButtonUp","RightButtonUp")
  pin:Hide()
  return pin
end

function Navigation:SetExternalMarkers(owner,points)
  owner=tostring(owner or "external")
  if type(points)~="table" or #points==0 then self.externalMarkers[owner]=nil
  else self.externalMarkers[owner]=points end
  self:UpdateMapPin()
  ZGV:Fire("ZGV_EXTERNAL_MARKERS_CHANGED",owner,self.externalMarkers[owner])
end

function Navigation:ClearExternalMarkers(owner)
  if owner then self.externalMarkers[tostring(owner)]=nil else self.externalMarkers={} end
  self:UpdateMapPin()
end

function Navigation:GetExternalMarkers()
  local result={}
  for _,points in pairs(self.externalMarkers or {}) do
    for _,point in ipairs(points) do result[#result+1]=point end
  end
  return result
end

-- A 3.3.5 Texture always owns an axis-aligned rectangle.  SetTexCoord can
-- rotate the pixels inside that rectangle, but it cannot rotate the quad
-- itself; opaque line strips therefore become large filled boxes at certain
-- angles.  Render a bounded stroke from small overlapping dots instead.  It
-- is a genuine line at every bearing and does not depend on unavailable
-- modern Line/rotation APIs.
local DOT_TEXTURE="Interface\\Buttons\\WHITE8X8"
local MAX_ROUTE_DOTS=180

local function createRouteStroke(canvas,layer,r,g,b,a,spacing)
  local stroke={canvas=canvas,layer=layer,r=r,g=g,b=b,a=a,spacing=spacing,dots={}}
  function stroke:Hide()
    for _,dot in ipairs(self.dots) do dot:Hide() end
    self.shown=false
  end
  return stroke
end

local function strokeDot(stroke,index)
  local dot=stroke.dots[index]
  if dot then return dot end
  dot=stroke.canvas:CreateTexture(nil,stroke.layer)
  dot:SetTexture(DOT_TEXTURE)
  dot:SetBlendMode("BLEND")
  dot:SetVertexColor(stroke.r,stroke.g,stroke.b,stroke.a)
  stroke.dots[index]=dot
  return dot
end

local function drawRouteLine(stroke, canvas, startX, startY, endX, endY, lineWidth, phase, relPoint)
  if not stroke or not canvas then return false end
  relPoint=relPoint or "TOPLEFT"
  lineWidth=math.max(1,tonumber(lineWidth) or 1)
  local dx,dy=endX-startX,endY-startY
  local length=math.sqrt(dx*dx+dy*dy)
  if length<.1 then stroke:Hide(); return false end
  local spacing=math.max(1,tonumber(stroke.spacing) or lineWidth*.6)
  if length/spacing+2>MAX_ROUTE_DOTS then spacing=length/(MAX_ROUTE_DOTS-2) end
  local offset=((tonumber(phase) or 0)%1)*spacing
  local position=-offset
  local used=0
  while position<=length do
    if position>=0 then
      used=used+1
      local fraction=position/length
      local dot=strokeDot(stroke,used)
      dot:SetWidth(lineWidth)
      dot:SetHeight(lineWidth)
      dot:ClearAllPoints()
      dot:SetPoint("CENTER",canvas,relPoint,startX+dx*fraction,startY+dy*fraction)
      dot:Show()
    end
    position=position+spacing
  end
  for index=used+1,#stroke.dots do stroke.dots[index]:Hide() end
  stroke.shown=used>0
  stroke.dotCount=used
  return length
end

function Navigation:CreateMapPin()
  if not WorldMapDetailFrame then return end
  self.mapPins=self.mapPins or {}
  if not self.mapOverlay then
    local overlay=CreateFrame("Frame",nil,WorldMapDetailFrame)
    overlay:SetAllPoints(WorldMapDetailFrame)
    overlay:SetFrameStrata("DIALOG")
    overlay:SetFrameLevel((WorldMapDetailFrame:GetFrameLevel() or 1)+90)
    self.mapOverlay=overlay
  end
end

function Navigation:EnsureMapPins(count)
  self:CreateMapPin()
  if not WorldMapDetailFrame then return end
  for index=#self.mapPins+1,count do
    self.mapPins[index]=createPin(WorldMapDetailFrame,30)
  end
  self.mapPin=self.mapPins[1]
end

function Navigation:EnsureMinimapPins(count)
  if not Minimap then return end
  self.minimapPins=self.minimapPins or {}
  for index=#self.minimapPins+1,count do
    self.minimapPins[index]=createPin(Minimap,18)
  end
end

function Navigation:EnsureMinimapLines(count)
  if not Minimap then return end
  self.minimapLines=self.minimapLines or {}
  self.minimapPulseLines=self.minimapPulseLines or {}
  for index=#self.minimapLines+1,count do
    local base=createRouteStroke(Minimap,"OVERLAY",.02,.02,.02,.92,3)
    local pulse=createRouteStroke(Minimap,"OVERLAY",1,1,1,.90,8)
    self.minimapLines[index]=base
    self.minimapPulseLines[index]=pulse
  end
end

function Navigation:GetMinimapTargetRadius(target)
  if not target or not Minimap or type(Minimap.GetCenter)~="function" then return nil end
  local centerX,centerY=Minimap:GetCenter()
  if type(centerX)~="number" or type(centerY)~="number" then return nil end
  for _,pin in ipairs(self.minimapPins or {}) do
    local point=pin.point
    local visible=not pin.IsShown or pin:IsShown()
    if visible and point and point.key==target.key and math.abs((point.x or 0)-(target.x or 0))<.0001 and math.abs((point.y or 0)-(target.y or 0))<.0001
      and type(pin.GetCenter)=="function" then
      local pinX,pinY=pin:GetCenter()
      if type(pinX)=="number" and type(pinY)=="number" then
        local edge=(type(pin.GetWidth)=="function" and pin:GetWidth() or 18)/2+2
        return math.max(0,math.sqrt((pinX-centerX)^2+(pinY-centerY)^2)-edge)
      end
    end
  end
  return nil
end

function Navigation:GetMapPoints()
  local points={}
  if navigationEnabled() and pointerOption("showWorldMap") then
    local player=ZGV.Compat.Map:GetPlayerPosition("player")
    if player and player.valid and player.key then
      points[#points+1]={key=player.key,mapKey=player.key,x=player.x,y=player.y,continent=player.continent,zone=player.zone,title="You",kind="player"}
    end
    local first=self.routeIndex or 1
    for index,entry in ipairs(self.route and self.route.path or {}) do
      if index>=first then
        local node=entry.node
        if node then
          local point=self:ResolveTarget({mapKey=node.mapKey,x=node.x,y=node.y,title=node.title})
          if point then point.kind="route"; point.routeMode=entry.mode; points[#points+1]=point end
        end
      end
    end
    if self.waypoint then self.waypoint.kind="waypoint"; points[#points+1]=self.waypoint end
    for _,point in ipairs(self.markers or {}) do point.kind="marker"; points[#points+1]=point end
  end
  local mapEnabled=not (ZGV.db and ZGV.db.profile and ZGV.db.profile.map and ZGV.db.profile.map.mapIcons==false)
  if mapEnabled then for _,point in ipairs(self:GetExternalMarkers()) do points[#points+1]=point end end
  return points
end

function Navigation:GetRouteLinePoints()
  local points={}
  if not navigationEnabled() or not pointerOption("showWorldMap") or not pointerOption("showLines") then return points end
  local last
  local function append(point)
    if not point or point.x==nil or point.y==nil then return end
    if last and point.key==last.key and math.abs(point.x-last.x)<.0001 and math.abs(point.y-last.y)<.0001 then return end
    points[#points+1]=point; last=point
  end
  local player=ZGV.Compat.Map:GetPlayerPosition("player")
  if player and player.valid then append(player) end
  local first=self.routeIndex or 1
  for index,entry in ipairs(self.route and self.route.path or {}) do
    if index>=first and entry.node then
      append(self:ResolveTarget({mapKey=entry.node.mapKey,x=entry.node.x,y=entry.node.y,title=entry.node.title}))
    end
  end
  append(self.waypoint)
  return points
end

function Navigation:GetMinimapPoints()
  local points={}
  if navigationEnabled() and pointerOption("showMinimap") then
    if self.waypoint then self.waypoint.kind="waypoint"; points[#points+1]=self.waypoint end
    for _,point in ipairs(self.markers or {}) do point.kind="marker"; points[#points+1]=point end
  end
  local minimapEnabled=not (ZGV.db and ZGV.db.profile and ZGV.db.profile.map and ZGV.db.profile.map.minimapIcons==false)
  if minimapEnabled then
    for _,point in ipairs(self:GetExternalMarkers()) do
      if point.onminimap then points[#points+1]=point end
    end
  end
  return points
end

function Navigation:UpdateMinimapPins()
  local points=self:GetMinimapPoints()
  self:EnsureMinimapPins(#points)
  local astrolabe=_G.Astrolabe
  for index,pin in ipairs(self.minimapPins or {}) do
    local point=points[index]
    pin.point=point
    if point and astrolabe and type(astrolabe.PlaceIconOnMinimap)=="function" and point.continent~=nil and point.x and point.y then
      applyPinAppearance(pin, point, true)
      local ok,result=pcall(astrolabe.PlaceIconOnMinimap,astrolabe,pin,point.continent,point.zone,point.x,point.y)
      if not ok or result~=0 then
        if type(astrolabe.RemoveIconFromMinimap)=="function" then pcall(astrolabe.RemoveIconFromMinimap,astrolabe,pin) end
        pin:Hide()
      end
    else
      if astrolabe and type(astrolabe.RemoveIconFromMinimap)=="function" then pcall(astrolabe.RemoveIconFromMinimap,astrolabe,pin) end
      pin:Hide()
    end
  end
end

function Navigation:UpdateMinimapLines()
  local state=self:GetArrowState()
  local target=state and self:GetNavigationTarget() or nil
  local count=0
  local angle
  if pointerOption("showMinimap") and pointerOption("showLines") and state and state.visible and type(state.direction)=="number" then
    -- A rotated minimap keeps the player facing up, so use the arrow's
    -- relative bearing.  On a north-up minimap, use its world bearing.
    local rotated=type(GetCVar)=="function" and GetCVar("rotateMinimap")~="0"
    angle=rotated and state.relative or state.direction
    if type(angle)=="number" and state.status~="arrived" then count=1 end
  end
  self:EnsureMinimapLines(count)
  local halfWidth=(Minimap and Minimap:GetWidth() or 0)/2
  local halfHeight=(Minimap and Minimap:GetHeight() or 0)/2
  local radius=math.max(18,math.min(halfWidth,halfHeight)-14)
  local innerRadius=math.min(12,math.max(7,radius*.2))
  -- Astrolabe has already positioned the direct objective pin.  When it is
  -- visible, use its actual on-screen radius instead of a fixed edge-of-map
  -- ray.  This prevents close objectives from having a line drawn beyond
  -- their icon while retaining a useful full-radius direction when the target
  -- is in another zone or is an intermediate route node.
  local targetRadius=self:GetMinimapTargetRadius(target)
  if targetRadius then radius=math.min(radius,targetRadius) end
  -- Keep the highlight moving toward the outer end of the ray.  This gives
  -- the player an immediate directional cue without a retail Line widget.
  local phase=-((type(GetTime)=="function" and GetTime() or 0)*.9)
  for index,line in ipairs(self.minimapLines or {}) do
    local pulse=self.minimapPulseLines and self.minimapPulseLines[index]
    if index<=count and angle then
      -- Navigation bearings increase clockwise with east at 3*pi/2, while
      -- frame Y offsets increase north/up.  This produces a ray pointing at
      -- the destination on both north-up and rotating minimaps.
      local x,y=-math.sin(angle),math.cos(angle)
      local length=radius-innerRadius
      if length>1 then
        drawRouteLine(line,Minimap,x*innerRadius,y*innerRadius,x*radius,y*radius,6,0,"CENTER")
        if pulse then drawRouteLine(pulse,Minimap,x*innerRadius,y*innerRadius,x*radius,y*radius,3,phase,"CENTER") end
      else
        line:Hide()
        if pulse then pulse:Hide() end
      end
    else
      line:Hide()
      if pulse then pulse:Hide() end
    end
  end
  -- Direction changes every frame while the player turns.  Keeping it in the
  -- diagnostic signature flooded SavedVariables with routine movement data.
  local signature=tostring(self.routeIndex or 0)..":"..tostring(count)
  if self.lastMinimapLineTrace~=signature then
    self.lastMinimapLineTrace=signature
    ZGV:LogInfo("navigation","minimap heading stroke="..tostring(count).." active="..signature)
  end
end

function Navigation:EnsureMapLines(count)
  if not self.mapOverlay then return end
  self.mapLines=self.mapLines or {}
  self.mapPulseLines=self.mapPulseLines or {}
  for index=#self.mapLines+1,count do
    local base=createRouteStroke(self.mapOverlay,"ARTWORK",.02,.02,.02,.90,4)
    local pulse=createRouteStroke(self.mapOverlay,"OVERLAY",1,1,1,.88,10)
    self.mapLines[index]=base
    self.mapPulseLines[index]=pulse
  end
end

function Navigation:UpdateMapLinePulse()
  if not self.mapOverlay then return end
  local phase=-((type(GetTime)=="function" and GetTime() or 0)*.9)
  for index,line in ipairs(self.mapPulseLines or {}) do
    local segment=self.mapLineSegments and self.mapLineSegments[index]
    if segment then
      -- Offset each segment by the distance before it, so the moving pattern
      -- remains continuous around turns in a multi-node route.
      drawRouteLine(line,self.mapOverlay,segment.x1,segment.y1,segment.x2,segment.y2,3,phase+(segment.offset/18),"TOPLEFT")
    else
      line:Hide()
    end
  end
end

function Navigation:UpdateMapLines(points)
  if not self.mapOverlay or not WorldMapDetailFrame then return end
  local astrolabe=_G.Astrolabe
  local translated={}
  local current=ZGV.Compat.Map:GetSelected()
  for index,point in ipairs(points) do
    local x,y
    if astrolabe and type(astrolabe.TranslateWorldMapPosition)=="function" then
      local ok,px,py=pcall(astrolabe.TranslateWorldMapPosition,astrolabe,point.continent,point.zone,point.x,point.y,current.continent,current.zone)
      if ok then x,y=px,py end
    elseif current.key==point.key then x,y=point.x,point.y end
    translated[index]=(x and y and x>0 and x<=1 and y>0 and y<=1) and {x=x,y=y} or nil
  end

  local width,height=WorldMapDetailFrame:GetWidth(),WorldMapDetailFrame:GetHeight()
  local segments={}
  local offset=0
  for index=1,#translated-1 do
    local first,second=translated[index],translated[index+1]
    if first and second then
      local x1,y1=first.x*width,-first.y*height
      local x2,y2=second.x*width,-second.y*height
      local dx,dy=x2-x1,y2-y1
      local length=math.sqrt(dx*dx+dy*dy)
      if length>1 then
        segments[#segments+1]={x1=x1,y1=y1,x2=x2,y2=y2,length=length,offset=offset}
        offset=offset+length
      end
    end
  end
  self.mapLineSegments=segments
  self:EnsureMapLines(#segments)
  for index,line in ipairs(self.mapLines or {}) do
    local segment=segments[index]
    if segment then
      drawRouteLine(line,self.mapOverlay,segment.x1,segment.y1,segment.x2,segment.y2,7,0,"TOPLEFT")
    else
      line:Hide()
    end
  end
  self:UpdateMapLinePulse()
  local signature=tostring(current.continent)..":"..tostring(current.zone)..":"..tostring(current.key)
    ..":"..tostring(#segments)..":"..tostring(self.routeIndex or 0)
  if self.lastWorldLineTrace~=signature then
    self.lastWorldLineTrace=signature
    ZGV:LogInfo("navigation","world route strokes="..tostring(#segments).." map="..signature)
  end
end

function Navigation:_UpdateMapPin()
  local points=self:GetMapPoints()
  self:EnsureMapPins(#points)
  self:UpdateMinimapPins()
  self:UpdateMinimapLines()
  if not WorldMapDetailFrame then return end
  local astrolabe=_G.Astrolabe
  local selected=ZGV.Compat.Map:GetSelected()
  for index,pin in ipairs(self.mapPins or {}) do
    local point=points[index]
    pin.point=point
    if point then
      applyPinAppearance(pin, point, false)
      local placed=false
      if astrolabe and type(astrolabe.PlaceIconOnWorldMap)=="function" and point.continent~=nil and point.x and point.y then
        local ok,px,py=pcall(astrolabe.PlaceIconOnWorldMap,astrolabe,WorldMapDetailFrame,pin,point.continent,point.zone,point.x,point.y)
        placed=ok and px and py and true or false
      elseif selected.key==point.key then
        pin:ClearAllPoints(); pin:SetPoint("CENTER",WorldMapDetailFrame,"TOPLEFT",point.x*WorldMapDetailFrame:GetWidth(),-point.y*WorldMapDetailFrame:GetHeight()); pin:Show(); placed=true
      end
      if not placed then pin:Hide() end
    else pin:Hide() end
  end
  -- Quest-area markers are deliberately not route vertices.  Connecting them
  -- produced false zig-zags across the map; draw only player → route → target.
  self:UpdateMapLines(self:GetRouteLinePoints())
  -- One compact record per meaningful map/route change gives us actionable
  -- diagnostics after the client writes SavedVariables on reload or logout.
  local signature=tostring(selected.continent)..":"..tostring(selected.zone)..":"..tostring(selected.key)
    ..":"..tostring(#points)..":"..tostring(self.routeIndex or 0)
  if self.lastMapTrace~=signature then
    self.lastMapTrace=signature
    ZGV:LogInfo("navigation","map overlay selected="..signature.." route="..tostring(self.route and "yes" or "no"))
  end
end

-- Astrolabe changes the selected map while placing a pin on 3.3.5.  That
-- emits WORLD_MAP_UPDATE synchronously, which used to invoke this method
-- again until the client exhausted its C stack.  Keep the entire placement
-- transaction atomic and report a single useful diagnostic if it fails.
function Navigation:UpdateMapPin()
  if self.updatingMap then return false, "map_update_in_progress" end
  self.updatingMap=true
  local ok,result=pcall(self._UpdateMapPin,self)
  self.updatingMap=nil
  if not ok then
    ZGV:LogError("navigation","map pin update failed: "..tostring(result))
    return false,result
  end
  return true
end

local function allowed(link)
  local faction=UnitFactionGroup("player")
  return not link[5] or link[5]==faction
end

function Navigation:FindRoute(from,to)
  local data=ZGV.Data.routes
  if not data or not to then return nil end
  local player=from or ZGV.Compat.Map:GetPlayerPosition("player")
  if not player or not player.key then return nil end
  -- Route assembly adds character-specific taxi vertices below.  Never write
  -- them into the shared data set: a second character can know a different
  -- set of flight paths in the same client profile.
  local nodes={}
  for key,node in pairs(data.nodes or {}) do nodes[key]=node end
  local links=data.links or {}
  local function normalizedDistance(a,b)
    if not a or not b or a.x==nil or a.y==nil or b.x==nil or b.y==nil then return huge end
    local dx,dy=tonumber(a.x)-tonumber(b.x),tonumber(a.y)-tonumber(b.y)
    return math.sqrt(dx*dx+dy*dy)
  end
  -- High-confidence city/ramp approaches replace only the final straight
  -- edge.  This is deliberately data-driven: 3.3.5a has no navmesh API, so
  -- an addon must use authored corridor coordinates for walls and elevation.
  local approach
  for _,candidate in ipairs(data.approaches or {}) do
    local node=nodes[candidate.node]
    if candidate.mapKey==to.key and node and normalizedDistance(node,to)<=tonumber(candidate.radius or 0) then
      approach=candidate
      break
    end
  end
  -- Use the same corridor on departure.  Without this, a route from an
  -- elevated city terrace to another zone could attach START directly to a
  -- gate, reintroducing the through-wall/through-cliff arrow in reverse.
  local sourceApproach
  if not approach and player.key~=to.key then
    for _,candidate in ipairs(data.approaches or {}) do
      if candidate.mapKey==player.key then
        local closest=huge
        for _,key in ipairs(candidate.corridor or {}) do
          local node=nodes[key]
          if node then closest=math.min(closest,normalizedDistance(player,node)) end
        end
        if closest<=.14 then sourceApproach=candidate break end
      end
    end
  end
  local graph={}
  local function edge(a,b,cost,mode,label)
    graph[a]=graph[a] or {}
    graph[a][#graph[a]+1]={to=b,cost=cost,mode=mode,label=label}
  end
  for i=1,#links do
    local link=links[i]
    if allowed(link) then
      edge(link[1],link[2],link[4],link[3],link[7])
      edge(link[2],link[1],link[4],link[6] or link[3],link[8])
    end
  end
  graph.START={} graph.FINISH={}
  local finishLinks=0
  local function localCost(a,b)
    if not a or not b or a.x==nil or a.y==nil or b.x==nil or b.y==nil then return 30 end
    local dx,dy=tonumber(a.x)-tonumber(b.x),tonumber(a.y)-tonumber(b.y)
    -- Map-normalized distance is only used to select among exits on the same
    -- map; it intentionally cannot make an inter-zone border cheaper than a
    -- nearby route node.
    return math.max(3,math.sqrt(dx*dx+dy*dy)*100)
  end
  -- The client exposes the player's discovered taxi destinations only while
  -- a taxi map is opened.  Compat.Taxi persists those discoveries and joins
  -- them to Data-WotLK/TaxiNodes.lua here.  Treat every learned source and
  -- destination on the same world continent as a selectable flight; the
  -- server itself handles intermediate flight stops for a selected endpoint.
  local taxiSources,taxiDestinations={},{}
  local taxi=ZGV.Compat and ZGV.Compat.Taxi
  if player.key~=to.key and taxi and type(taxi.GetKnownStaticNodes)=="function" then
    local function taxiContinent(mapKey)
      local record=ZGV.Compat.Map:Resolve(mapKey)
      local legacy=record and (record.legacy or record)
      return legacy and legacy.continent
    end
    local sourceContinent=taxiContinent(player.key)
    local destinationContinent=taxiContinent(to.key)
    if sourceContinent and sourceContinent==destinationContinent then
      for _,taxiNode in ipairs(taxi:GetKnownStaticNodes()) do
        local mapKey=taxiNode.mapKey
        if mapKey and taxiContinent(mapKey)==sourceContinent and taxiNode.x and taxiNode.y then
          local key="_taxi_"..tostring(taxiNode.key or (mapKey..":"..tostring(taxiNode.name)))
          nodes[key]={
            mapKey=mapKey,x=taxiNode.x,y=taxiNode.y,
            title=taxiNode.title or ((taxiNode.name or "Flight Master").." Flight Master"),
            taxi=true,
          }
          if mapKey==player.key then taxiSources[#taxiSources+1]=key end
          if mapKey==to.key then taxiDestinations[#taxiDestinations+1]=key end
        end
      end
      -- The fixed value represents boarding/flying overhead in the route
      -- scorer.  Local walking distance to/from the known flight masters is
      -- still included by the normal START/FINISH edges, so a distant flight
      -- master is not preferred over a nearby legal ground route.
      for _,source in ipairs(taxiSources) do
        for _,destination in ipairs(taxiDestinations) do
          if source~=destination then edge(source,destination,25,"taxi") end
        end
      end
    end
  end
  local nearestCorridor
  local startApproach=approach or sourceApproach
  if startApproach and player.key==startApproach.mapKey then
    for _,key in ipairs(startApproach.corridor or {}) do
      local node=nodes[key]
      if node then
        local distance=normalizedDistance(player,node)
        if not nearestCorridor or distance<nearestCorridor.distance then nearestCorridor={key=key,distance=distance} end
      end
    end
  end
  for key,node in pairs(nodes) do
    if node.mapKey==player.key and (not nearestCorridor or key==nearestCorridor.key) then
      edge("START",key,localCost(player,node),"walk")
    end
    if node.mapKey==to.key and (not approach or key==approach.node) then
      edge(key,"FINISH",localCost(node,to),"walk") finishLinks=finishLinks+1
    end
  end
  if player.key==to.key and not approach then
    edge("START","FINISH",localCost(player,to),"walk")
    finishLinks=finishLinks+1
  end
  if #graph.START==0 or finishLinks==0 then return nil end
  local distance,previous,visited={START=0},{},{}
  while true do
    local current,best=nil,huge
    for key,value in pairs(distance) do if not visited[key] and value<best then current,best=key,value end end
    if not current or current=="FINISH" then break end
    visited[current]=true
    for _,candidate in ipairs(graph[current] or {}) do
      local value=best+candidate.cost
      if value<(distance[candidate.to] or huge) then
        distance[candidate.to]=value
        previous[candidate.to]={node=current,mode=candidate.mode,label=candidate.label}
      end
    end
  end
  if not distance.FINISH then return nil end
  local path={} local current="FINISH"
  while current and current~="START" do
    local prior=previous[current]
    if not prior then break end
    if current~="FINISH" then table.insert(path,1,{key=current,node=nodes[current],mode=prior.mode,label=prior.label}) end
    current=prior.node
  end
  return {path=path,cost=distance.FINISH,from=player.key,to=to.key}
end

function Navigation:OnTaxiCache(snapshot)
  if ZGV.db and snapshot then
    local known=ZGV.db.profile.navigation.knownTaxi
    for key,node in pairs(ZGV.Compat.Taxi.known or {}) do known[key]={name=node.name,map=node.map and node.map.key,x=node.x,y=node.y} end
  end
end

function Navigation:OnStartup()
  self:CreateMapPin()
  if type(hooksecurefunc)=="function" and type(WorldMapFrame_Update)=="function" then
    hooksecurefunc("WorldMapFrame_Update",function() Navigation:UpdateMapPin() end)
  end
  if ZGV.Compat and ZGV.Compat.On then ZGV.Compat:On("TAXI_CACHE_UPDATED",self,"OnTaxiCache") end
  if ZGV.Compat and ZGV.Compat.Timer then
    self.ticker=ZGV.Compat.Timer:NewTicker(.1,function()
      if Navigation.waypoint then
        if Navigation:RefreshRouteProgress() then Navigation:UpdateMapPin() end
        local now=GetTime()
        -- Animation is intentionally cheap: geometry is refreshed less often,
        -- while only the highlight texture coordinates advance every tick.
        Navigation:UpdateMinimapLines()
        if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
          Navigation:UpdateMapLinePulse()
        end
        if now-(Navigation.lastLineRefresh or 0)>=.35 then
          Navigation.lastLineRefresh=now
          if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
            Navigation:UpdateMapLines(Navigation:GetRouteLinePoints())
          end
        end
        ZGV:Fire("ZGV_ARROW_UPDATED",Navigation:GetArrowState())
      end
    end)
  end
end

function Navigation:OnMapEvent()
  if (not self.waypoint and not next(self.externalMarkers or {})) or self.updatingMap then return end
  -- Defer updates triggered by the client's own map-selection calls.  The
  -- final update runs after Astrolabe has restored the map state, so pins and
  -- the route stroke are calculated from one stable map rather than a mix of
  -- temporary selections.
  if self.mapRefreshQueued then return end
  self.mapRefreshQueued=true
  local function refresh()
    Navigation.mapRefreshQueued=nil
    if Navigation.waypoint or next(Navigation.externalMarkers or {}) then Navigation:UpdateMapPin() end
  end
  if ZGV.Compat and ZGV.Compat.Timer then ZGV.Compat.Timer:NewTimer(0,refresh)
  else refresh() end
end

ZGV:RegisterEvent("WORLD_MAP_UPDATE",Navigation,"OnMapEvent")
ZGV:AddMessageHandler("SKIN_UPDATED",function()
  if Navigation.waypoint then Navigation:UpdateMapPin() end
end)

-- Extension surface retained for guide code and integrations that expect a
-- LibRover object. The implementation is intentionally native to build 12340.
ZGV.LibRover=ZGV.LibRover or {}
ZGV.LibRover.data=ZGV.Data.routes
function ZGV.LibRover:FindRoute(from,to) return Navigation:FindRoute(from,to) end
function ZGV.LibRover:GetPlayerPosition()
  local player=ZGV.Compat.Map:GetPlayerPosition("player")
  if not player or not player.valid then return 0,0,0 end
  local record=ZGV.Compat.Map:Resolve(player.key)
  local anniversary=record and record.anniversary
  return player.x or 0,player.y or 0,(anniversary and anniversary.uiMapID) or player.key
end
function ZGV.LibRover:CanFlyAt()
  -- 3.3.5a exposes no per-map flying query.  Returning the learned riding
  -- capability is conservative; route selection itself does not create
  -- free-flight edges, so this cannot produce an impossible route.
  if type(IsSpellKnown)~="function" then return false end
  return IsSpellKnown(34090) or IsSpellKnown(34091) or IsSpellKnown(54197) or false
end
_G.LibRover=ZGV.LibRover
