-- POI compatibility for the WotLK world-map API.  Classic data packs may
-- register their point sets directly in ZGV.Poi.Sets; pins are rendered by
-- Navigation rather than retail MapCanvas data providers.
local ZGV=ZygorGuidesViewer
if not ZGV or not ZGV.Compat or not ZGV.Navigation then return end

local Poi=ZGV:RegisterModule("Poi",{Sets={},Points={},Guidance={},enabled=true,DoneLoadingPoints=false,activePointID=nil})
ZGV.Poi=Poi
local Map=ZGV.Compat.Map

local function trim(value) return tostring(value or ""):gsub("^%s+",""):gsub("%s+$","") end
local function coordinate(value)
  value=tonumber(value)
  return value and (value>1 and value/100 or value) or nil
end

function Poi:RegisterSet(name,points)
  if type(name)~="string" or type(points)~="table" then return false end
  self.Sets[name]=points
  self.DoneLoadingPoints=false
  return true
end

-- Content packs may bind a point to a pre-registered local guide/step.  This
-- registry intentionally accepts only identifiers, never a guide body or a
-- callback, so clicking a map pin cannot introduce mutable remote DSL.
function Poi:RegisterGuidance(name,guide,step)
  if type(name)~="string" or name=="" or type(guide)~="string" or guide=="" then return false,"invalid guidance" end
  self.Guidance[name]={guide=guide,step=tonumber(step)}
  return true
end

function Poi:IsComplete(point)
  if not point then return true end
  if point.quest then
    local quest=ZGV.Compat.Quest
    return quest and quest:IsCompleted(tonumber(point.quest)) or (IsQuestFlaggedCompleted and IsQuestFlaggedCompleted(tonumber(point.quest))) or false
  end
  if point.achieve and GetAchievementInfo then
    if point.achievecriteria and GetAchievementCriteriaInfo then
      local _,_,completed=GetAchievementCriteriaInfo(tonumber(point.achieve),tonumber(point.achievecriteria),true)
      return completed and true or false
    end
    local _,_,_,completed=GetAchievementInfo(tonumber(point.achieve))
    return completed and true or false
  end
  return false
end

function Poi:IsValid(point)
  local profile=ZGV.db and ZGV.db.profile
  local map=profile and profile.map
  if not self.enabled or not map or not map.poiEnabled then return false,"system disabled" end
  local pointType=point.type or (point.rare and "rare") or (point.treasure and "treasure") or "poi"
  if map.hideTypes and map.hideTypes[pointType] then return false,"hidden type" end
  if map.poiMode=="quick" and point.access then return false,"hidden mode" end
  if type(point.condition)=="function" then
    local ok,result=pcall(point.condition,point)
    if not ok or not result then return false,"condition failed" end
  elseif type(point.condition)=="string" and point.condition~="" and ZGV.Conditions then
    local text=point.condition:gsub("^only if%s+","")
    local ok,result=pcall(ZGV.Conditions.Evaluate,ZGV.Conditions,text,point)
    if ok and not result then return false,"condition failed" end
  end
  return not self:IsComplete(point),"completion status"
end

function Poi:ResolvePoint(point)
  if type(point)~="table" then return nil end
  if point._poiResolved then return point._poiResolved end
  local mapName,floor,x,y
  if type(point.spot)=="string" then
    mapName,floor,x,y=point.spot:match("^(.-)%s*/%s*(%d+)%s+([%d%.]+)%s*,%s*([%d%.]+)%s*$")
    if not mapName then mapName,x,y=point.spot:match("^(.-)%s+([%d%.]+)%s*,%s*([%d%.]+)%s*$") end
  end
  local record=Map:Resolve(point.mapKey or point.map or point.m)
  if not record and mapName and ZGV.Pointer then record=ZGV.Pointer:ResolveMap(trim(mapName)) end
  if not record then return nil end
  local px,py=coordinate(point.x or x),coordinate(point.y or y)
  if not px or not py then return nil end
  point.mapKey=record.key point.map=record.key point.m=record.key point.f=tonumber(floor) or point.f or record.floor or 0
  point.x,point.y=px,py
  point.name=point.name or point.rare or point.treasure or point.title or "Point of interest"
  point.type=point.type or (point.rare and "rare") or (point.treasure and "treasure") or "poi"
  point.ident=point.ident or (point.quest and "quest"..tostring(point.quest)) or (point.achieve and "achieve"..tostring(point.achieve)) or (record.key..":"..string.format("%.4f:%.4f",px,py))
  point._poiResolved=true
  return point
end

