-- Guide DSL compatibility parser.
--
-- The guide files are authored against the long-lived Zygor grammar used by
-- the Classic client.  Keep parsing independent of the viewer so this 3.3.5a
-- port accepts the same source constructs while exposing the smaller modern
-- Guide/Step/Goal model consumed by Runtime.lua and the viewer.
local ZGV = ZygorGuidesViewer
if not ZGV then return end

local Parser = ZGV:RegisterModule("Parser", { cache={}, issues={} })

local tinsert, tremove = table.insert, table.remove
local tonumber, tostring, type, pairs, ipairs = tonumber, tostring, type, pairs, ipairs

local ACTION_ALIASES = {
  a="accept", t="turnin", c="complete", k="kill", get="collect",
  flightpath="taxi", fpath="taxi", quest="accept",
  at="goto", ggoto="goto", goldcollect="collect",
}

-- Actions which can appear either as the leading command or as a pipe tag.
-- Unknown leading words intentionally remain prose: many guide goals are
-- natural-language quest objectives ("Light the brazier", for example).
local ACTIONS = {
  accept=true, turnin=true, talk=true, kill=true, collect=true, click=true,
  clicknpc=true, buy=true, use=true, equip=true, unequip=true, learn=true,
  trainer=true, vendor=true, home=true, hearth=true, fly=true, taxi=true,
  ding=true, complete=true, condition=true, confirm=true, achieve=true,
  achievesub=true, earn=true, rep=true, repcollect=true, skill=true,
  skillmax=true, craft=true, create=true, cast=true, trash=true,
  discover=true, goal=true, havebuff=true, nobuff=true, havequest=true,
  nothavequest=true, notcompleted=true, ["goto"]=true, map=true, abandon=true,
  activepet=true, gossip=true, petaction=true, avoid=true, gotonpc=true,
  bank=true, goldtracker=true,
}

local ITEM_ACTIONS = {
  collect=true, buy=true, use=true, equip=true, unequip=true, trash=true,
  create=true, craft=true,
}
local NPC_ACTIONS = {
  talk=true, kill=true, clicknpc=true, trainer=true, vendor=true,
}
local QUEST_ACTIONS = {
  accept=true, turnin=true, abandon=true, havequest=true, nothavequest=true,
  notcompleted=true,
}
local COUNT_ACTIONS = {
  kill=true, collect=true, buy=true, craft=true, create=true, click=true,
  clicknpc=true, trash=true,
}

local CLASS_NAMES = {
  deathknight=true, druid=true, hunter=true, mage=true, paladin=true,
  priest=true, rogue=true, shaman=true, warlock=true, warrior=true,
}
local FACTION_NAMES = { alliance=true, horde=true }

local function trim(value)
  local result=tostring(value or ""):gsub("^%s+",""):gsub("%s+$","")
  return result
end

local function unquote(value)
  value=trim(value)
  local first,last=value:sub(1,1),value:sub(-1)
  if (first=='"' and last=='"') or (first=="'" and last=="'") then
    value=value:sub(2,-2)
  end
  return value
end

local function normalizeGuidePath(value)
  return unquote(value):gsub("\\\\","\\")
end

local function addCondition(existing, expression)
  expression=trim(expression)
  if expression=="" then return existing end
  if not existing or existing=="" then return expression end
  return "("..existing..") and ("..expression..")"
end

local colourCodes = {
  o="|cffff7d40", orange="|cffff7d40", g="|cff00ff00", green="|cff00ff00",
  r="|cffff0000", red="|cffff0000", b="|cff3dbffb", blue="|cff3dbffb",
  y="|cffffcc00", yellow="|cffffcc00", p="|cffcf3dbf", purple="|cffcf3dbf",
  w="|cffffffff", white="|cffffffff",
  q0="|cff9d9d9d", poor="|cff9d9d9d", q1="|cffffffff", common="|cffffffff",
  q2="|cff1eff00", uncommon="|cff1eff00", q3="|cff0070dd", rare="|cff0070dd",
  q4="|cffa335ee", epic="|cffa335ee", q5="|cffff8000", legendary="|cffff8000",
  q6="|cffe6cc80", artifact="|cffe6cc80", q7="|cff00ccff", heirloom="|cff00ccff",
}

local function displayText(value)
  local text=tostring(value or "")
  -- Preserve escaped markup while applying the same simple authoring colours
  -- supported by the modern Classic parser.
  text=text:gsub("\\_", "%%ZGV_UNDERSCORE%%")
  text=text:gsub("_(.-)_", "|cffffee88%1|r")
  text=text:gsub("{}", "|r")
  text=text:gsub("{#(%x+)}", "|cff%1")
  text=text:gsub("{([%a%d_]+)}", function(code) return colourCodes[code:lower()] or "{"..code.."}" end)
  text=text:gsub("%%ZGV_UNDERSCORE%%", "_")
  text=text:gsub("##+%d+/?%d*", "")
  -- Legacy guides use this token in explanatory prose.  It is resolved while
  -- parsing in the Classic viewer, so retain that behaviour on the WotLK API.
  if UnitName then
    local player=UnitName("player")
    if player and player~="" then text=text:gsub("%$NAME",player) end
  end
  return trim(text)
end

