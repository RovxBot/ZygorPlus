-- Public viewer facade.  The Anniversary monolith is represented in this
-- port by Core, Runtime, ModernViewer, and GuideMenu; this file restores its
-- public methods so Classic modules and user snippets see one coherent ZGV.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Viewer=ZGV.ViewerCompat or {}
ZGV.ViewerCompat=Viewer
ZGV:RegisterModule("ViewerCompat",Viewer)

local function runtime() return ZGV.Runtime end
local function ui() return ZGV.UI end

function Viewer:Refresh(full)
  if ui() and ui().Refresh then ui():Refresh() end
  if ZGV.GuideMenu and ZGV.GuideMenu.Refresh then ZGV.GuideMenu:Refresh() end
  if full and ZGV.Navigation then ZGV.Navigation:UpdateMapPin() end
end

function ZGV:OnInitialize() return true end
function ZGV:OnEnable() return self:Startup() end
function ZGV:OnDisable()
  if ui() and ui().frame then ui().frame:Hide() end
  if ZGV.GuideMenu and ZGV.GuideMenu.frame then ZGV.GuideMenu.frame:Hide() end
end

function ZGV:GetGuideByTitle(title)
  return self.Catalog and self.Catalog:Get(title) or nil
end
function ZGV:GetFocusedStep()
  local current=runtime()
  return current and current.currentGuide and current.currentGuide.steps[current.currentStep]
end
function ZGV:GetPreviousValidStep()
  local current=runtime()
  return current and current.currentStep and current.currentStep>1 and current.currentGuide.steps[current.currentStep-1] or nil
end
function ZGV:PreviousStep() return runtime() and runtime():PreviousStep() or false end
function ZGV:NextGuide() return runtime() and runtime():NextStep(true) or false end
function ZGV:SkipStep(_,_,forceFocus)
  local ok=runtime() and runtime():NextStep(true) or false
  if ok and forceFocus then self:FocusStep(runtime().currentStep) end
  return ok
end
function ZGV:ReloadStep() return runtime() and runtime():SetStep(runtime().currentStep,true) or false end
function ZGV:FocusStepQuiet(number) return self:FocusStep(number) end
function ZGV:FocusStepUnquiet() return true end

function ZGV:FindSuggestedGuides()
  local guide=runtime() and runtime():ChooseSuggestedGuide()
  return guide and {guide} or {}
end
function ZGV:FindSuggestedGuidesAsync(_,done)
  local guides=self:FindSuggestedGuides(); if type(done)=="function" then done(guides) end; return guides
