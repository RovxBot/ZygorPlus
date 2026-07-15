-- Build-12340 coordinate compatibility.  The old implementation depended on
-- C_Map and modern UI-map transforms; this version delegates to the checked-in
-- legacy-map registry and Astrolabe instead.
local ZGV=ZygorGuidesViewer
if not ZGV or not ZGV.Compat then return end

local MapCoords=ZGV:RegisterModule("MapCoords",{MAPDATA={},buttonsReady=false})
ZGV.MapCoords=MapCoords
local Map=ZGV.Compat.Map

local atan2=math.atan2 or function(y,x)
  if x>0 then return math.atan(y/x) end
  if x<0 and y>=0 then return math.atan(y/x)+math.pi end
  if x<0 then return math.atan(y/x)-math.pi end
  return y>=0 and math.pi/2 or -math.pi/2
end

local function trim(value) return tostring(value or ""):gsub("^%s+",""):gsub("%s+$","") end

local function resolve(value,floor)
  if type(value)=="table" then return Map:Resolve(value) end
  if type(value)=="number" then
    local found=Map:Resolve(value)
    if found then return found end
  end
  local key=ZGV:CanonicalMapKey(value,floor)
  return Map:Resolve(key) or Map:Resolve(value)
end

local function legacyPosition(record)
  if not record then return nil end
  local captured=Map:CaptureState()
  local selected=Map:Select(record)
  local state=Map:CaptureState()
  Map:RestoreState(captured)
  if not selected.ok then return nil end
  return state.continent,state.zone,state.floor or 0
end

function ZGV.GetPlayerPosition()
  local position=Map:GetPlayerPosition("player")
  if not position or not position.valid then return 0,0,0 end
  return position.x or 0,position.y or 0,position.key or 0
end

function ZGV.GetCurrentMapID()
  return Map:GetSelected().key
end

function ZGV.GetCurrentMapContinent()
  return Map:GetSelected().continent
end

function ZGV.GetCurrentMapDungeonLevel()
  return Map:GetSelected().floor or 0
end

function ZGV.GetMapInfo(mapID)
  local record=resolve(mapID)
  if not record then return nil end
  local legacy=record.legacy or {}
  return {
    mapID=record.anniversary and record.anniversary.uiMapID or mapID,
    name=record.name,key=record.key,floor=record.floor or legacy.floor or 0,
    continent=legacy.continent,mapFile=legacy.mapFile,instanceID=legacy.instanceID,
    mapType=legacy.instanceID and "instance" or (legacy.continent==0 and "world" or "zone"),
  }
end

function ZGV.GetMapContinent(mapID)
  local info=ZGV.GetMapInfo(mapID)
  return info and info.continent
end

function ZGV.GetMapNameByID(mapID,floor)
  local record=resolve(mapID,floor)
  return record and record.name
end

function ZGV.GetMapFloorNameByID(mapID,floor)
  local record=resolve(mapID,floor)
  if not record then return nil end
  return record.name..((record.floor or 0)>0 and ("/"..record.floor) or "")
end

function ZGV.GetMapGroupID(mapID,floor)
  local record=resolve(mapID,floor)
  return record and (record.legacy and record.legacy.instanceID or record.legacy and record.legacy.continent)
end

function ZGV.GetMapChildren(mapID,results)
  results=results or {}
  local parent=resolve(mapID)
  if not parent then return results end
  local parentContinent=parent.legacy and parent.legacy.continent
  for key,record in pairs(Map:GetRegistry()) do
    local legacy=record.legacy or {}
    if key~=parent.key and parentContinent and legacy.continent==parentContinent and not legacy.instanceID then results[key]=record end
  end
  return results
end

function ZGV.GetAllContinents()
  local result={}
  for key,record in pairs(Map:GetRegistry()) do
    local legacy=record.legacy or {}
    if not legacy.instanceID and (record.name=="Kalimdor" or record.name=="Eastern Kingdoms" or record.name=="Outland" or record.name=="Northrend") then result[key]=record end
  end
  return result
end

function ZGV.MapsOnDifferentFloors(first,second)
  local one,two=resolve(first),resolve(second)
  return one and two and one.name==two.name and (one.floor or 0)~=(two.floor or 0) or false
end

function MapCoords.Mdist(mapOne,xOne,yOne,mapTwo,xTwo,yTwo,keepSquared)
  local one,two=resolve(mapOne),resolve(mapTwo)
  if not (one and two and xOne and yOne and xTwo and yTwo) then return nil end
  local c1,z1=legacyPosition(one)
  local c2,z2=legacyPosition(two)
  local astrolabe=_G.Astrolabe
  if astrolabe and c1 and z1 and c2 and z2 and type(astrolabe.ComputeDistance)=="function" then
    local ok,distance=pcall(astrolabe.ComputeDistance,astrolabe,c1,z1,xOne,yOne,c2,z2,xTwo,yTwo)
    if ok and distance then return keepSquared and distance*distance or distance end
  end
  if one.key~=two.key then return nil end
  local dx,dy=xOne-xTwo,yOne-yTwo
  local squared=dx*dx+dy*dy
  return keepSquared and squared or math.sqrt(squared)
