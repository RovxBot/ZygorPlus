-- Guided-tour implementation based on the Classic tutorial, retargeted to
-- the 3.3.5a modern viewer shell.  It deliberately uses only ordinary frames
-- and textures so it works on build 12340 without modern mixin/XML support.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Tutorial=ZGV.Tutorial or {}
ZGV.Tutorial=Tutorial
Tutorial.Order={"start","guideviewer","guides","options","steps","progress","arrow","actionbar","finish"}

local copy={
  start={"Welcome to Zygor Guides","This short tour highlights the viewer controls you use while following a guide."},
  guideviewer={"Guide Viewer","Your current guide and its objectives are displayed here. Click an objective to use its guide action."},
  guides={"Guide Menu","Open the guide menu to browse, search, and load another guide without losing your current progress."},
  options={"Viewer Actions","This menu contains quick actions, settings, and diagnostics for the active guide."},
  steps={"Step Controls","Use the previous and next controls to move through a guide manually whenever you need to."},
  progress={"Guide Progress","The progress bar tracks completed objectives and steps in the active guide."},
  arrow={"Waypoint Arrow","The movable arrow points to the current guide destination and reports distance and direction."},
  actionbar={"Action Bar","Guide actions are surfaced here so common interactions remain one click away."},
  finish={"You are ready","The viewer, guide menu, waypoint arrow, widgets, and action bar all stay synchronized as your guide advances."},
}

local function title(text) return (ZGV.L and ZGV.L["guidetutorial_"..text]) or (copy[text] and copy[text][1]) or text end
local function body(text) return (ZGV.L and ZGV.L["guidetutorial_"..text.."tip"]) or (copy[text] and copy[text][2]) or "" end

local function frameText(parent,size,bold)
  local value=parent:CreateFontString(nil,"ARTWORK",bold and "GameFontHighlight" or "GameFontNormal")
  local path,_,flags=GameFontNormal:GetFont()
  value:SetFont(path,size,flags)
  value:SetJustifyH("LEFT")
  value:SetJustifyV("TOP")
  value:SetTextColor(1,1,1,1)
  return value
end

function Tutorial:CreateFrame()
  if self.TooltipFrame then return self.TooltipFrame end
  local cover=CreateFrame("Frame","ZygorGuidesViewerTutorialCover",UIParent)
  cover:SetAllPoints(UIParent); cover:SetFrameStrata("HIGH"); cover:SetFrameLevel(20); cover:EnableMouse(true); cover:Hide()
  self.Invis=cover

  local frame=CreateFrame("Frame","ZygorGuidesViewerTutorialTooltip",UIParent)
  frame:SetWidth(350); frame:SetHeight(180); frame:SetFrameStrata("DIALOG"); frame:SetFrameLevel(40); frame:EnableMouse(true)
  frame:SetBackdrop(ZGV:GetSkinData("WidgetsBackdrop") or {bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  local color=ZGV:GetSkinData("WidgetsPopupBackdropColor") or {.08,.08,.08,1}
  local border=ZGV:GetSkinData("WidgetsPopupBackdropBorderColor") or {.25,.25,.25,1}
  frame:SetBackdropColor(unpack(color)); frame:SetBackdropBorderColor(unpack(border))
  frame:Hide(); self.TooltipFrame=frame

  local line=frame:CreateTexture(nil,"BACKGROUND")
  line:SetTexture(ZGV.SKINDIR.."tutorialline-dia"); line:SetSize(100,100); frame.Line=line
  local heading=frameText(frame,16,true); heading:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-12); heading:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-35,-12); heading:SetHeight(22); frame.MainText=heading
  local tip=frameText(frame,13,false); tip:SetPoint("TOPLEFT",heading,"BOTTOMLEFT",0,-8); tip:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-12,-8); tip:SetWidth(326); tip:SetSpacing(4); frame.TipText=tip
  local highlight=frame:CreateTexture(nil,"ARTWORK"); highlight:SetPoint("RIGHT",heading,"LEFT",-7,0); highlight:SetSize(20,20); highlight:Hide(); frame.ButtonTex=highlight
  local progress=frameText(frame,11,true); progress:SetPoint("TOPLEFT",tip,"BOTTOMLEFT",0,-10); progress:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-12,-10); progress:SetText("Guide progress tracks your objectives and steps."); progress:Hide(); frame.ProgressText=progress
  local bar=CreateFrame("StatusBar",nil,frame); bar:SetPoint("TOPLEFT",progress,"BOTTOMLEFT",0,-5); bar:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-12,-5); bar:SetHeight(7); bar:SetMinMaxValues(0,1); bar:SetValue(.66); bar:SetStatusBarTexture(ZGV.SKINDIR.."white"); bar:SetStatusBarColor(.15,.85,.25,1); bar:Hide(); frame.ProgressBar=bar
  local back=CreateFrame("Frame",nil,bar); back:SetAllPoints(bar); back:SetFrameLevel(math.max(1,bar:GetFrameLevel()-1)); back:SetBackdrop({bgFile=ZGV.SKINDIR.."white"}); back:SetBackdropColor(.1,.1,.1,1)
  local function button(point,x,caption,callback)
    local value=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
    value:SetSize(68,24); value:SetPoint(point,frame,point,x,9); value:SetText(caption); value:SetScript("OnClick",callback)
    return value
  end
  frame.Back=button("BOTTOMLEFT",10,(ZGV.L and ZGV.L.guidetutorial_backbutton) or "Back",function() Tutorial:Previous() end)
  frame.Next=button("BOTTOMRIGHT",-10,(ZGV.L and ZGV.L.guidetutorial_next) or "Next",function() Tutorial:Next() end)
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,2); close:SetScale(.7); close:SetScript("OnClick",function() Tutorial:Close() end); frame.Close=close
  return frame
