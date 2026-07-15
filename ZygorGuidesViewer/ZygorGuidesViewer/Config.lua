-- Profile normalisation for the standalone WotLK database.  The Anniversary
-- module used AceDB profile switching; the port stores the same concepts in
-- Database.lua, so this layer preserves the legacy public Config:Run API.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Config=ZGV:RegisterModule("Config",{})

function Config:Run()
  local db=ZGV.db
  if not db or not db.root then return false,"database unavailable" end
  local root,charKey=db.root,db.charKey
  local selected=root.profileKeys and root.profileKeys[charKey]
  local current=root.profiles and root.profiles[selected]

  -- Honour an imported/default profile exactly once, without deleting any
  -- profile data that belongs to another character.
  if current and not current.usernamed then
    for name,profile in pairs(root.profiles or {}) do
      if profile.is_default then
        selected=name
        current=ZGV.Database and ZGV.Database.EnsureProfile and ZGV.Database:EnsureProfile(profile) or profile
        root.profiles[name]=current
        root.profileKeys[charKey]=name
        db.profileKey=name
        db.profile=profile
        break
      end
    end
    current.usernamed=true
  end
  if db.char then db.char.profile_selected=true end
  if current and current.ranconfig2 and root.global then root.global.saw_tutorial=true end
  return true
end

function Config:OnStartup() self:Run() end
