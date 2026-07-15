-- WotLK trainer advisor.  Build 12340 exposes the authoritative rank, price,
-- level and availability only while a trainer window is open, so the live
-- service list is primary and the bundled fixture identifies class/profession
-- coverage without inventing retail spell data.
local ZGV=ZygorGuidesViewer
if not ZGV then return end
local Skills=ZGV:RegisterModule("Skills",{banned={},services={},shown=false,context=nil})
ZGV.Skills=Skills

local function profile() return ZGV.db and ZGV.db.profile and ZGV.db.profile.skills or {} end
local function normalise(value) return tostring(value or ""):lower():gsub("[^%w]","") end
local function serviceKey(service) return normalise(service.name)..":"..normalise(service.rank)..":"..tostring(service.category or "") end
local function playerLevel() return UnitLevel and UnitLevel("player") or 0 end

function Skills:CleanSkillTable()
  self.banned=ZGV.db and ZGV.db.char and (ZGV.db.char.bannedSkills or {}) or {}
  if ZGV.db and ZGV.db.char then ZGV.db.char.bannedSkills=self.banned end
  return self.banned
end

function Skills:GetKnownProfessions()
  local known={}
  if type(GetProfessions)=="function" and type(GetProfessionInfo)=="function" then
    for slot=1,6 do
      local index=select(slot,GetProfessions())
      if index then
        local name,_,rank,maxRank,_,_,skillLine=GetProfessionInfo(index)
        known[tonumber(skillLine) or normalise(name)]={name=name,rank=rank,maxRank=maxRank,skillLine=skillLine}
      end
    end
  end
  return known
end

function Skills:GetContext()
  local class
  if UnitClass then local _,token=UnitClass("player"); class=token end
  local fixture=ZGV.TrainerFixtures or {}
  local validClass=false
  for _,token in ipairs(fixture.classTokens or {}) do if token==class then validClass=true break end end
  return {class=class,knownProfessions=self:GetKnownProfessions(),classSupported=validClass,fixtures=fixture}
end

function Skills:ClassifyService(status,requiredLevel,numAvailable)
  local required=tonumber(requiredLevel) or 0
  if required>playerLevel() then return "future" end
  if status=="available" or status=="green" or status==true or (tonumber(numAvailable) or 0)>0 then return "available" end
  if status=="unavailable" or status=="red" then return "unavailable" end
  if status=="used" or status=="known" then return "known" end
  return "unknown"
end

