local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local Chat = Compat:CreateService("Chat")

Chat.prefixes = Chat.prefixes or {}
Chat.listeners = Chat.listeners or {}
Chat.maxPrefixBytes = 16
Chat.maxPacketBytes = 254

local valid_distribution = {
	PARTY = true,
	RAID = true,
	GUILD = true,
	BATTLEGROUND = true,
	WHISPER = true,
}

function Chat:GetMaxPayload(prefix)
	if type(prefix) ~= "string" or string.len(prefix) > self.maxPrefixBytes then return 0 end
	return math.max(0, self.maxPacketBytes - string.len(prefix))
end

function Chat:RegisterPrefix(prefix)
	if type(prefix) ~= "string" or prefix == "" then return Compat:Result(false, "invalid_prefix") end
	if string.find(prefix, "[\t\r\n]") then return Compat:Result(false, "invalid_prefix") end
	if string.len(prefix) > self.maxPrefixBytes then return Compat:Result(false, "prefix_too_long", { prefix = prefix }) end
	if self.prefixes[prefix] then return Compat:Result(true, "already_registered", { prefix = prefix }) end
	if type(_G.RegisterAddonMessagePrefix) == "function" then
		local result = Compat.Pack(pcall(_G.RegisterAddonMessagePrefix, prefix))
		local registration_result = result[2]
		local rejected_number = type(registration_result) == "number" and registration_result > 1
		if not result[1] or registration_result == false or rejected_number then
			return Compat:Result(false, result[1] and "registration_rejected" or "lua_error", { prefix = prefix, error = result[2] })
		end
	end
	self.prefixes[prefix] = true
	return Compat:Result(true, "registered", { prefix = prefix })
end

function Chat:Send(prefix, message, distribution, target)
	distribution = string.upper(tostring(distribution or "PARTY"))
	if type(prefix) ~= "string" or prefix == "" then return Compat:Result(false, "invalid_prefix") end
	if type(message) ~= "string" then return Compat:Result(false, "invalid_message") end
	if string.find(prefix, "[\t\r\n]") then return Compat:Result(false, "invalid_prefix") end
	if string.find(message, "[\r\n]") then return Compat:Result(false, "invalid_message") end
	if string.len(prefix) > self.maxPrefixBytes then return Compat:Result(false, "prefix_too_long", { prefix = prefix }) end
	if string.len(prefix) + string.len(message) > self.maxPacketBytes then
		return Compat:Result(false, "message_too_long", { length = string.len(message), packetLength = string.len(prefix) + string.len(message) })
	end
	if not valid_distribution[distribution] then return Compat:Result(false, "invalid_distribution", { distribution = distribution }) end
	if distribution == "WHISPER" and (type(target) ~= "string" or target == "") then return Compat:Result(false, "target_required") end
	if type(_G.SendAddonMessage) ~= "function" then return Compat:Result(false, "api_unavailable") end
	local registered = self:RegisterPrefix(prefix)
	if not registered.ok then return registered end
	local result = Compat.Pack(pcall(_G.SendAddonMessage, prefix, message, distribution, target))
	return Compat:Result(result[1], result[1] and "sent" or "lua_error", {
		prefix = prefix,
		distribution = distribution,
		target = target,
		bytes = string.len(message),
		error = result[2],
	})
end

function Chat:Listen(prefix, owner, method)
	if type(prefix) ~= "string" or type(owner) ~= "table" then return nil, "invalid_listener" end
	local registration = self:RegisterPrefix(prefix)
	if not registration.ok then return nil, registration.code end
	local listeners = self.listeners[prefix]
	if not listeners then listeners = {} self.listeners[prefix] = listeners end
	local token = { prefix = prefix, owner = owner, method = method or "OnAddonMessage" }
	listeners[#listeners + 1] = token
	return token
end

function Chat:Unlisten(token)
	if type(token) ~= "table" then return end
	local listeners = self.listeners[token.prefix]
	if not listeners then return end
	for index = #listeners, 1, -1 do if listeners[index] == token then table.remove(listeners, index) end end
	if #listeners == 0 then self.listeners[token.prefix] = nil end
end

function Chat:OnEvent(_, prefix, message, distribution, sender)
	local packet = {
		prefix = prefix,
		message = message,
		distribution = distribution,
		sender = sender,
		receivedAt = Compat.Now(),
	}
	local listeners = self.listeners[prefix]
	if listeners then
		local pending = {}
		for index, listener in ipairs(listeners) do pending[index] = listener end
		for _, listener in ipairs(pending) do
			local method = type(listener.method) == "string" and listener.owner[listener.method] or listener.method
			if type(method) == "function" then
				local result = Compat.Pack(pcall(method, listener.owner, packet))
				if not result[1] then Compat:ReportError(result[2]) end
			end
		end
	end
	Compat:Fire("ADDON_MESSAGE", packet)
end

Compat:RegisterEvent("CHAT_MSG_ADDON", Chat, "OnEvent")
