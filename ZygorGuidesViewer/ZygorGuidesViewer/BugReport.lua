-- Source-name diagnostics/report facade for the WotLK port.
--
-- The original module implemented upload and rating windows tied to retail UI
-- libraries.  Core.lua now owns a bounded, session-tagged diagnostics store;
-- this facade keeps the useful report, serialization, feedback, and rating
-- entry points without attempting network submission or arbitrary file writes.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" then return end

local BugReport = ZGV.BugReport or {}
ZGV.BugReport = BugReport
BugReport.StepFeedback = BugReport.StepFeedback or {}
BugReport.GuideRating = BugReport.GuideRating or {}
local StepFeedback, GuideRating = BugReport.StepFeedback, BugReport.GuideRating

local function safe(callable, ...)
  if type(callable) ~= "function" then return nil end
  local ok, first, second, third = pcall(callable, ...)
  if ok then return first, second, third end
end

local function dumpValue(value, depth, maxDepth, seen)
  local kind = type(value)
  if kind == "string" then return string.format("%q", value) end
  if kind == "number" or kind == "boolean" or kind == "nil" then return tostring(value) end
  if kind ~= "table" then return "<" .. kind .. ">" end
  depth, maxDepth, seen = depth or 0, maxDepth or 4, seen or {}
  if seen[value] then return "<cycle>" end
  if depth >= maxDepth then return "{...}" end
  seen[value] = true
  local keys, output = {}, {}
  for key in pairs(value) do keys[#keys + 1] = key end
  table.sort(keys, function(left, right) return tostring(left) < tostring(right) end)
  for _, key in ipairs(keys) do
    output[#output + 1] = "[" .. dumpValue(key, depth + 1, maxDepth, seen) .. "]="
      .. dumpValue(value[key], depth + 1, maxDepth, seen)
  end
  seen[value] = nil
  return "{" .. table.concat(output, ",") .. "}"
end

function BugReport:GetReport_Flavor()
  return "CLASSIC-WOTLK"
end

function BugReport:GetReport_Player_Basic()
  local name = safe(UnitName, "player") or "unknown"
  local _, class = safe(UnitClass, "player")
  local _, race = safe(UnitRace, "player")
  local level = safe(UnitLevel, "player") or 0
  local faction = safe(UnitFactionGroup, "player") or "unknown"
  return string.format("Player: %s; level %s %s %s; faction %s\n", tostring(name), tostring(level),
    tostring(race or "unknown"), tostring(class or "unknown"), tostring(faction))
end

function BugReport:GetReport_Player_Location()
  local map = ZGV.Compat and ZGV.Compat.Map
  local position = map and map:GetPlayerPosition("player") or nil
  if not position or not position.valid then return "Location: unavailable\n" end
  local name = ZGV.GetMapNameByID and ZGV.GetMapNameByID(position.key) or position.key
  return string.format("Location: %s (%s), %.2f, %.2f\n", tostring(name or "unknown"),
    tostring(position.key or "?"), (tonumber(position.x) or 0) * 100, (tonumber(position.y) or 0) * 100)
end

function BugReport:GetReport_Travel()
  local navigation = ZGV.Navigation
  local state = navigation and type(navigation.GetArrowState) == "function" and navigation:GetArrowState() or nil
  if not state or state.status == "none" then return "Travel: no active destination\n" end
  return string.format("Travel: %s; target %s; distance %s\n", tostring(state.status),
    tostring(state.title or "unknown"), state.distance and string.format("%.1f", state.distance) or "unknown")
end

function BugReport:GetReport()
  local runtime = ZGV.Runtime
  local guide = runtime and runtime.currentGuide
  local header = {
    string.format("Zygor Guides Viewer v%s %s", tostring(ZGV.version or "?"), self:GetReport_Flavor()),
    string.format("Guide: %s", tostring(guide and (guide.title or guide.name) or "no guide")),
    string.format("Step: %s", tostring(runtime and runtime.currentStep or 0)),
    self:GetReport_Player_Basic():gsub("\n$", ""),
    self:GetReport_Player_Location():gsub("\n$", ""),
    self:GetReport_Travel():gsub("\n$", ""),
  }
  local diagnostics = type(ZGV.GetDiagnosticsText) == "function" and ZGV:GetDiagnosticsText() or "Diagnostics unavailable"
  return table.concat(header, "\n") .. "\n\n" .. diagnostics
end

function BugReport:GenerateAndShow(maintenance)
  local report = self:GetReport(maintenance)
  return ZGV:ShowDump(report, maintenance and "Zygor maintenance report" or "Zygor diagnostics")
end

function BugReport:SaveDump(text, timestamp, header, addonmodule, severity, geardump)
  local report = self:FormatDumpForUpload(text, header, addonmodule, severity, geardump)
  self.lastDump = { text = report, time = timestamp or (time and time() or 0), module = addonmodule, severity = severity }
  if type(ZGV.LogError) == "function" then ZGV:LogError(addonmodule or "bugreport", report) end
  return report
end

function BugReport:PruneDumps()
  -- Core.lua enforces the 100-error/500-entry bounds as records are inserted.
  return #(ZGV.Errors or {})
end

function BugReport:GetUniqueId()
  self.serial = (self.serial or 0) + 1
  return table.concat({ tostring(ZGV.diagnosticSession or "session"), tostring(time and time() or 0), tostring(self.serial) }, "-")
end

function BugReport:SimpleDump(value)
  return dumpValue(value, 0, 4, {})
end

function BugReport:FormatDumpForUpload(content, moreHeaders, addonmodule, severity, geardump)
  local headers = {
    "report_format=wotlk-diagnostics-1",
    "addon_version=" .. tostring(ZGV.version or "unknown"),
    "client_build=" .. tostring(ZGV.targetBuild or 12340),
    "session=" .. tostring(ZGV.diagnosticSession or "bootstrap"),
    "module=" .. tostring(addonmodule or "viewer"),
    "severity=" .. tostring(severity or "report"),
  }
  if moreHeaders and tostring(moreHeaders) ~= "" then headers[#headers + 1] = tostring(moreHeaders):gsub("\n$", "") end
  if geardump and tostring(geardump) ~= "" then headers[#headers + 1] = "gear=" .. tostring(geardump) end
  return table.concat(headers, "\n") .. "\n\n" .. tostring(content or "")
end

function BugReport:GetDumpBody(report)
  return tostring(report or ""):match("\n\n(.*)") or tostring(report or "")
end

function ZGV:ShowDump(text, title)
  BugReport.lastShown = { text = tostring(text or ""), title = tostring(title or "Zygor diagnostics") }
  if self.UI and type(self.UI.ShowReport) == "function" then self.UI:ShowReport()
  elseif type(self.Print) == "function" then self:Print(BugReport.lastShown.title .. " is ready in diagnostics.") end
  return BugReport.lastShown.text
end

function BugReport:DelayedShowReportDialog(report)
  if type(ZGV.ScheduleTimer) == "function" then
    return ZGV:ScheduleTimer(function() BugReport:ShowReportDialog(report) end, .01)
  end
  return self:ShowReportDialog(report)
end

function BugReport:ShowReportDialog(report)
  return ZGV:ShowDump(report or self:GetReport(), "Zygor diagnostics")
end

function ZGV:DumpVal(value, level, maxLevel)
  return dumpValue(value, tonumber(level) or 0, tonumber(maxLevel) or 4, {})
end

function ZGV:Serialize(value, level)
  return dumpValue(value, tonumber(level) or 0, 12, {})
end

function BugReport:ApplySkin()
  if ZGV.UI and type(ZGV.UI.Refresh) == "function" then return ZGV.UI:Refresh() end
end

function StepFeedback:CreateFrame(itemlink)
  self.itemlink = itemlink
  local ui = ZGV.UI
  if ui and type(ui.CreateFrame) == "function" then ui:CreateFrame() end
  local frame = ui and ui.frame or nil
  self.Frame = frame
  if frame and type(frame.UpdateLayout) ~= "function" then
    frame.UpdateLayout = function(_, ...) return StepFeedback:UpdateLayout(...) end
  end
  return frame
end
function StepFeedback:UpdateLayout(ftype, component, itemlink)
  if ftype ~= nil then self.ftype = ftype end
  if component ~= nil then self.component = component end
  if itemlink ~= nil then self.itemlink = itemlink end
  return true
end
function StepFeedback:Clear(ftype, component, itemlink)
  self.ftype, self.component, self.itemlink = ftype, component, itemlink
  self.text = nil
end
function StepFeedback:ApplySkin() return BugReport:ApplySkin() end
function StepFeedback:Show(ftype, component, itemlink)
  self:Clear(ftype, component, itemlink)
  return ZGV:ShowDump(BugReport:GetReport(), "Guide step feedback")
end
function StepFeedback:Hide() return true end
function StepFeedback:GetGuideStepSignature()
  local runtime, guide = ZGV.Runtime, ZGV.Runtime and ZGV.Runtime.currentGuide
  return tostring(guide and (guide.title or guide.name) or "??") .. "::" .. tostring(runtime and runtime.currentStep or "??")
end
function StepFeedback:GetStepReportHeader()
  return "guide_step=" .. self:GetGuideStepSignature() .. "\n"
end
function StepFeedback:FindStepReportForCurrentStep()
  local signature = self:GetGuideStepSignature()
  for _, entry in ipairs(ZGV.Errors or {}) do
    if tostring(entry.message or ""):find(signature, 1, true) then return entry end
  end
end
function StepFeedback:Save(text, addonmodule, severity, geardump)
  self.text = tostring(text or "")
  return BugReport:SaveDump(self.text, nil, self:GetStepReportHeader(), addonmodule or "step-feedback", severity, geardump)
end
function StepFeedback:ShowTooltip(text)
  if not GameTooltip then return end
  GameTooltip:SetOwner(ZGV.Frame or UIParent, "ANCHOR_TOP")
  GameTooltip:SetText(type(text) == "string" and text or "Report a problem with this guide step.", 1, 1, 1, true)
  GameTooltip:Show()
end

function GuideRating:NextRatingGuide()
  local runtime, guide = ZGV.Runtime, ZGV.Runtime and ZGV.Runtime.currentGuide
  local nextGuide = guide and guide.next
  if nextGuide and runtime and type(runtime.SelectGuide) == "function" then return runtime:SelectGuide(nextGuide) end
  return false
end
function GuideRating:CreateFrame() return nil end
function GuideRating:CreateAltFrame() return nil end
function GuideRating:CreateCancelledFrame() return nil end
function GuideRating:Save(text)
  if type(ZGV.LogInfo) == "function" then ZGV:LogInfo("guide-rating", tostring(text or self.score or "unrated")) end
  return true
end
function GuideRating:GetStepReportHeader()
  return "guide_rating=" .. tostring(self.score or "unrated") .. "\n"
end
function GuideRating:HideRatingWidgets()
  for _, frame in ipairs({ self.GuideRatingViewer, self.NoRatingFrame, self.ZygorPopup, self.ZygorPopupOn }) do
    if frame and type(frame.Hide) == "function" then frame:Hide() end
  end
end
function GuideRating:ShowGuideRating() return ZGV:ShowDump(BugReport:GetReport(), "Guide rating") end
function GuideRating:ClearRateState() self.score = nil return true end
function GuideRating:Popup() return self:ShowGuideRating() end
function GuideRating:Position() return false end
function GuideRating:UpdateText() return tostring(self.score or "unrated") end
