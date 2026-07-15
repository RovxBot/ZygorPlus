-- Standalone PlayerModel viewer for guide NPCs, objects and header models.
-- It is intentionally independent of the retail model APIs and works on the
-- native 3.3.5a PlayerModel surface.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local unpack=unpack or table.unpack

local Viewer=ZGV:RegisterModule("CreatureViewer",{models={},currentModel=1})
ZGV.CV=Viewer
local fallbackModel="Character\\Human\\Male\\HumanMale.m2"

local function options()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.creatureViewer
end

local function modelName(goal)
  return goal.modelName or goal.modelname or goal.target or goal.npcName or goal.text or "Guide target"
end

local function appendModel(models,model)
  if not model then return end
  local key=model.model or model.displayID or model.creature
  if not key then return end
  for _,existing in ipairs(models) do
    if (existing.model or existing.displayID or existing.creature)==key then return end
  end
  models[#models+1]=model
end

function Viewer:CollectModels()
  local runtime=ZGV.Runtime
  local guide=runtime and runtime.currentGuide
  local step=guide and guide.steps[runtime.currentStep]
  local models={}
  if guide then
    local header=guide.header or guide.meta or {}
    local values=type(header.model)=="table" and header.model or (header.model and {header.model} or {})
    for _,displayID in ipairs(values) do appendModel(models,{displayID=tonumber(displayID),name=guide.name or guide.title}) end
  end
  if not step then return models end
  for _,entry in ipairs(runtime:GetDisplayGoals(runtime.currentStep)) do
    local goal=entry.goal
    if not goal.noModels and not goal.nomodels then
      if goal.model then
        local objectModel=type(goal.model)=="number" and ZGV.ObjectModels and ZGV.ObjectModels[goal.model]
        appendModel(models,objectModel and {model=objectModel,name=modelName(goal)} or {model=type(goal.model)=="string" and goal.model or nil,displayID=type(goal.model)=="number" and goal.model or nil,name=modelName(goal)})
      elseif goal.modelDisplay or goal.displayinfo then appendModel(models,{displayID=goal.modelDisplay or goal.displayinfo,name=modelName(goal)})
      elseif goal.modelNPC or goal.modelnpc then appendModel(models,{creature=goal.modelNPC or goal.modelnpc,name=modelName(goal)})
      elseif goal.npcID then appendModel(models,{creature=goal.npcID,name=modelName(goal)})
      elseif goal.action=="click" and goal.objectID then appendModel(models,{creature=goal.objectID,name=modelName(goal)}) end
      for _,mob in ipairs(goal.mobs or {}) do if mob.id then appendModel(models,{creature=mob.id,name=mob.name}) end end
    end
  end
  return models
end

function Viewer:Create()
  if self.frame then return self.frame end
  local config=options() or {}
  local frame=CreateFrame("Frame","ZygorGuidesViewerCreatureViewer",UIParent)
  frame:SetWidth(config.width or 170); frame:SetHeight(config.height or 220)
  frame:SetScale(config.scale or 1); frame:SetPoint("CENTER",UIParent,"CENTER",config.x or 220,config.y or 40)
  frame:SetMovable(true); frame:SetResizable(true); frame:SetMinResize(120,160); frame:EnableMouse(true); frame:SetClampedToScreen(true)
  frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  frame:SetBackdropColor(.04,.04,.04,.95); frame:SetBackdropBorderColor(.25,.25,.25,1)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self) if not (options() or {}).locked then self:StartMoving() end end)
  frame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
    local x,y=self:GetCenter(); local px,py=UIParent:GetCenter(); local saved=options()
    if saved and x and px then saved.x,saved.y=math.floor(x-px+.5),math.floor(y-py+.5) end
  end)
  local model=CreateFrame("PlayerModel",nil,frame)
  model:SetPoint("TOPLEFT",frame,"TOPLEFT",4,-4); model:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-4,28)
  model:SetScript("OnUpdate",function(self,elapsed)
    local saved=options()
    if saved and saved.rotation and self.current then
      self.facing=(self.facing or 0)+elapsed*.35
      self:SetFacing(self.facing)
    end
  end)
  frame.model=model
  frame:EnableMouseWheel(true)
  frame:SetScript("OnMouseWheel",function(_,delta)
    local saved=options(); if not saved then return end
    saved.zoom=math.max(.35,math.min(2.5,(tonumber(saved.zoom) or 1)+(delta>0 and .1 or -.1)))
    if model.SetModelScale then model:SetModelScale(saved.zoom) end
  end)
  local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
  title:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",8,7); title:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-8,7); title:SetJustifyH("CENTER")
  frame.title=title
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
  close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,2); close:SetScript("OnClick",function() local saved=options(); if saved then saved.enabled=false end Viewer:Hide() end)
  local previous=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  previous:SetSize(20,20); previous:SetPoint("LEFT",frame,"BOTTOMLEFT",5,4); previous:SetText("<"); previous:SetScript("OnClick",function() Viewer:CycleCreature(-1) end)
  local nextButton=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  nextButton:SetSize(20,20); nextButton:SetPoint("RIGHT",frame,"BOTTOMRIGHT",-5,4); nextButton:SetText(">"); nextButton:SetScript("OnClick",function() Viewer:CycleCreature(1) end)
  local sizer=CreateFrame("Button",nil,frame)
  sizer:SetSize(18,18); sizer:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-1,1); sizer:RegisterForDrag("LeftButton")
  sizer:SetScript("OnDragStart",function() if not (options() or {}).locked then frame:StartSizing("BOTTOMRIGHT") end end)
  sizer:SetScript("OnDragStop",function()
    frame:StopMovingOrSizing(); local saved=options()
    if saved then saved.width,saved.height=frame:GetWidth(),frame:GetHeight() end
  end)
  self.frame=frame
  self:ApplySkin()
  frame:Hide()
  return frame
