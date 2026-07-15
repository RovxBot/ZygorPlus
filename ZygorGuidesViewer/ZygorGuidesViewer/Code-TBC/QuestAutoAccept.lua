-- Preserve the two Code-TBC gossip hooks without a second event handler.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local QuestAuto=ZGV and ZGV.QuestAutoAccept
if type(QuestAuto)~="table" then return end

if type(ZGV.QuestAutoAccept_InGossip)~="function" then
  function ZGV:QuestAutoAccept_InGossip()
    if type(_G.IsAltKeyDown)=="function" and _G.IsAltKeyDown() then return false,"modifier" end
    return QuestAuto:Gossip()
  end
end
if type(ZGV.QuestAutoTurnin_InGossip)~="function" then
  function ZGV:QuestAutoTurnin_InGossip()
    if type(_G.IsAltKeyDown)=="function" and _G.IsAltKeyDown() then return false,"modifier" end
    return QuestAuto:Gossip()
  end
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.QuestAutoAccept=QuestAuto
