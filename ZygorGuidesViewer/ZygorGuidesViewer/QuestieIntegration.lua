-- Own the boundary with Questie in one place.  Questie and the Blizzard
-- tracker share mutable state on 3.3.5, so callers must ask this adapter at
-- the time of an action instead of caching addon/settings state at login.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Integration=ZGV:RegisterModule("QuestieIntegration",{lastSignature=nil})

local function addonLoaded(name)
  return type(IsAddOnLoaded)=="function" and IsAddOnLoaded(name) and true or false
end

function Integration:GetState()
  local questie=rawget(_G,"Questie")
  local loaded=questie~=nil or addonLoaded("Questie-335") or addonLoaded("Questie")
  local profile=questie and questie.db and questie.db.profile or {}
  return {
    loaded=loaded,
    -- A loaded Questie owns the shared Blizzard quest-watch list even when
    -- its automatic accept/complete options are off.
    ownsWatch=loaded,
    autoAccept=profile.autoaccept==true,
    autoComplete=profile.autocomplete==true,
  }
end

function Integration:Report(action,state,allowed)
  local signature=table.concat({tostring(action),tostring(state.loaded),tostring(state.autoAccept),tostring(state.autoComplete),tostring(allowed)},":")
  if self.lastSignature==signature then return end
  self.lastSignature=signature
  if ZGV.LogEvent then
    ZGV:LogEvent("questie","automation decision",{action=action,loaded=state.loaded,autoAccept=state.autoAccept,autoComplete=state.autoComplete,decision=allowed and "allow" or "suppress"})
  elseif ZGV.LogInfo then
    ZGV:LogInfo("questie",("action=%s loaded=%s autoaccept=%s autocomplete=%s decision=%s"):format(
      tostring(action),tostring(state.loaded),tostring(state.autoAccept),tostring(state.autoComplete),allowed and "allow" or "suppress"))
  end
  ZGV:Fire("ZGV_QUESTIE_DECISION",action,state,allowed)
end

-- Returns true when Zygor may act.  The decision intentionally reads Questie
-- settings on every call, supporting either addon load order and live toggles.
function Integration:CanAutomate(action)
  local state=self:GetState()
  local suppress=(action=="accept" and state.autoAccept)
    or ((action=="progress" or action=="complete" or action=="reward") and state.autoComplete)
    or (action=="gossip" and (state.autoAccept or state.autoComplete))
  local allowed=not suppress
  self:Report(action,state,allowed)
  return allowed,suppress and "questie_automation" or nil,state
end

function Integration:OwnsQuestWatch()
  local state=self:GetState()
  self:Report("watch",state,not state.ownsWatch)
  return state.ownsWatch,state
end
