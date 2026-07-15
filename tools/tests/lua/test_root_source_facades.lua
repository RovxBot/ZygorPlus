local repo = assert(arg[1], "repository root required")
local addon = repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/"

time, date = os.time, os.date
UIParent = { name = "UIParent" }
local shownReport, activated, notificationShown = false, nil, nil

local function frame()
  local object = { points = {} }
  function object:ClearAllPoints() self.points = {} end
  function object:SetPoint(...) self.points = { ... } end
  function object:GetHeight() return 20 end
  return object
end

ZygorGuidesViewer = {
  version = "test", targetBuild = 12340, diagnosticSession = "test-session",
  Diagnostics = {}, Errors = {},
  db = {
    profile = { actionbar = { direction = 2 }, notifications = { x = -10, y = -20 } },
    global = { diagnostics = { errors = {}, entries = {} } },
  },
  Catalog = { guides = { { raw = "talk Test Guide NPC##99" } } },
  _NPCData = { Repair = "1287=sA|m1453|x64|y68 -- Stormwind City/0, Marda Weller" },
  Compat = {
    UI = { RunOutOfCombat = function(_, _, callback) callback(); return true end },
    Quest = {
      FindInLog = function(_, id)
        if id == 10 then return { questID = 10, title = "A Test Quest", level = 12, isComplete = false,
          objectives = { { text = "Wolf slain: 1/2", current = 1, required = 2, finished = false, type = "monster" } } } end
      end,
      IsCompleted = function() return false end,
    },
  },
  TooltipScanner = { GetTooltip = function() return {} end },
  UI = { ShowReport = function() shownReport = true end, Refresh = function() return true end },
  ActionBar = {
    buttons = { { id = 1 } },
    Create = function(self) self.frame = self.frame or frame(); return self.frame end,
    Refresh = function(self) self.refreshed = (self.refreshed or 0) + 1; return true end,
  },
  Runtime = {
    currentStep = 3,
    GetDisplayGoals = function() return { { goal = "goal", stepIndex = 3, goalIndex = 2 } } end,
    ActivateGoal = function(_, stepIndex, goalIndex) activated = { stepIndex, goalIndex }; return true end,
  },
  NotificationCenter = {
    anchor = frame(),
    Create = function(self) return self.anchor end,
    ShowOne = function(_, entry) notificationShown = entry; return true end,
    ShowNext = function(self) self.nextShown = true; return true end,
    CheckDynamicNotifications = function(self) self.dynamic = true; return true end,
    ApplySkin = function() return true end,
  },
}
ZGV = ZygorGuidesViewer

function ZGV:Log(level, context, message)
  local entry = { time = "now", level = level, context = context, message = message }
  self.Diagnostics[#self.Diagnostics + 1] = entry
  return entry
end
function ZGV:LogInfo(context, message) return self:Log("info", context, message) end
function ZGV:LogError(context, message)
  local entry = self:Log("error", context, message)
  self.Errors[#self.Errors + 1] = entry
  self.db.global.diagnostics.errors[#self.db.global.diagnostics.errors + 1] = entry
  return entry
end
function ZGV:GetDiagnosticsText() return "diagnostics-body" end
function ZGV:ScheduleTimer(callback) callback(); return true end
function ZGV:CancelTimer() return true end
function ZGV:SafeCall(_, callback, ...) return pcall(callback, ...) end
function ZGV:GetUnitId() return nil end

dofile(addon .. "Log.lua")
dofile(addon .. "ErrorLogger.lua")
dofile(addon .. "Localizers.lua")
dofile(addon .. "BugReport.lua")
dofile(addon .. "MacroGuide.lua")
dofile(addon .. "NotificationCenter.lua")
dofile(addon .. "ActionBar.lua")

ZGV:LogInfo("headless", "callable table still supports Core-style logging")
ZGV.Log:Add("legacy %s", "entry")
assert(ZGV.Log:Dump(2):find("legacy entry", 1, true), "legacy Log facade delegates to diagnostics")
ZGV:LogError("test", "one error")
assert(#ZGV:ErrorLogger_GetErrors() == 1, "error facade deduplicates live and persistent references")

local npc, _, found = ZGV.Localizers:GetTranslatedNPC(1287)
assert(npc == "Marda Weller" and found, "NPC name indexed from WotLK corpus")
assert(ZGV.Localizers:FindNPCIdByName("Test Guide NPC") == 99, "NPC name indexed from installed guides")
local quest, inLog = ZGV.Localizers:GetQuestData(10)
assert(inLog and quest.title == "A Test Quest" and quest.goals[1].needed == 2, "quest data delegates to Compat.Quest")

local report = ZGV.BugReport:GetReport()
assert(report:find("CLASSIC%-WOTLK") and report:find("diagnostics%-body"), "report facade includes runtime diagnostics")
ZGV.BugReport:GenerateAndShow()
assert(shownReport, "report facade opens the target diagnostic viewer")
assert(ZGV:Serialize({ b = 2, a = 1 }) == "{[\"a\"]=1,[\"b\"]=2}", "serializer remains deterministic")

local button = { attributes = {}, icon = { SetTexture = function(self, value) self.value = value end } }
function button:RegisterForClicks() end
function button:RegisterForDrag() end
function button:SetAttribute(key, value) self.attributes[key] = value end
ZGV.MacroGuideProto.ActionButtonPrepare(button)
local macro = setmetatable({ name = "Test", body = "/say hello", icon = "INV_MISC_QUESTIONMARK", updateHandlers = {} }, ZGV.MacroGuideProto_mt)
assert(button:SetMacro(macro), "macro facade configures a secure button")
assert(button.attributes.type == "macro" and button.attributes.macrotext == "/say hello", "macro text is contextual")
local created, reason = macro:CreateMacro()
assert(created == nil and reason == "secure_action_button", "facade does not create permanent player macros")

local actionFrame = ZGV.ActionBar:Create()
assert(ZGV.ActionBar.Frame == actionFrame and ZGV.ActionBar:IsExpandingRight(), "ActionBar source aliases are restored")
assert(ZGV.ActionBar:SetButton(nil, nil, nil, 1).id == 1, "SetButton delegates to the modern set")
assert(ZGV.ActionBar:CreateGoaltype("goal") and activated[1] == 3 and activated[2] == 2, "CreateGoaltype delegates to Runtime")

ZGV.NotificationCenter:UpdatePosition()
local notice = { ident = "test" }
assert(ZGV.NotificationCenter:ShowSpecial(notice) and notificationShown == notice, "special notification delegates to ShowOne")
ZGV.NotificationCenter.HandleQueue()
assert(ZGV.NotificationCenter.nextShown, "source queue entry point delegates to modern queue")

print("root source facade headless tests passed")
