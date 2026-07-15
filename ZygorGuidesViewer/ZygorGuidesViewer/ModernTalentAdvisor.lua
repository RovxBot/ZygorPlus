-- Classic-style Talent Advisor for the build-12340 talent frame.
--
-- The Anniversary implementation used retail mixins and C_SpecializationInfo,
-- neither of which exists on 3.3.5a.  This file retains its visible contracts
-- (talent-frame tab, dockable popout, build selector, ranked hints, status,
-- preview and configuration) on top of the WotLK APIs exposed by Compat.Talent.
local addonName,addonNamespace=...
local ZGV=type(addonNamespace)=="table" and (addonNamespace.ZygorGuidesViewer or addonNamespace.ZGV) or _G.ZygorGuidesViewer
if type(ZGV)~="table" or type(ZGV.Talent)~="table" then return end

local Advisor=ZGV:RegisterModule("TalentAdvisor",{})
ZGV.ZTA=Advisor
_G.ZygorTalentAdvisor=_G.ZygorTalentAdvisor or Advisor
_G.BINDING_HEADER_ZYGOR_TALENT_ADVISOR="Zygor Talent Advisor"
_G.BINDING_NAME_ZYGORTALENTADVISOR_OPENPOPUP="Toggle Talent Advisor"

local ORANGE="|cfff16100"
local RESET="|r"
local DEFAULT_ICON="Interface\\Icons\\INV_Misc_QuestionMark"

local function shown(frame,visible)
  if not frame then return end
  if visible then frame:Show() else frame:Hide() end
end

local function setEnabled(button,enabled)
  if not button then return end
  if enabled then button:Enable() else button:Disable() end
end

local function font(parent,template,size)
  local value=parent:CreateFontString(nil,"ARTWORK",template or "GameFontNormal")
  if size and value.GetFont then
    local path,_,flags=value:GetFont()
    if path then value:SetFont(path,size,flags) end
  end
  value:SetJustifyH("LEFT")
  return value
end

local function talentFrame()
  -- Some 3.3.5a UI packs expose both names, but only TalentFrame is the
  -- visible Blizzard panel.  Prefer the displayed frame so a stale hidden
  -- PlayerTalentFrame cannot make the popout dock off-screen.
  local player,legacy=_G.PlayerTalentFrame,_G.TalentFrame
  if player and type(player.IsShown)=="function" and player:IsShown() then return player end
  if legacy and type(legacy.IsShown)=="function" and legacy:IsShown() then return legacy end
  return player or legacy
end

local function settings()
  local profile=ZGV.db and ZGV.db.profile and ZGV.db.profile.talent
  if not profile then return {} end
  if profile.enabled==nil then profile.enabled=true end
  if profile.hints==nil then profile.hints=true end
  if profile.rankPreview==nil then profile.rankPreview=true end
  if profile.docked==nil then profile.docked=true end
  if profile.autoOpen==nil then profile.autoOpen=true end
  if profile.shown==nil then profile.shown=true end
  if profile.confirmLearn==nil then profile.confirmLearn=true end
  if profile.forceBuild==nil then profile.forceBuild=false end
  if type(profile.x)~="number" then profile.x=180 end
  if type(profile.y)~="number" then profile.y=80 end
  return profile
end

-- Blizzard_TalentUI can invoke its dropdown initializer while the viewer is
-- still constructing its startup profile.  Do not let that re-entrant event
-- path build or refresh a partial advisor frame.
function Advisor:IsFrameReady(frame)
  frame=frame or self.frame
  return frame and frame._zygorbuilt and frame.warning and frame.warning.texture
    and frame.status and frame.scroll and frame.close and frame.preview and frame.learn
end

local function treeName(tab,isPet)
  local tree=ZGV.Compat.Talent:GetTab(tab,isPet)
  return tree and tree.name or (isPet and "Pet" or ("Tree "..tostring(tab)))
end

local function makeBorder(frame)
  local title=frame:CreateTexture(nil,"BACKGROUND")
  title:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",9,-6)
  title:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",-4,-25)

  local background=frame:CreateTexture(nil,"BACKGROUND")
  background:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
  background:SetPoint("TOPLEFT",frame,"TOPLEFT",8,-24)
  background:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-6,8)
  background:SetVertexColor(0,0,0,.9)

  local function piece(width,height,point,relativePoint,x,y,left,right,top,bottom,secondPoint,secondRelative,x2,y2)
    local texture=frame:CreateTexture(nil,"BORDER")
    texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
    texture:SetWidth(width)
    texture:SetHeight(height)
    texture:SetPoint(point,frame,relativePoint,x,y)
    if secondPoint then texture:SetPoint(secondPoint,frame,secondRelative,x2,y2) end
    texture:SetTexCoord(left,right,top,bottom)
    return texture
  end
  piece(64,64,"TOPLEFT","TOPLEFT",0,0,.501953125,.625,0,1)
  -- Keep this corner so docking can use the seamless, no-close-button cap
  -- shipped with the Classic advisor.  Without it the close-button cut-out
  -- remains visible against the TalentFrame and makes the popout look like a
  -- detached placeholder panel.
  frame.topRight=piece(64,64,"TOPRIGHT","TOPRIGHT",0,0,.625,.75,0,1)
  piece(1,64,"TOPLEFT","TOPLEFT",64,0,.25,.369140625,0,1,"TOPRIGHT","TOPRIGHT",-64,0)
  piece(64,64,"BOTTOMLEFT","BOTTOMLEFT",0,0,.751953125,.875,0,1)
  piece(64,64,"BOTTOMRIGHT","BOTTOMRIGHT",0,0,.875,1,0,1)
  piece(1,64,"BOTTOMLEFT","BOTTOMLEFT",64,0,.376953125,.498046875,0,1,"BOTTOMRIGHT","BOTTOMRIGHT",-64,0)
  piece(64,1,"TOPLEFT","TOPLEFT",0,-64,.001953125,.125,0,1,"BOTTOMLEFT","BOTTOMLEFT",0,64)
  piece(64,1,"TOPRIGHT","TOPRIGHT",0,-64,.1171875,.2421875,0,1,"BOTTOMRIGHT","BOTTOMRIGHT",0,64)
