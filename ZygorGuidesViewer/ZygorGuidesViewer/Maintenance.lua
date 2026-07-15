-- Safe-start diagnostics for the 3.3.5a client.  Shift held during login
-- opens this frame before content addons are loaded, mirroring the original
-- maintenance escape hatch without relying on retail Settings APIs.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Maintenance=ZGV:RegisterModule("Maintenance",{prefix="maint_"})
local flags={
  "maint_dostartup","maint_startup_01","maint_startup_pointer","maint_startup_modules",
  "maint_startup_loadguides","maint_startup_final","maint_startup_startguide",
  "maint_enableprogressbar","maint_fetchquestdata","maint_fetchitemdata",
}
Maintenance.flags=flags

function Maintenance:InitializeFlags(value)
  if not (ZGV.db and ZGV.db.char) then return end
  for _,name in ipairs(flags) do if ZGV.db.char[name]==nil then ZGV.db.char[name]=value~=false end end
end

function Maintenance:SetFlag(name,value)
  if ZGV.db and ZGV.db.char and name then ZGV.db.char[name]=value and true or false end
end

function Maintenance:SyncButton(button)
  if not button then return end
  if button.text and button.txt then button.text:SetText(button.txt) end
  if button.var and ZGV.db and ZGV.db.char then button:SetChecked(ZGV.db.char[button.var] and true or false) end
end

function Maintenance:Sync()
  local frame=_G.ZygorGuidesViewerMaintenanceFrame
  if not frame then return end
  for index=1,#flags do self:SyncButton(_G[frame:GetName()..("_But%02d"):format(index)]) end
end

function Maintenance:Show()
  self:InitializeFlags(true)
  local frame=_G.ZygorGuidesViewerMaintenanceFrame
  if frame then self:Sync() frame:Show() end
end

function Maintenance:Report()
  if ZGV.UI and ZGV.UI.ShowReport then ZGV.UI:ShowReport()
  elseif ZGV.Print then ZGV:Print("Open /zygor report to view diagnostics.") end
end

function Maintenance:ShouldPauseStartup()
  if IsShiftKeyDown and IsShiftKeyDown() then
    self:InitializeFlags(false)
    for _,name in ipairs(flags) do ZGV.db.char[name]=false end
    return true
  end
  -- Once safe-start is requested it stays paused across reloads until the
  -- first gate is explicitly enabled from the panel.
  return ZGV.db and ZGV.db.char and ZGV.db.char.maint_dostartup==false
end

function Maintenance:OnStartup()
  self:InitializeFlags(true)
  self:Sync()
end

function ZGV:ShowMaintenance() return Maintenance:Show() end
