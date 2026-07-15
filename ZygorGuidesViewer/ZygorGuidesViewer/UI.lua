local ZGV = ZygorGuidesViewer
local UI = ZGV:RegisterModule("UI", {
  goalRows={}, listRows={}, settingRows={}, tabs={}, mode="guide",
  goalOffset=0, listPage=1, arrowState=nil, lastNotification=nil,
})
UI.SkinData = UI.SkinData or function(property, ...)
  return ZGV:GetSkinData(property, ...)
end

local ROWS_PER_PAGE = 10

local function viewerSettings()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.viewer or {}
end

local function setFont(label,size,r,g,b)
  label:SetFont(GameFontNormal:GetFont(),size)
  label:SetJustifyH("LEFT")
  label:SetJustifyV("TOP")
  label:SetTextColor(r or 1,g or 1,b or 1)
end

local function label(parent,size,r,g,b)
  local value=parent:CreateFontString(nil,"ARTWORK","GameFontNormal")
  setFont(value,size,r,g,b)
  return value
end

local function button(parent,width,height,text,click)
  local value=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
  value:SetWidth(width)
  value:SetHeight(height)
  value:SetText(text)
  if value.GetFontString and value:GetFontString() then value:GetFontString():SetJustifyH("LEFT") end
  if click then value:SetScript("OnClick",click) end
  return value
end

local function trim(text,length)
  text=tostring(text or "")
  if #text>length then return text:sub(1,length-3).."..." end
  return text
end

local function direction(state)
  if not state then return "No waypoint" end
  if state.status=="arrived" then return "Arrived" end
  if state.status=="unreachable" then return "Waypoint set (map only)" end
  if state.status=="route" then return "Route available" end
  local relative=state.relative
  if type(relative)~="number" then return "Waypoint set" end
  local labels={"forward","front-right","right","back-right","back","back-left","left","front-left"}
  local slot=math.floor((relative+math.pi/8)/(math.pi/4))%8+1
  return labels[slot]
end

function UI:CreateArrow()
  if self.arrow then return self.arrow end
  local settings=ZGV.db.profile.arrow
  local frame=CreateFrame("Frame","ZygorGuidesViewerArrowFrame",UIParent)
  frame:SetWidth(206) frame:SetHeight(48)
  frame:SetPoint("CENTER",UIParent,"CENTER",tonumber(settings.x) or 0,tonumber(settings.y) or -120)
  frame:SetFrameStrata("HIGH")
  frame:SetBackdrop({
    bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=true,tileSize=16,edgeSize=10,insets={left=3,right=3,top=3,bottom=3},
  })
  frame:SetBackdropColor(0.03,0.03,0.03,0.92)
  frame:SetBackdropBorderColor(1,0.62,0.15,1)
  frame:SetMovable(true) frame:EnableMouse(true) frame:RegisterForDrag("LeftButton") frame:SetClampedToScreen(true)
  frame:SetScript("OnDragStart",function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    local x,y=self:GetCenter()
    local parentX,parentY=UIParent:GetCenter()
    if x and parentX then settings.x=math.floor(x-parentX+0.5) end
    if y and parentY then settings.y=math.floor(y-parentY+0.5) end
  end)
  local title=label(frame,11,1,0.82,0.36)
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-7)
  title:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-7)
  title:SetHeight(14)
  frame.title=title
  local status=label(frame,12,1,1,1)
  status:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-23)
  status:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-23)
  status:SetHeight(16)
  frame.status=status
  frame:SetScript("OnMouseUp",function(_,mouseButton)
    if mouseButton=="RightButton" then settings.shown=false frame:Hide() else UI:Toggle() end
  end)
  self.arrow=frame
  return frame
end

function UI:UpdateArrow(state)
  self.arrowState=state
  if not self.arrow then return end
  local settings=ZGV.db.profile.arrow
  if not settings.shown or not state or not state.visible then self.arrow:Hide() return end
  self.arrow.title:SetText(trim(state.title or "Zygor waypoint",40))
  local distance=type(state.distance)=="number" and string.format("%.0f yards",state.distance) or "Map waypoint"
  self.arrow.status:SetText(direction(state).." - "..distance)
  self.arrow:Show()
