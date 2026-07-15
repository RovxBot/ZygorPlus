-- Loaded compatibility facade for the Anniversary TalentAdvisor.lua.
-- The build-12340 engine lives in Talent.lua and the frame implementation in
-- ModernTalentAdvisor.lua; this file preserves the Classic public ZTA surface
-- used by bindings, configuration code and third-party build packs.
local _,ZGV=...
if not ZGV then ZGV=_G.ZygorGuidesViewer end
local Advisor=ZGV and ZGV.TalentAdvisor
local Talent=ZGV and ZGV.Talent
if not Advisor or not Talent then return end

ZGV.ZTA=Advisor
_G.ZTA=Advisor
_G.ZygorTalentAdvisor=Advisor

function Advisor:SyncLegacyState()
  local _,build,isPet=self:GetContext()
  local state=build and Talent:GetSuggestionState(build) or nil
  self.currentBuild=build
  self.currentBuildTitle=build and build.title or nil
  self.status=state and {code=state.code,msg=state.message,pointsleft=state.unspent,missed=state.wrong} or {code="NONE"}
  self.suggestion=state and state.suggestions or {}
  self.pet=isPet and true or false
  return state
end

function Advisor:Initialize()
  Talent:InitializeBuilds("legacy Initialize")
  self:HookTalentFrame()
  self:SyncLegacyState()
  return true
end

function Advisor:SetCurrentBuild(key)
  local ok,reason,issues=Talent:SelectBuild(key)
  if ok then self:Refresh() self:SyncLegacyState() end
  return ok,reason,issues
end

function Advisor:LoadBuilds()
  Talent.compiled={}
  local ok,reason=Talent:InitializeBuilds("legacy LoadBuilds")
  self:Refresh()
  self:SyncLegacyState()
  return ok,reason
end

function Advisor:ReloadBuilds(pet)
  if pet~=nil then self:SetPetMode(pet and true or false) end
  return self:LoadBuilds()
end

function Advisor:UpdateSuggestions()
  self:Refresh()
  return self:SyncLegacyState()
end

function Advisor:ShowTalentSuggestions()
  local state=self:SyncLegacyState()
  self:RefreshTalentHints(state)
  if self.frame and self.frame:IsShown() then self:Refresh() end
  return state
end

function Advisor:GetBuildStatus(build)
  local state=Talent:GetSuggestionState(build or self.currentBuild)
  return {code=state.code,msg=state.message,pointsleft=state.unspent,missed=state.wrong}
end

function Advisor:GetStatusMessage()
  local state=self.state or self:SyncLegacyState()
  return state and state.message or "No talent build selected."
end

function Advisor:GetUnusedTalentPoints(pet)
  return ZGV.Compat.Talent:GetUnspentPoints(pet and true or false)
end

function Advisor:IsBuildStatusUsable(status)
  local code=status and status.code
  return code and code~="NONE" and code~="BLACK" and (code~="RED" or (ZGV.db and ZGV.db.profile.talent.forceBuild))
end

function Advisor:IsCurrentBuildUsable()
  return self:IsBuildStatusUsable(self.status or self:GetBuildStatus())
end

function Advisor:GetSuggestionFormatted()
  local state=self:SyncLegacyState()
  local formatted={}
  for _,row in ipairs(self:CollapseSuggestions(state or {suggestions={}})) do
    local point=row.point
    local tree=ZGV.Compat.Talent:GetTab(point.tab,point.isPet)
    local name=tree and tree.name or ("Tree "..tostring(point.tab))
    formatted[name]=formatted[name] or {}
    formatted[name][#formatted[name]+1]={
      tex=point.texture,tab=point.tab,talent=point.index,name=point.name,
      from=row.fromRank,to=row.toRank,oneofone=row.toRank==1,
    }
  end
  return formatted
end

-- Anniversary's function name implied bulk learning.  On WotLK this remains a
-- single explicit, optionally confirmed click; PreviewSuggestions is the safe
-- way to place all currently available points into Blizzard's preview tree.
function Advisor:LearnSuggestedTalents()
  return self:RequestLearn()
end

function Advisor:Safe_LearnTalent(tab,index,pet)
  return ZGV.Compat.Talent:Learn(tab,index,pet and true or false)
end

function Advisor:SetHooks()
  return self:HookTalentFrame()
end

function Advisor:HookToTalentFrame()
  return self:HookTalentFrame()
end

function Advisor:SetOption(key,value)
  local profile=ZGV.db and ZGV.db.profile and ZGV.db.profile.talent
  if not profile then return false end
  local aliases={
    zta_enabled="enabled",zta_hints="hints",zta_preview="rankPreview",
    zta_windowdocked="docked",zta_forcebuild="forceBuild",
  }
  key=aliases[key] or key
  if profile[key]==nil then return false end
  profile[key]=value
  self:ApplyDocking()
  self:Refresh()
  return true
end

local function sync() Advisor:SyncLegacyState() end
ZGV:RegisterCallback("ZGV_TALENT_BUILD_CHANGED",sync)
ZGV:RegisterCallback("ZGV_TALENTS_UPDATED",sync)
