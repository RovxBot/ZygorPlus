-- Source-name facade for legacy guide macros.
--
-- The WotLK port intentionally does not create, rename, or delete permanent
-- player macros.  Guide macro text is projected onto a secure action button,
-- using the same out-of-combat queue as ModernActionBar and Automation.
local _, namespace = ...
local ZGV = (type(namespace) == "table" and (namespace.ZygorGuidesViewer or namespace.ZGV))
  or _G.ZygorGuidesViewer or ZygorGuidesViewer
if type(ZGV) ~= "table" then return end

local MacroGuide = ZGV.MacroGuideProto or {
  name = "ZygorMacro",
  body = "/run print(\"No guide macro is active.\")",
  icon = "INV_MISC_QUESTIONMARK",
  protectednames = {},
  updateHandlers = {},
}
MacroGuide.protectednames = MacroGuide.protectednames or {}
MacroGuide.updateHandlers = MacroGuide.updateHandlers or {}
ZGV.MacroGuideProto = MacroGuide
ZGV.MacroGuideProto_mt = ZGV.MacroGuideProto_mt or { __index = MacroGuide }

local function outOfCombat(key, callback)
  if ZGV.Compat and ZGV.Compat.UI and type(ZGV.Compat.UI.RunOutOfCombat) == "function" then
    return ZGV.Compat.UI:RunOutOfCombat("macroguide:" .. tostring(key), callback)
  end
  if type(InCombatLockdown) == "function" and InCombatLockdown() then return false, "combat" end
  callback()
  return true
end

local function setButtonMacro(button, macro)
  if not button or type(button.SetAttribute) ~= "function" then return false, "invalid_button" end
  return outOfCombat(macro and macro.name or "clear", function()
    button:SetAttribute("type", macro and "macro" or nil)
    button:SetAttribute("macro", nil)
    button:SetAttribute("macrotext", macro and tostring(macro.body or "") or nil)
  end)
end

function MacroGuide.ActionButtonPrepare(button, refreshfunc)
  if not button then return nil end
  if type(button.RegisterForClicks) == "function" then button:RegisterForClicks("AnyUp") end
  if type(button.RegisterForDrag) == "function" then button:RegisterForDrag("LeftButton") end
  button.refreshfunc = refreshfunc

  function button:SetMacro(macro)
    if type(macro) ~= "table" then return false, "invalid_macro" end
    if self.macroguide and self.macroguide ~= macro then self.macroguide.linkedbutton = nil end
    self.macroguide = macro
    macro.linkedbutton = self
    MacroGuide.protectednames[macro.name] = macro
    local ok, reason = setButtonMacro(self, macro)
    self:UpdateMacroIcon()
    return ok, reason
  end

  function button:ClearMacro()
    local macro = self.macroguide
    if macro then
      MacroGuide.protectednames[macro.name] = nil
      macro.linkedbutton = nil
    end
    self.macroguide = nil
    if self.icon and type(self.icon.SetTexture) == "function" then self.icon:SetTexture(nil) end
    return setButtonMacro(self, nil)
  end

  function button:UpdateMacroIcon()
    if not self.icon or type(self.icon.SetTexture) ~= "function" or not self.macroguide then return end
    local icon = self.macroguide.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    if not tostring(icon):find("\\", 1, true) then icon = "Interface\\Icons\\" .. tostring(icon) end
    self.icon:SetTexture(icon)
  end
  return button
end

function MacroGuide:LocateMacro()
  if type(GetMacroIndexByName) ~= "function" then return nil end
  local index = tonumber(GetMacroIndexByName(self.name)) or 0
  return index > 0 and index or nil
end

function MacroGuide:MacroExists(location)
  if location and location ~= "account" and location ~= "character" then return false end
  local index = self:LocateMacro()
  if not index then return false end
  local account = tonumber(MAX_ACCOUNT_MACROS) or 36
  if not location then return true end
  return location == "account" and index <= account or location == "character" and index > account
end

function MacroGuide:CreateMacro()
  -- Permanent macros are deliberately superseded by the secure contextual
  -- button.  Updating a linked preview preserves the useful source behavior.
  self:Update()
  return nil, "secure_action_button"
end

function MacroGuide:NotifyAboutUpdates()
  for owner, callback in pairs(self.updateHandlers or {}) do
    if type(callback) == "function" then
      if type(ZGV.SafeCall) == "function" then ZGV:SafeCall("macroguide:update", callback, owner)
      else pcall(callback, owner) end
    end
  end
  if self.linkedbutton and type(self.linkedbutton.refreshfunc) == "function" then
    pcall(self.linkedbutton.refreshfunc)
  end
end

function MacroGuide:DeleteMacro()
  if self.linkedbutton and type(self.linkedbutton.ClearMacro) == "function" then self.linkedbutton:ClearMacro() end
  self:NotifyAboutUpdates()
  return false, "permanent_macros_not_managed"
end

function MacroGuide:Update()
  local ok, reason = true, nil
  if self.linkedbutton then
    ok, reason = setButtonMacro(self.linkedbutton, self)
    if type(self.linkedbutton.UpdateMacroIcon) == "function" then self.linkedbutton:UpdateMacroIcon() end
  end
  self:NotifyAboutUpdates()
  return ok, reason
end

function MacroGuide:PlaceOnBar()
  if ZGV.ActionBar and type(ZGV.ActionBar.Refresh) == "function" then ZGV.ActionBar:Refresh() end
  return false, "contextual_action_bar"
end