end

function MapCoords.Mangle(...)
  local arguments={...}
  local mapOne,xOne,yOne,mapTwo,xTwo,yTwo=arguments[1],arguments[2],arguments[3],arguments[4],arguments[5],arguments[6]
  local one,two=resolve(mapOne),resolve(mapTwo)
  if not (one and two) then return nil end
  if one.key~=two.key then
    local tx,ty=MapCoords.Mxlt(mapTwo,xTwo,yTwo,mapOne,true)
    if not tx then return nil end
    xTwo,yTwo=tx,ty
  end
  return atan2((xTwo or 0)-(xOne or 0),(yOne or 0)-(yTwo or 0))
end

function MapCoords.Mxlt(mapOne,x,y,mapTwo,outOfBounds)
  local from,to=resolve(mapOne),resolve(mapTwo)
  if not (from and to and x and y) then return nil end
  if from.key==to.key then return x,y end
  local c1,z1=legacyPosition(from)
  local c2,z2=legacyPosition(to)
  local astrolabe=_G.Astrolabe
  if astrolabe and c1 and z1 and c2 and z2 and type(astrolabe.TranslateWorldMapPosition)=="function" then
    local ok,tx,ty=pcall(astrolabe.TranslateWorldMapPosition,astrolabe,c1,z1,x,y,c2,z2)
    if ok and tx and ty and (outOfBounds or (tx>=0 and tx<=1 and ty>=0 and ty<=1)) then return tx,ty end
  end
  return nil
end

function MapCoords:Format(x,y)
  if x==nil or y==nil then return "--, --" end
  return string.format("%.1f, %.1f",x*100,y*100)
end

function MapCoords:UpdateCoordinateFrame()
  local frame=self.coordinateFrame
  if not frame or not frame:IsShown() then return end
  local player=Map:GetPlayerPosition("player",{keepMap=true})
  frame.player:SetText("Player: "..self:Format(player and player.x,player and player.y))
  local detail=WorldMapDetailFrame
  local cx,cy
  if detail and detail:IsShown() and GetCursorPosition then
    local px,py=GetCursorPosition()
    local scale=detail:GetEffectiveScale() or 1
    local left,top,width,height=detail:GetLeft(),detail:GetTop(),detail:GetWidth(),detail:GetHeight()
    if left and top and width>0 and height>0 then
      cx=(px/scale-left)/width cy=(top-py/scale)/height
      if cx<0 or cx>1 or cy<0 or cy>1 then cx,cy=nil,nil end
    end
  end
  frame.cursor:SetText("Cursor: "..self:Format(cx,cy))
end

function MapCoords:HandleWorldmapCoords()
  local enabled=ZGV.db and ZGV.db.profile and ZGV.db.profile.map and ZGV.db.profile.map.showCoords
  if not enabled then if self.coordinateFrame then self.coordinateFrame:Hide() end return end
  if not WorldMapDetailFrame then return end
  if not self.coordinateFrame then
    local frame=CreateFrame("Frame",nil,WorldMapDetailFrame)
    frame:SetWidth(210) frame:SetHeight(18)
    frame:SetPoint("BOTTOM",WorldMapDetailFrame,"BOTTOM",0,5)
    local player=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall") player:SetPoint("LEFT") frame.player=player
    local cursor=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall") cursor:SetPoint("RIGHT") frame.cursor=cursor
    frame:SetScript("OnUpdate",function(_,elapsed)
      MapCoords.coordElapsed=(MapCoords.coordElapsed or 0)+elapsed
      if MapCoords.coordElapsed>=.05 then MapCoords.coordElapsed=0 MapCoords:UpdateCoordinateFrame() end
    end)
    self.coordinateFrame=frame
  end
  self.coordinateFrame:Show()
end

function MapCoords:SetupMapButtons()
  if self.buttonsReady or not WorldMapDetailFrame then return end
  local button=CreateFrame("Button","ZygorWorldMapPoiButton",WorldMapDetailFrame,"UIPanelButtonTemplate")
  button:SetWidth(56) button:SetHeight(20) button:SetPoint("TOPRIGHT",WorldMapDetailFrame,"TOPRIGHT",-7,-7) button:SetText("POI")
  button:SetScript("OnClick",function(_,mouse)
    if mouse=="RightButton" then return ZGV:OpenOptions("maps") end
    if ZGV.Poi then ZGV.Poi:ChangeState(not ZGV.Poi.enabled) end
  end)
  button:RegisterForClicks("LeftButtonUp","RightButtonUp")
  button:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT") GameTooltip:SetText("Toggle guide points of interest. Right-click for map settings.") GameTooltip:Show()
  end)
  button:SetScript("OnLeave",function() GameTooltip:Hide() end)
  self.poiButton=button self.buttonsReady=true
end

function MapCoords:OnStartup()
  self:SetupMapButtons()
  self:HandleWorldmapCoords()
end

function MapCoords:OnMapEvent()
  self:SetupMapButtons()
  self:HandleWorldmapCoords()
end

ZGV:RegisterEvent("WORLD_MAP_UPDATE",MapCoords,"OnMapEvent")
