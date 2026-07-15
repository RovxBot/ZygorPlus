-- View/API bridge for the Classic GuideMenu-View module.  The actual frame
-- is ModernGuideMenu's Classic three-pane recreation; these methods preserve
-- the historical names expected by skins, bindings and optional modules.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
local Menu=ZGV and ZGV.GuideMenu
if type(Menu)~="table" then return end

local renderShow=Menu.Show
local legacySections={Home="HOME",Featured="FEATURED",Current="CURRENT",Recent="RECENT",Suggested="SUGGESTED",Favourites="FAVOURITES",Options="SETTINGS",Settings="SETTINGS"}
function Menu:CreateFrames() return self:Create() end
function Menu:Show(path,...)
  if legacySections[path] or path=="QuestSearch" then return self:Open(path,nil,...) end
  return renderShow(self,path,...)
end
function Menu:Hide() if self.frame then self.frame:Hide() end end

function Menu:SetSectionHeader(text) if self.listTitle then self.listTitle:SetText(tostring(text or "")) end end
function Menu:SetWideSectionHeader(text) if self.title then self.title:SetText(tostring(text or "")) end end
function Menu:ExportPath(row)
  local guide=row and (row.guide or row)
  local value=guide and guide.title or ""
  if self.exportBox then self.exportBox:SetText(value:gsub("\\","\\\\")); self.exportBox:SetFocus() end
  return value
end
function Menu:PrepareGuidesMenuButtons() return self:BuildCategoryButtons() end
function Menu:MakeMenuButton(name,caption,texture,x,width,y,height)
  self:Create()
  local button=CreateFrame("Button",name,self.sidebar)
  button:SetSize(204,24)
  button:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1})
  local icon=button:CreateTexture(nil,"ARTWORK"); icon:SetSize(16,16); icon:SetPoint("LEFT",8,0)
  if texture then icon:SetTexture(texture); icon:SetTexCoord(x or 0,(x or 0)+(width or 1),y or 0,(y or 0)+(height or 1)) end
  local label=button:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall"); label:SetPoint("LEFT",icon,"RIGHT",7,0); label:SetPoint("RIGHT",button,"RIGHT",-4,0); label:SetJustifyH("LEFT"); label:SetText(caption or "")
  button.texture,button.caption=icon,label
  button.SetHighlight=function(self,shown) self:SetBackdropColor(shown and .3 or .1,shown and .3 or .1,shown and .3 or .1,shown and .45 or .9) end
  button.SetLockHighlight=button.SetHighlight
  button.SetHighlightSprite=function(self,left,w,top,h) self.texture:SetTexCoord(left,left+w,top,top+h) end
  button.SetNormalTextColor=function(self,...) self.caption.NormalTextColor={...}; self.caption:SetTextColor(...) end
  button.SetHighlightTextColor=function(self,...) self.caption.HighlightTextColor={...} end
  button:SetScript("OnEnter",function(self) self:SetHighlight(true) end); button:SetScript("OnLeave",function(self) self:SetHighlight(false) end)
  return button
end
function Menu:CreateHome() return self:ShowHome() end
function Menu:UpdateHomeWidgets() if self.section=="HOME" then self:Refresh() end end
function Menu:StartFeatured() return self:Show("FEATURED") end
function Menu:ParseFeatured() return {} end
function Menu:ShowFeatured() return self:Show("FEATURED") end
function Menu:ShowBulletin() return self:Show("HOME") end
function Menu:GetSectionMenu() return self.categories end
function Menu:ToggleSectionMenu() self.sectionMenuOpen=not self.sectionMenuOpen; return self.sectionMenuOpen end
function Menu:ShowOptions(option) return self:Show(option and ("SETTINGS:"..tostring(option)) or "SETTINGS") end
function Menu:ShowOptionButtons(option) return self:ShowOptions(option) end
function Menu:CreateOptions() return self:Create() end
function Menu:HighlightOptionButton() end
function Menu:RefreshOptions() if self.section=="SETTINGS" then self:Refresh() end end

function ZGV:ZGV_LOADING_TOPLEVEL_GROUPS_UPDATED()
  if self.GuideMenu then self.GuideMenu:PrepareGuidesMenuButtons() end
end

-- The source skin has the exact five image files used by this frame.  Check
-- them during frame construction and substitute the real bundled no-image
-- art only when a content guide references a missing custom image.
local oldRenderDetails=Menu.RenderDetails
function Menu:RenderDetails()
  if self.selected and type(self.selected.image)=="string" and self.selected.image~="" and type(GetFileIDFromPath)=="function" then
    -- GetFileIDFromPath returns nil for a missing BLP/TGA on clients that
    -- expose it. Do not pass a bad path to SetTexture, which otherwise leaves
    -- stale art from the previous guide visible.
    local id=GetFileIDFromPath(self.selected.image)
    if not id then self.selected.image=nil end
  end
  return oldRenderDetails(self)
end
