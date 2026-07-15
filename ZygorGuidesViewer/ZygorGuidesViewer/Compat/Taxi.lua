local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Taxi = Compat:CreateService("Taxi")

Taxi.open = Taxi.open or false
Taxi.lastSnapshot = Taxi.lastSnapshot or { nodes = {}, byKey = {}, updatedAt = 0 }
Taxi.known = Taxi.known or {}
Taxi.knownNames = Taxi.knownNames or {}
Taxi.revision = Taxi.revision or 0

-- TaxiNodeName is returned as "Node, Zone" on the 3.3.5 client, while the
-- static map-position data uses the node's stable display name.  Keep the
-- comparison punctuation/case insensitive and discard the client-provided
-- zone suffix.  The saved cache remains backwards-compatible with the older
-- coordinate-keyed format.
local function name_key(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub(",.*$", "")
	return string.lower((name:gsub("[^%w]", "")))
end

function Taxi:RememberKnownName(name)
	local key = name_key(name)
	if key ~= "" and not self.knownNames[key] then
		self.knownNames[key] = true
		self.revision = (tonumber(self.revision) or 0) + 1
	end
end

function Taxi:IsKnownName(name)
	local key = name_key(name)
	if key == "" then return false end
	if self.knownNames[key] then return true end
	for saved_key, saved_value in pairs(self.saved or {}) do
		if name_key(saved_key) == key then return true end
		if type(saved_value) == "table" and name_key(saved_value.name) == key then return true end
	end
	for _, node in pairs(self.known or {}) do
		if type(node) == "table" and name_key(node.name) == key then return true end
	end
	return false
end

function Taxi:IsKnownStaticNode(node)
	if type(node) ~= "table" then return false end
	if self:IsKnownName(node.name) then return true end
	for _, alias in ipairs(node.aliases or {}) do
		if self:IsKnownName(alias) then return true end
	end
	return false
end

function Taxi:GetKnownStaticNodes()
	local static = type(ZGV.Data) == "table" and (ZGV.Data.Taxi or ZGV.Data.taxi) or {}
	local nodes = {}
	local faction = type(_G.UnitFactionGroup) == "function" and _G.UnitFactionGroup("player") or nil
	local faction_key = faction == "Alliance" and "A" or faction == "Horde" and "H" or nil
	for _, node in pairs(static or {}) do
		if type(node) == "table" and self:IsKnownStaticNode(node)
			and (not node.faction or node.faction == "B" or node.faction == faction_key) then
			nodes[#nodes + 1] = node
		end
	end
	return nodes
end

local function make_key(node, map_state)
	local map_key = map_state and (map_state.key or map_state.areaID or (tostring(map_state.continent) .. ":" .. tostring(map_state.zone))) or "unknown"
	if node.x and node.y then
		-- Coordinates remain stable across locales; localized taxi names do not.
		local x = math.floor(node.x * 10000 + 0.5)
		local y = math.floor(node.y * 10000 + 0.5)
		return tostring(map_key) .. "/@" .. tostring(x) .. ":" .. tostring(y)
	end
	local name = tostring(node.name or "node")
	name = string.lower(string.gsub(name, "[^%w]+", "-"))
	return tostring(map_key) .. "/" .. name
end

function Taxi:Capture()
	if type(_G.NumTaxiNodes) ~= "function" then
		return { nodes = {}, byKey = {}, updatedAt = Compat.Now(), available = false }
	end
	local map_state = Compat.Map and Compat.Map:GetSelected() or {}
	local snapshot = { nodes = {}, byKey = {}, map = map_state, updatedAt = Compat.Now(), available = true }
	local count = tonumber(_G.NumTaxiNodes()) or 0
	for index = 1, count do
		local name = type(_G.TaxiNodeName) == "function" and _G.TaxiNodeName(index) or nil
		local x, y
		if type(_G.TaxiNodePosition) == "function" then x, y = _G.TaxiNodePosition(index) end
		local node_type = type(_G.TaxiNodeGetType) == "function" and _G.TaxiNodeGetType(index) or nil
		local cost = type(_G.TaxiNodeCost) == "function" and _G.TaxiNodeCost(index) or nil
		local node = {
			index = index,
			name = name,
			x = tonumber(x),
			y = tonumber(y),
			type = node_type,
			isCurrent = node_type == "CURRENT",
			isReachable = node_type == "REACHABLE" or node_type == "CURRENT",
			isKnown = node_type ~= "NONE" and node_type ~= nil,
			cost = tonumber(cost),
			map = map_state,
		}
		node.key = make_key(node, map_state)
		snapshot.nodes[#snapshot.nodes + 1] = node
		snapshot.byKey[node.key] = node
		if node.isKnown then
			self.known[node.key] = node
			self:RememberKnownName(node.name)
			if self.saved and node.name then
				self.saved[node.name] = true
				self.saved[name_key(node.name)] = true
			end
		end
	end
	self.lastSnapshot = snapshot
	Compat:Fire("TAXI_CACHE_UPDATED", snapshot)
	return snapshot
end

function Taxi:GetNodes(include_static)
	local nodes = {}
	local seen = {}
	for _, node in ipairs(self.lastSnapshot.nodes or {}) do
		nodes[#nodes + 1] = node
		seen[node.key] = true
	end
	for key, node in pairs(self.known) do
		if not seen[key] then
			nodes[#nodes + 1] = node
			seen[key] = true
		end
	end
	if include_static then
		for _, node in ipairs(self:GetKnownStaticNodes()) do
			if type(node) == "table" then
				local stable_key = node.key or node.name
				local static_map_key = node.mapKey or (type(node.map) == "table" and node.map.key or node.map)
				local coordinate_key = node.x and node.y and make_key(node, { key = static_map_key }) or nil
				if not seen[stable_key] and not (coordinate_key and seen[coordinate_key]) then
					if not node.key then node.key = stable_key end
					nodes[#nodes + 1] = node
					seen[stable_key] = true
					if coordinate_key then seen[coordinate_key] = true end
				end
			end
		end
	end
	return nodes
end

function Taxi:Find(criteria)
	if type(criteria) == "string" then criteria = { key = criteria } end
	criteria = criteria or {}
	local candidates = {}
	for _, node in ipairs(self:GetNodes(criteria.includeStatic)) do
		local matches = true
		if criteria.key and node.key ~= criteria.key then matches = false end
		if criteria.name and node.name ~= criteria.name then matches = false end
		if criteria.index and node.index ~= tonumber(criteria.index) then matches = false end
		if matches then candidates[#candidates + 1] = node end
	end
	if #candidates == 1 then return Compat:Result(true, "unique", { node = candidates[1], candidates = candidates }) end
	if #candidates == 0 then return Compat:Result(false, "missing", { candidates = candidates }) end
	return Compat:Result(false, "ambiguous", { candidates = candidates })
end

function Taxi:Take(criteria)
	if not self.open then return Compat:Result(false, "taxi_map_closed") end
	local resolved = self:Find(criteria)
	if not resolved.ok then return resolved end
	local node = resolved.node
	if not node.index or not node.isReachable or node.isCurrent then return Compat:Result(false, "not_reachable", { node = node }) end
	if type(_G.TakeTaxiNode) ~= "function" then return Compat:Result(false, "api_unavailable", { node = node }) end
	local result = Compat.Pack(pcall(_G.TakeTaxiNode, node.index))
	return Compat:Result(result[1], result[1] and "flight_requested" or "lua_error", { node = node, error = result[2] })
end

function Taxi:OnEvent(event)
	if event == "TAXIMAP_OPENED" then
		self.open = true
		self:Capture()
	elseif event == "TAXIMAP_CLOSED" then
		self.open = false
	end
end

Compat:RegisterEvent("TAXIMAP_OPENED", Taxi, "OnEvent")
Compat:RegisterEvent("TAXIMAP_CLOSED", Taxi, "OnEvent")

-- Preserve the small public surface used by legacy guide modules and third
-- party integrations without loading the Anniversary LibTaxi implementation,
-- which depends on post-Wrath map/event APIs.  Mutating actions still flow
-- through Take(), where the open-frame and reachability guards are enforced.
function Taxi:GetTaxis()
	local paths = {}
	for _, node in ipairs(self:GetNodes(false)) do if node.name and node.isKnown then paths[node.name] = true end end
	for name, known in pairs(self.saved or {}) do
		if known and type(name) == "string" then paths[name] = true end
	end
	return paths
end
Taxi.GetTaxisEnglish = Taxi.GetTaxis
function Taxi:Startup(saved)
	if type(saved) ~= "table" then return false end
	for name, value in pairs(saved) do
		if type(name) == "string" then self:RememberKnownName(name) end
		if type(value) == "table" then self:RememberKnownName(value.name) end
	end
	for _, node in pairs(self.known) do
		if node.name then
			saved[node.name] = true
			self:RememberKnownName(node.name)
		end
	end
	self.saved = saved
	-- InitialFlightPaths binds SavedVariables after the addon modules have
	-- started.  Notify Navigation now that the learned-node set is usable;
	-- otherwise an already selected guide keeps the route calculated before
	-- this cache existed until the next /reload or manual waypoint change.
	Compat:Fire("TAXI_CACHE_UPDATED", {
		nodes = {}, byKey = {}, updatedAt = Compat.Now(), available = true,
		restored = true, revision = self.revision,
	})
	return true
end

ZGV.LibTaxi = Taxi
_G.LibTaxi = Taxi
