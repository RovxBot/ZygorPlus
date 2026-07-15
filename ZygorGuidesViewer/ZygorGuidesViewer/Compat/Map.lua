local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Map = Compat:CreateService("Map")
Map.zoneKeyCache = Map.zoneKeyCache or {}

local function legacy_field(record, field)
	if type(record) ~= "table" then return nil end
	if record[field] ~= nil then return record[field] end
	return type(record.legacy) == "table" and record.legacy[field] or nil
end

local function anniversary_map_id(record)
	if type(record) ~= "table" then return nil end
	if record.uiMapID ~= nil then return record.uiMapID end
	return type(record.anniversary) == "table" and record.anniversary.uiMapID or nil
end

local function safe_value(func, ...)
	if type(func) ~= "function" then return nil end
	local result = Compat.Pack(pcall(func, ...))
	if not result[1] then return nil end
	return Compat.Unpack(result, 2)
end

function Map:CaptureState()
	local state = {
		continent = tonumber(safe_value(_G.GetCurrentMapContinent)),
		zone = tonumber(safe_value(_G.GetCurrentMapZone)),
		floor = tonumber(safe_value(_G.GetCurrentMapDungeonLevel)),
		areaID = tonumber(safe_value(_G.GetCurrentMapAreaID)),
	}
	local map_file, texture_height, texture_width, is_micro, micro_name = safe_value(_G.GetMapInfo)
	state.mapFile = map_file
	state.textureHeight = texture_height
	state.textureWidth = texture_width
	state.isMicroDungeon = Compat.Bool(is_micro)
	state.microDungeonName = micro_name
	return state
end

