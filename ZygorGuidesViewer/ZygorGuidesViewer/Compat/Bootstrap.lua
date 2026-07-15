-- ZygorGuidesViewer 3.3.5a compatibility bootstrap.
-- This file must be loaded before every other file in Compat/.

local _G = _G
local type, pairs, ipairs, select = type, pairs, ipairs, select
local tostring, tonumber = tostring, tonumber
local unpack_values = _G.unpack or table.unpack

local ZGV = rawget(_G, "ZygorGuidesViewer") or rawget(_G, "ZGV")
if type(ZGV) ~= "table" then ZGV = {} end
_G.ZygorGuidesViewer = ZGV
_G.ZGV = ZGV

local Compat = ZGV.Compat
if type(Compat) ~= "table" then
	Compat = {}
	ZGV.Compat = Compat
end

Compat.API_VERSION = 1
Compat.TARGET_INTERFACE = 30300
Compat.TARGET_BUILD = 12340
Compat.services = Compat.services or {}
Compat._eventHandlers = Compat._eventHandlers or {}
Compat._callbacks = Compat._callbacks or {}

function Compat.Pack(...)
	return { n = select("#", ...), ... }
end

function Compat.Unpack(values, first, last)
	if not values then return end
	first = first or 1
	last = last or values.n or #values
	return unpack_values(values, first, last)
end

function Compat.Bool(value)
	return value == true or value == 1
end

function Compat.Now()
	if type(_G.GetTime) == "function" then return _G.GetTime() end
	if os and type(os.clock) == "function" then return os.clock() end
	return 0
end

function Compat:CreateService(name)
	local service = self.services[name]
	if type(service) ~= "table" then
		service = { name = name }
		self.services[name] = service
	end
	self[name] = service
	return service
end

function Compat:Result(ok, code, fields)
	local result = fields or {}
	result.ok = ok and true or false
	result.code = code or (result.ok and "ok" or "error")
	return result
end

function Compat:ReportError(message)
	message = "ZGV Compat: " .. tostring(message)
	if type(ZGV.LogError) == "function" then pcall(ZGV.LogError, ZGV, "compat", message) end
	if type(_G.geterrorhandler) == "function" then
		local handler = _G.geterrorhandler()
		if type(handler) == "function" then
			local ok = pcall(handler, message)
			if ok then return end
		end
	end
	if type(_G.print) == "function" then _G.print(message) end
end

local function call_handler(owner, method, ...)
	if type(method) == "string" then method = owner and owner[method] end
	if type(method) ~= "function" then return false, "handler is not callable" end
	local results = Compat.Pack(pcall(method, owner, ...))
	if not results[1] then
		Compat:ReportError(results[2])
		return false, results[2]
	end
	return true, Compat.Unpack(results, 2)
end