function Skills:CollectServices()
  local services={}; self.context=self:GetContext()
  if type(GetNumTrainerServices)~="function" or type(GetTrainerServiceInfo)~="function" then self.services=services; return services end
  for index=1,GetNumTrainerServices() do
    local name,rank,category,status,numAvailable,requiredLevel=GetTrainerServiceInfo(index)
    if name then
      local service={
        index=index,name=name,rank=rank,category=category,status=status,available=numAvailable,
        requiredLevel=tonumber(requiredLevel) or 0,icon=GetTrainerServiceIcon and GetTrainerServiceIcon(index),
        cost=GetTrainerServiceCost and tonumber(GetTrainerServiceCost(index)) or nil,
      }
      service.key=serviceKey(service); service.availability=self:ClassifyService(status,service.requiredLevel,numAvailable)
      service.banned=self.banned[service.key] or self.banned[index] or false
      services[#services+1]=service
    end
  end
  table.sort(services,function(a,b)
    local order={available=1,future=2,unavailable=3,unknown=4,known=5}
    if order[a.availability]~=order[b.availability] then return order[a.availability]<order[b.availability] end
    return tostring(a.name)<tostring(b.name)
  end)
  self.services=services; ZGV:Fire("ZGV_SKILLS_UPDATED",services,self.context); return services
end

function Skills:GetLearnableSkills(level,forceShow)
  local result={}
  for _,service in ipairs(self:CollectServices()) do
    if service.availability=="available" and not service.banned then result[#result+1]=service end
  end
  return result
end

function Skills:GetServiceSummary()
  local summary={available={},future={},unavailable={},known={},unknown={}}
  for _,service in ipairs(self:CollectServices()) do summary[service.availability][#summary[service.availability]+1]=service end
  return summary
end

function Skills:IsDependantKnown(service)
  if type(service)~="table" or not service.requiresSpell then return false end
  return (IsSpellKnown and IsSpellKnown(service.requiresSpell,service.pet)) and true or false
end

function Skills:BanLearnableSkills(value)
  local service=type(value)=="table" and value or self.services[tonumber(value)]
  local key=service and service.key or tostring(value or "")
  if key~="" then self.banned[key]=true end
  if ZGV.db and ZGV.db.char then ZGV.db.char.bannedSkills=self.banned end
  return self:RefreshSkillPopup()
end

function Skills:MarkLearnedSkills()
  local services=self:CollectServices()
  for _,service in ipairs(services) do if service.availability=="known" then self.banned[service.key]=nil end end
  return services
end

function Skills:FormatService(service)
  local text=service.name..(service.rank and service.rank~="" and " ("..service.rank..")" or "")
  if service.requiredLevel>playerLevel() then text=text.." — level "..service.requiredLevel end
  if service.cost and service.cost>0 then
    text=text.." — "..(GetCoinTextureString and GetCoinTextureString(service.cost) or tostring(service.cost).."c")
  end
  return text
end

function Skills:MakeSkillsPopup()
  if self.popup then return self.popup end
  local popup=ZGV.PopupHandler and ZGV.PopupHandler:NewPopup("ZygorSkillsTraining","skills")
  if not popup then return nil end
  popup.title="Trainer skills"
  popup.acceptbutton:SetText("Open trainer")
  popup.acceptbutton:SetScript("OnClick",function() popup:Hide() end)
  popup.declinebutton:SetText("Later")
  popup.morebutton:SetText("Ignore shown")
  popup.morebutton:Show()
  popup.morebutton:SetScript("OnClick",function() for _,service in ipairs(Skills:GetLearnableSkills()) do Skills.banned[service.key]=true end; Skills:RefreshSkillPopup(); popup:Hide() end)
  self.popup=popup; return popup
end

function Skills:RefreshSkillPopup()
  local popup=self:MakeSkillsPopup(); local services=self:GetLearnableSkills()
  if not popup then return services end
  local lines={}; for index,service in ipairs(services) do if index<=8 then lines[#lines+1]=self:FormatService(service) end end
  local future=#self:GetServiceSummary().future
  local suffix=future>0 and ("\n"..future.." additional skill"..(future==1 and " unlocks" or "s unlock").." at later levels.") or ""
  popup:SetText(#services>0 and "Your trainer has skills available:" or "No learnable trainer skills are available.",table.concat(lines,"\n")..suffix)
  return services
end

function Skills:ShowToast()
  local services=self:GetLearnableSkills(); if #services==0 then return false end
  if ZGV.NotificationCenter then ZGV.NotificationCenter:AddEntry("skills","Trainer skills available",tostring(#services).." skill"..(#services==1 and "" or "s").." can be learned.",{cleartype=true}) end
  return true
end

function Skills:ShowSkillPopup(_,_,forceShow)
  local services=self:RefreshSkillPopup(); if #services==0 and not forceShow then return false end
  local popup=self:MakeSkillsPopup(); if popup then popup:Show(); self.shown=true end; return popup
end
function Skills:MaybeShowPopupByDistance() if #self:GetLearnableSkills()>0 then return self:ShowSkillPopup() end end
function Skills:EventDriver(event)
  local settings=profile(); if settings.enabled==false then return end
  if event=="TRAINER_SHOW" then self:RefreshSkillPopup(); if settings.toast~=false then self:ShowToast() end
  elseif event=="TRAINER_CLOSED" and self.popup then self.popup:Hide() end
end
function Skills:OnStartup() self:CleanSkillTable(); self:MakeSkillsPopup() end
function Skills:OnEvent(event) self:EventDriver(event) end
ZGV:RegisterEvent("TRAINER_SHOW",Skills,"OnEvent")
ZGV:RegisterEvent("TRAINER_CLOSED",Skills,"OnEvent")
