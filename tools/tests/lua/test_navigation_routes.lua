local repo = assert(arg[1], "repository path is required")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error((label or "values differ")..": expected "..tostring(expected)..", got "..tostring(actual), 2) end
end

local Compat = {}
local player
local map = {}
local continents={
  ["Terokkar Forest/0"]=3,["Shattrath City/0"]=3,
  ["Elwynn Forest/0"]=2,["Stormwind City/0"]=2,
  ["Borean Tundra/0"]=4,["Dragonblight/0"]=4,["Unlinked Zone/0"]=1,["Remote Zone/0"]=1,
  ["Nagrand/0"]=3,["Zangarmarsh/0"]=3,["Blade's Edge Mountains/0"]=3,
}
function map:Resolve(key)
  if type(key) == "table" then return key end
  return {key=key,legacy={continent=continents[key] or 3}}
end
function map:GetPlayerPosition() return player end
function map:GetDistance()
  return {ok=true,distanceKnown=false,xDelta=0,yDelta=0}
end

local taxiNodes={
  {key="allerian",mapKey="Terokkar Forest/0",name="Allerian Stronghold",title="Allerian Stronghold Flight Master",x=.5945,y=.5543},
  {key="shattrath",mapKey="Shattrath City/0",name="Shattrath",title="Shattrath Flight Master",x=.6407,y=.4112},
  {key="goldshire",mapKey="Elwynn Forest/0",name="Goldshire",title="Goldshire Flight Master",x=.42,y=.66},
  {key="stormwind",mapKey="Stormwind City/0",name="Stormwind",title="Stormwind Flight Master",x=.66,y=.62},
  {key="valiance",mapKey="Borean Tundra/0",name="Valiance Keep",title="Valiance Keep Flight Master",x=.58,y=.68},
  {key="wyrmrest",mapKey="Dragonblight/0",name="Wyrmrest Temple",title="Wyrmrest Temple Flight Master",x=.60,y=.55},
  {key="garadar",mapKey="Nagrand/0",name="Garadar",title="Garadar Flight Master",x=.5719,y=.3525},
  {key="zabrajin",mapKey="Zangarmarsh/0",name="Zabra'jin",title="Zabra'jin Flight Master",x=.3307,y=.5107},
}
Compat.Map=map
Compat.Taxi={GetKnownStaticNodes=function() return taxiNodes end}

ZygorGuidesViewer={
  Compat=Compat,
  Data={Taxi=taxiNodes,routes={
    nodes={
      terokkar_gate={mapKey="Terokkar Forest/0",x=.360,y=.319,title="Shattrath City Gate"},
      shattrath_gate={mapKey="Shattrath City/0",x=.762,y=.773,title="Shattrath City Gate"},
      stormwind_harbor={mapKey="Stormwind City/0",x=.184,y=.254,title="Stormwind Harbor"},
      valiance_dock={mapKey="Borean Tundra/0",x=.590,y=.684,title="Valiance Keep"},
      nagrand_blade={mapKey="Nagrand/0",x=.285,y=.060,title="Border to Blade's Edge Mountains"},
      blade_nagrand={mapKey="Blade's Edge Mountains/0",x=.285,y=.939,title="Border to Nagrand"},
      blade_zangar={mapKey="Blade's Edge Mountains/0",x=.520,y=.988,title="Border to Zangarmarsh"},
      zangar_blade={mapKey="Zangarmarsh/0",x=.687,y=.329,title="Border to Blade's Edge Mountains"},
    },
    links={
      {"terokkar_gate","shattrath_gate","enter",38,nil,"leave"},
      {"stormwind_harbor","valiance_dock","boat",120,"Alliance"},
      {"nagrand_blade","blade_nagrand","cross",38},
      {"blade_zangar","zangar_blade","cross",38},
    },
    portkeys={
      {item=6948,destination="_HEARTH",cost=80,mode="hearth"},
      {spell=556,destination="_HEARTH",cost=20,mode="hearth",isAstral=true},
    },
  }},
  db={profile={arrow={arrival=15},navigation={enabled=true,knownTaxi={}}}},
}
ZGV=ZygorGuidesViewer
function ZGV:RegisterModule(name, defaults) self[name]=defaults return defaults end
function ZGV:RegisterEvent() end
function ZGV:RegisterCallback() end
function ZGV:AddMessageHandler() end
function ZGV:Fire() end
function ZGV:LogInfo() end
function ZGV:LogError(_, _, message) error(message, 2) end
UnitFactionGroup=function() return "Alliance" end
GetBindLocation=function() return "Stormwind" end
GetItemCount=function(item) return item==6948 and 1 or 0 end
IsUsableItem=function() return true end
GetItemCooldown=function() return 0,0,1 end
IsSpellKnown=function(spell) return spell==556 end
IsUsableSpell=function() return true end
GetSpellCooldown=function() return 0,0,1 end
GetTime=function() return 100 end

dofile(repo.."/ZygorGuidesViewer/ZygorGuidesViewer/Navigation.lua")
local Navigation=assert(ZGV.Navigation,"navigation module did not load")

