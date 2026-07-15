-- Compatibility implementation of the Classic Goal prototype on top of the
-- 3.3.5a runtime.  It intentionally keeps both the older lower-case fields
-- (questid/itemid/etc.) and the parser's camel-case fields interoperable.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" or type(ZGV.Goal)~="table" then return end

local Goal,Runtime=ZGV.Goal,ZGV.Runtime
local unpack=unpack or table.unpack
local standingNames={[1]="Hated",[2]="Hostile",[3]="Unfriendly",[4]="Neutral",[5]="Friendly",[6]="Honored",[7]="Revered",[8]="Exalted"}

local function alias(goal,modern,legacy)
  if goal[modern]==nil and goal[legacy]~=nil then goal[modern]=goal[legacy] end
  if goal[legacy]==nil and goal[modern]~=nil then goal[legacy]=goal[modern] end
end

function Goal:SyncLegacyFields()
  alias(self,"questID","questid"); alias(self,"itemID","itemid"); alias(self,"targetID","targetid")
  alias(self,"npcID","npcid"); alias(self,"spellID","spellid"); alias(self,"achievementID","achieveid")
  alias(self,"objective","objnum"); alias(self,"repFaction","rep"); alias(self,"repStanding","standing")
  alias(self,"forceNoComplete","force_nocomplete"); alias(self,"forceComplete","force_complete")
  alias(self,"loadGuide","loadguide"); alias(self,"loadGuideStep","loadguidestep")
  alias(self,"showInBrief","showinbrief"); alias(self,"noWaypoint","force_noway")
  if self.destination then
    self.map=self.map or self.destination.map; self.floor=self.floor or self.destination.floor
    self.x=self.x or self.destination.x; self.y=self.y or self.destination.y
  end
  return self
end

local oldNew=Goal.New
function Goal:New(data) local goal=oldNew(self,data); return goal:SyncLegacyFields() end

function Goal:GetStatus()
  self:SyncLegacyFields()
  local active=self.parentStep and self.parentStep.parentGuide==Runtime.currentGuide
  if not active then self.status="inactive"; return self.status end
  if not self:IsVisible() then self.status="hidden"; return self.status end
  if not self:IsCompleteable() then self.status="passive"; return self.status end
  local complete=self:IsComplete()
  self.status=complete and "complete" or "incomplete"
  return self.status
end

function Goal:UpdateStatus() return self:GetStatus() end

function Goal:IsValidRole()
  local wanted=self.groupRole or self.grouprole
  if not wanted or wanted=="" then return true end
  if type(UnitGroupRolesAssigned)~="function" then return true end
  return UnitGroupRolesAssigned("player")==wanted
end

function Goal:IsVisible()
  self:SyncLegacyFields()
  return not self.hidden and not self.wrong and self:IsValidRole() and Runtime:IsGoalApplicable(self)
end

function Goal:IsCompleteable()
  self:SyncLegacyFields()
  if self.forceNoComplete or self.force_nocomplete or self.future then return false end
  if self.mapTransition then return true end
  if self.questID or self.achievementID or self.expression then return true end
  -- In the Classic model these are companion instructions.  Their paired
  -- quest/condition goal controls the step unless the instruction itself is
  -- explicitly bound to a quest above.
  if self.action=="talk" or self.action=="gossip" then return false end
  return self.action~="text" and self.action~="label" and self.action~="info" and self.action~="image" and self.action~="webheader" and self.action~="webinfo"
end

function Goal:IsComplete()
  self:SyncLegacyFields()
  if not self.parentStep then return false,false,0,1,"unbound" end
  local complete,reason=Runtime:IsGoalComplete(self,self.parentStep.num,self.num)
  local progress=Runtime:GetGoalProgress(self,self.parentStep.num,self.num)
  local possible=reason~="not-applicable" and reason~="pending" and reason~="not-completable" and reason~="confirmation" or self:IsCompleteable()
  local current,required=progress and progress.current or (complete and 1 or 0),progress and progress.required or 1
  return complete and true or false,possible and true or false,current,required,reason
end

function Goal:CheckVisited()
  if not self.destination or not ZGV.Navigation then return false end
  local visited=ZGV.Navigation:IsArrived(self.destination)
  if visited and not self.was_visited then self:OnVisited() elseif not visited and self.was_visited then self:OnDevisited() end
  self.was_visited=visited
  return visited
