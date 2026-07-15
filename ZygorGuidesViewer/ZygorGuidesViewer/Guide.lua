-- Classic Guide prototype compatibility for the 3.3.5a catalog/runtime.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" or type(ZGV.Guide)~="table" then return end

local Guide,Runtime=ZGV.Guide,ZGV.Runtime
local floor,max,min=math.floor,math.max,math.min
local modernNew=Guide.New

local function header(guide) guide.headerdata=guide.headerdata or guide.header or {}; return guide.headerdata end
local function condition(guide,key,default)
  local value=header(guide)["condition_"..key]
  if value==nil then return default end
  if type(value)=="function" then local ok,result=pcall(value); return ok and result or false end
  if type(value)=="boolean" then return value end
  local result=ZGV.Conditions:Evaluate(tostring(value),guide)
  return result and true or false
end

function Guide:SyncLegacyFields()
  self.headerdata=self.headerdata or self.header or {}
  self.rawdata=self.rawdata or self.raw
  self.title_short=self.title_short or self.name or (self.title and self.title:match("([^\\]+)$")) or self.title
  self.guidepath=self.guidepath or self.path or ""
  self.type=self.type or (self.category and self.category:upper():gsub("[^%w]","")) or "MISC"
  self.startlevel=self.startlevel or tonumber(self.headerdata.startlevel or self.headerdata.startLevel)
  self.endlevel=self.endlevel or tonumber(self.headerdata.endlevel or self.headerdata.endLevel)
  self.next=self.next or self.headerdata.next
  return self
end

function Guide:New(title,headerData,data)
  local guide=modernNew(self,title,headerData,data)
  return guide:SyncLegacyFields()
end

function Guide:If_Complete_achieveid()
  local values=header(self).achieveid or header(self).achievement
  if type(values)~="table" then values={values} end
  if not values[1] then return false,false end
  for _,id in ipairs(values) do local _,_,_,done=GetAchievementInfo(tonumber(id)); if not done then return false,true end end
  return true,true
end
function Guide:If_Complete_mounts()
  -- Mount journal APIs are absent in the 3.3.5 client.  WotLK guide packs
  -- do not use this completion mode, so return "not knowable" rather than
  -- falsely marking a guide complete.
  return false,false
end
function Guide:If_Complete_pets() return false,false end

function Guide:DoCond(which,...)
  self:SyncLegacyFields()
  if which=="valid" or which=="visible" then return condition(self,"visible",true) end
  if which=="suggested" then
    local explicit=header(self).condition_suggested
    if explicit~=nil then return condition(self,"suggested",false) end
    if self.type=="LEVELING" and self.startlevel then
      local level=ZGV:GetPlayerPreciseLevel(); return level>=self.startlevel and level<(self.endlevel or 999)
    end
    return false
  end
  if which=="outleveled" then
    if self.endlevel and ZGV:GetPlayerPreciseLevel()>=self.endlevel then return true,"Level "..ZGV.FormatLevel(self.endlevel).." passed." end
    return false
  end
  if which=="end" then
    if self.endlevel then return ZGV:GetPlayerPreciseLevel()>=self.endlevel end
    if header(self).achieveid then return self:If_Complete_achieveid() end
    if header(self).mounts then return self:If_Complete_mounts() end
    if header(self).pet then return self:If_Complete_pets() end
    return condition(self,"end",false)
  end
  return condition(self,which,false)
end

function Guide:GetStatus(detailed)
  self:SyncLegacyFields()
  if not self:DoCond("valid") then return "INVALID" end
  local completion=self:GetCompletion()
  if type(completion)=="number" and completion>=1 then return "COMPLETE",detailed and completion or nil end
  if self:DoCond("outleveled") then return "OUTLEVELED",detailed and completion or nil end
  if self:DoCond("end") then return "COMPLETE",detailed and completion or nil end
  if self:DoCond("suggested") then return "SUGGESTED",detailed and completion or nil end
  return "VALID",detailed and completion or nil
end

function Guide:GetQuests()
  local quests,orQuests={},{ }
  for stepIndex,step in ipairs(self.steps or {}) do
    if Runtime:IsStepApplicable(step) then
      for _,goal in ipairs(step.goals or {}) do
        if goal:IsVisible() and goal.questID then
          quests[tonumber(goal.questID)]=stepIndex
          if goal.orGoal then orQuests[tonumber(goal.questID)]=stepIndex end
        end
      end
    end
  end
  return quests,orQuests
end

