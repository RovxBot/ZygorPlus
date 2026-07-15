-- Legacy-safe heartbeat frame.  The modern runtime has its own timers, but
-- several migrated systems still need the original MasterFrame lifecycle.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

function ZGV:MasterFramePulse(elapsed)
  self.masterElapsed=(self.masterElapsed or 0)+(tonumber(elapsed) or 0)
  if self.masterElapsed<.05 then return end
  local tick=self.masterElapsed
  self.masterElapsed=0
  self:Fire("ZGV_MASTER_UPDATE",tick)
end

function ZygorGuidesViewerFrameMaster_OnLoad(frame)
  ZGV.MasterFrame=frame
  frame:SetAlpha(0) -- it is a heartbeat owner, never a visible UI square.
end

function ZygorGuidesViewerFrameMaster_OnUpdate(_,elapsed)
  ZGV:MasterFramePulse(elapsed)
end
