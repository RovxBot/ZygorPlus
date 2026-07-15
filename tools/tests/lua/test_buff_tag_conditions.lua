local repo=assert(arg[1],"repository path is required")
local addon=repo.."/ZygorGuidesViewer/ZygorGuidesViewer/"

local modules={}
ZygorGuidesViewer={Compat={}}
function ZygorGuidesViewer:RegisterModule(name,module) modules[name]=module; self[name]=module; return module end
function ZygorGuidesViewer:RegisterEvent() end
function ZygorGuidesViewer:CanonicalMapKey(map,floor) return tostring(map).."/"..tostring(floor or 0) end
ZGV=ZygorGuidesViewer

function UnitBuff(_,index)
  if index==1 then return "Shadowy Disguise" end
end
function GetSpellInfo(id)
  if id==32756 then return "Shadowy Disguise" end
end

dofile(addon.."Conditions.lua")
local Conditions=assert(ZygorGuidesViewer.Conditions)
assert(Conditions:HaveBuff("Shadowy Disguise##32756"),"name-plus-ID buff tags resolve through UnitBuff")
assert(Conditions:HaveBuff(32756),"numeric buff tags resolve through GetSpellInfo")

dofile(addon.."Parser.lua")
local Parser=assert(ZygorGuidesViewer.Parser)
local modifiers=Parser:ParseModifiers({"havebuff Shadowy Disguise##32756"})
local goal=Parser:ParseGoal("talk Scout Neftis##18714",modifiers)
assert(goal.haveBuff==32756,"havebuff modifier preserves its spell ID")
assert(goal.spellID==32756,"havebuff modifier exposes the spell ID to Runtime")

-- Reproduce the critical part of the Terokkar "Who Are They?" branch.  The
-- player must stop on the actual buff objective until the disguise is active;
-- the three dialogue steps then retain their buff-gated objective state.
local terokkar=assert(Parser:ParseEntry({
  id="terokkar-shadowy",title="Terokkar Shadowy",header={},raw=[[
step
label "Gain_Shadowy_Disguise"
talk Scout Neftis##18714
Select _"Scout Neftis, I need another disguise."_ |gossip 118185
Gain the Shadowy Disguise |havebuff Shadowy Disguise##32756 |goto Terokkar Forest/0 39.03,43.75 |q 10041
step
talk Shadowy Advisor##18719
Select _"Advisor, what's the latest news?"_ |gossip 118073
Talk to the Shadowy Advisor |q 10041/3 |goto Terokkar Forest/0 40.32,39.04
|only if hasbuff(32756) and not (readyq(10041) or completedq(10041))
]]
}))
local gain=terokkar.steps[1]
assert(gain.label=="Gain_Shadowy_Disguise","Terokkar retry label is attached to the disguise step")
assert(gain.goals[#gain.goals].action=="havebuff","disguise instruction is a real buff objective")
assert(gain.goals[#gain.goals].haveBuff==32756,"disguise objective uses its WotLK spell ID")
assert(gain.goals[#gain.goals].text=="Gain the Shadowy Disguise","disguise objective retains visible guide text")
assert(terokkar.steps[2].onlyIf:find("hasbuff%(32756%)"),"dialogue step retains the active-disguise condition")

-- Natural-language guide instructions are valid in the leading segment.
-- Pipe-delimited fields remain strict DSL syntax, so real unsupported tags
-- still reach diagnostics without falsely reporting prose as a parser error.
local nagrandProse=assert(Parser:ParseEntry({
  id="nagrand-prose",title="Nagrand prose",header={},raw=[[
step
Destroy the Large Hut |q 9805/1 |goto Nagrand/0 72.40,50.36
step
Follow the path up |goto Nagrand/0 74.22,67.78 < 30 |only if walking
]]
}))
assert(#nagrandProse.parseIssues==0,"valid Nagrand prose does not produce unsupported-tag errors")
assertEqual = assertEqual or function(actual,expected,label) if actual~=expected then error(label,2) end end
assertEqual(nagrandProse.steps[1].goals[1].action,"goto","prose objective retains its route goal")
assertEqual(nagrandProse.steps[1].goals[1].questID,9805,"prose objective retains quest metadata")
assertEqual(nagrandProse.steps[2].goals[1].action,"goto","prose travel instruction retains destination")
local unknown=Parser:ParseModifiers({"Talk to a guard","unsupportedfixture data"})
assert(#unknown.unsupported==1 and unknown.unsupported[1]=="unsupportedfixture","unsupported pipe tag remains diagnostic")

-- Private servers can leave historical quest completion unavailable.  The
-- retry branch therefore only retries when the quest is active, and sends a
-- non-active quest to the turn-in continuation.
local hordeSource=assert(io.open(repo.."/ZygorGuidesViewer/ZygorGuidesViewer_GuidesHorde/Leveling/ZygorLevelingHordeCLASSIC.lua","r")):read("*a")
assert(hordeSource:find("havequest%(10041%) and not readyq%(10041%)"),"Horde Terokkar retry requires an active quest")
assert(hordeSource:find("readyq%(10041%) or not havequest%(10041%)"),"Horde Terokkar non-active quest reaches hand-in")
local allianceSource=assert(io.open(repo.."/ZygorGuidesViewer/ZygorGuidesViewer_GuidesAlliance/Leveling/ZygorLevelingAllianceCLASSIC.lua","r")):read("*a")
assert(allianceSource:find("havequest%(10040%) and not readyq%(10040%)"),"Alliance Terokkar retry requires an active quest")
assert(allianceSource:find("readyq%(10040%) or not havequest%(10040%)"),"Alliance Terokkar non-active quest reaches hand-in")

print("buff tag condition tests passed")
