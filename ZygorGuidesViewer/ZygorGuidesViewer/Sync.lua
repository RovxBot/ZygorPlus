-- Secure New-to-New party synchronization for build 12340.  Packets contain
-- only locally-verifiable guide IDs and progress state; guide DSL/text is
-- deliberately never transmitted, parsed, or executed.
local addonName, addonNamespace = ...
local ZGV=(type(addonNamespace)=="table" and (addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV)) or _G.ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Sync=ZGV:RegisterModule("Sync",{peers={},prefix="ZGV335",protocol=2,sequence=0,contentHash=nil,lastMismatch={}})

local function profile() return ZGV.db and ZGV.db.profile and ZGV.db.profile.sync end
local function now() return GetTime and GetTime() or 0 end
local function playerName(name) return tostring(name or ""):match("^([^%-]+)") or tostring(name or "") end
local function safe(value,limit)
  value=tostring(value or ""):gsub("|","")
  if #value>(limit or 160) then return nil end
  return value
end
local function groupChannel()
  if GetNumRaidMembers and GetNumRaidMembers()>0 then return "RAID" end
  if GetNumPartyMembers and GetNumPartyMembers()>0 then return "PARTY" end
end
local function validChannel(channel)
  local settings=profile(); if not settings then return false end
  return (channel=="PARTY" and settings.acceptParty) or (channel=="RAID" and settings.acceptRaid)
    or (channel=="WHISPER" and settings.acceptWhisper) or false
end

function Sync:IsEnabled()
  local settings=profile()
  -- Sync is opt-in for a session: merely having the addon installed never
  -- accepts party state until the player chooses master or slave mode.
  return settings and settings.enabled and settings.mode~="off" or false
end

function Sync:Role()
  local settings=profile()
  return settings and (settings.mode=="master" or settings.mode=="slave") and settings.mode or "off"
end

