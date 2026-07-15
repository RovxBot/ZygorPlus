-- In-client micro test helper, retained for migrated developer scripts.
-- It is dormant unless ZGV.UseUnitTesting is deliberately enabled.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local Framework=ZGV.TestFramework or {PassText="|cff00ff00PASS|r",FailText="|cffff0000FAIL|r",numTests=0,passTests=0,failTests=0,locals={}}
ZGV.TestFramework=Framework
function Framework:Reset() self.numTests=0; self.passTests=0; self.failTests=0 end
function Framework:CheckLoad() return true end
function Framework.test(name,rethrow,callback,...)
  assert(name and callback,"test name and callback required")
  Framework.numTests=Framework.numTests+1
  local result={pcall(callback,...)}
  if not result[1] or result[2]==false or (result[1] and result[2]==nil) then
    Framework.failTests=Framework.failTests+1
    local message=not result[1] and result[2] or "assertion returned false or nil"
    if ZGV.Print then ZGV:Print(tostring(name)..": "..Framework.FailText.." "..tostring(message)) end
    if rethrow then error("Unit test failed: "..tostring(name)..": "..tostring(message),2) end
    return false,message
  end
  Framework.passTests=Framework.passTests+1
  if ZGV.Print then ZGV:Print(tostring(name)..": "..Framework.PassText) end
  return true,result[2]
end
function Framework.assertError(callback,...)
  local ok=pcall(callback,...); if ok then error("Unit test failed: expected an error",2) end; return true
end
function Framework.assertSuccess(callback,...)
  local ok,errorMessage=pcall(callback,...); if not ok then error("Unit test failed: "..tostring(errorMessage),2) end; return true
end
function Framework.fail(message) error(message or "Failed test.",2) end
