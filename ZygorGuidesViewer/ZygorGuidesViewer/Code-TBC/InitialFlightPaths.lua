-- The static eight-race seed is intentionally replaced by live taxi capture.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local Taxi=ZGV and ZGV.Compat and ZGV.Compat.Taxi
if type(Taxi)~="table" then return end

ZGV.InitialFlightPaths=Taxi
local function bindSavedTaxiCache()
  local known=ZGV.db and ZGV.db.profile and ZGV.db.profile.navigation and ZGV.db.profile.navigation.knownTaxi
  if type(known)~="table" or type(Taxi.Startup)~="function" then return false end
  Taxi:Startup(known)
  return true
end
if not bindSavedTaxiCache() and type(ZGV.RegisterCallback)=="function" then
  ZGV:RegisterCallback("ZGV_STARTED",bindSavedTaxiCache)
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.InitialFlightPaths=Taxi