end

function UI:CreateMinimapButton()
  if self.minimapButton or not Minimap then return end
  local value=CreateFrame("Button","ZygorGuidesViewerMinimapButton",Minimap)
  value:SetWidth(30) value:SetHeight(30)
  value:SetPoint("TOPLEFT",Minimap,"TOPLEFT",-3,-2)
  value:SetFrameStrata("MEDIUM")
  local icon=value:CreateTexture(nil,"ARTWORK")
  icon:SetAllPoints(value)
  icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
  value.icon=icon
  value:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  value:SetScript("OnClick",function(_,mouseButton)
    if mouseButton=="RightButton" then UI:ShowGuideMenu() else UI:Toggle() end
  end)
  value:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:SetText("Zygor Guides")
    GameTooltip:AddLine("Left-click: show or hide viewer",0.8,0.8,0.8)
    GameTooltip:AddLine("Right-click: browse guides",0.8,0.8,0.8)
    GameTooltip:Show()
  end)
  value:SetScript("OnLeave",function() GameTooltip:Hide() end)
  self.minimapButton=value
end

function UI:CreateFrame()
  if self.frame then return self.frame end
  local settings=viewerSettings()
  local width=math.max(470,tonumber(settings.width) or 470)
  local height=math.max(500,tonumber(settings.height) or 500)
  local frame=CreateFrame("Frame","ZygorGuidesViewerFrame",UIParent)
  frame:SetWidth(width) frame:SetHeight(height)
  frame:SetScale(tonumber(settings.scale) or 1)
  frame:SetPoint("CENTER",UIParent,"CENTER",tonumber(settings.x) or -260,tonumber(settings.y) or 40)
  frame:SetFrameStrata("MEDIUM") frame:SetToplevel(true) frame:SetClampedToScreen(true)
  frame:SetMovable(true) frame:EnableMouse(true) frame:EnableMouseWheel(true) frame:RegisterForDrag("LeftButton")
  frame:SetBackdrop({
    bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
    tile=true,tileSize=16,edgeSize=12,insets={left=3,right=3,top=3,bottom=3},
  })
  frame:SetBackdropColor(0.025,0.025,0.045,0.97)
  frame:SetBackdropBorderColor(0.95,0.48,0.1,1)
  frame:SetScript("OnDragStart",function(self)
    if not viewerSettings().locked then self:StartMoving() end
  end)
  frame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    local x,y=self:GetCenter()
    local parentX,parentY=UIParent:GetCenter()
    if x and parentX then settings.x=math.floor(x-parentX+0.5) end
    if y and parentY then settings.y=math.floor(y-parentY+0.5) end
  end)
  frame:SetScript("OnMouseWheel",function(_,delta)
    if UI.mode=="guide" then UI:ScrollGoals(delta) end
  end)

  local title=label(frame,15,1,0.62,0.16)
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-13)
  title:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-36,-13)
  title:SetHeight(18) title:SetText("Zygor Guides Viewer")
  frame.title=title
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
  close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-2,-2)
  close:SetScript("OnClick",function() frame:Hide() end)

  local tabData={{"guide","Guide"},{"browse","Browse"},{"history","History"},{"favorites","Favorites"},{"settings","Settings"},{"report","Report"}}
  local previous
  for index,data in ipairs(tabData) do
    local tab=button(frame,70,22,data[2],function() UI:SetMode(data[1]) end)
    if previous then tab:SetPoint("TOPLEFT",previous,"TOPRIGHT",3,0) else tab:SetPoint("TOPLEFT",frame,"TOPLEFT",14,-39) end
    previous=tab
    tab.mode=data[1]
    self.tabs[index]=tab
  end

  local heading=label(frame,13,1,1,1)
  heading:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-67)
  heading:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-15,-67)
  heading:SetHeight(18)
  frame.heading=heading
  local subheading=label(frame,11,0.74,0.74,0.74)
  subheading:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-87)
  subheading:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-15,-87)
  subheading:SetHeight(16)
  frame.subheading=subheading

  local progress=CreateFrame("StatusBar",nil,frame)
  progress:SetWidth(width-30) progress:SetHeight(12)
  progress:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-108)
  progress:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  progress:SetStatusBarColor(0.95,0.45,0.08,1)
  progress:SetMinMaxValues(0,1) progress:SetValue(0)
  frame.progress=progress
  local progressText=label(progress,10,1,1,1)
  progressText:SetAllPoints(progress) progressText:SetJustifyH("CENTER") progressText:SetJustifyV("MIDDLE")
  frame.progressText=progressText
  local waypoint=label(frame,11,0.86,0.86,0.55)
  waypoint:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-124)
  waypoint:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-15,-124)
  waypoint:SetHeight(15)
  frame.waypoint=waypoint

  local search=CreateFrame("EditBox",nil,frame,"InputBoxTemplate")
  search:SetAutoFocus(false) search:SetHeight(20)
  search:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-111)
  search:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-112,-111)
  search:SetScript("OnTextChanged",function() if UI.mode=="browse" then UI.listPage=1 UI:Refresh() end end)
  search:SetScript("OnEnterPressed",function(self)
    local matches=ZGV.Catalog:Find(self:GetText() or "")
    if #matches==1 then ZGV.Runtime:SelectGuide(matches[1]) UI:SetMode("guide") end
    self:ClearFocus()
  end)
  frame.search=search
  local searchButton=button(frame,82,22,"Find guide",function() UI.listPage=1 UI:Refresh() end)
  searchButton:SetPoint("LEFT",search,"RIGHT",7,0)
  frame.searchButton=searchButton

  local previousList=button(frame,60,21,"< Page",function() UI.listPage=math.max(1,UI.listPage-1) UI:Refresh() end)
  previousList:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",15,15)
  frame.previousList=previousList
  local nextList=button(frame,60,21,"Page >",function() UI.listPage=UI.listPage+1 UI:Refresh() end)
  nextList:SetPoint("LEFT",previousList,"RIGHT",5,0)
  frame.nextList=nextList
  local listStatus=label(frame,10,0.7,0.7,0.7)
  listStatus:SetPoint("LEFT",nextList,"RIGHT",8,0)
  listStatus:SetHeight(18)
  frame.listStatus=listStatus

  local rowPrevious
  for index=1,ROWS_PER_PAGE do
    local row=button(frame,width-30,29,"",function(self)
      if self.guide then ZGV.Runtime:SelectGuide(self.guide) UI:SetMode("guide") end
    end)
    if rowPrevious then row:SetPoint("TOPLEFT",rowPrevious,"BOTTOMLEFT",0,-3) else row:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-146) end
    rowPrevious=row
    row:SetScript("OnEnter",function(self)
      if not self.guide then return end
      GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
      GameTooltip:SetText(self.guide.name or self.guide.title)
      GameTooltip:AddLine(self.guide.path or "",0.8,0.8,0.8,true)
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave",function() GameTooltip:Hide() end)
    self.listRows[index]=row
  end

  local goalPrevious
  for index=1,ROWS_PER_PAGE do
    local row=button(frame,width-30,31,"",function(self)
      if self.goalIndex then
        ZGV.Runtime:ActivateGoal(ZGV.Runtime.currentStep,self.goalIndex)
        UI:Refresh()
      end
    end)
    if goalPrevious then row:SetPoint("TOPLEFT",goalPrevious,"BOTTOMLEFT",0,-3) else row:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-146) end
    goalPrevious=row
    row:SetScript("OnEnter",function(self)
      local goal=self.goal
      if not goal then return end
      GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
      GameTooltip:SetText(goal.text or goal.raw or "Goal")
      if goal.destination then GameTooltip:AddLine("Waypoint: "..tostring(goal.destination.map or "unknown"),0.8,0.8,0.4,true) end
      if goal.questID then GameTooltip:AddLine("Quest ID: "..tostring(goal.questID),0.65,0.65,0.65) end
      for tipIndex=1,#(goal.tips or {}) do GameTooltip:AddLine(goal.tips[tipIndex],0.8,0.8,0.8,true) end
      GameTooltip:AddLine("Click to perform this guide action or mark it complete.",0.5,0.8,1,true)
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave",function() GameTooltip:Hide() end)
    self.goalRows[index]=row
  end

  local actionPrevious=button(frame,66,22,"Previous",function() ZGV.Runtime:PreviousStep() UI:Refresh() end)
  actionPrevious:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-222,15)
  frame.actionPrevious=actionPrevious
  local actionNext=button(frame,66,22,"Next",function() ZGV.Runtime:NextStep(true) UI:Refresh() end)
  actionNext:SetPoint("LEFT",actionPrevious,"RIGHT",5,0)
  frame.actionNext=actionNext
  local actionReset=button(frame,66,22,"Reset",function() ZGV.Runtime:ResetCurrentGuide() UI:Refresh() end)
  actionReset:SetPoint("LEFT",actionNext,"RIGHT",5,0)
  frame.actionReset=actionReset
  local favorite=button(frame,66,22,"Favorite",function()
    local guide=ZGV.Runtime.currentGuide
    if guide then ZGV.Runtime:ToggleFavorite(guide) UI:Refresh() end
  end)
  favorite:SetPoint("LEFT",actionReset,"RIGHT",5,0)
  frame.favorite=favorite

  local settingPrevious
  for index=1,8 do
    local row=button(frame,width-30,28,"",function(self)
      if self.settingAction then self.settingAction() UI:Refresh() end
    end)
    if settingPrevious then row:SetPoint("TOPLEFT",settingPrevious,"BOTTOMLEFT",0,-4) else row:SetPoint("TOPLEFT",frame,"TOPLEFT",15,-115) end
    settingPrevious=row
    self.settingRows[index]=row
  end

  frame:SetScript("OnHide",function() if ZGV.db then viewerSettings().shown=false end end)
  frame:Hide()
  self.frame=frame
  return frame