function Guide:GetCompletion(mode)
  self:SyncLegacyFields()
  mode=mode or self.completionmode
  if not mode then
    mode=(self.type=="LEVELING" or self.type=="LOREMASTER" or self.type=="DAILIES") and "quests" or "steps"
    if header(self).achieveid then mode="achievement" elseif header(self).mounts then mode="mounts" elseif header(self).pet then mode="battlepet" end
    self.completionmode=mode
  end
  if mode=="none" then return "none" end
  if mode=="level" then
    if not self.startlevel or not self.endlevel then return 0,0,1 end
    local progress=self.startlevel==self.endlevel and (ZGV:GetPlayerPreciseLevel()>self.startlevel and 1 or 0) or min(1,max(0,(ZGV:GetPlayerPreciseLevel()-self.startlevel)/(self.endlevel-self.startlevel)))
    return progress,progress*(self.endlevel-self.startlevel),self.endlevel-self.startlevel
  end
  if mode=="quests" then
    local quests,orQuests=self:GetQuests(); local completed,total=0,0
    for id in pairs(quests) do
      total=total+1
      local done=ZGV.Compat.Quest:IsCompleted(id)
      if done then completed=completed+1 end
    end
    return total>0 and completed/total or 0,completed,total
  end
  if mode=="achievement" then
    local values=header(self).achieveid; if type(values)~="table" then values={values} end
    local done,total=0,0
    for _,id in ipairs(values) do local _,_,_,complete=GetAchievementInfo(tonumber(id)); total=total+1; if complete then done=done+1 end end
    return total>0 and done/total or 0,done,total
  end
  if mode=="mounts" then local done=self:If_Complete_mounts(); return done and 1 or 0,done and 1 or 0,1 end
  if mode=="battlepet" then local done=self:If_Complete_pets(); return done and 1 or 0,done and 1 or 0,1 end
  local done,total=0,0
  for index,step in ipairs(self.steps or {}) do
    if Runtime:IsStepApplicable(step) then
      local state=Runtime:GetStepState(step,index)
      if not state.skipped and state.required>0 then total=total+1; if state.complete then done=done+1 end end
    end
  end
  return total>0 and done/total or 0,done,total
end

function Guide:GetCompletionText(mode)
  local completion,done,total=self:GetCompletion(mode)
  if completion=="none" then return "-","This guide does not complete." end
  if type(completion)~="number" then return "?","Completion unavailable" end
  local label=(mode or self.completionmode)=="quests" and "Quests" or "Steps"
  return string.format("%d%%",floor(completion*100+.5)),string.format("%s completed: %d/%d",label,done or 0,total or 0)
end

function Guide:Load(step) return Runtime:SelectGuide(self,step) end
function Guide:Unload() return true end
function Guide:ParseHeader() self.header=ZGV.Parser:ParseHeader(self.header or self.raw); self.headerdata=self.header; return self.header end
function Guide:Parse(fully) local parsed,error=ZGV.Parser:ParseGuide(self); if not parsed then self.parse_failed=true; return nil,error end; return true end
function Guide:GetFutureGuides()
  local results,guide={},self
  while guide and guide.next do guide=ZGV.Catalog:Get(guide.next); if not guide or results[guide.title] then break end; results[guide.title]=true end
  return results
end
function Guide:HasProfession() return self.type=="PROFESSIONS" end
function Guide:AdvertiseWithPopup()
  if ZGV.Notifications then ZGV.Notifications:Notify("Next guide available",self.title_short or self.title,"guide") end
end
function Guide:LegionPopup(title,message) if ZGV.Notifications then ZGV.Notifications:Notify(title,message,"guide") end end
function Guide:GetFirstValidStep(start)
  for index=tonumber(start) or 1,#(self.steps or {}) do if Runtime:IsStepApplicable(self.steps[index]) then return self.steps[index],index end end
end
function Guide:GetCurStep() if self==Runtime.currentGuide then return self.steps[Runtime.currentStep] end end
function Guide:GetStep(value)
  local index=type(value)=="string" and (self.labels and self.labels[value]) or tonumber(value)
  return self.steps and self.steps[index or 1]
end
function Guide:tostring() return self.title end
function Guide:GetParentFolder() return self.path or self.guidepath or "" end
function Guide:ToggleFavourite() return Runtime:ToggleFavorite(self) end
function Guide:IsFavourite() return ZGV.db and ZGV.db.profile.favorites[self.id] and true or false end

ZGV.GuideProto=Guide
ZGV.GuideFuncs=ZGV.GuideFuncs or {}
function ZGV.GuideFuncs:IsValid(guide,step) return guide and guide:DoCond("valid") and (not step or Runtime:IsStepApplicable(step)) end
function ZGV.GuideFuncs:IsDungeon() return Runtime.currentGuide and Runtime.currentGuide.type=="DUNGEONS" or false end
function ZGV.GuideFuncs:ToggleViewer() if ZGV.UI then ZGV.UI:Toggle() end end
function ZGV.GuideFuncs:SuggestDungeonGuide(guide) if guide then return guide:AdvertiseWithPopup() end end
function ZGV.GuideFuncs:AskReload() if type(ReloadUI)=="function" then ReloadUI() end end
function ZGV.GuideFuncs:CreateDungeonPopup(object,title)
  if object and object.AdvertiseWithPopup then object:AdvertiseWithPopup() end
  return object
end
function ZGV.GuideFuncs:SuggestPreviousGuide(guide) if guide then return guide:AdvertiseWithPopup() end end
function ZGV.GuideFuncs:CheckIfEvent() return false end
function ZGV.GuideFuncs:MonkQuest() return false end
function ZGV.GuideFuncs:LearnMountGuideSuggestion() return false end
function ZGV.GuideFuncs:OnEvent(event,...) if event=="PLAYER_LEVEL_UP" and Runtime.currentGuide then ZGV:Fire("ZGV_GUIDE_LEVEL_CHANGED",Runtime.currentGuide,...) end end
function ZGV.GuideFuncs:RegisterEvents()
  if self.eventsRegistered then return end
  self.eventsRegistered=true
  ZGV:RegisterEvent("PLAYER_LEVEL_UP",self,"OnEvent")
end
function ZGV.GuideFuncs:IsGuideBanned(title)
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.bannedguides and ZGV.db.profile.bannedguides[title] and true or false
end
ZGV:RegisterCallback("ZGV_STARTED",function() ZGV.GuideFuncs:RegisterEvents() end)
