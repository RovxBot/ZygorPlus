-- Classic-style options model backed by the WotLK profile database.  The
-- frame renderer lives in ModernGuideMenu; this module owns the public option
-- API so menu rows, slash commands and Blizzard's Interface Options entry all
-- change the same live settings without retail-only AceConfig dependencies.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Options=ZGV:RegisterModule("Options",{})
local defaults={
  map={showCoords=true,poiEnabled=true,poiMode="quick",hideTypes={rare=false,treasure=false},mapIcons=true,minimapIcons=true},
  pointer={audio=true,meters=false,freeze=false,showMinimap=true,showWorldMap=true,showLines=true,autoCorpse=true},
}

-- The Anniversary options panel is part of the Guide Menu, rather than a
-- handful of unrelated toggles.  Keep the data model independent from the
-- frame implementation so the same supported settings are available to the
-- menu, slash commands and headless compatibility tests.
local optionGroups={
  {id="display",label="Display",description="Viewer appearance, size and position.",options={
    {label="Show guide viewer",path={"viewer","shown"},type="toggle"},
    {label="Lock viewer position",path={"viewer","locked"},type="toggle"},
    {label="Glass viewer skin",path={"opacitytoggle"},type="toggle",skin=true},
    {label="Viewer scale",path={"viewer","scale"},type="range",min=.5,max=1.6,step=.1,format="%.1fx"},
    {label="Visible objective rows",path={"viewer","rows"},type="range",min=3,max=12,step=1,format="%d"},
    {label="Viewer opacity",path={"viewer","opacity"},type="range",min=.3,max=1,step=.1,format="%d%%",percent=true},
  }},
  {id="stepdisplay",label="Step Display",description="Guide step progress and objective presentation.",options={
    {label="Automatically advance completed steps",path={"automation","progress"},type="toggle"},
    {label="Enable quest progress tracking",path={"tracking","enabled"},type="toggle"},
    {label="Use Blizzard quest watch list",path={"tracking","watchActive"},type="toggle",description="Leave disabled when Questie owns the shared watch list."},
    {label="Show travel route lines",path={"pointer","showLines"},type="toggle"},
    {label="Show item counts in bags",path={"inventory","showBagSpace"},type="toggle"},
    {label="Show Magic Key reminder",path={"viewer","magicKeyHint"},type="toggle",description="Display the optional Magic Key prompt outside the guide viewer."},
    {label="Play navigation audio cues",path={"pointer","audio"},type="toggle"},
  }},
  {id="automation",label="Automation",description="Quest, gossip and vendor assistance.",options={
    {label="Automatically accept guide quests",path={"automation","accept"},type="toggle"},
    {label="Automatically complete quest progress",path={"automation","progress"},type="toggle"},
    {label="Automatically turn in guide quests",path={"automation","turnin"},type="toggle"},
    {label="Automatically select guide gossip",path={"automation","gossip"},type="toggle"},
    {label="Automatically repair at vendors",path={"automation","repair"},type="toggle"},
    {label="Automatically sell grey items",path={"automation","sellGreys"},type="toggle"},
    {label="Automatically equip quest upgrades",path={"gear","autoEquip"},type="toggle"},
    {label="Automatically choose suggested reward",path={"automation","autoSelectReward"},type="toggle"},
    {label="Highlight suggested quest reward",path={"automation","questRewardHint"},type="toggle"},
  }},
  {id="actionbuttons",label="Action Buttons",description="Guide item, talk, kill and quest action buttons.",options={
    {label="Enable guide action bar",path={"actionbar","enabled"},type="toggle"},
    {label="Lock action bar",path={"actionbar","locked"},type="toggle"},
    {label="Hide action bar in combat",path={"actionbar","hideInCombat"},type="toggle"},
    {label="Show quest actions",path={"actionbar","quest"},type="toggle"},
    {label="Show talk actions",path={"actionbar","talk"},type="toggle"},
    {label="Show kill actions",path={"actionbar","kill"},type="toggle"},
    {label="Show discard actions",path={"actionbar","trash"},type="toggle"},
    {label="Action bar scale",path={"actionbar","scale"},type="range",min=.6,max=1.8,step=.1,format="%.1fx"},
    {label="Action bar direction",path={"actionbar","direction"},type="select",values={1,2,3,4},labels={"Right","Down","Left","Up"}},
  }},
  {id="travelsystem",label="Waypoint Arrow",description="Arrow, route and waypoint behaviour.",options={
    {label="Enable navigation",path={"navigation","enabled"},type="toggle"},
    {label="Show waypoint arrow",path={"arrow","shown"},type="toggle"},
    {label="Send waypoints to TomTom",path={"navigation","useTomTom"},type="toggle"},
    {label="Recommend learned flight paths",path={"navigation","useTaxi"},type="toggle"},
    {label="Recommend Hearthstone",path={"navigation","useHearth"},type="toggle"},
    {label="Recommend Astral Recall",path={"navigation","useAstralRecall"},type="toggle"},
    {label="Recommend travel items",path={"navigation","useTravelItems"},type="toggle"},
    {label="Show route on world map",path={"pointer","showWorldMap"},type="toggle"},
    {label="Show route on minimap",path={"pointer","showMinimap"},type="toggle"},
    {label="Freeze arrow position",path={"pointer","freeze"},type="toggle"},
    {label="Display metres instead of yards",path={"pointer","meters"},type="toggle"},
    {label="Point to corpse after death",path={"pointer","autoCorpse"},type="toggle"},
    {label="Arrow scale",path={"arrow","scale"},type="range",min=.6,max=1.8,step=.1,format="%.1fx"},
    {label="Arrival distance",path={"arrow","arrival"},type="range",min=5,max=50,step=5,format="%d yd"},
  }},
  {id="maps",label="Maps & POIs",description="World map, minimap and point-of-interest overlays.",options={
    {label="Show player map coordinates",path={"map","showCoords"},type="toggle"},
    {label="Enable points of interest",path={"map","poiEnabled"},type="toggle"},
    {label="Show route and POIs on world map",path={"map","mapIcons"},type="toggle"},
    {label="Show route and POIs on minimap",path={"map","minimapIcons"},type="toggle"},
    {label="Hide rare-creature markers",path={"map","hideTypes","rare"},type="toggle"},
    {label="Hide treasure markers",path={"map","hideTypes","treasure"},type="toggle"},
  }},
  {id="notifications",label="Notifications",description="Toast, creature and level-up notifications.",options={
    {label="Enable notifications",path={"notifications","enabled"},type="toggle"},
    {label="Show toast notifications",path={"notifications","toast"},type="toggle"},
    {label="Toast duration",path={"notifications","duration"},type="range",min=2,max=12,step=1,format="%d sec"},
    {label="Open notification history",type="action",action="notificationHistory",valueLabel="Open"},
    {label="Enable creature detector",path={"creatureDetector","enabled"},type="toggle"},
    {label="Notify for detected creatures",path={"creatureDetector","notify"},type="toggle"},
    {label="Announce level ups",path={"announcements","levelUp"},type="toggle"},
    {label="Level-up emote",path={"announcements","emote"},type="toggle"},
    {label="Announce level ups to party",path={"announcements","party"},type="toggle"},
    {label="Announce level ups to guild",path={"announcements","guild"},type="toggle"},
  }},
  {id="gear",label="Gear Advisor",description="Upgrade scoring and equipment recommendations.",options={
    {label="Enable Gear Advisor",path={"gear","enabled"},type="toggle"},
    {label="Show upgrade notifications",path={"gear","notifications"},type="toggle"},
    {label="Automatically equip upgrades",path={"gear","autoEquip"},type="toggle"},
    {label="Preferred role",path={"gear","role"},type="select",values={false,"melee","caster","healer","tank"},labels={"Automatic","Physical damage","Spell damage","Healer","Tank"}},
    {label="Custom stat weights",type="action",action="gearWeights",valueLabel="Edit"},
  }},
  {id="talents",label="Talent Advisor",description="WotLK build recommendations, hints and learning safety.",options={
    {label="Open Talent Advisor",type="action",action="talentAdvisor",valueLabel="Open"},
    {label="Enable Talent Advisor",path={"talent","enabled"},type="toggle"},
    {label="Show recommendation arrows",path={"talent","hints"},type="toggle"},
    {label="Show current / build rank overlays",path={"talent","rankPreview"},type="toggle"},
    {label="Open with Blizzard talent window",path={"talent","autoOpen"},type="toggle"},
    {label="Dock advisor to talent window",path={"talent","docked"},type="toggle"},
    {label="Confirm before learning a talent",path={"talent","confirmLearn"},type="toggle"},
    {label="Continue suggestions while off build",path={"talent","forceBuild"},type="toggle"},
  }},
  {id="gold",label="Gold Guide",description="Auction scanning, opportunities and posting defaults.",options={
    {label="Auction posting duration",path={"gold","post","duration"},type="select",values={12,24,48},labels={"12 hours","24 hours","48 hours"}},
    {label="Default stack size",path={"gold","post","stackSize"},type="range",min=1,max=20,step=1,format="%d"},
    {label="Default stack count",path={"gold","post","stackCount"},type="range",min=1,max=20,step=1,format="%d"},
    {label="Minimum opportunity discount",path={"gold","opportunities","minDiscount"},type="range",min=.05,max=.5,step=.05,format="%d%%",percent=true},
  }},
  {id="extras",label="Extras",description="Sync, widgets, skills and auxiliary viewer features.",options={
    {label="Enable group sync",path={"sync","enabled"},type="toggle"},
    {label="Sync role",path={"sync","mode"},type="select",values={"off","master","slave"},labels={"Off","Master","Follow master"},description="Sync only sends or accepts state after you explicitly choose a role."},
    {label="Accept party sync",path={"sync","acceptParty"},type="toggle"},
    {label="Accept raid sync",path={"sync","acceptRaid"},type="toggle"},
    {label="Accept whisper sync",path={"sync","acceptWhisper"},type="toggle"},
    {label="Broadcast guide progress",path={"sync","announce"},type="toggle"},
    {label="Wait for synced party progress",path={"sync","magnetic"},type="toggle"},
    {label="Enable skill notifications",path={"skills","enabled"},type="toggle"},
    {label="Show skill toasts",path={"skills","toast"},type="toggle"},
    {label="Enable creature model viewer",path={"creatureViewer","enabled"},type="toggle"},
    {label="Rotate creature models",path={"creatureViewer","rotation"},type="toggle"},
    {label="Creature model slideshow",path={"creatureViewer","slideshow"},type="toggle"},
    {label="Creature preview zoom",path={"creatureViewer","zoom"},type="range",min=.35,max=2.5,step=.05,format="%.2fx"},
    {label="Run viewer tutorial",type="action",action="tutorial",valueLabel="Start"},
  }},
  {id="about",label="Profiles & About",description="Profile, diagnostics and reset tools.",options={
    {label="Active profile",type="profile"},
    {label="Create a copy of this profile",type="action",action="copyProfile",valueLabel="Create"},
    {label="Reset viewer position",type="action",action="resetViewer",valueLabel="Run"},
    {label="Reset arrow position",type="action",action="resetArrow",valueLabel="Run"},
    {label="Open diagnostics report",type="action",action="diagnostics",valueLabel="Open"},
  }},
}

