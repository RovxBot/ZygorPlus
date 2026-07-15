-- Keep the Classic version contract while reading metadata through the
-- build-12340 API.  C_AddOns does not exist on 3.3.5a.
local addonName, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local metadata = type(GetAddOnMetadata)=="function" and GetAddOnMetadata(addonName or ZGV.name,"Version") or nil
ZGV.revision = tonumber(string.sub("$Revision: 36749 $",12,-3))
ZGV.versionBase = metadata or ZGV.version or "8.1.0-wotlk.13"
ZGV.version = tostring(ZGV.versionBase).."."..tostring(ZGV.revision)
ZGV.date = string.sub("$Date: $WCDATE$ $",8,17)
