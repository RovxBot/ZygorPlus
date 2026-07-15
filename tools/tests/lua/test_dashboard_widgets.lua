local repo = assert(arg[1], "repository root required")
local registered = {}

time = function() return 123456 end
UnitLevel = function() return 42 end

ZygorGuidesViewer = {
  db = { profile = { history = {} }, char = {} },
  Widgets = {
    RegisterWidget = function(self, object)
      assert(type(object.ident) == "string" and object.ident ~= "", "widget identifier")
      assert(not registered[object.ident], "duplicate widget " .. object.ident)
      registered[object.ident] = object
      return object
    end,
  },
}

dofile(repo .. "/ZygorGuidesViewerNew/ZygorGuidesViewer/DashboardWidgets.lua")

for _, ident in ipairs({ "guidehistory", "guidesuggest", "timeplayed", "dailyreset", "bank", "gold", "worldevents" }) do
  assert(registered[ident], "missing dashboard widget " .. ident)
end
assert(ZygorGuidesViewer.DashboardWidgets.FormatDuration(59) == "0m 59s", "seconds formatting")
assert(ZygorGuidesViewer.DashboardWidgets.FormatDuration(3661) == "1h 1m", "hour formatting")
assert(ZygorGuidesViewer.DashboardWidgets.FormatDuration(90061) == "1d 1h", "day formatting")

registered.timeplayed:OnEvent("TIME_PLAYED_MSG", 1234, 234)
local played = ZygorGuidesViewer.db.char.dashboardTimePlayed
assert(played.total == 1234 and played.level == 234 and played.playerLevel == 42 and played.updated == 123456, "time-played persistence")

assert(registered.dailyreset.tick == 1, "daily reset refresh cadence")
assert(registered.worldevents.valid() == false, "calendar widget is hidden without WotLK calendar globals")

print("dashboard widget headless tests passed")