-- A known taxi in both the current and target zone must produce the two
-- explicit actions expected by the arrow: reach the flight master, then fly.
player={key="Terokkar Forest/0",valid=true,x=.59,y=.55}
local route=assert(Navigation:FindRoute(nil,{key="Shattrath City/0",x=.60,y=.42,title="Shattrath objective"}),"known taxi route was not found")
assertEqual(#route.path,2,"taxi route vertex count")
assertEqual(route.path[1].mode,"walk","taxi route starts by walking to the flight master")
assertEqual(route.path[2].mode,"taxi","taxi route includes a flight action")
assertEqual(route.path[2].node.mapKey,"Shattrath City/0","taxi lands in the target map")

-- Learned taxis must connect to a same-map transport node, then continue on
-- a new continent.  The previous reduced planner considered only a source
-- and target taxi pair, so it could never suggest this flight + boat route.
player={key="Elwynn Forest/0",valid=true,x=.43,y=.65}
route=assert(Navigation:FindRoute(nil,{key="Dragonblight/0",x=.61,y=.56,title="Dragonblight objective"}),"multi-continent route was not found")
local sawTaxi,sawBoat=false,false
for _,entry in ipairs(route.path) do
  if entry.mode=="taxi" then sawTaxi=true end
  if entry.mode=="boat" then sawBoat=true end
end
assertEqual(sawTaxi,true,"route includes learned flight paths")
assertEqual(sawBoat,true,"route connects flight path to boat")

-- Astral Recall is a ready, lower-cost travel leg to the known bind point.
-- It must be shown as advice, never invoked by navigation.
route=assert(Navigation:FindRoute(nil,{key="Stormwind City/0",x=.50,y=.60,title="Stormwind objective"}),"Astral Recall route was not found")
assertEqual(route.path[1].mode,"astral","ready Astral Recall is preferred over Hearthstone")
assertEqual(route.path[1].label,"Stormwind","Astral Recall names the bound destination")

-- The spell API exposes the global cooldown through GetSpellCooldown. It is
-- not Astral Recall's actual cooldown and must not make the route graph churn
-- every time the player casts an unrelated spell.
GetSpellCooldown=function() return 99.5,1.5,1 end
local ports=Navigation:GetAvailableTravelPorts(ZGV.Data.routes)
local sawAstral=false
for _,port in ipairs(ports) do if port.mode=="astral" then sawAstral=true end end
assertEqual(sawAstral,true,"global cooldown does not remove Astral Recall from routing")
GetSpellCooldown=function() return 50,900,1 end
ports=Navigation:GetAvailableTravelPorts(ZGV.Data.routes)
sawAstral=false
for _,port in ipairs(ports) do if port.mode=="astral" then sawAstral=true end end
assertEqual(sawAstral,false,"real Astral Recall cooldown removes the travel option")
GetSpellCooldown=function() return 0,0,1 end

-- Regression from live testing: an active Nagrand goal in Zangarmarsh must
-- prefer the learned Garadar -> Zabra'jin flight over the two-border detour
-- through Blade's Edge Mountains.
player={key="Nagrand/0",valid=true,x=.55,y=.38}
route=assert(Navigation:FindRoute(nil,{key="Zangarmarsh/0",x=.31,y=.54,title="Zangarmarsh quest"}),"Nagrand flight route was not found")
assertEqual(route.path[1].node.title,"Garadar Flight Master","Nagrand route starts at Garadar")
assertEqual(route.path[1].mode,"walk","player is directed to Garadar")
assertEqual(route.path[2].node.title,"Zabra'jin Flight Master","Nagrand route selects Zabra'jin")
assertEqual(route.path[2].mode,"taxi","Garadar to Zabra'jin is a flight leg")

-- A taxi-cache revision must invalidate an otherwise unchanged Runtime
-- waypoint.  This is the automatic refresh that previously required /reload.
Navigation.waypoint={key="Zangarmarsh/0",mapKey="Zangarmarsh/0",x=.31,y=.54,title="Zangarmarsh quest"}
Navigation.route=route
Navigation.routeIndex=1
Compat.Taxi.revision=1
Navigation:RememberRouteInputs(player)
local refreshReason
local realRebuild=Navigation.RebuildRoute
function Navigation:RebuildRoute(reason,livePlayer)
  refreshReason=reason
  return realRebuild(self,reason,livePlayer)
end
Compat.Taxi.revision=2
Navigation:MaybeRefreshRoute(10)
assertEqual(refreshReason,"travel inputs changed","taxi cache revision refreshes active route")
refreshReason=nil
player={key="Zangarmarsh/0",valid=true,x=.32,y=.53}
Navigation:OnTravelEvent("ZONE_CHANGED_NEW_AREA")
assertEqual(refreshReason,"ZONE_CHANGED_NEW_AREA","zone transition hard-refreshes active route")
Navigation.RebuildRoute=realRebuild

-- Even without a complete route graph, a ready travel ability remains useful
-- advice.  The final continuation will be rebuilt from the live bind map.
player={key="Unlinked Zone/0",valid=true,x=.5,y=.5}
route=assert(Navigation:FindRoute(nil,{key="Remote Zone/0",x=.61,y=.56,title="Remote objective"}),"travel fallback was not found")
assertEqual(route.fallback,true,"incomplete graph returns a marked fallback")
assertEqual(route.path[1].mode,"astral","fallback recommends ready Astral Recall")

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
