-- Compatibility surface for directly ported modules from the modern Classic
-- viewer. Keep client-specific replacements here; gameplay code stays in the
-- ported module that uses them.
local _G = _G
local _, ZGVNamespace = ...
local ZGV = (type(ZGVNamespace) == "table" and (ZGVNamespace.ZygorGuidesViewer or ZGVNamespace.ZGV)) or _G.ZygorGuidesViewer
if type(ZGV) ~= "table" or type(ZGV.Compat) ~= "table" then return end

local Compat = ZGV.Compat
local Timer = Compat.Timer

ZGV.ModernBridge = ZGV.ModernBridge or {}
local Bridge = ZGV.ModernBridge

ZGV.IsClassic = false
ZGV.IsClassicTBC = false
ZGV.IsClassicWOTLK = true
ZGV.IsClassicCATA = false
ZGV.IsClassicMOP = false
ZGV.IsRetail = false
ZGV.CLASSIC_SCALE_ADJUST = (_G.UIParent and _G.UIParent.GetEffectiveScale and _G.UIParent:GetEffectiveScale()) or 1
ZGV.SKINSDIR = ZGV.SKINDIR
ZGV.ARROWSDIR = ZGV.DIR .. "\\Arrows\\"
ZGV.CFG = ZGV.CFG or { LINES_PER_STEP = 30 }
ZGV.F = ZGV.F or {}

function ZGV.F.HTMLColor(value)
  local hex = tostring(value or ""):gsub("#", "")
  if #hex == 6 then hex = hex .. "ff" end
  if #hex ~= 8 then return 1, 1, 1, 1 end
  local function channel(first)
    return (tonumber(hex:sub(first, first + 1), 16) or 255) / 255
  end
  return channel(1), channel(3), channel(5), channel(7)
end

function ZGV.F.AssignButtonTexture(button, texture, number, count)
  if not button or not texture then return end
  number, count = tonumber(number) or 1, tonumber(count) or 1
  local left, right = (number - 1) / count, number / count
  -- Modern button atlases are a row for each button state, not a single
  -- horizontal strip.  Cropping every state from row one was the reason
  -- 3.3.5 rendered the viewer controls as plain white squares.
  local function ensure(getter, setter)
    local region = getter and getter(button)
    if not region and setter then
      setter(button, "Interface\\Buttons\\WHITE8X8")
      region = getter(button)
    end
    return region
  end
  local function assign(region, row)
    if region then
      region:SetTexture(texture)
      region:SetTexCoord(left, right, (row - 1) / 4, row / 4)
    end
  end
  assign(ensure(button.GetNormalTexture, button.SetNormalTexture), 1)
  assign(ensure(button.GetPushedTexture, button.SetPushedTexture), 2)
  assign(ensure(button.GetHighlightTexture, button.SetHighlightTexture), 3)
  assign(ensure(button.GetDisabledTexture, button.SetDisabledTexture), 4)
end

local function resolve_callback(owner, callback)
  if type(callback) == "string" then callback = owner and owner[callback] end
  if type(callback) ~= "function" then return nil end
  if owner then return function(...) return callback(owner, ...) end end
  return callback
end

local function legacy_handler(handler, event)
  if type(handler) == "function" then
    return nil, function(...)
      return handler(ZGV, event, ...)
    end
  elseif type(handler) == "string" then
    return ZGV, handler
  elseif type(handler) == "table" then
    return handler[1], handler[2]
  elseif handler == true then
    return ZGV, function(_, firedEvent, ...)
      local method = ZGV[firedEvent]
      if type(method) == "function" then return method(ZGV, firedEvent, ...) end
    end
  end
  return nil, nil
end

Bridge.EventHandlers = Bridge.EventHandlers or {}
Bridge.MessageHandlers = Bridge.MessageHandlers or {}

