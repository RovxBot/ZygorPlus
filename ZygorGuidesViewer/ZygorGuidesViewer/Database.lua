local ZGV = ZygorGuidesViewer
local Database = ZGV:RegisterModule("Database",{})

local defaults = {
  schema=1,
  migration={ legacyImported=false, talentImported=false, unmappedGuides={} },
  profileKeys={},
  profiles={},
  chars={},
  global={ diagnostics={errors={},entries={}}, profiling=false, trustedUserScripts=false, trendData={} },
}

local profileDefaults = {
  viewer={ shown=true, x=-260, y=40, width=340, height=155, scale=1, locked=false, theme="Starlight-glass", rows=7, opacity=1, autoHeight=true, layoutVersion=2, magicKeyHint=false },
  skin="default", skinstyle="starlight", opacitytoggle=true,
  arrow={ shown=true, x=0, y=-120, scale=1, arrival=15, theme="Starlight" },
  foglight=true,
  minimap={ x=-3, y=-2 },
  actionbar={ enabled=true, x=0, y=80, scale=1, locked=false, direction=2, quest=true, talk=true, kill=true, trash=false, hideInCombat=false },
  automation={ accept=true, progress=true, turnin=true, gossip=true, repair=true, sellGreys=false, equip=false, autoSelectReward=false, questRewardHint=true },
  navigation={ enabled=true, useTomTom=true, knownTaxi={} },
  map={ showCoords=true, poiEnabled=true, poiMode="quick", hideTypes={rare=false,treasure=false}, mapIcons=true, minimapIcons=true },
  pointer={ audio=true, meters=false, freeze=false, showMinimap=true, showWorldMap=true, showLines=true, autoCorpse=true },
  -- Questie owns the Blizzard quest-watch list when installed.  Zygor keeps
  -- its own unobtrusive progress cache and never takes over that shared list
  -- unless the user explicitly enables native quest watching.
  tracking={ enabled=true, watchActive=false, autoUnwatch=false, autoAbandon=false },
  notifications={ enabled=true, history={}, toast=true, duration=5, x=-30, y=-180 },
  announcements={ levelUp=false, emote=false, party=false, guild=false },
  creatureDetector={ enabled=true, notify=true },
  creatureViewer={ enabled=true, x=220, y=40, width=170, height=220, scale=1, zoom=1, locked=false, rotation=false, slideshow=false },
  faction={ analyze=false, fake={} },
  sync={ enabled=true, acceptParty=true, acceptRaid=true, acceptWhisper=false, magnetic=false, announce=true, mode="off", protocol=2 },
  widgets={ guide={ shown=false, x=250, y=-130, locked=false }, layout={}, floating={} },
  favorites={}, history={}, currentGuide=nil, currentStep=1,
  talent={
    selected={}, enabled=true, hints=true, rankPreview=true, docked=true,
    autoOpen=true, shown=true, confirmLearn=true, forceBuild=false, x=180, y=80,
  },
  gear={ role=nil, autoEquip=false, enabled=true, notifications=true, seen={}, customWeights={} },
  inventory={ showBagSpace=false }, skills={enabled=true,toast=true}, questitemcache={},
  gold={
    scans={}, appraisals={}, shopping={}, session=nil, history={}, appraisalMaxAge=7200, undercutCopper=1,
    query={minInterval=.8,timeout=15}, trend={maxSamples=20,maxScans=40},
    fullScan={maxDuration=300,maxPages=200,maxRows=30000},
    opportunities={minDiscount=.15,minPotential=0,limit=100}, crafting={auctionCut=.05},
    post={duration=24,stackSize=1,stackCount=1},
  },
}

local function copy(source,seen)
  if type(source)~="table" then return source end
  seen=seen or {}
  if seen[source] then return seen[source] end
  local result={}
  seen[source]=result
  for key,value in pairs(source) do result[copy(key,seen)]=copy(value,seen) end
  return result
end

local function fill(target,source)
  for key,value in pairs(source) do
    if target[key]==nil then target[key]=copy(value)
    elseif type(value)=="table" and type(target[key])=="table" then fill(target[key],value) end
  end
  return target
end

local function path(tableValue,...)
  local value=tableValue
  for i=1,select("#",...) do
    if type(value)~="table" then return nil end
    value=value[select(i,...)]
  end
  return value
end

function Database:CharacterKey()
  local name=type(UnitName)=="function" and UnitName("player") or "Unknown"
  local realm=type(GetRealmName)=="function" and GetRealmName() or "Realm"
  return tostring(name).." - "..tostring(realm)
