-- Source-name localization facade for build 12340.
-- NPC names are learned from the checked-in WotLK location corpus, installed
-- guides, and live units; quest data comes from the authoritative Compat.Quest
-- cache and the legacy hidden-tooltip scanner.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" then return end

local Localizers = ZGV.Localizers or {}
ZGV.Localizers = Localizers
local npcNames, npcIDsByName, questCache = {}, {}, {}
local indexed = false

local function trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function rememberNPC(id, name)
  id, name = tonumber(id), trim(name)
  if not id or name == "" then return end
  local plain, description = name:match("^(.-)|(.*)$")
  plain = trim(plain or name)
  if plain == "" then return end
  npcNames[id] = { name = plain, description = description ~= "" and description or nil }
  npcIDsByName[plain] = id
  npcIDsByName[plain:lower()] = id
end

local function indexNPCNames()
  if indexed then return end
  indexed = true
  for _, blob in pairs(type(ZGV._NPCData) == "table" and ZGV._NPCData or {}) do
    for id, raw in tostring(blob):gmatch("(%d+)=([^\r\n]+)") do
      local name = raw:match(",%s*([^,\r\n]+)%s*$")
      if name then rememberNPC(id, name) end
    end
  end
  for _, guide in ipairs(ZGV.Catalog and ZGV.Catalog.guides or {}) do
    for line in tostring(guide.raw or ""):gmatch("[^\r\n]+") do
      local action, body = line:match("^%s*(%a+)%s+(.+)$")
      if action == "talk" or action == "kill" or action == "clicknpc" then
        local id, name = body:match("##(%d+)"), body:match("^([^#|]+)")
        if id and name then rememberNPC(id, name) end
      end
    end
  end
end

local function observeUnits()
  if type(UnitName) ~= "function" or type(ZGV.GetUnitId) ~= "function" then return end
  for _, unit in ipairs({ "target", "mouseover", "focus" }) do
    local id, name = ZGV.GetUnitId(unit), UnitName(unit)
    if id and name then rememberNPC(id, name) end
  end
end

function Localizers:GetTranslatedNPC(id, fallbackname)
  if not id then return fallbackname end
  indexNPCNames()
  observeUnits()
  local record = npcNames[tonumber(id)]
  local name = record and record.name or fallbackname or ("(npc " .. tostring(id) .. ")")
  return name, record and record.description or nil, record ~= nil
end

function Localizers:FindNPCIdByName(name)
  indexNPCNames()
  observeUnits()
  return npcIDsByName[tostring(name or "")] or npcIDsByName[tostring(name or ""):lower()]
end

function Localizers:PruneNPCs()
  -- The installed WotLK corpus is immutable shared data; pruning it by faction
  -- would make later guide/package loads nondeterministic.
  return false, "immutable_wotlk_data"
end

function Localizers:GetQuestDataFromTooltip(qid)
  qid = tonumber(qid)
  local scanner = ZGV.TooltipScanner
  if not qid or not scanner or type(scanner.GetTooltip) ~= "function" then return nil end
  local lines = scanner:GetTooltip("quest:" .. tostring(qid) .. ":1") or {}
  if #lines == 0 then return false end
  local title, objectives = lines[1], nil
  for index = 2, #lines do
    local line = tostring(lines[index]):match("^%s*%-?%s*(.-)%s*$")
    if line and line ~= "" then
      local item, needed = line:match("^(.-)%s+[xX]?%s*(%d+)$")
      objectives = objectives or {}
      objectives[#objectives + 1] = { item = trim(item or line), needed = tonumber(needed) }
    end
  end
  return title, objectives
end

function Localizers:GetQuestData(qid)
  qid = tonumber(qid)
  if not qid then return nil end
  local legacy = ZGV.questsbyid and ZGV.questsbyid[qid]
  if legacy then return legacy, legacy.inlog and true or false end

  local service = ZGV.Compat and ZGV.Compat.Quest
  local entry = service and service:FindInLog(qid) or nil
  if entry then
    local goals = {}
    for _, objective in ipairs(entry.objectives or {}) do
      goals[#goals + 1] = {
        item = objective.description or objective.text,
        num = objective.current,
        needed = objective.required,
        complete = objective.finished and true or false,
        type = objective.type,
      }
    end
    local quest = {
      title = entry.title, id = qid, level = entry.level, complete = entry.isComplete,
      failed = entry.isFailed, daily = entry.isDaily, goals = goals, index = entry.index, inlog = true,
    }
    questCache[qid] = quest
    return quest, true
  end

  local cached = questCache[qid]
  if cached then return cached, false end
  local title, goals = self:GetQuestDataFromTooltip(qid)
  if not title and ZGV.QuestDB and type(ZGV.QuestDB.GetQuestName) == "function" then
    local candidate = ZGV.QuestDB:GetQuestName(qid)
    if candidate and tostring(candidate) ~= tostring(qid) then title = candidate end
  end
  if not title then return nil end
  local complete = service and service:IsCompleted(qid) or false
  local quest = { title = title, id = qid, complete = complete and true or false, goals = goals, inlog = false }
  questCache[qid] = quest
  return quest, false
end

if type(ZGV.RegisterCallback) == "function" then
  ZGV:RegisterCallback("ZGV_CATALOG_FINALIZED", function() indexed = false end)
end
