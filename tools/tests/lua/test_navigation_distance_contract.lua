local repo = assert(arg[1], "repository path is required")

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2)
  end
end

local function assertNear(actual, expected, tolerance, label)
  if type(actual) ~= "number" or math.abs(actual - expected) > tolerance then
    error(("%s: expected %.8f (+/- %.8f), got %s"):format(label, expected, tolerance, tostring(actual)), 2)
  end
end

local services = {}
local Compat = {}
function Compat:CreateService(name)
  local service = {}
  services[name] = service
  self[name] = service
  return service
end
function Compat.Pack(...) return { n = select("#", ...), ... } end
function Compat.Unpack(values, first, last) return unpack(values, first or 1, last or values.n) end
function Compat.Bool(value) return value and true or false end
function Compat:Result(ok, code, fields)
  local result = fields or {}
  result.ok = ok and true or false
  result.code = code
  return result
end
function Compat:ReportError(message) error(message, 2) end

ZygorGuidesViewer = {
  Compat = Compat,
  Data = { routes = { nodes = {}, links = {} } },
  db = {
    profile = {
      arrow = { arrival = 15 },
      navigation = { useTomTom = false, knownTaxi = {} },
      map = {},
    },
  },
  SKINDIR = "",
  StyleDir = "",
}
ZGV = ZygorGuidesViewer
function ZGV:RegisterModule(name, defaults) self[name] = defaults; return defaults end
function ZGV:RegisterEvent() end
function ZGV:AddMessageHandler() end
function ZGV:Fire() end
function ZGV:LogInfo() end
function ZGV:LogError(_, _, message) error(message, 2) end

local exactDistance
Astrolabe = {}
function Astrolabe:ComputeDistance()
  if exactDistance then return exactDistance, 3, 4 end
  return nil
end

dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/Compat/Map.lua")
local Map = assert(services.Map, "map compatibility service did not load")

local player = {
  valid = true,
  key = "zone:test",
  continent = 1,
  zone = 1,
  floor = 0,
  x = 0.5,
  y = 0.5,
}
local target = {
  key = "zone:test",
  mapKey = "zone:test",
  continent = 1,
  zone = 1,
  floor = 0,
  x = 0.501,
  y = 0.5,
  title = "Nearby objective",
}

local normalised = Map:GetDistance(player, target)
assertEqual(normalised.ok, true, "normalised fallback succeeds for bearing")
assertEqual(normalised.code, "normalised_map", "normalised fallback result code")
assertEqual(normalised.source, "normalised_map", "normalised fallback source")
assertEqual(normalised.distanceKnown, false, "normalised fallback distance is unknown")
assertEqual(normalised.distance, nil, "normalised fallback exposes no yard distance")
assertNear(normalised.normalisedDistance, 0.001, 0.0000001, "unitless normalised separation")
assertNear(normalised.xDelta, 0.001, 0.0000001, "normalised fallback x bearing")
assertNear(normalised.yDelta, 0, 0.0000001, "normalised fallback y bearing")

function Map:GetPlayerPosition() return player end
GetPlayerFacing = function() return 0 end

dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/Navigation.lua")
local Navigation = assert(ZGV.Navigation, "navigation module did not load")
Navigation.waypoint = target
Navigation.route = nil
Navigation.routeIndex = 1

ZGV.db.profile.navigation.enabled = false
local disabledState = Navigation:GetArrowState()
assertEqual(disabledState.visible, false, "disabled navigation hides the live arrow")
assertEqual(disabledState.status, "disabled", "disabled navigation has an explicit state")
ZGV.db.profile.navigation.enabled = true

