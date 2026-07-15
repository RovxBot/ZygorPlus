-- Bag and equipped-item upgrade service for the WotLK scorer.
local ZGV=ZygorGuidesViewer
local ItemScore=ZGV and ZGV.ItemScore
if not ItemScore then return end

local Upgrades=ZGV:RegisterModule("ItemUpgrades",{EquippedItems={},UpgradeQueue={},UpgradeQueueFlat={},BagsItems={},ReportedUpgrades={}})
ItemScore.Upgrades=Upgrades
ItemScore.AutoEquip=Upgrades -- legacy public name used by quest-item helpers.

local inventorySlots={
  "HeadSlot","NeckSlot","ShoulderSlot","BackSlot","ChestSlot","WristSlot","HandsSlot","WaistSlot",
  "LegsSlot","FeetSlot","Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot","MainHandSlot",
  "SecondaryHandSlot","RangedSlot",
}

local function option(name,default)
  local gear=ZGV.db and ZGV.db.profile and ZGV.db.profile.gear
  if gear and gear[name]~=nil then return gear[name] end
  return default
end

local function itemKey(link)
  return ItemScore.strip_link(link)
end

function Upgrades:IsEnabled()
  return option("enabled",true) and ItemScore:GetRule()~=nil
end

function Upgrades:GetEquipped(slot)
  return self.EquippedItems[slot] or {slot=slot,score=0}
end

function Upgrades:ScoreEquippedItems()
  if not self:IsEnabled() then return false,"disabled" end
  local result={}
  for _,name in ipairs(inventorySlots) do
    local slot=GetInventorySlotInfo and GetInventorySlotInfo(name)
    if slot then
      local link=GetInventoryItemLink and GetInventoryItemLink("player",slot)
      local entry={slot=slot,name=name,itemlink=link,score=0}
      if link then
        local details=ItemScore:GetItemDetails(link)
        local score=details and ItemScore:GetItemScore(details,nil,nil,nil,nil,slot)
        if tonumber(score) and score>0 then entry.score=score end
        entry.itemid=details and details.itemid
        entry.equipslot=details and details.equipslot
        entry.details=details
        if ItemScore.QuestItem and ItemScore.QuestItem:IsProtectedQuestItem(link) then entry.protected=true entry.score=math.huge end
      end
      result[slot]=entry
    end
  end
  self.EquippedItems=result
  self.ScoredEquippedItems=true
  ZGV:Fire("ZGV_EQUIPMENT_SCORED",result)
  return true,result
end

local function lowestCandidate(candidates,equipped)
  local selected,score
  for _,slot in ipairs(candidates) do
    local entry=equipped[slot] or {score=0}
    if not entry.protected and (score==nil or (entry.score or 0)<score) then selected,score=slot,entry.score or 0 end
  end
  return selected,score
end

function Upgrades:GetReplacement(details)
  if not details then return nil,0,"missing item details" end
  local candidates=ItemScore:GetSlotCandidates(details.equipslot)
  if #candidates==0 then return nil,0,"item cannot be equipped" end
  local selected,score=lowestCandidate(candidates,self.EquippedItems)
  if not selected then return nil,0,"every candidate slot is quest-protected" end
  if details.equipslot=="INVTYPE_2HWEAPON" and not ItemScore.playerdual2h then
    local main=GetInventorySlotInfo and GetInventorySlotInfo("MainHandSlot")
    local off=GetInventorySlotInfo and GetInventorySlotInfo("SecondaryHandSlot")
    local mainEntry=main and self:GetEquipped(main) or {}
    local offEntry=off and self:GetEquipped(off) or {}
    if mainEntry.protected or offEntry.protected then return nil,0,"a quest-protected weapon would be replaced" end
    selected,score=main,(mainEntry.score or 0)+(offEntry.score or 0)
  elseif details.equipslot=="INVTYPE_WEAPON" and not ItemScore.playerdualwield then
    local main=GetInventorySlotInfo and GetInventorySlotInfo("MainHandSlot")
    local mainEntry=main and self:GetEquipped(main) or {}
    if mainEntry.protected then return nil,0,"the main-hand quest item is protected" end
    selected,score=main,mainEntry.score or 0
  end
  return selected,score
end

