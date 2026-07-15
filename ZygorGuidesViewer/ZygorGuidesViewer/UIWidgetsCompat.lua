-- Compact build-12340 implementation of the Anniversary ZGV.UI widget
-- factory.  The live WotLK viewer renders its modern shell directly, but
-- content modules still expect these public constructors to exist.
local ZGV = ZygorGuidesViewer
local UI = ZGV and ZGV.UI
if type(UI) ~= "table" then return end

UI.widgets = UI.widgets or {}

local function key(value) return type(value) == "string" and value:upper() or nil end
local function shown(frame, condition)
  if condition then frame:Show() else frame:Hide() end
  return frame
end
local function fontObject(frame)
  return frame.GetFontString and frame:GetFontString()
end
local function setFont(frame, path, size, flags)
  local label = fontObject(frame)
  if label then label:SetFont(path or ZGV.Font or STANDARD_TEXT_FONT, size or 12, flags or "") end
  return frame
end
local function tooltip(frame, text)
  frame.zgvTooltip = text
  frame:SetScript("OnEnter", function(self)
    if not self.zgvTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.zgvTooltip, nil, nil, nil, nil, true)
    GameTooltip:Show()
  end)
  frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return frame
end
local function backdrop(frame)
  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = ZGV.SKINDIR .. "white", edgeFile = ZGV.SKINDIR .. "white",
      edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(.08, .08, .08, .96)
    frame:SetBackdropBorderColor(.25, .25, .25, 1)
  end
  return frame
end

function UI:RegisterWidget(name, prototype)
  name = key(name)
  if not name or type(prototype) ~= "table" or type(prototype.New) ~= "function" then return nil end
  self.widgets[name] = prototype
  return prototype
end

function UI:Create(widgetType, parent, name, ...)
  local prototype = self.widgets[key(widgetType)]
  if not prototype then return nil, "unsupported UI widget: " .. tostring(widgetType) end
  return prototype:New(parent or UIParent, name, ...)
end

local Button = {}
function Button:New(parent, name, style, template)
  local frame = CreateFrame("Button", name, parent, template or "UIPanelButtonTemplate")
  frame.tex = frame.tex or frame:CreateTexture(nil, "ARTWORK")
  frame.tex:SetPoint("LEFT", frame, "LEFT", 3, 0); frame.tex:Hide()
  function frame:ShowIf(value) return shown(self, value) end
  function frame:EnableIf(value) return self:SetEnabledIf(value) end
  function frame:SetEnabledIf(value) ZGV.Compat.UI:SetEnabled(self, value); return self end
  function frame:SetNormalBackdropColor(r, g, b, a) self.zgvNormal = { r, g, b, a }; if self.SetBackdropColor then self:SetBackdropColor(r, g, b, a) end; return self end
  function frame:SetHighlightBackdropColor(r, g, b, a) self.zgvHighlight = { r, g, b, a }; return self end
  function frame:SetPushedBackdropColor(r, g, b, a) self.zgvPushed = { r, g, b, a }; return self end
  function frame:SetTooltip(text) return tooltip(self, text) end
  function frame:SetPerfectSizing(value) self.zgvPerfectSizing = value and true or false; return self end
  function frame:SetFont(path, size, flags) return setFont(self, path, size, flags) end
  function frame:SetTextColor(r, g, b, a) local label = fontObject(self); if label then label:SetTextColor(r, g, b, a or 1) end; return self end
  function frame:GetStringWidth() local label = fontObject(self); return label and label:GetStringWidth() or 0 end
  function frame:GetStringHeight() local label = fontObject(self); return label and label:GetStringHeight() or 0 end
  function frame:SetTexture(texture) self.tex:SetTexture(texture); self.tex:Show(); return self end
  function frame:SetTexCoord(...) self.tex:SetTexCoord(...); return self end
  function frame:CanDrag(value)
    self:SetMovable(value and true or false); if value then self:RegisterForDrag("LeftButton") else self:RegisterForDrag() end
    self:SetScript("OnDragStart", value and function(self) self:StartMoving() end or nil)
    self:SetScript("OnDragStop", value and function(self) self:StopMovingOrSizing() end or nil)
    return self
  end
  return frame
end
UI:RegisterWidget("Button", Button)

