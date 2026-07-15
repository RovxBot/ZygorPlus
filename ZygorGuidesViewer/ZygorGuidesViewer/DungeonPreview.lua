-- WotLK-safe replacement for the Anniversary PointerMap preview.  The
-- source artwork is retained, but the frame uses the build-12340 instance
-- ID returned by GetInstanceInfo instead of retail UiMapIDs/MapCanvas.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Preview=ZGV:RegisterModule("PointerMap",{Instances={},CurrentLevel=1})
ZGV.PointerMap=Preview

local function floor(file,name,both) return {file=file,name=name,both=both} end
Preview.Instances={
  [48]={name="Blackfathom Deeps",floor("blackfathomdeeps","Blackfathom Deeps")},
  [230]={name="Blackrock Depths",floor("blackrockdepths-db","Detention Block"),floor("blackrockdepths-sf","Shadowforge City",true)},
  [229]={name="Blackrock Spire",floor("lbrs-1","Lower Spire - part 1"),floor("lbrs-2","Lower Spire - part 2",true),floor("lbrs-3","Lower Spire - part 3"),floor("lbrs-4","Lower Spire - part 4"),floor("ubrs","Upper Spire")},
  [36]={name="The Deadmines",floor("deadmines","The Deadmines",true)},
  [429]={name="Dire Maul",floor("diremaul-east-up","Dire Maul East - Upstairs",true),floor("diremaul-east-down","Dire Maul East - Downstairs",true),floor("diremaul-west","Dire Maul West",true),floor("diremaul-north","Dire Maul North",true)},
  [90]={name="Gnomeregan",floor("gnomeregan","Gnomeregan")},
  [349]={name="Maraudon",floor("maraudon","Maraudon",true)},
  [389]={name="Ragefire Chasm",floor("ragefirechasm","Ragefire Chasm",true)},
  [129]={name="Razorfen Downs",floor("razorfendowns","Razorfen Downs",true)},
  [47]={name="Razorfen Kraul",floor("razorfenkraul","Razorfen Kraul")},
  -- Anniversary used the post-Wrath split IDs 1001/1004 and 1007.  Build
  -- 12340 reports the original Map.dbc IDs 189 and 289.
  [189]={name="Scarlet Monastery",floor("sm-armory","The Armory",true),floor("sm-library","The Library"),floor("sm-cathedral","The Cathedral",true),floor("sm-cemetery","The Graveyard")},
  [289]={name="Scholomance",floor("scholo-up","Main Floor",true),floor("scholo-down","Downstairs",true)},
  [33]={name="Shadowfang Keep",floor("shadowfangkeep","Shadowfang Keep")},
  [34]={name="The Stockade",floor("stockade","The Stockade",true)},
  [329]={name="Stratholme",floor("stratholme-living","Living Side",true),floor("stratholme-undead","Undead Side",true)},
  [109]={name="The Temple of Atal'Hakkar",floor("sunkentemple","The Temple of Atal'Hakkar",true)},
  [70]={name="Uldaman",floor("uldaman","Uldaman")},
  [43]={name="Wailing Caverns",floor("wailingcaverns","Wailing Caverns")},
  [209]={name="Zul'Farrak",floor("zulfarrak","Zul'Farrak")},
  [558]={name="Auchenai Crypts",floor("Auchindoun-AuchenaiCrypts","Auchenai Crypts",true)},
  [557]={name="Mana-Tombs",floor("Auchindoun-ManaTombs","Mana-Tombs",true)},
  [556]={name="Sethekk Halls",floor("Auchindoun-SethekkHalls","Sethekk Halls",true)},
  [555]={name="Shadow Labyrinth",floor("Auchindoun-ShadowLabyrinth","Shadow Labyrinth",true)},
  [269]={name="The Black Morass",floor("CavernsOfTime-BlackMorass","The Black Morass",true)},
  [560]={name="Old Hillsbrad Foothills",floor("CavernsOfTime-OldHillsbrad","Old Hillsbrad Foothills",true)},
  [547]={name="The Slave Pens",floor("CoilfangReservoir-SlavePens","The Slave Pens",true)},
  [545]={name="The Steamvault",floor("CoilfangReservoir-Steamvault","The Steamvault",true)},
  [546]={name="The Underbog",floor("CoilfangReservoir-Underbog","The Underbog",true)},
  [542]={name="The Blood Furnace",floor("HellfireCitadel-BloodFurnace","The Blood Furnace",true)},
  [543]={name="Hellfire Ramparts",floor("HellfireCitadel-Ramparts","Hellfire Ramparts",true)},
  [540]={name="The Shattered Halls",floor("HellfireCitadel-ShatteredHalls","The Shattered Halls",true)},
  [552]={name="The Arcatraz",floor("TempestKeep-Arcatraz","The Arcatraz",true)},
  [553]={name="The Botanica",floor("TempestKeep-Botanica","The Botanica",true)},
  [554]={name="The Mechanar",floor("TempestKeep-Mechanar","The Mechanar",true)},
}

local function settings()
  local profile=ZGV.db and ZGV.db.profile or {}
  return profile.preview~=false,tonumber(profile.preview_alpha) or .92,tonumber(profile.preview_scale) or .75
end

local function setSize(frame,width,height)
  local ui=ZGV.Compat and ZGV.Compat.UI
  if ui and ui.SetSize then ui:SetSize(frame,width,height) else frame:SetWidth(width); frame:SetHeight(height) end
end

