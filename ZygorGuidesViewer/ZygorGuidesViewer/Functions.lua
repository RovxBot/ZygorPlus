-- Shared utility surface used by the Classic viewer.  Keep this deliberately
-- Lua 5.1 / 3.3.5a-safe: these helpers are consumed by the ported skin and
-- guide modules as well as by content packs.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local unpack = unpack or table.unpack
local tinsert, tremove = table.insert, table.remove
local F = ZGV.F or {}
ZGV.F = F

function ZGV.TableKeys(tab)
  local result={}
  for key in pairs(tab or {}) do result[#result+1]=key end
  return result
end
_G.TableKeys = _G.TableKeys or function(tab) return ZGV.TableKeys(tab) end

table.zygor_join = table.zygor_join or function(first,second)
  local result={}
  for _,value in ipairs(first or {}) do result[#result+1]=value end
  for _,value in ipairs(second or {}) do result[#result+1]=value end
  return result
end

function ZGV.CloneTable(subject,into)
  into=into or {}
  if type(subject)~="table" then return into end
  for key,value in pairs(subject) do into[key]=value end
  return into
end

function ZGV.MergeTable(subject,into)
  into=into or {}
  if type(subject)~="table" then return into end
  for key,value in pairs(subject) do
    if type(value)=="table" then into[key]=ZGV.MergeTable(value,type(into[key])=="table" and into[key] or {})
    else into[key]=value end
  end
  return into
end

function F.DeepCopy(subject,seen)
  if type(subject)~="table" then return subject end
  seen=seen or {}
  if seen[subject] then return seen[subject] end
  local copy={}; seen[subject]=copy
  for key,value in pairs(subject) do copy[F.DeepCopy(key,seen)]=F.DeepCopy(value,seen) end
  return setmetatable(copy,getmetatable(subject))
end

function ZGV.MOVE(frame)
  if not frame then return end
  frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self) if not ZGV:IsPlayerInCombat() then self:StartMoving() end end)
  frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
  return frame
end

function ZGV.RotatePair(x,y,ox,oy,angle,aspect)
  aspect=aspect or 1; angle=angle or 0
  local sin,cos=math.sin(angle),math.cos(angle)
  x,y=(x or 0)-(ox or 0),(y or 0)-(oy or 0)
  return (ox or 0)+(x*cos-y*sin*aspect),(oy or 0)+(x*sin/aspect+y*cos)
end

function ZGV.RotateTex(texture,angle)
  if not texture or not texture.SetTexCoord then return end
  local c,s=math.cos(angle or 0)*.5,math.sin(angle or 0)*.5
  texture:SetTexCoord(.5-c-s,.5+c-s,.5-c+s,.5+c+s)
end

function ZGV.AnimRotOnUpdate(frame,step)
  frame.angle=(frame.angle or 0)+(step or .03)
  return ZGV.RotateTex(frame,frame.angle)
end
function ZGV.AnimRotOnUpdate2(frame) return ZGV.AnimRotOnUpdate(frame,(frame.elapsed or .03)*2) end

-- Kept as globals because the original UIDropDownFork templates invoke them
-- by name.  3.3.5 does not suffer the later frame-level regression, but
-- retaining the handlers prevents a missing-script error for imported skins.
function _G.FixDropDownMenuFrameLevelBug() end
function _G.FixDropDownMenuFrameLevelBug_List_OnShow() end
function _G.BigFixDropDownMenuFrameLevelBug() end

function F.SetNPHtx(button,normal,pushed,highlight)
  if not button then return end
  if normal then button:SetNormalTexture(normal) end
  if pushed then button:SetPushedTexture(pushed) end
  if highlight then button:SetHighlightTexture(highlight) end
end

function F.SetSpriteTexCoord(object,x,width,y,height)
  if not object or not object.SetTexCoord then return end
  x,width,y,height=tonumber(x) or 0,tonumber(width) or 1,tonumber(y) or 0,tonumber(height) or 1
  object:SetTexCoord(x,y,x+width,y+height)
end

-- The viewer's button atlases have four vertical state rows.  Keep this
-- implementation here as well as in ModernBridge so files loaded later can
-- use the historical Functions.lua API without white-square fallbacks.
function F.AssignButtonTexture(button,texture,number,count,flip)
  if not button or not texture then return end
  number,count=tonumber(number) or 1,tonumber(count) or 1
  local left,right=(number-1)/count,number/count
  local function region(getter,setter)
    local value=getter and getter(button)
    if not value and setter then setter(button,"Interface\\Buttons\\WHITE8X8"); value=getter(button) end
    return value
  end
  local function apply(value,row)
    if not value then return end
    value:SetTexture(texture)
    if flip then value:SetTexCoord(right,left,(row-1)/4,row/4) else value:SetTexCoord(left,right,(row-1)/4,row/4) end
  end
  apply(region(button.GetNormalTexture,button.SetNormalTexture),1)
  apply(region(button.GetPushedTexture,button.SetPushedTexture),2)
  apply(region(button.GetHighlightTexture,button.SetHighlightTexture),3)
  apply(region(button.GetDisabledTexture,button.SetDisabledTexture),4)
end

function F.fromRGB_a(color,alpha) return color and color[1] or 1,color and color[2] or 1,color and color[3] or 1,alpha==nil and (color and color[4] or 1) or alpha end
function F.fromRGBA(color) return F.fromRGB_a(color) end
function F.fromRGBmul_a(color,multiplier,alpha)
  multiplier=multiplier or 1
  local r,g,b,a=F.fromRGB_a(color,alpha)
  return r*multiplier,g*multiplier,b*multiplier,a
end
function F.fromRGB(color) local r,g,b=F.fromRGB_a(color); return r,g,b end
function F.mix(a,b,percentage) return (a or 0)+((b or 0)-(a or 0))*(percentage or 0) end
function F.mix4(a,b,c,d,u,v,w,x) return F.mix(a,u,x),F.mix(b,v,x),F.mix(c,w,x),F.mix(d,x,x) end

function ZGV.Benchmark(func,count)
  local started=debugprofilestop and debugprofilestop() or 0
  local result
  for index=1,(tonumber(count) or 1) do result=func(index) end
  return (debugprofilestop and debugprofilestop()-started or 0),result
end

function ZGV.AllCall(list)
  return setmetatable({}, {__index=function(_,key)
    return function(_, ...)
      for _,object in ipairs(list or {}) do local fn=object and object[key]; if type(fn)=="function" then fn(object,...) end end
    end
  end})
end

function ZGV.GetTargetId() return ZGV.GetUnitId("target") end
function ZGV.GetUnitId(unit)
  local guid=type(UnitGUID)=="function" and UnitGUID(unit)
  if type(guid)~="string" then return nil end
  return tonumber(guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")) or tonumber(guid:sub(7,10),16)
end

function ZGV.FormatLevel(level,mono)
  level=tonumber(level)
  if not level then return "" end
  local label=(mono and "|cffdddddd" or "|cfffe6100")..tostring(level).."|r"
  return label
end

if not string.nformat then
  function string:nformat(...) return string.format(self,...):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") end
end

if GameTooltip and not GameTooltip.ZGV_ShowManyLines then
  function GameTooltip:ZGV_ShowManyLines(lines)
    for _,line in ipairs(lines or {}) do self:AddLine(tostring(line),1,1,1,true) end
  end
end

function ZGV.ArrayToStringColor(values)
  local r,g,b,a=F.fromRGB_a(values)
  return string.format("%02x%02x%02x%02x",math.floor(r*255+.5),math.floor(g*255+.5),math.floor(b*255+.5),math.floor(a*255+.5))
end

function F.dig_in(data,...)
  for index=1,select("#",...) do if type(data)~="table" then return nil end; data=data[select(index,...)] end
  return data
end
function F.dig_set(data,...)
  local count=select("#",...); if count<2 or type(data)~="table" then return nil end
  for index=1,count-2 do local key=select(index,...); data[key]=type(data[key])=="table" and data[key] or {}; data=data[key] end
  data[select(count-1,...)]=select(count,...); return data
end
function F.dig_in_call(data,...)
  local callable=F.dig_in(data,...); if type(callable)=="function" then return callable() end
end

function ZGV.GetMoneyString(money,color,style,trim)
  money=math.max(0,math.floor(tonumber(money) or 0))
  local gold=math.floor(money/10000); local silver=math.floor(money/100)%100; local copper=money%100
  local parts={}
  local function add(value,label,hex)
    if value>0 or not trim or #parts==0 then parts[#parts+1]=(color and ("|cff"..hex) or "")..value..(color and "|r" or "")..label end
  end
  add(gold,style=="full" and " gold" or "g","ffd700")
  add(silver,style=="full" and " silver" or "s","c7c7cf")
  add(copper,style=="full" and " copper" or "c","eea55f")
  return table.concat(parts," ")
end

function ZGV.TableProduct(tables)
  local result={{}}
  for _,values in ipairs(tables or {}) do
    local nextResult={}
    for _,prefix in ipairs(result) do for _,value in ipairs(values or {}) do local item=ZGV.CloneTable(prefix); item[#item+1]=value; nextResult[#nextResult+1]=item end end
    result=nextResult
  end
  return result
end

function ZGV:RenderAnimation(variables)
  if type(variables)~="table" then return end
  for _,entry in ipairs(variables) do
    local object,method,value=entry.object or entry[1],entry.method or entry[2],entry.value or entry[3]
    local fn=object and object[method]
    if type(fn)=="function" then fn(object,value) end
  end
end

function ZGV.ExplodeString(pattern,value)
  local result={}; pattern=pattern or ","; value=tostring(value or "")
  if pattern=="" then for index=1,#value do result[#result+1]=value:sub(index,index) end; return result end
  local start=1
  while true do local first,last=value:find(pattern,start); if not first then result[#result+1]=value:sub(start); break end; result[#result+1]=value:sub(start,first-1); start=last+1 end
  return result
end

function ZGV:DelayedRun(event,func,arg)
  self._delayedRuns=self._delayedRuns or {}
  local prior=self._delayedRuns[event]
  if prior then self:CancelTimer(prior) end
  local timer=self:ScheduleTimer(function()
    ZGV._delayedRuns[event]=nil
    if type(func)=="function" then func(arg) end
  end,0)
  self._delayedRuns[event]=timer
  return timer
end
function ZGV:TimedDelayedRun(wait,func,arg) return self:ScheduleTimer(func,wait or 0,arg) end

ZGV.ItemInfoCache=ZGV.ItemInfoCache or {}
function ZGV:GetItemInfo(id)
  id=tonumber(id) or id
  local cached=self.ItemInfoCache[id]
  if cached then return unpack(cached) end
  if type(GetItemInfo)~="function" then return nil end
  local info={GetItemInfo(id)}
  if info[1] then self.ItemInfoCache[id]=info end
  return unpack(info)
end
function ZGV:GetItemInfoWipe() self.ItemInfoCache={} end
function ZGV:PurgeItemCache() self:GetItemInfoWipe() end
function ZGV:ExpireItemCache() self:GetItemInfoWipe() end
function ZGV.cachedGetItemInfo(id) return ZGV:GetItemInfo(id) end

ZGV.ItemLinks=ZGV.ItemLinks or {}
local ItemLinks=ZGV.ItemLinks
function ItemLinks.GetItemID(link) return tonumber(tostring(link or ""):match("item:(%-?%d+)")) end
function ItemLinks.MatchID(first,second) return ItemLinks.GetItemID(first)==ItemLinks.GetItemID(second) end
function ItemLinks.Strip(link) return tostring(link or ""):gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") end
function ItemLinks.ProcessItemLink(link) return tostring(link or "") end
function ItemLinks.SetLevel(link) return tostring(link or "") end
function ItemLinks.SetFated(link) return tostring(link or "") end
function ItemLinks.SetCurrentSpec(link) return tostring(link or "") end
function ItemLinks.StripBlizzExtras(link) return tostring(link or "") end
function ItemLinks.FixLink(link) return tostring(link or "") end
function ItemLinks.Match(first,second) return ItemLinks.Strip(first)==ItemLinks.Strip(second) end
function ItemLinks.GetItemBonuses() return {} end
function ItemLinks.AddBonus(link) return tostring(link or "") end
function ItemLinks.RemoveBonus(link) return tostring(link or "") end
function ItemLinks.ReplaceBonus(link) return tostring(link or "") end
function ItemLinks.Explain(link) return {itemID=ItemLinks.GetItemID(link)} end
function ItemLinks.GetChatLink(link) return tostring(link or "") end

ZGV.Profiler=ZGV.Profiler or {records={}}
function ZGV.Profiler:Start(tag) self.active=self.active or {}; self.active[tag]={time=debugprofilestop and debugprofilestop() or 0,memory=collectgarbage("count")} end
function ZGV.Profiler:Stop(tag,newTag)
  local active=self.active and self.active[tag]; if not active then return end
  local record={time=(debugprofilestop and debugprofilestop() or 0)-active.time,memory=collectgarbage("count")-active.memory,cycles=1}
  self.records[newTag or tag]=record; self.active[tag]=nil; return record
end
function ZGV.Profiler:Store(tag,memory,cpu,timeTaken,cycles) self.records[tag]={memory=memory,cpu=cpu,time=timeTaken,cycles=cycles} end
function ZGV.Profiler:Show(tag) return self.records[tag] end
function ZGV.Profiler:ShowAll() return self.records end
function ZGV.Profiler:SetEnabled() self.enabled=true end
function ZGV.Profiler:Disable() self.enabled=false end
function ZGV.Profiler:Enable() self.enabled=true end

function ZGV.softassert(condition,message) if not condition then ZGV:LogError("assert",message or "assertion failed") end; return condition end
function ZGV.IsSavedBossDead(instanceID,bossBit)
  if type(GetSavedInstanceInfo)~="function" then return false end
  for index=1,(GetNumSavedInstances and GetNumSavedInstances() or 0) do
    local _,_,reset,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,id=GetSavedInstanceInfo(index)
    if id==instanceID and not reset then return false end
  end
  return false
end
function ZGV.Garrison_HasFollower() return false end
function ZGV.Garrison_GetBuildingState() return nil end
function ZGV.Garrison_HasBuildingBlueprint() return false end
function ZGV.Garrison_GetBuildingLocation() return nil end
function ZGV.IsDataProviderRegistered(frame,name)
  if not frame or not name then return false end
  for _,provider in pairs(frame.dataProviders or {}) do if provider.name==name then return true end end
  return false
end
function ZGV.IsItemBound(bag,slot)
  return type(IsBoundToAccountUntilEquip) == "function" and IsBoundToAccountUntilEquip(bag,slot) or false
end

function ZGV.CreateFrameWithBG(kind,name,parent,template)
  local frame=CreateFrame(kind or "Frame",name,parent,template)
  if frame.SetBackdrop then frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1}) end
  return frame
end
function ZGV.GetChromieTime() return nil end
function ZGV:Timerize(func,...)
  local arguments={...}
  return function(...) return func(unpack(arguments),...) end
end

Zygor_SpriteTexture_Mixin=Zygor_SpriteTexture_Mixin or {}
function Zygor_SpriteTexture_Mixin:CreateSprite(count,width,height,imageWidth,imageHeight)
  self.spriteCount=count; self.spriteWidth=width; self.spriteHeight=height; self.spriteImageWidth=imageWidth or width*count; self.spriteImageHeight=imageHeight or height
  return self:SetSpriteNum(1)
end
function Zygor_SpriteTexture_Mixin:SetBounce(mirror) self.spriteBounce=mirror end
function Zygor_SpriteTexture_Mixin:SetSpriteNum(number)
  if not self.spriteCount or not self.SetTexCoord then return end
  number=math.max(1,math.min(self.spriteCount,tonumber(number) or 1))
  local left=(number-1)/self.spriteCount; local right=number/self.spriteCount
  if self.spriteBounce and number%2==0 then left,right=right,left end
  self:SetTexCoord(left,right,0,1)
end

function F.is_coro_yieldable() local thread,isMain=coroutine.running(); return thread and not isMain end
function F.safe_yield(...) if F.is_coro_yieldable() then return coroutine.yield(...) end end
function F.coroutine_safe_pcall(func,arg) if F.is_coro_yieldable() then return pcall(func,arg) end; return xpcall(function() return func(arg) end,function(err) return err end) end
function F.IsPlayerRole(role) return type(UnitGroupRolesAssigned)=="function" and UnitGroupRolesAssigned("player")==role or false end
function F.CutsceneCancel() if type(CinematicFrame_CancelCinematic)=="function" then CinematicFrame_CancelCinematic() end end
function F.MovieCancel() if type(MovieFrame_OnMovieFinished)=="function" then MovieFrame_OnMovieFinished() end end
function F.GetSecondsFromTime(value) return (tonumber(value and value.hour) or 0)*3600+(tonumber(value and value.minute) or 0)*60+(tonumber(value and value.second) or 0) end
function F.GetTimeFromSeconds(seconds)
  seconds=math.max(0,math.floor(tonumber(seconds) or 0)); return {hour=math.floor(seconds/3600),minute=math.floor(seconds/60)%60,second=seconds%60}
end
function F.GetTimeUntil(value,short) local seconds=F.GetSecondsFromTime(value)-time(); if short then return string.format("%02d:%02d",math.floor(seconds/60),seconds%60) end; return seconds end
function F.SetFrameAnchor(frame,data)
  if not frame or type(data)~="table" then return end
  frame:ClearAllPoints(); frame:SetPoint(data.point or "CENTER",data.relativeTo and _G[data.relativeTo] or UIParent,data.relativePoint or data.point or "CENTER",data.x or 0,data.y or 0)
end
function F.SaveFrameAnchor(frame,name,context)
  if not frame or not ZGV.db then return end
  context=context or ZGV.db.profile; context[name]=context[name] or {}
  local point,relative,relativePoint,x,y=frame:GetPoint(1); context[name]={point=point,relativeTo=relative and relative:GetName(),relativePoint=relativePoint,x=x,y=y}; return context[name]
end
function F.SaveFrameSizes(frame,name,context) context=context or ZGV.db.profile; context[name]=context[name] or {}; context[name].width,context[name].height=frame:GetWidth(),frame:GetHeight() end
function F.SetFrameSizes(frame,data) if frame and data then if data.width then frame:SetWidth(data.width) end; if data.height then frame:SetHeight(data.height) end end end
function F.GetItemCooldown(itemID) local start,duration,enabled=GetItemCooldown(itemID); return start,duration,enabled end
function F.IsBoosted() return false end
function F.TrackKills() end
function F:GetKillsNeeded(level,experience) return math.max(0,math.ceil((tonumber(experience) or 0)/math.max(1,(tonumber(level) or 1)*45))) end
function ZGV:Throttler(identifier,delay,callback,params) return self:DelayedRun("throttle:"..tostring(identifier),callback,params) end
function ZGV:ThrottlerWrap(identifier,delay,callback,params) return function(...) return ZGV:Throttler(identifier,delay,callback,params or {...}) end end
function ZGV.IsSecret() return false end
function ZGV.WillBeSecret() return false end

function F.GetCurrentPath(_,full)
  local guide=ZGV.Runtime and ZGV.Runtime.currentGuide
  if not guide then return full and {} or "" end
  local path=guide.path or guide.guidepath or ""
  if full then
    local parts={}; for segment in (path.."\\"):gmatch("(.-)\\") do if segment~="" then parts[#parts+1]=segment end end; return parts
  end
  return path
end
function F.GetCurrentPath_Test() return F.GetCurrentPath() end

ZGV.Languages=ZGV.Languages or {}
function ZGV.Languages:GetLanguageSkill(name)
  if type(GetSkillLineInfo)~="function" then return 0 end
  for index=1,(GetNumSkillLines and GetNumSkillLines() or 0) do
    local skill,_,_,rank=GetSkillLineInfo(index)
    if skill==name then return rank or 0 end
  end
  return 0
end
ZGV.Replacements=ZGV.Replacements or {}
function ZGV.Replacements:UpdateVisibility() end
function ZGV.Replacements:Startup() end
