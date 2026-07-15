local repo = assert(arg[1], "repository path is required")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2) end
end

local modules, hooks, events, fired = {}, {}, {}, {}
local selectedName, selectedIndex = "Cancelled Quest", 4

ZygorGuidesViewer = {
  Compat = {
    UI = {},
    Quest = {},
  },
  Runtime = { ActivateGoal = function() return "original" end },
  db = {
    profile = { automation = {} },
    global = {},
    char = { abandoned = {} },
  },
  L = {},
  SKINDIR = "",
}
local ZGV = ZygorGuidesViewer

function ZGV:RegisterModule(name, module) modules[name] = module; self[name] = module; return module end
function ZGV:RegisterEvent(event, owner, method) events[event] = { owner = owner, method = method } end
function ZGV:RegisterCallback() end
function ZGV:Fire(event, ...) fired[#fired + 1] = { event = event, args = { ... } } end
function ZGV:AbandonedQuestEvent(title, questID) self:Fire("ZGV_QUEST_ABANDONED", title, questID) end
function ZGV:Print() end
function ZGV:LogError() end
function ZGV.Compat.UI:CreateSecureActionButton() return nil end
function ZGV.Compat.Quest:GetLogEntry(index)
  if index == selectedIndex then return { index = index, questID = 24680, title = selectedName } end
end

UIParent = {}
function GetTime() return 50 end
function time() return 1700000000 end
function GetAbandonQuestName() return selectedName end
function GetQuestLogSelection() return selectedIndex end
function SetAbandonQuest() end
function AbandonQuest() end
function hooksecurefunc(name, callback)
  hooks[name] = hooks[name] or {}
  hooks[name][#hooks[name] + 1] = callback
end

dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/Automation.lua")
local Automation = assert(modules.Automation)
Automation:OnStartup()
assertEqual(#hooks.SetAbandonQuest, 1, "SetAbandonQuest hook")
assertEqual(#hooks.AbandonQuest, 1, "AbandonQuest hook")

-- Opening and then cancelling Blizzard's confirmation popup must not create a
-- saved abandonment entry.
SetAbandonQuest()
hooks.SetAbandonQuest[1]()
assertEqual(Automation.pendingAbandon.name, "Cancelled Quest", "pending quest title")
assertEqual(#Automation.abandoned, 0, "cancelled abandon is not persisted")
assertEqual(#fired, 0, "cancelled abandon emits no event")

-- A later confirmation replaces the stale pending dialog state, then records
-- exactly the quest whose AbandonQuest call was confirmed.
selectedName, selectedIndex = "Confirmed Quest", 4
SetAbandonQuest()
hooks.SetAbandonQuest[1]()
AbandonQuest()
hooks.AbandonQuest[1]()
assertEqual(#Automation.abandoned, 1, "confirmed abandon count")
assertEqual(Automation.abandoned[1].name, "Confirmed Quest", "confirmed quest title")
assertEqual(Automation.abandoned[1].questID, 24680, "confirmed quest ID")
assertEqual(Automation.abandoned[1].time, 1700000000, "confirmed timestamp")
assertEqual(Automation.pendingAbandon, nil, "pending state cleared")
assertEqual(ZGV.db.char.abandoned, Automation.abandoned, "saved abandonment list")
assertEqual(fired[1].event, "ZGV_QUEST_ABANDONED", "abandonment event")
assertEqual(fired[1].args[1], "Confirmed Quest", "event quest title")
assertEqual(fired[1].args[2], 24680, "event quest ID")

-- A bare AbandonQuest call without a matching SetAbandonQuest is ignored.
hooks.AbandonQuest[1]()
assertEqual(#Automation.abandoned, 1, "bare confirmation is ignored")

print("automation abandon confirmation tests passed")