function Map:RestoreState(state)
	if type(state) ~= "table" then return Compat:Result(false, "invalid_state") end
	local restored = false
	local errors = {}
	if state.areaID and type(_G.SetMapByID) == "function" then
		local ok, error_message = pcall(_G.SetMapByID, state.areaID)
		if ok then restored = true else errors[#errors + 1] = error_message end
	end
	if not restored and state.continent and type(_G.SetMapZoom) == "function" then
		local ok, error_message
		local continent, zone = state.continent, state.zone
		-- The Scarlet Enclave reports the synthetic -1/0 pair on build 12340;
		-- the selectable legacy map lives at 5/1.
		if continent == -1 and zone == 0 and state.mapFile == "ScarletEnclave" then continent, zone = 5, 1 end
		if zone ~= nil then ok, error_message = pcall(_G.SetMapZoom, continent, zone)
		else ok, error_message = pcall(_G.SetMapZoom, continent) end
		if ok then restored = true else errors[#errors + 1] = error_message end
	end
	if state.floor and state.floor > 0 and type(_G.SetDungeonMapLevel) == "function" then
		local ok, error_message = pcall(_G.SetDungeonMapLevel, state.floor)
		if not ok then errors[#errors + 1] = error_message end
	end
	return Compat:Result(restored, restored and "restored" or "restore_failed", { state = state, errors = errors })
end

function Map:WithPreservedState(callback, ...)
	if type(callback) ~= "function" then return false, "callback_not_callable" end
	local state = self:CaptureState()
	local results = Compat.Pack(pcall(callback, ...))
	local restore = self:RestoreState(state)
	if not results[1] then return false, results[2], restore end
	if not restore.ok then Compat:ReportError("failed to restore the selected map") end
	return true, Compat.Unpack(results, 2)
end

function Map:GetSelected()
	local state = self:CaptureState()
	state.key = self:GetKeyForState(state)
	return state
end

function Map:GetRegistry()
	local data = ZGV.Data
	if type(data) == "table" then
		local registry = data.Maps or data.maps or data.MapRegistry
		if type(registry) == "table" then return registry end
	end
	return type(ZGV.MapRegistry) == "table" and ZGV.MapRegistry or {}
end

function Map:Resolve(key_or_record)
	if type(key_or_record) == "table" then return key_or_record end
	local registry = self:GetRegistry()
	local direct = registry[key_or_record]
	if type(direct) == "table" then
		if not direct.key then direct.key = key_or_record end
		return direct
	end
	local numeric = tonumber(key_or_record)
	for key, record in pairs(registry) do
		if type(record) == "table" and (
			record.key == key_or_record or
			(numeric and (tonumber(legacy_field(record, "areaID")) == numeric or tonumber(anniversary_map_id(record)) == numeric))
		) then
			return record
		end
	end
	return nil
end

function Map:GetKeyForState(state)
	local registry = self:GetRegistry()
	for key, record in pairs(registry) do
		if type(record) == "table" then
			local record_area = legacy_field(record, "areaID")
			local record_continent = legacy_field(record, "continent")
			local record_zone = legacy_field(record, "zone")
			local record_floor = legacy_field(record, "floor") or record.floor
			local record_file = legacy_field(record, "mapFile")
			local area_match = state.areaID and record_area and tonumber(record_area) == tonumber(state.areaID)
			local file_match = state.mapFile and record_file and state.mapFile == record_file
				and (not record_floor or tonumber(record_floor) == tonumber(state.floor or 0))
			local legacy_match = record_continent and tonumber(record_continent) == tonumber(state.continent)
				and record_zone and tonumber(record_zone) == tonumber(state.zone)
				and (not record_floor or tonumber(record_floor) == tonumber(state.floor or 0))
			if area_match or file_match or legacy_match then return record.key or key end
		end
	end
	if state.continent ~= nil and state.zone ~= nil then
		return self:_ResolveLegacyZoneKey(state.continent, state.zone, state.floor)
	end
	return nil
end

function Map:_ResolveLegacyZoneKey(continent, zone, floor)
	local cache_key = tostring(continent) .. ":" .. tostring(zone) .. ":" .. tostring(floor or 0)
	if self.zoneKeyCache[cache_key] then return self.zoneKeyCache[cache_key] end
	local registry = self:GetRegistry()
	local zone_name = self:GetZoneNames(continent)[zone]
	if zone_name then
		for key, record in pairs(registry) do
			if type(record) == "table" then
				local record_floor = legacy_field(record, "floor") or record.floor or 0
				if tonumber(legacy_field(record, "continent")) == tonumber(continent)
					and record.name == zone_name and tonumber(record_floor) == tonumber(floor or 0) then
					self.zoneKeyCache[cache_key] = record.key or key
					return self.zoneKeyCache[cache_key]
				end
			end
		end
	end
	-- Registry names are canonical English, so localized clients may need one
	-- map-file lookup. Do it once per zone and never while the world map is open.
	local visible = _G.WorldMapFrame and type(_G.WorldMapFrame.IsShown) == "function" and _G.WorldMapFrame:IsShown()
	if visible or type(_G.SetMapZoom) ~= "function" or type(_G.GetMapInfo) ~= "function" then return nil end
	local old_state = self:CaptureState()
	local selected = pcall(_G.SetMapZoom, continent, zone)
	local map_file = selected and _G.GetMapInfo() or nil
	self:RestoreState(old_state)
	if map_file then
		for key, record in pairs(registry) do
			if type(record) == "table" then
				local record_floor = legacy_field(record, "floor") or record.floor or 0
				if legacy_field(record, "mapFile") == map_file and tonumber(record_floor) == tonumber(floor or 0) then
					self.zoneKeyCache[cache_key] = record.key or key
					return self.zoneKeyCache[cache_key]
				end
			end
		end
	end
	return nil
end

function Map:Select(key_or_record)
	local record = self:Resolve(key_or_record)
	if not record then return Compat:Result(false, "unknown_map", { requested = key_or_record }) end
	local selected = false
	local error_message
	local area_id = legacy_field(record, "areaID")
	local continent = legacy_field(record, "continent")
	local zone = legacy_field(record, "zone")
	local map_file = legacy_field(record, "mapFile")
	local floor = legacy_field(record, "floor") or record.floor
	if area_id and type(_G.SetMapByID) == "function" then
		selected, error_message = pcall(_G.SetMapByID, area_id)
	elseif continent and type(_G.SetMapZoom) == "function" then
		if zone then
			selected, error_message = pcall(_G.SetMapZoom, continent, zone)
		elseif map_file and type(_G.GetMapZones) == "function" and type(_G.GetMapInfo) == "function" then
			local continent_ok = pcall(_G.SetMapZoom, continent)
			if continent_ok and _G.GetMapInfo() == map_file then
				zone = 0
				selected = true
			else
				local zone_names = self:GetZoneNames(continent)
				for candidate = 1, #zone_names do
					local ok = pcall(_G.SetMapZoom, continent, candidate)
					if ok and _G.GetMapInfo() == map_file then
						zone = candidate
						selected = true
						break
					end
				end
			end
			if not selected then error_message = "legacy zone index not found" end
		else
			selected, error_message = pcall(_G.SetMapZoom, continent, 0)
		end
	else
		return Compat:Result(false, "map_has_no_legacy_coordinates", { map = record })
	end
	if selected and floor and floor > 0 and type(_G.SetDungeonMapLevel) == "function" then
		local floor_ok, floor_error = pcall(_G.SetDungeonMapLevel, floor)
		if not floor_ok then error_message = floor_error end
	end
	return Compat:Result(selected, selected and "selected" or "lua_error", { map = record, legacyZone = zone, error = error_message })
end

function Map:GetPlayerPosition(unit, options)
	unit = unit or "player"
	options = options or {}
	local world_map_visible = _G.WorldMapFrame and type(_G.WorldMapFrame.IsShown) == "function" and _G.WorldMapFrame:IsShown()
	local keep_map = options.keepMap or (world_map_visible and not options.allowVisibleMapMutation)
	local astrolabe = _G.Astrolabe
	if not options.raw and type(astrolabe) == "table" and type(astrolabe.GetUnitPosition) == "function" then
		local call = Compat.Pack(pcall(astrolabe.GetUnitPosition, astrolabe, unit, keep_map and true or false))
		if call[1] and call[2] then
			local continent, zone, x, y = call[2], call[3], call[4], call[5]
			local selected_state = self:CaptureState()
			local selected_matches = tonumber(selected_state.continent) == tonumber(continent)
				and tonumber(selected_state.zone) == tonumber(zone)
			local state = selected_matches and selected_state or { continent = continent, zone = zone, floor = 0 }
			return {
				unit = unit,
				x = x,
				y = y,
				percentX = x and x * 100 or nil,
				percentY = y and y * 100 or nil,
				continent = continent,
				zone = zone,
				floor = state.floor or 0,
				areaID = selected_matches and state.areaID or nil,
				mapFile = selected_matches and state.mapFile or nil,
				key = self:GetKeyForState(state),
				valid = x ~= nil and y ~= nil and (x > 0 or y > 0),
				source = "astrolabe",
			}
		end
	end
	if type(_G.GetPlayerMapPosition) ~= "function" then return { unit = unit, valid = false, reason = "api_unavailable" } end
	local old_state = self:CaptureState()
	if not keep_map and type(_G.SetMapToCurrentZone) == "function" then pcall(_G.SetMapToCurrentZone) end
	local state = self:CaptureState()
	local x, y = _G.GetPlayerMapPosition(unit)
	local restore = keep_map and Compat:Result(true, "unchanged", { state = old_state }) or self:RestoreState(old_state)
	return {
		unit = unit,
		x = tonumber(x),
		y = tonumber(y),
		percentX = x and x * 100 or nil,
		percentY = y and y * 100 or nil,
		continent = state.continent,
		zone = state.zone,
		floor = state.floor,
		areaID = state.areaID,
		mapFile = state.mapFile,
		key = self:GetKeyForState(state),
		valid = x ~= nil and y ~= nil and (x > 0 or y > 0),
		source = "legacy_map",
		worldMapVisible = world_map_visible and true or false,
		restore = restore,
	}
end

function Map:GetZoneNames(continent)
	if type(_G.GetMapZones) ~= "function" then return {} end
	local values = Compat.Pack(_G.GetMapZones(continent))
	local zones = {}
	for index = 1, values.n do zones[index] = values[index] end
	return zones
end

function Map:GetDistance(from, to)
	if type(from) ~= "table" or type(to) ~= "table" then return Compat:Result(false, "invalid_position") end
	local astrolabe = _G.Astrolabe
	local astrolabe_error
	if type(astrolabe) == "table" and type(astrolabe.ComputeDistance) == "function"
		and from.continent and from.zone and to.continent and to.zone then
		local result = Compat.Pack(pcall(astrolabe.ComputeDistance, astrolabe,
			from.continent, from.zone, from.x, from.y,
			to.continent, to.zone, to.x, to.y))
		if result[1] and result[2] then
			return Compat:Result(true, "computed", {
				distance = result[2], distanceKnown = true,
				xDelta = result[3], yDelta = result[4], source = "astrolabe",
			})
		end
		astrolabe_error = result[2]
	end
	local same_map = (from.key and from.key == to.key)
		or (from.continent == to.continent and from.zone == to.zone and from.floor == to.floor)
	local width = tonumber(from.width or to.width)
	local height = tonumber(from.height or to.height)
	if same_map and width and height and from.x and from.y and to.x and to.y then
		local dx, dy = (to.x - from.x) * width, (to.y - from.y) * height
		return Compat:Result(true, "computed", {
			distance = math.sqrt(dx * dx + dy * dy), distanceKnown = true,
			xDelta = dx, yDelta = dy, source = "map_dimensions",
		})
	end
	-- Astrolabe can decline a distance calculation while the legacy map is
	-- changing zoom.  On the same map, normalised coordinates are still enough
	-- to point the arrow correctly, but they are not a distance in game yards.
	-- Preserve that useful direction without exposing a made-up yard value to
	-- arrival checks or the viewer.
	if same_map and from.x and from.y and to.x and to.y then
		local dx, dy = to.x - from.x, to.y - from.y
		return Compat:Result(true, "normalised_map", {
			normalisedDistance = math.sqrt(dx * dx + dy * dy), distanceKnown = false,
			xDelta = dx, yDelta = dy, source = "normalised_map",
		})
	end
	return Compat:Result(false, astrolabe_error and "astrolabe_error" or "no_transform", { error = astrolabe_error })
end