end

function Advisor:GetContext()
  if not (ZGV.db and ZGV.db.profile) then return {},nil,false,nil end
  if self.petMode then
    local builds,petType=ZGV.Talent:GetPetBuilds()
    return builds,ZGV.Talent:GetSelected(true),true,petType
  end
  return ZGV.Talent:GetBuilds(),ZGV.Talent:GetSelected(false),false,nil
end

function Advisor:EnsureSelection()
  local builds,selected,isPet=self:GetContext()
  if not selected and builds[1] then
    ZGV.Talent:SelectBuild(builds[1].id)
    selected=ZGV.Talent:GetSelected(isPet)
  end
  return builds,selected,isPet
end

function Advisor:CreateBuildDropdown(frame)
  if frame.buildDropdown then return frame.buildDropdown end
  local dropdown=CreateFrame("Frame","ZygorTalentAdvisorBuildDropDown",frame,"UIDropDownMenuTemplate")
  -- The 3.3.5 menu is used only as the picker's menu source.  Leaving its
  -- retail-sized dropdown control visible was the biggest remaining visual
  -- mismatch with the Classic popout, which presents the selected build as a
  -- plain line of text.
  dropdown:SetPoint("TOPLEFT",frame,"TOPLEFT",-30,30)
  dropdown:Hide()
  if UIDropDownMenu_Initialize then
    UIDropDownMenu_Initialize(dropdown,function()
      local builds,selected=Advisor:GetContext()
      if #builds==0 then
        local info=UIDropDownMenu_CreateInfo()
        info.text=ZGV.Talent.dataReady and "No valid builds" or "Talent data is loading..."
        info.disabled=true
        UIDropDownMenu_AddButton(info)
        return
      end
      for _,candidate in ipairs(builds) do
        local build=candidate
        local info=UIDropDownMenu_CreateInfo()
        info.text=build.title
        info.value=build.id
        info.checked=selected and selected.id==build.id
        info.func=function()
          ZGV.Talent:SelectBuild(build.id)
          if CloseDropDownMenus then CloseDropDownMenus() end
          Advisor:Refresh()
        end
        UIDropDownMenu_AddButton(info)
      end
    end)
  end
  frame.buildDropdown=dropdown
  return dropdown
end

function Advisor:OpenBuildPicker()
  local frame=self:Create()
  local dropdown=frame.buildDropdown
  if not dropdown then return end
  if ToggleDropDownMenu then
    ToggleDropDownMenu(1,nil,dropdown,frame.buildChange,0,0)
  elseif dropdown.initializer then
    -- This is primarily useful to stripped-down 3.3.5 UI packs: building the
    -- menu data is preferable to a dead-looking selector even when their
    -- dropdown fork does not expose ToggleDropDownMenu.
    dropdown.initializer()
  end
end

