if type(seterrorhandler) == "function" and type(_G.ZGVLoadDiagnosticPreviousErrorHandler) == "function" then
  seterrorhandler(_G.ZGVLoadDiagnosticPreviousErrorHandler)
end
_G.ZGVLoadDiagnosticPreviousErrorHandler = nil