end

function UI:HideContent()
  local frame=self.frame
  frame.progress:Hide() frame.progressText:Hide() frame.waypoint:Hide()
  frame.search:Hide() frame.searchButton:Hide()
  frame.previousList:Hide() frame.nextList:Hide() frame.listStatus:Hide()
  frame.actionPrevious:Hide() frame.actionNext:Hide() frame.actionReset:Hide() frame.favorite:Hide()
  for index=1,ROWS_PER_PAGE do
    if self.goalRows[index] then self.goalRows[index]:Hide() end
    if self.listRows[index] then self.listRows[index]:Hide() end
    if self.settingRows[index] then self.settingRows[index]:Hide() end
  end
end

function UI:ScrollGoals(delta)
  local guide=ZGV.Runtime.currentGuide
  local step=guide and guide.steps[ZGV.Runtime.currentStep]
  if not step then return end
  local maxOffset=math.max(0,#step.goals-ROWS_PER_PAGE)
  self.goalOffset=math.max(0,math.min(maxOffset,self.goalOffset-(delta or 0)))
  self:RenderGuide()
end

function UI:RenderGuide()
  local frame=self.frame
  local runtime=ZGV.Runtime
  local guide=runtime.currentGuide
  self:HideContent()
  frame.progress:Show() frame.progressText:Show() frame.waypoint:Show()
  frame.actionPrevious:Show() frame.actionNext:Show() frame.actionReset:Show() frame.favorite:Show()
  if not guide then
    frame.heading:SetText("No guide selected")
    frame.subheading:SetText("Open Browse to choose from the installed guide catalog.")
    frame.progress:SetValue(0) frame.progressText:SetText("") frame.waypoint:SetText("")
    frame.actionPrevious:Disable() frame.actionNext:Disable() frame.actionReset:Disable() frame.favorite:Disable()
    return
  end
  local stepIndex=runtime.currentStep
  local step=guide.steps[stepIndex]
  if not step then
    frame.heading:SetText(guide.name or guide.title)
    frame.subheading:SetText("This guide has no usable steps. Use Report to inspect diagnostics.")
    frame.progress:SetValue(0) frame.progressText:SetText("") frame.waypoint:SetText("")
    frame.actionPrevious:Disable() frame.actionNext:Disable() frame.actionReset:Disable() frame.favorite:Enable()
    return
  end
  local state=runtime:GetStepState(step,stepIndex)
  frame.heading:SetText(trim(guide.name or guide.title,65))
  frame.subheading:SetText("Step "..stepIndex.." of "..#guide.steps.." - scroll over goals to see more")
  local ratio=state.required>0 and state.done/state.required or 0
  frame.progress:SetValue(ratio)
  frame.progressText:SetText(state.done.." / "..state.required.." objectives complete")
  local arrow=self.arrowState or (ZGV.Navigation and ZGV.Navigation:GetArrowState())
  if arrow and arrow.visible then
    local distance=type(arrow.distance)=="number" and string.format("%.0f yards",arrow.distance) or "map only"
    frame.waypoint:SetText("Waypoint: "..trim(arrow.title or "destination",45).." - "..direction(arrow).." ("..distance..")")
  else frame.waypoint:SetText("Waypoint: none") end
  local maxOffset=math.max(0,#step.goals-ROWS_PER_PAGE)
  self.goalOffset=math.max(0,math.min(self.goalOffset,maxOffset))
  for rowIndex=1,ROWS_PER_PAGE do
    local goalIndex=rowIndex+self.goalOffset
    local goal=step.goals[goalIndex]
    if goal then
      local goalState=state.goals[goalIndex]
      local row=self.goalRows[rowIndex]
      row.goal=goal row.goalIndex=goalIndex
      local marker=goalState and goalState.complete and "[x] " or "[ ] "
      row:SetText(marker..trim(goal.text or goal.raw or "",86))
      row:Show()
    end
  end
  ZGV.Compat.UI:SetEnabled(frame.actionPrevious,stepIndex>1)
  ZGV.Compat.UI:SetEnabled(frame.actionNext,stepIndex<#guide.steps or guide.next~=nil)
  frame.actionNext:SetText(stepIndex>=#guide.steps and "Finish" or "Next")
  frame.actionReset:Enable()
  frame.favorite:Enable()
  frame.favorite:SetText(ZGV.db.profile.favorites[guide.id] and "Unfavorite" or "Favorite")
end

function UI:GetListResults()
  if self.mode=="browse" then return ZGV.Catalog:Find(self.frame.search:GetText() or "") end
  if self.mode=="favorites" then
    local results={}
    for index=1,#ZGV.Catalog.sorted do
      local guide=ZGV.Catalog.sorted[index]
      if ZGV.db.profile.favorites[guide.id] then results[#results+1]=guide end
    end
    return results
  end
  local results={}
  for index=1,#ZGV.db.profile.history do
    local entry=ZGV.db.profile.history[index]
    local guide=ZGV.Catalog:Get(type(entry)=="table" and entry.id or entry)
    if guide then results[#results+1]=guide end
  end
  return results
end

function UI:RenderList()
  local frame=self.frame
  self:HideContent()
  if self.mode=="browse" then frame.search:Show() frame.searchButton:Show()
  else frame.search:Hide() frame.searchButton:Hide() end
  frame.previousList:Show() frame.nextList:Show() frame.listStatus:Show()
  local results=self:GetListResults()
  local pages=math.max(1,math.ceil(#results/ROWS_PER_PAGE))
  self.listPage=math.max(1,math.min(self.listPage,pages))
  local labels={browse="Guide browser",history="Guide history",favorites="Favourite guides"}
  frame.heading:SetText(labels[self.mode] or "Guides")
  frame.subheading:SetText(self.mode=="browse" and "Search by title, zone, profession, dungeon, or category." or "Select a guide to load it.")
  local first=(self.listPage-1)*ROWS_PER_PAGE+1
  for rowIndex=1,ROWS_PER_PAGE do
    local guide=results[first+rowIndex-1]
    if guide then
      local row=self.listRows[rowIndex]
      row.guide=guide
      row:SetText(trim((guide.path~="" and guide.path.." - " or "")..(guide.name or guide.title),86))
      row:Show()
    end
  end
  ZGV.Compat.UI:SetEnabled(frame.previousList,self.listPage>1)
  ZGV.Compat.UI:SetEnabled(frame.nextList,self.listPage<pages)
  frame.listStatus:SetText(#results.." guides - page "..self.listPage.."/"..pages)
end

function UI:RenderSettings()
  local frame=self.frame
  self:HideContent()
  frame.heading:SetText("Viewer settings")
  frame.subheading:SetText("Changes are saved for this profile.")
  local profile=ZGV.db.profile
  local settings={
    {"Automatically accept quests",profile.automation,"accept"},
    {"Automatically turn in quests",profile.automation,"turnin"},
    {"Automatically select gossip",profile.automation,"gossip"},
    {"Automatically advance completed steps",profile.automation,"progress"},
    {"Send waypoints to TomTom",profile.navigation,"useTomTom"},
    {"Show waypoint helper",profile.arrow,"shown"},
    {"Lock viewer position",profile.viewer,"locked"},
  }
  for index=1,#settings do
    local setting=settings[index]
    local row=self.settingRows[index]
    row:SetText(setting[1]..": "..(setting[2][setting[3]] and "ON" or "OFF"))
    row.settingAction=function() setting[2][setting[3]]=not setting[2][setting[3]] UI:UpdateArrow(UI.arrowState) end
    row:Show()
  end
  local reset=self.settingRows[8]
  reset:SetText("Reset viewer position")
  reset.settingAction=function()
    profile.viewer.x=-260 profile.viewer.y=40 profile.viewer.scale=1
    frame:ClearAllPoints() frame:SetPoint("CENTER",UIParent,"CENTER",-260,40) frame:SetScale(1)
  end
  reset:Show()
end

function UI:RenderReport()
  local frame=self.frame
  self:HideContent()
  frame.heading:SetText("Diagnostics")
  frame.subheading:SetText("The same report is available through /zygor report.")
  local index=0
  for line in ZGV:GetDiagnosticsText():gmatch("[^\n]+") do
    index=index+1
    if index>ROWS_PER_PAGE then break end
    local row=self.settingRows[index]
    row:SetText(trim(line,88)) row.settingAction=nil row:Show()
  end
end

function UI:Refresh()
  if not self.frame then return end
  for index=1,#self.tabs do
    local tab=self.tabs[index]
    ZGV.Compat.UI:SetEnabled(tab,tab.mode~=self.mode)
  end
  if self.mode=="guide" then self:RenderGuide()
  elseif self.mode=="browse" or self.mode=="history" or self.mode=="favorites" then self:RenderList()
  elseif self.mode=="settings" then self:RenderSettings()
  else self:RenderReport() end
end

function UI:SetMode(mode)
  self:CreateFrame()
  self.mode=mode or "guide"
  self.goalOffset=0
  if mode=="browse" then self.listPage=1 end
  self.frame:Show()
  if ZGV.db then viewerSettings().shown=true end
  self:Refresh()
end

function UI:ShowViewer() self:SetMode("guide") end
function UI:ShowGuideMenu() self:SetMode("browse") end
function UI:ShowOptions() self:SetMode("settings") end
function UI:ShowReport() self:SetMode("report") end

function UI:Toggle()
  self:CreateFrame()
  if self.frame:IsShown() then self.frame:Hide() else self:ShowViewer() end
end

function UI:OnNotification(notification)
  self.lastNotification=notification
  if self.mode=="guide" then self:Refresh() end
end

function UI:OnStartup()
  self:CreateFrame()
  self:CreateMinimapButton()
  self:CreateArrow()
  self:UpdateArrow(ZGV.Navigation and ZGV.Navigation:GetArrowState())
  if viewerSettings().shown~=false then self:ShowViewer() else self.frame:Hide() end
end

ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",UI,"Refresh")
ZGV:RegisterCallback("ZGV_STEP_CHANGED",UI,"Refresh")
ZGV:RegisterCallback("ZGV_GOAL_UPDATED",UI,"Refresh")
ZGV:RegisterCallback("ZGV_CATALOG_FINALIZED",UI,"Refresh")
ZGV:RegisterCallback("ZGV_FAVORITES_CHANGED",UI,"Refresh")
ZGV:RegisterCallback("ZGV_ARROW_UPDATED",UI,"UpdateArrow")
ZGV:RegisterCallback("ZGV_NOTIFICATION",UI,"OnNotification")
