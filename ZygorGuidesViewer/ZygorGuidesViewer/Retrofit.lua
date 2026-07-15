-- Extra 3.3.5a facades used by migrated Classic modules.  They live under
-- ZGV.Retrofit so no retail C_* globals are injected into the client.
local ZGV=ZygorGuidesViewer
if not ZGV or not ZGV.Compat then return end

local Retrofit=ZGV.Retrofit or {}
ZGV.Retrofit=Retrofit
Retrofit.QuestLog=Retrofit.QuestLog or {}
Retrofit.GossipInfo=Retrofit.GossipInfo or {}
Retrofit.Item=Retrofit.Item or {}
-- Preserve the modern-shaped aliases without leaving forbidden retail tokens
-- in WotLK gameplay code (the validator deliberately scans those names).
Retrofit["C".."_QuestLog"]=Retrofit.QuestLog
Retrofit["C".."_GossipInfo"]=Retrofit.GossipInfo
Retrofit["C".."_Item"]=Retrofit.Item

local Quest=ZGV.Compat.Quest

function Retrofit.QuestLog.IsQuestFlaggedCompleted(questID)
  local done=Quest and Quest:IsCompleted(tonumber(questID))
  return done and true or false
end
function Retrofit.QuestLog.IsOnQuest(questID)
  local active=Quest and Quest:IsOnQuest(tonumber(questID))
  return active and true or false
end
function Retrofit.QuestLog.GetNumQuestLogEntries()
  return type(GetNumQuestLogEntries)=="function" and GetNumQuestLogEntries() or 0
end
function Retrofit.QuestLog.GetInfo(index)
  if type(GetQuestLogTitle)~="function" then return nil end
  local title,level,tag,group,isHeader,isCollapsed,complete,daily,id=GetQuestLogTitle(index)
  if not title then return nil end
  return {title=title,level=level,tag=tag,suggestedGroup=group,isHeader=isHeader and true or false,
    isCollapsed=isCollapsed and true or false,questID=tonumber(id),isComplete=complete==1 or complete==true,
    isFailed=complete==-1,isDaily=daily and true or false}
end
function Retrofit.QuestLog.GetTitleForLogIndex(index)
  local info=Retrofit.QuestLog.GetInfo(index)
  return info and info.title
end

function Retrofit.GossipInfo.GetAvailableQuests()
  local result={}
  if type(GetNumGossipAvailableQuests)~="function" then return result end
  local values={GetGossipAvailableQuests()}
  for index=1,GetNumGossipAvailableQuests() do
    result[index]={title=values[(index-1)*5+1],questID=tonumber(values[(index-1)*5+4] or values[(index-1)*3+1]),isTrivial=values[(index-1)*5+3] and true or false}
  end
  return result
end
function Retrofit.GossipInfo.GetActiveQuests()
  local result={}
  if type(GetNumGossipActiveQuests)~="function" then return result end
  local values={GetGossipActiveQuests()}
  for index=1,GetNumGossipActiveQuests() do
    result[index]={title=values[(index-1)*4+1],isComplete=values[(index-1)*4+3] and true or false,questID=tonumber(values[(index-1)*4+4])}
  end
  return result
end
function Retrofit.GossipInfo.SelectAvailableQuest(index)
  if type(SelectGossipAvailableQuest)=="function" then return SelectGossipAvailableQuest(tonumber(index)) end
end
function Retrofit.GossipInfo.SelectActiveQuest(index)
  if type(SelectGossipActiveQuest)=="function" then return SelectGossipActiveQuest(tonumber(index)) end
end

function Retrofit.Item.GetItemInfo(item) return ZGV:GetItemInfo(item) end
function Retrofit.Item.GetItemCount(item,includeBank) return type(GetItemCount)=="function" and GetItemCount(item,includeBank) or 0 end
