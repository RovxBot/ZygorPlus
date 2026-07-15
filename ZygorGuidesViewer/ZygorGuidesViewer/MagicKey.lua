-- The binding itself remains ZGV:MagicKey() (defined by Runtime).  Keeping
-- the hint controller separate avoids replacing that callable API with the
-- table used by later-retail Zygor revisions.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local MagicKey=ZGV:RegisterModule("MagicKeyHint",{defaultText="Press your Magic Key to continue."})
ZGV.MagicKeyHint=MagicKey

-- The key binding is useful, but the old always-on screen-sized reminder is
-- not part of the Classic viewer.  Keep a small, opt-in reminder for players
-- who want it and leave the binding/API available for everyone else.
function MagicKey:IsEnabled()
  return ZGV.db and ZGV.db.profile and ZGV.db.profile.viewer and ZGV.db.profile.viewer.magicKeyHint and true or false
end

function MagicKey:CreateFrame()
  if self.frame then return self.frame end
  local frame=CreateFrame("Button","ZygorGuidesViewer_MagicKeyHint",UIParent)
  frame:SetWidth(310) frame:SetHeight(28)
  frame:SetPoint("BOTTOMRIGHT",UIParent,"BOTTOMRIGHT",-95,92)
  frame:RegisterForClicks("LeftButtonUp")
  frame:SetScript("OnClick",function() ZGV:MagicKey() end)
  frame:SetScript("OnEnter",function(self)
    if GameTooltip then GameTooltip:SetOwner(self,"ANCHOR_TOP") GameTooltip:SetText("Activates the first incomplete guide objective.") GameTooltip:Show() end
  end)
  frame:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
  local label=frame:CreateFontString(nil,"OVERLAY","SystemFont_Shadow_Med1")
  label:SetAllPoints(frame) label:SetJustifyH("RIGHT") label:SetJustifyV("MIDDLE")
  if STANDARD_TEXT_FONT then label:SetFont(STANDARD_TEXT_FONT,16) end
  frame.label=label frame:Hide()
  self.frame=frame
  return frame
end

function MagicKey:SetHint(text)
  local frame=self:CreateFrame()
  if not self:IsEnabled() then
    frame.label:SetText("")
    frame:Hide()
    return
  end
  text=tostring(text or "")
  frame.label:SetText(text)
  ZGV.Compat.UI:SetShown(frame,text~="")
end

function MagicKey:ClearHint() self:SetHint("") end

function MagicKey:RefreshHint()
  if not self:IsEnabled() then return self:ClearHint() end
  local runtime=ZGV.Runtime
  if not (runtime and runtime.currentGuide) then return self:ClearHint() end
  for _,entry in ipairs(runtime:GetDisplayGoals(runtime.currentStep)) do
    if not (entry.state and entry.state.complete) then return self:SetHint(self.defaultText) end
  end
  self:SetHint("Press your Magic Key for the next step.")
end

function MagicKey:OnStartup() self:RefreshHint() end

-- Legacy XML and external keybind snippets call this global helper.
ZGV.MagicButton_OnClick=function() return ZGV:MagicKey() end
function ZGV:SetMagicKeyHint(text) return MagicKey:SetHint(text) end
ZGV:RegisterCallback("ZGV_STEP_CHANGED",MagicKey,"RefreshHint")
ZGV:RegisterCallback("ZGV_GOAL_UPDATED",MagicKey,"RefreshHint")
ZGV:RegisterCallback("ZGV_GUIDE_CHANGED",MagicKey,"RefreshHint")
ZGV:RegisterCallback("ZGV_OPTIONS_CHANGED",MagicKey,"RefreshHint")