local function copy(source)
  if type(source)~="table" then return source end
  local result={}
  for key,value in pairs(source) do result[key]=copy(value) end
  return result
end

local function fill(target,source)
  for key,value in pairs(source) do
    if target[key]==nil then target[key]=copy(value)
    elseif type(target[key])=="table" and type(value)=="table" then fill(target[key],value) end
  end
end

function Options:EnsureDefaults()
  if not (ZGV.db and ZGV.db.profile) then return false end
  fill(ZGV.db.profile,defaults)
  local profile=ZGV.db.profile
  -- Legacy names remain aliases for data imported from either old viewer.
  if profile.poienabled~=nil then profile.map.poiEnabled=profile.poienabled end
  if profile.mapcoords~=nil then profile.map.showCoords=profile.mapcoords end
  if profile.minicons~=nil then profile.map.minimapIcons=profile.minicons end
  if profile.mapicons~=nil then profile.map.mapIcons=profile.mapicons end
  profile.poienabled=profile.map.poiEnabled
  profile.mapcoords=profile.map.showCoords
  profile.minicons=profile.map.minimapIcons
  profile.mapicons=profile.map.mapIcons
  return true
end

local function resolvePath(root,path,create)
  if type(root)~="table" or type(path)~="table" or #path==0 then return nil,nil end
  local parent=root
  for index=1,#path-1 do
    local key=path[index]
    if type(parent[key])~="table" then
      if not create then return nil,nil end
      parent[key]={}
    end
    parent=parent[key]
  end
  return parent,path[#path]
end

function Options:GetGroups()
  return optionGroups
end

function Options:GetGroup(id)
  id=tostring(id or ""):lower()
  local aliases={viewer="display",steps="stepdisplay",navigation="travelsystem",map="maps",poi="maps",actionbar="actionbuttons",talent="talents",zta="talents"}
  id=aliases[id] or id
  for _,group in ipairs(optionGroups) do if group.id==id then return group end end
end

function Options:GetValue(option)
  if not option or not option.path then return nil end
  local parent,key=resolvePath(ZGV.db and ZGV.db.profile,option.path,false)
  return parent and parent[key] or nil
end

function Options:GetValueText(option)
  if not option then return "" end
  if option.type=="profile" then return tostring(ZGV.db and ZGV.db.profileKey or "Default") end
  if option.type=="action" then return option.valueLabel or "Run" end
  local value=self:GetValue(option)
  if option.type=="toggle" then return value and "ON" or "OFF" end
  if option.type=="select" then
    for index,candidate in ipairs(option.values or {}) do
      if candidate==value then return tostring(option.labels and option.labels[index] or candidate) end
    end
    return tostring(value or option.labels and option.labels[1] or "Automatic")
  end
  local number=tonumber(value) or tonumber(option.min) or 0
  if option.percent then number=number*100 end
  return option.format and option.format:format(number) or tostring(number)
end

function Options:RunAction(action)
  local profile=ZGV.db and ZGV.db.profile
  if not profile then return false,"profile unavailable" end
  if action=="copyProfile" then
    if not (ZGV.Database and ZGV.Database.CopyProfile) then return false,"profile service unavailable" end
    local ok,name=ZGV.Database:CopyProfile()
    if not ok then return false,name end
  elseif action=="resetViewer" then
    profile.viewer.x,profile.viewer.y,profile.viewer.scale=-260,40,1
    profile.viewer.width,profile.viewer.height=340,155
    profile.viewer.autoHeight,profile.viewer.layoutVersion=true,2
    local frame=ZGV.UI and ZGV.UI.frame
    if frame then frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",profile.viewer.x,profile.viewer.y); frame:SetScale(1); frame:SetWidth(340); frame:SetHeight(155) end
  elseif action=="resetArrow" then
    profile.arrow.x,profile.arrow.y,profile.arrow.scale=0,-120,1
    local frame=ZGV.UI and (ZGV.UI.arrow or ZGV.UI.arrowFrame)
    if frame then frame:ClearAllPoints(); frame:SetPoint("CENTER",UIParent,"CENTER",profile.arrow.x,profile.arrow.y); frame:SetScale(1) end
  elseif action=="diagnostics" then
    if ZGV.GuideMenu and ZGV.GuideMenu.frame then ZGV.GuideMenu.frame:Hide() end
    if ZGV.UI and ZGV.UI.ShowReport then ZGV.UI:ShowReport() end
  elseif action=="talentAdvisor" then
    if ZGV.GuideMenu and ZGV.GuideMenu.frame then ZGV.GuideMenu.frame:Hide() end
    if ZGV.TalentAdvisor and ZGV.TalentAdvisor.OpenOptions then ZGV.TalentAdvisor:OpenOptions()
    else return false,"talent advisor unavailable" end
  elseif action=="gearWeights" then
    if ZGV.GuideMenu and ZGV.GuideMenu.frame then ZGV.GuideMenu.frame:Hide() end
    if ZGV.GearAdvisor and ZGV.GearAdvisor.ShowWeightEditor then ZGV.GearAdvisor:ShowWeightEditor()
    else return false,"gear advisor unavailable" end
  elseif action=="notificationHistory" then
    if ZGV.NotificationCenter and ZGV.NotificationCenter.ShowHistory then ZGV.NotificationCenter:ShowHistory()
    else return false,"notification history unavailable" end
  elseif action=="tutorial" then
    if ZGV.Tutorial and ZGV.Tutorial.Run then ZGV.Tutorial:Run()
    else return false,"tutorial unavailable" end
  else return false,"unknown action" end
  self:Apply()
  return true
end

function Options:Activate(option,reverse)
  if not option then return false,"missing option" end
  if option.type=="action" then return self:RunAction(option.action) end
  if option.type=="profile" then
    if not (ZGV.Database and ZGV.Database.GetProfileNames) then return false,"profile service unavailable" end
    local profiles,index=ZGV.Database:GetProfileNames(),1
    if #profiles==0 then return false,"no profiles" end
    for candidate,name in ipairs(profiles) do if name==ZGV.db.profileKey then index=candidate break end end
    index=index+(reverse and -1 or 1)
    if index>#profiles then index=1 elseif index<1 then index=#profiles end
    local ok,errorMessage=ZGV.Database:SetProfile(profiles[index])
    if not ok then return false,errorMessage end
    self:Apply()
    return true,profiles[index]
  end
  local parent,key=resolvePath(ZGV.db and ZGV.db.profile,option.path,true)
  if not parent then return false,"invalid option path" end
  local value=parent[key]
  if option.type=="toggle" then
    parent[key]=not value
  elseif option.type=="range" then
    local step=tonumber(option.step) or 1
    local minimum,maximum=tonumber(option.min) or 0,tonumber(option.max) or 1
    local nextValue=(tonumber(value) or minimum)+(reverse and -step or step)
    if nextValue>maximum then nextValue=minimum elseif nextValue<minimum then nextValue=maximum end
    -- Avoid accumulating floating point tails in SavedVariables and labels.
    parent[key]=math.floor(nextValue*1000+.5)/1000
  elseif option.type=="select" then
    local values,index=option.values or {},1
    for candidateIndex,candidate in ipairs(values) do if candidate==value then index=candidateIndex break end end
    index=index+(reverse and -1 or 1)
    if index>#values then index=1 elseif index<1 then index=#values end
    parent[key]=values[index]
  else return false,"unsupported option type" end
  if option.skin then
    local profile=ZGV.db.profile
    local style=(profile.skinstyle or "starlight"):gsub("%-glass$","")
    if profile.opacitytoggle then style=style.."-glass" end
    ZGV:SetSkin(profile.skin,style)
  end
  self:Apply()
  return true,parent[key]
end

function Options:Apply()
  self:EnsureDefaults()
  if ZGV.MapCoords then ZGV.MapCoords:HandleWorldmapCoords() end
  if ZGV.Poi then ZGV.Poi:ChangeState(ZGV.db.profile.map.poiEnabled) end
  if ZGV.Pointer then ZGV.Pointer:ApplyOptions() end
  if ZGV.Navigation then ZGV.Navigation:UpdateMapPin() end
  if ZGV.Sync then
    ZGV.Sync:UpdateMode()
    if ZGV.Sync:IsEnabled() then ZGV.Sync:RequestStatuses() end
  end
  local profile=ZGV.db.profile
  local frame=ZGV.UI and ZGV.UI.frame
  if frame then
    if ZGV.UI.PrepareViewerLayout then ZGV.UI:PrepareViewerLayout(profile.viewer) end
    frame:ClearAllPoints()
    frame:SetPoint("CENTER",UIParent,"CENTER",profile.viewer.x or -260,profile.viewer.y or 40)
    frame:SetWidth(profile.viewer.width or 340)
    frame:SetHeight(profile.viewer.height or 155)
    frame:SetScale(profile.viewer.scale or 1)
    frame:SetAlpha(profile.viewer.opacity or 1)
    if profile.viewer.shown==false then frame:Hide() elseif ZGV.UI.mode=="guide" then frame:Show() end
  end
  local arrow=ZGV.UI and (ZGV.UI.arrow or ZGV.UI.arrowFrame)
  if arrow then
    arrow:ClearAllPoints()
    arrow:SetPoint("CENTER",UIParent,"CENTER",profile.arrow.x or 0,profile.arrow.y or -120)
    arrow:SetScale(profile.arrow.scale or 1)
  end
  if ZGV.ActionBar and ZGV.ActionBar.Refresh then ZGV.ActionBar:Refresh() end
  if ZGV.UI and ZGV.UI.Refresh then ZGV.UI:Refresh()
  elseif ZGV.UI and ZGV.UI.Render then ZGV.UI:Render() end
  ZGV:Fire("ZGV_OPTIONS_CHANGED",ZGV.db.profile)
end

function ZGV:Options_RegisterDefaults() return Options:EnsureDefaults() end

function ZGV:Options_DefineOptionTables()
  self.optiontables={}; self.optiontables_ordered={}
  for index,group in ipairs(optionGroups) do
    self.optiontables[group.id]={name=group.label,description=group.description,options=group.options}
    self.optiontables_ordered[index]={name=group.id,blizname="ZygorGuidesViewer-"..group.id}
  end
  return self.optiontables
end

function ZGV:Options_Initialize()
  Options:EnsureDefaults()
  self:Options_DefineOptionTables()
  return true
end

function ZGV:Options_SetFromMode() return Options:Apply() end
function ZGV:Options_SetupConfig()
  Options:EnsureDefaults()
  return self:Options_DefineOptionTables()
end

function ZGV:Options_SetupBlizConfig()
  if self.blizzardOptionsPanel then return self.blizzardOptionsPanel end
  if type(CreateFrame)~="function" or type(InterfaceOptions_AddCategory)~="function" then return false end
  local panel=CreateFrame("Frame","ZygorGuidesViewerBlizzardOptions",UIParent)
  panel.name="Zygor Guides Viewer"
  panel:SetScript("OnShow",function(frame)
    if frame.initialized then return end
    frame.initialized=true
    local title=frame:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    title:SetPoint("TOPLEFT",frame,"TOPLEFT",16,-16); title:SetText("Zygor Guides Viewer")
    local description=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
    description:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-10); description:SetPoint("RIGHT",frame,"RIGHT",-24,0)
    description:SetJustifyH("LEFT"); description:SetText("Viewer, automation, navigation, notification, gear, gold and profile settings are available in the Classic Guide Menu.")
    local open=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
    open:SetPoint("TOPLEFT",description,"BOTTOMLEFT",0,-18); open:SetWidth(190); open:SetHeight(24); open:SetText("Open Zygor Options")
    open:SetScript("OnClick",function()
      if InterfaceOptionsFrame and InterfaceOptionsFrame.Hide then InterfaceOptionsFrame:Hide() end
      ZGV:OpenOptions("display")
    end)
    local hint=frame:CreateFontString(nil,"ARTWORK","GameFontDisableSmall")
    hint:SetPoint("TOPLEFT",open,"BOTTOMLEFT",0,-10); hint:SetText("Tip: right-click a range or list setting to select the previous value.")
  end)
  InterfaceOptions_AddCategory(panel)
  self.blizzardOptionsPanel=panel
  return panel
