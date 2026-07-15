-- Local-only diagnostic telemetry.  Nothing is transmitted; records remain
-- in character SavedVariables for troubleshooting and guide migration QA.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local Telemetry=ZGV:RegisterModule("Telemetry",{events={},maxAge=7*86400,maxEntries=500})
ZGV.Telemetry=Telemetry

function Telemetry:Setup()
  ZGV.db.char.telemetry=ZGV.db.char.telemetry or {}
  self.events=ZGV.db.char.telemetry; self:Prune(); return self.events
end
function Telemetry:Prune()
  local now=time(); local events=self.events or {}
  for index=#events,1,-1 do if not events[index].time or now-events[index].time>self.maxAge then table.remove(events,index) end end
  while #events>self.maxEntries do table.remove(events,1) end
end
function Telemetry:AddEvent(kind,data)
  if not self.events then self:Setup() end
  local event={time=time(),event=tostring(kind)}
  for key,value in pairs(data or {}) do if type(value)~="function" and type(value)~="userdata" then event[key]=value end end
  self.events[#self.events+1]=event; self:Prune(); return event
end
function Telemetry:SetupEvents()
  ZGV:RegisterCallback("ZGV_STARTED",function() Telemetry:AddEvent("STARTUP",{version=ZGV.version,build=ZGV.targetBuild}) end)
  ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",function(guide,step) Telemetry:AddEvent("GUIDE_CHANGED",{guide=guide and guide.id,step=step}) end)
  ZGV:RegisterCallback("ZGV_STEP_CHANGED",function(guide,step,manual) Telemetry:AddEvent("STEP_CHANGED",{guide=guide and guide.id,step=step,manual=manual and true or false}) end)
  ZGV:RegisterCallback("ZGV_OPTIONS_CHANGED",function() Telemetry:AddEvent("OPTIONS",{scale=GetCVar and GetCVar("uiscale") or nil}) end)
  ZGV:RegisterEvent("PLAYER_LOGOUT",function() Telemetry:AddEvent("SHUTDOWN") end)
end
Telemetry.Miner={RecentOptions={},CurrentStepData={}}
function Telemetry.Miner:Startup()
  ZGV:RegisterEvent("GOSSIP_SHOW",function() Telemetry.Miner:GetGossips() end)
  ZGV:RegisterCallback("ZGV_STEP_CHANGED",function() Telemetry.Miner:CheckCurrentStep() end)
end
function Telemetry.Miner:CheckCurrentStep()
  local runtime=ZGV.Runtime; local step=runtime and runtime.currentGuide and runtime.currentGuide.steps[runtime.currentStep]
  self.CurrentStepData={step=step and step.number,guide=runtime and runtime.currentGuide and runtime.currentGuide.id}
end
function Telemetry.Miner:GetGossips()
  local values={GetGossipOptions and GetGossipOptions() or nil}; local options={}
  for index=1,#values,2 do if values[index] then options[#options+1]=values[index] end end
  self.RecentOptions=options
  if #options>0 then Telemetry:AddEvent("GOSSIP_OPTIONS",{count=#options,step=self.CurrentStepData.step}) end
end
function Telemetry.Miner:GetSelectedOption(kind,value) Telemetry:AddEvent("GOSSIP_SELECT",{kind=kind,value=value}) end
function Telemetry:OnStartup() self:Setup(); self:SetupEvents(); self.Miner:Startup(); self:AddEvent("SESSION_READY",{revision=ZGV.buildRevision}) end