function Poi:ParsePoints()
  self.Points={}
  for _,set in pairs(self.Sets) do
    for _,point in pairs(set) do
      local resolved=self:ResolvePoint(point)
      if resolved then
        self.Points[resolved.mapKey]=self.Points[resolved.mapKey] or {}
        self.Points[resolved.mapKey][#self.Points[resolved.mapKey]+1]=resolved
      end
    end
  end
  self.DoneLoadingPoints=true
  return self:PreparePoints()
end

function Poi:PreparePoints()
  local markers={}
  if not self.enabled then ZGV.Navigation:ClearExternalMarkers("poi"); return markers end
  for _,set in pairs(self.Points) do
    for _,point in ipairs(set) do
      if self:IsValid(point) then
        local resolved=ZGV.Navigation:ResolveTarget({mapKey=point.mapKey,x=point.x,y=point.y,title=point.name})
        if resolved then
          resolved.kind="poi" resolved.poiType=point.type resolved.onminimap=true resolved.poi=point
          resolved.selected=point.ident==self.activePointID
          resolved.onClick=function(_,button) if button=="LeftButton" then Poi:LoadPoint(point) end end
          markers[#markers+1]=resolved
        end
      end
    end
  end
  ZGV.Navigation:SetExternalMarkers("poi",markers)
  ZGV:Fire("ZGV_POI_UPDATED",markers)
  return markers
end

function Poi:FindPoint(ident)
  for _,set in pairs(self.Points or {}) do
    for _,point in ipairs(set) do if point.ident==ident then return point end end
  end
end

function Poi:ResolveGuidance(point)
  local registered=point and point.guidance and self.Guidance[point.guidance]
  local guide=(registered and registered.guide) or (point and point.guide)
  local step=(registered and registered.step) or (point and (point.guideStep or point.guide_step or point.step))
  if type(guide)~="string" or guide=="" then return nil end
  local catalog=ZGV.Catalog; local localGuide=catalog and catalog:Get(guide)
  if not localGuide then return nil,"unregistered guide" end
  return localGuide,tonumber(step)
end

function Poi:PopulateTooltip(tooltip,point)
  if not tooltip or not point then return false end
  tooltip:SetText(point.name or "Point of interest")
  tooltip:AddLine((point.type or "poi"):gsub("^%l",string.upper),1,.82,.15)
  if point.comment and point.comment~="" then tooltip:AddLine(tostring(point.comment),1,1,1,true) end
  if point.quest then tooltip:AddLine("Quest: "..tostring(point.quest),.75,.75,.75) end
  if point.achieve then tooltip:AddLine("Achievement: "..tostring(point.achieve),.75,.75,.75) end
  local guide=self:ResolveGuidance(point)
  if guide then tooltip:AddLine("Left-click: open local guide",.4,1,.4) else tooltip:AddLine("Left-click: set waypoint",.75,.75,.75) end
  return true
end

function Poi:LoadPoint(point,noswitch)
  if not point then return false end
  self.activePointID=point.ident
  if ZGV.db and ZGV.db.char then ZGV.db.char.activepoi=point.ident end
  local guide,step,reason=self:ResolveGuidance(point)
  if point.guidance or point.guide then
    if not guide then
      ZGV:LogError("poi","Rejected "..tostring(point.ident)..": "..tostring(reason or "invalid local guidance"))
      return false,reason or "invalid local guidance"
    end
    if not noswitch and ZGV.Runtime then
      local ok=ZGV.Runtime:SelectGuide(guide.id,step)
      if not ok then return false,"guide selection failed" end
    end
  elseif not noswitch and ZGV.Navigation then
    ZGV.Navigation:SetWaypoint({mapKey=point.mapKey,x=point.x,y=point.y,title=point.name},point.name)
  end
  self:PreparePoints()
  ZGV:Fire("ZGV_POI_LOADED",point)
  if ZGV.NotificationCenter then ZGV.NotificationCenter:Push({title="Point selected",message=point.name or "Point of interest",kind="info",duration=3}) end
  return true
end

function Poi:ChangeState(enable)
  self.enabled=enable~=false
  if ZGV.db and ZGV.db.profile and ZGV.db.profile.map then
    ZGV.db.profile.map.poiEnabled=self.enabled ZGV.db.profile.poienabled=self.enabled
  end
  if not self.DoneLoadingPoints then self:ParsePoints() else self:PreparePoints() end
  return self.enabled
end

function Poi:Refresh()
  if not self.DoneLoadingPoints then return self:ParsePoints() end
  return self:PreparePoints()
end

function Poi:OnStartup()
  self.enabled=not (ZGV.db and ZGV.db.profile and ZGV.db.profile.map and ZGV.db.profile.map.poiEnabled==false)
  self:ParsePoints()
  local selected=ZGV.db and ZGV.db.char and ZGV.db.char.activepoi
  local point=selected and self:FindPoint(selected)
  if point then self:LoadPoint(point,true) end
end
function Poi:OnProgressEvent() self:Refresh() end
ZGV:RegisterEvent("QUEST_LOG_UPDATE",Poi,"OnProgressEvent")
ZGV:RegisterEvent("ACHIEVEMENT_EARNED",Poi,"OnProgressEvent")
ZGV:RegisterEvent("ZONE_CHANGED_NEW_AREA",Poi,"OnProgressEvent")
