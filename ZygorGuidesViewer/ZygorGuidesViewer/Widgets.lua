-- Classic widget-manager contract for the WotLK viewer.  The Anniversary
-- manager is data driven; this implementation retains registration, grid
-- layout, resize/drag, floating widgets, persistence, backup/import, popup
-- ownership, and skin refresh without shipping retail-only widget content.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Widgets=ZGV.Widgets or {}
ZGV.Widgets=Widgets
ZGV:RegisterModule("Widgets",Widgets)
Widgets.Registered=Widgets.Registered or {}
Widgets.RegisteredFloating=Widgets.RegisteredFloating or {}
Widgets.Events=Widgets.Events or {}
Widgets.Messages=Widgets.Messages or {}
Widgets.Grid=6
Widgets.Padding=10

local function wipe(tab) for key in pairs(tab) do tab[key]=nil end return tab end
local function copy(source)
  local result={}
  for key,value in pairs(source or {}) do result[key]=value end
  return result
end
local function skin(name,fallback) return (ZGV.GetSkinData and ZGV:GetSkinData(name)) or fallback end
local function data()
  local profile=ZGV.db and ZGV.db.profile
  if not profile then return {} end
  if type(profile.widgets)~="table" then profile.widgets={} end
  -- Old profiles used widgets for the grid; the original compact widget used
  -- widgets.guide.  Store grid data separately so neither representation is
  -- overwritten during migration.
  profile.widgets.layout=profile.widgets.layout or {}
  profile.widgets.floating=profile.widgets.floating or {}
  return profile.widgets
end

function Widgets:RegisterWidget(object)
  if type(object)~="table" or type(object.ident)~="string" or object.ident=="" then return false,"widget identifier required" end
  if object.valid~=nil and ((type(object.valid)=="function" and not object.valid()) or object.valid==false) then return false,"not valid" end
  object.sizes=object.sizes or {{width=1,height=1}}
  object.width=object.width or object.sizes[1].width or 1
  object.height=object.height or object.sizes[1].height or 1
  object.name=object.name or (ZGV.L and ZGV.L["widget_"..object.ident.."_name"]) or object.ident
  object.description=object.description or (ZGV.L and ZGV.L["widget_"..object.ident.."_description"]) or ""
  local limits={minwidth=object.width,minheight=object.height,maxwidth=object.width,maxheight=object.height}
  for _,size in ipairs(object.sizes) do
    limits.minwidth=math.min(limits.minwidth,size.width); limits.minheight=math.min(limits.minheight,size.height)
    limits.maxwidth=math.max(limits.maxwidth,size.width); limits.maxheight=math.max(limits.maxheight,size.height)
  end
  object.sizelimits=object.sizelimits or limits
  self.Registered[object.ident]=object
  if object.floating then self.RegisteredFloating[object.ident]=object end
  for event in pairs(object.events or {}) do self.Events[event]=true end
  for topic in pairs(object.messages or {}) do self.Messages[topic]=true end
  return object
end

function Widgets:CreateParent()
  if self.Parent then return self.Parent end
  local parent=CreateFrame("Frame","ZygorGuidesViewerWidgetsHome",UIParent)
  parent:SetWidth(600); parent:SetHeight(110); parent:SetPoint("CENTER",UIParent,"CENTER",0,120); parent:SetFrameStrata("DIALOG"); parent:SetClampedToScreen(true)
  parent:SetBackdrop(skin("WidgetsBackdrop",{bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1}))
  parent:SetBackdropColor(unpack(skin("WidgetsBackdropColor",{.06,.06,.06,.94}))); parent:SetBackdropBorderColor(unpack(skin("WidgetsBackdropBorderColor",{.2,.2,.2,1})))
  parent:Hide(); self.Parent=parent; self.TileSize=math.floor((parent:GetWidth()-self.Padding)/self.Grid)
  return parent
end

