-- Anniversary profession facade over the build-12340 TradeSkill service.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local Service=ZGV and ZGV.Compat and ZGV.Compat.Profession
local Professions=ZGV and ZGV.Professions
if type(Service)~="table" or type(Professions)~="table" then return end

Professions.skillSpells=Professions.skillSpells or {}
Professions.SkillsKnown=Professions.SkillsKnown or {}
Professions.tradeskillsIdByName=Professions.tradeskillsIdByName or {}
Professions.skillLocale=Professions.skillLocale or {}
Professions.LocaleSkills=Professions.LocaleSkills or {}
Professions.LocaleSkillsR=Professions.LocaleSkillsR or {}
for id,data in pairs(Professions.tradeskills or {}) do
  if data.name then
    Professions.tradeskillsIdByName[data.name]=id
    Professions.skillLocale[id]=Professions.skillLocale[id] or data.name
    Professions.LocaleSkills[data.name]=Professions.LocaleSkills[data.name] or Professions.skillLocale[id]
    Professions.LocaleSkillsR[Professions.skillLocale[id]]=Professions.LocaleSkillsR[Professions.skillLocale[id]] or id
  end
end

if type(ZGV.CacheRecipes_Queued)~="function" then
  function ZGV:CacheRecipes_Queued() return Service:RefreshRecipes() end
end
if type(ZGV.CacheRecipesCraft)~="function" then
  function ZGV:CacheRecipesCraft() return Service:RefreshRecipes() end
end
if type(ZGV.CacheRecipesCraft_Queued)~="function" then
  function ZGV:CacheRecipesCraft_Queued() return Service:RefreshRecipes() end
end
if type(ZGV.Profession_NEW_RECIPE_LEARNED)~="function" then
  function ZGV:Profession_NEW_RECIPE_LEARNED(_,spellID)
    self.recentlyLearnedRecipes=self.recentlyLearnedRecipes or {}
    if spellID then self.recentlyLearnedRecipes[spellID]=true end
    return Service:RefreshRecipes()
  end
end
if type(ZGV.Profession_CHAT_MSG_SYSTEM)~="function" then
  function ZGV:Profession_CHAT_MSG_SYSTEM() return Service:RefreshRecipes() end
end
if type(Professions.GoalRecipe)~="function" then
  function Professions:GoalRecipe(skill,spellID)
    if not skill or not spellID then return nil,"no_data" end
    if not Service:Find(skill) then return nil,"no_prof" end
    local recipe=Service:FindRecipe(spellID)
    if not recipe then return nil,"unknown" end
    return recipe
  end
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.Profession=Service