end

function Viewer:CreateFrame() return self:Create() end

function Viewer:ApplySkin()
  if not self.frame then return end
  local backdrop=ZGV.GetSkinData and ZGV:GetSkinData("CreatureBackdrop")
  local colour=ZGV.GetSkinData and ZGV:GetSkinData("CreatureBackdropColor") or {.04,.04,.04,.95}
  local border=ZGV.GetSkinData and ZGV:GetSkinData("CreatureBackdropBorderColor") or {.25,.25,.25,1}
  if backdrop then self.frame:SetBackdrop(backdrop) end
  self.frame:SetBackdropColor(unpack(colour)); self.frame:SetBackdropBorderColor(unpack(border))
end
Viewer.UpdateSkin=Viewer.ApplySkin

function Viewer:SetMaster()
  local config=options()
  if not config or not config.locked or not self.frame then return end
  local master=ZGV.UI and ZGV.UI.frame
  if not master then return end
  self.frame:ClearAllPoints()
  self.frame:SetPoint("TOPLEFT",master,"TOPRIGHT",8,0)
end

function Viewer:AlignFrame()
  local config=options()
  if not config then return end
  config.locked=true
  self:Create()
  self:SetMaster()
end

function Viewer:ShowModels(models)
  local config=options()
  if not config or not config.enabled or type(models)~="table" or #models==0 then return self:Hide() end
  self:Create()
  self.models=models; self.currentModel=1; self.frame:Show()
  self:Update()
end

function Viewer:ShowCreature(id,name) self:ShowModels({{creature=tonumber(id),name=name}}) end

function Viewer:Hide()
  if self.frame then self.frame:Hide(); self.frame.model:ClearModel(); self.frame.model.current=nil end
  self.models={}; self.currentModel=1
end

function Viewer:CycleCreature(delta)
  if #self.models==0 then return end
  self.currentModel=((self.currentModel-1+(delta or 1))%#self.models)+1
  self:Update()
end

function Viewer:Update()
  local frame=self.frame
  local data=self.models[self.currentModel]
  if not frame or not data then return self:Hide() end
  local model=frame.model
  model:ClearModel(); model.current=data; model.facing=(data.facing or 0)/57.2958
  local ok=false
  if type(data.model)=="string" and data.model~="" then ok=pcall(model.SetModel,model,data.model)
  elseif data.displayID and model.SetDisplayInfo then ok=pcall(model.SetDisplayInfo,model,data.displayID)
  elseif data.creature and model.SetCreature then ok=pcall(model.SetCreature,model,data.creature) end
  if not ok and model.RefreshCamera then pcall(model.RefreshCamera,model) end
  if not ok and model.SetModel then
    ok=pcall(model.SetModel,model,data.fallbackModel or fallbackModel)
    data.usedFallback=ok and true or false
  else data.usedFallback=false end
  if model.SetModelScale then model:SetModelScale(math.max(.01,(tonumber(data.scale) or 1)*(tonumber(options() and options().zoom) or 1))) end
  if model.SetPosition then model:SetPosition(data.cx or 0,data.cy or 0,(data.cz or 0)-.1) end
  if model.SetCamera and data.camera then pcall(model.SetCamera,model,data.camera) elseif model.RefreshCamera then pcall(model.RefreshCamera,model) end
  frame.title:SetText(tostring(data.name or "Guide target")..(data.usedFallback and " (preview)" or "")..(#self.models>1 and ("  "..self.currentModel.."/"..#self.models) or ""))
end

function Viewer:DumpModelSettings()
  local data=self.models[self.currentModel]
  if not data then return nil end
  local message=string.format("model=%s display=%s creature=%s",tostring(data.model),tostring(data.displayID),tostring(data.creature))
  ZGV:Print(message)
  return message
end

function Viewer:Test()
  self:ShowModels({
    {creature=6,name="Kobold Vermin"},
    {creature=38,name="Defias Thug"},
  })
end

function Viewer:TryToDisplayCreature(force)
  local config=options()
  if not config or not config.enabled then return self:Hide() end
  local models=self:CollectModels()
  if #models>0 then self:ShowModels(models) else self:Hide() end
end

function ZGV:TryToDisplayCreature(force) return Viewer:TryToDisplayCreature(force) end

function Viewer:OnStartup()
  self:Create()
  self:SetMaster()
  if ZGV.Compat and ZGV.Compat.Timer then
    self.slideshow=ZGV.Compat.Timer:NewTicker(5,function()
      if (options() or {}).slideshow and #Viewer.models>1 then Viewer:CycleCreature(1) end
    end)
  end
end

ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",Viewer,"TryToDisplayCreature")
ZGV:RegisterCallback("ZGV_STEP_CHANGED",Viewer,"TryToDisplayCreature")
ZGV:RegisterCallback("ZGV_GOAL_UPDATED",Viewer,"TryToDisplayCreature")
ZGV:AddMessageHandler("SKIN_UPDATED",function() Viewer:ApplySkin() end)
