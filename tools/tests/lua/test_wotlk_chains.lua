local repo = assert(arg[1], "repository path is required")
local addon = repo .. "/ZygorGuidesViewer/ZygorGuidesViewer/"

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2)
  end
end

local sourceHandle = assert(io.open(addon .. "Data-WotLK/QuestChainsClassicTBC.lua", "rb"))
local sourceText = sourceHandle:read("*a")
sourceHandle:close()
local mixedFactionSample = assert(sourceText:match("[\r\n]%s*(A 2011 or H 2012,2013)[\r\n]"), "mixed-faction source sample is missing")

local function loadRuntime(faction)
  ZygorGuidesViewer = { Data = { datasets = {} } }
  ZGV = nil
  UnitFactionGroup = function() return faction end

  function ZygorGuidesViewer.Data:Register(name, version, records, provenance)
    self[name] = records
    self.datasets[name] = { version=version, records=records, provenance=provenance }
  end
  function ZygorGuidesViewer:RegisterModule(name, module)
    module.name = name
    self[name] = module
    return module
  end
  function ZygorGuidesViewer:RegisterEvent() end
  function ZygorGuidesViewer:LogError(context, message) error(context .. ": " .. message) end
  function ZygorGuidesViewer:Fire() end

  dofile(addon .. "Data-WotLK/QuestChains.lua")
  dofile(addon .. "ChainsParser.lua")

  local sample = {}
  ZygorGuidesViewer.ChainsParser:Parse(mixedFactionSample .. "\n", sample)
  assertEqual(sample[2013], faction == "Alliance" and 2011 or 2012, faction .. " mixed-faction prerequisite")

  dofile(addon .. "Data-WotLK/QuestChainsClassicTBC.lua")
  ZygorGuidesViewer.ChainsParser:OnStartup()
  return ZygorGuidesViewer
end

local expected = {
  Alliance = { chains=4417, reverse=4031 },
  Horde = { chains=4426, reverse=3992 },
}

for _,faction in ipairs({"Alliance", "Horde"}) do
  local runtime = loadRuntime(faction)
  local chains, reverse = 0, 0
  for _ in pairs(runtime.Chains) do chains = chains + 1 end
  for _ in pairs(runtime.RevChains) do reverse = reverse + 1 end
  assertEqual(chains, expected[faction].chains, faction .. " merged chain count")
  assertEqual(reverse, expected[faction].reverse, faction .. " reverse chain count")
  assertEqual(runtime.Chains[13413], 13412, faction .. " Wrath prerequisite")
end

print("WotLK quest chain tests passed")
