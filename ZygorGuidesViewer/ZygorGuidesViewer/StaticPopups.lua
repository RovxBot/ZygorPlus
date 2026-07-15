-- Queue-based popup service compatible with the Classic PopupHandler API.
-- It uses only build-12340 widgets and feeds minimized prompts into the
-- native notification center.
local ZGV=ZygorGuidesViewer
if not ZGV then return end

local Handler={Queue={},Popup={},IsPopupVisible=false,CurrentPopup=nil}
ZGV.PopupHandler=Handler
ZGV.Poup=Handler -- original typo retained for integrations.
local popupTypes={default=true,skills=true,gear=true,dungeon=true,mount=true,loot=true,sis=true,monk=true,panda=true}
local Popup={private={}}
Handler.Popup=Popup

local function skinFrame(frame)
  frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  frame:SetBackdropColor(.055,.055,.065,.98); frame:SetBackdropBorderColor(.95,.48,.08,1)
end
local function nextPopup()
  if Handler.IsPopupVisible or #Handler.Queue==0 then return end
  local popup=table.remove(Handler.Queue,1)
  if popup and popup.SavedShow then popup:SavedShow() end
end
function Handler:IsInNC(name)
  for _,entry in ipairs((ZGV.NotificationCenter and ZGV.NotificationCenter.Entries) or {}) do if entry.ident==name then return true end end
  return false
end
function Handler:GetNCTextureInfo() return ZGV.SKINDIR.."icons-notificationcenter",{0,1,0,1} end
function Handler:QueuePush(popup)
  if not popup or popup:IsShown() then return end
  for _,queued in ipairs(self.Queue) do if queued==popup then return end end
  self.Queue[#self.Queue+1]=popup; nextPopup()
end
function Handler:QueuePop() self.IsPopupVisible=false; self.CurrentPopup=nil; nextPopup() end
function Handler:NewPopup(name,ptype,skin)
  assert(name and name~="","popup name required")
  local popup=self:CreatePopup(name,skin)
  popup.type=popupTypes[ptype] and ptype or "default"
  return popup
end
function Handler:CreatePopup(name)
  local existing=_G[name]; if existing and existing.zgvPopup then return existing end
  local popup=CreateFrame("Frame",name,UIParent)
  popup.zgvPopup=true; skinFrame(popup); popup:SetWidth(360); popup:SetHeight(150); popup:SetPoint("TOP",UIParent,"TOP",0,-80)
  popup:SetFrameStrata("DIALOG"); popup:SetToplevel(true); popup:SetMovable(true); popup:SetClampedToScreen(true); popup:EnableMouse(true); popup:RegisterForDrag("LeftButton")
  popup:SetScript("OnDragStart",function(self) self:StartMoving() end); popup:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
  for key,value in pairs(Popup) do popup[key]=value end
  popup.private=Popup.private
  local logo=popup:CreateTexture(nil,"ARTWORK"); logo:SetTexture(ZGV.SKINDIR.."zygorlogo"); logo:SetWidth(100); logo:SetHeight(25); logo:SetPoint("TOP",0,-9); popup.logo=logo
  local text=popup:CreateFontString(nil,"OVERLAY","GameFontHighlight"); text:SetPoint("TOPLEFT",popup,"TOPLEFT",15,-42); text:SetPoint("TOPRIGHT",popup,"TOPRIGHT",-15,-42); text:SetJustifyH("CENTER"); text:SetJustifyV("TOP"); text:SetWordWrap(true); popup.text=text
  local text2=popup:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall"); text2:SetPoint("TOPLEFT",text,"BOTTOMLEFT",0,-5); text2:SetPoint("TOPRIGHT",text,"BOTTOMRIGHT",0,-5); text2:SetJustifyH("CENTER"); text2:SetJustifyV("TOP"); text2:SetWordWrap(true); popup.text2=text2
  local function makeButton(label,x,callback)
    local button=CreateFrame("Button",nil,popup,"UIPanelButtonTemplate"); button:SetWidth(92); button:SetHeight(22); button:SetPoint("BOTTOM",popup,"BOTTOM",x,11); button:SetText(label); button:SetScript("OnClick",callback); return button
  end
  popup.acceptbutton=makeButton(ACCEPT or "Accept",-100,function() popup.private:Accept(popup) end)
  popup.declinebutton=makeButton(CANCEL or "Cancel",0,function() popup.private:Decline(popup) end)
  popup.morebutton=makeButton("More",100,function() popup.private:More(popup) end); popup.morebutton:Hide()
  local settings=CreateFrame("Button",nil,popup,"UIPanelButtonTemplate"); settings:SetWidth(20); settings:SetHeight(20); settings:SetPoint("TOPRIGHT",popup,"TOPRIGHT",-4,-4); settings:SetText("?"); settings:SetScript("OnClick",function() popup.private:Settings(popup) end); popup.settings=settings
  popup.SavedShow=popup.Show
  popup.Show=function(self,unique) if unique and Handler:IsInNC(self:GetName()) then return end; Handler:QueuePush(self) end
  popup:SetScript("OnShow",function(self) Handler.IsPopupVisible=true; Handler.CurrentPopup=self; self:AdjustSize() end)
  popup:SetScript("OnHide",function(self) self.shownFromNC=nil; Handler:QueuePop() end)
  if type(UISpecialFrames)=="table" then table.insert(UISpecialFrames,name) end
  popup:Hide(); return popup
end
function Popup:Debug(message,...) return ZGV:Debug("&popup "..tostring(message),...) end
function Popup:OnAccept() end
function Popup:OnDecline() end
function Popup:OnEscape() end
function Popup:OnMore() end
function Popup:OnClose() end
function Popup:OnSettings() ZGV:OpenOptions("notifications") end
function Popup:returnMinimizeSettings() return "info",self.title or "Zygor Guides",self.text:GetText(),{ident=self:GetName(),shown=true,reviewed=true} end
function Popup:AdjustSize()
  local height=88+(self.text:GetStringHeight() or 0)+(self.text2:IsShown() and self.text2:GetStringHeight() or 0)
  self:SetHeight(math.max(125,math.min(310,height)))
end
function Popup:SetText(text,text2)
  self.text:SetText(tostring(text or "")); self.text2:SetText(tostring(text2 or "")); ZGV.Compat.UI:SetShown(self.text2,tostring(text2 or "")~=""); self:AdjustSize()
end
function Popup.private:Accept(popup) popup:OnAccept(); popup:Hide() end
function Popup.private:Decline(popup) popup:OnDecline(); popup:Hide() end
function Popup.private:Escape(popup) if popup:IsShown() then popup:OnEscape(); popup:Hide() end end
function Popup.private:More(popup) popup:OnMore(); popup:Hide() end
function Popup.private:Hide(popup) popup:Hide() end
function Popup.private:Close(popup) popup:OnClose(); popup:Hide() end
function Popup.private:Settings(popup) popup:OnSettings() end
function Popup.private:Minimize(popup)
  local kind,title,text,data=popup:returnMinimizeSettings()
  if kind and ZGV.NotificationCenter then ZGV.NotificationCenter:AddEntry(kind,title or "Zygor Guides",text or "",data or {}) end
  popup:Hide()
end
