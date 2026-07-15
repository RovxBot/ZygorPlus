local repo=assert(arg[1],"repository path is required")
local addon=repo.."/ZygorGuidesViewer/ZygorGuidesViewer/"

local Object={}
Object.__index=Object
function Object:SetWidth(value) self.width=value end
function Object:SetHeight(value) self.height=value end
function Object:SetPoint(...) self.point={...} end
function Object:SetFrameStrata() end
function Object:SetText(value) self.text=value end
function Object:SetScript(event,callback) self.scripts[event]=callback end
function Object:HookScript(event,callback) self.hooks[event]=callback end
function Object:GetParent() return self.parent end
function Object:SetParent(parent) self.parent=parent end
function Object:SetNormalTexture(value) self.normalTexture=setmetatable({parent=self,scripts={},hooks={}},Object) self.normalTexture.texture=value end
function Object:SetPushedTexture(value) self.pushedTexture=setmetatable({parent=self,scripts={},hooks={}},Object) self.pushedTexture.texture=value end
function Object:SetHighlightTexture(value) self.highlightTexture=setmetatable({parent=self,scripts={},hooks={}},Object) self.highlightTexture.texture=value end
function Object:GetNormalTexture() return self.normalTexture end
function Object:GetPushedTexture() return self.pushedTexture end
function Object:GetHighlightTexture() return self.highlightTexture end
function Object:SetTexCoord(...) self.texcoord={...} end
function Object:Show() self.shown=true end
function Object:Hide() self.shown=false end
function Object:IsShown() return self.shown and true or false end

local function object(name,parent)
  return setmetatable({name=name,parent=parent,scripts={},hooks={},shown=true},Object)
end

UIParent=object("UIParent")
PaperDollFrame=object("PaperDollFrame",UIParent)
GameTooltip=object("GameTooltip",UIParent)
function GameTooltip:SetOwner() end
function GameTooltip:SetText() end
function GameTooltip:AddLine() end

function CreateFrame(_,name,parent)
  return object(name,parent or UIParent)
end

local modules={}
ZygorGuidesViewer={
    SKINDIR="Interface\\AddOns\\ZygorGuidesViewer\\Skins\\",
    db={profile={gear={enabled=true}}},
  ItemScore={Items={}},
}
function ZygorGuidesViewer:RegisterModule(name,module) modules[name]=module self[name]=module return module end
function ZygorGuidesViewer:RegisterCallback() end
function ZygorGuidesViewer:RegisterEvent() end
function ZygorGuidesViewer:Fire() end

dofile(addon.."Item-GearFinder.lua")
local finder=assert(ZygorGuidesViewer.ItemScore.GearFinder)
assert(finder:AttachFrame(),"character-frame control attaches")
local button=assert(finder.PaperDollButton,"upgrade-search button exists")
assert(button:GetParent()==PaperDollFrame,"button belongs to PaperDollFrame")
assert(button.width==32,"button uses the reference utility-control width")
assert(button.height==32,"button uses the reference utility-control height")
assert(button.point[1]=="TOPRIGHT","button uses the paper-doll utility position")
assert(button.normalTexture and button.normalTexture.texture:find("popout-button-2",1,true),"button has a Zygor skin texture")
finder.ShowFinder=function(self) self.opened=true end
button.scripts.OnClick(button)
assert(finder.opened,"character button opens the gear finder")
ZygorGuidesViewer.db.profile.gear.enabled=false
finder:UpdateSystemTab()
assert(not button:IsShown(),"character button follows gear advisor enablement")

print("gear finder character button tests passed")
