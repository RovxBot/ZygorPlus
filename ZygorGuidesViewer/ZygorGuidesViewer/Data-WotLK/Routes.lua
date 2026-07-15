local ZGV=ZygorGuidesViewer

local nodes={
  stormwind_harbor={mapKey="Stormwind City/0",x=.184,y=.254,title="Stormwind Harbor"},
  borean_valiance={mapKey="Borean Tundra/0",x=.590,y=.684,title="Valiance Keep"},
  menethil_north={mapKey="Wetlands/0",x=.049,y=.570,title="Menethil Harbor"},
  howling_valgarde={mapKey="Howling Fjord/0",x=.598,y=.636,title="Valgarde"},
  orgrimmar_zeppelin={mapKey="Durotar/0",x=.413,y=.179,title="Orgrimmar Zeppelin Tower"},
  borean_warsong={mapKey="Borean Tundra/0",x=.414,y=.536,title="Warsong Hold"},
  undercity_zeppelin={mapKey="Tirisfal Glades/0",x=.608,y=.586,title="Undercity Zeppelin Tower"},
  howling_vengeance={mapKey="Howling Fjord/0",x=.782,y=.290,title="Vengeance Landing"},
  dark_portal_azeroth={mapKey="Blasted Lands/0",x=.582,y=.557,title="The Dark Portal"},
  dark_portal_outland={mapKey="Hellfire Peninsula/0",x=.892,y=.505,title="The Dark Portal"},
  shattrath_portal={mapKey="Shattrath City/0",x=.550,y=.375,title="Shattrath City"},
  -- Outland zone transitions.  These were taken from the original 3.3.5a
  -- LibRover border graph, rather than drawing an impossible straight line
  -- through Shattrath's walls.
  terokkar_shattrath_west={mapKey="Terokkar Forest/0",x=.360,y=.319,title="Shattrath City Gate"},
  shattrath_terokkar_west={mapKey="Shattrath City/0",x=.762,y=.773,title="Shattrath City Gate"},
  terokkar_shattrath_east={mapKey="Terokkar Forest/0",x=.389,y=.241,title="Shattrath City Gate"},
  shattrath_terokkar_east={mapKey="Shattrath City/0",x=.880,y=.450,title="Shattrath City Gate"},
  -- Terrace of Light: the guide's 56.37,16.27 waypoint is above the lower
  -- city.  These authored corridor nodes stop the pointer from suggesting a
  -- line through the terrace wall or directly up the cliff.
  shattrath_lower_terrace={mapKey="Shattrath City/0",x=.495,y=.445,title="Lower Terrace"},
  shattrath_terrace_center={mapKey="Shattrath City/0",x=.530,y=.375,title="Terrace of Light"},
  shattrath_ramp_foot={mapKey="Shattrath City/0",x=.523,y=.325,title="Terrace Ramp"},
  shattrath_ramp_turn={mapKey="Shattrath City/0",x=.543,y=.253,title="Upper Terrace Ramp"},
  shattrath_upper_terrace={mapKey="Shattrath City/0",x=.558,y=.205,title="Upper Terrace"},
  shattrath_terrace_light={mapKey="Shattrath City/0",x=.564,y=.163,title="Terrace of Light"},
  dalaran_center={mapKey="Dalaran/0",x=.500,y=.470,title="Dalaran"},
  dalaran_stormwind={mapKey="Dalaran/0",x=.401,y=.628,title="Portal to Stormwind"},
  dalaran_orgrimmar={mapKey="Dalaran/0",x=.552,y=.253,title="Portal to Orgrimmar"},
  stormwind_portal={mapKey="Stormwind City/0",x=.494,y=.870,title="Mage Quarter"},
  orgrimmar_portal={mapKey="Orgrimmar/0",x=.386,y=.852,title="Valley of Spirits"},
  booty_bay={mapKey="Stranglethorn Vale/0",x=.269,y=.732,title="Booty Bay"},
  ratchet={mapKey="The Barrens/0",x=.630,y=.385,title="Ratchet"},
  auberdine={mapKey="Darkshore/0",x=.321,y=.439,title="Auberdine"},
  ruttheran={mapKey="Teldrassil/0",x=.553,y=.916,title="Rut'theran Village"},
  exodar_boat={mapKey="Azuremyst Isle/0",x=.205,y=.544,title="Valaar's Berth"},
  silvermoon_transloc={mapKey="Silvermoon City/0",x=.493,y=.144,title="Orb of Translocation"},
  undercity_transloc={mapKey="Undercity/0",x=.856,y=.177,title="Orb of Translocation"},
}