function Upgrades:GetComparison(item,options)
  options=options or {}
  if not self:IsEnabled() then return nil,nil,0,0,"gear scoring is disabled" end
  if not self.ScoredEquippedItems then self:ScoreEquippedItems() end
  local details=type(item)=="table" and item or ItemScore:GetItemDetails(item)
  if not details then return nil,nil,0,0,"item information is not cached" end
  if ItemScore.QuestItem and ItemScore.QuestItem:IsProtectedQuestItem(details.itemlink) then
    return nil,nil,0,0,"quest item is protected"
  end
  local slot,oldScore,slotReason=self:GetReplacement(details)
  local score,code,reason=ItemScore:GetItemScore(details,nil,nil,options.allowbad,nil,slot)
  if not score or score<0 then return nil,nil,0,0,reason or code end
  if not slot then return nil,nil,0,score,slotReason end
  local change=score-(oldScore or 0)
  if change>.01 then return "upgrade",slot,change,score,"upgrade" end
  if change<-.01 then return "downgrade",slot,change,score,"equipped item scores higher" end
  return "sidegrade",slot,change,score,"equipped item scores the same"
end

function Upgrades:IsUpgrade(item,options)
  local classification,slot,change,score,reason=self:GetComparison(item,options)
  return classification=="upgrade",slot,change,score,reason
end

function Upgrades:GetSlotName(slot)
  local entry=self.EquippedItems and self.EquippedItems[slot]
  local name=entry and entry.name or nil
  if not name then return "an equipped item" end
  name=name:gsub("Slot$",""):gsub("(%d)$"," %1")
  return name
end

function Upgrades:AppendUpgradeTooltip(tooltip)
  if not tooltip or not self:IsEnabled() or type(tooltip.GetItem)~="function" then return end
  local name,link=tooltip:GetItem()
  link=link or name
  if not link or tooltip.ZygorGearUpgradeLink==link then return end
  local details=ItemScore:GetItemDetails(link)
  if not details then return end -- Item data is still being cached; the next hover retries it.
  tooltip.ZygorGearUpgradeLink=link
  local classification,slot,delta=self:GetComparison(details)
  if not classification or type(tooltip.AddLine)~="function" then return end
  local label,color
  if classification=="upgrade" then label,color="Upgrade",{.20,1,.20}
  elseif classification=="downgrade" then label,color="Downgrade",{1,.28,.28}
  else label,color="Sidegrade",{1,.82,.20} end
  tooltip:AddLine("Zygor Gear Advisor",1,.65,.10)
  tooltip:AddLine(("%s: %+.1f score (replaces %s)"):format(label,delta,self:GetSlotName(slot)),color[1],color[2],color[3],true)
end

function Upgrades:HookTooltip(tooltip)
  if not tooltip or tooltip.ZygorGearUpgradeHooked or type(tooltip.HookScript)~="function" then return end
  tooltip.ZygorGearUpgradeHooked=true
  tooltip:HookScript("OnTooltipSetItem",function(frame) Upgrades:AppendUpgradeTooltip(frame) end)
  tooltip:HookScript("OnTooltipCleared",function(frame) frame.ZygorGearUpgradeLink=nil end)
end

function Upgrades:HookUpgradeTooltips()
  self:HookTooltip(_G.GameTooltip)
  self:HookTooltip(_G.ItemRefTooltip)
  self:HookTooltip(_G.ShoppingTooltip1)
  self:HookTooltip(_G.ShoppingTooltip2)
end

