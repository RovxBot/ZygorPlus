local repo=assert(arg[1],"repository path is required")
local addon=repo.."/ZygorGuidesViewer/ZygorGuidesViewer/"

local function assertEqual(actual,expected,label)
  if actual~=expected then error(("%s: expected %s, got %s"):format(label,tostring(expected),tostring(actual)),2) end
end

local Object={}
Object.__index=Object
function Object:SetWidth(value) self.width=value end
function Object:SetHeight(value) self.height=value end
function Object:SetSize(width,height) self.width,self.height=width,height end
function Object:GetWidth() return self.width or 0 end
function Object:GetHeight() return self.height or 0 end
function Object:SetPoint(...) self.point={...} end
function Object:ClearAllPoints() self.point=nil end
function Object:SetAllPoints() self.allPoints=true end
function Object:SetParent(parent) self.parent=parent end
function Object:GetParent() return self.parent end
function Object:GetName() return self.name end
function Object:SetScript(event,callable) self.scripts[event]=callable end
function Object:HookScript(event,callable) self.hooks[event]=self.hooks[event] or {} self.hooks[event][#self.hooks[event]+1]=callable end
function Object:Show() self.shown=true end
function Object:Hide() self.shown=false end
function Object:IsShown() return self.shown and true or false end
function Object:IsVisible() return self:IsShown() end
function Object:Enable() self.enabled=true end
function Object:Disable() self.enabled=false end
function Object:IsEnabled() return self.enabled~=false end
function Object:EnableMouse() end
function Object:SetMovable() end
function Object:SetClampedToScreen() end
function Object:SetFrameStrata() end
function Object:SetFrameLevel() end
function Object:RegisterForDrag() end
function Object:StartMoving() end
function Object:StopMovingOrSizing() end
function Object:SetTexture(value) self.texture=value end
function Object:SetTexCoord(...) self.texcoord={...} end
function Object:SetVertexColor(...) self.vertex={...} end
function Object:SetTextColor(...) self.textColor={...} end
function Object:SetDrawLayer() end
function Object:SetJustifyH() end
function Object:SetJustifyV() end
function Object:SetFont(path,size,flags) self.font={path,size,flags} end
function Object:GetFont() return "Fonts\\FRIZQT__.TTF",12,"" end
function Object:SetText(value) self.text=value end
function Object:GetText() return self.text end
function Object:SetChecked(value) self.checked=value end
function Object:GetChecked() return self.checked end
function Object:SetButtonState(value) self.buttonState=value end
function Object:SetNormalTexture(value) self.normalTexture=value end
function Object:SetPushedTexture(value) self.pushedTexture=value end
function Object:SetHighlightTexture(value) self.highlightTexture=value end
function Object:SetScrollChild(value) self.scrollChild=value end
function Object:GetEffectiveScale() return 1 end
function Object:GetLeft() return 180 end
function Object:GetRight() return 580 end
function Object:GetBottom() return 80 end
function Object:GetTop() return 600 end
function Object:CreateTexture(name)
  local child=setmetatable({name=name,parent=self,scripts={},hooks={},shown=true},Object)
  if name then _G[name]=child end
  return child
end
function Object:CreateFontString(name)
  local child=setmetatable({name=name,parent=self,scripts={},hooks={},shown=true},Object)
  if name then _G[name]=child end
  return child
end

local function object(name,parent,template)
  local value=setmetatable({name=name,parent=parent,scripts={},hooks={},shown=true,enabled=true,template=template},Object)
  if name then _G[name]=value end
  if template=="UICheckButtonTemplate" and name then _G[name.."Text"]=value:CreateFontString(name.."Text") end
  return value
end

UIParent=object("UIParent")
PlayerTalentFrame=object("PlayerTalentFrame",UIParent)
PlayerTalentFrame.pet=false
MAX_NUM_TALENTS=1
PlayerTalentFrameTalent1=object("PlayerTalentFrameTalent1",PlayerTalentFrame)
PlayerTalentFrameTalent1.icon=PlayerTalentFrameTalent1:CreateTexture("PlayerTalentFrameTalent1IconTexture")

function CreateFrame(_,name,parent,template) return object(name,parent or UIParent,template) end
function PanelTemplates_GetSelectedTab() return 1 end
function UnitClass() return "Shaman","SHAMAN" end
function GetCVarBool() return false end
function TalentFrame_LoadUI() end
function IsAddOnLoaded() return true end
function ResetGroupPreviewTalentPoints() end
local previewPoints=0
function GetGroupPreviewTalentPointsSpent() return previewPoints end
function AddPreviewTalentPoints() previewPoints=previewPoints+1 end
function UIDropDownMenu_Initialize(frame,initializer) frame.initializer=initializer end
function UIDropDownMenu_SetWidth(frame,width) frame.dropdownWidth=width end
function UIDropDownMenu_JustifyText() end
function UIDropDownMenu_SetText(frame,value) frame.dropdownText=value end
function UIDropDownMenu_SetSelectedValue(frame,value) frame.dropdownValue=value end
function UIDropDownMenu_CreateInfo() return {} end
local dropdownButtons={}
function UIDropDownMenu_AddButton(info) dropdownButtons[#dropdownButtons+1]=info end
function CloseDropDownMenus() end
function hooksecurefunc() end

GameTooltip=object("GameTooltip",UIParent)
function GameTooltip:SetOwner() end
function GameTooltip:AddLine(value) self.lines=self.lines or {} self.lines[#self.lines+1]=value end
function GameTooltip:SetTalent() end
StaticPopupDialogs={}
function StaticPopup_Show() return object(nil,UIParent) end
ACCEPT="Accept"
CANCEL="Cancel"

local callbacks={}
local events={}
local modules={}
local build={id="SHAMAN:Leveling",class="SHAMAN",title="WotLK Enhancement Leveling",glyphs={"Major Glyph of Stormstrike","Minor Glyph of Ghost Wolf"}}
local point={tab=1,index=1,name="Ancestral Knowledge",targetRank=1,currentRank=0,isPet=false,texture="Interface\\Icons\\Spell_Shadow_GrimWard"}
local state={
  build=build,ready=true,code="GREEN",message="On track. 1 unspent talent point available.",
  suggestions={point},allMissing={point},unspent=1,wrong=0,complete=false,isPet=false,
  compiled={isPet=false,sequence={{tab=1,index=1,name=point.name}}},
}
ZygorGuidesViewer={
  SKINDIR="Interface\\AddOns\\ZygorGuidesViewer\\Skins\\",
  db={profile={talent={selected={},enabled=true,hints=true,rankPreview=true,docked=true,autoOpen=true,shown=true,confirmLearn=true,forceBuild=false,x=180,y=80}}},
  Compat={Talent={}},Talent={},
}
local ZGV=ZygorGuidesViewer
function ZGV:RegisterModule(name,module) modules[name]=module self[name]=module return module end
function ZGV:RegisterCallback(event,owner,method) callbacks[event]={owner=owner,method=method} end
function ZGV:RegisterEvent(event,owner,method) events[event]={owner=owner,method=method} end
function ZGV:Print(message) self.lastPrint=message end
function ZGV:LogError() end
function ZGV.Talent:GetBuilds() return {build} end
function ZGV.Talent:GetSelected() return build end
function ZGV.Talent:GetPetBuilds() return {},nil end
function ZGV.Talent:GetPetType() return nil end
function ZGV.Talent:GetSuggestionState() return state end
function ZGV.Talent:GetGlyphRecommendations() return build.glyphs end
function ZGV.Talent:InitializeBuilds() self.dataReady=true return true end
function ZGV.Talent:LoadBlizzardTalentUI() end
function ZGV.Talent:SelectBuild() return true end
function ZGV.Talent:GetNextPoint() return point end
function ZGV.Talent:LearnNext() return true,point end
function ZGV.Talent:RegisterBuild(class,title,raw,glyphs) return {id=class..":"..title,class=class,title=title,raw=raw,glyphs=glyphs} end
function ZGV.Compat.Talent:GetTab() return {name="Enhancement"} end
function ZGV.Compat.Talent:GetInfo() return {rank=0,maxRank=5,texture=point.texture,meetsPrerequisite=true} end
function ZGV.Compat.Talent:GetActiveGroup() return 1 end
function ZGV.Compat.Talent:GetUnspentPoints() return 1 end
function ZGV.Compat.Talent:Learn() return {ok=true} end

dofile(addon.."ModernTalentAdvisor.lua")
dofile(addon.."Code-TBC/TalentAdvisor.lua")
dofile(addon.."Code-TBC/TalentAdvisor-Registering.lua")
dofile(addon.."Code-TBC/TalentAdvisor-Popout.lua")

local Advisor=assert(ZGV.TalentAdvisor)
local savedDatabase=ZGV.db
ZGV.db=nil
local earlyBuilds,earlySelected=Advisor:GetContext()
assertEqual(#earlyBuilds,0,"startup context tolerates an uninitialized database")
assertEqual(earlySelected,nil,"startup context has no selected build before profile initialization")
ZGV.db=savedDatabase
Advisor:OnStartup()
Advisor:Show()
assertEqual(Advisor.frame:GetWidth(),250,"Classic popout width")
assertEqual(Advisor.frame:GetHeight(),350,"Classic popout keeps a stable recommendation workspace")
assertEqual(Advisor.frame.point[4],-36,"docked advisor uses the Classic frame-edge offset")
assertEqual(Advisor.frame.point[5],-130,"docked advisor uses the Classic vertical alignment")
assertEqual(Advisor.frame.build:GetText(),build.title,"selected build uses the Classic text line")
assertEqual(Advisor.frame.status:GetText(),"Recommended talents:","Classic recommendation label rendering")
assertEqual(Advisor.frame.groups[1].heading:GetText(),"Enhancement","Classic recommendation tree heading")
assert(Advisor.frame.groups[1].talents:GetText():find(point.name,1,true),"Classic recommendation list rendering")
assert(Advisor.frame.groups[1].talents:GetText():find("(1)",1,true),"Classic recommendation rank rendering")
assertEqual(Advisor.frame.topRight.texture,ZGV.SKINDIR.."popout-noclose","docked popout uses the seamless Classic corner")
assertEqual(Advisor.frame.glyphBox.recommendations[1],build.glyphs[1],"glyph recommendations")
assertEqual(Advisor.frame.scroll:GetName(),"ZygorTalentAdvisorPopoutScroll","legacy skin-compatible scroll name")
assert(_G.ZygorTalentAdvisorPopoutAcceptButton,"legacy skin-compatible accept button")
assertEqual(PlayerTalentFrameTalent1.ZygorHint:IsShown(),true,"on-tree recommendation arrow")
assertEqual(PlayerTalentFrameTalent1.ZygorDesiredRank:IsShown(),true,"on-tree desired rank")
assertEqual(type(ZygorTalentAdvisorPopout_Toggle),"function","legacy popout global")
assertEqual(_G.ZygorTalentAdvisor,Advisor,"legacy global advisor")

-- Several 3.3.5a UI packs define a hidden PlayerTalentFrame alongside the
-- visible TalentFrame.  The popout must follow the displayed Blizzard frame.
TalentFrame=object("TalentFrame",UIParent)
PlayerTalentFrame:Hide()
TalentFrame:Show()
Advisor:Show()
assertEqual(Advisor.frame:GetParent(),TalentFrame,"advisor docks to the visible talent frame")
assertEqual(Advisor.frame.point[2],TalentFrame,"advisor anchor uses the visible talent frame")

dropdownButtons={}
Advisor.frame.buildDropdown.initializer()
assertEqual(dropdownButtons[1].text,build.title,"build dropdown entry")
local registered=Advisor:RegisterBuild("SHAMAN","External Build",{},nil)
assertEqual(registered.title,"External Build","external build registration facade")
local anniversary=Advisor:RegisterBuild("SHAMAN","Anniversary Build",2,"2 Ancestral Knowledge")
assertEqual(anniversary.raw,"2 Ancestral Knowledge","Anniversary registration signature")
assertEqual(anniversary.statweights,2,"Anniversary statweights retained")

local ok,count=Advisor:PreviewSuggestions()
assertEqual(ok,true,"preview suggestions")
assertEqual(count,1,"previewed point count")

print("talent advisor UI tests passed")