-- A number of Classic travel steps intentionally put the coordinate just
-- outside a city gate (for example, "Enter Stormwind City |goto Elwynn
-- Forest ...").  That coordinate is a suggested approach, not a requirement
-- to use that single gate.  Preserve the author's city-transition intent so
-- Runtime can complete the step when the player enters/leaves the city map.
local CITY_TRANSITION_MAPS = {
  {"Shattrath City", "Shattrath City/0"}, {"Stormwind City", "Stormwind City/0"},
  {"Silvermoon City", "Silvermoon City/0"}, {"Thunder Bluff", "Thunder Bluff/0"},
  {"The Exodar", "The Exodar/0"}, {"Darnassus", "Darnassus/0"},
  {"Ironforge", "Ironforge/0"}, {"Orgrimmar", "Orgrimmar/0"},
  {"Undercity", "Undercity/0"}, {"Dalaran", "Dalaran/0"},
}

local function annotateCityTransition(goal)
  if not goal or (goal.action ~= "text" and goal.action ~= "goto") then return end
  local text=trim(goal.text):lower()
  for _,entry in ipairs(CITY_TRANSITION_MAPS) do
    local city,mapKey=entry[1],entry[2]
    local lowerCity=city:lower()
    if text:find(lowerCity,1,true) then
      if text:find("leave "..lowerCity,1,true) then
        goal.mapTransition={kind="leave",mapKey=mapKey}
      elseif text:find("enter "..lowerCity,1,true)
        or text:find("go to "..lowerCity,1,true)
        or text:find("to "..lowerCity,1,true) then
        goal.mapTransition={kind="enter",mapKey=mapKey}
      end
      if goal.mapTransition then return end
    end
  end
end

local function splitEscaped(value, delimiter)
  local parts, buffer={},{}
  value=tostring(value or "")
  local index=1
  while index<=#value do
    local char=value:sub(index,index)
    local following=value:sub(index+1,index+1)
    if char=="\\" and following==delimiter then
      buffer[#buffer+1]=following
      index=index+2
    elseif char==delimiter then
      parts[#parts+1]=table.concat(buffer)
      buffer={}
      index=index+1
    else
      buffer[#buffer+1]=char
      index=index+1
    end
  end
  parts[#parts+1]=table.concat(buffer)
  return parts
end

-- Comments are source syntax, not guide prose.  Do not mistake a comment
-- token within a quoted string for a comment, and allow authors to escape it.
local function stripComment(value)
  value=tostring(value or "")
  local quote=nil
  local index=1
  while index<=#value do
    local char=value:sub(index,index)
    local nextChar=value:sub(index+1,index+1)
    if char=="\\" then
      index=index+2
    elseif quote then
      if char==quote then quote=nil end
      index=index+1
    elseif char=="'" or char=='"' then
      quote=char
      index=index+1
    elseif (char=="/" and nextChar=="/") or (char=="-" and nextChar=="-") then
      return trim(value:sub(1,index-1))
    else
      index=index+1
    end
  end
  return trim(value)
end

local function splitCommand(segment)
  segment=trim(segment)
  if segment=="" then return "", "" end
  local command, parameters=segment:match("^(%S+)%s*(.-)$")
  return (command or ""):lower(), parameters or ""
end

function Parser:ParseID(value)
  value=trim(value)
  local name,id,objective=value:match("^(.-)##+(%d+)/(%d+)")
  if not id then name,id=value:match("^(.-)##+(%d+)") end
  if not id then id,objective=value:match("^##?(%d+)/(%d+)%+?%s*$") end
  if not id then id=value:match("^##?(%d+)%+?%s*$") end
  if name then name=trim(name) end
  if name=="" then name=nil end
  if not name and not id then name=value:gsub("%+$", "") end
  return name,tonumber(id),tonumber(objective)
end

function Parser:ParseRanges(value, asKeys)
  local result={}
  for _,piece in ipairs(splitEscaped(value,",")) do
    local first,last=trim(piece):match("^(%d+)%s*%-%s*(%d+)$")
    first,last=tonumber(first),tonumber(last)
    if first and last then
      for number=first,last do
        if asKeys then result[number]=true else result[#result+1]=number end
      end
    else
      local number=tonumber(trim(piece))
      if number then
        if asKeys then result[number]=true else result[#result+1]=number end
      end
    end
  end
  return result
end

-- Accept all location forms used by the modern parser: map/floor x,y, map,
-- x,y, bare x,y inherited from a previous map, and the legacy distance
-- suffix (< radius / > leave-radius).  Coordinates are normalised for the
-- legacy map APIs at this boundary.
function Parser:ParseMapXYDist(value, inheritedMap)
  local text=trim(value):gsub("^%[",""):gsub("%]$","")
  local number="%-?%d+%.?%d*"
  local mapText,x,y,distance,direction

  mapText,x,y,direction,distance=text:match("^(.-)%s*,?%s*("..number..")%s*,%s*("..number..")%s*([<>])%s*("..number..")%s*$")
  if not x then
    mapText,x,y,distance=text:match("^(.-)%s*,?%s*("..number..")%s*,%s*("..number..")%s*,%s*("..number..")%s*$")
  end
  if not x then
    mapText,x,y=text:match("^(.-)%s*,?%s*("..number..")%s*,%s*("..number..")%s*$")
  end
  if not x then
    mapText,x,y=text:match("^(.-)%s+("..number..")%s*,%s*("..number..")%s*$")
  end
  if mapText and trim(mapText)=="" then mapText=nil end
  if not x then
    x,y,direction,distance=text:match("^("..number..")%s*,%s*("..number..")%s*([<>])%s*("..number..")%s*$")
    mapText=nil
  end
  if not x then
    x,y=text:match("^("..number..")%s*,%s*("..number..")%s*$")
    mapText=nil
  end
  if not x and not mapText and text~="" then mapText=text end

  local map,floor
  if mapText and trim(mapText)~="" then
    mapText=trim(mapText):gsub("[,]$","")
    map,floor=mapText:match("^(.-)%s*/%s*(%d+)%s*$")
    if not map then map=mapText end
  elseif inheritedMap then
    if type(inheritedMap)=="table" then
      map,floor=inheritedMap.map,inheritedMap.floor
    else
      map,floor=tostring(inheritedMap):match("^(.-)/(%d+)$")
      map=map or inheritedMap
    end
  end

  map=trim(map)
  if map=="" then map=nil end
  floor=tonumber(floor) or 0
  x,y=tonumber(x),tonumber(y)
  distance=tonumber(distance)
  if distance and direction==">" then distance=-distance end
  if not distance then distance=.2 end
  return map,floor,x and x*.01 or nil,y and y*.01 or nil,distance,nil
end

function Parser:ParseLocation(value, inheritedMap)
  local map,floor,x,y,distance,err=self:ParseMapXYDist(value,inheritedMap)
  if not map and not x and not y then return nil,err end
  local numericMap=map and tonumber(map)
  local key
  if ZGV.CanonicalMapKey then key=ZGV:CanonicalMapKey(numericMap or map,floor) end
  if not key and map then key=tostring(map).."/"..tostring(floor or 0) end
  if not key then return nil,"location has coordinates but no map" end
  return {
    mapKey=key, map=map or tostring(key):match("^(.-)/%d+$"), floor=floor or 0,
    x=x, y=y, distance=distance, dist=distance,
  }
end

local function legacyOnlyCondition(value)
  value=trim(value)
  if value=="" then return nil end
  if value:lower():match("^if%s+") then return trim(value:sub(3)) end
  local alternatives={}
  for _,entry in ipairs(splitEscaped(value,",")) do
    entry=trim(entry)
    if entry~="" then
      local inverse=entry:match("^!%s*(.*)$")
      local words={}
      for word in (inverse or entry):gmatch("[^%s]+") do words[#words+1]=word end
      local normalized={}
      for index=1,#words do normalized[index]=words[index]:gsub("[%s_%-]","") end
      local expression
      if #normalized>=2 and CLASS_NAMES[(normalized[#normalized] or ""):lower()] then
        expression="raceclass("..string.format("%q",table.concat(normalized))..")"
      elseif #normalized==1 then
        expression="raceclass("..string.format("%q",normalized[1])..")"
      else
        -- Old guide syntax treats a whitespace list without a class suffix as
        -- separate alternatives (for example, "Human Dwarf").
        local options={}
        for index=1,#normalized do options[#options+1]="raceclass("..string.format("%q",normalized[index])..")" end
        expression="("..table.concat(options," or ")..")"
      end
      if inverse then expression="not ("..expression..")" end
      alternatives[#alternatives+1]=expression
    end
  end
  if #alternatives==0 then return nil end
  return "("..table.concat(alternatives," or ")..")"
end

-- A small number of imported guide packs used the Anniversary item's modern
-- adapter directly.  That adapter is intentionally not exposed on 3.3.5a
-- (doing so changes other addons' feature detection), so lower those safe
-- expressions into the portable condition vocabulary before Runtime sees it.
local function normalizeCondition(value)
  local expression=trim(value)
  expression=expression:gsub("ZGV%.Compat%.Item:GetCount%((%d+)%s*,%s*true%s*%)%.count", "itemcount(%1,true)")
  expression=expression:gsub("ZGV%.Compat%.Item:GetCount%((%d+)%s*%)%.count", "itemcount(%1)")
  expression=expression:gsub("_G%.GetMoney%(%s*%)", "money()")
  expression=expression:gsub("_G%.IsIndoors%(%s*%)", "indoors()")
  expression=expression:gsub("ZGV%.completedQuests%[(%d+)%]", "completedq(%1)")
  -- Old guide files sometimes checked that the quest table entry existed before
  -- looking at its completion member.  Both halves represent the same safe
  -- completion predicate in the 3.3.5a runtime.
  expression=expression:gsub("ZGV%.questsbyid%[(%d+)%]%s+and%s+ZGV%.questsbyid%[%1%]%.complete", "completedq(%1)")
  expression=expression:gsub("ZGV%.questsbyid%[(%d+)%]%.complete", "completedq(%1)")
  return expression
end

local function parseQuest(value)
  local name,id,objective=Parser:ParseID(trim(value):match("^(.-),") or value)
  if not id then
    id,objective=trim(value):match("^(%d+)%s*/%s*(%d+)")
    id,objective=tonumber(id),tonumber(objective)
  end
  return id,objective,name
end

local function parseCount(value)
  value=trim(value)
  local count,rest=value:match("^#(%d+)#%s*(.-)$")
  if not count then count,rest=value:match("^(%d+)!?%s+(.+)$") end
  return tonumber(count),rest
end

local function parseMobs(value)
  local result={}
  for _,raw in ipairs(splitEscaped(value,",")) do
    raw=trim(raw)
    local plural=raw:sub(-1)=="+"
    raw=plural and raw:sub(1,-2) or raw
    local name,id=Parser:ParseID(raw)
    result[#result+1]={name=name,id=id,plural=plural}
  end
  return result
end

local function parseRepCollect(value)
  local fields=splitEscaped(value,",")
  local name,itemID=Parser:ParseID(fields[1] or "")
  return {
    itemName=name, itemID=itemID, count=tonumber(trim(fields[2])),
    reputationAmount=tonumber(trim(fields[3])), reputation=trim(fields[4]),
    standing=trim(fields[5]),
  }
end

local function actionText(action, body, count)
  body=displayText(body)
  local prefixes={
    accept="Accept ", turnin="Turn in ", talk="Talk to ", kill="Kill ",
    collect="Collect ", click="Click ", clicknpc="Click ", buy="Buy ",
    use="Use ", equip="Equip ", unequip="Unequip ", learn="Learn ",
    trainer="Train with ", vendor="Visit ", home="Set your hearthstone to ",
    hearth="Use your hearthstone", fly="Fly to ", taxi="Discover the flight path at ",
    ding="Reach level ", achieve="Earn achievement ", craft="Craft ",
    create="Create ", cast="Cast ", trash="Destroy ", abandon="Abandon ",
    gossip="Select ", gotonpc="Go to ",
  }
  if prefixes[action] then
    if count and count>1 and body~="" and not body:match("^%d") then body=tostring(count).." "..body end
    return trim(prefixes[action]..body)
  end
  return body
end

local function copyValue(value, seen)
  if type(value)~="table" then return value end
  seen=seen or {}
  if seen[value] then return seen[value] end
  local clone={}
  seen[value]=clone
  for key,child in pairs(value) do clone[copyValue(key,seen)]=copyValue(child,seen) end
  return clone
end

-- Parse pipe tags.  Actions are retained separately so a tag-only source line
-- ("|goldcollect ...") creates a real goal instead of disappearing.
function Parser:ParseModifiers(pieces, inheritedMap)
  local mods={tips={},markers={},flags={},actions={},tags={},unsupported={}}
  for index=1,#pieces do
    local segment=trim(pieces[index])
    if segment~="" then
      local command,parameters=splitCommand(segment)
      command=ACTION_ALIASES[command] or command
      local lower=command:lower()
      if ACTIONS[lower] and not (index==1 and lower=="map") then
        mods.actions[#mods.actions+1]={action=lower,body=parameters,raw=segment}
      end
      if lower=="only" then
        mods.onlyIf=addCondition(mods.onlyIf,normalizeCondition(legacyOnlyCondition(parameters)))
      elseif lower=="if" then
        mods.onlyIf=addCondition(mods.onlyIf,normalizeCondition(parameters))
      elseif lower=="stickyif" then
        mods.stickyIf=addCondition(mods.stickyIf,normalizeCondition(parameters))
      elseif lower=="goto" or lower=="ggoto" or lower=="at" then
        mods.destination=self:ParseLocation(parameters,inheritedMap)
      elseif lower=="mapmarker" or lower=="markmaker" then
        local marker=self:ParseLocation(parameters,inheritedMap)
        if marker then mods.markers[#mods.markers+1]=marker end
      elseif lower=="q" or lower=="quest" then
        mods.questID,mods.objective,mods.questName=parseQuest(parameters)
      elseif lower=="tip" then
        mods.tips[#mods.tips+1]=displayText(parameters)
      elseif lower=="complete" or lower=="condition" then
        mods.expression=normalizeCondition(parameters)
      elseif lower=="next" then
        local destination=normalizeGuidePath(parameters)
        if destination=="" then destination="+1" end
        mods.nextJump=destination
        if destination:find("\\",1,true) or destination:match("^id:") then
          local guide,step=destination:match("^(.-)::(.-)$")
          mods.nextGuide=guide or destination
          mods.nextGuideStep=step
        else
          mods.nextLabel=destination
        end
      elseif lower=="loadguide" then
        local destination=normalizeGuidePath(parameters)
        local guide,step=destination:match("^(.-)::(.-)$")
        mods.loadGuide=guide or destination
        mods.loadGuideStep=step
      elseif lower=="achieve" then
        mods.achievementID,mods.achievementObjective=parseQuest(parameters)
      elseif lower=="itemcount" then
        mods.itemCount=parameters
      elseif lower=="skill" then
        mods.skill=parameters
      elseif lower=="skillmax" then
        mods.skillMax=parameters
      elseif lower=="havebuff" then
        mods.haveBuff=parameters
      elseif lower=="nobuff" then
        mods.noBuff=parameters
      elseif lower=="gossip" then
        mods.gossipID=tonumber(parameters) or parameters
      elseif lower=="script" then
        mods.script=parameters
      elseif lower=="autoscript" or lower=="execute" then
        mods.autoscript=parameters
      elseif lower=="updatescript" then
        mods.updateScript=parameters
      elseif lower=="macro" then
        mods.macro=parameters
      elseif lower=="or" then
        mods.orGoal=tonumber(parameters) or 1
      elseif lower=="confirm" then
        mods.confirm=true
      elseif lower=="future" then
        mods.future=true
      elseif lower=="instant" then
        mods.instant=true
      elseif lower=="daily" then
        mods.daily=true
      elseif lower=="repeatable" then
        mods.repeatable=true
      elseif lower=="noobsolete" then
        mods.noObsolete=true
      elseif lower=="more" then
        mods.more=true
      elseif lower=="showtext" then
        mods.showText=true
      elseif lower=="killcount" then
        mods.useKillCount=true
      elseif lower=="sticky" then
        mods.forceSticky=true
        mods.forceStickySaved=parameters:lower()=="saved"
      elseif lower=="important" then
        mods.important=true
      elseif lower=="override" then
        mods.override=true
      elseif lower=="ordcount" then
        mods.ordCount=true
      elseif lower=="noordinal" then
        mods.noOrdinal=true
      elseif lower=="usebank" then
        mods.useBank=true
      elseif lower=="usename" then
        mods.useName,mods.useID=Parser:ParseID(parameters)
      elseif lower=="grouprole" then
        mods.groupRole,mods.groupRole2=parameters:match("^%s*([%a]+)%s+[oO][rR]%s+([%a]+)%s*$")
        mods.groupRole=mods.groupRole or parameters
      elseif lower=="buttonicon" then
        mods.buttonIcon=tonumber(parameters) or 1
      elseif lower=="countexpr" then
        mods.countExpression=parameters
      elseif lower=="model" then
        mods.modelName,mods.modelID=Parser:ParseID(parameters)
      elseif lower=="modelnpc" then
        mods.modelName,mods.modelNPC=Parser:ParseID(parameters)
      elseif lower=="modeldisplay" then
        mods.modelName,mods.modelDisplay=Parser:ParseID(parameters)
      elseif lower=="nomodels" then
        mods.noModels=true
      elseif lower=="simulate" then
        mods.simulate=parameters
      elseif lower=="blizztooltip" then
        mods.blizzTooltip=true
      elseif lower=="n" then
        mods.forceNoComplete=true
      elseif lower=="c" then
        mods.forceComplete=true
      elseif lower=="h" or lower=="hide" then
        mods.hideWhenComplete=true
      elseif lower=="opt" then
        mods.optional=true
      elseif lower=="optional" then
        mods.skipOptional=true
      elseif lower=="required" then
        mods.required=true
      elseif lower=="noway" then
        mods.noWaypoint=true
      elseif lower=="nowayinzone" then
        mods.noWaypointInZone=true
      elseif lower=="notravel" then
        mods.noTravel=true
      elseif lower=="direct" then
        mods.direct=tonumber(parameters) or 200
      elseif lower=="gotoontaxi" then
        mods.gotoOnTaxi=true
      elseif lower=="walk" or lower=="fly" or lower=="zombiewalk" then
        mods.flags[lower]=true
      elseif lower=="invehicle" or lower=="outvehicle" then
        mods.onlyIf=addCondition(mods.onlyIf,lower.."()")
      elseif lower=="indoors" then
        mods.indoors=parameters~="" and parameters or true
      elseif lower=="outdoors" then
        mods.outdoors=true
      elseif lower=="equipped" then
        mods.equipped=parameters
        local _,id=Parser:ParseID(parameters)
        mods.equippedID=id
      elseif lower=="unequipped" or lower=="unequip" then
        mods.unequipped=parameters
        local _,id=Parser:ParseID(parameters)
        mods.unequippedID=id
      elseif lower=="from" or lower=="avoid" then
        mods.mobs=parseMobs(parameters)
        mods.mobSource=lower
      elseif lower=="multiq" then
        mods.multiQuestIDs=self:ParseRanges(parameters,false)
      elseif lower=="autoacceptany" then
        mods.autoAcceptAny=self:ParseRanges(parameters,true)
      elseif lower=="autoturninany" then
        mods.autoTurninAny=self:ParseRanges(parameters,true)
      elseif lower=="noautoaccept" then
        mods.noAutoAccept=true
        if parameters=="inparty" then mods.noAutoAcceptParty=true end
      elseif lower=="noautogossip" then
        mods.noAutoGossip=true
      elseif lower=="notinsticky" then
        mods.notInSticky=true
      elseif lower=="mapicon" then
        mods.mapIcon=parameters
      elseif lower=="delay" then
        mods.delay=tonumber(parameters)
      elseif lower=="goldtracker" then
        mods.goldTracker=true
      elseif lower=="nohearth" then
        mods.noHearth=true
      elseif lower=="travelcfg" then
        local key,value=parameters:match("^(.-)%s*,%s*(.-)$")
        if key then
          mods.travelConfig=mods.travelConfig or {}
          mods.travelConfig[trim(key)]=trim(value):lower()=="true"
        end
      elseif lower=="it" or lower=="they" then
        -- A small number of legacy Wrath lines use a bare pipe as a prose-tip
        -- separator ("Click the rack|It looks like ...") rather than |tip.
        mods.tips[#mods.tips+1]=displayText(command..(parameters~="" and " "..parameters or ""))
      elseif lower=="r" or lower:match("^c%x%x%x%x%x%x%x%x") then
        -- Inline WoW colour markup occasionally occurs inside a legacy DSL
        -- string. It is display text, not an authoring tag.
      -- The first segment is the guide's visible instruction, and is often
      -- ordinary prose (for example, "Destroy the Large Hut").  Only later
      -- pipe-delimited segments are authoring tags, so diagnosing the leading
      -- words as unsupported creates false parser errors for valid guides.
      elseif index>1 and not ACTIONS[lower] and lower~="label" and lower~="title" and lower~="map" and lower~="path" and lower~="step" and lower~="sticky" and lower~="stickystart" and lower~="stickystop" and lower~="blockstart" and lower~="blockend" then
        mods.tags[lower]=parameters~="" and parameters or true
        mods.unsupported[#mods.unsupported+1]=lower
      end
    end
  end
  return mods
end

local function applyModifiers(goal, mods)
  if not goal or not mods then return end
  goal.modifiers=goal.modifiers or mods
  goal.onlyIf=addCondition(goal.onlyIf,mods.onlyIf)
  if mods.stickyIf then goal.stickyIf=addCondition(goal.stickyIf,mods.stickyIf) end
  goal.tips=goal.tips or {}
  for _,tip in ipairs(mods.tips or {}) do goal.tips[#goal.tips+1]=tip end
  if mods.destination then goal.destination=mods.destination end
  if mods.questID then goal.questID,goal.objective=mods.questID,mods.objective end
  if mods.questName then goal.questName=mods.questName end
  if mods.expression and mods.expression~="" then goal.expression=mods.expression end
  if mods.nextJump then goal.next=mods.nextJump; goal.nextJump=mods.nextJump end
  if mods.nextLabel and mods.nextLabel~="" then goal.nextLabel=mods.nextLabel end
  if mods.nextGuide and mods.nextGuide~="" then goal.nextGuide=mods.nextGuide end
  if mods.nextGuideStep and mods.nextGuideStep~="" then goal.nextGuideStep=mods.nextGuideStep end
  if mods.loadGuide and mods.loadGuide~="" then goal.loadGuide=mods.loadGuide end
  if mods.loadGuideStep and mods.loadGuideStep~="" then goal.loadGuideStep=mods.loadGuideStep end
  if mods.achievementID then goal.achievementID,goal.achievementObjective=mods.achievementID,mods.achievementObjective end
  if mods.itemCount then goal.itemCount=mods.itemCount end
  if mods.skill then goal.skillSource=mods.skill end
  if mods.skillMax then goal.skillMaxSource=mods.skillMax end
  if mods.haveBuff then goal.haveBuff=mods.haveBuff end
  if mods.noBuff then goal.noBuff=mods.noBuff end
  if mods.gossipID then goal.gossipID=mods.gossipID end
  if mods.script then goal.script=mods.script end
  if mods.autoscript then goal.autoscript=mods.autoscript end
  if mods.updateScript then goal.updateScript=mods.updateScript end
  if mods.macro then goal.macro=mods.macro end
  if mods.confirm then goal.confirm=true end
  if mods.orGoal then goal.orGoal=mods.orGoal end
  if mods.future then goal.future=true end
  if mods.instant then goal.instant=true; goal.useTitle=true; goal.usetitle=true end
  if mods.daily then goal.daily=true end
  if mods.repeatable then goal.repeatable=true; goal.repeatableQuest=true end
  if mods.noObsolete then goal.noObsolete=true; goal.noobsolete=true end
  if mods.more then goal.more=true end
  if mods.showText then goal.showText=true; goal.showtext=true end
  if mods.useKillCount then goal.useKillCount=true; goal.usekillcount=true end
  if mods.forceSticky then goal.forceSticky=true; goal.force_sticky=true end
  if mods.forceStickySaved then goal.forceStickySaved=true; goal.force_sticky_saved=true end
  if mods.important then goal.important=true; goal.showInBrief=true; goal.showinbrief=true end
  if mods.override then goal.override=true end
  if mods.ordCount then goal.ordCount=true; goal.ordcount=true end
  if mods.noOrdinal then goal.noOrdinal=true; goal.countord=false end
  if mods.useBank then goal.useBank=true; goal.usebank=true end
  if mods.useName then goal.useName,goal.usename=mods.useName,mods.useName end
  if mods.useID then goal.useID,goal.useid=mods.useID,mods.useID end
  if mods.groupRole then goal.groupRole,goal.grouprole=mods.groupRole,mods.groupRole end
  if mods.groupRole2 then goal.groupRole2,goal.grouprole2=mods.groupRole2,mods.groupRole2 end
  if mods.buttonIcon then goal.buttonIcon,goal.buttonicon=mods.buttonIcon,mods.buttonIcon end
  if mods.countExpression then goal.countExpression,goal.countexpr=mods.countExpression,mods.countExpression end
  if mods.modelName then goal.modelName,goal.modelname=mods.modelName,mods.modelName end
  if mods.modelID then goal.model,goal.modelID=mods.modelID,mods.modelID end
  if mods.modelNPC then goal.modelNPC,goal.modelnpc=mods.modelNPC,mods.modelNPC end
  if mods.modelDisplay then goal.modelDisplay,goal.displayinfo=mods.modelDisplay,mods.modelDisplay end
  if mods.noModels then goal.noModels=true; goal.nomodels=true end
  if mods.simulate then goal.simulate=mods.simulate end
  if mods.blizzTooltip then goal.blizzTooltip=true; goal.blizztooltip=true end
  if mods.forceNoComplete then goal.forceNoComplete=true end
  if mods.forceComplete then goal.forceComplete=true end
  if mods.hideWhenComplete then goal.hideWhenComplete=true end
  if mods.optional then goal.optional=true end
  if mods.skipOptional then goal.skipOptional=true end
  if mods.required then goal.required=true end
  if mods.noWaypoint then goal.noWaypoint=true end
  if mods.noWaypointInZone then goal.noWaypointInZone=true end
  if mods.noTravel then goal.noTravel=true end
  if mods.direct then goal.direct=mods.direct end
  if mods.gotoOnTaxi then goal.gotoOnTaxi=true end
  if mods.indoors then goal.indoors=mods.indoors end
  if mods.outdoors then goal.outdoors=true end
  if mods.equippedID then goal.itemID=mods.equippedID end
  if mods.unequippedID then goal.itemID=mods.unequippedID end
  if mods.mobs then goal.mobs,goal.mobSource=mods.mobs,mods.mobSource end
  if mods.multiQuestIDs then goal.multiQuestIDs=mods.multiQuestIDs end
  if mods.autoAcceptAny then goal.autoAcceptAny=mods.autoAcceptAny end
  if mods.autoTurninAny then goal.autoTurninAny=mods.autoTurninAny end
  if mods.noAutoAccept then goal.noAutoAccept=true end
  if mods.noAutoAcceptParty then goal.noAutoAcceptParty=true end
  if mods.noAutoGossip then goal.noAutoGossip=true end
  if mods.notInSticky then goal.notInSticky=true end
  if mods.mapIcon then goal.mapIcon=mods.mapIcon end
  if mods.goldTracker then goal.goldTracker=true end
  for key,value in pairs(mods.flags or {}) do goal[key]=value end
  for key,value in pairs(mods.tags or {}) do goal.tags=goal.tags or {}; goal.tags[key]=value end
end

local function parseSkill(value)
  local name,rank=trim(value):match("^(.-)%s*,%s*(%d+)%s*$")
  return trim(name or value),tonumber(rank)
end

local function applyPetAction(goal,value)
  local name,id=Parser:ParseID(value)
  local wanted=name or (id and tostring(id)) or trim(value)
  goal.petaction,goal.petAction=wanted,wanted
  if name and id then goal.petactionid,goal.petActionID=id,id end
end

function Parser:ParseGoal(base, mods, inheritedMap)
  mods=mods or {tips={},markers={},flags={},actions={}}
  local raw=trim(base)
  local content=raw:gsub("^%.+%s*","")
  if content:sub(1,1)=="'" then content=trim(content:sub(2)) end
  local command,body=splitCommand(content)
  command=ACTION_ALIASES[command] or command
  local action=ACTIONS[command] and command or nil
  local proseLeadingAction=not action
  local actionBody=body

  -- A source line can begin with descriptive prose and introduce the actual
  -- action via a pipe tag ("Train abilities |trainer ...").
  if not action then
    for _,tag in ipairs(mods.actions or {}) do
      if tag.action~="complete" and tag.action~="condition" and tag.action~="map" and tag.action~="goldtracker" then
        action,actionBody=tag.action,tag.body
        break
      end
    end
  end
  action=action or "text"

  local count,objectBody
  if COUNT_ACTIONS[action] then count,objectBody=parseCount(actionBody) end
  if objectBody and objectBody~="" then actionBody=objectBody end
  local name,id,objective=self:ParseID(actionBody)
  local plural=trim(actionBody):sub(-1)=="+"
  local displayBody=name or actionBody:gsub("%+$","")
  local goal={
    action=action, raw=raw, legacy=raw:match("^%.")~=nil or raw:match("^'")~=nil,
    count=count, exact=trim(body):match("^%d+!")~=nil, plural=plural,
    text=action=="text" and displayText(content) or actionText(action,displayBody,count),
    target=name, targetID=id, sourceBody=actionBody,
  }
  -- Authored hearth steps often use a separate `use Hearthstone` goal plus a
  -- prose/condition line. Preserve the named destination so Runtime can
  -- compare it with the live GetBindLocation result before offering the item.
  local hearthDestination=content:match("^[Hh]earth%s+to%s+(.+)$")
  if hearthDestination then goal.hearthDestination=displayText(hearthDestination) end

  if QUEST_ACTIONS[action] then
    goal.questID=id
  elseif ITEM_ACTIONS[action] then
    goal.itemID=id
  elseif NPC_ACTIONS[action] then
    goal.npcID=id
  elseif action=="click" then
    goal.objectID=id
  elseif action=="learn" or action=="cast" or action=="havebuff" or action=="nobuff" then
    goal.spellID=id
  elseif action=="petaction" then
    applyPetAction(goal,actionBody)
  elseif action=="achieve" then
    goal.achievementID=id
  elseif action=="earn" then
    local amount,currency=parseCount(actionBody)
    local _,currencyID=self:ParseID(currency or actionBody)
    goal.count=amount or goal.count or 1
    goal.currencyID=currencyID or id
  elseif action=="home" then
    goal.homeName=displayBody
  elseif action=="hearth" then
    goal.hearthZone=displayBody
  elseif action=="discover" then
    goal.discoverZone=displayBody:gsub("^[Tt]he%s+","")
  elseif action=="taxi" or action=="fly" then
    goal.travelTarget=displayBody
  elseif action=="complete" or action=="condition" then
    goal.expression=normalizeCondition(actionBody)
  elseif action=="ding" then
    goal.level=tonumber(actionBody:match("(%d+)"))
  elseif action=="skill" or action=="skillmax" then
    goal.skillName,goal.skillRank=parseSkill(actionBody)
  elseif action=="goto" then
    goal.destination=self:ParseLocation(actionBody,inheritedMap)
    goal.text=goal.destination and ("Go to "..tostring(goal.destination.map or "destination")) or displayText(actionBody)
  elseif action=="map" then
    goal.destination=self:ParseLocation(actionBody,inheritedMap)
  elseif action=="gossip" then
    goal.gossipText=displayText(actionBody):gsub('^"',''):gsub('"$','')
  elseif action=="gotonpc" then
    goal.npcName=actionBody
    goal.optional=true
  elseif action=="repcollect" then
    local data=parseRepCollect(actionBody)
    goal.itemID,goal.count=data.itemID,data.count
    goal.repFaction,goal.repStanding=data.reputation,data.standing
    goal.reputationAmount=data.reputationAmount
    goal.text=goal.text~="" and goal.text or ("Collect "..tostring(data.itemName or "reputation items"))
  elseif action=="rep" then
    local faction,standing=actionBody:match("^(.-)%s*,%s*(.-)%s*$")
    goal.repFaction,goal.repStanding=trim(faction),trim(standing)
  elseif action=="goldtracker" then
    goal.forceNoComplete=true
  end

  applyModifiers(goal,mods)
  -- Modifier actions use the same source data as leading actions but do not
  -- override an explicit leading command.  Their parsed fields still matter.
  for _,tag in ipairs(mods.actions or {}) do
    if tag.action=="goto" then
      goal.destination=goal.destination or self:ParseLocation(tag.body,inheritedMap)
    elseif tag.action=="repcollect" then
      local data=parseRepCollect(tag.body)
      goal.itemID=goal.itemID or data.itemID
      goal.count=goal.count or data.count
      goal.repFaction=goal.repFaction or data.reputation
      goal.repStanding=goal.repStanding or data.standing
    elseif tag.action=="havebuff" then
      local display,spellID=self:ParseID(tag.body)
      if not goal.haveBuff or goal.haveBuff==tag.body then goal.haveBuff=spellID or display or tag.body end
      goal.spellID=goal.spellID or spellID
      if goal.action=="text" then goal.action="havebuff" end
    elseif tag.action=="nobuff" then
      local display,spellID=self:ParseID(tag.body)
      if not goal.noBuff or goal.noBuff==tag.body then goal.noBuff=spellID or display or tag.body end
      goal.spellID=goal.spellID or spellID
      if goal.action=="text" then goal.action="nobuff" end
    elseif tag.action=="petaction" then
      if not goal.petaction then applyPetAction(goal,tag.body) end
      if goal.action=="text" or (goal.action=="use" and not goal.itemID) then goal.action="petaction" end
    elseif tag.action=="skill" or tag.action=="skillmax" then
      goal.skillName,goal.skillRank=parseSkill(tag.body)
      if goal.action=="text" then goal.action=tag.action end
    elseif tag.action=="complete" or tag.action=="condition" then
      goal.expression=goal.expression or tag.body
    elseif tag.action=="gossip" then
      goal.gossipText=goal.gossipText or displayText(tag.body)
    elseif tag.action=="equipped" then
      local _,itemID=self:ParseID(tag.body)
      goal.itemID=goal.itemID or itemID
      if goal.action=="text" then goal.action="equip" end
    elseif tag.action=="unequip" then
      local _,itemID=self:ParseID(tag.body)
      goal.itemID=goal.itemID or itemID
      if goal.action=="text" then goal.action="unequip" end
    end
  end

  if goal.action=="text" and goal.questID then goal.action="goal" end
  if goal.action=="text" and goal.expression then goal.action="complete" end
  if goal.action=="text" and goal.haveBuff then goal.action="havebuff" end
  if goal.action=="text" and goal.noBuff then goal.action="nobuff" end
  if goal.action=="text" and goal.destination and goal.text=="" then goal.action="goto" end
  -- A bare named kill is guidance rather than a measurable objective in the
  -- source grammar.  Counted NPC kills remain trackable through combat; an
  -- uncounted one must not become an impossible automatic gate.
  if goal.action=="kill" and not goal.questID and not goal.count then goal.forceNoComplete=true end
  if goal.action=="collect" and (content:lower():match("^goldcollect%s") or mods.goldTracker) then goal.goldCollect=true end
  if goal.goldCollect then goal.forceNoComplete=goal.forceNoComplete~=false end
  if proseLeadingAction and content~="" and action~="text" then goal.text=displayText(content) end
  if goal.text=="" then goal.text=displayText(raw) end
  annotateCityTransition(goal)
  return goal
end

local function parseIncludeArguments(value)
  value=value:gsub("\\,","%%ZGV_COMMA%%"):gsub('\\"',"%%ZGV_QUOTE%%")
  local fields=splitEscaped(value,",")
  local title=unquote(fields[1] or "")
  local params={}
  for index=2,#fields do
    local key,item=fields[index]:match("^%s*(.-)%s*=%s*\"(.-)\"%s*$")
    if key then
      params[trim(key)]=item:gsub("%%ZGV_COMMA%%",","):gsub("%%ZGV_QUOTE%%",'"')
    end
  end
  return title,params
end

function Parser:ExpandIncludes(body, guide, depth)
  depth=depth or 0
  if depth>=20 then
    guide.parseIssues[#guide.parseIssues+1]="include nesting exceeds 20"
    return ""
  end
  local lines={}
  for source in (tostring(body or "").."\n"):gmatch("(.-)\r?\n") do
    local include=source:match("^%s*#include%s+(.+)%s*$")
    if include then
      local name,params=parseIncludeArguments(include)
      local data=ZGV.Catalog.includes[name]
      if type(data)=="string" then
        data=data:gsub("%%(%w+)%%",function(key) return params[key] or "" end)
        lines[#lines+1]=self:ExpandIncludes(data,guide,depth+1)
      else
        guide.parseIssues[#guide.parseIssues+1]="missing include: "..tostring(name)
      end
    else
      lines[#lines+1]=source
    end
  end
  return table.concat(lines,"\n")
end

local function cloneStep(step, parentGuide, number)
  local copy=copyValue(step)
  copy.parentGuide=parentGuide
  copy.number,copy.num=number,number
  copy.leeched=true
  for index,goal in ipairs(copy.goals or {}) do
    goal.parentGuide=parentGuide
    goal.parentStep=copy
    goal.num=index
  end
  return copy
end

local function parsePath(parser, step, parameters, inheritedMap, previousPath)
  step.waypath=step.waypath or {follow="loose",loop=true,ants="straight",coords={}}
  for key,value in pairs(previousPath) do if step.waypath[key]==nil then step.waypath[key]=value end end
  local normal=parameters:gsub("^%+%s*",""):gsub("%s*[\t;]+%s*",";"):gsub("  +",";")
  for _,entry in ipairs(splitEscaped(normal,";")) do
    entry=trim(entry)
    if entry~="" then
      local point=parser:ParseLocation(entry,inheritedMap)
      if point and point.x and point.y then
        point.distance=point.distance or step.waypath.distance
        step.waypath.coords[#step.waypath.coords+1]=point
        inheritedMap=point
      else
        local key,value=entry:match("^(%S+)%s*(.-)$")
        value=trim(value)
        if value=="" then value=true elseif value=="on" then value=true elseif value=="off" then value=false else value=tonumber(value) or value end
        if key:sub(1,1)=="<" and #step.waypath.coords>0 then
          step.waypath.coords[#step.waypath.coords][key:sub(2)]=value
        else
          step.waypath[key]=value
          previousPath[key]=value
        end
        if key=="radius" then step.waypath.distance=value end
      end
    end
  end
  return inheritedMap
end

function Parser:ParseHeader(value)
  if type(value)=="table" and value.header then
    value=value.header
  end
  if type(value)=="table" then
    local copy={}
    for key,item in pairs(value) do copy[key]=item end
    return copy
  end
  local header={}
  for raw in (tostring(value or "").."\n"):gmatch("(.-)\r?\n") do
    local line=stripComment(raw):gsub("||","|")
    local command,parameters=splitCommand(line)
    if command=="step" then break end
    if command~="" then
      if header[command] and command=="description" then header[command]=header[command].."\n"..parameters
      else header[command]=parameters end
    end
  end
  if header.guide then header.title=header.guide; header.guide=nil end
  return header
end

function Parser:ParseEntry(guide, fullyParse, stack)
  if type(guide)=="string" then
    guide={id="raw",title="Raw guide",raw=guide,header={}}
  end
  if type(guide)~="table" then return nil,"No guide" end
  if guide.rawdata and not guide.raw then guide.raw=guide.rawdata end
  if type(guide.raw)~="string" then return nil,"No text" end
  return self:_ParseGuide(guide,stack)
end

function Parser:_ParseGuide(guide, stack)
  stack=stack or {}
  if stack[guide] then return nil,"recursive guide reference" end
  stack[guide]=true
  guide.steps={}
  guide.labels={}
  guide.labelSteps={}
  guide.stepBlocks={}
  guide.meta={}
  guide.parseIssues={}
  guide.parseStats={}
  local header=self:ParseHeader(guide.header)
  guide.header=header
  for key,value in pairs(header) do
    if type(value)=="string" and key:match("^condition_") then
      value=normalizeCondition(value)
      header[key]=value
    end
    guide.meta[key]=value
  end
  -- Header registration is deferred until a guide is parsed because content
  -- packs load before the viewer's optional detector module on 3.3.5a.
  if ZGV.CreatureDetector and ZGV.CreatureDetector.RegisterGuideHeader then
    ZGV.CreatureDetector:RegisterGuideHeader(guide)
  end

  local body=self:ExpandIncludes(guide.raw,guide)
  local current,lastGoal,lastMap
  local openStickies,stickyOrder,usedStickies={},{},{}
  local autoSticky,autoStickyNumber=nil,0
  local previousPath={}
  local openBlocks={}
  local stickyStarts,stickyStops=0,0
  local lineNumber=0

  local function issue(message)
    guide.parseIssues[#guide.parseIssues+1]="line "..tostring(lineNumber)..": "..message
  end

  local function nextAutoSticky()
    autoStickyNumber=autoStickyNumber+1
    autoSticky="__sticky_"..tostring(autoStickyNumber)
    return autoSticky
  end

  local function closeSticky(label)
    if not label or not openStickies[label] then return false end
    openStickies[label]=nil
    for index=#stickyOrder,1,-1 do if stickyOrder[index]==label then tremove(stickyOrder,index) end end
    return true
  end

  local function openSticky(label)
    if not label or label=="" then label=nextAutoSticky() end
    autoSticky=label
    if not openStickies[label] then
      openStickies[label]=true
      usedStickies[label]=true
      stickyOrder[#stickyOrder+1]=label
      stickyStarts=stickyStarts+1
    end
    return label
  end

  local function assignLabel(value)
    if not current then return end
    local label=unquote(value)
    if label=="" then return end
    if current.label and current.label~=label then
      current.extraLabels=current.extraLabels or {}
      current.extraLabels[#current.extraLabels+1]=label
    else
      current.label=label
    end
    -- The Classic format allows the same label to occur repeatedly.  Keep
    -- every occurrence for nearest/forward/backward `|next` jumps while
    -- retaining `labels` as the historical single-value convenience map.
    local entries=guide.labelSteps[label] or {}
    entries[#entries+1]=current.number
    guide.labelSteps[label]=entries
    guide.labels[label]=current.number
    if closeSticky(label) then stickyStops=stickyStops+1 end
    if usedStickies[label] then current.isSticky=true end
    if current.stickyLabels then
      for index=#current.stickyLabels,1,-1 do
        if current.stickyLabels[index]==label then tremove(current.stickyLabels,index) end
      end
      if #current.stickyLabels==0 then current.stickyLabels=nil end
    end
    autoSticky=label
  end

  local function addStep(comment,label)
    current={
      number=#guide.steps+1, num=#guide.steps+1, goals={}, markers={}, rawLines={},
      comment=comment, parentGuide=guide,
      map=lastMap and lastMap.map or nil, floor=lastMap and lastMap.floor or 0,
    }
    guide.steps[#guide.steps+1]=current
    lastGoal=nil
    if label and label~="" then assignLabel(label) end
    if #stickyOrder>0 then
      current.stickyLabels={}
      for _,sticky in ipairs(stickyOrder) do
        if sticky~=current.label then current.stickyLabels[#current.stickyLabels+1]=sticky end
      end
      if #current.stickyLabels==0 then current.stickyLabels=nil end
    end
  end

  local function addMarkers(mods)
    if not current then return end
    for _,marker in ipairs(mods.markers or {}) do current.markers[#current.markers+1]=marker end
  end

  local function addGoal(goal, mods)
    if not current or not goal then return end
    goal.parentGuide=guide
    goal.parentStep=current
    goal.num=#current.goals+1
    current.goals[#current.goals+1]=goal
    lastGoal=goal
    if goal.hearthDestination then current.hearthDestination=goal.hearthDestination end
    if goal.questID then
      if goal.daily then
        ZGV.dailyQuests=ZGV.dailyQuests or {}
        ZGV.dailyQuests[goal.questID]=true
      end
      if goal.instant then
        ZGV.instantQuests=ZGV.instantQuests or {}
        ZGV.instantQuests[goal.questID]=true
      end
      if goal.noObsolete then
        guide.noObsoleteQuests=guide.noObsoleteQuests or {}
        guide.noObsoleteQuests[goal.questID]=true
      end
    end
    if goal.destination then
      lastMap=goal.destination
      current.map,current.floor=goal.destination.map,goal.destination.floor
    end
    addMarkers(mods)
  end

  local function leech(parameters)
    local target,block=parameters:match('^%s*"(.-)"%s*"(.-)"%s*$')
    local first,last
    if not target then target,first,last=parameters:match('^%s*"(.-)"%s*(%d+)%s*%-%s*(%d+)%s*$') end
    if not target then target=unquote(parameters) end
    target=normalizeGuidePath(target)
    local source=ZGV.Catalog and ZGV.Catalog:Get(target)
    if not source then issue("missing leechsteps target: "..tostring(target)); return end
    local parsed,errorMessage=self:_ParseGuide(source,stack)
    if not parsed then issue("leechsteps: "..tostring(errorMessage)); return end
    if block and block~="" then
      local range=parsed.stepBlocks and parsed.stepBlocks[block]
      if not range then issue("leeched named block not found: "..block); return end
      first,last=range[1],range[2]
    end
    first,last=tonumber(first) or 1,tonumber(last) or #parsed.steps
    for index=first,math.min(last,#parsed.steps) do
      local sourceStep=parsed.steps[index]
      if sourceStep then
        local copied=cloneStep(sourceStep,guide,#guide.steps+1)
        guide.steps[#guide.steps+1]=copied
        if copied.label then
          guide.labels[copied.label]=copied.number
          guide.labelSteps[copied.label]=guide.labelSteps[copied.label] or {}
          guide.labelSteps[copied.label][#guide.labelSteps[copied.label]+1]=copied.number
        end
        for _,label in ipairs(copied.extraLabels or {}) do
          guide.labels[label]=copied.number
          guide.labelSteps[label]=guide.labelSteps[label] or {}
          guide.labelSteps[label][#guide.labelSteps[label]+1]=copied.number
        end
        current=copied
        lastGoal=copied.goals[#copied.goals]
        if copied.map then lastMap={map=copied.map,floor=copied.floor,mapKey=ZGV:CanonicalMapKey(copied.map,copied.floor)} end
      end
    end
  end

  for sourceLine in (body.."\n"):gmatch("(.-)\r?\n") do
    lineNumber=lineNumber+1
    local original=sourceLine
    local line=stripComment(sourceLine)
    if line~="" then
      local indent
      indent,line=line:match("^(%.*)%s*(.-)$")
      local hadAsterisk=line:match("^%s*%*%s*")~=nil
      line=line:gsub("^%*%s*",""):gsub("^|%s*","")
      local leadingPipe=sourceLine:match("^%s*%.?%s*%*?%s*|")~=nil
      local baseBeforePipes=trim(splitEscaped(line,"|")[1] or "")
      local sourceCommand,sourceParameters=splitCommand(baseBeforePipes)
      sourceCommand=ACTION_ALIASES[sourceCommand] or sourceCommand

      if sourceCommand=="step" then
        local comment=original:match("^%s*%.?step%s*//%s*(.-)%s*$")
        local label=trim(sourceParameters)
        if label:match("^/") or label:match("^%d+$") then label=nil end
        addStep(comment,label)
      elseif sourceCommand=="leechsteps" then
        leech(sourceParameters)
      elseif sourceCommand=="stickystart" then
        -- Stickies can intentionally open before the first step.  This is
        -- common in the level ranges that start with a short optional turn-in.
        openSticky(unquote(sourceParameters))
      elseif sourceCommand=="stickystop" then
        local label=unquote(sourceParameters)
        if label=="" then label=autoSticky end
        if closeSticky(label) then stickyStops=stickyStops+1 else issue("stickystop without open sticky: "..tostring(label or "(implicit)")) end
        autoSticky=nil
      elseif not current then
        if sourceCommand~="" then
          local value=sourceParameters
          if sourceCommand=="description" and guide.meta.description then value=guide.meta.description.."\n"..value end
          if sourceCommand:match("^condition_") then value=normalizeCondition(value) end
          if sourceCommand=="startlevel" or sourceCommand=="endlevel" then value=tonumber(value) or value end
          guide.meta[sourceCommand]=value
          -- Legacy Wrath files keep their header in the DSL body rather than
          -- the RegisterGuide table.  Publish it through the same header
          -- contract as table-style guides so menu filtering and suggestions
          -- do not lose defaultfor/condition metadata.
          if sourceCommand=="description" and guide.header.description then
            guide.header.description=guide.header.description.."\n"..sourceParameters
          elseif guide.header[sourceCommand]==nil then
            guide.header[sourceCommand]=value
          end
        end
      else
        current.rawLines[#current.rawLines+1]=original
        local pieces=splitEscaped(line,"|")
        if leadingPipe then tinsert(pieces,1,"") end
        local base=trim(pieces[1] or "")
        local mods=self:ParseModifiers(pieces,lastMap)
        if #mods.unsupported>0 then issue("unsupported guide tag(s): "..table.concat(mods.unsupported,", ")) end
        local directive,parameters=splitCommand(base)
        directive=ACTION_ALIASES[directive] or directive
        local handled=false

        if directive=="stickystart" then
          openSticky(unquote(parameters))
          handled=true
        elseif directive=="stickystop" then
          local label=unquote(parameters)
          if label=="" then label=autoSticky end
          if closeSticky(label) then stickyStops=stickyStops+1 else issue("stickystop without open sticky: "..tostring(label or "(implicit)")) end
          autoSticky=nil
          handled=true
        elseif directive=="sticky" and #mods.actions==0 then
          if not current.label then assignLabel(autoSticky or nextAutoSticky()) end
          local label=current.label
          if current.isSticky then
            -- A matching labelled step already closed stickystart.
          elseif label and closeSticky(label) then
            current.isSticky=true; stickyStops=stickyStops+1
          elseif label then
            current.isSticky=true; openStickies[label]=true; usedStickies[label]=true
            stickyOrder[#stickyOrder+1]=label; stickyStarts=stickyStarts+1
          end
          if trim(parameters):lower()=="only" then current.isStickyOnly=true end
          handled=true
        elseif directive=="label" then
          assignLabel(parameters)
          handled=true
        elseif directive=="title" then
          current.title=parameters:gsub("^%+%s*","")
          handled=true
        elseif directive=="only" or directive=="if" then
          current.onlyIf=addCondition(current.onlyIf,mods.onlyIf)
          handled=true
        elseif directive=="map" and #mods.actions==0 then
          local location=self:ParseLocation(parameters,lastMap)
          if location then
            lastMap=location; current.map,current.floor=location.map,location.floor
          else issue("unknown map syntax: "..parameters) end
          handled=true
        elseif directive=="path" then
          lastMap=parsePath(self,current,parameters,lastMap,previousPath) or lastMap
          handled=true
        elseif directive=="blockstart" then
          local name=unquote(parameters)
          if name~="" then openBlocks[name]=current.number; current.blockstart=name end
          handled=true
        elseif directive=="blockend" then
          local name=unquote(parameters)
          if name~="" and openBlocks[name] then
            guide.stepBlocks[name]={openBlocks[name],current.number}; openBlocks[name]=nil
          end
          current.blockend=name
          handled=true
        elseif directive=="travelfor" then
          current.travelFor=tonumber(parameters) or parameters
          handled=true
        elseif directive=="delay" and #mods.actions==0 then
          current.delay=tonumber(parameters)
          handled=true
        elseif directive=="travelcfg" then
          current.travelConfig=mods.travelConfig or current.travelConfig
          handled=true
        elseif directive=="nohearth" then
          current.travelConfig=current.travelConfig or {}; current.travelConfig.use_hearth=false
          handled=true
        end

        if not handled and base=="" and #mods.actions==0 then
          -- A leading pipe makes a standalone modifier a step modifier.  This
          -- is the old parser's chunk-count behaviour and is vital for the
          -- legacy Wrath packs' standalone "only Race" lines.
          -- `|nohearth |only if ...` is different: the condition scopes the
          -- travel restriction, not the quest goal or the whole step.  If it
          -- leaks into either applicability check, leaving the named subzone
          -- can skip an unfinished objective (notably the Bladespire half of
          -- A Curse Upon Both of Your Clans) and jump directly to turn-in.
          local travelOnly=mods.noHearth and true or false
          if not travelOnly then
            current.onlyIf=addCondition(current.onlyIf,mods.onlyIf)
            current.stickyIf=addCondition(current.stickyIf,mods.stickyIf)
          end
          if mods.delay then current.delay=mods.delay end
          if mods.noHearth then
            current.travelConfig=current.travelConfig or {}
            current.travelConfig.use_hearth=false
            current.travelConfig.noHearthIf=mods.onlyIf
          end
          addMarkers(mods)
          if lastGoal and not travelOnly then
            applyModifiers(lastGoal,mods)
            if lastGoal.questID then
              if lastGoal.daily then ZGV.dailyQuests=ZGV.dailyQuests or {}; ZGV.dailyQuests[lastGoal.questID]=true end
              if lastGoal.instant then ZGV.instantQuests=ZGV.instantQuests or {}; ZGV.instantQuests[lastGoal.questID]=true end
              if lastGoal.noObsolete then
                guide.noObsoleteQuests=guide.noObsoleteQuests or {}
                guide.noObsoleteQuests[lastGoal.questID]=true
              end
            end
          end
          handled=true
        end

        if not handled then
          local goal=self:ParseGoal(base,mods,lastMap)
          -- A text goal with bracketed coordinates is a classic waypointed
          -- note.  Retain its prose while supplying the first coordinate as
          -- a navigation target.
          if not goal.destination then
            local waypoint=base:match("%[(.-)%]")
            if waypoint then goal.destination=self:ParseLocation(waypoint,lastMap) end
          end
          if goal.action=="talk" and not goal.destination and lastGoal and lastGoal.destination and (lastGoal.action=="goto" or lastGoal.action=="text") then
            goal.destination=lastGoal.destination
          end
          if goal.action=="gossip" and lastGoal and lastGoal.action=="talk" then
            goal.npcID=goal.npcID or lastGoal.npcID
            goal.destination=goal.destination or lastGoal.destination
          end
          if hadAsterisk then goal.showInBrief=true; goal.showinbrief=true end
          if #indent>0 then goal.indent=#indent end
          addGoal(goal,mods)
        end
      end
    end
  end

  for name,first in pairs(openBlocks) do guide.stepBlocks[name]={first,#guide.steps} end
  local stickyReferences,resolvedStickies=0,0
  for _,step in ipairs(guide.steps) do
    if step.stickyLabels then
      step.stickies={}
      for _,label in ipairs(step.stickyLabels) do
        stickyReferences=stickyReferences+1
        local number=guide.labels[label]
        local sticky=number and guide.steps[number]
        if sticky and sticky.isSticky then
          step.stickies[#step.stickies+1]=sticky
          resolvedStickies=resolvedStickies+1
        else
          issue("sticky label not found: "..tostring(label).." (step "..tostring(step.number)..")")
        end
      end
      if #step.stickies==0 then step.stickies=nil end
    end
  end
  if #guide.steps==0 then issue("guide has no steps") end
  guide.next=normalizeGuidePath(header.next or guide.meta.next or "")
  if guide.next=="" then
    guide.next=nil
  else
    local nextGuide,nextStep=guide.next:match("^(.-)::(.-)$")
    if nextGuide then guide.next,guide.nextStep=nextGuide,nextStep end
  end
  guide.parseStats={
    lines=lineNumber,steps=#guide.steps,stickyStarts=stickyStarts,stickyStops=stickyStops,
    stickyReferences=stickyReferences,resolvedStickies=resolvedStickies,unclosedStickies=#stickyOrder,
  }
  guide.parsed=true
  guide.parsing=nil
  stack[guide]=nil
  self.cache[guide.id or guide.title]=guide
  return guide
end

function Parser:ParseGuide(idOrGuide, stack)
  local guide=ZGV.Catalog and ZGV.Catalog:Get(idOrGuide) or (type(idOrGuide)=="table" and idOrGuide)
  if not guide then return nil,"guide not found" end
  if guide.parsed then return guide end
  if guide.parsing then return nil,"recursive guide reference" end
  guide.parsing=true
  local parsed,errorMessage=self:_ParseGuide(guide,stack)
  guide.parsing=nil
  return parsed,errorMessage
end

function Parser:ReleaseGuide(guide)
  guide=(ZGV.Catalog and ZGV.Catalog:Get(guide)) or guide
  if not guide then return end
  self.cache[guide.id or guide.title]=nil
  guide.steps=nil; guide.labels=nil; guide.stepBlocks=nil
  guide.parsed=false; guide.parsing=nil
end

function Parser:ParseAll()
  local result={total=0,parsed=0,failed=0,issues={}}
  local guides=ZGV.Catalog and ZGV.Catalog.sorted or {}
  for index=1,#guides do
    local guide=guides[index]
    result.total=result.total+1
    local parsed,errorMessage=self:ParseGuide(guide)
    if parsed then
      result.parsed=result.parsed+1
      for _,message in ipairs(parsed.parseIssues or {}) do result.issues[#result.issues+1]={guide=parsed.title,message=message} end
    else
      result.failed=result.failed+1
      result.issues[#result.issues+1]={guide=guide.title,message=errorMessage}
    end
  end
  return result
end

-- Compatibility entry points used by legacy guide utilities and external
-- content.  They delegate to this parser rather than maintaining a second DSL
-- implementation with subtly different grammar.
ZGV.ParseID=function(_,value) return Parser:ParseID(value) end
ZGV.ParseMapXYDist=function(_,value) return Parser:ParseMapXYDist(value) end
ZGV.ParseHeader=function(_,value) return Parser:ParseHeader(value) end
ZGV.ParseEntry=function(_,value) return Parser:ParseEntry(value,true) end
ZGV.GuideParser=Parser