end
function ZGV:FindSuggestedGuidesAsync2(_,done) return self:FindSuggestedGuidesAsync(nil,done) end
function ZGV:ForeachInGuidesAsync(guides,callback,progress,done)
  for index,guide in ipairs(guides or {}) do if callback then callback(guide,index) end if progress then progress(index,#guides) end end
  if done then done() end
end
function ZGV:ForeachInGuidesAsync2(guides,callback,progress,done) return self:ForeachInGuidesAsync(guides,callback,progress,done) end

function ZGV:ClearRecentActivities()
  if self.db and self.db.profile then self.db.profile.history={} end
  if ZGV.GuideMenu then ZGV.GuideMenu:Refresh() end
end
function ZGV:GetMentionedFollowups(questID)
  local results={}
  for _,guide in ipairs((self.Catalog and self.Catalog.sorted) or {}) do
    local text=tostring(guide.raw or "")
    if text:find("|q%s*"..tostring(questID).."[^%d]",1) then results[#results+1]=guide end
  end
  return results
end
function ZGV:CacheMentionedFollowups() return true end
function ZGV:TryToCompleteStep(force)
  if runtime() then runtime():Tick(); return force and runtime():NextStep(false) or true end
  return false
end

function ZGV:TrackQuest(questID)
  if ZGV.QuestTracking and ZGV.QuestTracking.TrackQuest then return ZGV.QuestTracking:TrackQuest(questID) end
  return false
end
function ZGV:PointToQuest(_,questID)
  if not ZGV.QuestDB or not runtime() then return false end
  local found,matches=ZGV.QuestDB:GetGuidesForQuest(questID)
  if not found then return false end
  for title,step in pairs(matches) do return runtime():SelectGuide(title,step) end
  return false
end

function ZGV:UpdateFrame(full) Viewer:Refresh(full) end
function ZGV:UpdateFrame_Schedule() Viewer:Refresh(false) end
function ZGV:DoUpdateFrame(full) Viewer:Refresh(full) end
function ZGV:UpdateFrameStepSkipping() Viewer:Refresh(false) end
function ZGV:GoalProgress(goal)
  local current=runtime()
  if not current or not goal then return nil end
  return current:GetGoalProgress(goal,goal.parentStep and goal.parentStep.num,goal.num)
end

function ZGV:SetFrameScale(scale)
  scale=math.max(.5,math.min(2,tonumber(scale) or 1))
  if self.db and self.db.profile then self.db.profile.viewer.scale=scale end
  if ui() and ui().frame then ui().frame:SetScale(scale) end
end
function ZGV:ReanchorFrame()
  local frame=ui() and ui().frame; local settings=self.db and self.db.profile.viewer
  if frame and settings then frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",settings.x or 0,settings.y or 0) end
end
function ZGV:AlignFrame() return self:ReanchorFrame() end
function ZGV:ResizeFrame()
  local frame=ui() and ui().frame; local settings=self.db and self.db.profile.viewer
  if frame and settings then frame:SetSize(settings.width or 440,settings.height or 500) end
end
function ZGV:ApplySkin()
  if ui() and ui().ApplyModernSkin then ui():ApplyModernSkin() end
  if ZGV.GuideMenu and ZGV.GuideMenu.ApplySkin then ZGV.GuideMenu:ApplySkin() end
  if ZGV.GuideWidget and ZGV.GuideWidget.ApplySkin then ZGV.GuideWidget:ApplySkin() end
end
function ZGV:UpdateLocking()
  local frame=ui() and ui().frame
  if frame then frame:SetMovable(not (self.db and self.db.profile.viewer.locked)) end
end
function ZGV:SetDisplayMode(mode)
  if ui() and ui().SetMode then ui():SetMode(mode=="guide" and "guide" or "browse") end
end
function ZGV:IsVisible() return ui() and ui().frame and ui().frame:IsShown() or false end
function ZGV:SetVisible(_,onoff)
  if not ui() then return end
  if onoff==false then if ui().frame then ui().frame:Hide() end else ui():ShowViewer() end
end
function ZGV:ToggleFrame() if ui() then ui():Toggle() end end

function ZGV:GetGuideFolderInfo(folder)
  local prefix=tostring(folder or "")
  local count=0
  for _,guide in ipairs((self.Catalog and self.Catalog.sorted) or {}) do if tostring(guide.path or ""):find(prefix,1,true)==1 then count=count+1 end end
  return {name=prefix,count=count,fullpath=prefix}
end
function ZGV:RaceClassMatchList(list)
  for _,entry in ipairs(list or {}) do if self:RaceClassMatch(entry) then return true end end
  return false
end
function ZGV:MatchProfs() return true end
function ZGV:FindEvent(name)
  for _,guide in ipairs((self.Catalog and self.Catalog.sorted) or {}) do if tostring(guide.title):lower():find(tostring(name or ""):lower(),1,true) then return guide end end
end
function ZGV:Frame_OnShow() if self.db and self.db.profile then self.db.profile.viewer.shown=true end end
function ZGV:Frame_OnHide() if self.db and self.db.profile then self.db.profile.viewer.shown=false end end
function ZGV:HighlightCurrentStep() Viewer:Refresh(false) end
function ZGV:UpdateMainFrame() Viewer:Refresh(false) end
function ZGV:InitializeDropDown() return ZGV.GuideMenu end
function ZGV:SectionChange(value) if ZGV.GuideMenu then return ZGV.GuideMenu:Show(value) end end