end

function Database:EnsureProfile(profile)
  return fill(profile or {},profileDefaults)
end

function Database:GetProfileNames()
  local names={}
  local profiles=ZGV.db and ZGV.db.root and ZGV.db.root.profiles or {}
  for name in pairs(profiles) do names[#names+1]=name end
  table.sort(names)
  return names
end

function Database:SetProfile(name)
  name=tostring(name or ""):gsub("^%s+",""):gsub("%s+$","")
  if name=="" or not (ZGV.db and ZGV.db.root) then return false,"invalid profile" end
  local root=ZGV.db.root
  root.profiles[name]=self:EnsureProfile(root.profiles[name])
  root.profileKeys[ZGV.db.charKey]=name
  ZGV.db.profile=root.profiles[name]
  ZGV.db.profileKey=name
  if ZGV.Runtime and ZGV.Catalog then
    local saved=ZGV.db.profile.currentGuide
    if saved and ZGV.Runtime:SelectGuide(saved,ZGV.db.profile.currentStep or 1) then
      -- SelectGuide restores the profile-specific current step and refreshes
      -- all guide consumers through the normal runtime callbacks.
    else
      ZGV.Runtime.currentGuide=nil
      ZGV.Runtime.currentStep=1
    end
  end
  ZGV:Fire("ZGV_PROFILE_CHANGED",name,ZGV.db.profile)
  return true,ZGV.db.profile
end

function Database:CopyProfile()
  if not (ZGV.db and ZGV.db.root and ZGV.db.profile) then return false,"profile unavailable" end
  local root,base=ZGV.db.root,tostring(ZGV.db.profileKey or "Default").." Copy"
  local name,index=base,2
  while root.profiles[name] do name=base.." "..index; index=index+1 end
  root.profiles[name]=self:EnsureProfile(copy(ZGV.db.profile))
  local ok=self:SetProfile(name)
  return ok,name
end

function Database:ImportLegacy(old)
  local root=ZygorGuidesViewerWotLKSettings
  if root.migration.legacyImported or type(old)~="table" then return end
  local p=ZGV.db.profile

  local x=path(old,"profile","frame_anchor","x") or path(old,"profile","viewer_anchor","x") or path(old,"frame","x")
  local y=path(old,"profile","frame_anchor","y") or path(old,"profile","viewer_anchor","y") or path(old,"frame","y")
  local scale=path(old,"profile","framescale") or path(old,"profile","viewer_scale")
  if type(x)=="number" then p.viewer.x=x end
  if type(y)=="number" then p.viewer.y=y end
  if type(scale)=="number" and scale>=0.5 and scale<=2 then p.viewer.scale=scale end

  local guide=path(old,"char","guidename") or path(old,"char","currentguide") or path(old,"profile","guidename") or old.CurrentGuide
  local step=path(old,"char","step") or path(old,"char","currentstep") or path(old,"profile","step")
  if type(guide)=="string" then p.currentGuide=guide end
  if type(step)=="number" then p.currentStep=math.max(1,math.floor(step)) end

  local history=path(old,"char","guidehistory") or path(old,"profile","guidehistory") or path(old,"profile","history")
  if type(history)=="table" then p.history=copy(history) end
  local favorites=path(old,"profile","favorites") or path(old,"char","favorites")
  if type(favorites)=="table" then p.favorites=copy(favorites) end

  local auto=path(old,"profile","autoturnin")
  if type(auto)=="boolean" then p.automation.turnin=auto end
  auto=path(old,"profile","autoaccept")
  if type(auto)=="boolean" then p.automation.accept=auto end
  auto=path(old,"profile","autosell")
  if type(auto)=="boolean" then p.automation.sellGreys=auto end
  auto=path(old,"profile","autorepair")
  if type(auto)=="boolean" then p.automation.repair=auto end

  local actionbar=path(old,"profile","enable_actionbar")
  if type(actionbar)=="boolean" then p.actionbar.enabled=actionbar end
  local actionScale=path(old,"profile","actionbar_scale")
  if type(actionScale)=="number" then p.actionbar.scale=actionScale end
  local actionDirection=path(old,"profile","actionbar_direction")
  if type(actionDirection)=="number" then p.actionbar.direction=actionDirection end
  for legacy,current in pairs({actionbar_quest="quest",actionbar_talk="talk",actionbar_kill="kill",actionbar_trash="trash",hidebarincombat="hideInCombat"}) do
    local value=path(old,"profile",legacy)
    if type(value)=="boolean" then p.actionbar[current]=value end
  end

  for legacy,current in pairs({spam_levelup="levelUp",spam_levelup_emote="emote",spam_levelup_party="party",spam_levelup_guild="guild"}) do
    local value=path(old,"profile",legacy)
    if type(value)=="boolean" then p.announcements[current]=value end
  end

  local viewerEnabled=path(old,"profile","mv_enabled")
  if type(viewerEnabled)=="boolean" then p.creatureViewer.enabled=viewerEnabled end
  local viewerRotation=path(old,"profile","mv_rotation")
  if type(viewerRotation)=="boolean" then p.creatureViewer.rotation=viewerRotation end
  local viewerSlideshow=path(old,"profile","mv_slideshow")
  if type(viewerSlideshow)=="boolean" then p.creatureViewer.slideshow=viewerSlideshow end
  local viewerScale=path(old,"profile","mv_scale")
  if type(viewerScale)=="number" then p.creatureViewer.scale=viewerScale end

  local reputationAnalysis=path(old,"profile","analyzereps")
  if type(reputationAnalysis)=="boolean" then p.faction.analyze=reputationAnalysis end
  local fakeReputations=path(old,"profile","fakereps")
  if type(fakeReputations)=="table" then p.faction.fake=copy(fakeReputations) end

  local levelTimes=path(old,"char","timeperlevel") or path(old,"profile","timeperlevel")
  if type(levelTimes)=="table" then ZGV.db.char.timePerLevel=copy(levelTimes) end

  local taxis=path(old,"char","taxis") or path(old,"profile","known_taxis")
  if type(taxis)=="table" then p.navigation.knownTaxi=copy(taxis) end
  root.migration.legacyImported=true
  root.migration.importedAt=type(time)=="function" and time() or 0
end

function Database:ImportLegacyTalentAdvisorSettings(old)
  local root=ZygorGuidesViewerWotLKSettings
  if root.migration.talentImported or type(old)~="table" then return end
  local selected=path(old,"char","build") or path(old,"profile","build") or old.currentBuild
  if type(selected)=="string" then ZGV.db.profile.talent.legacyBuild=selected end
  local builds=path(old,"profile","selected")
  if type(builds)=="table" then ZGV.db.profile.talent.selected=copy(builds) end
  local profile=path(old,"profile") or old
  local talent=ZGV.db.profile.talent
  local mappings={
    zta_enabled="enabled", zta_hints="hints", zta_preview="rankPreview",
    zta_windowdocked="docked", zta_forcebuild="forceBuild",
  }
  for legacy,current in pairs(mappings) do
    if type(profile[legacy])=="boolean" then talent[current]=profile[legacy] end
  end
  if type(profile.zta_popup)=="number" then talent.autoOpen=profile.zta_popup>0 end
  root.migration.talentImported=true
end

function Database:Initialize()
  if type(ZygorGuidesViewerWotLKSettings)~="table" then ZygorGuidesViewerWotLKSettings={} end
  local root=fill(ZygorGuidesViewerWotLKSettings,defaults)
  local charKey=self:CharacterKey()
  local profileKey=root.profileKeys[charKey] or "Default"
  root.profileKeys[charKey]=profileKey
  root.profiles[profileKey]=self:EnsureProfile(root.profiles[profileKey])
  root.chars[charKey]=root.chars[charKey] or {}
  ZGV.db={ root=root, profile=root.profiles[profileKey], char=root.chars[charKey], global=root.global, profileKey=profileKey, charKey=charKey }
  local diagnostics=root.global.diagnostics
  diagnostics.entries=type(diagnostics.entries)=="table" and diagnostics.entries or {}
  diagnostics.errors=type(diagnostics.errors)=="table" and diagnostics.errors or {}
  diagnostics.currentSession=ZGV.diagnosticSession or diagnostics.currentSession or "bootstrap"
  self:ImportLegacy(rawget(_G,"ZygorGuidesViewerSettings"))
  if rawget(_G,"ZygorTalentAdvisorSettings") then self:ImportLegacyTalentAdvisorSettings(ZygorTalentAdvisorSettings) end
  for i=1,#ZGV.Errors do root.global.diagnostics.errors[#root.global.diagnostics.errors+1]=ZGV.Errors[i] end
  for i=1,#ZGV.Diagnostics do root.global.diagnostics.entries[#root.global.diagnostics.entries+1]=ZGV.Diagnostics[i] end
end

function ZGV:ImportLegacyTalentAdvisorSettings(old) return Database:ImportLegacyTalentAdvisorSettings(old) end
ZGV.Migration=Database
