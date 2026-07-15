local ZGV=ZygorGuidesViewer
local Talent=ZGV:RegisterModule("Talent",{builds={},byClass={},selected=nil,compiled={}})

-- On build 12340 the talent query functions exist before their backing data is
-- necessarily available.  In particular, PLAYER_LOGIN can precede the first
-- useful GetTalentInfo result.  Loading Blizzard_TalentUI and retrying from the
-- later talent/player events is therefore part of the data contract, not a UI
-- convenience.
function Talent:LoadBlizzardTalentUI()
  if self.loadingBlizzardTalentUI then return end
  self.loadingBlizzardTalentUI=true
  if type(IsAddOnLoaded)=="function" and not IsAddOnLoaded("Blizzard_TalentUI") and type(LoadAddOn)=="function" then
    pcall(LoadAddOn,"Blizzard_TalentUI")
  end
  if type(TalentFrame_LoadUI)=="function" then pcall(TalentFrame_LoadUI) end
  self.loadingBlizzardTalentUI=nil
end

local function normalize(text)
  local value=tostring(text or ""):lower():gsub("|r",""):gsub("|c%x%x%x%x%x%x%x%x","")
  value=value:gsub("^%s+",""):gsub("%s+$",""):gsub("%s+"," ")
  return value
end

local function talentIDForName(classData,name)
  if not classData then return nil end
  local normalized=normalize(name)
  if classData[normalized] then return classData[normalized] end
  if classData[name] then return classData[name] end
  -- Data-WotLK normalizes its keys at load time, but retain compatibility
  -- with callers or older datasets which expose authored title-case keys.
  for talentName,talentID in pairs(classData) do
    if normalize(talentName)==normalized then return talentID end
  end
end

