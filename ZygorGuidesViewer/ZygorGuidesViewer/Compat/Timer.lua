local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Timer = Compat:CreateService("Timer")

Timer.tasks = Timer.tasks or {}
Timer.nextID = Timer.nextID or 0

local Handle = {}
Handle.__index = Handle

function Handle:Cancel()
	if self.cancelled then return false end
	self.cancelled = true
	Timer.tasks[self.id] = nil
	return true
end

function Handle:IsCancelled()
	return self.cancelled == true
end

local function invoke(task)
	local result = Compat.Pack(pcall(task.callback, Compat.Unpack(task.args)))
	if not result[1] then
		Compat:ReportError(result[2])
		return false
	end
	return true
end

function Timer:NewTimer(delay, callback, ...)
	if type(callback) ~= "function" then return nil, "callback_not_callable" end
	delay = tonumber(delay) or 0
	if delay < 0 then delay = 0 end
	self.nextID = self.nextID + 1
	local handle = setmetatable({
		id = self.nextID,
		due = Compat.Now() + delay,
		callback = callback,
		args = Compat.Pack(...),
		cancelled = false,
	}, Handle)
	self.tasks[handle.id] = handle
	return handle
end

function Timer:After(delay, callback, ...)
	return self:NewTimer(delay, callback, ...)
end

function Timer:NewTicker(interval, callback, iterations, ...)
	if type(callback) ~= "function" then return nil, "callback_not_callable" end
	interval = tonumber(interval) or 0
	if interval <= 0 then interval = 0.01 end
	iterations = tonumber(iterations)
	if iterations and iterations <= 0 then return nil, "invalid_iterations" end
	local handle, reason = self:NewTimer(interval, callback, ...)
	if not handle then return nil, reason end
	handle.interval = interval
	handle.remaining = iterations
	return handle
end

function Timer:Cancel(handle)
	if type(handle) == "table" and type(handle.Cancel) == "function" then
		return handle:Cancel()
	end
	return false
end

function Timer:Pump(now)
	now = tonumber(now) or Compat.Now()
	local due = {}
	for _, task in pairs(self.tasks) do
		if not task.cancelled and task.due <= now then due[#due + 1] = task end
	end
	table.sort(due, function(left, right)
		if left.due == right.due then return left.id < right.id end
		return left.due < right.due
	end)
	for _, task in ipairs(due) do
		if self.tasks[task.id] and not task.cancelled then
			local keep = invoke(task)
			if task.interval and keep and not task.cancelled then
				if task.remaining then
					task.remaining = task.remaining - 1
					if task.remaining <= 0 then task:Cancel() end
				end
				if not task.cancelled then task.due = now + task.interval end
			else
				task:Cancel()
			end
		end
	end
end

if type(_G.CreateFrame) == "function" and not Timer.frame then
	Timer.frame = _G.CreateFrame("Frame", "ZGVCompatTimerFrame")
	Timer.frame:SetScript("OnUpdate", function()
		Timer:Pump()
	end)
end

