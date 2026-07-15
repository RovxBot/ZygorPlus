-- Directly ported from the modern viewer's Retrofit.lua.  The modern module
-- uses this narrow surface instead of assuming a particular Classic client.
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer

ZGV.Retrofit = ZGV.Retrofit or {}
ZGV.Retrofit.C_Spell = ZGV.Retrofit.C_Spell or {}

ZGV.Retrofit.C_Spell.GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or function(spellID)
  local name, rank, iconID, castTime, minRange, maxRange, resolvedID, originalIconID = GetSpellInfo(spellID)
  return {
    name = name,
    rank = nil,
    iconID = iconID,
    castTime = castTime,
    minRange = minRange,
    maxRange = maxRange,
    spellID = resolvedID or spellID,
    originalIconID = originalIconID,
  }
end

ZGV.Retrofit.C_Spell.GetSpellCooldown = C_Spell and C_Spell.GetSpellCooldown or function(spellID)
  local startTime, duration, isEnabled, modRate = GetSpellCooldown(spellID)
  return {
    startTime = startTime,
    duration = duration,
    isEnabled = isEnabled,
    modRate = modRate,
  }
end
