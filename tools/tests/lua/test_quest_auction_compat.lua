local repo = assert(arg[1], "repository path is required")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2) end
end

local services, events, timers, fired = {}, {}, {}, {}
local now = 100
local Compat = {}
function Compat:CreateService(name) local service = {}; services[name] = service; self[name] = service; return service end
function Compat:RegisterEvent(event, owner, method) events[event] = { owner = owner, method = method } end
function Compat.Pack(...) return { n = select("#", ...), ... } end
function Compat.Bool(value) return value and true or false end
function Compat.Now() return now end
function Compat:Result(ok, code, data) data = data or {}; data.ok = ok and true or false; data.code = code; return data end
function Compat:Fire(event, payload) fired[#fired + 1] = { event = event, payload = payload } end
function Compat:ReportError(message) error(message, 2) end
Compat.Timer = {}
function Compat.Timer:After(delay, callback) timers[#timers + 1] = { delay = delay, callback = callback } end

ZygorGuidesViewer = { Compat = Compat }
ZGV = ZygorGuidesViewer

local nativeCompletedCalls, queryCalls = 0, 0
function GetQuestsCompleted(target)
  nativeCompletedCalls = nativeCompletedCalls + 1
  if type(target) ~= "table" then error("GetQuestsCompleted requires an output table") end
  target[101] = true
  target[303] = 1
end
function QueryQuestsCompleted() queryCalls = queryCalls + 1 end

dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/Compat/Quest.lua")
local Quest = assert(services.Quest)
local callbackResult
local started = Quest:RefreshCompleted(true, function(result) callbackResult = result end)
assertEqual(started.code, "query_started", "completed query start")
assertEqual(Quest.completedState, "querying", "querying cache state")
assertEqual(queryCalls, 1, "native query count")
assertEqual(nativeCompletedCalls, 0, "completion table waits for event")
assertEqual(#timers, 1, "query timeout scheduled")

Quest:OnEvent("QUEST_QUERY_COMPLETE")
assertEqual(nativeCompletedCalls, 1, "native output-table read count")
assertEqual(Quest.completedState, "ready", "event makes cache ready")
assertEqual(Quest.completedUpdatedAt, now, "event cache timestamp")
assertEqual(Quest:GetCompletion(101).completed, true, "boolean completion map")
assertEqual(Quest:GetCompletion(303).completed, true, "numeric completion map")
assertEqual(Quest:GetCompletion(999).known, true, "negative result is known after snapshot")
assertEqual(callbackResult and callbackResult.code, "ready", "query callback result")
assertEqual(fired[#fired].event, "QUEST_COMPLETED_CACHE_UPDATED", "cache update event")

timers[1].callback()
assertEqual(Quest.completedState, "ready", "resolved query ignores old timeout")

now = 120
local timeoutResult
Quest:RefreshCompleted(true, function(result) timeoutResult = result end)
assertEqual(Quest.completedState, "querying", "forced refresh starts a new query")
assertEqual(#timers, 2, "second timeout scheduled")
timers[2].callback()
assertEqual(Quest.completedState, "stale", "timed out snapshot becomes stale")
assertEqual(Quest:GetCompletion(101).completed, true, "timeout preserves last snapshot")
assertEqual(Quest:GetCompletion(101).known, true, "stale snapshot remains known")
assertEqual(timeoutResult and timeoutResult.code, "timeout", "timeout callback result")

now = 121
Quest:OnEvent("QUEST_QUERY_COMPLETE")
assertEqual(Quest.completedState, "ready", "late query event refreshes stale cache")

local fallbackOrder = {}
GetQuestsCompleted = function(target)
  if target ~= nil then
    fallbackOrder[#fallbackOrder + 1] = "table"
    error("server only supports a returned table")
  end
  fallbackOrder[#fallbackOrder + 1] = "noarg"
  return { [202] = true }
end
local fallback, fallbackError = Quest:_ReadCompleted()
assert(fallback and not fallbackError, tostring(fallbackError))
assertEqual(fallback[202], true, "no-argument server fallback")
assertEqual(table.concat(fallbackOrder, ","), "table,noarg", "native table form is attempted first")

local startArguments
function StartAuction(...) startArguments = { ... } end
dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/Compat/Auction.lua")
local Auction = assert(services.Auction)
Auction.open = true
local posted = Auction:Start(100, 500, 24, 5, 2)
assertEqual(posted.ok, true, "24-hour auction accepted")
assertEqual(startArguments[1], 100, "native minimum bid")
assertEqual(startArguments[2], 500, "native buyout")
assertEqual(startArguments[3], 2, "24 hours maps to native duration code 2")
assertEqual(startArguments[4], 5, "native stack size")
assertEqual(startArguments[5], 2, "native stack count")
assertEqual(posted.duration, 24, "result retains duration hours")
assertEqual(posted.durationCode, 2, "result reports native duration code")

posted = Auction:Start(100, 500, 3, 1, 1)
assertEqual(posted.ok, true, "pre-normalized duration accepted inside adapter")
assertEqual(startArguments[3], 3, "pre-normalized native duration code")
assertEqual(posted.duration, 48, "normalized result restores duration hours")
assertEqual(Auction:Start(100, 500, 36, 1, 1).code, "invalid_duration", "invalid duration rejected")

function GetActiveTalentGroup() return 1 end
function GetNumGlyphSockets() return 1 end
function GetGlyphSocketInfo(socket, group)
  assertEqual(socket, 1, "glyph socket argument")
  assertEqual(group, 1, "glyph group argument")
  return true, 2, 54321, "Interface\\Icons\\INV_Glyph_MajorMage"
end
function GetTalentInfo(tab, talent, inspect, isPet, group)
  assertEqual(tab, 1, "talent info tab argument")
  assertEqual(talent, 2, "talent info index argument")
  assertEqual(inspect, false, "talent info inspect argument")
  assertEqual(group, 1, "talent info group argument")
  return "Dependent Talent", "Interface\\Icons\\Spell_Test", 2, 1, 0, 1, false, not isPet
end
function GetTalentPrereqs(tab, talent, inspect, isPet)
  assertEqual(tab, 1, "talent prerequisite tab argument")
  assertEqual(talent, 2, "talent prerequisite index argument")
  assertEqual(inspect, false, "talent prerequisite inspect argument")
  return 1, 1, not isPet
end
dofile(repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/Compat/Talent.lua")
local Talent = assert(services.Talent)
local playerTalent = assert(Talent:GetInfo(1, 2, false))
assertEqual(playerTalent.prerequisiteTab, 1, "player prerequisite tab")
assertEqual(playerTalent.prerequisiteIndex, 1, "player prerequisite talent")
assertEqual(playerTalent.prerequisiteLearnable, true, "player prerequisite learnability")
local petTalent = assert(Talent:GetInfo(1, 2, true))
assertEqual(petTalent.prerequisiteTab, 1, "pet prerequisite tab")
assertEqual(petTalent.prerequisiteIndex, 1, "pet prerequisite talent")
assertEqual(petTalent.prerequisiteLearnable, false, "pet prerequisite learnability")
local glyphs = Talent:GetGlyphs(1)
assertEqual(#glyphs, 1, "glyph socket count")
assertEqual(glyphs[1].enabled, true, "glyph enabled tuple value")
assertEqual(glyphs[1].type, 2, "glyph type tuple value")
assertEqual(glyphs[1].spellID, 54321, "Wrath glyph spell ID tuple position")
assertEqual(glyphs[1].iconFileID, "Interface\\Icons\\INV_Glyph_MajorMage", "Wrath glyph icon tuple position")
assertEqual(glyphs[1].tooltipIndex, nil, "Wrath glyph tuple has no tooltip index")

print("quest and auction compatibility tests passed")
