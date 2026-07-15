local repo = assert(arg[1], "repository path required")
local addon = repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/"

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    error((message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

local refreshes, skinChanges = 0, 0
ZygorGuidesViewer = {
  Modules = {},
  Errors = {}, Diagnostics = {},
  UI = { Refresh = function() refreshes = refreshes + 1 end },
}
ZGV = ZygorGuidesViewer

function ZGV:RegisterModule(name, module)
  module = module or {}
  self.Modules[name], self[name] = module, module
  return module
end
function ZGV:Fire() end
function ZGV:SetSkin() skinChanges = skinChanges + 1 end
function UnitName() return "OptionsTester" end
function GetRealmName() return "TestRealm" end

dofile(addon .. "Database.lua")
ZGV.Database:Initialize()
dofile(addon .. "Options.lua")

local Options = assert(ZGV.Options, "Options module must register")
assert(Options:EnsureDefaults(), "option defaults must initialize")
ZGV.db.profile.automation.accept = false

local groups = Options:GetGroups()
assert(#groups >= 11, "Classic options menu must expose all major setting groups")
local seen = {}
for _, group in ipairs(groups) do
  assert(type(group.id) == "string" and group.id ~= "", "setting group requires an id")
  assert(not seen[group.id], "setting group ids must be unique")
  seen[group.id] = true
  assert(type(group.options) == "table" and #group.options > 0, "setting group cannot be empty")
end
assert(Options:GetGroup("map") == Options:GetGroup("maps"), "legacy map alias must resolve")
assert(Options:GetGroup("navigation") == Options:GetGroup("travelsystem"), "legacy navigation alias must resolve")

local accept = Options:GetGroup("automation").options[1]
assertEqual(Options:GetValueText(accept), "OFF", "toggle label reflects stored value")
assert(Options:Activate(accept), "toggle option must activate")
assertEqual(ZGV.db.profile.automation.accept, true, "toggle option updates profile")
assertEqual(Options:GetValueText(accept), "ON", "toggle label refreshes")

local scale = Options:GetGroup("display").options[4]
ZGV.db.profile.viewer.scale = scale.max
Options:Activate(scale)
assertEqual(ZGV.db.profile.viewer.scale, scale.min, "range wraps at its maximum")
Options:Activate(scale, true)
assertEqual(ZGV.db.profile.viewer.scale, scale.max, "reverse range wraps at its minimum")

local role = Options:GetGroup("gear").options[4]
assertEqual(Options:GetValueText(role), "Automatic", "unset role uses automatic scoring")
Options:Activate(role)
assertEqual(ZGV.db.profile.gear.role, "melee", "role selector uses ItemScore-compatible role keys")
Options:Activate(role, true)
assertEqual(ZGV.db.profile.gear.role, false, "reverse role selection returns to automatic")
local weights = Options:GetGroup("gear").options[5]
assertEqual(weights.action, "gearWeights", "gear options expose the custom stat-weight editor")

local copied, copiedName = ZGV.Database:CopyProfile()
assert(copied and copiedName == "Default Copy", "profile service creates and selects an independent copy")
local activeProfile = Options:GetGroup("about").options[1]
assertEqual(Options:GetValueText(activeProfile), "Default Copy", "profile row shows the active profile")
Options:Activate(activeProfile)
assertEqual(ZGV.db.profileKey, "Default", "profile row cycles through saved profiles")

local glass = Options:GetGroup("display").options[3]
Options:Activate(glass)
assertEqual(skinChanges, 1, "skin option applies immediately")
assert(refreshes >= 6, "option changes refresh their live consumers")

ZGV:Options_DefineOptionTables()
assertEqual(#ZGV.optiontables_ordered, #groups, "legacy option API exposes every group")

print("Classic options contract tests passed")