function Upgrades:ScanBagsForUpgrades(forced)
  if not self:IsEnabled() then return {} end
  if not self.ScoredEquippedItems or forced then self:ScoreEquippedItems() end
  local container=ZGV.Compat and ZGV.Compat.Container
  if not container then return {} end
  local queue,flat,bags={}, {}, {}
  for _,item in ipairs(container:Enumerate({includeKeyring=true})) do
    if item.itemLink and item.itemID then
      local details=ItemScore:GetItemDetails(item.itemLink)
      if details then
        local isUpgrade,slot,change,score,reason=self:IsUpgrade(details)
        bags[itemKey(item.itemLink)]={bag=item.bag,slot=item.slot,item=item,details=details}
        if isUpgrade then
          local entry={item=item,details=details,slot=slot,delta=change,score=score,reason=reason}
          queue[slot]=queue[slot] or {}
          queue[slot][#queue[slot]+1]=entry
          flat[itemKey(item.itemLink)]=entry
        end
      end
    end
  end
  for _,entries in pairs(queue) do table.sort(entries,function(a,b) return a.delta>b.delta end) end
  self.UpgradeQueue=queue
  self.UpgradeQueueFlat=flat
  self.BagsItems=bags
  for key in pairs(self.ReportedUpgrades) do if not flat[key] then self.ReportedUpgrades[key]=nil end end
  self:RefreshBags()
  ZGV:Fire("ZGV_UPGRADES_SCANNED",queue,flat)
  return self:GetUpgradeList()
end

function Upgrades:GetUpgradeList(limit)
  local result={}
  for _,entries in pairs(self.UpgradeQueue or {}) do
    for _,entry in ipairs(entries) do result[#result+1]=entry end
  end
  table.sort(result,function(a,b) return a.delta>b.delta end)
  if limit and #result>limit then
    local trimmed={}
    for index=1,limit do trimmed[index]=result[index] end
    return trimmed
  end
  return result
end

function Upgrades:EquipFromBags(entry)
  if not entry or not entry.item or not entry.slot then return false,"invalid_upgrade" end
  if InCombatLockdown and InCombatLockdown() then return false,"combat_lockdown" end
  local item=entry.item
  local picked=ZGV.Compat.Container:Pickup(item.bag,item.slot)
  if not picked.ok then return false,picked.code end
  if type(EquipCursorItem)~="function" then if ClearCursor then ClearCursor() end return false,"api_unavailable" end
  local ok,errorMessage=pcall(EquipCursorItem,entry.slot)
  if ClearCursor then ClearCursor() end
  if not ok then return false,errorMessage end
  self.ScoredEquippedItems=false
  if ZGV.Compat and ZGV.Compat.Timer then ZGV.Compat.Timer:After(.25,function() Upgrades:ScanBagsForUpgrades(true) end) end
  return true,"equipped"
end

function Upgrades:RefreshBags()
  -- 3.3.5a has no combined-bag data provider.  Refresh visible legacy bag
  -- windows where possible, and expose a callback for the modern viewer.
  for index=1,(NUM_CONTAINER_FRAMES or 13) do
    local frame=_G["ContainerFrame"..index]
    if frame and frame:IsShown() and type(ContainerFrame_Update)=="function" then ContainerFrame_Update(frame) end
  end
  ZGV:Fire("ZGV_BAG_UPGRADE_VISUALS",self.UpgradeQueueFlat)
end

function Upgrades:GetGearReport(newItem)
  local lines={"WotLK gear report",("class: %s  talent tree: %d  level: %d"):format(tostring(ItemScore.playerclass),tonumber(ItemScore.playerspec) or 1,tonumber(ItemScore.playerlevel) or 0)}
  for _,name in ipairs(inventorySlots) do
    local slot=GetInventorySlotInfo and GetInventorySlotInfo(name)
    local entry=slot and self.EquippedItems[slot]
    if entry and entry.itemlink then lines[#lines+1]=("%s: %.1f %s"):format(name,entry.score or 0,entry.itemlink) end
  end
  if newItem then
    local details=ItemScore:GetItemDetails(newItem)
    local score=details and ItemScore:GetItemScore(details) or -1
    lines[#lines+1]=("candidate: %.1f %s"):format(score or -1,tostring(newItem))
  end
  return table.concat(lines,"\n")
end

function Upgrades:OnInventoryUpdated()
  self.ScoredEquippedItems=false
  if ZGV.Compat and ZGV.Compat.Timer then
    ZGV.Compat.Timer:After(.20,function() Upgrades:ScanBagsForUpgrades(true) end)
  else
    self:ScanBagsForUpgrades(true)
  end
end

function Upgrades:OnStartup()
  self:HookUpgradeTooltips()
  self:ScoreEquippedItems()
  self:ScanBagsForUpgrades()
end

ZGV:RegisterCallback("ZGV_INVENTORY_UPDATED",Upgrades,"OnInventoryUpdated")
ZGV:RegisterEvent("UNIT_INVENTORY_CHANGED",function(_,unit) if unit=="player" then Upgrades:OnInventoryUpdated() end end)
