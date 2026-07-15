-- Detects a selected companion, hunter pet or mounted player and exposes the
-- associated guide through the WotLK notification/runtime surfaces.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Detector=ZGV:RegisterModule("CreatureDetector",{
  mountSpellDatabase={},petIDDatabase={},modelDatabase={},displayDatabase={},registeredHeaders={},
})
Detector.MAX_DETECTED_GUIDES=5

local function register(database,id,guide)
  id=tonumber(id) or id
  if not id or type(guide)~="table" then return end
  local guides=database[id] or {}
  database[id]=guides
  for _,existing in ipairs(guides) do if existing==guide then return end end
  guides[#guides+1]=guide
end

local function npcID(guid)
  if type(guid)~="string" then return nil end
  return tonumber(guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-"))
    or tonumber(guid:match("^Vehicle%-%d+%-%d+%-%d+%-%d+%-(%d+)%-"))
    or tonumber(guid:sub(7,10),16) -- original build-12340 hexadecimal GUIDs
end

local function first(database,id)
  local guides=database[id]
  return guides and guides[1],guides
end

local function profile()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.creatureDetector
end

function Detector:RegisterMountSpell(spellID,guide) register(self.mountSpellDatabase,spellID,guide) end
function Detector:RegisterPetID(petID,guide) register(self.petIDDatabase,petID,guide) end

function Detector:RegisterGuideModel(displayID,guide,fileID)
  register(self.displayDatabase,displayID,guide)
  if fileID then register(self.modelDatabase,fileID,guide) end
end

function Detector:RegisterGuideHeader(guide)
  if type(guide)~="table" or self.registeredHeaders[guide] then return end
  self.registeredHeaders[guide]=true
  local header=guide.header or guide.meta or {}
  local function values(value)
    if type(value)=="table" then return value end
    if value~=nil then return {value} end
    return {}
  end
  for _,spellID in ipairs(values(header.mounts or header.mount)) do self:RegisterMountSpell(spellID,guide) end
  for _,petID in ipairs(values(header.pets or header.pet)) do self:RegisterPetID(petID,guide) end
  for _,displayID in ipairs(values(header.model)) do self:RegisterGuideModel(displayID,guide) end
end

function Detector:Report(kind,guides,owned)
  if type(guides)~="table" or not guides[1] then return nil end
  self.DetectedGuides=guides
  local settings=profile()
  if not settings or not settings.enabled then return guides end
  local guide=guides[1]
  if settings.notify and ZGV.NotificationCenter then
    ZGV.NotificationCenter:Push({
      kind="route",title=(kind=="mount" and "Mount guide found" or "Companion guide found"),
      message=(owned and "Already known: " or "Guide available: ")..tostring(guide.name or guide.title),duration=7,
      action=function() if ZGV.Runtime then ZGV.Runtime:SelectGuide(guide) end end,
    })
  end
  ZGV:Fire("ZGV_CREATURE_DETECTED",kind,guides,owned)
  return guides
end

function Detector:DetectMount(silent)
  if not UnitExists("target") or not UnitIsPlayer("target") then return nil end
  for index=1,40 do
    local name,_,_,_,_,_,_,_,_,_,spellID=UnitBuff("target",index)
    if not name then break end
    local guide,guides=first(self.mountSpellDatabase,spellID)
    if guide then return self:Report("mount",guides,false) end
  end
  if not silent then self.DetectedGuides=nil end
end

function Detector:DetectPet(silent)
  local id=npcID(UnitGUID("target"))
  local guide,guides=first(self.petIDDatabase,id)
  if guide then return self:Report("pet",guides,false) end
  if not silent then self.DetectedGuides=nil end
end
Detector.DetectMinipet=Detector.DetectPet

function Detector:DetectHunterPet(silent)
  if select(2,UnitClass("player"))~="HUNTER" or UnitIsUnit("target","pet") then return nil end
  local targetGUID=UnitGUID("target")
  if not targetGUID or not UnitExists("target") then return nil end
  self.PetMirror=self.PetMirror or CreateFrame("PlayerModel")
  self.PetMirror:Show()
  self.PetMirror:SetUnit("target")
  local fileID=self.PetMirror.GetModelFileID and self.PetMirror:GetModelFileID() or self.PetMirror:GetModel()
  local displayID=self.PetMirror.GetDisplayInfo and self.PetMirror:GetDisplayInfo()
  self.PetMirror:Hide()
  local guide,guides=first(self.modelDatabase,fileID)
  if not guide then guide,guides=first(self.displayDatabase,displayID) end
  if guide then return self:Report("hunterpet",guides,false) end
  if not silent then self.DetectedGuides=nil end
end

function Detector:Detect(force)
  local settings=profile()
  if not settings or not settings.enabled or InCombatLockdown() or not UnitExists("target") then return nil end
  if UnitIsUnit("target","player") then return nil end
  if UnitIsPlayer("target") then return self:DetectMount(not force) end
  local creatureType=UnitCreatureType and UnitCreatureType("target")
  if creatureType=="Non-combat Pet" then return self:DetectPet(not force) end
  local guid=UnitGUID("target") or ""
  if guid:match("^Pet%-") then return self:DetectHunterPet(not force) end
  -- The original 3.3 client uses hexadecimal GUIDs.  Only the pet/minipet
  -- nibbles are detector candidates; ordinary creatures must not be treated
  -- as hunter pets merely because their GUID begins with 0x.
  if guid:sub(1,2)=="0x" then
    local raw=tonumber(guid:sub(3,5),16)
    local band=bit and bit.band
    local kind=raw and (band and band(raw,0x00f) or raw%16)
    if kind==0x003 then return self:DetectPet(not force) end
    if kind==0x004 then return self:DetectHunterPet(not force) end
    return nil
  end
  return nil
end

function Detector:ShowTooltip(parent,anchor,x,y)
  local guides=self.DetectedGuides
  if not guides or not guides[1] then return end
  GameTooltip:SetOwner(parent,anchor or "ANCHOR_CURSOR",x or 0,y or 0)
  if #guides==1 then GameTooltip:SetText(guides[1].title or "Zygor guide")
  else GameTooltip:SetText("Multiple Zygor guides") end
  GameTooltip:AddLine("Click a notification to load the matching guide.",0.7,0.9,1,true)
  GameTooltip:Show()
end

function Detector:OnEvent(event)
  if event=="PLAYER_TARGET_CHANGED" then self:Detect(false) end
end

function Detector:OnStartup()
  -- Content packages have registered by now, but their bodies are intentionally
  -- parsed lazily.  Index guide headers here so target detection works before
  -- a user has opened any particular mount or pet guide.
  local catalog=ZGV.Catalog
  for _,guide in ipairs(catalog and catalog.guides or {}) do self:RegisterGuideHeader(guide) end
  self:Detect(false)
end
ZGV:RegisterEvent("PLAYER_TARGET_CHANGED",Detector,"OnEvent")