local Frame = {}
function Frame:New(parent, name, template)
  local frame = backdrop(CreateFrame("Frame", name, parent, template))
  function frame:ShowIf(value) return shown(self, value) end
  function frame:EnableIf(value) self:EnableMouse(value and true or false); return self end
  function frame:CanDrag(value) self:SetMovable(value and true or false); if value then self:RegisterForDrag("LeftButton") else self:RegisterForDrag() end; return self end
  function frame:UpdateTimeStamp(stamp)
    local elapsed = math.max(0, time() - (tonumber(stamp) or time()))
    if elapsed >= 86400 then return string.format("%d days ago", math.floor(elapsed / 86400)) end
    if elapsed >= 3600 then return string.format("%d hours ago", math.floor(elapsed / 3600)) end
    if elapsed >= 60 then return string.format("%d mins ago", math.floor(elapsed / 60)) end
    return "less than a min ago"
  end
  function frame:ResetTimeStamp() self.zgvTimeStamp = time(); return self end
  function frame:DoFadeIn(duration) if UIFrameFadeIn then UIFrameFadeIn(self, duration or .2, self:GetAlpha(), 1) else self:SetAlpha(1) end; return self end
  function frame:DoFadeOut(duration) if UIFrameFadeOut then UIFrameFadeOut(self, duration or .2, self:GetAlpha(), 0) else self:SetAlpha(0) end; return self end
  function frame:SquareCorners() self.zgvSquareCorners = true; return self end
  return frame
end
UI:RegisterWidget("Frame", Frame)
UI:RegisterWidget("SecFrame", Frame)

local EditBox = {}
function EditBox:New(parent, name)
  local frame = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
  frame:SetAutoFocus(false)
  frame.back = frame.back or CreateFrame("Frame", nil, frame)
  frame.back:SetAllPoints(frame); backdrop(frame.back); frame.back:SetFrameLevel(math.max(0, frame:GetFrameLevel() - 1))
  return frame
end
UI:RegisterWidget("EditBox", EditBox)

local HyperEditBox = {}
function HyperEditBox:New(parent, name)
  local frame = EditBox:New(parent, name)
  frame.zgvMaxWidth = 320
  frame:SetHyperlinksEnabled(true); frame:Disable()
  function frame:SetMaxWidth(width) self.zgvMaxWidth = tonumber(width) or self.zgvMaxWidth; self:SetWidth(math.min(self:GetWidth(), self.zgvMaxWidth)); return self end
  function frame:OnHyperEnter(linkData) GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT"); GameTooltip:SetHyperlink(linkData); GameTooltip:Show() end
  function frame:OnHyperLeave() GameTooltip:Hide() end
  frame:SetScript("OnHyperlinkEnter", function(self, linkData) self:OnHyperEnter(linkData) end)
  frame:SetScript("OnHyperlinkLeave", function(self) self:OnHyperLeave() end)
  return frame
end
UI:RegisterWidget("HyperEditBox", HyperEditBox)

local ProgressBar = {}
function ProgressBar:New(parent, name)
  local frame = backdrop(CreateFrame("Frame", name, parent))
  frame.bar = CreateFrame("StatusBar", nil, frame); frame.bar:SetAllPoints(frame)
  frame.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  frame.bar:SetMinMaxValues(0, 100); frame.bar:SetValue(0)
  frame.text = frame.bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); frame.text:SetAllPoints(frame.bar)
  function frame:SetPercent(value, mode) local percent = tonumber(value) or 0; if mode == "fraction" then percent = percent * 100 end; self.bar:SetValue(math.max(0, math.min(100, percent))); return self end
  function frame:ShowBar() self.bar:Show(); return self end
  function frame:HideBar() self.bar:Hide(); return self end
  function frame:SetColor(...) self.bar:SetStatusBarColor(...); return self end
  function frame:SetTexture(texture) self.bar:SetStatusBarTexture(texture); return self end
  function frame:SetTextOnMouse(mode) self.zgvTextOnMouse = mode and true or false; return self end
  function frame:SetText(text) self.text:SetText(text or ""); return self end
  function frame:SetTooltip(text) return tooltip(self, text) end
  function frame:SetTextColor(...) self.text:SetTextColor(...); return self end
  function frame:SetDecor(mode) self.zgvDecor = mode; return self end
  function frame:SetAnim(mode) self.zgvAnimated = mode and true or false; return self end
  return frame
end
UI:RegisterWidget("ProgressBar", ProgressBar)

