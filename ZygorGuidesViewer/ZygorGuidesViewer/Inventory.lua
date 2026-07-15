local ZGV=ZygorGuidesViewer
local Inventory=ZGV:RegisterModule("Inventory",{items={},byID={},bank={},mail={},pending={},merchantOpen=false,ItemsToBuy={},Queue={}})

local protectedTools={
  [2901]=true,[1819]=true,[5956]=true,[6367]=true,[19970]=true,[6365]=true,[6256]=true,
  [6366]=true,[7005]=true,[12225]=true,[2709]=true,[9901]=true,
}

local function addIndex(index,item)
  if not item.itemID then return end
  local entries=index[item.itemID] or {}
  index[item.itemID]=entries
  entries[#entries+1]=item
end

function Inventory:Scan(includeBank)
  local container=ZGV.Compat.Container
  local items=container:Enumerate({includeBank=includeBank and true or false,includeKeyring=true})
  local byID={}
  for i=1,#items do
    local item=items[i]
    addIndex(byID,item)
    if item.itemID then
      local info=ZGV.Compat.Item:GetInfo(item.itemID)
      item.name=info.name item.vendorPrice=info.vendorPrice item.equipLocation=info.equipLocation
      if not info.ready and not self.pending[item.itemID] then
        self.pending[item.itemID]=true
        ZGV.Compat.Item:RequestInfo(item.itemID,function()
          Inventory.pending[item.itemID]=nil
          Inventory:Scan(ZGV.Compat.Container.bankOpen)
        end)
      end
    end
  end
  self.items=items self.byID=byID self.updatedAt=GetTime()
  if includeBank then
    self.bank={}
    local bankContainer=BANK_CONTAINER or -1
    for i=1,#items do
      local item=items[i]
      if item.bag==bankContainer or item.bag>(NUM_BAG_SLOTS or 4) then self.bank[#self.bank+1]=item end
    end
    ZGV.db.char.bank=self.bank
    ZGV.db.char.bankUpdated=time()
  end
  ZGV:Fire("ZGV_INVENTORY_UPDATED",self)
  return items
end

function Inventory:GetCount(itemID,includeBank)
  local count=0
  for _,item in ipairs(self.byID[tonumber(itemID)] or {}) do count=count+(item.count or 1) end
  if includeBank and not ZGV.Compat.Container.bankOpen then
    for _,item in ipairs(ZGV.db.char.bank or {}) do if item.itemID==tonumber(itemID) then count=count+(item.count or 1) end end
  end
  return count
end

function Inventory:Find(query,includeBank)
  query=tostring(query or ""):lower()
  local result,seen={},{}
  local function inspect(item,location)
    local name=item.name or (item.itemLink and item.itemLink:match("%[(.-)%]")) or ""
    if query=="" or name:lower():find(query,1,true) or tostring(item.itemID)==query then
      local key=tostring(location)..":"..tostring(item.bag)..":"..tostring(item.slot)
      if not seen[key] then item.location=location result[#result+1]=item seen[key]=true end
    end
  end
  for _,item in ipairs(self.items) do inspect(item,"bags") end
  if includeBank and not ZGV.Compat.Container.bankOpen then for _,item in ipairs(ZGV.db.char.bank or {}) do inspect(item,"bank") end end
  for _,item in ipairs(self.mail) do inspect(item,"mail") end
  return result
end

function Inventory:UseItem(itemID)
  local matches=ZGV.Compat.Container:FindItem(itemID,{includeKeyring=true})
  if #matches==0 then return false,"missing" end
  local result=ZGV.Compat.Container:Use(matches[1].bag,matches[1].slot)
  return result.ok,result.code
end

function Inventory:GetFreeSlots()
  local total=0
  local container=ZGV.Compat.Container
  for bag=0,(NUM_BAG_SLOTS or 4) do total=total+(container:GetNumFreeSlots(bag).free or 0) end
  return total
end

function Inventory:UpdateBagspaceText()
  local free=self:GetFreeSlots()
  if not self.bagSpaceText and MainMenuBarBackpackButton and MainMenuBarBackpackButton.CreateFontString then
    local label=MainMenuBarBackpackButton:CreateFontString(nil,"OVERLAY","NumberFontNormalSmall")
    label:SetPoint("BOTTOMRIGHT",MainMenuBarBackpackButton,"BOTTOMRIGHT",-1,2)
    self.bagSpaceText=label
  end
  if self.bagSpaceText then
    self.bagSpaceText:SetText(tostring(free))
    ZGV.Compat.UI:SetShown(self.bagSpaceText,ZGV.db.profile.inventory and ZGV.db.profile.inventory.showBagSpace)
  end
  return free
end

function Inventory:SetKeptItem(itemID,kept)
  if not itemID then return false end
  ZGV.db.char.keptItems=ZGV.db.char.keptItems or {}
  if kept==false then ZGV.db.char.keptItems[tonumber(itemID)]=nil else ZGV.db.char.keptItems[tonumber(itemID)]=true end
  return true
end

function Inventory:addKeptItem(itemID) return self:SetKeptItem(itemID,true) end

function Inventory:IsTravelItem(itemID)
  local rover=_G.LibRover
  if not (rover and rover.data and rover.data.portkeys) then return false end
  for _,entry in ipairs(rover.data.portkeys) do if tonumber(entry.item)==tonumber(itemID) then return true end end
  return false
end

function Inventory:GetGrayTrashDetails()
  local result={}
  local kept=ZGV.db.char.keptItems or {}
  for _,item in ipairs(ZGV.Compat.Container:Enumerate({includeKeyring=true})) do
    local info=ZGV.Compat.Item:GetInfo(item.itemID)
    if item.quality==0 and not item.isQuestItem and not kept[item.itemID] and not protectedTools[item.itemID]
      and not self:IsTravelItem(item.itemID) and (info.vendorPrice or 0)>0 then
      result[#result+1]={bagID=item.bag,bagSlotID=item.slot,itemName=info.name,itemID=item.itemID,count=item.count or 1,price=(info.vendorPrice or 0)*(item.count or 1),texture=item.texture,item=item}
    end
  end
  table.sort(result,function(a,b) return a.price<b.price end)
  return result
end

function Inventory:DestroyItem(entry)
  if not entry or InCombatLockdown and InCombatLockdown() then return false,"combat_lockdown" end
  local item=entry.item or entry
  if item.bag==nil or item.slot==nil then return false,"invalid_item" end
  local picked=ZGV.Compat.Container:Pickup(item.bag,item.slot)
  if not picked.ok then return false,picked.code end
  if type(DeleteCursorItem)~="function" then if ClearCursor then ClearCursor() end return false,"api_unavailable" end
  local ok,errorMessage=pcall(DeleteCursorItem)
  if not ok and ClearCursor then ClearCursor() end
  return ok,ok and "destroyed" or errorMessage
end

function Inventory:HandleTrashMacro()
  local entry=self:GetGrayTrashDetails()[1]
  if not entry then return false,"no_trash" end
  if GetMouseButtonClicked and GetMouseButtonClicked()=="RightButton" then
    self:SetKeptItem(entry.itemID,true)
    return true,"kept"
  end
  if IsShiftKeyDown and IsShiftKeyDown() then return self:DestroyItem(entry) end
  return false,"hold_shift_to_destroy"
end

function Inventory:SetUpGreySellButton()
  if self.greySellButton or not MerchantFrame then return end
  local button=CreateFrame("Button","ZygorGuidesViewerSellButton",MerchantFrame,"UIPanelButtonTemplate")
  button:SetWidth(112) button:SetHeight(22) button:SetPoint("TOPLEFT",MerchantFrame,"TOPLEFT",58,-31)
  button:SetText("Sell Grey Items")
  button:SetScript("OnClick",function() Inventory:SellGreys() end)
  button:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_BOTTOM") GameTooltip:SetText("Sell grey items, excluding kept and guide-protected items.") GameTooltip:Show()
  end)
  button:SetScript("OnLeave",function() GameTooltip:Hide() end)
  self.greySellButton=button
end

function Inventory:GetUnusableItems()
  local result={}
  local upgrades=ZGV.ItemScore and ZGV.ItemScore.Upgrades
  if not upgrades then return result end
  upgrades:ScanBagsForUpgrades()
  local kept=ZGV.db.char.keptItems or {}
  for _,item in ipairs(ZGV.Compat.Container:Enumerate({includeKeyring=true})) do
    local info=ZGV.Compat.Item:GetInfo(item.itemID)
    local details=ZGV.ItemScore:GetItemDetails(item.itemLink)
    local isUpgrade=upgrades:IsUpgrade(details)
    local equipment=details and ZGV.ItemScore.possEquipSlots[details.equipslot]
    if equipment and not isUpgrade and not kept[item.itemID] and not protectedTools[item.itemID]
      and not self:IsTravelItem(item.itemID) and (info.vendorPrice or 0)>0 and (info.quality or 0)<5 then
      result[#result+1]={itemID=item.itemID,itemLink=item.itemLink,itemName=info.name,bagID=item.bag,bagSlotID=item.slot,itemQuality=info.quality}
    end
  end
  table.sort(result,function(a,b) return tostring(a.itemName)<tostring(b.itemName) end)
  return result
end

function Inventory:ScanMail()
  self.mail={}
  if not GetInboxNumItems or not GetInboxItem then return end
  local count=GetInboxNumItems() or 0
  for mailIndex=1,count do
    for attachment=1,(ATTACHMENTS_MAX_RECEIVE or 12) do
      local name,itemID,texture,itemCount,quality=GetInboxItem(mailIndex,attachment)
      if name then
        local link=GetInboxItemLink and GetInboxItemLink(mailIndex,attachment)
        itemID=tonumber(itemID) or (link and tonumber(link:match("item:(%d+)")))
        self.mail[#self.mail+1]={mail=mailIndex,slot=attachment,name=name,itemID=itemID,texture=texture,count=itemCount,quality=quality,itemLink=link}
      end
    end
  end
  ZGV.db.char.mail=self.mail
end

function Inventory:Repair()
  if not self.merchantOpen or not CanMerchantRepair or not CanMerchantRepair() then return false end
  local cost,possible=GetRepairAllCost()
  if possible and cost and cost>0 and GetMoney()>=cost then RepairAllItems() return true,cost end
  return false
end

function Inventory:SellGreys()
  if not self.merchantOpen or InCombatLockdown and InCombatLockdown() then return false end
  local queue=self:GetGrayTrashDetails()
  if #queue==0 then return true,0 end
  local sold,value,index=0,0,1
  local function sellNext()
    local item=queue[index]
    if not item or not Inventory.merchantOpen then return end
    local result=ZGV.Compat.Container:Use(item.bagID,item.bagSlotID)
    if result.ok then sold=sold+1 value=value+(item.price or 0) end
    index=index+1
    if queue[index] then ZGV.Compat.Timer:After(.12,sellNext)
    else ZGV:Fire("ZGV_GREYS_SOLD",sold,value) end
  end
  sellNext()
  return true,#queue
end

function Inventory:FindItemsToBuy()
  local runtime=ZGV.Runtime
  if not self.merchantOpen or not runtime or not runtime.currentStep then return {} end
  -- Runtime stores the selected step as its numeric position.  Older viewer
  -- code assumed the fully resolved step table, which made the merchant
  -- helper fail as soon as it evaluated currentStep.goals.
  local step=runtime.currentStep
  if type(step)~="table" then
    local guide=runtime.currentGuide
    step=guide and guide.steps and guide.steps[tonumber(step)]
  end
  if type(step)~="table" then return {} end
  local wanted={}
  for _,goal in ipairs(step.goals or {}) do
    if goal.action=="buy" and goal.itemID then
      local have=self:GetCount(goal.itemID,false)
      local needed=math.max(0,(tonumber(goal.count) or 1)-have)
      if needed>0 then wanted[goal.itemID]={itemID=goal.itemID,amount=needed,name=goal.target or goal.text} end
    end
  end
  if not next(wanted) then self.ItemsToBuy={} return self.ItemsToBuy end
  local total=0
  for index=1,(GetMerchantNumItems and GetMerchantNumItems() or 0) do
    local name,_,price,stack,available,_,_,extended=GetMerchantItemInfo(index)
    local link=GetMerchantItemLink and GetMerchantItemLink(index)
    local id=link and tonumber(link:match("item:(%d+)"))
    local entry=id and wanted[id]
    if entry and not extended and (available==-1 or available>=entry.amount) then
      entry.index=index entry.maxStack=math.max(1,tonumber(stack) or 1) entry.name=entry.name or name
      total=total+entry.amount*((tonumber(price) or 0)/entry.maxStack)
    end
  end
  self.ItemsToBuy=wanted
  self.BuyTotal=total
  ZGV:Fire("ZGV_VENDOR_BUY_LIST",wanted,total)
  return wanted,total
end

function Inventory:FindItemsToBuyDelayed(delay)
  if self.buyPending then return end
  self.buyPending=true
  ZGV.Compat.Timer:After(tonumber(delay) or .10,function() Inventory.buyPending=false Inventory:FindItemsToBuy() end)
end

function Inventory:BuyItems()
  if not self.merchantOpen or InCombatLockdown and InCombatLockdown() then return false,"merchant_unavailable" end
  local entries={}
  for _,entry in pairs(self.ItemsToBuy or {}) do if entry.index then entries[#entries+1]=entry end end
  table.sort(entries,function(a,b) return a.index>b.index end)
  for _,entry in ipairs(entries) do
    while entry.amount>0 do
      local count=math.min(entry.amount,entry.maxStack)
      if type(BuyMerchantItem)~="function" then return false,"api_unavailable" end
      BuyMerchantItem(entry.index,count)
      entry.amount=entry.amount-count
    end
  end
  self.ItemsToBuy={}
  return true,"purchased"
end

function Inventory:QueueMoveItems(source,itemID,count)
  self.Queue[#self.Queue+1]={source=source,itemID=tonumber(itemID),count=count or "all"}
  if self.QueuePending then return end
  self.QueuePending=true
  local function nextMove()
    local entry=table.remove(Inventory.Queue,1)
    if entry then
      Inventory:MoveItems(entry.source,entry.itemID,entry.count)
      ZGV.Compat.Timer:After(.12,nextMove)
    else Inventory.QueuePending=false end
  end
  nextMove()
end

function Inventory:MoveItems(source,itemID,count)
  if not itemID or not ZGV.Compat.Container.bankOpen then return false,"bank_closed" end
  local from=source=="bank" and {BANK_CONTAINER or -1,5,6,7,8,9,10,11} or {0,1,2,3,4}
  local to=source=="bank" and {0,1,2,3,4} or {BANK_CONTAINER or -1,5,6,7,8,9,10,11}
  if count=="all" then count=0 for _,entry in ipairs(ZGV.Compat.Container:FindItem(itemID,{includeBank=source=="bank"})) do if (source=="bank")==(entry.bag==(BANK_CONTAINER or -1) or entry.bag>4) then count=count+(entry.count or 1) end end end
  count=tonumber(count) or 0
  if count<=0 then return true,"nothing_to_move" end
  local target
  for _,bag in ipairs(to) do if (ZGV.Compat.Container:GetNumFreeSlots(bag).free or 0)>0 then target=bag break end end
  if not target then return false,"no_space" end
  for _,bag in ipairs(from) do
    for slot=1,(ZGV.Compat.Container:GetNumSlots(bag).count or 0) do
      if count<=0 then break end
      local entry=ZGV.Compat.Container:GetItemInfo(bag,slot)
      if entry.itemID==itemID then
        local amount=math.min(count,entry.count or 1)
        if amount<(entry.count or 1) then ZGV.Compat.Container:Split(bag,slot,amount) else ZGV.Compat.Container:Pickup(bag,slot) end
        local destination=ZGV.Compat.Container:GetInventoryID(target)
        if destination and type(PutItemInBag)=="function" then PutItemInBag(destination) elseif ClearCursor then ClearCursor() end
        count=count-amount
      end
    end
  end
  if ClearCursor then ClearCursor() end
  return count==0,count==0 and "moved" or "partial"
end

function Inventory:RecordBank()
  if not ZGV.Compat.Container.bankOpen then return false,"bank_closed" end
  self:Scan(true)
  return true,self.bank
end

function Inventory:CountBank(itemID)
  local count=0
  for _,item in ipairs(self.bank or ZGV.db.char.bank or {}) do if item.itemID==tonumber(itemID) then count=count+(item.count or 1) end end
  return count
end

function Inventory:OnEvent(event)
  if event=="BANKFRAME_OPENED" then self:Scan(true)
  elseif event=="BANKFRAME_CLOSED" then self:Scan(false)
  elseif event=="MAIL_SHOW" or event=="MAIL_INBOX_UPDATE" then self:ScanMail()
  elseif event=="MERCHANT_SHOW" then
    self.merchantOpen=true
    self:SetUpGreySellButton()
    if self.greySellButton then self.greySellButton:Show() end
    if ZGV.db.profile.automation.repair then self:Repair() end
    if ZGV.db.profile.automation.sellGreys then self:SellGreys() end
    self:FindItemsToBuyDelayed()
  elseif event=="MERCHANT_CLOSED" then self.merchantOpen=false if self.greySellButton then self.greySellButton:Hide() end
  else self:Scan(ZGV.Compat.Container.bankOpen) self:UpdateBagspaceText() end
end

function Inventory:OnStartup()
  self.bank=ZGV.db.char.bank or {}
  self.mail=ZGV.db.char.mail or {}
  ZGV.db.char.keptItems=ZGV.db.char.keptItems or {}
  self:Scan(false)
  self:UpdateBagspaceText()
end

for _,event in ipairs({"BAG_UPDATE","BANKFRAME_OPENED","BANKFRAME_CLOSED","PLAYERBANKSLOTS_CHANGED","MAIL_SHOW","MAIL_INBOX_UPDATE","MERCHANT_SHOW","MERCHANT_CLOSED"}) do
  ZGV:RegisterEvent(event,Inventory,"OnEvent")
end

ZGV.WhoWhere=ZGV.WhoWhere or {}
function ZGV.WhoWhere:FindItem(query) return Inventory:Find(query,true) end
