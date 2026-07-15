-- Temporary loader diagnostic for the 3.3 client.  Some unrelated addons
-- replace the global error handler with one that fails while reporting errors,
-- hiding the useful Lua message from FrameXML.log.  Keep a safe handler only
-- while the ported files are being loaded; LoadDiagnosticsEnd.lua restores it.
local oldHandler = type(geterrorhandler) == "function" and geterrorhandler() or nil
_G.ZGVLoadDiagnosticPreviousErrorHandler = oldHandler

if type(seterrorhandler) == "function" then
  seterrorhandler(function(message)
    local ZGV = _G.ZygorGuidesViewer
    if type(ZGV) == "table" then
      ZGV.Errors = ZGV.Errors or {}
      ZGV.Errors[#ZGV.Errors + 1] = {
        time = type(date) == "function" and date("%Y-%m-%d %H:%M:%S") or "load",
        context = "load",
        message = tostring(message),
      }
    end
    return tostring(message)
  end)
end