local function makeToggle(parent, name, radio)
  local frame = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
  frame.zgvCallbacks = {}
  frame.label = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  frame.label:SetPoint("LEFT", frame, "RIGHT", 2, 0)
  function frame:SetToggle(value, noCallbacks)
    self:SetChecked(value and true or false)
    if not noCallbacks then for _, callback in ipairs(self.zgvCallbacks) do callback(self, self:GetChecked() and true or false) end end
    return self
  end
  function frame:AddToggleCallback(callback) if type(callback) == "function" then self.zgvCallbacks[#self.zgvCallbacks + 1] = callback end; return self end
  function frame:RegisterToggleCallback(callback) return self:AddToggleCallback(callback) end
  function frame:RegisterOnEnterCallback(callback) if type(callback) == "function" then self:HookScript("OnEnter", callback) end; return self end
  function frame:RegisterOnLeaveCallback(callback) if type(callback) == "function" then self:HookScript("OnLeave", callback) end; return self end
  function frame:RemoveToggleCallbacks() self.zgvCallbacks = {}; return self end
  function frame:RemoveOnEnterCallbacks() self:SetScript("OnEnter", nil); return self end
  function frame:RemoveOnLeaveCallbacks() self:SetScript("OnLeave", nil); return self end
  function frame:SetCanToggle(value) self.zgvCanToggle = value ~= false; ZGV.Compat.UI:SetEnabled(self, self.zgvCanToggle); return self end
  function frame:Toggle() return self:SetToggle(not self:GetChecked()) end
  function frame:ApplySkin() return self end
  function frame:IsChecked() return self:GetChecked() and true or false end
  function frame:SetText(text) self.label:SetText(text or ""); return self end
  function frame:SetTextPos(position) self.label:ClearAllPoints(); if position == "LEFT" then self.label:SetPoint("RIGHT", self, "LEFT", -2, 0) else self.label:SetPoint("LEFT", self, "RIGHT", 2, 0) end; return self end
  function frame:SetFont(path, size, flags) self.label:SetFont(path or ZGV.Font or STANDARD_TEXT_FONT, size or 12, flags or ""); return self end
  function frame:SetTextColor(...) self.label:SetTextColor(...); return self end
  function frame:GetFont() return self.label:GetFont() end
  function frame:GetText() return self.label:GetText() end
  frame:SetScript("OnClick", function(self) if self.zgvCanToggle ~= false then self:SetToggle(self:GetChecked()) end end)
  frame.zgvRadio = radio and true or false
  return frame
end

local ToggleButton = {}
function ToggleButton:New(parent, name) return makeToggle(parent, name, false) end
UI:RegisterWidget("ToggleButton", ToggleButton)

local RadioButton = {}
function RadioButton:New(parent, name) return makeToggle(parent, name, true) end
UI:RegisterWidget("RadioButton", RadioButton)

local RadioButtonGroup = {}
function RadioButtonGroup:New()
  local group = { radios = {}, value = nil }
  function group:AddRadio(value, parent)
    local radio = makeToggle(parent, nil, true); radio.zgvValue = value; self.radios[#self.radios + 1] = radio
    radio:AddToggleCallback(function(_, checked) if checked then group:SetValue(value) end end)
    return radio
  end
  function group:GetValue() return self.value end
  function group:SetValue(value) self.value = value; for _, radio in ipairs(self.radios) do radio:SetToggle(radio.zgvValue == value, true) end; return self end
  return group
end
UI:RegisterWidget("RadioButtonGroup", RadioButtonGroup)

local ScrollChild = {}
function ScrollChild:New(parent, name, childType)
  local scroll = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
  local child = CreateFrame(childType == "Button" and "Button" or "Frame", nil, scroll)
  child:SetWidth(scroll:GetWidth() > 0 and scroll:GetWidth() or 1); child:SetHeight(1)
  scroll:SetScrollChild(child); scroll.child = child
  return scroll
end
UI:RegisterWidget("ScrollChild", ScrollChild)

local ScrollItems = {}
function ScrollItems:New(parent, name)
  local scroll = ScrollChild:New(parent, name); scroll.items = {}; scroll.itemYOffset = 0
  function scroll:UpdateList()
    local previous, totalHeight = nil, 0
    for _, item in ipairs(self.items) do
      item:ClearAllPoints()
      if previous then item:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -self.itemYOffset) else item:SetPoint("TOPLEFT", self.child, "TOPLEFT", 0, 0) end
      previous = item; totalHeight = totalHeight + (item:GetHeight() or 0) + self.itemYOffset
    end
    self.child:SetHeight(math.max(1, totalHeight))
    return self
  end
  function scroll:AddItem(item, first) if first then table.insert(self.items, 1, item) else self.items[#self.items + 1] = item end; item:SetParent(self.child); return self:UpdateList() end
  function scroll:RemoveItem(item) for index = #self.items, 1, -1 do if self.items[index] == item then table.remove(self.items, index) end end; item:Hide(); return self:UpdateList() end
  function scroll:ClearList() for _, item in ipairs(self.items) do item:Hide() end; self.items = {}; return self end
  function scroll:SetItemYOffset(offset) self.itemYOffset = tonumber(offset) or 0; return self:UpdateList() end
  function scroll:ShowIf(value) return shown(self, value) end
  function scroll:EnableIf(value) self:EnableMouse(value and true or false); return self end
  return scroll
end
UI:RegisterWidget("ScrollItems", ScrollItems)

local ScrollBar = {}
function ScrollBar:New(parent, name)
  local slider = CreateFrame("Slider", name, parent, "UIPanelScrollBarTemplate")
  slider:SetMinMaxValues(0, 0); slider:SetValueStep(1); slider.zgvHideWhenUseless = false
  function slider:AddButtons() return self end
  function slider:SetHideWhenUseless(value) self.zgvHideWhenUseless = value and true or false; local low, high = self:GetMinMaxValues(); if self.zgvHideWhenUseless then shown(self, high > low) end; return self end
  function slider:SetDefaults() self:SetMinMaxValues(0, 0); self:SetValue(0); return self end
  function slider:MaxValueAtOnce(value) if value ~= nil then self.zgvPage = tonumber(value) or 0 end; return self.zgvPage or 0 end
  function slider:TotalValue(value) local total = math.max(0, tonumber(value) or 0); self:SetMinMaxValues(0, math.max(0, total - self:MaxValueAtOnce())); self:SetHideWhenUseless(self.zgvHideWhenUseless); return self end
  function slider:RefreshScroller() return self:SetHideWhenUseless(self.zgvHideWhenUseless) end
  function slider:ValueChanged(callback) if type(callback) == "function" then self:SetScript("OnValueChanged", callback) end; return self end
  function slider:MySetPoint(...) self:SetPoint(...); return self end
  return slider
end
UI:RegisterWidget("ScrollBar", ScrollBar)

local function dropdown(parent, name, multi)
  local frame = backdrop(CreateFrame("Frame", name, parent)); frame.items = {}; frame.multi = multi and true or false
  frame.button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate"); frame.button:SetAllPoints(frame); frame.button:SetText("Select")
  frame.pullout = backdrop(CreateFrame("Frame", nil, frame)); frame.pullout:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2); frame.pullout:SetFrameStrata("DIALOG"); frame.pullout:Hide()
  frame.button:SetScript("OnClick", function() if frame.pullout:IsShown() then frame.pullout:Hide() else frame.pullout:Show() end end)
  function frame:AddItem(object, value, callback, itemTooltip)
    local item = type(object) == "table" and object or { text = tostring(object or value or "") }
    item.value = value ~= nil and value or item.value or item.text; item.callback = callback or item.callback; item.tooltip = itemTooltip or item.tooltip
    self.items[#self.items + 1] = item
    local row = CreateFrame("Button", nil, self.pullout, "UIPanelButtonTemplate"); row:SetHeight(20); row:SetText(item.text or tostring(item.value)); row.item = item
    row:SetPoint("TOPLEFT", self.pullout, "TOPLEFT", 2, -2 - (#self.items - 1) * 21); row:SetPoint("TOPRIGHT", self.pullout, "TOPRIGHT", -2, -2 - (#self.items - 1) * 21)
    if item.tooltip then tooltip(row, item.tooltip) end
    row:SetScript("OnClick", function()
      if frame.multi then item.selected = not item.selected else frame.current = item; frame.button:SetText(item.text or tostring(item.value)); frame.pullout:Hide() end
      if type(item.callback) == "function" then item.callback(item.value, item) end
      if type(frame.callbacks and frame.callbacks.OnValueChanged) == "function" then frame.callbacks.OnValueChanged(frame, "OnValueChanged", item.value) end
    end)
    item.button = row; self:UpdatePulloutSize(); return item
  end
  function frame:AddTooltip(position, text) self.zgvTooltipPosition = position; return tooltip(self.button, text) end
  function frame:UpdatePulloutSize() self.pullout:SetWidth(math.max(120, self:GetWidth())); self.pullout:SetHeight(math.max(24, #self.items * 21 + 4)); return self end
  function frame:GetCurrentSelectedItem() return self.current end
  function frame:GetCurrentSelectedItemValue() return self.current and self.current.value end
  function frame:SetCurrentSelectedItem(item) self.current = item; if item then self.button:SetText(item.text or tostring(item.value)) end; return self end
  function frame:SetCurrentSelectedByValue(value) for _, item in ipairs(self.items) do if item.value == value then return self:SetCurrentSelectedItem(item) end end; return self end
  function frame:SetName(text) self.button:SetText(text or ""); return self end
  function frame:SetCallback(event, callback) self.callbacks = self.callbacks or {}; self.callbacks[event] = callback; return self end
  function frame:OnWidthSet(width) self:SetWidth(width); return self:UpdatePulloutSize() end
  function frame:OnHeightSet(height) self:SetHeight(height); return self end
  return frame
end

local DropDown = {}
function DropDown:New(parent, style, frameLevel, multi) local frame = dropdown(parent, nil, multi); if frameLevel then frame:SetFrameLevel(frameLevel) end; return frame end
UI:RegisterWidget("DropDown", DropDown)

local Multiselect = {}
function Multiselect:New(parent, style, frameLevel)
  local frame = DropDown:New(parent, style, frameLevel, true)
  local addItem = frame.AddItem
  function frame:AddItem(object, value, dbName, callback, itemTooltip)
    local item = addItem(self, object, value, callback, itemTooltip); item.dbName = dbName; return item
  end
  return frame
end
UI:RegisterWidget("Multiselect", Multiselect)

local DropDownFork = {}
function DropDownFork:New(parent, name)
  local frame = dropdown(parent, name, false)
  function frame:ApplySkin() return self end
  function frame:ShowMenu() self.pullout:Show(); return self end
  function frame:SetValues(values) for _, value in ipairs(values or {}) do self:AddItem(value.text or value[1], value.value or value[2], value.func or value[3], value.tooltip) end; return self end
  function frame:SetValuesFunc(callback) self.valuesFunc = callback; return self end
  function frame:GetCurrentSelectedText() return self.current and (self.current.text or tostring(self.current.value)) or nil end
  function frame:OnButtonClicked(button) return self:SetSelected(button) end
  function frame:IsButtonChecked(button) return button and button.item == self.current end
  function frame:SetSelected(button) return self:SetCurrentSelectedItem(button and button.item) end
  return frame
end
UI:RegisterWidget("DropDownFork", DropDownFork)

local ScrollTable = {}
function ScrollTable:New(parent, name, columns, definition, useParent)
  local frame = useParent and parent or backdrop(CreateFrame("Frame", name, parent)); frame.columns = columns or {}; frame.definition = definition or {}; frame.rows = {}; frame.value = 0
  frame.scrollbar = UI:Create("ScrollBar", frame); frame.scrollbar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -18); frame.scrollbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 18)
  local rowCount = frame.definition.ROW_COUNT or 10
  for index = 1, rowCount do
    local row = CreateFrame("Button", nil, frame); row:SetHeight(frame.definition.ROW_HEIGHT or 20); row:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2 - (index - 1) * (frame.definition.ROW_HEIGHT or 20)); row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -2 - (index - 1) * (frame.definition.ROW_HEIGHT or 20)); row:Hide(); frame.rows[index] = row
  end
  function frame:SetColumnWidth(column, width) if self.columns[column] then self.columns[column].width = width end; return self end
  function frame:ResizeRows(count) for index, row in ipairs(self.rows) do shown(row, index <= (tonumber(count) or #self.rows)) end; return self end
  function frame:CountRows() return #self.rows end
  function frame:TotalValue(value) self.scrollbar:TotalValue(value); return self end
  function frame:SetValue(value) self.value = tonumber(value) or 0; self.scrollbar:SetValue(self.value); return self end
  return frame
end
UI:RegisterWidget("ScrollTable", ScrollTable)

local SuggestBox = {}
function SuggestBox:New(parent, name, autoShow, callback)
  local frame = CreateFrame("Frame", name, parent); frame.EditBox = EditBox:New(frame); frame.EditBox:SetAllPoints(frame); frame.items = {}; frame.callback = callback
  frame.list = backdrop(CreateFrame("Frame", nil, frame)); frame.list:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2); frame.list:SetWidth(180); frame.list:Hide()
  function frame:GetText() return self.EditBox:GetText() end
  function frame:SetText(text) self.EditBox:SetText(text or ""); return self end
  function frame:SetFocus() self.EditBox:SetFocus(); return self end
  function frame:HighlightText(...) self.EditBox:HighlightText(...); return self end
  function frame:AddSuggestItem(display, value) self.items[#self.items + 1] = { display = display, value = value }; return self end
  function frame:SetAllTrigger(value) self.allTrigger = value; return self end
  function frame:ShowSuggestList(mode) shown(self.list, mode ~= false and #self.items > 0); return self end
  frame.EditBox:SetScript("OnTextChanged", function(self, user) if user and autoShow then frame:ShowSuggestList(true) end; if user and type(frame.callback) == "function" then frame.callback(self:GetText()) end end)
  return frame
end
UI:RegisterWidget("SuggestBox", SuggestBox)

local ActionButton = {}
function ActionButton:New(parent, name)
  local button, createError = ZGV.Compat.UI:CreateSecureActionButton(name, parent, "SecureActionButtonTemplate")
  if not button then return nil, createError end
  button.icon = button:CreateTexture(nil, "ARTWORK"); button.icon:SetAllPoints(button)
  button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate"); button.cooldown:SetAllPoints(button)
  button:RegisterForClicks("AnyUp")
  local function configure(attributes)
    return ZGV.Compat.UI:RunOutOfCombat("ui-action:" .. tostring(button:GetName() or button), function()
      for _, attribute in ipairs({ "type", "spell", "item", "itemid", "macro", "macrotext", "action", "petaction" }) do
        button:SetAttribute(attribute, attributes and attributes[attribute] or nil)
      end
    end)
  end
  function button:SetAllSizes(width, height) self:SetWidth(width); self:SetHeight(height or width); return self end
  function button:UpdateCooldown(start, duration, enabled) if CooldownFrame_SetTimer then CooldownFrame_SetTimer(self.cooldown, start or 0, duration or 0, enabled or 0) end; return self end
  function button:UpdateTexture(texture) if texture then self.icon:SetTexture(texture) end; return self end
  function button:EnableCooldown() self.cooldown:Show(); return self end
  function button:DisableCooldown() self.cooldown:Hide(); return self end
  function button:EnableHighlight() self:LockHighlight(); return self end
  function button:DisableHighlight() self:UnlockHighlight(); return self end
  function button:EnableTooltip() self.zgvTooltipEnabled = true; return self end
  function button:DisableTooltip() self.zgvTooltipEnabled = false; GameTooltip:Hide(); return self end
  function button:EnableDrag() self:RegisterForDrag("LeftButton"); self.zgvDragEnabled = true; return self end
  function button:DisableDrag() self:RegisterForDrag(); self.zgvDragEnabled = false; return self end
  function button:SetSpell(spellID)
    local spellName, _, texture = GetSpellInfo(spellID); if not spellName then return false end
    self:UpdateTexture(texture); return configure({ type = "spell", spell = spellName })
  end
  function button:SetItem(itemID)
    local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
    self:UpdateTexture(texture); return configure({ type = "item", item = "item:" .. tostring(itemID), itemid = tonumber(itemID) })
  end
  function button:SetMacro(macro)
    return configure({ type = "macro", macro = macro })
  end
  function button:SetPetAction(petAction)
    local slot = tonumber(petAction)
    if not slot and type(ZGV.FindPetActionInfo) == "function" then slot = tonumber((ZGV.FindPetActionInfo(petAction))) end
    if not slot then return false end
    local _, _, texture = GetPetActionInfo(slot); self:UpdateTexture(texture)
    return configure({ type = "pet", action = slot })
  end
  function button:ClearData() self.icon:SetTexture(nil); return configure(nil) end
  function button:SetCombatHiding(mode)
    if not (RegisterStateDriver and UnregisterStateDriver) then return false end
    return ZGV.Compat.UI:RunOutOfCombat("ui-action-visibility:" .. tostring(self:GetName() or self), function()
      if mode then RegisterStateDriver(button, "visibility", "[combat] hide; show") else UnregisterStateDriver(button, "visibility"); button:Show() end
    end)
  end
  return button
end
UI:RegisterWidget("ActionButton", ActionButton)
