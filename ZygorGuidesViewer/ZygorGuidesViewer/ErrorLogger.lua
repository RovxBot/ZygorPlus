-- Source-name facade for Core.lua and Compat/LoadDiagnostics.lua errors.
-- It intentionally does not replace the global error handler at runtime.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" then return end

function ZGV:ErrorLogger_GetErrors()
  local result, seen = {}, {}
  local function append(entries)
    for _, entry in ipairs(type(entries) == "table" and entries or {}) do
      local record = type(entry) == "table" and entry or { message = tostring(entry) }
      -- Core inserts the same record object into the live and persistent
      -- collections.  Deduplicate that shared reference, but retain genuinely
      -- repeated errors even when their text and timestamp are identical.
      if not seen[record] then
        seen[record] = true
        result[#result + 1] = {
          message = tostring(record.message or ""),
          time = record.time,
          context = record.context,
          session = record.session,
        }
      end
    end
  end
  append(self.Errors)
  append(self.db and self.db.global and self.db.global.diagnostics and self.db.global.diagnostics.errors)
  return result
end