ZGV.db.profile.pointer = { showWorldMap = true, showMinimap = true, showLines = false }
assertEqual(#Navigation:GetRouteLinePoints(), 0, "route-line option suppresses world-map route geometry")
ZGV.db.profile.pointer.showLines = true
assertEqual(#Navigation:GetRouteLinePoints(), 2, "same-map direct target keeps route geometry")
local savedWaypoint = Navigation.waypoint
Navigation.waypoint = {key="zone:other",mapKey="zone:other",continent=1,zone=2,x=.7,y=.7,title="Other zone"}
assertEqual(#Navigation:GetRouteLinePoints(), 1, "unrouted cross-map target has no fabricated straight line")
Navigation.waypoint = savedWaypoint

local distance, distanceResult = Navigation:GetDistance(target)
assertEqual(distance, nil, "unknown distance does not cross navigation API")
assertEqual(distanceResult.distanceKnown, false, "navigation preserves unknown-distance metadata")
assertEqual(Navigation:IsArrived(target), false, "ten-unit old approximation cannot trigger fifteen-yard arrival")

local unknownState = Navigation:GetArrowState()
assertEqual(unknownState.status, "direct", "unknown distance retains direct arrow")
assertEqual(unknownState.distanceKnown, false, "arrow reports unknown distance")
assertEqual(unknownState.distance, nil, "arrow exposes no value that UI can label as yards")
assertEqual(type(unknownState.direction), "number", "unknown distance retains world bearing")
assertEqual(type(unknownState.relative), "number", "unknown distance retains relative bearing")

-- Even if a future adapter accidentally includes an approximate numeric value,
-- the navigation boundary must continue to reject it as a yard measurement.
local realGetDistance = Map.GetDistance
function Map:GetDistance()
  return Compat:Result(true, "synthetic_unknown", {
    distance = 10,
    distanceKnown = false,
    xDelta = 0.001,
    yDelta = 0,
    source = "synthetic_unknown",
  })
end
local guardedDistance = Navigation:GetDistance(target)
assertEqual(guardedDistance, nil, "unknown numeric approximation is filtered")
assertEqual(Navigation:IsArrived(target), false, "unknown numeric approximation cannot arrive")
local guardedState = Navigation:GetArrowState()
assertEqual(guardedState.status, "direct", "guarded approximation retains direction")
assertEqual(guardedState.distance, nil, "guarded approximation cannot be shown as yards")
Map.GetDistance = realGetDistance

-- The minimap trail consumes only the valid direction; it must not disappear
-- merely because there is no yard measurement.
local realGetArrowState = Navigation.GetArrowState
local realEnsureMinimapLines = Navigation.EnsureMinimapLines
local ensuredLineCount
function Navigation:GetArrowState() return unknownState end
function Navigation:EnsureMinimapLines(count) ensuredLineCount = count end
Navigation.minimapLines = {}
Minimap = {
  GetWidth = function() return 140 end,
  GetHeight = function() return 140 end,
}
GetCVar = function() return "0" end
Navigation:UpdateMinimapLines()
assertEqual(ensuredLineCount, 1, "direction-only fallback keeps minimap heading stroke")
ZGV.db.profile.pointer.showLines = false
Navigation:UpdateMinimapLines()
assertEqual(ensuredLineCount, 0, "route-line option suppresses the minimap heading trail")
ZGV.db.profile.pointer.showLines = true
Navigation.GetArrowState = realGetArrowState
Navigation.EnsureMinimapLines = realEnsureMinimapLines

-- East is 3*pi/2 in the navigation bearing convention.  Frame offsets use
-- positive X for east, so the minimap trail must land to the right rather
-- than mirroring the direction to the left.  The 3.3.5 renderer uses a
-- bounded dot stroke instead of a rotated texture quad, which cannot change
-- its rectangular geometry on that client.
local directionState={visible=true,status="direct",direction=math.pi*1.5,relative=math.pi*1.5}
local function makeLine()
  local line={}
  function line:SetTexture(...) self.texture={...} end
  function line:SetBlendMode(mode) self.blend=mode end
  function line:SetVertexColor(...) self.color={...} end
  function line:SetWidth(value) self.width=value end
  function line:SetHeight(value) self.height=value end
  function line:ClearAllPoints() self.point=nil end
  function line:SetPoint(...) self.point={...} end
  function line:Show() self.shown=true end
  function line:Hide() self.shown=false end
  return line
end
function Navigation:GetArrowState() return directionState end
local minimapDots={}
Minimap={
  GetWidth=function() return 140 end,
  GetHeight=function() return 140 end,
  GetCenter=function() return 400,300 end,
  CreateTexture=function()
    local dot=makeLine()
    minimapDots[#minimapDots+1]=dot
    return dot
  end,
}
Navigation.minimapLines={}
Navigation.minimapPulseLines={}
Navigation.minimapPins={{
  point=target,
  IsShown=function() return true end,
  GetCenter=function() return 430,300 end,
  GetWidth=function() return 18 end,
}}
Navigation:UpdateMinimapLines()
local minimapBase=Navigation.minimapLines[1]
local minimapPulse=Navigation.minimapPulseLines[1]
assert(minimapBase.dots[1].point and minimapBase.dots[1].point[4]>0,"eastward minimap trail uses a positive X frame offset")
assert(minimapBase.dotCount>1 and minimapPulse.dotCount>0,"minimap heading stroke has black base and white directional dashes")
local lastMinimapDot=minimapBase.dots[minimapBase.dotCount]
assert(lastMinimapDot.point[4]<=19,"nearby minimap objective clamps the stroke before its icon")
Navigation.GetArrowState = realGetArrowState

-- World-map route geometry uses the same bounded dot stroke.  It must render
-- a true diagonal without relying on a rotated opaque texture rectangle.
local function makeMapLine()
  local line={}
  function line:SetTexture(...) self.texture={...} end
  function line:SetBlendMode(mode) self.blend=mode end
  function line:SetVertexColor(...) self.color={...} end
  function line:SetWidth(value) self.width=value end
  function line:SetHeight(value) self.height=value end
  function line:ClearAllPoints() self.point=nil end
  function line:SetPoint(...) self.point={...} end
  function line:Show() self.shown=true end
  function line:Hide() self.shown=false end
  return line
end
local mapLines={}
Navigation.mapOverlay={
  CreateTexture=function()
    local line=makeMapLine()
    mapLines[#mapLines+1]=line
    return line
  end,
}
WorldMapDetailFrame={
  GetWidth=function() return 512 end,
  GetHeight=function() return 512 end,
}
local realGetSelected=Map.GetSelected
function Map:GetSelected() return {key="zone:test",continent=1,zone=1} end
Navigation.mapLines={}
Navigation.mapPulseLines={}
Navigation:UpdateMapLines({
  {key="zone:test",continent=1,zone=1,x=.2,y=.2},
  {key="zone:test",continent=1,zone=1,x=.8,y=.8},
})
assertEqual(#Navigation.mapLines,1,"world route creates one base texture per segment")
assertEqual(#Navigation.mapPulseLines,1,"world route creates one highlight texture per segment")
assert(Navigation.mapLines[1].shown and Navigation.mapLines[1].dotCount>1,"world route base uses a bounded black stroke")
assert(Navigation.mapPulseLines[1].shown and Navigation.mapPulseLines[1].dotCount>0,"world route highlight uses white directional dashes")
assert(Navigation.mapLines[1].dots[1].point and Navigation.mapLines[1].dots[1].point[4]<Navigation.mapLines[1].dots[Navigation.mapLines[1].dotCount].point[4],"world route stroke follows the diagonal in frame coordinates")
Map.GetSelected=realGetSelected

exactDistance = 12
local measured = Map:GetDistance(player, target)
assertEqual(measured.ok, true, "Astrolabe measurement succeeds")
assertEqual(measured.source, "astrolabe", "Astrolabe measurement source")
assertEqual(measured.distanceKnown, true, "Astrolabe result is known yards")
assertEqual(measured.distance, 12, "Astrolabe yard distance retained")
assertEqual(measured.xDelta, 3, "Astrolabe x delta retained")
assertEqual(measured.yDelta, 4, "Astrolabe y delta retained")

local measuredDistance, measuredResult = Navigation:GetDistance(target)
assertEqual(measuredDistance, 12, "known yard distance crosses navigation API")
assertEqual(measuredResult.distanceKnown, true, "known-distance metadata crosses navigation API")
assertEqual(Navigation:IsArrived(target), true, "twelve measured yards triggers fifteen-yard arrival")
local measuredState = Navigation:GetArrowState()
assertEqual(measuredState.status, "arrived", "known nearby measurement reports arrival")
assertEqual(measuredState.distanceKnown, true, "arrived arrow marks distance known")
assertEqual(measuredState.distance, 12, "arrived arrow exposes measured yards")

print("navigation distance contract tests passed")