end
function Goal:OnShow() self:CheckVisited() end
function Goal:OnHide() end
function Goal:RegisterEvents() end
function Goal:UnregisterEvents() end
function Goal:OnVisited() if self.force_sticky_saved then self:SaveStickyComplete() end end
function Goal:OnDevisited() end
function Goal:GetWaypoint() return self.destination end
function Goal:OnCompleted() if self.force_sticky_saved then self:SaveStickyComplete() end end
function Goal:OnUncompleted() end

function Goal:GetTooltip()
  self:SyncLegacyFields()
  local lines={self:GetText(false,false,true,true)}
  if self.destination then
    local map=tostring(self.destination.map or "")
    local x,y=tonumber(self.destination.x),tonumber(self.destination.y)
    lines[#lines+1]=x and string.format("Waypoint: %s (%.1f, %.1f)",map,x*100,y*100) or ("Waypoint: "..map)
  end
  for _,tip in ipairs(self.tips or {}) do lines[#lines+1]=tip end
  if self.grouprole or self.groupRole then lines[#lines+1]="Shift-click to share this tip to fellow players." end
  return table.concat(lines,"\n")
end

function Goal:IsPOIComplete() return self:IsComplete() end
function Goal:IsDynamic() return self.dynamicwaypoint and true or false end

function Goal:IsCompleteAs(goaltype)
  if not self.parentStep or not goaltype or goaltype==self.action then return self:IsComplete() end
  local original=self.action; self.action=goaltype
  local complete,reason=Runtime:IsGoalComplete(self,self.parentStep.num,self.num)
  self.action=original
  return complete,reason
end

function ZGV.GoalPopupImage(goal)
  if not goal then return end
  if ZGV.CreatureViewer and ZGV.CreatureViewer.ShowCreature then
    return ZGV.CreatureViewer:ShowCreature(goal.modelNPC or goal.npcID or goal.modelDisplay or goal.model)
  end
end

function ZGV.FindPetActionInfo(goal)
  if type(GetPetActionInfo)~="function" then return nil end
  local desired=goal and (goal.petaction or goal.petAction)
  if tonumber(desired) then
    local name,_,texture=GetPetActionInfo(tonumber(desired))
    if name then return tonumber(desired),name,texture end
    return nil
  end
  for index=1,12 do
    local name,_,texture=GetPetActionInfo(index)
    local wanted=tostring(desired or ""):lower()
    if wanted~="" and ((name and name:lower():find(wanted,1,true)) or (texture and tostring(texture):lower():find(wanted,1,true))) then return index,name,texture end
  end
end

function Goal:IsActionable()
  self:SyncLegacyFields()
  if self.itemID and (not self.itemuse or (ZGV.Conditions and ZGV.Conditions:ItemCount(self.itemID,true)>0)) then return true end
  if (self.castspellid or self.spellID) and type(IsUsableSpell)=="function" and IsUsableSpell(self.castspellid or self.spellID) then return true end
  if self.petaction and ZGV.FindPetActionInfo(self) then return true end
  return self.loadGuide~=nil or self.nextGuide~=nil or self.nextJump~=nil or self.nextLabel~=nil or self.script~=nil or self.macro~=nil or self:IsCompleteable()
end

function Goal:IsFitting()
  if self.wrong then return false end
  if not self.requirement then return true end
  self.wrong=not ZGV:RaceClassMatch(self.requirement)
  return not self.wrong
end
function Goal:NeedsTranslation() return false end
function Goal:AutoTranslate() return true end

local function plain(value) return tostring(value or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") end
function Goal:GetCurrencyProgress(brief,complete)
  local progress=Runtime:GetGoalProgress(self,self.parentStep and self.parentStep.num,self.num)
  if not progress then return "" end
  return string.format("%d/%d",progress.current or 0,progress.required or 1)
end

function Goal:GetText(showcompleteness,brief,showtotals,nocolor)
  self:SyncLegacyFields()
  local text=self.text or self.raw or self.target or ""
  local complete,_,current,required=self:IsComplete()
  if showcompleteness and required and required>1 then text=text..string.format(" (%d/%d)",current or 0,required) end
  if showcompleteness and complete and not nocolor then text="|cff66dd66"..text.."|r" end
  return nocolor and plain(text) or text
end
function Goal:GetString() return self.target or self.itemName or self.questName or self.text end

function Goal:Prepare(reset)
  if reset then self.prepared=nil end
  if self.prepared then return self end
  self:SyncLegacyFields(); self.was_visited=false; self.was_clicked=false
  if (self.action=="goal" or self.action=="kill" or self.action=="get") and not self.count then self.count=1 end
  self.prepared=true
  return self
end
function Goal:IsObsolete() return false end
function Goal:IsAuxiliary()
  return self.action=="goto" or self.action=="map" or self.action=="fly" or self.action=="hearth" or (self.action=="confirm" and self.always)
end

function Goal:OnEnter()
  self:Prepare()
  -- Scripts received from guide content remain governed by Automation's
  -- trusted-source policy.  A display callback must never elevate a user
  -- guide into executable code.
  if self.autoscript and ZGV.Automation and ZGV.Automation.Run then ZGV.Automation:Run(self.autoscript,self) end
end

function Goal:GetIndentChildren()
  local children,goals={},self.parentStep and self.parentStep.goals or {}
  for index=(self.num or 0)+1,#goals do
    local goal=goals[index]
    if goal.indent==(self.indent or 0)+1 then children[#children+1]=goal elseif (goal.indent or 0)<=(self.indent or 0) then break end
  end
  return children
end
function Goal:CanBeIndentHidden()
  local children=self:GetIndentChildren(); local complete=self:IsComplete()
  if #children==0 then return complete end
  for _,child in ipairs(children) do if not child:CanBeIndentHidden() then return false end end
  return complete
end

function Goal:IsViableDressup()
  if type(IsModifiedClick)=="function" and not IsModifiedClick("DRESSUP") then return false end
  return self.itemID and type(DressUpItemLink)=="function" or false
end
function Goal:PerformDressup() if self.itemID and type(DressUpItemLink)=="function" then DressUpItemLink("item:"..self.itemID); return true end end

function Goal:OnClick(button)
  self:SyncLegacyFields()
  if self:IsViableDressup() then return self:PerformDressup() end
  if not self.parentStep then return false end
  local result=Runtime:ActivateGoal(self.parentStep and self.parentStep.num, self.num)
  if result then self.was_clicked=true; if self.force_sticky_saved then self:SaveStickyComplete() end end
  if type(IsShiftKeyDown)=="function" and IsShiftKeyDown() then self:ShareToChat((ZGV.db.profile.share_target or "SAY"),"brand","withtips") end
  return result
end

function Goal:WasSavedStickyComplete()
  local saved=ZGV.db and ZGV.db.profile and ZGV.db.profile.saved_sticky_goals
  local guide=self.parentStep and self.parentStep.parentGuide
  return saved and guide and saved[guide.id] and saved[guide.id][tostring(self.parentStep.num).."/"..tostring(self.num)]
end
function Goal:SaveStickyComplete()
  if not self.forceStickySaved and not self.force_sticky_saved then return end
  local guide=self.parentStep and self.parentStep.parentGuide; if not guide or not ZGV.db then return end
  local saved=ZGV.db.profile.saved_sticky_goals or {}; ZGV.db.profile.saved_sticky_goals=saved; saved[guide.id]=saved[guide.id] or {}
  saved[guide.id][tostring(self.parentStep.num).."/"..tostring(self.num)]=self:IsComplete()
end
function Goal:IsInlineTravel() return self.destination and self.action=="goto" and not self.forceComplete and not self.questID and not self.npcID end
function Goal:GetDebugDump()
  local complete,possible,current,required,reason=self:IsComplete()
  return string.format("[%d] %s status=%s %d/%d (%s)",self.num or 0,self:GetText(false,false,false,true),complete and "complete" or "incomplete",current or 0,required or 1,tostring(reason))
end
function Goal:GetTextForSharing(withtip)
  local text=self:GetText(false,false,true,true)
  if withtip then for _,tip in ipairs(self.tips or {}) do text=text.."\n"..plain(tip) end end
  return text
end
function Goal:GetTextForSharingWithAllTips() return {self:GetTextForSharing(true)} end
function Goal:ShareToChat(target,brand,withtips)
  if type(SendChatMessage)~="function" then return false end
  if target=="PARTY" and type(IsInGroup)=="function" and not IsInGroup() then return false end
  if target=="RAID" and type(IsInRaid)=="function" and not IsInRaid() then return false end
  if brand then SendChatMessage("Zygor: "..tostring(self.parentStep and self.parentStep.parentGuide and self.parentStep.parentGuide.title or "Guide"),target) end
  for _,line in ipairs(self:GetTextForSharingWithAllTips()) do SendChatMessage(line,target) end
  return true
end
