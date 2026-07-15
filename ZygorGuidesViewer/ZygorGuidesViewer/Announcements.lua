-- Optional level-up announcements, migrated from the Classic Announcements
-- module with per-character timing persisted by the WotLK database.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Announcements=ZGV:RegisterModule("Announcements",{})

function Announcements:FormatTime(seconds)
  seconds=math.max(0,tonumber(seconds) or 0)
  local days=math.floor(seconds/86400)
  local hours=math.floor((seconds%86400)/3600)
  local minutes=math.floor((seconds%3600)/60)
  if days>0 then return string.format("%d days %d hours %d minutes",days,hours,minutes) end
  if hours>0 then return string.format("%d hours %d minutes",hours,minutes) end
  return string.format("%d minutes",minutes)
end

function Announcements:FormatMessage(fromLevel,toLevel,elapsed)
  return string.format("Zygor Guides: I just leveled up from %d to %d! (%s)",fromLevel,toLevel,self:FormatTime(elapsed))
end

function Announcements:SendMessage(message)
  local settings=ZGV.db.profile.announcements
  if not settings.levelUp or not SendChatMessage then return false end
  if settings.emote then SendChatMessage(message,"EMOTE") end
  if settings.party and GetNumPartyMembers and GetNumPartyMembers()>0 then SendChatMessage(message,"PARTY") end
  if settings.guild and IsInGuild and IsInGuild() then SendChatMessage(message,"GUILD") end
  return true
end

function Announcements:OnEvent(event,level)
  if event~="PLAYER_LEVEL_UP" then return end
  local character=ZGV.db.char
  local now=GetTime()
  local previous=tonumber(level) and tonumber(level)-1 or (self.lastLevel or UnitLevel("player")-1)
  local started=character.levelStartedAt or self.levelStartedAt or now
  local elapsed=math.max(0,now-started)
  character.timePerLevel=character.timePerLevel or {}
  character.timePerLevel[previous]=elapsed
  character.levelStartedAt=now
  self.levelStartedAt=now
  self.lastLevel=tonumber(level) or UnitLevel("player")
  self:SendMessage(self:FormatMessage(previous,self.lastLevel,elapsed))
  ZGV:Fire("ZGV_LEVEL_ANNOUNCEMENT",previous,self.lastLevel,elapsed)
end

function Announcements:OnStartup()
  self.lastLevel=UnitLevel("player") or 1
  self.levelStartedAt=ZGV.db.char.levelStartedAt or GetTime()
  ZGV.db.char.levelStartedAt=self.levelStartedAt
end

ZGV:RegisterEvent("PLAYER_LEVEL_UP",Announcements,"OnEvent")