local links={
  {"stormwind_harbor","borean_valiance","boat",120,"Alliance"},
  {"menethil_north","howling_valgarde","boat",120,"Alliance"},
  {"orgrimmar_zeppelin","borean_warsong","zeppelin",120,"Horde"},
  {"undercity_zeppelin","howling_vengeance","zeppelin",120,"Horde"},
  {"dark_portal_azeroth","dark_portal_outland","portal",10},
  -- `enter` and `leave` intentionally differ by direction so the arrow gives
  -- an actionable city-transition instruction instead of a generic run line.
  {"terokkar_shattrath_west","shattrath_terokkar_west","enter",38,nil,"leave"},
  {"terokkar_shattrath_east","shattrath_terokkar_east","enter",38,nil,"leave"},
  {"shattrath_terokkar_west","shattrath_lower_terrace","walk",16,nil,"walk","Follow the Lower City road","Follow the Lower City road"},
  {"shattrath_terokkar_east","shattrath_terrace_center","walk",15,nil,"walk","Follow the Terrace road","Follow the Terrace road"},
  {"shattrath_lower_terrace","shattrath_terrace_center","walk",8,nil,"walk","Follow the Terrace of Light","Follow the Lower Terrace"},
  {"shattrath_terrace_center","shattrath_ramp_foot","walk",8,nil,"walk","Go to the Terrace ramp","Go down to the Terrace"},
  {"shattrath_ramp_foot","shattrath_ramp_turn","walk",10,nil,"walk","Run up the Terrace ramp","Run down the Terrace ramp"},
  {"shattrath_ramp_turn","shattrath_upper_terrace","walk",8,nil,"walk","Continue up the Terrace ramp","Go down the Terrace ramp"},
  {"shattrath_upper_terrace","shattrath_terrace_light","walk",6,nil,"walk","Follow the upper terrace","Follow the upper terrace"},
  {"booty_bay","ratchet","boat",90},
  {"auberdine","ruttheran","boat",60,"Alliance"},
  {"auberdine","exodar_boat","boat",90,"Alliance"},
  {"silvermoon_transloc","undercity_transloc","teleport",10,"Horde"},
  {"dalaran_stormwind","stormwind_portal","portal",10,"Alliance"},
  {"dalaran_orgrimmar","orgrimmar_portal","portal",10,"Horde"},
  {"dalaran_center","dalaran_stormwind","walk",20,"Alliance"},
  {"dalaran_center","dalaran_orgrimmar","walk",20,"Horde"},
}

-- The original WotLK LibRover data describes these as real map borders.  A
-- normalised waypoint cannot know about a zone wall on its own, so retain the
-- crossings as route nodes and let Navigation select the nearest legal exit.
local function addOutlandBorder(id, mapA, xA, yA, mapB, xB, yB)
  local a, b = "outland_" .. id .. "_a", "outland_" .. id .. "_b"
  nodes[a] = { mapKey = mapA .. "/0", x = xA, y = yA, title = "Border to " .. mapB }
  nodes[b] = { mapKey = mapB .. "/0", x = xB, y = yB, title = "Border to " .. mapA }
  -- [6] is the reverse mode; [7]/[8] are the directional labels consumed by
  -- Navigation so the list reads "Enter Zangarmarsh", not a coordinate.
  links[#links + 1] = { a, b, "cross", 38, nil, "cross", mapB, mapA }
end

addOutlandBorder("blade_zangar_west", "Blade's Edge Mountains", .285, .939, "Zangarmarsh", .433, .275)
addOutlandBorder("blade_zangar_east", "Blade's Edge Mountains", .520, .988, "Zangarmarsh", .687, .329)
addOutlandBorder("blade_netherstorm", "Blade's Edge Mountains", .825, .287, "Netherstorm", .200, .561)
addOutlandBorder("hellfire_terokkar", "Hellfire Peninsula", .311, .922, "Terokkar Forest", .583, .193)
addOutlandBorder("hellfire_zangar", "Hellfire Peninsula", .047, .506, "Zangarmarsh", .830, .655)
addOutlandBorder("nagrand_zangar_west", "Nagrand", .340, .130, "Zangarmarsh", .210, .705)
addOutlandBorder("nagrand_zangar_east", "Nagrand", .741, .329, "Zangarmarsh", .741, .326)
addOutlandBorder("nagrand_terokkar", "Nagrand", .779, .826, "Terokkar Forest", .203, .556)
addOutlandBorder("nagrand_shattrath", "Nagrand", .783, .545, "Shattrath City", .128, .564)
addOutlandBorder("shadowmoon_terokkar", "Shadowmoon Valley", .180, .237, "Terokkar Forest", .713, .504)
addOutlandBorder("terokkar_zangar", "Terokkar Forest", .323, .047, "Zangarmarsh", .822, .925)

-- Destination approaches select a known walkable corridor instead of a
-- direct point-to-point edge.  They deliberately cover only high-confidence
-- terrain transitions; ordinary open-world coordinates continue to use the
-- fast direct route.
local approaches={
  {
    mapKey="Shattrath City/0",node="shattrath_terrace_light",radius=.070,
    corridor={"shattrath_lower_terrace","shattrath_terrace_center","shattrath_ramp_foot","shattrath_ramp_turn","shattrath_upper_terrace","shattrath_terrace_light"},
  },
}

-- Travel items from the Anniversary rover dataset which exist on build 12340.
-- Keeping them on the replacement route contract prevents Inventory from
-- offering to destroy or vendor a hearth/teleport item.  The Anniversary-only
-- Dark Portal hearth item (184871) is deliberately absent: it does not exist
-- in the 3.3.5a item database.
local portkeys={
  {item=6948,destination="_HEARTH",cost=80,mode="hearth"},
  {item=22631,destination="Deadwind Pass/0",x=.4724,y=.7540,cost=30},
  {item=22589,destination="Deadwind Pass/0",x=.4724,y=.7540,cost=30},
  {item=22632,destination="Deadwind Pass/0",x=.4724,y=.7540,cost=30},
  {item=22630,destination="Deadwind Pass/0",x=.4724,y=.7540,cost=30},
  {item=18984,destination="Winterspring/0",x=.6115,y=.3756,cost=120,cooldown=14400},
  {item=18986,destination="Tanaris/0",x=.5227,y=.2683,cost=120,cooldown=14400},
  {spell=556,destination="_HEARTH",cost=20,mode="hearth",isAstral=true},
}

ZGV.Data:Register("routes",3,{nodes=nodes,links=links,approaches=approaches,portkeys=portkeys},{
  source="build-12340 transport topology; coordinates cross-checked against bundled guides",
  rules="Wrath faction transports, Dalaran portals, and build-12340 travel items; no post-Wrath systems",
})
