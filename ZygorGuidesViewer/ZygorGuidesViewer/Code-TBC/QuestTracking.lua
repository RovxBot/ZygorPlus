-- QuestTracking.lua already exposes the Anniversary cache/event facade.  This
-- loaded mirror intentionally keeps the same root object rather than creating
-- another quest-log scanner or another set of events.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local Tracking=ZGV and ZGV.QuestTracking
if type(Tracking)~="table" then return end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.QuestTracking=Tracking
