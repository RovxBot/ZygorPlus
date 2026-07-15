-- WotLK quest-chain parser.  This is kept data-only by default: `func`
-- entries are accepted only for explicitly trusted user content, matching the
-- port's script trust boundary.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Chains=ZGV:RegisterModule("ChainsParser",{})
ZGV.Chains=ZGV.Chains or {}
ZGV.ChainsRaw=ZGV.ChainsRaw or ""
ZGV.ChainsBreadcrumbs=ZGV.ChainsBreadcrumbs or {}
ZGV.ChainsInProgress=ZGV.ChainsInProgress or {}
ZGV.ChainsSiblings=ZGV.ChainsSiblings or {}
ZGV.ChainExclusives=ZGV.ChainExclusives or {}

local function trim(value)
  return tostring(value or ""):gsub("^%s+",""):gsub("%s+$","")
end

local function split(value,separator)
  local result={}
  for field in (tostring(value or "")..separator):gmatch("(.-)"..separator) do result[#result+1]=field end
  return result
end

local function maybeYield()
  local thread,isMain=coroutine.running()
  if thread and not isMain then coroutine.yield() end
end

local function parseEntry(value)
  local text=trim(value):lower()
  local side,remainder=text:match("^([ah])%s+(.+)$")
  if side then
    local faction=UnitFactionGroup and UnitFactionGroup("player") or nil
    local playerSide=faction=="Alliance" and "a" or faction=="Horde" and "h" or nil
    if playerSide and side~=playerSide then return nil,nil,false,false end
    text=remainder
  end
  local breadcrumb=text:find(" breadcrumb",1,true)~=nil
  local inLog=text:find(" inlog",1,true)~=nil
  text=trim(text:gsub(" breadcrumb",""):gsub(" inlog",""))
  local id=tonumber((text:gsub("^[ah]%s+","")))
  if id then
    if breadcrumb then ZGV.ChainsBreadcrumbs[id]=true end
    if inLog then ZGV.ChainsInProgress[id]=true end
  end
  return text,id,breadcrumb,inLog
end

local function parseCondition(value)
  local text=trim(value):lower()
  if text:sub(1,5)=="func " then
    if not (ZGV.db and ZGV.db.global and ZGV.db.global.trustedUserScripts) then return nil end
    local loader=loadstring(text:sub(6),"ZGV quest chain")
    return loader
  end
  text=text:gsub("%s+and%s+"," and "):gsub("%s+or%s+"," or ")
  local hasOr=text:find(" or ",1,true)~=nil
  local hasAnd=text:find(" and ",1,true)~=nil
  if not hasOr and not hasAnd then
    local _,id=parseEntry(text)
    return id
  end
  -- Faction markers apply to individual operands, not the full expression.
  -- For example, "A 2011 or H 2012" must retain 2011 for Alliance and 2012
  -- for Horde instead of rejecting the expression based on its first marker.
  local separator,operator=hasOr and " or " or " and ",hasOr and "OR" or "AND"
  local fields=split(text,separator)
  if #fields<=1 then return nil end
  local result={operator}
  local siblings={}
  for _,field in ipairs(fields) do
    local clean,number=parseEntry(field)
    local parsed=number or clean
    if parsed then result[#result+1]=parsed end
    if number then siblings[#siblings+1]=number end
  end
  if #result==1 then return nil end
  if #result==2 then return result[2] end
  if operator=="OR" then
    for _,number in ipairs(siblings) do ZGV.ChainsSiblings[number]=siblings end
  end
  return result
end

function ZGV:RegisterQuestChains(text)
  if type(text)=="string" then self.ChainsRaw=(self.ChainsRaw or "")..text.."\n" end
end

function Chains:Parse(text,output)
  text=text or ZGV.ChainsRaw
  output=output or ZGV.Chains
  if type(text)~="string" then return output end
  text=text:gsub("\r",""):gsub("%s*//.-\n","\n")
  local lineNumber=0
  for raw in (text.."\n"):gmatch("(.-)\n") do
    lineNumber=lineNumber+1
    local line=trim(raw)
    if line~="" then
      if line~="" then
        local target,data=line:match("^(%d+)%s*=%s*(.-)$")
        if target then
          output[tonumber(target)]=parseCondition(data)
        elseif line:match("^EITHER%s+") then
          local choices={}
          for _,id in ipairs(split(line:match("^EITHER%s+(.+)$"),",")) do
            id=tonumber(trim(id))
            if id then choices[#choices+1]=id end
          end
          if #choices>1 then ZGV.ChainExclusives[#ZGV.ChainExclusives+1]=choices end
        else
          local nodes=split(line,",")
          if #nodes>1 then
            for index=1,#nodes-1 do
              local before,after=parseCondition(nodes[index]),parseCondition(nodes[index+1])
              local pre=type(before)=="table" and before or {before}
              local post=type(after)=="table" and after or {after}
              local operator=type(before)=="table" and before[1] or "AND"
              for _,postQuest in ipairs(post) do
                if type(postQuest)=="number" then
                  for _,preQuest in ipairs(pre) do
                    if type(preQuest)=="number" then
                      local existing=output[postQuest]
                      if not existing then output[postQuest]=preQuest
                      elseif type(existing)~="table" then output[postQuest]={operator,existing,preQuest}
                      else existing[#existing+1]=preQuest end
                    end
                  end
                end
              end
            end
          elseif ZGV.LogError then
            ZGV:LogError("quest chains","unrecognised line "..tostring(lineNumber)..": "..line)
          end
        end
      end
    end
    maybeYield()
  end
  for quest,requirements in pairs(output) do
    if type(requirements)=="table" then
      local seen,index={},2
      while index<=#requirements do
        local value=requirements[index]
        if seen[value] then table.remove(requirements,index) else seen[value]=true; index=index+1 end
      end
      if #requirements==2 then output[quest]=requirements[2] end
    end
  end
  return output
end

function ZGV:ParseQuestChains_yielding(text,chains) return Chains:Parse(text,chains) end

function Chains:CreateReverse()
  local reverse={}
  for post,requirements in pairs(ZGV.Chains) do
    local values=type(requirements)=="table" and requirements or {requirements}
    for _,pre in ipairs(values) do
      if type(pre)=="number" then
        reverse[pre]=reverse[pre] or {}
        reverse[pre][#reverse[pre]+1]=post
      end
    end
    maybeYield()
  end
  ZGV.RevChains=reverse
  return reverse
end

function ZGV:CreateReverseQuestChains_yielding() return Chains:CreateReverse() end

function Chains:Cleanup(chains)
  chains=chains or ZGV.Chains
  for post,requirements in pairs(chains) do
    if requirements==post then chains[post]=nil
    elseif type(requirements)=="table" then
      for index=#requirements,2,-1 do if requirements[index]==post then table.remove(requirements,index) end end
      if #requirements==1 then chains[post]=nil elseif #requirements==2 then chains[post]=requirements[2] end
    end
  end
end

function ZGV:CleanupChains() return Chains:Cleanup() end

function Chains:OnStartup()
  local merged={}
  local base=ZGV.Data and ZGV.Data.questChains or {}
  for post,requirements in pairs(base) do
    if type(requirements)=="table" then
      local copy={}
      for index,value in ipairs(requirements) do copy[index]=value end
      merged[post]=copy
    else
      merged[post]=requirements
    end
  end
  -- The exact Anniversary Classic/TBC graph is parsed separately and takes
  -- precedence for overlapping pre-Wrath quests.  The static 3.3.5 graph
  -- supplies Northrend and any older prerequisites absent from that source.
  local classicTBC={}
  self:Parse(nil,classicTBC)
  self:Cleanup(classicTBC)
  for post,requirements in pairs(classicTBC) do merged[post]=requirements end
  ZGV.Chains=merged
  self:Cleanup(merged)
  self:CreateReverse()
  ZGV.ChainsRaw=nil
  ZGV:Fire("ZGV_QUEST_CHAINS_UPDATED",ZGV.Chains,ZGV.RevChains)
end