function Talent:RegisterBuild(class,title,first,second,third)
  -- Both supported source packages call this API.  Anniversary registrations
  -- include an optional stat-weight argument before build/glyph data; losing
  -- that argument made those otherwise valid WotLK builds appear as an
  -- unsupported numeric build to the compiler.
  local statweights,build,glyphs
  if third~=nil or type(first)=="number" then statweights,build,glyphs=first,second,third
  else build,glyphs=first,second end
  class=tostring(class or ""):upper()
  local petType=class:match("^PET%s+(.+)$")
  local record={
    id=class..":"..title,class=petType and nil or class,petType=petType,title=title,raw=build,glyphs=glyphs,statweights=statweights,
    -- The imported WotLK text lists final rank allocations in a readable
    -- build order, not an order the client can necessarily learn them.  Keep
    -- coordinate and compact build formats strict, but treat those text
    -- order diagnostics as warnings and use the live tree to plan points.
    displayOrder=type(build)=="string" and build:find("[\r\n]")~=nil,
  }
  self.builds[#self.builds+1]=record
  local key=petType and ("PET "..petType) or class
  self.byClass[key]=self.byClass[key] or {}
  self.byClass[key][#self.byClass[key]+1]=record
  return record
end

function ZGV:RegisterTalentBuild(class,title,...)
  return Talent:RegisterBuild(class,title,...)
end

function Talent:GetTalentLookup(isPet)
  local service=ZGV.Compat.Talent
  local lookup={byName={},byID={},byPosition={},ordered={}}
  -- The 3.3.5 talent API is populated by Blizzard_TalentUI.  Text builds are
  -- compiled before the frame is first opened, so make the data dependency
  -- explicit instead of caching an empty lookup for the whole session.
  self:LoadBlizzardTalentUI()
  local trees=service:GetTrees(isPet)
  for _,tree in ipairs(trees) do
    for _,info in ipairs(tree.talents) do
      local prerequisite=info.prerequisite
      local position={
        tab=info.tab,index=info.index,name=info.name,maxRank=info.maxRank,tier=info.tier,column=info.column,
        prerequisiteTab=info.prerequisiteTab or (prerequisite and prerequisite.tab),
        prerequisiteIndex=info.prerequisiteIndex or (prerequisite and prerequisite.index),
        prerequisiteLearnable=info.prerequisiteLearnable,
      }
      lookup.byName[normalize(info.name)]=position
      lookup.byPosition[info.tab..":"..info.index]=position
      local link=GetTalentLink and GetTalentLink(info.tab,info.index,false,isPet and true or false)
      local id=link and tonumber(link:match("talent:(%d+)"))
      if id then lookup.byID[id]=position position.talentID=id end
      lookup.ordered[#lookup.ordered+1]=position
    end
  end
  for _,position in ipairs(lookup.ordered) do
    if position.prerequisiteTab and position.prerequisiteIndex then
      local prerequisite=lookup.byPosition[position.prerequisiteTab..":"..position.prerequisiteIndex]
      position.prerequisite=prerequisite
      position.prerequisiteName=prerequisite and prerequisite.name or nil
      position.prerequisiteMaxRank=prerequisite and prerequisite.maxRank or nil
    end
  end
  return lookup
end

function Talent:IsDataReady(isPet)
  local lookup=self:GetTalentLookup(isPet)
  return #lookup.ordered>0,lookup
end

function Talent:GetPetType()
  local tree=ZGV.Compat.Talent:GetTab(1,true)
  local background=tree and tostring(tree.background or "") or ""
  local petType=background:match("HunterPet([%a]+)")
  return petType and petType:upper() or nil
end

function Talent:GetGlyphRecommendations(build)
  local recommendations={}
  local raw=build and build.glyphs
  local function add(value)
    value=tostring(value or ""):gsub("//.*$",""):gsub("^%s+",""):gsub("%s+$","")
    if value~="" then recommendations[#recommendations+1]=value end
  end
  if type(raw)=="string" then
    for line in (raw.."\n"):gmatch("(.-)\r?\n") do add(line) end
  elseif type(raw)=="table" then
    for _,value in ipairs(raw) do add(value) end
  end
  return recommendations
end

local function append(sequence,position,count)
  for _=1,(tonumber(count) or 1) do
    sequence[#sequence+1]={
      tab=position.tab,index=position.index,name=position.name,
      maxRank=position.maxRank,tier=position.tier,column=position.column,talentID=position.talentID,
      prerequisiteTab=position.prerequisiteTab,prerequisiteIndex=position.prerequisiteIndex,
      prerequisiteName=position.prerequisiteName,prerequisiteMaxRank=position.prerequisiteMaxRank,
    }
  end
end

function Talent:ResolveName(name,lookup,classKey)
  local alternatives={}
  for value in tostring(name):gmatch("[^|]+") do alternatives[#alternatives+1]=normalize(value) end
  for _,value in ipairs(alternatives) do if lookup.byName[value] then return lookup.byName[value] end end
  local ids=ZGV.Data.talentIDs or ZGV.Data.TalentIDs
  local classData=ids and ids[classKey]
  if classData then
    for _,value in ipairs(alternatives) do
      local id=talentIDForName(classData,value)
      if id and lookup.byID[id] then return lookup.byID[id] end
    end
  end
end

function Talent:Compile(build)
  if not build then return nil,"missing build" end
  if self.compiled[build.id] then return self.compiled[build.id] end
  local isPet=build.petType~=nil
  local lookup=self:GetTalentLookup(isPet)
  if #lookup.ordered==0 then return nil,"talent data unavailable" end
  local sequence,issues,warnings={},{},{}
  local function issue(message) issues[#issues+1]=message end
  local function warning(message) warnings[#warnings+1]=message end
  local function orderIssue(message)
    if build.displayOrder then warning(message) else issue(message) end
  end
  if type(build.raw)=="table" then
    for _,point in ipairs(build.raw) do
      if type(point)=="table" and tonumber(point[1]) and tonumber(point[2]) then
        local position=lookup.byPosition[tonumber(point[1])..":"..tonumber(point[2])]
        if position then append(sequence,position,1)
        else issue("unknown position "..tostring(point[1])..":"..tostring(point[2])) end
      elseif type(point)=="string" then
        -- The legacy 3.3.5 package contains both coordinate tables and tables
        -- with one authored talent name per point.  Preserve both encodings.
        local position=self:ResolveName(point,lookup,build.petType and ("PET "..build.petType) or build.class)
        if position then append(sequence,position,1) else issue("unknown talent: "..point) end
      else
        issue("unsupported table entry")
      end
    end
  elseif type(build.raw)=="string" and build.raw:match("^%d+$") then
    for index=1,math.min(#build.raw,#lookup.ordered) do
      local rank=tonumber(build.raw:sub(index,index)) or 0
      append(sequence,lookup.ordered[index],rank)
    end
  elseif type(build.raw)=="string" then
    -- Text registrations state target ranks (for example `3/3 Flurry`) and
    -- may later add one rank with a `Now 2/3` note.  Treat the former as a
    -- target, not three new allocations every time it is repeated.  This
    -- keeps the imported WotLK level-order notes within live rank caps.
    local plannedRanks={}
    for sourceLine in (build.raw.."\n"):gmatch("(.-)\r?\n") do
      local now=sourceLine:match("%(%s*[Nn]ow%s+(%d+)%s*/%s*%d+%s*%)")
      local line=sourceLine:gsub("//.*$",""):gsub("^%s+",""):gsub("%s+$",""):gsub("||","|")
      if line~="" then
        local declared,maximum,name=line:match("^(%d+)%s*/%s*(%d+)%s+(.+)$")
        local count
        if name then
          count=tonumber(declared) or 1
        else
          count,name=line:match("^(%d+)%s*[%*x]?%s+(.+)$")
          if not name then count,name=1,line end
        end
        local position=self:ResolveName(name,lookup,build.petType and ("PET "..build.petType) or build.class)
        if position then
          local key=position.tab..":"..position.index
          local prior=plannedRanks[key] or 0
          local target
          if declared then target=tonumber(now) or tonumber(declared) or prior
          elseif now then target=tonumber(now) or prior+(tonumber(count) or 1)
          else target=prior+(tonumber(count) or 1) end
          target=math.min(target,tonumber(position.maxRank) or target)
          if target>prior then append(sequence,position,target-prior) end
          plannedRanks[key]=math.max(prior,target)
        else
          orderIssue("unknown talent: "..name)
        end
      end
    end
  else return nil,"unsupported build encoding" end

  -- Reject sequences which can never be learned.  Previously an over-ranked
  -- talent remained the permanent "next" recommendation after LearnTalent
  -- returned max_rank, making several release builds impossible to finish.
  local ranks={}
  local overRanked={}
  local spentByTree={}
  local tierStep=isPet and 3 or 5
  for pointIndex,point in ipairs(sequence) do
    local key=point.tab..":"..point.index
    local nextRank=(ranks[key] or 0)+1
    local overRank=point.maxRank and nextRank>point.maxRank
    if overRank and not overRanked[key] then
      orderIssue(("talent over rank cap: %s (%d/%d)"):format(point.name,nextRank,point.maxRank))
      overRanked[key]=true
    end
    local required=(math.max(1,tonumber(point.tier) or 1)-1)*tierStep
    local spent=spentByTree[point.tab] or 0
    local tierBlocked=not overRank and spent<required
    local prerequisiteBlocked=false
    if not overRank and point.prerequisiteTab and point.prerequisiteIndex then
      local prerequisiteKey=point.prerequisiteTab..":"..point.prerequisiteIndex
      local prerequisiteRank=ranks[prerequisiteKey] or 0
      local prerequisiteMaxRank=tonumber(point.prerequisiteMaxRank)
      if not prerequisiteMaxRank or prerequisiteMaxRank<1 then
        orderIssue(("talent prerequisite data unavailable at point %d: %s requires position %s"):format(pointIndex,point.name,prerequisiteKey))
        prerequisiteBlocked=true
      elseif prerequisiteRank<prerequisiteMaxRank then
        orderIssue(("talent prerequisite unavailable at point %d: %s requires %s at %d/%d, only %d precede it"):format(
          pointIndex,point.name,point.prerequisiteName or prerequisiteKey,prerequisiteMaxRank,prerequisiteMaxRank,prerequisiteRank))
        prerequisiteBlocked=true
      end
    end
    if tierBlocked then
      orderIssue(("talent tier unavailable at point %d: %s requires %d points in tree %d, only %d precede it"):format(pointIndex,point.name,required,point.tab,spent))
    end
    -- Even when a display-order line comes before its prerequisite, keep the
    -- allocation tally.  GetSuggestionState uses it to select the currently
    -- learnable prerequisite rather than excluding the whole build.
    if not overRank and (build.displayOrder or (not tierBlocked and not prerequisiteBlocked)) then
      ranks[key]=nextRank
      spentByTree[point.tab]=spent+1
    end
  end

  local limit=isPet and 20 or 71
  if #sequence>limit then
    local message=("too many talent points: %d/%d"):format(#sequence,limit)
    if build.displayOrder then
      warning(message)
      while #sequence>limit do table.remove(sequence) end
    else issue(message) end
  end
  if not isPet then
    local one,two,three=tostring(build.title or ""):match("%(%s*(%d+)%s*/%s*(%d+)%s*/%s*(%d+)%s*%)")
    if one then
      local advertised=tonumber(one)+tonumber(two)+tonumber(three)
      if advertised>71 then issue("title advertises more than 71 points") end
      if #sequence~=advertised then
        orderIssue(("point total does not match title: %d/%d"):format(#sequence,advertised))
      end
    end
  end

  local result={build=build,sequence=sequence,issues=issues,warnings=warnings,isPet=isPet,valid=#sequence>0 and #issues==0}
  self.compiled[build.id]=result
  return result
end

function Talent:GetBuilds(classKey)
  if not classKey then
    local _,class=UnitClass("player")
    classKey=class
  end
  local builds=self.byClass[tostring(classKey or ""):upper()] or {}
  local valid={}
  for _,build in ipairs(builds) do
    local compiled=self:Compile(build)
    if compiled and compiled.valid then valid[#valid+1]=build end
  end
  return valid
end

function Talent:GetPetBuilds()
  local petType=self:GetPetType()
  if not petType then return {},nil end
  return self:GetBuilds("PET "..petType),petType
end

function Talent:SelectBuild(value)
  local _,class=UnitClass("player")
  for _,build in ipairs(self.builds) do
    if (build.id==value or build.title==value) and (build.class==class or (class=="HUNTER" and build.petType)) then
      local compiled,compileError=self:Compile(build)
      if not compiled or not compiled.valid then
        return false,"invalid_build",compiled and compiled.issues or {compileError}
      end
      self.selected=build
      local group=ZGV.Compat.Talent:GetActiveGroup(build.petType~=nil)
      local context=(build.petType and "pet" or "player")..tostring(group)
      self.selectedByContext=self.selectedByContext or {}
      self.selectedByContext[context]=build
      ZGV.db.profile.talent.selected[context]=build.id
      ZGV:Fire("ZGV_TALENT_BUILD_CHANGED",build)
      return true
    end
  end
  return false
end

function Talent:GetSelected(isPet)
  local group=ZGV.Compat.Talent:GetActiveGroup(isPet)
  local context=(isPet and "pet" or "player")..tostring(group)
  local selected=self.selectedByContext and self.selectedByContext[context]
  if selected then
    local compiled=self:Compile(selected)
    if compiled and compiled.valid then return selected end
  end
  local id=ZGV.db.profile.talent.selected[context]
  if id then
    for _,build in ipairs(self.builds) do
      if build.id==id then
        local compiled=self:Compile(build)
        if compiled and compiled.valid then
          self.selectedByContext=self.selectedByContext or {}
          self.selectedByContext[context]=build
          return build
        end
      end
    end
  end
end

function Talent:GetNextPoint(build)
  build=build or self:GetSelected(false)
  -- Callers use this as the next structural point even between level-ups;
  -- request one planned slot so it retains the Classic API contract when the
  -- player currently has zero unspent points.
  local state=self:GetSuggestionState(build,1)
  if not state.ready then return nil,state.message end
  if state.suggestions and state.suggestions[1] then return state.suggestions[1] end
  if state.complete then return nil,"complete" end
  if state.firstBlocked then
    return nil,"prerequisite unavailable: "..(state.firstBlocked.name or (state.firstBlocked.tab..":"..state.firstBlocked.index))
  end
  return nil,"no learnable recommendation"
end

-- Return the complete Classic-style recommendation state.  Unlike GetNextPoint
-- this includes every point that can be previewed with the player's currently
-- unspent points, the selected build's recovery status, and off-build points.
function Talent:GetSuggestionState(build,requestedSlots)
  build=build or self:GetSelected(false)
  local compiled,err=self:Compile(build)
  if not compiled then
    return {build=build,code=err=="talent data unavailable" and "NONE" or "BLACK",message=err or "No build selected.",suggestions={},ready=false}
  end
  if not compiled.valid then
    return {build=build,code="BLACK",message=compiled.issues[1] or "The selected build is invalid.",suggestions={},ready=true,compiled=compiled}
  end

  local actual,planned,occurrence={},{},{}
  local spent=0
  local trees=ZGV.Compat.Talent:GetTrees(compiled.isPet)
  for _,tree in ipairs(trees) do
    for _,info in ipairs(tree.talents or {}) do
      local key=info.tab..":"..info.index
      actual[key]=tonumber(info.rank) or 0
      spent=spent+actual[key]
    end
  end
  for _,point in ipairs(compiled.sequence) do
    local key=point.tab..":"..point.index
    planned[key]=(planned[key] or 0)+1
  end

  local wrong,matched=0,0
  for key,rank in pairs(actual) do
    matched=matched+math.min(rank,planned[key] or 0)
    if rank>(planned[key] or 0) then wrong=wrong+rank-(planned[key] or 0) end
  end

  local missingSeen,outOfOrder=false,false
  local allMissing={}
  for pointIndex,point in ipairs(compiled.sequence) do
    local key=point.tab..":"..point.index
    occurrence[key]=(occurrence[key] or 0)+1
    if (actual[key] or 0)<occurrence[key] then
      missingSeen=true
      local liveInfo=ZGV.Compat.Talent:GetInfo(point.tab,point.index,compiled.isPet)
      allMissing[#allMissing+1]={
        tab=point.tab,index=point.index,name=point.name,targetRank=occurrence[key],
        currentRank=actual[key] or 0,isPet=compiled.isPet,build=build,
        texture=liveInfo and liveInfo.texture,point=pointIndex,
      }
    elseif missingSeen then
      outOfOrder=true
    end
  end

  local unspent=math.max(0,tonumber(ZGV.Compat.Talent:GetUnspentPoints(compiled.isPet)) or 0)
  local suggestionSlots=tonumber(requestedSlots) or unspent
  local suggestions={}
  -- A legacy build's display order is not necessarily its acquisition order.
  -- Simulate the points available right now and take any point that satisfies
  -- the live tree plus its WotLK tier/prerequisite requirements.  This makes
  -- all imported build templates usable instead of repeatedly suggesting a
  -- locked talent at the top of the text block.
  local simulatedRanks,simulatedSpent={},{}
  for key,rank in pairs(actual) do simulatedRanks[key]=rank end
  for _,tree in ipairs(trees) do
    local treeSpent=0
    for _,info in ipairs(tree.talents or {}) do treeSpent=treeSpent+(tonumber(info.rank) or 0) end
    simulatedSpent[tree.index or (tree.talents[1] and tree.talents[1].tab)]=treeSpent
  end
  local tierStep=compiled.isPet and 3 or 5
  local firstBlocked
  for _,candidate in ipairs(allMissing) do
    local key=candidate.tab..":"..candidate.index
    local liveInfo=ZGV.Compat.Talent:GetInfo(candidate.tab,candidate.index,compiled.isPet)
    local current=simulatedRanks[key] or 0
    local position=compiled.sequence[candidate.point or 1]
    -- `GetTalentInfo` is the authority for the active 3.3.5 tree.  Some
    -- clients report incomplete prerequisite coordinates via
    -- GetTalentPrereqs (notably after localization), so using those cached
    -- coordinates here would falsely lock otherwise learnable WotLK talents.
    local required=(math.max(1,tonumber(position and position.tier) or 1)-1)*tierStep
    local tierOK=(simulatedSpent[candidate.tab] or 0)>=required
    local liveOK=liveInfo and liveInfo.meetsPrerequisite~=false
    if candidate.targetRank==current+1 and liveOK and tierOK and #suggestions<suggestionSlots then
      suggestions[#suggestions+1]=candidate
      simulatedRanks[key]=current+1
      simulatedSpent[candidate.tab]=(simulatedSpent[candidate.tab] or 0)+1
    elseif not firstBlocked and candidate.targetRank==current+1 then
      firstBlocked={tab=candidate.tab,index=candidate.index,name=(liveInfo and liveInfo.name) or candidate.name}
    end
  end

  local code,message
  if wrong>0 then
    code="RED"
    message=("Your current talents contain %d point%s outside this build. Reset or select a build that matches your talents."):format(wrong,wrong==1 and "" or "s")
  elseif #allMissing==0 then
    code="GREEN"
    message="This build is complete."
  elseif outOfOrder then
    code="YELLOW"
    message="Some talents were learned out of order. The advisor will guide you back onto this build."
  elseif unspent==0 then
    code="GREEN"
    message=("On track. The next recommendation unlocks with your next talent point (%d remaining)."):format(#allMissing)
  elseif #suggestions==0 then
    code="YELLOW"
    message="The next build talent is locked. Spend a listed prerequisite or update the talent frame."
  else
    code="GREEN"
    message=("On track. %d unspent talent point%s available."):format(unspent,unspent==1 and "" or "s")
  end
  return {
    build=build,compiled=compiled,code=code,message=message,suggestions=suggestions,
    allMissing=allMissing,unspent=unspent,spent=spent,matched=matched,wrong=wrong,
    outOfOrder=outOfOrder,complete=#allMissing==0,ready=true,isPet=compiled.isPet,firstBlocked=firstBlocked,
  }
end

function Talent:GetSuggestions(build)
  return self:GetSuggestionState(build).suggestions
end

function Talent:LearnNext(build)
  local nextPoint,reason=self:GetNextPoint(build)
  if not nextPoint then return false,reason end
  local result=ZGV.Compat.Talent:Learn(nextPoint.tab,nextPoint.index,nextPoint.isPet)
  if not result.ok then return false,result.code end
  return true,nextPoint
end

function Talent:ValidateBuilds(classKey)
  if not classKey then
    local _,playerClass=UnitClass("player")
    classKey=playerClass
  end
  classKey=tostring(classKey or ""):upper()
  local candidates=self.byClass[classKey] or {}
  local report={class=classKey,total=#candidates,valid=0,invalid=0,issues={}}
  for _,build in ipairs(candidates) do
    local compiled,err=self:Compile(build)
    if compiled and compiled.valid then report.valid=report.valid+1 else report.invalid=report.invalid+1 end
    if err or compiled and #compiled.issues>0 then report.issues[#report.issues+1]={build=build.title,error=err,issues=compiled and compiled.issues} end
  end
  self.validationReport=report
  return report
end

function Talent:InitializeBuilds(trigger)
  local ready=self:IsDataReady(false)
  if not ready then
    if not self.waitingForData and ZGV.LogInfo then
      ZGV:LogInfo("talents","talent data not ready during "..tostring(trigger or "startup").."; initialization deferred")
    end
    self.waitingForData=true
    return false,"talent data unavailable"
  end

  local _,class=UnitClass("player")
  local report=self:ValidateBuilds(class)
  if ZGV.LogInfo and not self.validationLogged then
    ZGV:LogInfo("talents",("validated %d %s builds: %d valid, %d invalid"):format(report.total,tostring(class),report.valid,report.invalid))
    for _,entry in ipairs(report.issues) do
      local detail=entry.error or table.concat(entry.issues or {},"; ")
      ZGV:LogInfo("talents",("excluded invalid build %s: %s"):format(tostring(entry.build),tostring(detail)))
    end
    self.validationLogged=true
  end
  local legacy=ZGV.db.profile.talent.legacyBuild
  if legacy then self:SelectBuild(legacy) end
  if not self:GetSelected(false) then
    local builds=self:GetBuilds(class)
    if builds[1] then self:SelectBuild(builds[1].id) end
  end
  self.waitingForData=nil
  self.dataReady=true
  if self.retryFrame then self.retryFrame:SetScript("OnUpdate",nil) self.retryFrame:Hide() end
  return report.valid>0,report.valid>0 and nil or "no valid builds"
end

function Talent:StartInitializationRetry()
  if type(CreateFrame)~="function" or self.dataReady then return end
  if not self.retryFrame then self.retryFrame=CreateFrame("Frame") end
  self.retryElapsed=0
  self.retryAttempts=0
  self.retryFrame:SetScript("OnUpdate",function(frame,elapsed)
    Talent.retryElapsed=Talent.retryElapsed+(tonumber(elapsed) or 0)
    if Talent.retryElapsed<.5 then return end
    Talent.retryElapsed=0
    Talent.retryAttempts=Talent.retryAttempts+1
    Talent.compiled={}
    if Talent:InitializeBuilds("deferred retry "..tostring(Talent.retryAttempts)) or Talent.retryAttempts>=20 then
      frame:SetScript("OnUpdate",nil)
      frame:Hide()
    end
  end)
  self.retryFrame:Show()
end

function Talent:OnStartup()
  if not self:InitializeBuilds("PLAYER_LOGIN") then self:StartInitializationRetry() end
end

function Talent:OnEvent(event,addon)
  if event=="ADDON_LOADED" and addon~="Blizzard_TalentUI" then return end
  self.compiled={}
  if not self.dataReady or not self:GetSelected(false) then self:InitializeBuilds(event) end
  if event=="ACTIVE_TALENT_GROUP_CHANGED" and not self:GetSelected(false) then self:InitializeBuilds(event) end
  ZGV:Fire("ZGV_TALENTS_UPDATED",event)
end
for _,event in ipairs({"PLAYER_ALIVE","PLAYER_ENTERING_WORLD","PLAYER_TALENT_UPDATE","CHARACTER_POINTS_CHANGED","ACTIVE_TALENT_GROUP_CHANGED","GLYPH_ADDED","GLYPH_REMOVED","PET_TALENT_UPDATE","UNIT_PET","ADDON_LOADED"}) do
  ZGV:RegisterEvent(event,Talent,"OnEvent")
end
