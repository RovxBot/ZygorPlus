local repo=assert(arg[1],"repository path is required")
local addon=repo.."/ZygorGuidesViewerNew/ZygorGuidesViewer/"

local function assertEqual(actual,expected,label)
  if actual~=expected then error((label or "value")..": expected "..tostring(expected)..", got "..tostring(actual),2) end
end
local function assertTrue(value,label) if not value then error(label or "expected true",2) end end

local events,packets={},{ }
ZygorGuidesViewer={
  db={profile={sync={enabled=true,acceptParty=true,acceptRaid=true,acceptWhisper=true,magnetic=true,announce=true,mode="master"},map={poiEnabled=true,poiMode="all",hideTypes={}},skills={enabled=true,toast=true}},char={}},
  Compat={Map={Resolve=function(_,key) return {key=key or "Elwynn",floor=0} end}},
}
ZGV=ZygorGuidesViewer
function ZGV:RegisterModule(name,module) self[name]=module; return module end
function ZGV:RegisterEvent() end
function ZGV:RegisterCallback() end
function ZGV:Fire(name,...) events[#events+1]={name,...} end
function ZGV:LogInfo() end
function ZGV:LogError() end
function ZGV:LogEvent() end
function GetTime() return 100 end
function time() return 1000 end
function UnitName() return "Local" end
function GetNumPartyMembers() return 1 end
function GetNumRaidMembers() return 0 end
function SendAddonMessage(prefix,payload,channel,target) packets[#packets+1]={prefix,payload,channel,target} end
function IsAddOnLoaded() return false end

-- Questie ownership is evaluated when an action happens, not once at login.
dofile(addon.."QuestieIntegration.lua")
local integration=assert(ZGV.QuestieIntegration)
assertEqual(integration:CanAutomate("accept"),true,"no Questie accepts")
Questie={db={profile={autoaccept=true,autocomplete=false}}}
assertEqual(integration:CanAutomate("accept"),false,"Questie autoaccept suppresses")
assertEqual(integration:CanAutomate("complete"),true,"Questie accept does not suppress completion")
assertEqual(integration:OwnsQuestWatch(),true,"loaded Questie owns watch")
Questie.db.profile.autoaccept=false; Questie.db.profile.autocomplete=true
assertEqual(integration:CanAutomate("gossip"),false,"live Questie toggle suppresses gossip")
Questie=nil

-- Sync v2 transfers only matched local IDs/state and lets a slave follow a
-- local guide.  A content mismatch is surfaced without touching runtime state.
local guide={id="guideA",title="Guide A",raw="step one",steps={{goals={}}}}
ZGV.Catalog={sorted={guide},guides={guide},Get=function(_,id) return id=="guideA" and guide or nil end}
local selected
ZGV.Runtime={currentGuide=guide,currentStep=1,GetStepState=function() return {complete=false} end,
  SelectGuide=function(_,id,step) selected={id,step}; return id=="guideA" end}
dofile(addon.."Sync.lua")
local sync=assert(ZGV.Sync)
local hash=sync:ContentHash()
sync:OnMessage(sync.prefix,"H|2|test|"..hash.."|remote-session|master","PARTY","Remote")
assertTrue(sync.peers.Remote and sync.peers.Remote.compatible,"matching handshake accepted")
sync:OnMessage(sync.prefix,"S|2|"..hash.."|remote-session|master|guideA|4|1|1","PARTY","Remote")
assertEqual(sync.peers.Remote.step,4,"state packet recorded")
ZGV.db.profile.sync.mode="slave"
sync:OnMessage(sync.prefix,"S|2|"..hash.."|remote-session|master|guideA|3|0|2","PARTY","Remote")
assertEqual(selected[1],"guideA","slave follows only local guide")
assertEqual(selected[2],3,"slave follows remote step")
local prior=sync.peers.Remote.step
sync:OnMessage(sync.prefix,"H|2|test|different:1|other|master","PARTY","Mismatch")
assertEqual(sync.peers.Remote.step,prior,"mismatch cannot replace matched peer state")
assertTrue(#packets>0,"handshake/status responses sent")

-- POI guidance resolves a registered local guide; it never compiles point text.
ZGV.Navigation={
  ResolveTarget=function(_,target) return target end,
  SetExternalMarkers=function(_,owner,points) ZGV.lastMarkers=points end,
  ClearExternalMarkers=function() end,
  SetWaypoint=function(_,target) ZGV.lastWaypoint=target; return true end,
}
dofile(addon.."Poi.lua")
local poi=assert(ZGV.Poi)
poi:RegisterSet("test",{{map="Elwynn",x=40,y=50,name="Local guide",ident="local-guide",guide="guideA",guideStep=1}})
poi:ParsePoints()
local point=assert(poi:FindPoint("local-guide"))
selected=nil
assertEqual(poi:LoadPoint(point),true,"registered local guidance loads")
assertEqual(selected[1],"guideA","POI selects local catalog guide")
assertEqual(ZGV.db.char.activepoi,"local-guide","POI selection persists")
assertEqual(poi:LoadPoint({ident="unsafe",guide="not-local"}),false,"unregistered POI guide rejected")

-- Trainer service records retain WotLK live price/rank/availability instead of
-- treating the current service-index as a permanent ban key.
function UnitClass() return "Death Knight","DEATHKNIGHT" end
function UnitLevel() return 55 end
function GetProfessions() return nil,nil,nil,nil,nil,nil end
function GetNumTrainerServices() return 2 end
function GetTrainerServiceInfo(index)
  if index==1 then return "Death Strike","Rank 1","Death Knight", "available",1,55 end
  return "Rune Strike","Rank 1","Death Knight","unavailable",0,56
end
function GetTrainerServiceCost(index) return index*10000 end
function GetTrainerServiceIcon() return "icon" end
dofile(addon.."Data-WotLK/TrainerFixtures.lua")
dofile(addon.."Skills.lua")
local skills=assert(ZGV.Skills); skills:CleanSkillTable()
local learnable=skills:GetLearnableSkills()
assertEqual(#learnable,1,"only available live service is learnable")
assertEqual(learnable[1].cost,10000,"trainer cost captured")
assertEqual(skills.context.classSupported,true,"Death Knight fixture coverage")
skills:BanLearnableSkills(learnable[1])
assertEqual(#skills:GetLearnableSkills(),0,"stable service ban applied")

print("release hardening Lua tests passed")