end

function ZGV:Options_ResetToDefaults(section)
  Options:EnsureDefaults()
  if section and defaults[section] then ZGV.db.profile[section]=copy(defaults[section])
  else
    for key,value in pairs(defaults) do ZGV.db.profile[key]=copy(value) end
  end
  Options:Apply()
end

function ZGV:OpenOptions(section)
  Options:EnsureDefaults()
  if self.UI and self.UI.ShowOptions then self.UI:ShowOptions(section) end
  self:Fire("ZGV_OPTIONS_OPENED",section)
end

function ZGV:RefreshOptions() return Options:Apply() end

local function setBoolean(value)
  value=tostring(value or ""):lower()
  return value=="on" or value=="true" or value=="1" or value=="yes"
end

function ZGV:SetOption(category,command)
  Options:EnsureDefaults()
  local key,value=tostring(command or ""):match("^%s*(%S+)%s*(.-)%s*$")
  if not key or key=="" then return false,"missing option" end
  key=key:lower()
  local profile=self.db.profile
  local map=profile.map
  if key=="poienabled" then map.poiEnabled=setBoolean(value) profile.poienabled=map.poiEnabled
  elseif key=="mapcoords" or key=="showcoords" then map.showCoords=setBoolean(value) profile.mapcoords=map.showCoords
  elseif key=="minicons" then map.minimapIcons=setBoolean(value) profile.minicons=map.minimapIcons
  elseif key=="mapicons" then map.mapIcons=setBoolean(value) profile.mapicons=map.mapIcons
  elseif key=="arrow" then profile.arrow.shown=setBoolean(value)
  elseif key=="autoturnin" then profile.automation.turnin=setBoolean(value)
  elseif key=="autoaccept" then profile.automation.accept=setBoolean(value)
  else return false,"unknown option" end
  Options:Apply()
  return true
end

function Options:OnStartup()
  ZGV:Options_Initialize()
  ZGV:Options_SetupBlizConfig()
  self:Apply()
end
