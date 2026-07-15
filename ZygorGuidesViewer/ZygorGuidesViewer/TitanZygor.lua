-- Optional Titan Panel bridge.  All calls are guarded so this file is safe
-- when Titan is absent, while a loaded Titan Panel receives the full legacy
-- plugin contract and live step updates.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local ID="Zygor"
local function update()
  if TitanPanelPluginHandle_OnUpdate then TitanPanelPluginHandle_OnUpdate({ID,TITAN_PANEL_UPDATE_BUTTON}) end
end
function TitanPanelZygorButton_OnLoad(self)
  if not TITAN_VERSION then return end
  self.registry={id=ID,category="General",version=ZGV.version,menuText="Zygor Guides",buttonTextFunction="TitanPanelZygorButton_GetButtonText",tooltipTitle="Zygor Guides",tooltipTextFunction="TitanPanelZygorButton_GetTooltipText",icon=ZGV.SKINDIR.."zglogo",iconWidth=16,iconCoords={0,1,0,.25},controlVariables={ShowIcon=true,ShowLabelText=true,ShowRegularText=false,ShowColoredText=true,DisplayOnRightSide=false},savedVariables={ShowIcon=1,ShowLabelText=1,ShowColoredText=1}}
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
function TitanPanelZygorButton_OnEvent(self)
  if TITAN_VERSION and TitanPanelButton_SetButtonIcon then TitanPanelButton_SetButtonIcon(ID,self.registry.iconCoords) end
end
function TitanPanelZygorButton_OnUpdate(self) self:SetScript("OnUpdate",nil); update() end
function TitanPanelZygorButton_OnClick(_,button) if button=="LeftButton" then ZGV:ToggleFrame() elseif button=="RightButton" then ZGV:OpenOptions() end end
function TitanPanelZygorButton_GetButtonText()
  local runtime=ZGV.Runtime; return runtime and runtime.currentGuide and ("Step |cffffffff"..tostring(runtime.currentStep)) or "No guide"
end
function TitanPanelZygorButton_GetTooltipText()
  local runtime=ZGV.Runtime; local guide=runtime and runtime.currentGuide
  if not guide then return "No guide loaded" end
  local lines={(guide.name or guide.title)..", step "..tostring(runtime.currentStep)}
  local step=guide.steps[runtime.currentStep]; for _,goal in ipairs(step and step.goals or {}) do lines[#lines+1]=goal.text or goal.raw or "" end
  return table.concat(lines,"\n")
end
function TitanPanelRightClickMenu_PrepareZygorMenu()
  if not TitanPanelRightClickMenu_AddTitle then return end
  TitanPanelRightClickMenu_AddTitle("Zygor Guides")
  TitanPanelRightClickMenu_AddSpacer(); TitanPanelRightClickMenu_AddToggleIcon(ID); TitanPanelRightClickMenu_AddToggleLabelText(ID)
  TitanPanelRightClickMenu_AddSpacer(); TitanPanelRightClickMenu_AddCommand("Hide",ID,TITAN_PANEL_MENU_FUNC_HIDE)
end
function TitanPanelZygorButton_ShowDetailedInfo() end
ZGV.Titan=ZGV.Titan or {}
function ZGV.Titan:TryRegister()
  if not TITAN_VERSION or self.registered then return false end
  local button=_G.TitanPanelZygorButton
  if not button and CreateFrame then local ok,created=pcall(CreateFrame,"Button","TitanPanelZygorButton",UIParent,"TitanPanelComboTemplate"); button=ok and created or nil end
  if not button then return false end
  TitanPanelZygorButton_OnLoad(button); if TitanPanelButton_OnLoad then TitanPanelButton_OnLoad(button) end
  self.registered=true; return true
end
local Bootstrap=ZGV:RegisterModule("TitanBridge",{})
function Bootstrap:OnStartup()
  ZGV.Titan:TryRegister()
  ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",update); ZGV:RegisterCallback("ZGV_STEP_CHANGED",update)
end
