local ZGV = ZygorGuidesViewer
local _, ZGVNamespace = ...

-- 3.3 loads TOC Lua files in addon-specific environments.  The modern files
-- use the shared table explicitly, so publish Core's authoritative instance
-- before any compatibility or skin module is loaded.
_G.ZygorGuidesViewer = ZGV
_G.ZGV = ZGV
if type(ZGVNamespace) == "table" then
  ZGVNamespace.ZygorGuidesViewer = ZGV
  ZGVNamespace.ZGV = ZGV
end

ZGV.name = "ZygorGuidesViewer"
ZGV.displayName = "Zygor Guides Viewer"
ZGV.version = "8.1.0-wotlk.13"
-- Bump this whenever a client-facing package is deployed.  It is included in
-- the first session diagnostic so a reload can be verified from the client
-- log rather than inferred from file timestamps.
ZGV.buildRevision = "20260715-travel-refresh-01"
ZGV.interface = 30300
ZGV.targetBuild = 12340
ZGV.DIR = "Interface\\AddOns\\ZygorGuidesViewer"
ZGV.SKINDIR = ZGV.DIR.."\\Skins\\"
ZGV.IMAGESDIR = "Interface\\AddOns\\ZygorGuidesViewer_GuidesCommon\\Images\\"
ZGV.Modules = ZGV.Modules or {}
ZGV.ModuleOrder = ZGV.ModuleOrder or {}
ZGV.Callbacks = ZGV.Callbacks or {}
ZGV.Errors = ZGV.Errors or {}
ZGV.Diagnostics = ZGV.Diagnostics or {}
ZGV.Mutexes = ZGV.Mutexes or {}
ZGV._events = ZGV._events or {}
ZGV._startupComplete = false
ZGV.Gold = ZGV.Gold or { guides_loaded=false }
ZGV.BETAguides = false
function ZGV.BETASTART() ZGV.BETAguides=true end
function ZGV.BETAEND() ZGV.BETAguides=false end

local unpack = unpack
local function traceback(message)
  if type(debugstack)=="function" then return tostring(message).."\n"..debugstack(3,12,12) end
  return tostring(message)
end

local function diagnosticValue(value,depth)
  depth=depth or 0
  if value==nil or type(value)=="number" or type(value)=="boolean" then return value end
  if type(value)=="string" then
    value=value:gsub("[%c]"," ")
    return #value>240 and value:sub(1,237).."..." or value
  end
  if type(value)~="table" or depth>=2 then return tostring(value) end
  local result,count={},0
  for key,item in pairs(value) do
    if count>=16 then break end
    local safeKey=tostring(key):gsub("[^%w_.-]","_")
    result[safeKey]=diagnosticValue(item,depth+1)
    count=count+1
  end
  return result
end