function Widgets:CreateConfig()
  if self.Config then return self.Config end
  local frame=CreateFrame("Frame","ZygorGuidesViewerWidgetsConfig",UIParent)
  frame:SetWidth(430); frame:SetHeight(360); frame:SetPoint("CENTER",UIParent,"CENTER",0,40); frame:SetFrameStrata("DIALOG"); frame:SetToplevel(true); frame:EnableMouse(true)
  frame:SetBackdrop(skin("WidgetsBackdrop",{bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1}))
  frame:SetBackdropColor(unpack(skin("WidgetsBackdropColor",{.06,.06,.06,.94}))); frame:SetBackdropBorderColor(unpack(skin("WidgetsBackdropBorderColor",{.2,.2,.2,1})))
  local heading=frame:CreateFontString(nil,"ARTWORK","GameFontHighlight")
  heading:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-12); heading:SetText("Zygor Widgets"); heading:SetHeight(20); frame.heading=heading
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,2); close:SetScript("OnClick",function() Widgets:DisableConfig() end)
  frame.rows={}; frame:Hide(); self.Config=frame; return frame
end

function Widgets:RenderConfig()
  local frame=self:CreateConfig()
  local items={}
  for _,object in pairs(self.Registered) do if not object.system then items[#items+1]=object end end
  table.sort(items,function(left,right) return tostring(left.name)<tostring(right.name) end)
  for index,object in ipairs(items) do
    local row=frame.rows[index]
    if not row then
      row=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate"); row:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-40-(index-1)*28); row:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-12,-40-(index-1)*28); row:SetHeight(24); frame.rows[index]=row
    end
    row.object=object; row:SetText((object.active and "Remove: " or "Add: ")..object.name)
    row:SetScript("OnClick",function(self)
      if self.object.active then Widgets:DisableWidget(self.object) else Widgets:AddWidget(self.object) end
      Widgets:RenderConfig()
    end); row:Show()
  end
  for index=#items+1,#frame.rows do frame.rows[index]:Hide() end
end

function Widgets:CreateFrame(object)
  if object.frame then return object.frame end
  if object.external then
    if object.Initialise then object:Initialise() end
    return object.frame
  end
  local parent=object.floating and UIParent or self:CreateParent()
  local frame=CreateFrame("Button",nil,parent)
  frame:SetBackdrop(skin("WidgetsBackdrop",{bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1}))
  frame:SetBackdropColor(unpack(skin("WidgetsBackdropColor",{.06,.06,.06,.94}))); frame:SetBackdropBorderColor(unpack(skin("WidgetsBackdropBorderColor",{.2,.2,.2,1})))
  frame:SetClampedToScreen(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  local heading=frame:CreateFontString(nil,"ARTWORK","GameFontHighlight")
  heading:SetPoint("TOPLEFT",frame,"TOPLEFT",7,-6); heading:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-25,-6); heading:SetHeight(17); heading:SetJustifyH("LEFT"); heading:SetText(object.name); frame.heading=heading
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",3,3); close:SetScale(.62); close:SetScript("OnClick",function() Widgets:DisableWidget(object) end); frame.close=close
  frame:SetScript("OnDragStart",function()
    if object.floating then frame:StartMoving() else Widgets.Dragging=object end
  end)
  frame:SetScript("OnDragStop",function()
    if object.floating then frame:StopMovingOrSizing(); Widgets:SaveFloating(object) else Widgets.Dragging=nil; Widgets:ApplyLayout() end
  end)
  frame:SetScript("OnMouseUp",frame:GetScript("OnDragStop"))
  frame:SetScript("OnClick",function(_,button) if button=="RightButton" and object.TogglePopup then object:TogglePopup() end end)
  if object.floating then frame:SetMovable(true) end
  object.frame=frame
  if object.Initialise then object:Initialise(frame) end
  return frame
end

function Widgets:Resize(object)
  local frame=self:CreateFrame(object)
  if object.external then return frame end
  local width=(object.width or 1)*self.TileSize-self.Padding
  local height=(object.height or 1)*self.TileSize-self.Padding
  frame:SetSize(width,height)
  if object.OnResize then object:OnResize(width,height) end
end

function Widgets:SaveFloating(object)
  local x,y=object.frame:GetCenter(); local px,py=UIParent:GetCenter()
  if x and px then
    local saved={x=math.floor(x-px+.5),y=math.floor(y-py+.5),width=object.frame:GetWidth(),height=object.frame:GetHeight()}
    data().floating[object.ident]=saved
    if object.ident=="guide" and ZGV.db and ZGV.db.profile.widgets.guide then
      local legacy=ZGV.db.profile.widgets.guide; legacy.x,legacy.y=saved.x,saved.y
    end
  end
end

function Widgets:Place(object,row,column)
  object.row,object.column=row,column
  local frame=self:CreateFrame(object); self:Resize(object); frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT",self.Parent,"TOPLEFT",column*self.TileSize+self.Padding/2,-row*self.TileSize-self.Padding/2)
end

function Widgets:Fits(object,row,column)
  if row<0 or column<0 or column+(object.width or 1)>self.Grid then return false end
  for ident,entry in pairs(data().layout) do
    if ident~=object.ident then
      local other=self.Registered[ident]
      if other then
        local r,c,w,h=entry.row or entry[1] or 0,entry.column or entry[2] or 0,entry.width or entry[3] or other.width,entry.height or entry[4] or other.height
        if row<r+h and r<row+(object.height or 1) and column<c+w and c<column+(object.width or 1) then return false end
      end
    end
  end
  return true
end

function Widgets:EnableWidget(object,row,column)
  if type(object)=="string" then object=self.Registered[object] end
  if not object then return false end
  local settings=data()
  if object.floating then
    local saved=settings.floating[object.ident] or {}; settings.floating[object.ident]=saved; local frame=self:CreateFrame(object)
    self:Resize(object); frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",saved.x or 250,saved.y or -130)
  else
    row,column=row or 0,column or 0
    if not self:Fits(object,row,column) then
      for r=0,20 do for c=0,self.Grid-1 do if self:Fits(object,r,c) then row,column=r,c; break end end if self:Fits(object,row,column) then break end end
    end
    settings.layout[object.ident]={row=row,column=column,width=object.width,height=object.height}
    self:Place(object,row,column)
  end
  object.active=true; self:CreateFrame(object):Show()
  if object.ident=="guide" and ZGV.db and ZGV.db.profile.widgets.guide then ZGV.db.profile.widgets.guide.shown=true end
  if object.Update then object:Update() end
  self:ApplyLayout(); return true
end

function Widgets:DisableWidget(object)
  if type(object)=="string" then object=self.Registered[object] end
  if not object then return false end
  object.active=false; if object.frame then object.frame:Hide() end
  if object.ident=="guide" and ZGV.db and ZGV.db.profile.widgets.guide then ZGV.db.profile.widgets.guide.shown=false end
  if object.floating then data().floating[object.ident]=nil else data().layout[object.ident]=nil end
  return true
end

function Widgets:ApplyLayout()
  local settings=data(); local rows=0
  for ident,entry in pairs(settings.layout) do
    local object=self.Registered[ident]
    if object then
      object.width=entry.width or entry[3] or object.width; object.height=entry.height or entry[4] or object.height
      self:Place(object,entry.row or entry[1] or 0,entry.column or entry[2] or 0); object.active=true; object.frame:Show(); rows=math.max(rows,(object.row or 0)+(object.height or 1))
    else settings.layout[ident]=nil end
  end
  if self.Parent then self.Parent:SetHeight(math.max(110,(rows+1)*self.TileSize)); ZGV.Compat.UI:SetShown(self.Parent,rows>0) end
end

function Widgets:SetupWidgets()
  self:CreateParent(); self:CreateConfig(); self:ApplyLayout(); return true
end
function Widgets:LoadFloating() return self:ToggleFloaters(nil,true) end
function Widgets:ShowConfig()
  self:CreateConfig(); self:RenderConfig(); self.Config:Show(); self.ConfigMode=true; return self.Config
end
function Widgets:EnableConfig() return self:ShowConfig() end
function Widgets:DisableConfig()
  if self.Config then self.Config:Hide() end
  self.ConfigMode=false; self.Dragging=nil; self.Resizing=nil
end
function Widgets:ToggleConfig()
  if self.ConfigMode then self:DisableConfig() else self:EnableConfig() end
  return self.ConfigMode
end
function Widgets:ToggleConfigMenu() return self:ToggleConfig() end
function Widgets:ExitAddMode() self.PendingRow=nil; self.PendingColumn=nil; return self:DisableConfig() end
function Widgets:RecordAddWidget(row,column)
  self.PendingRow,self.PendingColumn=tonumber(row) or 0,tonumber(column) or 0
  return self:ShowConfig()
end
function Widgets:AddWidget(object)
  return self:EnableWidget(object,self.PendingRow or 0,self.PendingColumn or 0)
end
function Widgets:HoverBarShow() end
function Widgets:HoverBarHide() end
function Widgets:ConfigButtonTooltip() end
function Widgets:ClearButtonTooltip() end
function Widgets:ExitAddButtonTooltip() end

function Widgets:ToggleFloaters(_,visible)
  for ident,object in pairs(self.RegisteredFloating) do
    if data().floating[ident] then
      if visible==false then if object.frame then object.frame:Hide() end else self:EnableWidget(object) end
    end
  end
end

function Widgets:ApplySkin()
  local backdrop=skin("WidgetsBackdrop",{bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  local color=skin("WidgetsBackdropColor",{.06,.06,.06,.94}); local border=skin("WidgetsBackdropBorderColor",{.2,.2,.2,1})
  for _,frame in ipairs({self.Parent,self.Config}) do
    if frame then frame:SetBackdrop(backdrop); frame:SetBackdropColor(unpack(color)); frame:SetBackdropBorderColor(unpack(border)) end
  end
  for _,object in pairs(self.Registered) do
    if object.frame then
      object.frame:SetBackdrop(backdrop); object.frame:SetBackdropColor(unpack(color)); object.frame:SetBackdropBorderColor(unpack(border))
      if object.ApplySkin then object:ApplySkin() end
    end
  end
end

function Widgets:ClearWidgets()
  for ident in pairs(copy(data().layout)) do self:DisableWidget(ident) end
  for ident in pairs(copy(data().floating)) do self:DisableWidget(ident) end
  self:ApplyLayout()
end

function Widgets:TogglePinned(object)
  if type(object)=="string" then object=self.Registered[object] end
  if not object then return false end
  if object.active then return self:DisableWidget(object) end
  return self:EnableWidget(object)
end

function Widgets:HideAllPopups()
  for _,object in pairs(self.Registered) do if object.HidePopup then object:HidePopup() end end
end

function Widgets:Backup()
  local result={layout=copy(data().layout),floating=copy(data().floating),state={}}
  for ident,object in pairs(self.Registered) do if object.Backup then result.state[ident]=object:Backup() end end
  self.lastExportString=result; return result
end

function Widgets:Import(snapshot)
  if type(snapshot)=="string" and loadstring and ZGV.db and ZGV.db.global and ZGV.db.global.trustedUserScripts then
    local chunk=loadstring("return "..snapshot); snapshot=chunk and chunk()
  end
  if type(snapshot)~="table" then return false,"invalid widget backup" end
  local settings=data(); settings.layout=copy(snapshot.layout); settings.floating=copy(snapshot.floating)
  for ident,value in pairs(snapshot.state or {}) do local object=self.Registered[ident]; if object and object.Import then object:Import(value) end end
  self:ApplyLayout(); self:ToggleFloaters(nil,true); return true
end

function Widgets:EventDriver(event,...)
  for _,object in pairs(self.Registered) do if object.active and object.events and object.events[event] and object.OnEvent then object:OnEvent(event,...) end end
end
function Widgets:MessageDriver(_,topic,...)
  for _,object in pairs(self.Registered) do if object.active and object.messages and object.messages[topic] and object.OnEvent then object:OnEvent(topic,...) end end
end

function Widgets:OnUpdate(elapsed)
  for _,object in pairs(self.Registered) do
    if object.active and object.OnTick then
      object._elapsed=(object._elapsed or 0)+elapsed
      if object._elapsed>=(object.tick or 1) then object._elapsed=0; object:OnTick() end
    end
  end
end

function Widgets:RegisterGuideWidget()
  if self.Registered.guide or not ZGV.GuideWidget then return end
  local guide={ident="guide",name="Guide Objectives",description="A movable compact view of the current guide objectives.",floating=true,external=true,sizes={{width=3,height=2}}}
  function guide:Initialise()
    -- Reuse the established WotLK objective widget rather than rendering a
    -- duplicate set of goal counters.  The manager owns its persisted state.
    self.frame=ZGV.GuideWidget:Create()
    self.frame:SetScript("OnDragStop",function() self.frame:StopMovingOrSizing(); Widgets:SaveFloating(self) end)
  end
  function guide:Update() ZGV.GuideWidget:Refresh() end
  self:RegisterWidget(guide)
end

function Widgets:OnStartup()
  self:CreateParent(); self:RegisterGuideWidget()
  local settings=data()
  local legacy=settings.guide
  if legacy and legacy.shown and not settings.floating.guide then settings.floating.guide={x=legacy.x or 250,y=legacy.y or -130} end
  self:ApplyLayout()
  self:ToggleFloaters(nil,true)
  for event in pairs(self.Events) do ZGV:AddEventHandler(event,function(_,fired,...) Widgets:EventDriver(fired,...) end) end
  for topic in pairs(self.Messages) do ZGV:AddMessageHandler(topic,function(_,fired,...) Widgets:MessageDriver(nil,fired,...) end) end
  self.Driver=self.Driver or CreateFrame("Frame")
  self.Driver:SetScript("OnUpdate",function(_,elapsed) Widgets:OnUpdate(elapsed) end)
  ZGV:AddMessageHandler("SKIN_UPDATED",function() Widgets:ApplySkin(); Widgets:ApplyLayout() end)
end

-- Source widget payloads use this mixin directly.  Keep it available for
-- compatible WotLK widgets registered by content packages.
ZGV_Widget_Object_Mixin=ZGV_Widget_Object_Mixin or {}
function ZGV_Widget_Object_Mixin:Enable() return Widgets:EnableWidget(self) end
function ZGV_Widget_Object_Mixin:Disable() return Widgets:DisableWidget(self) end
function ZGV_Widget_Object_Mixin:Place() return Widgets:Place(self,self.row or 0,self.column or 0) end
function ZGV_Widget_Object_Mixin:Fits(row,column) return Widgets:Fits(self,row,column) end
function ZGV_Widget_Object_Mixin:Resize() return Widgets:Resize(self) end
function ZGV_Widget_Object_Mixin:SetInteractive() end
function ZGV_Widget_Object_Mixin:WarnOn() end
function ZGV_Widget_Object_Mixin:WarnOff() end
function ZGV_Widget_Object_Mixin:TogglePinned() return Widgets:TogglePinned(self) end
function ZGV_Widget_Object_Mixin:ShowPopup() if self.popup then self.popup:Show() end end
function ZGV_Widget_Object_Mixin:HidePopup() if self.popup then self.popup:Hide() end end
function ZGV_Widget_Object_Mixin:TogglePopup() if self.popup then if self.popup:IsShown() then self.popup:Hide() else self.popup:Show() end end end
