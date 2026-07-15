local _G = _G
local ZGV = _G.ZygorGuidesViewer or _G.ZGV
if not ZGV or not ZGV.Compat then return end
local Compat = ZGV.Compat
local UI = Compat:CreateService("UI")

UI.atlases = UI.atlases or {}
UI.deferred = UI.deferred or {}

function UI:SetShown(region, shown)
	if not region then return false end
	if type(region.SetShown) == "function" then region:SetShown(shown and true or false)
	elseif shown then region:Show()
	else region:Hide() end
	return true
end

function UI:SetEnabled(button, enabled)
	if not button then return false end
	if enabled then
		if type(button.Enable) == "function" then button:Enable() else return false end
	else
		if type(button.Disable) == "function" then button:Disable() else return false end
	end
	return true
end

function UI:SetSize(region, width, height)
	if not region then return false end
	if type(region.SetSize) == "function" then region:SetSize(width, height)
	else
		if type(region.SetWidth) == "function" then region:SetWidth(width) end
		if type(region.SetHeight) == "function" then region:SetHeight(height) end
	end
	return true
end

function UI:SetColorTexture(texture, red, green, blue, alpha)
	if not texture then return false end
	if type(texture.SetColorTexture) == "function" then texture:SetColorTexture(red, green, blue, alpha or 1)
	else
		texture:SetTexture("Interface\\Buttons\\WHITE8X8")
		texture:SetVertexColor(red, green, blue, alpha or 1)
	end
	return true
end

function UI:RegisterAtlas(name, texture_path, left, right, top, bottom)
	if type(name) ~= "string" or type(texture_path) ~= "string" then return false end
	self.atlases[name] = { texture = texture_path, left = left or 0, right = right or 1, top = top or 0, bottom = bottom or 1 }
	return true
end

function UI:SetAtlas(texture, name)
	local atlas = self.atlases[name]
	if not texture or not atlas then return Compat:Result(false, "unknown_atlas", { atlas = name }) end
	texture:SetTexture(atlas.texture)
	texture:SetTexCoord(atlas.left, atlas.right, atlas.top, atlas.bottom)
	return Compat:Result(true, "applied", { atlas = name })
end

function UI:SetTextureRotation(texture, radians)
	if not texture or type(texture.SetTexCoord) ~= "function" then return false end
	radians = tonumber(radians) or 0
	local sine, cosine = math.sin(radians), math.cos(radians)
	local function rotate(x, y)
		local dx, dy = x - 0.5, y - 0.5
		return 0.5 + cosine * dx - sine * dy, 0.5 + sine * dx + cosine * dy
	end
	local tlx, tly = rotate(0, 0)
	local blx, bly = rotate(0, 1)
	local trx, try = rotate(1, 0)
	local brx, bry = rotate(1, 1)
	texture:SetTexCoord(tlx, tly, blx, bly, trx, try, brx, bry)
	return true
end

function UI:RunOutOfCombat(key, callback, ...)
	if type(key) == "function" then
		callback, key = key, tostring(key)
	end
	if type(callback) ~= "function" then return Compat:Result(false, "callback_not_callable") end
	if type(_G.InCombatLockdown) ~= "function" or not _G.InCombatLockdown() then
		local result = Compat.Pack(pcall(callback, ...))
		return Compat:Result(result[1], result[1] and "performed" or "lua_error", { error = result[2] })
	end
	self.deferred[key or tostring(callback)] = { callback = callback, args = Compat.Pack(...) }
	return Compat:Result(true, "deferred", { key = key })
end

function UI:FlushDeferred()
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then return end
	local pending = self.deferred
	self.deferred = {}
	for key, operation in pairs(pending) do
		local result = Compat.Pack(pcall(operation.callback, Compat.Unpack(operation.args)))
		if not result[1] then
			Compat:ReportError("deferred UI operation " .. tostring(key) .. ": " .. tostring(result[2]))
		end
	end
end

function UI:ConfigureSecureButton(button, attributes, key)
	if not button or type(button.SetAttribute) ~= "function" then return Compat:Result(false, "invalid_button") end
	return self:RunOutOfCombat(key or tostring(button), function()
		for attribute, value in pairs(attributes or {}) do button:SetAttribute(attribute, value) end
	end)
end

function UI:CreateSecureActionButton(name, parent, template)
	if type(_G.CreateFrame) ~= "function" then return nil, "api_unavailable" end
	if type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() then return nil, "combat_lockdown" end
	return _G.CreateFrame("Button", name, parent or _G.UIParent, template or "SecureActionButtonTemplate")
end

function UI:CreateFramePool(frame_type, parent, template, resetter)
	if type(_G.CreateFramePool) ~= "function" then return nil end
	return _G.CreateFramePool(frame_type, parent, template, resetter)
end

function UI:OnEvent(event)
	if event == "PLAYER_REGEN_ENABLED" then self:FlushDeferred() end
end

Compat:RegisterEvent("PLAYER_REGEN_ENABLED", UI, "OnEvent")