function ZGV:Log(level,context,message,payload,correlation)
  self.diagnosticSequence=(self.diagnosticSequence or 0)+1
  local entry={
    time=type(date)=="function" and date("%Y-%m-%d %H:%M:%S") or tostring(time()),
    session=self.diagnosticSession or "bootstrap",
    level=tostring(level or "info"),severity=tostring(level or "info"),
    context=tostring(context or "runtime"),feature=tostring(context or "runtime"),message=tostring(message or ""),
    correlation=correlation or (self.diagnosticSession or "bootstrap")..":"..tostring(self.diagnosticSequence),
    payload=diagnosticValue(payload),
  }
  self.Diagnostics[#self.Diagnostics+1]=entry
  if #self.Diagnostics>500 then table.remove(self.Diagnostics,1) end
  if self.db and self.db.global and self.db.global.diagnostics then
    local list=self.db.global.diagnostics.entries
    if type(list)~="table" then list={} self.db.global.diagnostics.entries=list end
    list[#list+1]=entry
    if #list>500 then table.remove(list,1) end
  end
  return entry
end

function ZGV:LogInfo(context,message,payload,correlation)
  return self:Log("info",context,message,payload,correlation)
end

function ZGV:LogError(context, message,payload,correlation)
  local entry=self:Log("error",context,message,payload,correlation)
  self.Errors[#self.Errors+1]=entry
  if #self.Errors>100 then table.remove(self.Errors,1) end
  if self.db and self.db.global and self.db.global.diagnostics then
    local list=self.db.global.diagnostics.errors
    list[#list+1]=entry
    if #list>100 then table.remove(list,1) end
  end
end

function ZGV:LogEvent(feature,message,payload,severity,correlation)
  return self:Log(severity or "info",feature,message,payload,correlation)
end

function ZGV:SafeCall(context, callable, ...)
  if type(callable)~="function" then return false,"not callable" end
  local args={...}
  local function invoke() return callable(unpack(args)) end
  local results={xpcall(invoke,traceback)}
  if not results[1] then
    self:LogError(context,results[2])
    return false,results[2]
  end
  table.remove(results,1)
  return true,unpack(results)
end

function ZGV:Print(message)
  local text="|cffffa800Zygor:|r "..tostring(message or "")
  if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(text) elseif print then print(text) end
end

function ZGV:RegisterModule(name,module)
  assert(type(name)=="string" and name~="", "module name required")
  module=module or {}
  module.name=name
  module.ZGV=self
  if not self.Modules[name] then self.ModuleOrder[#self.ModuleOrder+1]=name end
  self.Modules[name]=module
  self[name]=module
  return module
end

function ZGV:RegisterCallback(event,owner,method)
  if type(owner)=="function" and method==nil then method,owner=owner,nil end
  local callbacks=self.Callbacks[event] or {}
  self.Callbacks[event]=callbacks
  callbacks[#callbacks+1]={owner=owner,method=method}
end

function ZGV:UnregisterCallback(event,owner,method)
  local callbacks=self.Callbacks[event]
  if not callbacks then return end
  for i=#callbacks,1,-1 do
    local callback=callbacks[i]
    if callback.owner==owner and (method==nil or callback.method==method) then
      table.remove(callbacks,i)
      if method~=nil then break end
    end
  end
  if #callbacks==0 then self.Callbacks[event]=nil end
end

function ZGV:Fire(event,...)
  local callbacks=self.Callbacks[event]
  if not callbacks then return end
  for i=1,#callbacks do
    local callback=callbacks[i]
    local fn=type(callback.method)=="string" and callback.owner and callback.owner[callback.method] or callback.method
    if type(fn)=="function" then
      if callback.owner then self:SafeCall("callback:"..event,fn,callback.owner,...)
      else self:SafeCall("callback:"..event,fn,...) end
    end
  end
end

function ZGV:RegisterEvent(event,owner,method)
  if type(owner)=="function" and method==nil then method,owner=owner,nil end
  local handlers=self._events[event] or {}
  self._events[event]=handlers
  handlers[#handlers+1]={owner=owner,method=method}
  self.EventFrame:RegisterEvent(event)
end

function ZGV:UnregisterEvent(event,owner,method)
  local handlers=self._events[event]
  if not handlers then return end
  for i=#handlers,1,-1 do
    local handler=handlers[i]
    if handler.owner==owner and (method==nil or handler.method==method) then
      table.remove(handlers,i)
      if method~=nil then break end
    end
  end
  if #handlers==0 then self._events[event]=nil self.EventFrame:UnregisterEvent(event) end
end

function ZGV:DispatchEvent(event,...)
  local handlers=self._events[event]
  if not handlers then return end
  for i=1,#handlers do
    local handler=handlers[i]
    local fn=type(handler.method)=="string" and handler.owner and handler.owner[handler.method] or handler.method
    if type(fn)=="function" then
      if handler.owner then self:SafeCall("event:"..event,fn,handler.owner,event,...)
      else self:SafeCall("event:"..event,fn,event,...) end
    end
  end
end

function ZGV:DoMutex(name)
  if self.Mutexes[name] then return true end
  self.Mutexes[name]=true
  return false
end

function ZGV:SetRegistrationSource(source,priority)
  self._registrationSource=source
  self._registrationPriority=priority or 0
end

function ZGV:RegisterContentPackage(manifest)
  if type(manifest)~="table" then return end
  self.ContentPackages=self.ContentPackages or {}
  self.ContentPackages[manifest.id or tostring(#self.ContentPackages+1)]=manifest
end

function ZGV:ContentPackageLoaded(manifest)
  self:Fire("ZGV_CONTENT_PACKAGE_LOADED",manifest)
end

function ZGV:GetDiagnosticsText()
  local out={
    self.displayName.." "..self.version,
    "target interface="..self.interface.." build="..self.targetBuild,
    "locale="..tostring(self.Locale),
    "guides="..tostring(self.Catalog and self.Catalog:Count() or 0),
  }
  local client=self.Compat and self.Compat.Client
  if client and client.GetBuild then
    local ok,record=pcall(client.GetBuild,client)
    if ok and type(record)=="table" then out[#out+1]="client="..tostring(record.version).." build="..tostring(record.build).." interface="..tostring(record.interface) end
  end
  out[#out+1]="errors="..tostring(#self.Errors)
  for i=1,#self.Errors do
    local entry=self.Errors[i]
    out[#out+1]=string.format("[%s] %s: %s",entry.time,entry.context,entry.message)
  end
  local first=math.max(1,#self.Diagnostics-39)
  if #self.Diagnostics>=first then out[#out+1]="recent diagnostics="..tostring(#self.Diagnostics-first+1) end
  for i=first,#self.Diagnostics do
    local entry=self.Diagnostics[i]
    out[#out+1]=string.format("[%s] %s %s: %s",entry.time,entry.level or "info",entry.context,entry.message)
  end
  return table.concat(out,"\n")
end

function ZGV:LoadContentAddons()
  local addons={"ZygorGuidesViewer_GuidesCommon"}
  local faction=type(UnitFactionGroup)=="function" and UnitFactionGroup("player") or nil
  if faction=="Alliance" then addons[#addons+1]="ZygorGuidesViewer_GuidesAlliance"
  elseif faction=="Horde" then addons[#addons+1]="ZygorGuidesViewer_GuidesHorde" end
  for i=1,#addons do
    local name=addons[i]
    if type(IsAddOnLoaded)~="function" or not IsAddOnLoaded(name) then
      local loaded,reason=LoadAddOn(name)
      if not loaded then self:LogError("content",name..": "..tostring(reason)) end
    end
  end
  if type(IsAddOnLoaded)~="function" or not IsAddOnLoaded("ZygorTalentAdvisor") then
    local _,reason=LoadAddOn("ZygorTalentAdvisor")
    if reason and reason~="MISSING" and reason~="DISABLED" then self:LogError("talents","ZygorTalentAdvisor: "..tostring(reason)) end
  end
end

function ZGV:Startup()
  if self._startupComplete then return end
  -- Saved diagnostics span reloads.  Tag every event from this process so
  -- the host-side exporter can surface fresh evidence without hiding the
  -- previous sessions needed for regression investigation.
  local stamp=type(date)=="function" and date("%Y%m%d-%H%M%S") or tostring(time())
  local tick=type(GetTime)=="function" and math.floor(GetTime()*1000) or 0
  self.diagnosticSession=stamp.."-"..tostring(tick)
  self:LogInfo("startup","initializing build "..tostring(self.targetBuild).." revision "..tostring(self.buildRevision))
  if self.Database then self.Database:Initialize() end
  if self.Maintenance and self.Maintenance:ShouldPauseStartup() then
    self:LogInfo("startup","maintenance mode requested; content startup paused")
    self.Maintenance:Show()
    return
  end
  self._startupComplete=true
  self:LoadContentAddons()
  if self.Catalog then self.Catalog:Finalize() end
  for index=1,#self.ModuleOrder do
    local module=self.Modules[self.ModuleOrder[index]]
    if type(module.OnStartup)=="function" then self:SafeCall("startup:"..module.name,module.OnStartup,module) end
  end
  self:Fire("ZGV_STARTED")
  self:LogInfo("startup","ready; guides="..tostring(self.Catalog and self.Catalog:Count() or 0))
end

function ZGV:ToggleFrame()
  if self.UI then self.UI:Toggle() end
end

ZGV.EventFrame=ZGV.EventFrame or CreateFrame("Frame","ZygorGuidesViewerEventFrame")
ZGV.EventFrame:SetScript("OnEvent",function(_,event,...)
  ZGV:DispatchEvent(event,...)
end)
ZGV:RegisterEvent("PLAYER_LOGIN",function() ZGV:Startup() end)

SLASH_ZYGOR1="/zygor"
SLASH_ZYGOR2="/zgv"
SlashCmdList.ZYGOR=function(text)
  text=tostring(text or "")
  local command,arg=text:match("^%s*(%S*)%s*(.-)%s*$")
  command=command:lower()
  if command=="" or command=="show" or command=="toggle" then ZGV:ToggleFrame()
  elseif command=="next" and ZGV.Runtime then ZGV.Runtime:NextStep(true)
  elseif command=="prev" and ZGV.Runtime then ZGV.Runtime:PreviousStep()
  elseif command=="menu" and ZGV.UI then ZGV.UI:ShowGuideMenu()
  elseif command=="options" and ZGV.UI then ZGV.UI:ShowOptions()
  elseif command=="sync" and ZGV.Sync then
    local ok,reason=ZGV.Sync:BroadcastProgress()
    if not ok then ZGV:Print("Sync: "..tostring(reason)) end
  elseif command=="gear" and ZGV.GearAdvisor then ZGV.GearAdvisor:Show()
  elseif command=="gearfind" and ZGV.GearFinder then ZGV.GearFinder:Show()
  elseif command=="maintenance" and ZGV.ShowMaintenance then ZGV:ShowMaintenance()
  elseif command=="gold" and ZGV.GoldTracker then ZGV.GoldTracker:Show()
  elseif command=="widget" and ZGV.GuideWidget then ZGV.GuideWidget:Toggle()
  elseif command=="widgets" and ZGV.Widgets then ZGV.Widgets:ToggleConfig()
  elseif command=="way" and ZGV.Pointer then ZGV.Pointer:SetWaypointByCommandLine(arg)
  elseif command=="poi" and ZGV.Poi then ZGV.Poi:ChangeState(not ZGV.Poi.enabled)
  elseif command=="checklist" and ZGV.Modules and ZGV.Modules.IntroWizard then ZGV.Modules.IntroWizard:Checklist()
  elseif command=="errors" or command=="log" then ZGV:Print("Use /zygor report to open diagnostics. Persistent entries are exported after logout with tools/export_zgv_diagnostics.py.") if ZGV.UI then ZGV.UI:ShowReport() end
  elseif command=="report" then if ZGV.UI then ZGV.UI:ShowReport() end
  elseif command=="guide" and arg~="" and ZGV.Runtime then ZGV.Runtime:SelectGuide(arg)
  elseif command=="reset" and ZGV.Runtime then ZGV.Runtime:ResetCurrentGuide()
  else ZGV:Print("Commands: /zygor, menu, next, prev, guide <title>, way <map> <x>,<y>, poi, checklist, options, gear, gearfind, maintenance, gold, widget, widgets, sync, report, log, reset") end
end
