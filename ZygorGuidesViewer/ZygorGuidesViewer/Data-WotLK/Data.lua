local ZGV = ZygorGuidesViewer

ZGV.Data = ZGV.Data or {
  version = 1,
  datasets = {},
  provenance = {
    client = "World of Warcraft 3.3.5a build 12340",
    anniversarySource = "ZygorGuidesViewerClassicTBCAnniv 8.1",
    legacySource = "ZygorGuidesViewer 2.0.1327 and Talent Advisor 2.0.1293",
    externalValidation = "TrinityCore/TrinityCore branch 3.3.5 (revision pinned by generator manifest)",
  },
}

function ZGV.Data:Register(name, version, records, provenance)
  assert(type(name)=="string" and name~="", "dataset name required")
  assert(type(version)=="number", "dataset version required")
  assert(type(records)=="table", "dataset records must be a table")
  local previous = self.datasets[name]
  if previous and previous.version > version then return false end
  self.datasets[name] = { version=version, records=records, provenance=provenance }
  self[name] = records
  return true
end

function ZGV.Data:Get(name)
  local dataset = self.datasets[name]
  return dataset and dataset.records, dataset and dataset.version
end
