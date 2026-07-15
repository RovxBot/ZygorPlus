-- Source-name facade for the bounded diagnostics store in Core.lua.
--
-- Core exposes ZGV:Log(...), while the Classic source exposed ZGV.Log as a
-- table with Add/Print/Dump.  A callable table preserves both contracts and
-- keeps one authoritative ring rather than creating a second logging engine.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" then return end

local diagnosticLog = ZGV.Log
if type(diagnosticLog) ~= "function" then return end

local LegacyLog = {
  entries = ZGV.Diagnostics,
  size = 500,
  loud = false,
  _diagnosticLog = diagnosticLog,
}

local function formatEntry(entry)
  if type(entry) ~= "table" then return tostring(entry or "") end
  return string.format("[%s] %s %s: %s", tostring(entry.time or "?"),
    tostring(entry.level or "info"), tostring(entry.context or "runtime"), tostring(entry.message or ""))
end

setmetatable(LegacyLog, {
  __call = function(_, owner, level, context, message)
    if owner ~= ZGV then
      message, context, level, owner = context, level, owner, ZGV
    end
    return diagnosticLog(owner, level, context, message)
  end,
})
ZGV.Log = LegacyLog

function LegacyLog:SetSize(size)
  self.size = math.max(1, math.min(500, math.floor(tonumber(size) or 500)))
  self:Trim()
  return self.size
end

function LegacyLog:Trim()
  local entries = ZGV.Diagnostics or {}
  self.entries = entries
  while #entries > self.size do table.remove(entries, 1) end
  return #entries
end

function LegacyLog:Add(formatString, ...)
  local ok, message = pcall(string.format, tostring(formatString or ""), ...)
  if not ok then message = tostring(formatString or "") end
  local entry = diagnosticLog(ZGV, "info", "legacy", message)
  self.entries = ZGV.Diagnostics
  self:Trim()
  if self.loud then
    local chat = ChatFrame1 or DEFAULT_CHAT_FRAME
    if chat and type(chat.AddMessage) == "function" then chat:AddMessage(formatEntry(entry)) end
  end
  return entry
end

function LegacyLog:Print(count)
  local entries = ZGV.Diagnostics or {}
  count = math.min(tonumber(count) or #entries, #entries)
  local chat = ChatFrame1 or DEFAULT_CHAT_FRAME
  if not chat or type(chat.AddMessage) ~= "function" then return 0 end
  for index = math.max(1, #entries - count + 1), #entries do chat:AddMessage(formatEntry(entries[index])) end
  return count
end

function LegacyLog:Dump(count)
  local entries, output = ZGV.Diagnostics or {}, {}
  count = math.min(tonumber(count) or #entries, #entries)
  for index = math.max(1, #entries - count + 1), #entries do output[#output + 1] = formatEntry(entries[index]) end
  return table.concat(output, "\n") .. (#output > 0 and "\n" or "")
end
