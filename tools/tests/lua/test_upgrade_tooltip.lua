local repo=assert(arg[1],"repository path is required")
local addon=repo.."/ZygorGuidesViewerNew/ZygorGuidesViewer/"

local modules={}
ZygorGuidesViewer={
  Compat={Item={}},
  db={profile={gear={enabled=true,customWeights={}}}},
}
ZGV=ZygorGuidesViewer
function ZygorGuidesViewer:RegisterModule(name,module) modules[name]=module self[name]=module return module end
function ZygorGuidesViewer:RegisterEvent() end
function ZygorGuidesViewer:RegisterCallback() end
function ZygorGuidesViewer:Fire() end
function UnitClass() return "Warrior","WARRIOR" end
function UnitLevel() return 80 end
function GetInventorySlotInfo(name) return ({MainHandSlot=16})[name] end

local tooltip={hooks={},lines={}}
function tooltip:GetItem() return "Test sword","item:123" end
function tooltip:AddLine(text) self.lines[#self.lines+1]=text end
function tooltip:HookScript(event,callback) self.hooks[event]=callback end
GameTooltip=tooltip

dofile(addon.."Item-ItemScore.lua")
local score=ZygorGuidesViewer.ItemScore
score:SetFilters("WARRIOR",1,80)
score.GetItemDetails=function(_,link) return {itemlink=link,equipslot="INVTYPE_WEAPON"} end
dofile(addon.."Item-Upgrades.lua")
local upgrades=score.Upgrades
upgrades.EquippedItems[16]={name="MainHandSlot",score=1}
local classification,delta="upgrade",6.5
upgrades.GetComparison=function() return classification,16,delta,20,classification end
upgrades:HookUpgradeTooltips()
assert(tooltip.hooks.OnTooltipSetItem,"ordinary GameTooltip is hooked")
tooltip.hooks.OnTooltipSetItem(tooltip)
assert(tooltip.lines[1]=="Zygor Gear Advisor","upgrade tooltip has advisor heading")
assert(tooltip.lines[2]:find("Upgrade: %+6%.5 score",1),"upgrade tooltip reports the score increase")
assert(tooltip.lines[2]:find("MainHand",1,true),"upgrade tooltip identifies the replaced slot")

tooltip.lines={}
tooltip.ZygorGearUpgradeLink=nil
classification,delta="sidegrade",0
tooltip.hooks.OnTooltipSetItem(tooltip)
assert(tooltip.lines[2]:find("Sidegrade: %+0%.0 score",1),"sidegrade tooltip remains visible")

tooltip.lines={}
tooltip.ZygorGearUpgradeLink=nil
classification,delta="downgrade",-4.25
tooltip.hooks.OnTooltipSetItem(tooltip)
assert(tooltip.lines[2]:find("Downgrade: %-4%.2 score",1),"downgrade tooltip remains visible")

print("gear upgrade tooltip tests passed")
