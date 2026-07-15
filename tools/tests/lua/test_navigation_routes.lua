local repo = assert(arg[1], "repository path is required")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error((label or "values differ")..": expected "..tostring(expected)..", got "..tostring(actual), 2) end
end

local Compat = {}
local player
local map = {}
function map:Resolve(key)
  if type(key) == "table" then return key end
  return {key=key,legacy={continent=3}}
end
function map:GetPlayerPosition() return player end
function map:GetDistance()
  return {ok=true,distanceKnown=false,xDelta=0,yDelta=0}
end

local taxiNodes={
  {key="allerian",mapKey="Terokkar Forest/0",name="Allerian Stronghold",title="Allerian Stronghold Flight Master",x=.5945,y=.5543},
  {key="shattrath",mapKey="Shattrath City/0",name="Shattrath",title="Shattrath Flight Master",x=.6407,y=.4112},
}
Compat.Map=map
Compat.Taxi={GetKnownStaticNodes=function() return taxiNodes end}

ZygorGuidesViewer={
  Compat=Compat,
  Data={routes={
    nodes={
      terokkar_gate={mapKey="Terokkar Forest/0",x=.360,y=.319,title="Shattrath City Gate"},
      shattrath_gate={mapKey="Shattrath City/0",x=.762,y=.773,title="Shattrath City Gate"},
    },
    links={{"terokkar_gate","shattrath_gate","enter",38,nil,"leave"}},
  }},
  db={profile={arrow={arrival=15},navigation={enabled=true,knownTaxi={}}}},
}
ZGV=ZygorGuidesViewer
function ZGV:RegisterModule(name, defaults) self[name]=defaults return defaults end
function ZGV:RegisterEvent() end
function ZGV:AddMessageHandler() end
function ZGV:Fire() end
function ZGV:LogInfo() end
function ZGV:LogError(_, _, message) error(message, 2) end
UnitFactionGroup=function() return "Alliance" end

dofile(repo.."/ZygorGuidesViewerNew/ZygorGuidesViewer/Navigation.lua")
local Navigation=assert(ZGV.Navigation,"navigation module did not load")

-- A known taxi in both the current and target zone must produce the two
-- explicit actions expected by the arrow: reach the flight master, then fly.
player={key="Terokkar Forest/0",valid=true,x=.59,y=.55}
local route=assert(Navigation:FindRoute(nil,{key="Shattrath City/0",x=.60,y=.42,title="Shattrath objective"}),"known taxi route was not found")
assertEqual(#route.path,2,"taxi route vertex count")
assertEqual(route.path[1].mode,"walk","taxi route starts by walking to the flight master")
assertEqual(route.path[2].mode,"taxi","taxi route includes a flight action")
assertEqual(route.path[2].node.mapKey,"Shattrath City/0","taxi lands in the target map")

-- Route originally chose the western Shattrath gate.  Entering through a
-- different gate still changes the live map to Shattrath, so navigation must
-- consume the map-transition leg and rebuild from the actual arrival point.
Navigation.route={
  path={
    {key="terokkar_gate",node=ZGV.Data.routes.nodes.terokkar_gate,mode="walk"},
    {key="shattrath_gate",node=ZGV.Data.routes.nodes.shattrath_gate,mode="enter"},
  },
}
Navigation.routeIndex=1
Navigation.waypoint={key="Shattrath City/0",mapKey="Shattrath City/0",x=.53,y=.37,title="Terrace of Light"}
player={key="Shattrath City/0",valid=true,x=.88,y=.45}
assertEqual(Navigation:RefreshRouteProgress(),true,"alternate city entrance triggers a route refresh")
assertEqual(Navigation.route.from,"Shattrath City/0","route is rebuilt from the entered city")
assertEqual(#Navigation.route.path,0,"stale authored gate is discarded after city arrival")

print("navigation taxi and city-arrival tests passed")