function Advisor:CreateSuggestionRow(parent,index)
  local row=CreateFrame("Frame",nil,parent)
  row:SetHeight(34)
  row:SetPoint("TOPLEFT",parent,"TOPLEFT",0,-((index-1)*34))
  row:SetPoint("TOPRIGHT",parent,"TOPRIGHT",0,-((index-1)*34))
  row:EnableMouse(true)

  local icon=row:CreateTexture(nil,"ARTWORK")
  icon:SetWidth(28); icon:SetHeight(28)
  icon:SetPoint("LEFT",row,"LEFT",1,0)
  icon:SetTexCoord(.07,.93,.07,.93)
  row.icon=icon

  local border=row:CreateTexture(nil,"OVERLAY")
  border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
  border:SetWidth(46); border:SetHeight(46)
  border:SetPoint("CENTER",icon,"CENTER",0,-1)

  local name=font(row,"GameFontNormal",11)
  name:SetPoint("TOPLEFT",icon,"TOPRIGHT",7,-1)
  name:SetPoint("TOPRIGHT",row,"TOPRIGHT",-2,-1)
  row.name=name

  local detail=font(row,"GameFontHighlightSmall",9)
  detail:SetPoint("TOPLEFT",name,"BOTTOMLEFT",0,-2)
  detail:SetPoint("TOPRIGHT",row,"TOPRIGHT",-2,-2)
  detail:SetTextColor(.72,.72,.72,1)
  row.detail=detail

  row:SetScript("OnEnter",function(self)
    if not self.point then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    if GameTooltip.SetTalent then
      local group=ZGV.Compat.Talent:GetActiveGroup(self.point.isPet)
      local preview=type(GetCVarBool)=="function" and GetCVarBool("previewTalents") or false
      local ok=pcall(GameTooltip.SetTalent,GameTooltip,self.point.tab,self.point.index,false,self.point.isPet,group,preview)
      if not ok then GameTooltip:SetText(self.point.name or "Talent",1,.82,0) end
    else
      GameTooltip:SetText(self.point.name or "Talent",1,.82,0)
    end
    GameTooltip:AddLine("Zygor recommends rank "..tostring(self.toRank).." for this point.",1,.75,.2,true)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave",function() GameTooltip:Hide() end)
  return row
end

-- The Classic popout lists recommendations under their talent-tree headings,
-- rather than rendering a modern card for every point.  Keep the grouping in
-- Lua so it works with the build-12340 frame API and the same live data used
-- for the talent-frame arrows.
function Advisor:CreateSuggestionGroup(parent)
  local group=CreateFrame("Frame",nil,parent)
  group:SetPoint("TOPLEFT",parent,"TOPLEFT",0,0)
  group:SetPoint("TOPRIGHT",parent,"TOPRIGHT",0,0)
  local heading=font(group,"GameFontHighlightLarge",12)
  heading:SetPoint("TOPLEFT",group,"TOPLEFT",0,0)
  heading:SetPoint("TOPRIGHT",group,"TOPRIGHT",0,0)
  heading:SetHeight(18)
  group.heading=heading
  local talents=font(group,"GameFontNormal",11)
  talents:SetPoint("TOPLEFT",heading,"BOTTOMLEFT",0,-1)
  talents:SetPoint("TOPRIGHT",group,"TOPRIGHT",0,-1)
  talents:SetJustifyV("TOP")
  group.talents=talents
  return group
end

function Advisor:CreateOptions(frame)
  local panel=CreateFrame("Frame",nil,frame)
  panel:SetPoint("TOPLEFT",frame,"TOPLEFT",16,-66)
  panel:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-16,42)
  panel:Hide()
  frame.optionsPanel=panel

  local heading=font(panel,"GameFontNormalLarge",14)
  heading:SetPoint("TOPLEFT",panel,"TOPLEFT",0,-4)
  heading:SetText("Talent Advisor Settings")

  local description=font(panel,"GameFontHighlightSmall",10)
  description:SetPoint("TOPLEFT",heading,"BOTTOMLEFT",0,-7)
  description:SetPoint("TOPRIGHT",panel,"TOPRIGHT",0,-7)
  description:SetText("Classic talent hints remain advisory. Points are only spent after your click.")
  description:SetTextColor(.78,.78,.78,1)

  local definitions={
    {"enabled","Enable Talent Advisor"},
    {"hints","Show recommendation arrows on talents"},
    {"rankPreview","Show current / build rank overlays"},
    {"autoOpen","Open with the Blizzard talent window"},
    {"docked","Dock the advisor to the talent window"},
    {"confirmLearn","Confirm before learning a talent"},
    {"forceBuild","Continue suggestions when off build"},
  }
  panel.checks={}
  for index,definition in ipairs(definitions) do
    local key,label=definition[1],definition[2]
    local check=CreateFrame("CheckButton","ZygorTalentAdvisorOption"..index,panel,"UICheckButtonTemplate")
    check:SetPoint("TOPLEFT",panel,"TOPLEFT",0,-55-(index-1)*29)
    local text=_G[check:GetName().."Text"]
    if text then text:SetText(label) end
    check.key=key
    check:SetScript("OnClick",function(self)
      settings()[self.key]=self:GetChecked() and true or false
      Advisor:ApplyDocking()
      Advisor:Refresh()
    end)
    panel.checks[#panel.checks+1]=check
  end

  local back=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
  back:SetWidth(120); back:SetHeight(22)
  back:SetPoint("BOTTOM",panel,"BOTTOM",0,0)
  back:SetText("Back to Suggestions")
  back:SetScript("OnClick",function() Advisor:ToggleOptions(false) end)
end

function Advisor:Create()
  if self.frame then return self.frame end
  -- Loading Blizzard_TalentUI can synchronously emit talent callbacks.  Do
  -- not let one of those callbacks refresh a half-constructed popout.
  self.creating=true
  local frame=CreateFrame("Frame","ZygorTalentAdvisorPopout",UIParent)
  -- This is the reference advisor's 250x350 Gear Manager popout.  Keeping a
  -- stable working area prevents controls from moving over one another as the
  -- client delivers talent updates or a long build is selected.
  frame:SetWidth(250); frame:SetHeight(350)
  frame:SetFrameStrata("MEDIUM")
  if frame.SetToplevel then frame:SetToplevel(true) end
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:Hide()
  makeBorder(frame)
  self.frame=frame

  local title=font(frame,"GameFontNormal",13)
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",13,-8)
  title:SetText("Zygor Talent Advisor")
  frame.title=title

  local close=CreateFrame("Button","ZygorTalentAdvisorPopoutCloseButton",frame,"UIPanelCloseButton")
  close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,1)
  close:SetScript("OnClick",function() settings().shown=false frame:Hide() Advisor:UpdateToggleState() end)
  frame.close=close

  local drag=CreateFrame("Frame",nil,frame)
  drag:SetPoint("TOPLEFT",frame,"TOPLEFT",4,-3)
  drag:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-30,-3)
  drag:SetHeight(23)
  drag:EnableMouse(true)
  drag:RegisterForDrag("LeftButton")
  drag:SetScript("OnDragStart",function()
    local profile=settings()
    profile.docked=false
    frame:SetParent(UIParent)
    frame:StartMoving()
  end)
  drag:SetScript("OnDragStop",function()
    frame:StopMovingOrSizing()
    local profile=settings()
    local left,bottom=frame:GetLeft(),frame:GetBottom()
    local scale=frame:GetEffectiveScale()
    local uiScale=UIParent:GetEffectiveScale()
    if left and bottom then
      profile.x=left*scale/uiScale
      profile.y=bottom*scale/uiScale
    end
    local parent=talentFrame()
    if parent and parent:IsShown() and frame:GetLeft() and parent:GetRight() and math.abs(frame:GetLeft()-parent:GetRight()+36)<24 then
      profile.docked=true
    end
    Advisor:ApplyDocking()
    Advisor:Refresh()
  end)

  local buildLabel=font(frame,"GameFontNormalSmall",10)
  buildLabel:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-29)
  buildLabel:SetText("Build:")
  frame.buildLabel=buildLabel
  self:CreateBuildDropdown(frame)

  local build=font(frame,"GameFontHighlightSmall",10)
  build:SetPoint("TOPLEFT",buildLabel,"TOPRIGHT",5,1)
  build:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-58,-50)
  build:SetHeight(16)
  frame.build=build

  local buildChange=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  buildChange:SetWidth(46); buildChange:SetHeight(18)
  buildChange:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-27,-27)
  buildChange:SetText("Change")
  buildChange:SetScript("OnClick",function() Advisor:OpenBuildPicker() end)
  buildChange:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText("Select a talent build",1,.82,0)
    GameTooltip:AddLine("Choose one of the WotLK builds available for your class.",1,1,1,true)
    GameTooltip:Show()
  end)
  buildChange:SetScript("OnLeave",function() GameTooltip:Hide() end)
  frame.buildChange=buildChange

  local mode=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  mode:SetWidth(48); mode:SetHeight(19)
  mode:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-50)
  mode:SetText("Pet")
  mode:SetScript("OnClick",function() Advisor:SetPetMode(not Advisor.petMode) end)
  frame.mode=mode

  local warning=CreateFrame("Frame",nil,frame)
  warning:SetWidth(16); warning:SetHeight(16)
  warning:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-7,-30)
  local warningTexture=warning:CreateTexture(nil,"ARTWORK")
  warningTexture:SetAllPoints(warning)
  warningTexture:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon")
  warning.texture=warningTexture
  warning:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_BOTTOMRIGHT")
    GameTooltip:SetText("Build status",1,.82,0)
    GameTooltip:AddLine(self.message or "Unknown",1,1,1,true)
    GameTooltip:Show()
  end)
  warning:SetScript("OnLeave",function() GameTooltip:Hide() end)
  frame.warning=warning

  -- This occupies the Classic popout's "suggestion label" position.  It is
  -- deliberately a short, plain line while suggestions exist; detailed
  -- errors use the same space only when there is nothing to list.
  local status=font(frame,"GameFontNormalSmall",10)
  status:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-50)
  status:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-50)
  status:SetHeight(34)
  status:SetJustifyV("TOP")
  frame.status=status

  local suggestionTitle=font(frame,"GameFontNormal",11)
  suggestionTitle:SetPoint("TOPLEFT",frame,"TOPLEFT",13,-69)
  suggestionTitle:SetText("Recommended talents")
  suggestionTitle:Hide()
  frame.suggestionTitle=suggestionTitle

  -- Preserve the legacy names: existing 3.3.5a skins (including ElvUI's
  -- Zygor adapter) use these globals to skin the controls after load.
  local scroll=CreateFrame("ScrollFrame","ZygorTalentAdvisorPopoutScroll",frame,"UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-70)
  scroll:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-35,70)
  local child=CreateFrame("Frame",nil,scroll)
  child:SetWidth(200); child:SetHeight(1)
  scroll:SetScrollChild(child)
  scroll.child=child
  frame.scroll=scroll
  frame.rows={}
  frame.groups={}

  -- Retained for compatibility with the legacy popout facade.  Empty states
  -- now render through status above, so this never leaks an overlapping text
  -- block into the compact frame.
  local empty=font(frame,"GameFontHighlightSmall",10)
  empty:Hide()
  frame.empty=empty

  local glyphBox=CreateFrame("Frame",nil,frame)
  glyphBox:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",13,84)
  glyphBox:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-13,84)
  glyphBox:SetHeight(28)
  glyphBox:EnableMouse(true)
  local glyphText=font(glyphBox,"GameFontHighlightSmall",9)
  glyphText:SetAllPoints(glyphBox)
  glyphText:SetJustifyV("TOP")
  glyphText:SetTextColor(.73,.73,.73,1)
  glyphBox.text=glyphText
  glyphBox:SetScript("OnEnter",function(self)
    if not self.recommendations or #self.recommendations==0 then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Recommended glyphs",1,.82,0)
    for _,glyph in ipairs(self.recommendations) do GameTooltip:AddLine(glyph,.9,.9,.9,true) end
    GameTooltip:Show()
  end)
  glyphBox:SetScript("OnLeave",function() GameTooltip:Hide() end)
  frame.glyphBox=glyphBox
  glyphBox:Hide()

  local preview=CreateFrame("Button","ZygorTalentAdvisorPopoutPreviewButton",frame,"UIPanelButtonTemplate")
  preview:SetWidth(80); preview:SetHeight(22)
  preview:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",10,40)
  preview:SetText("Preview")
  preview:SetScript("OnClick",function() Advisor:PreviewSuggestions() end)
  frame.preview=preview

  local learn=CreateFrame("Button","ZygorTalentAdvisorPopoutAcceptButton",frame,"UIPanelButtonTemplate")
  learn:SetWidth(80); learn:SetHeight(22)
  learn:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-10,40)
  learn:SetText("Learn Next")
  learn:SetScript("OnClick",function() Advisor:RequestLearn() end)
  frame.learn=learn

  local modeOptions=CreateFrame("Button","ZygorTalentAdvisorPopoutConfigureButton",frame,"UIPanelButtonTemplate")
  modeOptions:SetWidth(120); modeOptions:SetHeight(22)
  modeOptions:SetPoint("BOTTOM",frame,"BOTTOM",0,12)
  modeOptions:SetText("Configure")
  modeOptions:SetScript("OnClick",function()
    -- Classic's Configure action opens the shared settings surface.  Keeping
    -- talent options there avoids replacing this compact popout with a second
    -- modern-looking configuration panel.
    if ZGV.UI and ZGV.UI.ShowGuideMenu then
      if ZGV.GuideMenu then ZGV.GuideMenu.settingsCategory="talents" end
      ZGV.UI:ShowGuideMenu("SETTINGS")
    else
      Advisor:ToggleOptions(true)
    end
  end)
  frame.options=modeOptions

  local safety=font(frame,"GameFontHighlightSmall",9)
  safety:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",13,18)
  safety:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-13,18)
  safety:SetText("Preview fills Blizzard's preview tree; Learn spends one point.")
  safety:SetTextColor(.56,.56,.56,1)
  frame.safety=safety
  safety:Hide()

  self:CreateOptions(frame)
  frame:SetScript("OnShow",function() settings().shown=true Advisor:ApplyDocking() Advisor:Refresh() end)
  frame:SetScript("OnHide",function() Advisor:UpdateToggleState() end)
  frame._zygorbuilt=true
  self.creating=nil
  return frame
