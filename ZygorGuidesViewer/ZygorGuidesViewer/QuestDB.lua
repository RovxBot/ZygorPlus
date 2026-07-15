-- Guide/quest index rebuilt directly from registered guide DSL.  It replaces
-- the retail cache tables with a deterministic WotLK index that covers every
-- bundled guide and remains correct for later-loaded content packages.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local QuestDB=ZGV:RegisterModule("QuestDB",{GuideForQuest={},index={},ready=false})
ZGV.QuestDB=QuestDB
QuestDB.VALID_NOW=1; QuestDB.VALID_FUTURE=2; QuestDB.VALID_NEVER=-1

local actions={accept=true,turnin=true,havequest=true,nothavequest=true,notcompleted=true}
local function complete(id)
  local service=ZGV.Compat and ZGV.Compat.Quest
  return service and service:IsCompleted(id) or false
end
function QuestDB:Init()
  self.GuideForQuest={}; self.index={}
  for _,guide in ipairs((ZGV.Catalog and ZGV.Catalog.guides) or {}) do
    for line in tostring(guide.raw or ""):gmatch("[^\r\n]+") do
      local foundAction=line:match("^%s*([%a]+)")
      if not actions[foundAction] then foundAction=nil end
      local id=foundAction and tonumber(line:match("##(%d+)"))
      if id then
        self.index[id]=self.index[id] or {accept={},turnin={}}
        local list=self.index[id][foundAction=="turnin" and "turnin" or "accept"]
        list[#list+1]=guide
        self.GuideForQuest[id]=self.GuideForQuest[id] or {}; self.GuideForQuest[id][#self.GuideForQuest[id]+1]=guide.title
      end
    end
  end
  self.ready=true; return self.index
end
function QuestDB:GetGuidesForQuest(id)
  id=tonumber(id); if not id then return false,{} end
  if not self.ready then self:Init() end
  local pack=self.index[id]; if not pack then return false,{} end
  local kind=complete(id) and "turnin" or "accept"; local result={}
  for _,guide in ipairs(pack[kind] or {}) do
    local parsed=ZGV.Parser and ZGV.Parser:ParseGuide(guide)
    if parsed then
      for stepIndex,step in ipairs(parsed.steps or {}) do
        for _,goal in ipairs(step.goals or {}) do
          if tonumber(goal.questID)==id and (goal.action==kind or (kind=="accept" and actions[goal.action])) then result[guide.title]=stepIndex break end
        end
        if result[guide.title] then break end
      end
    end
  end
  return next(result)~=nil,result
end
function QuestDB:GetQuestName(id)
  local entry=ZGV.Compat and ZGV.Compat.Quest and ZGV.Compat.Quest:FindInLog(tonumber(id))
  return entry and entry.title or (ZGV.LQ and ZGV.LQ[tonumber(id)]) or tostring(id or "Unknown quest")
end
function QuestDB:CreateButton()
  if self.SearchIcon or not QuestLogFrame then return self.SearchIcon end
  local button=CreateFrame("Button","ZygorQuestFinder",QuestLogFrame)
  button:SetWidth(22); button:SetHeight(22); button:SetPoint("TOPRIGHT",QuestLogFrame,"TOPRIGHT",-42,-84)
  local texture=button:CreateTexture(nil,"ARTWORK"); texture:SetAllPoints(button); texture:SetTexture(ZGV.SKINDIR.."findinzygor"); button.texture=texture
  button:SetScript("OnClick",function() QuestDB:SuggestGuidesForQuest(QuestDB.questID) end)
  button:SetScript("OnEnter",function(self) GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:SetText("Find guides for "..tostring(QuestDB.questName or "this quest")); GameTooltip:Show() end)
  button:SetScript("OnLeave",function() GameTooltip:Hide() end); button:Hide(); self.SearchIcon=button; return button
end
function QuestDB:SetQuestForButton(index)
  if not self:CreateButton() or type(GetQuestLogTitle)~="function" then return end
  local title,_,_,_,_,_,_,_,id=GetQuestLogTitle(tonumber(index) or 0); id=tonumber(id)
  local found=self:GetGuidesForQuest(id)
  self.questID,self.questName=id,title
  if found then self.SearchIcon:Show() else self.SearchIcon:Hide() end
end
function QuestDB:MaybeShowButton()
  if type(GetQuestLogSelection)=="function" then self:SetQuestForButton(GetQuestLogSelection()) end
end
function QuestDB:SuggestGuidesForQuest(id)
  local found,results=self:GetGuidesForQuest(id)
  if not found then return false end
  if ZGV.GuideMenu and ZGV.GuideMenu.SearchQuest then ZGV.GuideMenu:SearchQuest(id); ZGV.GuideMenu:Show() end
  return true,results
end
function QuestDB:FocusNextStepForQuest(id)
  local runtime=ZGV.Runtime; local guide=runtime and runtime.currentGuide; id=tonumber(id)
  if not guide then return false end
  for stepIndex,step in ipairs(guide.steps or {}) do for _,goal in ipairs(step.goals or {}) do
    if tonumber(goal.questID)==id then return runtime:SetStep(stepIndex,true) end
  end end
  return false
end
function QuestDB:MaybeSkipThisGoal(goal) return goal and complete(goal.questID) or false end
function QuestDB:MaybeStopOnThisStep(step)
  for _,goal in ipairs(step and step.goals or {}) do if goal.questID and not complete(goal.questID) then return true end end
  return false
end
function QuestDB:GetQuestsByTitle(title)
  local result={}; for _,entry in ipairs((ZGV.Compat.Quest:GetLog()).entries or {}) do if not entry.isHeader and entry.title==title then result[#result+1]=entry end end
  return result
end
function QuestDB:IsQuestPossible(id)
  id=tonumber(id); if not id then return self.VALID_NEVER end
  if complete(id) then return self.VALID_NOW end
  return (ZGV.Compat.Quest:IsOnQuest(id) and self.VALID_NOW) or self.VALID_FUTURE
end
function QuestDB:CacheQuestNames() return ZGV.Compat.Quest:RefreshLog() end
function QuestDB:CacheQuestNameResult() return self:CacheQuestNames() end
function QuestDB:SortGuides(guides)
  table.sort(guides,function(left,right) return tostring(left.title or left)<tostring(right.title or right) end); return guides
end
function QuestDB:ExplainStep(step) return step and (step.GetDebugDump and step:GetDebugDump() or step.title) or "No step" end
function QuestDB:ShowGuideHelper() if ZGV.GuideMenu then ZGV.GuideMenu:Show("SUGGESTED") end end
function QuestDB:OnStartup() self:Init(); self:CreateButton(); self:MaybeShowButton() end
function QuestDB:OnEvent() self:MaybeShowButton() end
ZGV:RegisterEvent("QUEST_LOG_UPDATE",QuestDB,"OnEvent")
ZGV:RegisterCallback("ZGV_CATALOG_FINALIZED",QuestDB,"Init")
