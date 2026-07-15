local repo=assert(arg[1],"repository path is required")
local addon=repo.."/ZygorGuidesViewerNew/ZygorGuidesViewer/"

local modules={}
ZygorGuidesViewer={
  db={char={bank={},mail={}},profile={automation={}}},
  Compat={Container={},Item={},Timer={},UI={}},
}
local ZGV=ZygorGuidesViewer
function ZGV:RegisterModule(name,module) modules[name]=module self[name]=module return module end
function ZGV:RegisterEvent() end
function ZGV:Fire(event,...) self.lastEvent={event,...} end

function GetMerchantNumItems() return 1 end
function GetMerchantItemInfo(index)
  assert(index==1,"merchant fixture index")
  return "Test Reagent",nil,200,1,-1,nil,nil,false
end
function GetMerchantItemLink(index)
  assert(index==1,"merchant link fixture index")
  return "|Hitem:12345:0:0:0|h[Test Reagent]|h"
end

dofile(addon.."Inventory.lua")
local Inventory=assert(ZGV.Inventory)
Inventory.merchantOpen=true
Inventory.byID={[12345]={{itemID=12345,count=1}}}
ZGV.Runtime={
  currentStep=1,
  currentGuide={steps={{goals={{action="buy",itemID=12345,count=3,target="Test Reagent"}}}}},
}

local wanted,total=Inventory:FindItemsToBuy()
assert(wanted[12345],"numeric Runtime step resolves to its guide step")
assert(wanted[12345].amount==2,"buy list subtracts inventory count")
assert(total==400,"buy list totals the missing reagent cost")
assert(ZGV.lastEvent[1]=="ZGV_VENDOR_BUY_LIST","buy-list update is emitted")

ZGV.Runtime.currentStep=2
local missing=Inventory:FindItemsToBuy()
assert(next(missing)==nil,"out-of-range numeric Runtime step safely yields no buy list")

print("inventory buy-list tests passed")
