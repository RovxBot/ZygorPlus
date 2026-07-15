-- Legacy quest-chain helpers backed by the parsed WotLK chain graph/runtime.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local QuestDB=ZGV and ZGV.QuestDB
if type(QuestDB)~="table" then return end

local function completed(questID)
  local quest=ZGV.Compat and ZGV.Compat.Quest
  return quest and quest:IsCompleted(questID) or false
end

local function collect(graph,input,onlyIncomplete,result,seen)
  result,seen=result or {},seen or {}
  if type(input)=="table" then
    for _,value in pairs(input) do if type(value)=="number" then collect(graph,value,onlyIncomplete,result,seen) end end
    return result
  end
  local questID=tonumber(input)
  if not questID or seen[questID] then return result end
  seen[questID]=true
  if onlyIncomplete and completed(questID) then return result end
  if ZGV.ChainsBreadcrumbs and ZGV.ChainsBreadcrumbs[questID] then return result end
  if result[questID]==nil then result[questID]=true end
  local linked=graph and graph[questID]
  if type(linked)=="number" then collect(graph,linked,onlyIncomplete,result,seen)
  elseif type(linked)=="table" then
    for _,value in pairs(linked) do if type(value)=="number" then collect(graph,value,onlyIncomplete,result,seen) end end
  end
  return result
end

if type(QuestDB.GetChain)~="function" then
  function QuestDB:GetChain(questInput,onlyIncomplete,results)
    return collect(ZGV.Chains,questInput,onlyIncomplete,results)
  end
end
if type(QuestDB.GetChainFuture)~="function" then
  function QuestDB:GetChainFuture(questInput,onlyIncomplete,results)
    if not ZGV.RevChains and ZGV.ChainsParser and type(ZGV.ChainsParser.CreateReverse)=="function" then
      ZGV.ChainsParser:CreateReverse()
    end
    return collect(ZGV.RevChains,questInput,onlyIncomplete,results)
  end
end
if type(QuestDB.FindStartingPoint)~="function" then
  function QuestDB:FindStartingPoint(guide,forceStep)
    local runtime=ZGV.Runtime
    if not runtime then return false,"runtime unavailable" end
    if type(guide)~="table" and guide~=nil and ZGV.Catalog then guide=ZGV.Catalog:Get(guide) end
    guide=guide or runtime:ChooseSuggestedGuide()
    if not guide then return false,"guide unavailable" end
    return runtime:SelectGuide(guide,tonumber(forceStep) or 1)
  end
end
if type(QuestDB.GetStepTag)~="function" then
  function QuestDB:GetStepTag(step)
    if not step or not ZGV.Runtime then return nil end
    local state=ZGV.Runtime:GetStepState(step,step.num or step.number)
    if state and state.complete then return "Complete",false end
    if state and state.skipped then return "Skipped",false end
    return nil,state and state.required>0 or false
  end
end
if type(QuestDB.Cancel)~="function" then
  function QuestDB:Cancel()
    local char=ZGV.db and ZGV.db.char
    if char then
      char.SISquests=nil; char.SISguides=nil; char.SISdestination=nil; char.SISstarted=nil
    end
    if ZGV.Runtime and type(ZGV.Runtime.Tick)=="function" then ZGV.Runtime:Tick() end
    return true
  end
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.QuestDB=QuestDB
