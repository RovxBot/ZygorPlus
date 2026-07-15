-- Build-12340 progression constants.  The table keeps the legacy Zygor
-- convention: ExpToLevel[N] is the experience needed to advance from N-1
-- to N (the server/DBC source is indexed by the current level instead).
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local xpForCurrentLevel={
  400,900,1400,2100,2800,3600,4500,5400,6500,7600,
  8700,9800,11000,12300,13600,15000,16400,17800,19300,20800,
  22400,24000,25500,27200,28900,30500,32200,33900,36300,38800,
  41600,44600,48000,51400,55000,58700,62400,66200,70200,74300,
  78500,82800,87100,91600,96300,101000,105800,110700,115700,120900,
  126100,131500,137000,142500,148200,154000,159900,165800,172000,
  290000,317000,349000,386000,428000,475000,527000,585000,648000,717000,
  1523800,1539600,1555700,1571800,1587900,1604200,1620700,1637400,1653900,1670800,
}

ZGV.ExpToLevel={}
for currentLevel,experience in ipairs(xpForCurrentLevel) do
  ZGV.ExpToLevel[currentLevel+1]=experience
end

-- Phases.lua in the Anniversary TBC payload is deliberately empty.  Keep
-- the public table without pretending that the pre-Cata client exposes the
-- modern C_Map phase APIs.
ZGV.Phases=ZGV.Phases or {}

ZGV.Data:Register("progression",1,{
  maxLevel=80,
  xpForCurrentLevel=xpForCurrentLevel,
  expToLevel=ZGV.ExpToLevel,
},{
  source="build-12340 player_xp_for_level (levels 1-79)",
  contract="ExpToLevel[targetLevel] matches the legacy viewer convention",
})
