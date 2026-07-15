-- Tooltip scanning compatibility from the Classic viewer.  3.3.5a has no
-- modern tooltip-data namespace, so LibGratuity is the authoritative path.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV)~="table" then return end

local Scanner = ZGV.TooltipScanner or {}
ZGV.TooltipScanner = Scanner

local function strip(text)
  return tostring(text or ""):gsub("|c........",""):gsub("|r","")
end

local gratuity = type(LibStub)=="function" and LibStub("LibGratuity-3.0",true) or nil
local function lines()
    local result={}
    if not gratuity or gratuity:NumLines()==0 then return result end
    for index=1,gratuity:NumLines() do
      local left=gratuity:GetLine(index)
      if not left or left==RETRIEVING_ITEM_INFO then return result end
      result[#result+1]=strip(left)
      local right=gratuity:GetLine(index,true)
      if right and right~="" then result[#result+1]=strip(right) end
    end
    return result
end
function Scanner:GetTooltip(itemLink)
  if not gratuity then return {} end
  gratuity:SetHyperlink(itemLink)
  return lines()
end
function Scanner:GetQuestLogItem(kind,index,quest)
  if not gratuity then return nil end
  gratuity:SetQuestLogItem(kind,index,quest)
  local _,link=gratuity.vars.tooltip:GetItem()
  return link
end
function Scanner:GetSpellTooltip(spellID)
  if not gratuity then return {} end
  -- SetSpell takes a spell-book slot, not a spell ID, on build 12340.  Spell
  -- hyperlinks are ID-stable and are understood by the hidden tooltip.
  gratuity:SetHyperlink("spell:"..tostring(spellID))
  return lines()
end
function Scanner:GetUnit(token)
  if not gratuity then return {} end
  gratuity:SetUnit(token)
  return lines()
end