function Compat:RegisterEvent(event, owner, method)
	if type(event) ~= "string" or type(owner) ~= "table" then return nil end
	method = method or event
	local handlers = self._eventHandlers[event]
	if not handlers then
		handlers = {}
		self._eventHandlers[event] = handlers
		if self._eventFrame then self._eventFrame:RegisterEvent(event) end
	end
	for _, handler in ipairs(handlers) do
		if handler.owner == owner and handler.method == method then return handler end
	end
	local token = { event = event, owner = owner, method = method }
	handlers[#handlers + 1] = token
	return token
end

function Compat:UnregisterEvent(token_or_event, owner)
	local event = type(token_or_event) == "table" and token_or_event.event or token_or_event
	local handlers = self._eventHandlers[event]
	if not handlers then return end
	for index = #handlers, 1, -1 do
		local handler = handlers[index]
		if handler == token_or_event or (handler.owner == owner) then
			table.remove(handlers, index)
		end
	end
	if #handlers == 0 then
		self._eventHandlers[event] = nil
		if self._eventFrame then self._eventFrame:UnregisterEvent(event) end
	end
end

function Compat:DispatchEvent(event, ...)
	local handlers = self._eventHandlers[event]
	if not handlers then return end
	-- Copy the list so a callback may safely unregister itself.
	local pending = {}
	for index, handler in ipairs(handlers) do pending[index] = handler end
	for _, handler in ipairs(pending) do
		call_handler(handler.owner, handler.method, event, ...)
	end
end

function Compat:On(topic, owner, method)
	if type(topic) ~= "string" or type(owner) ~= "table" then return nil end
	local callbacks = self._callbacks[topic]
	if not callbacks then
		callbacks = {}
		self._callbacks[topic] = callbacks
	end
	local token = { topic = topic, owner = owner, method = method or topic }
	callbacks[#callbacks + 1] = token
	return token
end

function Compat:Off(token)
	if type(token) ~= "table" then return end
	local callbacks = self._callbacks[token.topic]
	if not callbacks then return end
	for index = #callbacks, 1, -1 do
		if callbacks[index] == token then table.remove(callbacks, index) end
	end
	if #callbacks == 0 then self._callbacks[token.topic] = nil end
end

function Compat:Fire(topic, ...)
	local callbacks = self._callbacks[topic]
	if not callbacks then return end
	local pending = {}
	for index, callback in ipairs(callbacks) do pending[index] = callback end
	for _, callback in ipairs(pending) do
		call_handler(callback.owner, callback.method, topic, ...)
	end
end

if type(_G.CreateFrame) == "function" and not Compat._eventFrame then
	local frame = _G.CreateFrame("Frame", "ZGVCompatEventFrame")
	frame:SetScript("OnEvent", function(_, event, ...)
		Compat:DispatchEvent(event, ...)
	end)
	Compat._eventFrame = frame
	for event in pairs(Compat._eventHandlers) do frame:RegisterEvent(event) end
end

-- Safe utility polyfills. Game-domain APIs deliberately remain namespaced.
if type(_G.Mixin) ~= "function" then
	function _G.Mixin(object, ...)
		for index = 1, select("#", ...) do
			local mixin = select(index, ...)
			if type(mixin) == "table" then
				for key, value in pairs(mixin) do object[key] = value end
			end
		end
		return object
	end
end

if type(_G.CreateFromMixins) ~= "function" then
	function _G.CreateFromMixins(...)
		return _G.Mixin({}, ...)
	end
end

if type(_G.CopyTable) ~= "function" then
	local function copy_table(source, seen)
		if type(source) ~= "table" then return source end
		seen = seen or {}
		if seen[source] then return seen[source] end
		local copy = {}
		seen[source] = copy
		for key, value in pairs(source) do
			copy[copy_table(key, seen)] = copy_table(value, seen)
		end
		local metatable = getmetatable(source)
		if type(metatable) == "table" then setmetatable(copy, metatable) end
		return copy
	end
	_G.CopyTable = copy_table
end

if type(_G.Clamp) ~= "function" then
	function _G.Clamp(value, minimum, maximum)
		if value < minimum then return minimum end
		if value > maximum then return maximum end
		return value
	end
end

if type(table.wipe) ~= "function" then
	function table.wipe(target)
		for key in pairs(target) do target[key] = nil end
		return target
	end
end
if type(_G.wipe) ~= "function" then _G.wipe = table.wipe end

local function default_pool_resetter(pool, frame)
	if frame.Hide then frame:Hide() end
	if frame.ClearAllPoints then frame:ClearAllPoints() end
	if frame.SetParent and pool and pool.parent then frame:SetParent(pool.parent) end
end

if type(_G.CreateFramePool) ~= "function" and type(_G.CreateFrame) == "function" then
	function _G.CreateFramePool(frame_type, parent, template, resetter)
		local pool = {
			frameType = frame_type,
			parent = parent,
			template = template,
			resetter = resetter or default_pool_resetter,
			active = {},
			inactive = {},
		}
		function pool:Acquire()
			local frame = table.remove(self.inactive)
			local is_new = false
			if not frame then
				frame = _G.CreateFrame(self.frameType, nil, self.parent, self.template)
				is_new = true
			end
			self.active[frame] = true
			return frame, is_new
		end
		function pool:Release(frame)
			if not self.active[frame] then return false end
			self.active[frame] = nil
			local ok, error_message = pcall(self.resetter, self, frame)
			if not ok then Compat:ReportError(error_message) end
			self.inactive[#self.inactive + 1] = frame
			return true
		end
		function pool:ReleaseAll()
			local frames = {}
			for frame in pairs(self.active) do frames[#frames + 1] = frame end
			for _, frame in ipairs(frames) do self:Release(frame) end
		end
		function pool:EnumerateActive()
			return next, self.active, nil
		end
		function pool:GetNumActive()
			local count = 0
			for _ in pairs(self.active) do count = count + 1 end
			return count
		end
		return pool
	end
end