end

function Advisor:CreateTalentFrameButton(parent)
  if self.toggleButton then return self.toggleButton end
  local button=CreateFrame("Button","ZygorTalentAdvisorPopoutButton",parent)
  button:SetWidth(44); button:SetHeight(44)
  -- This is the same large, round tab atlas the Classic advisor attaches to
  -- the talent window.  The smaller generic popout-button texture exposed a
  -- stretched, blurry 32px icon at this 44px size.
  if ZGV.F and ZGV.F.AssignButtonTexture then
    ZGV.F.AssignButtonTexture(button,ZGV.SKINDIR.."popout-v2",1,1,false)
  else
    button:SetNormalTexture(ZGV.SKINDIR.."popout-v2")
    button:SetPushedTexture(ZGV.SKINDIR.."popout-v2")
    button:SetHighlightTexture(ZGV.SKINDIR.."popout-v2")
  end
  button:SetScript("OnClick",function() Advisor:Toggle() end)
  button:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Zygor Talent Advisor",1,.82,0)
    GameTooltip:AddLine("Show build recommendations and talent hints.",1,1,1,true)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave",function() GameTooltip:Hide() end)
  self.toggleButton=button
  parent.advisorbutton=button
  self:ApplyDocking()
  return button
end

function Advisor:ApplyDocking()
  local frame=self.frame
  local parent=talentFrame()
  if not self:IsFrameReady(frame) then return end
  local profile=settings()
  frame:ClearAllPoints()
  if profile.docked and parent then
    frame:SetParent(parent)
    -- This is the Classic popout's docking point: it nests against the
    -- talent-panel edge instead of floating below its title bar.
    frame:SetPoint("TOPLEFT",parent,"TOPRIGHT",-36,-130)
    frame.close:Hide()
    if frame.topRight then
      frame.topRight:SetTexture(ZGV.SKINDIR.."popout-noclose")
      frame.topRight:SetTexCoord(0,1,0,1)
    end
  else
    frame:SetParent(UIParent)
    frame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",profile.x or 180,profile.y or 80)
    frame.close:Show()
    if frame.topRight then
      frame.topRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
      frame.topRight:SetTexCoord(.625,.75,0,1)
    end
  end
  if self.toggleButton and parent then
    self.toggleButton:ClearAllPoints()
    if profile.docked and frame:IsShown() then
      self.toggleButton:SetParent(frame)
      self.toggleButton:SetPoint("TOPLEFT",frame,"TOPRIGHT",-5,-10)
    else
      self.toggleButton:SetParent(parent)
      self.toggleButton:SetPoint("TOPLEFT",parent,"TOPRIGHT",-35,-140)
    end
  end