function Sync:ContentHash()
  if self.contentHash then return self.contentHash end
  local catalog=ZGV.Catalog
  local guides=catalog and (catalog.sorted and #catalog.sorted>0 and catalog.sorted or catalog.guides) or {}
  local ordered={}
  for i=1,#guides do ordered[#ordered+1]=guides[i] end
  table.sort(ordered,function(a,b) return tostring(a.id)<tostring(b.id) end)
  local hash=5381
  local function add(value)
    value=tostring(value or "")
    for i=1,#value do hash=(hash*33+value:byte(i))%2147483647 end
  end
  -- Body text is part of the hash, so two builds with the same guide titles
  -- but different step data cannot silently drive each other.
  for _,guide in ipairs(ordered) do add(guide.id); add("\n"); add(guide.raw); add("\n") end
  self.contentHash=tostring(hash)..":"..tostring(#ordered)
  return self.contentHash
end

function Sync:AddonVersion() return safe(ZGV.version or ZGV.versionBase or "unknown",48) or "unknown" end
function Sync:Session()
  if not self.session then
    self.session=safe((UnitName and UnitName("player") or "player")..":"..tostring(time and time() or 0),64) or "session"
  end
  return self.session
end

function Sync:EncodeHandshake()
  return table.concat({"H",self.protocol,self:AddonVersion(),self:ContentHash(),self:Session(),self:Role()},"|")
end

function Sync:EncodeStatus()
  local runtime=ZGV.Runtime; local guide=runtime and runtime.currentGuide
  local step=guide and tonumber(runtime.currentStep) or 0
  local complete=false
  if guide and runtime.GetStepState then
    local state=runtime:GetStepState(guide.steps[step],step); complete=state and state.complete and true or false
  end
  self.sequence=(self.sequence or 0)+1
  return table.concat({"S",self.protocol,self:ContentHash(),self:Session(),self:Role(),safe(guide and guide.id,180) or "",step,complete and "1" or "0",self.sequence},"|")
end

function Sync:EncodeRequest() return table.concat({"R",self.protocol,self:ContentHash(),self:Session()},"|") end

-- Kept for callers from the Classic UI facade.  It now produces a v2 state
-- packet rather than an unsafe remote-step-data packet.
function Sync:Encode(kind,guideID,step,complete)
  if kind=="R" then return self:EncodeRequest() end
  return self:EncodeStatus()
end

function Sync:Send(payload,channel,target)
  if not self:IsEnabled() or type(SendAddonMessage)~="function" then return false,"unavailable" end
  channel=channel or groupChannel(); if not channel then return false,"not_grouped" end
  local ok,err=pcall(SendAddonMessage,self.prefix,payload,channel,target)
  if ZGV.LogEvent then ZGV:LogEvent("sync","packet sent",{kind=tostring(payload):match("^[^|]+"),channel=channel})
  elseif ZGV.LogInfo then ZGV:LogInfo("sync","sent "..tostring(payload):sub(1,24).." channel="..channel) end
  return ok,err
end

function Sync:SendHandshake(channel,target) return self:Send(self:EncodeHandshake(),channel,target) end
function Sync:SendStatus(force,channel,target)
  local settings=profile()
  if not force and (not settings or not settings.announce) then return false,"disabled" end
  return self:Send(self:EncodeStatus(),channel,target)
end
function Sync:BroadcastProgress() return self:SendStatus(false) end
function Sync:RequestStatuses()
  local sent=self:SendHandshake()
  local requested=self:Send(self:EncodeRequest())
  return sent or requested
end

function Sync:NotifyMismatch(sender,reason)
  local key=tostring(sender)..":"..tostring(reason)
  if self.lastMismatch[key] and now()-self.lastMismatch[key]<15 then return end
  self.lastMismatch[key]=now()
  local text="Party sync with "..tostring(sender).." is unavailable ("..tostring(reason)..")."
  if ZGV.LogEvent then ZGV:LogEvent("sync",text,{peer=sender,reason=reason},"warning")
  elseif ZGV.LogError then ZGV:LogError("sync",text) end
  ZGV:Fire("ZGV_NOTIFICATION",{message=text,kind="warning",time=time and time() or 0})
  ZGV:Fire("ZGV_SYNC_MISMATCH",sender,reason)
end

function Sync:UpdatePeer(sender,fields,channel)
  local peer=self.peers[sender] or {name=sender}
  for key,value in pairs(fields) do peer[key]=value end
  peer.channel=channel; peer.updatedAt=now(); self.peers[sender]=peer
  ZGV:Fire("ZGV_SYNC_PEER_UPDATED",peer)
  return peer
end

function Sync:AcceptHandshake(sender,version,addonVersion,contentHash,session,role,channel)
  if tonumber(version)~=self.protocol then self:NotifyMismatch(sender,"protocol v"..tostring(version)); return nil end
  if contentHash~=self:ContentHash() then
    self:UpdatePeer(sender,{compatible=false,mismatch="content_hash",addonVersion=addonVersion,contentHash=contentHash,session=session,mode=role},channel)
    self:NotifyMismatch(sender,"different guide content")
    return nil
  end
  return self:UpdatePeer(sender,{compatible=true,mismatch=nil,handshake=true,addonVersion=addonVersion,contentHash=contentHash,session=session,mode=role},channel)
end

function Sync:ApplyMasterState(peer)
  if not self:IsSlave() or peer.mode~="master" or not peer.compatible or peer.guideID=="" then return false end
  local runtime,catalog=ZGV.Runtime,ZGV.Catalog
  local guide=catalog and catalog:Get(peer.guideID)
  if not runtime or not guide then self:NotifyMismatch(peer.name,"guide unavailable locally"); return false end
  if runtime.currentGuide==guide and runtime.currentStep==peer.step then return true end
  self.applyingRemote=true
  local ok=runtime:SelectGuide(guide.id,peer.step)
  self.applyingRemote=false
  if ok and ZGV.LogInfo then ZGV:LogInfo("sync","followed master "..peer.name.." guide="..guide.id.." step="..tostring(peer.step)) end
  return ok
end

function Sync:AcceptStatus(sender,version,contentHash,session,role,guideID,step,complete,sequence,channel)
  if tonumber(version)~=self.protocol then self:NotifyMismatch(sender,"protocol v"..tostring(version)); return end
  if contentHash~=self:ContentHash() then self:NotifyMismatch(sender,"different guide content"); return end
  step,sequence=tonumber(step),tonumber(sequence)
  if not step or step<0 or step%1~=0 or not sequence or guideID==nil then return end
  guideID=safe(guideID,180); if not guideID then return end
  local catalog=ZGV.Catalog
  if guideID~="" and (not catalog or not catalog:Get(guideID)) then self:NotifyMismatch(sender,"guide unavailable locally"); return end
  local peer=self.peers[sender]
  if peer and peer.session==session and peer.sequence and sequence<peer.sequence then return end
  peer=self:UpdatePeer(sender,{compatible=true,mismatch=nil,handshake=true,contentHash=contentHash,session=session,mode=role,guideID=guideID,step=step,complete=complete=="1",sequence=sequence},channel)
  self:ApplyMasterState(peer)
end

function Sync:OnMessage(prefix,message,channel,sender)
  if prefix~=self.prefix or not self:IsEnabled() or not validChannel(channel) then return end
  sender=playerName(sender); if sender==playerName(UnitName and UnitName("player")) then return end
  local fields={}; for field in (tostring(message or "").."|"):gmatch("([^|]*)|") do fields[#fields+1]=field end
  -- Exact field counts prevent a malformed packet from reaching any
  -- state-changing code (including a deliberately empty status guide ID).
  local kind=fields[1]
  if kind=="H" and #fields==6 then
    self:AcceptHandshake(sender,fields[2],fields[3],fields[4],fields[5],fields[6],channel)
    self:SendStatus(true,channel,sender)
  elseif kind=="S" and #fields==9 then
    self:AcceptStatus(sender,fields[2],fields[3],fields[4],fields[5],fields[6],fields[7],fields[8],fields[9],channel)
  elseif kind=="R" and #fields==4 then
    if tonumber(fields[2])~=self.protocol then self:NotifyMismatch(sender,"protocol v"..tostring(fields[2])); return end
    if fields[3]~=self:ContentHash() then self:NotifyMismatch(sender,"different guide content"); return end
    self:SendHandshake(channel,sender); self:SendStatus(true,channel,sender)
  end
end

function Sync:OnEvent(event,...)
  if event=="CHAT_MSG_ADDON" then self:OnMessage(...)
  elseif event=="PARTY_MEMBERS_CHANGED" or event=="RAID_ROSTER_UPDATE" then self:RequestStatuses() end
end

function Sync:GetPeers()
  local result={}; for _,peer in pairs(self.peers) do result[#result+1]=peer end
  table.sort(result,function(a,b) return a.name<b.name end); return result
end
function Sync:IsClearToProceed(guideID,step)
  local settings=profile(); if not settings or not settings.magnetic then return true end
  for _,peer in pairs(self.peers) do if peer.compatible and peer.guideID==guideID and peer.step==step and not peer.complete then return false end end
  return true
end

function Sync:Init() return self:OnStartup() end
function Sync:UpdateMode() ZGV:Fire("ZGV_SHAREMODE",self:Role()) end
function Sync:UpdateButtonColor() return self:GetPeers() end
function Sync:ActivateAsMaster()
  local settings=profile(); if not settings then return false,"profile unavailable" end
  settings.mode="master"; settings.magnetic=true; self:UpdateMode(); self:RequestStatuses(); return true
end
function Sync:ActivateAsSlave()
  local settings=profile(); if not settings then return false,"profile unavailable" end
  settings.mode="slave"; settings.magnetic=true; self:UpdateMode(); self:RequestStatuses(); return true
end
function Sync:Deactivate()
  local settings=profile(); if not settings then return false,"profile unavailable" end
  settings.mode="off"; settings.magnetic=false; self:ResetPartyStatus(); self:UpdateMode(); return true
end
function Sync:IsMaster() return self:Role()=="master" end
function Sync:IsSlave() return self:Role()=="slave" end
function Sync:IsInGroup() return groupChannel()~=nil end
function Sync:GetAheadBehind(name) local peer=self.peers[playerName(name)] or self.peers[name]; local current=ZGV.Runtime and ZGV.Runtime.currentStep or 0; return peer and (peer.step-current) or nil end
function Sync:GetStepGoalPartyStatusText()
  local peers=self:GetPeers(); if #peers==0 then return "No synced party members" end
  local values={}; for _,peer in ipairs(peers) do values[#values+1]=peer.name..": "..(peer.compatible and "step "..tostring(peer.step) or "content mismatch") end
  return table.concat(values,", ")
end
function Sync:AnnounceStatus() return self:BroadcastProgress() end
function Sync:CreatePacket_GuideStatus() return self:EncodeStatus() end
function Sync:CreatePackets_StepData() return nil,"remote guide text is intentionally disabled" end
function Sync:CreatePacket_StatusRequest() return self:EncodeRequest() end
function Sync:CreatePacket_StepRequest() return self:EncodeRequest() end
function Sync:CreatePacket_SlaveRequest() return self:EncodeRequest() end
function Sync:SplitXXIntoPacket(packet,data) return packet,data end
function Sync:Unpack(packet) return packet end
function Sync:HandleReceivedPacket(packet) return packet end
function Sync:BroadcastStepContents() return false,"remote guide text is disabled" end
function Sync:RequestStepContents() return self:RequestStatuses() end
function Sync:RequestPartyStatus() return self:RequestStatuses() end
function Sync:RequestSlaveMode() return self:RequestStatuses() end
function Sync:ResetPartyStatus() self.peers={}; ZGV:Fire("ZGV_SYNC_PEERS_RESET") end
function Sync:GetStepSource(stepNumber)
  local guide=ZGV.Runtime and ZGV.Runtime.currentGuide; local step=guide and guide.steps[tonumber(stepNumber) or ZGV.Runtime.currentStep]
  local lines={}; for _,goal in ipairs(step and step.goals or {}) do lines[#lines+1]=goal.raw or goal.text or "" end; return lines
end
function Sync:IsSecret() return false end
function Sync:IsSnapping() local settings=profile(); return settings and settings.magnetic and true or false end
function Sync:SendSelf(payload) return self:OnMessage(self.prefix,payload,"WHISPER",UnitName and UnitName("player") or "player") end
function Sync:RequestAllStatuses() return self:RequestStatuses() end
function Sync:OnChatReceived(message,channel,sender) return self:OnMessage(self.prefix,message,channel,sender) end
function Sync:OnPartyStatusChanged() ZGV:Fire("ZGV_SYNC_PARTY_STATUS",self:GetPeers()) end
function Sync:DeclarePartyStatusComplete(name) local peer=self.peers[playerName(name)]; if peer then peer.complete=true; self:OnPartyStatusChanged(); return true end return false end
function Sync:IsPartyStatusComplete() for _,peer in pairs(self.peers) do if peer.compatible and not peer.complete then return false end end return true end
function Sync:GetParty_NotSlaveNames() local result={}; for _,peer in ipairs(self:GetPeers()) do if peer.mode~="slave" then result[#result+1]=peer.name end end return result end
function Sync:GetParty_SlaveNames() local result={}; for _,peer in ipairs(self:GetPeers()) do if peer.mode=="slave" then result[#result+1]=peer.name end end return result end
function Sync:ShowMasterConfirmation() return self:ActivateAsMaster() end
function Sync:ShowSlaveConfirmation() return self:ActivateAsSlave() end
function Sync:OnShareButtonEnter(frame) if frame then GameTooltip:SetOwner(frame,"ANCHOR_TOP"); GameTooltip:SetText(self:GetStepGoalPartyStatusText()); GameTooltip:Show() end end
function Sync:OnShareButtonClick() return self:IsMaster() and self:Deactivate() or self:ActivateAsMaster() end
function Sync:Debug(message,...) return ZGV:Debug("&sync "..tostring(message),...) end

function Sync:OnStartup()
  if RegisterAddonMessagePrefix then pcall(RegisterAddonMessagePrefix,self.prefix) end
  if self:IsEnabled() then self:RequestStatuses() end
end

local registered,registrationError=pcall(function()
  ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",Sync,"BroadcastProgress")
  ZGV:RegisterCallback("ZGV_STEP_CHANGED",Sync,"BroadcastProgress")
  ZGV:RegisterEvent("CHAT_MSG_ADDON",Sync,"OnEvent")
  ZGV:RegisterEvent("PARTY_MEMBERS_CHANGED",Sync,"OnEvent")
  ZGV:RegisterEvent("RAID_ROSTER_UPDATE",Sync,"OnEvent")
end)
if not registered and ZGV.LogError then ZGV:LogError("load: Sync",registrationError) end
