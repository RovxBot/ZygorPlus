-- Quest-reward selection and temporary quest-equipment protection.
local ZGV=ZygorGuidesViewer
local ItemScore=ZGV and ZGV.ItemScore
if not ItemScore then return end

local QuestItem=ZGV:RegisterModule("QuestItem",{hardProtected={[20408]=1451,[20406]=1451,[20407]=1451}})
ItemScore.QuestItem=QuestItem

local function cache()
  ZGV.db.profile.questitemcache=ZGV.db.profile.questitemcache or {}
  return ZGV.db.profile.questitemcache
end

local function rewardButton(index)
  return _G["QuestInfoRewardsFrameQuestInfoItem"..index] or _G["QuestInfoItem"..index]
end

function QuestItem:HideQuestRewardGlow()
  if self.GlowFrame then self.GlowFrame:Hide() self.GlowFrame:ClearAllPoints() end
end

function QuestItem:ShowQuestRewardGlow(index,reason)
  local button=index and rewardButton(index)
  if not button then return false end
  if not self.GlowFrame then
    local frame=CreateFrame("Frame",nil,button)
    frame:SetBackdrop({bgFile="",edgeFile=ZGV.SKINDIR.."glowborder",edgeSize=5})
    frame:SetWidth(108) frame:SetHeight(45) frame:SetFrameStrata("HIGH")
    local icon=frame:CreateTexture(nil,"OVERLAY")
    icon:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-3,-3) icon:SetWidth(18) icon:SetHeight(18)
    icon:SetTexture(reason=="money" and "Interface\\MONEYFRAME\\UI-GoldIcon" or ZGV.SKINDIR.."item-upgrade")
    frame.icon=icon self.GlowFrame=frame
  end
  self.GlowFrame:ClearAllPoints()
  self.GlowFrame:SetPoint("CENTER",button,"CENTER",0,0)
  self.GlowFrame.icon:SetTexture(reason=="money" and "Interface\\MONEYFRAME\\UI-GoldIcon" or ZGV.SKINDIR.."item-upgrade")
  self.GlowFrame:Show()
  return true
end

function QuestItem:IsQuestItemsReady()
  local count=GetNumQuestChoices and GetNumQuestChoices() or 0
  if count<1 then return false end
  for index=1,count do
    local link=GetQuestItemLink and GetQuestItemLink("choice",index)
    if not (link and ItemScore:GetItemDetails(link)) then return false end
  end
  return true
end

function QuestItem:GetQuestRewardIndex()
  local count=GetNumQuestChoices and GetNumQuestChoices() or 0
  if count<1 then return nil,"no rewards" end
  if count==1 then return 1,"only choice" end
  if not self:IsQuestItemsReady() then return -5,"items not ready" end
  local bestUpgrade,bestChange,bestMoney,bestMoneyValue
  for index=1,count do
    local link=GetQuestItemLink("choice",index)
    local details=ItemScore:GetItemDetails(link)
    local isUpgrade,_,change=ItemScore.Upgrades:IsUpgrade(details)
    if isUpgrade and change>(bestChange or 0) then bestUpgrade,bestChange=index,change end
    local _,_,quantity=GetQuestItemInfo and GetQuestItemInfo("choice",index)
    local value=(details.vendorprice or 0)*(tonumber(quantity) or 1)
    if value>(bestMoneyValue or 0) then bestMoney,bestMoneyValue=index,value end
  end
  if bestUpgrade then return bestUpgrade,"upgrade" end
  if bestMoney then return bestMoney,"money" end
  return nil,"no scored reward"
end

function QuestItem:UpdateQuestRewardGlow()
  local index,reason=self:GetQuestRewardIndex()
  if index and index>0 then self:ShowQuestRewardGlow(index,reason) else self:HideQuestRewardGlow() end
  return index,reason
end