end

function Tutorial:SavePositions()
  local ui=ZGV.UI
  if ui and ui.CreateFrame then ui:CreateFrame() end
  local viewer=ui and ui.frame
  local controls=viewer and viewer.iconButtons or {}
  self.Locations={
    start=viewer,guideviewer=viewer,guides=controls and controls[1],options=controls and controls[2],
    steps=viewer and viewer.actionNext,progress=viewer and viewer.progressBack,arrow=ui and ui.arrow,
    actionbar=ZGV.ActionBar and ZGV.ActionBar.Frame,finish=viewer,
  }
end

function Tutorial:SetDim(target)
  if self.dimmed and self.dimmed.SetAlpha then self.dimmed:SetAlpha(1) end
  self.dimmed=nil
  local viewer=ZGV.UI and ZGV.UI.frame
  if viewer and target and target~=viewer and target.GetParent then
    viewer:SetAlpha(.38); self.dimmed=viewer
  elseif viewer then viewer:SetAlpha(1) end
end

function Tutorial:Place(target)
  local frame=self.TooltipFrame
  frame:ClearAllPoints(); frame.Line:Hide()
  if not target or not target.GetCenter or not target:IsVisible() then
    frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
    return
  end
  local left,right,top,bottom=target:GetLeft(),target:GetRight(),target:GetTop(),target:GetBottom()
  local width,height=UIParent:GetWidth(),UIParent:GetHeight()
  if not left or not right or not top or not bottom then frame:SetPoint("CENTER",UIParent,"CENTER",0,0); return end
  local side=left<(width/2) and "RIGHT" or "LEFT"
  local vertical=top+frame:GetHeight()+45<height and "TOP" or "BOTTOM"
  local targetPoint=(vertical=="TOP" and "BOTTOM" or "TOP")..(side=="RIGHT" and "LEFT" or "RIGHT")
  local anchorPoint=(vertical=="TOP" and "TOP" or "BOTTOM")..(side=="RIGHT" and "RIGHT" or "LEFT")
  local x=side=="RIGHT" and 52 or -52
  local y=vertical=="TOP" and 52 or -52
  frame:SetPoint(anchorPoint,target,targetPoint,x,y)
  frame.Line:SetTexCoord(side=="RIGHT" and 0 or 1,side=="RIGHT" and 1 or 0,0,1)
  frame.Line:SetSize(math.abs(x),math.abs(y)); frame.Line:SetPoint(targetPoint,frame,anchorPoint); frame.Line:Show()