local function remember(registry, topic, handler, owner, method)
  local handlers = registry[topic] or {}
  registry[topic] = handlers
  handlers[#handlers + 1] = { handler = handler, owner = owner, method = method }
end

local function forget(registry, topic, handler)
  local handlers = registry[topic]
  if not handlers then return nil end
  for index = 1, #handlers do
    local record = handlers[index]
    if record.handler == handler then
      table.remove(handlers, index)
      if #handlers == 0 then registry[topic] = nil end
      return record
    end
  end
end

-- This mirrors the modern viewer contract: a handler can be a function,
-- method name, { object, method }, or true, and is invoked as
-- handler(ZGV, event, ...).
function ZGV:AddEventHandler(event, handler, callback)
  if callback ~= nil then
    self:RegisterEvent(event, handler, callback)
    remember(Bridge.EventHandlers, event, handler, handler, callback)
    return handler
  end
  local owner, method = legacy_handler(handler, event)
  if not method then return nil end
  self:RegisterEvent(event, owner, method)
  remember(Bridge.EventHandlers, event, handler, owner, method)
  return handler
end

function ZGV:RemoveEventHandler(event, handler)
  local record = forget(Bridge.EventHandlers, event, handler)
  if not record then return nil end
  self:UnregisterEvent(event, record.owner, record.method)
  return handler
end

function ZGV:AddMessageHandler(topic, handler, callback)
  if callback ~= nil then
    self:RegisterCallback(topic, handler, callback)
    remember(Bridge.MessageHandlers, topic, handler, handler, callback)
    return handler
  end
  local method
  -- Core callbacks deliberately do not carry their topic.  The modern viewer
  -- does, so adapt every supported handler shape here.
  if type(handler) == "function" then
    method = function(...) return handler(ZGV, topic, ...) end
  elseif type(handler) == "string" then
    method = function(...)
      local fn = ZGV[handler]
      if type(fn) == "function" then return fn(ZGV, topic, ...) end
    end
  elseif type(handler) == "table" then
    method = function(...)
      local object, callbackMethod = handler[1], handler[2]
      local fn = type(callbackMethod) == "string" and object and object[callbackMethod] or callbackMethod
      if type(fn) == "function" then return fn(object, topic, ...) end
    end
  elseif handler == true then
    method = function(...)
      local fn = ZGV[topic]
      if type(fn) == "function" then return fn(ZGV, topic, ...) end
    end
  end
  if not method then return nil end
  self:RegisterCallback(topic, nil, method)
  remember(Bridge.MessageHandlers, topic, handler, nil, method)
  return handler
end

function ZGV:RegisterMessage(topic, owner, callback)
  return self:AddMessageHandler(topic, owner, callback)
end

function ZGV:RemoveMessageHandler(topic, handler)
  local record = forget(Bridge.MessageHandlers, topic, handler)
  if not record then return nil end
  self:UnregisterCallback(topic, record.owner, record.method)
  return handler
end

function ZGV:UnregisterMessage(topic, handler)
  if handler == nil then
    local handlers = Bridge.MessageHandlers[topic]
    if not handlers then return end
    Bridge.MessageHandlers[topic] = nil
    for index = #handlers, 1, -1 do
      local record = handlers[index]
      self:UnregisterCallback(topic, record.owner, record.method)
    end
    return
  end
  return self:RemoveMessageHandler(topic, handler)
end

function ZGV:SendMessage(topic, ...)
  return self:Fire(topic, ...)
end

function ZGV:ScheduleTimer(owner, callback, delay, ...)
  if type(owner) == "function" then
    delay, callback, owner = callback, owner, nil
  elseif type(owner) == "string" then
    delay, callback, owner = callback, owner, self
  end
  local callable = owner and resolve_callback(owner, callback) or callback
  if not callable or not Timer then return nil end
  return Timer:NewTimer(delay or 0, callable, ...)
end

function ZGV:ScheduleRepeatingTimer(owner, callback, interval, ...)
  if type(owner) == "function" then
    interval, callback, owner = callback, owner, nil
  elseif type(owner) == "string" then
    interval, callback, owner = callback, owner, self
  end
  local callable = owner and resolve_callback(owner, callback) or callback
  if not callable or not Timer then return nil end
  return Timer:NewTicker(interval or 0.01, callable, nil, ...)
end

function ZGV:CancelTimer(handle)
  return Timer and Timer:Cancel(handle) or false
end

function ZGV:Debug(message, ...)
  if not (self.db and self.db.global and self.db.global.profiling) then return end
  if select("#", ...) > 0 then message = string.format(tostring(message), ...) end
  self:Print(message)
end

function ZGV:Error(message, ...)
  if select("#", ...) > 0 then message = string.format(tostring(message), ...) end
  self:LogError("modern-port", message)
end

function ZGV:ChainCall(object)
  local chain = { __object = object }
  return setmetatable(chain, {
    __index = function(self, key)
      if key == "__END" then return self.__object end
      local method = self.__object and self.__object[key]
      if type(method) ~= "function" then return method end
      return function(_, ...)
        method(self.__object, ...)
        return self
      end
    end,
  })
end

function ZGV.F.SetVisible(frame, visible)
  if not frame then return end
  if visible then frame:Show() else frame:Hide() end
end

function ZGV.F.SetSize(frame, width, height)
  return Compat.UI:SetSize(frame, width, height)
end

function ZGV.F.SetColorTexture(texture, red, green, blue, alpha)
  return Compat.UI:SetColorTexture(texture, red, green, blue, alpha)
end

function ZGV:GetPlayerPreciseLevel()
  local level = type(_G.UnitLevel) == "function" and _G.UnitLevel("player") or 1
  return tonumber(level) or 1
end

function ZGV:IsPlayerInCombat()
  return type(_G.InCombatLockdown) == "function" and _G.InCombatLockdown() or false
end

function ZGV:SanitizeGuideTitle(title)
  local value = tostring(title or ""):gsub("\\\\", "\\")
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

function ZGV:GetShortGuideTitle(title)
  return self:SanitizeGuideTitle(title):match("([^\\]+)$") or tostring(title or "")
end

function ZGV:FormatNiceGuideTitle(title)
  return self:GetShortGuideTitle(title)
end

function ZGV:SetGuide(title, step)
  if not self.Runtime then return false end
  return self.Runtime:SelectGuide(self:SanitizeGuideTitle(title), step)
end

function ZGV:FocusStep(step)
  if not self.Runtime then return false end
  if type(step) == "table" then step = step.num or step.number end
  return self.Runtime:SetStep(tonumber(step) or 1, true)
end

function ZGV:ToggleFrame()
  if self.UI then self.UI:Toggle() end
end

function ZGV:RaceClassMatch(expression)
  return self.Conditions and self.Conditions:RaceClass(expression) or true
end

function Bridge:SyncCurrentGuide()
  local runtime = ZGV.Runtime
  ZGV.CurrentGuide = runtime and runtime.currentGuide or nil
  ZGV.CurrentStep = ZGV.CurrentGuide and ZGV.CurrentGuide.steps[runtime.currentStep] or nil
end

ZGV:RegisterCallback("ZGV_GUIDE_CHANGED", Bridge, "SyncCurrentGuide")
ZGV:RegisterCallback("ZGV_STEP_CHANGED", Bridge, "SyncCurrentGuide")

-- Do not publish modern C_* or Enum globals on a 3.3.5a client.  Their
-- presence makes other addons (notably Questie) select an API branch that is
-- only partly implemented by a compatibility shim.  Ported code accesses the
-- real 3.3.5a services through ZGV.Compat; this private table is retained only
-- for optional in-addon adapters and is deliberately not exported to _G.
Bridge.API = Bridge.API or {}
Bridge.API.Timer = Bridge.API.Timer or {
  After = function(delay, callback) return Timer and Timer:After(delay, callback) end,
  NewTicker = function(interval, callback, iterations) return Timer and Timer:NewTicker(interval, callback, iterations) end,
}