function QuestItem:TestCurStepForQuestItem(step)
  local runtime=ZGV.Runtime
  -- Runtime.currentStep and the second ZGV_STEP_CHANGED argument are numeric
  -- indices.  The original Classic implementation used a current-step
  -- object, so resolve either representation before inspecting goals.
  if type(step)=="number" then
    step=runtime and runtime.currentGuide and runtime.currentGuide.steps and runtime.currentGuide.steps[step]
  elseif type(step)~="table" then
    local index=runtime and runtime.currentStep
    step=runtime and runtime.currentGuide and runtime.currentGuide.steps and runtime.currentGuide.steps[index]
  end
  if type(step)~="table" then return nil end
  local questID,itemID
  for _,goal in ipairs(step.goals or {}) do
    if goal.questID then questID=goal.questID end
    if (goal.action=="equip" or goal.action=="equipped") and goal.itemID then itemID=goal.itemID end
    if (goal.action=="unequip" or goal.action=="unequipped") and questID then cache()[questID]=nil end
    if questID and itemID then cache()[questID]=itemID return questID,itemID end
  end
  return questID,questID and cache()[questID]
end

function QuestItem:IsProtectedQuestItem(item)
  local itemID=type(item)=="number" and item or tonumber(tostring(item):match("item:(%d+)"))
  if not itemID then return false end
  local zone=self.hardProtected[itemID]
  if zone and type(GetCurrentMapAreaID)=="function" and GetCurrentMapAreaID()==zone then return true,"hard quest item" end
  local questID,required=self:TestCurStepForQuestItem()
  if questID and tonumber(required)==itemID and (not GetItemCount or GetItemCount(itemID)>0) then return true,"current guide quest item" end
  return false
end

local popupName="ZYGOR_WOTLK_EQUIP_QUEST_ITEM"
if StaticPopupDialogs and not StaticPopupDialogs[popupName] then
  StaticPopupDialogs[popupName]={
    text="Equip %s for the current guide step?",button1=ACCEPT,button2=CANCEL,timeout=0,whileDead=true,hideOnEscape=true,
    OnAccept=function(dialog,data)
      data=data or (dialog and dialog.data)
      if data and data.itemID then ZGV.Compat.Item:Equip(data.itemID) end
    end,
  }
end

function QuestItem:FoundQuestItemForCurStep(questID,itemID)
  itemID=tonumber(itemID)
  if not itemID or (IsEquippedItem and IsEquippedItem(itemID)) or (GetItemCount and GetItemCount(itemID)<1) then return false end
  local details=ItemScore:GetItemDetails(itemID)
  if not details then return false end
  cache()[questID]=itemID
  local gear=ZGV.db.profile.gear or {}
  if gear.autoEquip and not (InCombatLockdown and InCombatLockdown()) then
    ZGV.Compat.Item:Equip(itemID)
    return true,"equipped"
  end
  if StaticPopup_Show then
    local data={questID=questID,itemID=itemID}
    local dialog=StaticPopup_Show(popupName,details.name,nil,data)
    if dialog then dialog.data=data end
  else
    ZGV:Fire("ZGV_NOTIFICATION",{title="Quest equipment",message="Equip "..tostring(details.name).." for the current guide step.",kind="reward",duration=6})
  end
  return true,"prompted"
end

function QuestItem:ReEquipNormalItem()
  local itemID=ZGV.db.profile.questitemreplaced
  if itemID and GetItemCount and GetItemCount(itemID)>0 and not (InCombatLockdown and InCombatLockdown()) then return ZGV.Compat.Item:Equip(itemID) end
  return false
end

function QuestItem:OnStepChanged(guide,stepIndex)
  local step=type(guide)=="table" and guide.steps and guide.steps[tonumber(stepIndex)] or stepIndex
  local questID,itemID=self:TestCurStepForQuestItem(step)
  if questID and itemID then self:FoundQuestItemForCurStep(questID,itemID) end
end

function QuestItem:QueueRewardUpdate()
  if self.rewardPending then return end
  self.rewardPending=true
  ZGV.Compat.Timer:After(.20,function() QuestItem.rewardPending=false QuestItem:UpdateQuestRewardGlow() end)
end

function QuestItem:OnStartup()
  cache()
  self:QueueRewardUpdate()
end

ZGV:RegisterCallback("ZGV_STEP_CHANGED",QuestItem,"OnStepChanged")
for _,event in ipairs({"QUEST_DETAIL","QUEST_COMPLETE","QUEST_PROGRESS","QUEST_FINISHED"}) do
  ZGV:RegisterEvent(event,QuestItem,"QueueRewardUpdate")
end