function Preview:CreateFrame()
  if self.Frame then return self.Frame end
  local frame=CreateFrame("Frame","ZygorGuidesViewerDungeonPreview",UIParent)
  setSize(frame,772,539)
  frame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",24,-96)
  frame:SetFrameStrata("HIGH")
  frame:SetMovable(true); frame:EnableMouse(true); frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",function(self) self:StartMoving() end)
  frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
  frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  frame:SetBackdropColor(.025,.025,.025,.96); frame:SetBackdropBorderColor(.28,.28,.28,1)

  local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormal")
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-9); title:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-90,-9)
  title:SetJustifyH("LEFT"); frame.title=title
  local floorTitle=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
  floorTitle:SetPoint("TOP",frame,"TOP",0,-10); frame.floorTitle=floorTitle

  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton")
  close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",1,1)
  close:SetScript("OnClick",function() Preview:HidePreview(true) end)

  local previous=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  setSize(previous,25,20); previous:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-57,-6); previous:SetText("<")
  previous:SetScript("OnClick",function() Preview:ShowPreview(Preview.CurrentMap,(Preview.CurrentLevel or 1)-1) end)
  frame.previous=previous
  local nextButton=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  setSize(nextButton,25,20); nextButton:SetPoint("LEFT",previous,"RIGHT",2,0); nextButton:SetText(">")
  nextButton:SetScript("OnClick",function() Preview:ShowPreview(Preview.CurrentMap,(Preview.CurrentLevel or 1)+1) end)
  frame.nextButton=nextButton

  local image=frame:CreateTexture(nil,"ARTWORK")
  image:SetPoint("TOPLEFT",frame,"TOPLEFT",11,-30); setSize(image,750,500)
  image:SetTexCoord(0,1,0,683/1024); frame.ImageTexture=image
  frame:Hide(); self.Frame=frame
  self:UpdateSettings()
  return frame
end

function Preview:UpdateSettings()
  if not self.Frame then return end
  local _,alpha,scale=settings()
  self.Frame:SetAlpha(alpha); self.Frame:SetScale(scale)
end

function Preview:ShowPreview(instanceID,level)
  instanceID=tonumber(instanceID) or select(8,GetInstanceInfo())
  local data=self.Instances[instanceID]
  if not data then return false,"unsupported_instance" end
  if self.CurrentMap~=instanceID then level=level or 1 end
  level=math.max(1,math.min(#data,tonumber(level) or self.CurrentLevel or 1))
  local floorData=data[level]
  if not floorData then return false,"unsupported_floor" end
  local frame=self:CreateFrame()
  local faction=floorData.both and "both" or string.lower(UnitFactionGroup("player") or "Alliance")
  local texture=ZGV.IMAGESDIR.."Dungeons\\"..floorData.file.."-"..faction
  frame.ImageTexture:SetTexture(texture)
  frame.title:SetText(data.name)
  frame.floorTitle:SetText((floorData.name or ("Floor "..level))..(#data>1 and ("  "..level.."/"..#data) or ""))
  if level>1 then frame.previous:Show() else frame.previous:Hide() end
  if level<#data then frame.nextButton:Show() else frame.nextButton:Hide() end
  self.CurrentMap,self.CurrentLevel=instanceID,level
  self.hiddenInstance=nil
  self:UpdateSettings(); frame:Show()
  return true,texture
end

function Preview:HidePreview(manual)
  if self.Frame then self.Frame:Hide() end
  if manual then self.hiddenInstance=self.CurrentMap end
end

function Preview:IsPreviewShown() return self.Frame and self.Frame:IsShown() or false end
function Preview:FadeOut() if self.Frame and self.Frame:IsShown() then self.Frame:SetAlpha(.45) end end
function Preview:FadeIn() local _,alpha=settings(); if self.Frame and self.Frame:IsShown() then self.Frame:SetAlpha(alpha) end end

function Preview:ShouldShowPreview()
  local enabled=settings()
  if not enabled then return false,"disabled" end
  local _,instanceType,_,_,_,_,_,instanceID=GetInstanceInfo()
  if instanceType~="party" and instanceType~="raid" then return false,"not_instance" end
  if not self.Instances[tonumber(instanceID)] then return false,"no_artwork" end
  if self.hiddenInstance==tonumber(instanceID) then return false,"manually_hidden" end
  if not (ZGV.Runtime and ZGV.Runtime.currentGuide) then return false,"no_guide" end
  return true,tonumber(instanceID)
end

function Preview:Refresh()
  local show,instanceID=self:ShouldShowPreview()
  if show then return self:ShowPreview(instanceID) end
  self:HidePreview(false); return false,instanceID
end

function Preview:OnEvent(event)
  if event=="PLAYER_STARTED_MOVING" then return self:FadeOut() end
  if event=="PLAYER_STOPPED_MOVING" then return self:FadeIn() end
  if event=="ZONE_CHANGED_NEW_AREA" or event=="PLAYER_ENTERING_WORLD" then self.hiddenInstance=nil end
  return self:Refresh()
end

function Preview:OnStartup() self:CreateFrame(); self:Refresh() end
ZGV:RegisterEvent("PLAYER_ENTERING_WORLD",Preview,"OnEvent")
ZGV:RegisterEvent("ZONE_CHANGED_NEW_AREA",Preview,"OnEvent")
ZGV:RegisterEvent("PLAYER_STARTED_MOVING",Preview,"OnEvent")
ZGV:RegisterEvent("PLAYER_STOPPED_MOVING",Preview,"OnEvent")
ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",Preview,"Refresh")