end

function Advisor:UpdateToggleState()
  if not self.toggleButton then return end
  if self.frame and self.frame:IsShown() then self.toggleButton:SetButtonState("PUSHED",true)
  else self.toggleButton:SetButtonState("NORMAL",false) end
end

function Advisor:SetPetMode(enabled)
  local _,class=UnitClass("player")
  if enabled and class~="HUNTER" then return false,"not a hunter" end
  local builds,petType=ZGV.Talent:GetPetBuilds()
  if enabled and (not petType or #builds==0) then return false,"pet talents unavailable" end
  self.petMode=enabled and true or false
  if type(PlayerTalentFrame_Open)=="function" then
    local group=ZGV.Compat.Talent:GetActiveGroup(self.petMode)
    pcall(PlayerTalentFrame_Open,self.petMode,group)
  end
  self:EnsureSelection()
  self:Refresh()
  return true
end

function Advisor:SetStatus(code,message)
  local frame=self:Create()
  if not self:IsFrameReady(frame) then return end
  local colors={GREEN={0,1,1},YELLOW={1,.7,0},RED={1,0,0},BLACK={.45,.45,.45},NONE={.45,.45,.45}}
  local color=colors[code] or colors.BLACK
  frame.warning.texture:SetVertexColor(color[1],color[2],color[3],1)
  frame.warning.message=message
  self.statusMessage=message or ""
  -- The old advisor used the icon for state and reserved the label beneath
  -- the build name for either "Recommended talents" or a useful empty-state
  -- explanation.  Rendering every verbose status here made the compact
  -- panel look crowded and pushed recommendation text into the scroll area.
  shown(frame.warning,code and code~="NONE")
end

function Advisor:ResizeForSuggestions(contentHeight,hasSuggestions)
  local frame=self:Create()
  if not self:IsFrameReady(frame) then return end
  if frame:GetHeight()~=350 then frame:SetHeight(350) end
  self:ApplyDocking()
end

function Advisor:SetActionVisibility(showPreview,showLearn)
  local frame=self:Create()
  shown(frame.preview,showPreview)
  shown(frame.learn,showLearn)
end

function Advisor:CollapseSuggestions(state)
  local rows,byKey={},{}
  for _,point in ipairs(state.suggestions or {}) do
    local key=point.tab..":"..point.index
    local row=byKey[key]
    if not row then
      row={point=point,fromRank=point.currentRank+1,toRank=point.targetRank,count=1}
      byKey[key]=row
      rows[#rows+1]=row
    else
      row.toRank=math.max(row.toRank,point.targetRank)
      row.count=row.count+1
    end
  end
  return rows
end

function Advisor:RenderSuggestions(state)
  local frame=self:Create()
  local rows=self:CollapseSuggestions(state)
  local grouped,order={},{}
  for _,data in ipairs(rows) do
    local name=treeName(data.point.tab,data.point.isPet)
    local group=grouped[name]
    if not group then
      group={name=name,rows={}}
      grouped[name]=group
      order[#order+1]=group
    end
    group.rows[#group.rows+1]=data
  end
  local offset=0
  for index,groupData in ipairs(order) do
    local group=frame.groups[index]
    if not group then group=self:CreateSuggestionGroup(frame.scroll.child) frame.groups[index]=group end
    group:ClearAllPoints()
    group:SetPoint("TOPLEFT",frame.scroll.child,"TOPLEFT",0,-offset)
    group:SetPoint("TOPRIGHT",frame.scroll.child,"TOPRIGHT",0,-offset)
    group.heading:SetText(groupData.name)
    local entries={}
    for _,data in ipairs(groupData.rows) do
      local point=data.point
      local ranks=data.fromRank==data.toRank and tostring(data.toRank) or (tostring(data.fromRank).."-"..tostring(data.toRank))
      entries[#entries+1]=(point.texture and ("|T"..point.texture..":0:0:0:0|t ") or "")
        ..tostring(point.name or "Unknown talent").." |cff997700("..ranks..")|r"
    end
    group.talents:SetText(table.concat(entries,"\n"))
    -- FrameXML measures these strings after draw, but a deterministic line
    -- height keeps the compact Classic popout correct immediately on 3.3.5a.
    local height=18+#entries*17+3
    group:SetHeight(height)
    offset=offset+height+4
    group:Show()
  end
  for index=#order+1,#frame.groups do frame.groups[index]:Hide() end
  for _,row in ipairs(frame.rows) do row:Hide() end
  frame.scroll.child:SetHeight(math.max(1,offset))
  shown(frame.empty,false)
  if #rows>0 then
    frame.status:SetText("Recommended talents:")
    frame.scroll:Show()
    self:ResizeForSuggestions(offset,true)
  else
    local message=self.statusMessage
    if not message or message=="" then
      if not state.ready then message="Talent data is loading. Open the talent window or click Retry."
      elseif state.complete then message="All talents in this build have been learned."
      elseif state.unspent==0 then message="No unspent points. Your next talent is ready when you level."
      else message="No safe recommendation is currently available." end
    end
    frame.status:SetText(message)
    frame.scroll:Hide()
    self:ResizeForSuggestions(0,false)
  end
end

local function glyphShort(name)
  return tostring(name or ""):gsub("^Major Glyph of ",""):gsub("^Minor Glyph of ",""):gsub("^Glyph of ","")
end

function Advisor:RenderGlyphs(build,isPet)
  local frame=self:Create()
  if not self:IsFrameReady(frame) then return end
  local glyphs=isPet and {} or ZGV.Talent:GetGlyphRecommendations(build)
  frame.glyphBox.recommendations=glyphs
  if #glyphs==0 then
    frame.glyphBox.text:SetText(isPet and "Pet builds do not use glyphs." or "No glyph recommendations stored for this build.")
    frame.glyphBox:Hide()
    return
  end
  local summary=glyphShort(glyphs[1])
  if glyphs[2] then summary=summary..", "..glyphShort(glyphs[2]) end
  if #glyphs>2 then summary=summary.." +"..tostring(#glyphs-2) end
  frame.glyphBox.text:SetText("Glyphs: "..summary)
  frame.glyphBox:Show()
end

function Advisor:RefreshDropdown(build)
  local dropdown=self.frame and self.frame.buildDropdown
  local frame=self.frame
  if not dropdown or not frame then return end
  local title=build and build.title or (ZGV.Talent.dataReady and "No valid builds" or "Loading talent data...")
  if frame.build then frame.build:SetText(title) end
  setEnabled(frame.buildChange,build~=nil)
  if UIDropDownMenu_SetText then UIDropDownMenu_SetText(dropdown,title) end
  if UIDropDownMenu_SetSelectedValue then UIDropDownMenu_SetSelectedValue(dropdown,build and build.id or nil) end
end

function Advisor:RefreshOptions()
  local panel=self.frame and self.frame.optionsPanel
  if not panel then return end
  local profile=settings()
  for _,check in ipairs(panel.checks or {}) do check:SetChecked(profile[check.key] and true or false) end
end

function Advisor:Refresh()
  if self.creating or not self:IsFrameReady() then return end
  local frame=self:Create()
  local profile=settings()
  self:RefreshOptions()
  -- The standalone fallback checklist owns the popout while it is open.
  -- Talent events continue to arrive in the background; do not let one
  -- redraw the suggestion list on top of the options page.
  if self.showingOptions then return end
  local _,class=UnitClass("player")
  local petType=ZGV.Talent:GetPetType()
  local parent=talentFrame()
  if parent and parent:IsShown() and parent.pet~=nil then self.petMode=parent.pet and true or false end
  if self.petMode and not petType then self.petMode=false end
  shown(frame.mode,class=="HUNTER")
  if class=="HUNTER" then
    frame.mode:SetText(self.petMode and "Player" or "Pet")
    setEnabled(frame.mode,petType~=nil)
  end
  frame.status:ClearAllPoints()
  frame.status:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-50)
  frame.status:SetPoint("TOPRIGHT",frame,"TOPRIGHT",class=="HUNTER" and -66 or -10,-50)
  frame.title:SetText("Zygor Talent Advisor")

  if not profile.enabled then
    self:SetStatus("NONE","Talent Advisor is disabled. Open Options to enable it.")
    self:RefreshDropdown(nil)
    self:RenderSuggestions({ready=false,suggestions={}})
    self:RenderGlyphs(nil,false)
    frame.learn:SetText("Retry")
    setEnabled(frame.learn,false); setEnabled(frame.preview,false)
    self:SetActionVisibility(false,false)
    self:RefreshTalentHints(nil)
    self:UpdateToggleState()
    return
  end

  local _,build,isPet=self:EnsureSelection()
  self:RefreshDropdown(build)
  if not build then
    local ready,reason=ZGV.Talent:InitializeBuilds("advisor refresh")
    if ready then
      _,build,isPet=self:EnsureSelection()
      self:RefreshDropdown(build)
    end
    if not build then
      self:SetStatus(ready and "BLACK" or "NONE",reason=="talent data unavailable" and "Talent data is loading. Open the Blizzard talent window or click Retry." or "No valid WotLK build is available for this class.")
      self:RenderSuggestions({ready=false,suggestions={}})
      self:RenderGlyphs(nil,isPet)
      frame.learn:SetText("Retry")
      setEnabled(frame.learn,true); setEnabled(frame.preview,false)
      self:SetActionVisibility(false,true)
      self:RefreshTalentHints(nil)
      self:UpdateToggleState()
      return
    end
  end

  local state=ZGV.Talent:GetSuggestionState(build)
  self.state=state
  self:SetStatus(state.code,state.message)
  self:RenderSuggestions(state)
  self:RenderGlyphs(build,isPet)
  local allowed=state.code~="RED" or profile.forceBuild
  frame.learn:SetText("Learn Next")
  setEnabled(frame.learn,state.ready and #state.suggestions>0 and allowed)
  local previewAvailable=type(AddPreviewTalentPoints)=="function" and type(ResetGroupPreviewTalentPoints)=="function"
  setEnabled(frame.preview,previewAvailable and #state.suggestions>0 and allowed)
  local hasSuggestions=#state.suggestions>0
  self:SetActionVisibility(hasSuggestions and previewAvailable,hasSuggestions)
  self:RefreshTalentHints(state)
  self:UpdateToggleState()
end

function Advisor:Retry()
  ZGV.Talent.compiled={}
  ZGV.Talent:InitializeBuilds("manual retry")
  self:Refresh()
end

function Advisor:LearnNext(build)
  local ok,result=ZGV.Talent:LearnNext(build)
  if not ok and result~="complete" then ZGV:Print("Talent Advisor: "..tostring(result)) end
  self:Refresh()
  return ok,result
end

function Advisor:RequestLearn()
  if self.frame and self.frame.learn:GetText()=="Retry" then self:Retry() return end
  local _,build=self:GetContext()
  local point,reason=ZGV.Talent:GetNextPoint(build)
  if not point then
    if reason and reason~="complete" then ZGV:Print("Talent Advisor: "..tostring(reason)) end
    self:Refresh()
    return
  end
  if settings().confirmLearn and StaticPopup_Show then
    local dialog=StaticPopup_Show("ZYGOR_VIEWER_LEARN_TALENT",point.name)
    if dialog then dialog.data=point self.pendingBuild=build end
  else
    self:LearnNext(build)
  end
end

function Advisor:PreviewSuggestions()
  local state=self.state
  if not state or #state.suggestions==0 then return false,"no suggestions" end
  if type(ResetGroupPreviewTalentPoints)~="function" or type(AddPreviewTalentPoints)~="function" then
    ZGV:Print("Talent previews are unavailable on this client.")
    return false,"preview unavailable"
  end
  local isPet=state.isPet and true or false
  local group=ZGV.Compat.Talent:GetActiveGroup(isPet)
  local resetOK=pcall(ResetGroupPreviewTalentPoints,isPet,group)
  if not resetOK then pcall(ResetGroupPreviewTalentPoints) end
  local applied=0
  for _,point in ipairs(state.suggestions) do
    local before=type(GetGroupPreviewTalentPointsSpent)=="function" and GetGroupPreviewTalentPointsSpent(isPet) or nil
    local ok=pcall(AddPreviewTalentPoints,point.tab,point.index,1,isPet,group)
    local after=type(GetGroupPreviewTalentPointsSpent)=="function" and GetGroupPreviewTalentPointsSpent(isPet) or nil
    if ok and (before==nil or after==nil or after>before) then applied=applied+1 else break end
  end
  if applied>0 then
    self:SetStatus("GREEN",("Previewed %d recommended point%s. Review the tree, then use Blizzard's Learn button to confirm."):format(applied,applied==1 and "" or "s"))
    self:RefreshTalentHints(state)
    return true,applied
  end
  ZGV:Print("Talent Advisor could not apply the preview; the next talent may still be locked.")
  return false,"preview blocked"
end

function Advisor:ToggleOptions(showOptions)
  local frame=self:Create()
  self.showingOptions=showOptions and true or false
  if self.showingOptions then
    -- The fallback option checklist is intentionally a separate full-height
    -- page.  Returning to suggestions lets RenderSuggestions restore the
    -- compact Classic height on the next refresh.
    frame:SetHeight(320)
  end
  shown(frame.optionsPanel,self.showingOptions)
  for _,region in ipairs({frame.buildLabel,frame.build,frame.buildChange,frame.buildDropdown,frame.mode,frame.warning,frame.status,frame.suggestionTitle,frame.scroll,frame.empty,frame.glyphBox,frame.preview,frame.learn,frame.options,frame.safety}) do
    shown(region,not self.showingOptions)
  end
  -- Glyph and safety copy belonged to the former tall placeholder, not the
  -- Classic popout.  Do not resurrect either after returning from fallback
  -- options on clients without the shared Guide Menu.
  shown(frame.suggestionTitle,false)
  shown(frame.glyphBox,false)
  shown(frame.safety,false)
  self:RefreshOptions()
  self:ApplyDocking()
  if not self.showingOptions then self:Refresh() end
end

function Advisor:OpenOptions()
  settings().shown=true
  self:Show()
  self:ToggleOptions(true)
end

function Advisor:Show()
  local frame=self:Create()
  local profile=settings()
  profile.shown=true
  -- Opening from the live Blizzard Talent window is always a popout action.
  -- Restore Classic side docking even if a previous drag left the persisted
  -- profile in its floating state.  The standalone options page remains able
  -- to open the advisor as a movable window when no talent panel is visible.
  local parent=talentFrame()
  if parent and type(parent.IsShown)=="function" and parent:IsShown() then profile.docked=true end
  self:ApplyDocking()
  frame:Show()
  self:Refresh()
end

function Advisor:Toggle()
  local frame=self:Create()
  if frame:IsShown() then settings().shown=false frame:Hide()
  else self:Show() end
  self:UpdateToggleState()
end

function Advisor:UpdateVisibility()
  local parent=talentFrame()
  if not parent then return end
  local frame=self:Create()
  self:CreateTalentFrameButton(parent)
  self.toggleButton:Show()
  if parent:IsShown() then
    if settings().autoOpen and settings().shown then frame:Show() end
    self:ApplyDocking()
    self:Refresh()
  elseif settings().docked then
    frame:Hide()
  end
end

function Advisor:BuildRankMap(state)
  local ranks={}
  if not state or not state.compiled then return ranks end
  for _,point in ipairs(state.compiled.sequence) do
    local key=point.tab..":"..point.index
    ranks[key]=(ranks[key] or 0)+1
  end
  return ranks
end

function Advisor:AddTalentTooltip(button)
  if not self.state or not self.state.compiled or not button.ZygorTalentIndex then return end
  local parent=talentFrame()
  local tab=parent and PanelTemplates_GetSelectedTab and PanelTemplates_GetSelectedTab(parent) or 1
  local key=tostring(tab)..":"..tostring(button.ZygorTalentIndex)
  local desired=self:BuildRankMap(self.state)[key] or 0
  local info=ZGV.Compat.Talent:GetInfo(tab,button.ZygorTalentIndex,self.state.isPet)
  if not info then return end
  local current=tonumber(info.rank) or 0
  local color=current>desired and "|cffff4040" or current==desired and "|cff40ff40" or "|cffffff40"
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine("Zygor build: "..color..tostring(current).." / "..tostring(desired)..RESET,1,1,1)
  if current>desired then GameTooltip:AddLine("This talent is above the selected build.",1,.25,.25,true)
  elseif current<desired then GameTooltip:AddLine((desired-current).." rank(s) remain in this build.",1,.82,.25,true) end
  GameTooltip:Show()
end

function Advisor:ClearTalentHints()
  for _,button in ipairs(self.talentButtons or {}) do
    if button.ZygorHint then button.ZygorHint:Hide() end
    if button.ZygorDesiredRank then button.ZygorDesiredRank:Hide() end
  end
end

function Advisor:RefreshTalentHints(state)
  local parent=talentFrame()
  if not parent or not parent:IsShown() then return end
  local profile=settings()
  if not state or not state.ready or not profile.enabled then self:ClearTalentHints() return end
  local viewingPet=parent.pet and true or false
  if viewingPet~=state.isPet then self:ClearTalentHints() return end
  local tab=PanelTemplates_GetSelectedTab and PanelTemplates_GetSelectedTab(parent) or 1
  local ranks=self:BuildRankMap(state)
  local recommended={}
  for _,point in ipairs(state.suggestions or {}) do
    if point.tab==tab then recommended[point.index]=(recommended[point.index] or 0)+1 end
  end
  self.talentButtons=self.talentButtons or {}
  local maximum=tonumber(_G.MAX_NUM_TALENTS) or 40
  local prefix=parent.GetName and parent:GetName() or "PlayerTalentFrame"
  for index=1,maximum do
    local button=_G[prefix.."Talent"..index]
    if button then
      button.ZygorTalentIndex=index
      if not button.ZygorTooltipHooked then
        button:HookScript("OnEnter",function(self) Advisor:AddTalentTooltip(self) end)
        button.ZygorTooltipHooked=true
      end
      if not button.ZygorHint then
        local hint=button:CreateTexture(nil,"OVERLAY")
        hint:SetWidth(32); hint:SetHeight(32)
        local icon=button.icon or _G[prefix.."Talent"..index.."IconTexture"] or button
        hint:SetPoint("LEFT",icon,"RIGHT",-14,5)
        hint:SetTexture(ZGV.SKINDIR.."zta_hints")
        button.ZygorHint=hint
      end
      if not button.ZygorDesiredRank then
        local desired=font(button,"GameFontNormalSmall",9)
        desired:SetPoint("BOTTOM",button,"TOP",0,-2)
        desired:SetJustifyH("CENTER")
        button.ZygorDesiredRank=desired
      end
      local count=recommended[index]
      if profile.hints and count and count>0 then
        count=math.min(6,count)
        button.ZygorHint:SetTexCoord(.125*count,.125*(count+1),0,1)
        button.ZygorHint:Show()
      else button.ZygorHint:Hide() end
      local desired=ranks[tab..":"..index] or 0
      local info=ZGV.Compat.Talent:GetInfo(tab,index,state.isPet)
      if profile.rankPreview and desired>0 and info then
        local current=tonumber(info.rank) or 0
        local color=current>desired and "|cffff4040" or current==desired and "|cff40ff40" or "|cffffffff"
        button.ZygorDesiredRank:SetText(color..tostring(current)..RESET.."/"..ORANGE..tostring(desired)..RESET)
        button.ZygorDesiredRank:Show()
      else button.ZygorDesiredRank:Hide() end
      self.talentButtons[index]=button
    end
  end
end

function Advisor:HookTalentFrame()
  ZGV.Talent:LoadBlizzardTalentUI()
  local parent=talentFrame()
  if not parent then return false end
  self:Create()
  self:CreateTalentFrameButton(parent)
  if not self.frameHooked then
    parent:HookScript("OnShow",function() Advisor:UpdateVisibility() end)
    parent:HookScript("OnHide",function() Advisor:UpdateVisibility() end)
    self.frameHooked=true
  end
  if hooksecurefunc and not self.updateHooks then
    if type(PlayerTalentFrame_Update)=="function" then hooksecurefunc("PlayerTalentFrame_Update",function() Advisor:Refresh() end) end
    if type(TalentFrame_Update)=="function" then hooksecurefunc("TalentFrame_Update",function() Advisor:Refresh() end) end
    if type(PlayerTalentTab_OnClick)=="function" then hooksecurefunc("PlayerTalentTab_OnClick",function() Advisor:Refresh() end) end
    self.updateHooks=true
  end
  self:UpdateVisibility()
  return true
end

function Advisor:OnStartup()
  settings()
  if StaticPopupDialogs and not StaticPopupDialogs.ZYGOR_VIEWER_LEARN_TALENT then
    StaticPopupDialogs.ZYGOR_VIEWER_LEARN_TALENT={
      text="Learn Zygor's next talent recommendation: %s?",
      button1=ACCEPT or "Accept",button2=CANCEL or "Cancel",
      OnAccept=function()
        local build=Advisor.pendingBuild
        Advisor.pendingBuild=nil
        Advisor:LearnNext(build)
      end,
      OnCancel=function() Advisor.pendingBuild=nil end,
      timeout=0,whileDead=1,hideOnEscape=1,
    }
  end
  self:HookTalentFrame()
end

function Advisor:OnEvent(event,addon)
  if event=="ADDON_LOADED" and addon~="Blizzard_TalentUI" then return end
  self:HookTalentFrame()
  self:Refresh()
end

function Advisor:OnOptionsChanged()
  self:ApplyDocking()
  self:Refresh()
end

local registered,registrationError=pcall(function()
  ZGV:RegisterCallback("ZGV_TALENT_BUILD_CHANGED",Advisor,"Refresh")
  ZGV:RegisterCallback("ZGV_TALENTS_UPDATED",Advisor,"Refresh")
  ZGV:RegisterCallback("ZGV_OPTIONS_CHANGED",Advisor,"OnOptionsChanged")
  ZGV:RegisterEvent("ADDON_LOADED",Advisor,"OnEvent")
end)
if not registered and ZGV.LogError then ZGV:LogError("load: TalentAdvisor",registrationError) end
