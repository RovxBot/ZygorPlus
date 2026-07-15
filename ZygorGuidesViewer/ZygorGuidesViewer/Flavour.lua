-- Client-flavour guard.  The Classic file uses WOW_PROJECT_ID, which does
-- not exist on the 3.3.5a client and would therefore display a false
-- "wrong flavour" dialog on every login.  Validate build/interface instead.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Flavour=ZGV:RegisterModule("Flavour",{})
function Flavour:GetClient()
  local version,build,_,interface=GetBuildInfo()
  return {version=tostring(version or "unknown"),build=tonumber(build),interface=tonumber(interface)}
end
function Flavour:IsSupported()
  local client=self:GetClient()
  return client.interface==30300 or client.build==12340,client
end
function Flavour:OnStartup()
  local supported,client=self:IsSupported()
  if supported then return true end
  local message="Zygor Guides Viewer WotLK requires WoW 3.3.5a (build 12340). Detected "..client.version.." (build "..tostring(client.build or "unknown")..")."
  ZGV:LogError("flavour",message)
  if StaticPopupDialogs and StaticPopup_Show then
    StaticPopupDialogs.ZYGOR_WRONGFLAVOR={text=message,button1=OKAY or "OK",timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
    StaticPopup_Show("ZYGOR_WRONGFLAVOR")
  else ZGV:Print(message) end
  return false
end