end

function Tutorial:Show(position)
  local key=self.Order[position] or position
  if not key then self:Close(); return end
  self.CurrentIndex=type(position)=="number" and position or 1
  if type(position)~="number" then for i,name in ipairs(self.Order) do if name==key then self.CurrentIndex=i; break end end end
  local target=self.Locations and self.Locations[key]
  local frame=self:CreateFrame()
  frame.MainText:SetText(title(key)); frame.TipText:SetText(body(key)); frame.TipText:SetHeight(frame.TipText:GetStringHeight())
  local showProgress=key=="progress"; ZGV.Compat.UI:SetShown(frame.ProgressText,showProgress); ZGV.Compat.UI:SetShown(frame.ProgressBar,showProgress)
  local height=frame.TipText:GetStringHeight()+78+(showProgress and 35 or 0); frame:SetHeight(math.max(132,math.min(260,height)))
  local texture=target and target.GetNormalTexture and target:GetNormalTexture()
  if texture and texture.GetTexture and texture:GetTexture() then frame.ButtonTex:SetTexture(texture:GetTexture()); frame.ButtonTex:SetTexCoord(texture:GetTexCoord()); frame.ButtonTex:Show() else frame.ButtonTex:Hide() end
  ZGV.Compat.UI:SetEnabled(frame.Back,self.CurrentIndex>1); frame.Next:SetText(key=="finish" and ((ZGV.L and ZGV.L.guidetutorial_donebutton) or "Done") or ((ZGV.L and ZGV.L.guidetutorial_next) or "Next"))
  self:SetDim(target); self:Place(target); frame:Show(); self.Invis:Show(); self.Running=true; self.CurrentTip=key
end

function Tutorial:FadeStart()
  self:CreateFrame()
  if self.Invis then self.Invis:Show() end
end
function Tutorial:FadingReset()
  if self.dimmed and self.dimmed.SetAlpha then self.dimmed:SetAlpha(1) end
  self.dimmed=nil
end
function Tutorial:GetDimensions(viewer)
  local frame=self:CreateFrame(); viewer=viewer or (ZGV.UI and ZGV.UI.frame)
  self.SizeInfo={TotalWidth=UIParent:GetWidth(),TotalHeight=UIParent:GetHeight(),TooltipWidth=frame:GetWidth(),TooltipHeight=frame:GetHeight()}
  if viewer then self.SizeInfo.ViewerLeft,self.SizeInfo.ViewerRight,self.SizeInfo.ViewerBottom,self.SizeInfo.ViewerTop=viewer:GetLeft(),viewer:GetRight(),viewer:GetBottom(),viewer:GetTop() end
  return self.SizeInfo
end
function Tutorial:PlaceTooltip(_,_,_,_,placement)
  return self:Place(placement or (self.Locations and self.Locations[self.CurrentTip]))
end
function Tutorial:Next(position)
  if position~=nil then return self:Show(position) end
  if self.CurrentTip=="finish" then return self:Close() end
  self:Show((self.CurrentIndex or 0)+1)
end
function Tutorial:Previous() self:Show(math.max(1,(self.CurrentIndex or 1)-1)) end
function Tutorial:Run()
  self:SavePositions(); self:CreateFrame(); self:GetDimensions(); self:Show(1); self:FadeStart()
end
function Tutorial:Close()
  self.Running=false
  if self.dimmed and self.dimmed.SetAlpha then self.dimmed:SetAlpha(1) end
  self.dimmed=nil
  if self.Invis then self.Invis:Hide() end
  if self.TooltipFrame then self.TooltipFrame:Hide() end
end
