-- Consumes the original guide-side ItemScore.Items dungeon-drop tables.
-- The data is loaded by content addons after the core TOC, so parsing occurs
-- at startup and can safely be repeated when an optional content addon loads.
local ZGV=ZygorGuidesViewer
local ItemScore=ZGV and ZGV.ItemScore
if not ItemScore then return end

local GearFinder=ZGV:RegisterModule("GearFinder",{ResultsCache={},items_in_guides={},itemSources={}})
ItemScore.GearFinder=GearFinder

function GearFinder:IsEnabled()
  local gear=ZGV.db and ZGV.db.profile and ZGV.db.profile.gear
  return not gear or gear.enabled~=false
end

function GearFinder:UpdateSystemTab()
  local button=self.PaperDollButton
  if button then
    if self:IsEnabled() then button:Show() else button:Hide() end
  end
  if not self:IsEnabled() and self.frame and self.frame:IsShown() then self.frame:Hide() end
  return self:IsEnabled()
end

function GearFinder:AttachFrame()
  local parent=_G.PaperDollFrame or _G.CharacterFrame
  if not parent or type(CreateFrame)~="function" then return false end
  if self.PaperDollButton then
    if self.PaperDollButton:GetParent()~=parent then self.PaperDollButton:SetParent(parent) end
    self:UpdateSystemTab()
    return true
  end
  -- Match the reference integration: this is a compact, skinned control in
  -- the paper-doll's upper-right utility position, not a stock text button in
  -- the character panel's footer (where it overlaps other client controls).
  local button=CreateFrame("Button","ZygorGearFinderCharacterButton",parent)
  button:SetWidth(32)
  button:SetHeight(32)
  button:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-40,-40)
  button:SetFrameStrata("HIGH")
  if button.SetFrameLevel then button:SetFrameLevel(((parent.GetFrameLevel and parent:GetFrameLevel()) or 1)+10) end
  local skin=ZGV.SKINDIR or "Interface\\AddOns\\ZygorGuidesViewer\\Skins\\"
  button:SetNormalTexture(skin.."popout-button-2")
  button:SetPushedTexture(skin.."popout-button-2-down")
  button:SetHighlightTexture(skin.."popout-button-2-hi")
  local normal=button.GetNormalTexture and button:GetNormalTexture()
  local pushed=button.GetPushedTexture and button:GetPushedTexture()
  local highlight=button.GetHighlightTexture and button:GetHighlightTexture()
  if normal then normal:SetTexCoord(0,1,0,.5) end
  if pushed then pushed:SetTexCoord(0,1,0,.5) end
  if highlight then highlight:SetTexCoord(0,1,0,.5) end
  button:SetScript("OnClick",function() GearFinder:ShowFinder() end)
  button:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_TOP")
    GameTooltip:SetText("Find upgrades",1,.82,0)
    GameTooltip:AddLine("Show level-appropriate dungeon drops that improve your equipped gear.",1,1,1,true)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave",function() GameTooltip:Hide() end)
  self.PaperDollButton=button
  if parent.HookScript then
    parent:HookScript("OnShow",function() GearFinder:UpdateSystemTab() end)
  end
  self:UpdateSystemTab()
  return true
end

local function currentFaction()
  return UnitFactionGroup and UnitFactionGroup("player") or "ALL"
end

local expansionBands={
  [0]={minLevel=10,maxLevel=60},
  [1]={minLevel=58,maxLevel=70},
  [2]={minLevel=68,maxLevel=80},
}

local function expansionForGuide(guideName)
  if tostring(guideName):find("^Wrath of the Lich King") then return 2 end
  if tostring(guideName):find("^Burning Crusade") then return 1 end
  return 0
end

local function normalizedDungeonName(value)
  value=tostring(value or ""):gsub("^.-\\",""):gsub("%s*%(Heroic%)$",""):lower()
  value=value:gsub("^the%s+",""):gsub("[^%w]+","")
  return value
end

local function dungeonMetadata(guideName,dungeon)
  local service=ZGV.Dungeons
  if not service then return nil end
  if tonumber(dungeon.dungeon) then
    local exact=service:Get(tonumber(dungeon.dungeon))
    if exact then return exact end
  end
  local wanted=normalizedDungeonName(guideName)
  local heroic=dungeon.heroic and true or false
  for _,candidate in pairs(service.byID or {}) do
    if candidate.heroic==heroic and normalizedDungeonName(candidate.name)==wanted then return candidate end
  end
end

function GearFinder:IsSourceAvailable(source)
  local level=tonumber(ItemScore.playerlevel) or (UnitLevel and UnitLevel("player")) or 1
  local serverExpansion=ZGV.Dungeons and tonumber(ZGV.Dungeons.CurrentExpansion) or 2
  local expansion=tonumber(source.expansionLevel) or 0
  if expansion>serverExpansion then return false,"future_expansion" end
  local minimum=tonumber(source.minLevel)
  local maximum=tonumber(source.maxLevel)
  local band=expansionBands[expansion]
  if not minimum and band then minimum=band.minLevel end
  if not maximum and band then maximum=band.maxLevel end
  if minimum and level<minimum then return false,"below_dungeon_level" end
  if maximum and maximum>0 and level>maximum then return false,"above_dungeon_level" end
  return true
end

local function addItem(self,itemID,source)
  itemID=tonumber(itemID)
  if not itemID then return end
  self.itemSources[itemID]=self.itemSources[itemID] or {}
  self.itemSources[itemID][#self.itemSources[itemID]+1]=source
  self.items_in_guides[itemID]=self.items_in_guides[itemID] or source
end

function GearFinder:AddItem(itemID,item)
  addItem(self,itemID,item)
end

function GearFinder:ParseItemDatabase()
  self.items_in_guides={}
  self.itemSources={}
  local faction=currentFaction()
  self.availableDungeonCount=0
  self.filteredDungeonCount=0
  for guideName,dungeon in pairs(ItemScore.Items or {}) do
    if type(dungeon)=="table" then
      local metadata=dungeonMetadata(guideName,dungeon)
      local baseSource={
        guide=guideName,dungeon=metadata and metadata.id or tonumber(dungeon.dungeon),dungeonmap=dungeon.dungeonmap,
        heroic=dungeon.heroic and true or false,normal=dungeon.normal and true or false,
        expansionLevel=metadata and metadata.expansionLevel or expansionForGuide(guideName),
        minLevel=metadata and metadata.minLevel,maxLevel=metadata and metadata.maxLevel,
      }
      if self:IsSourceAvailable(baseSource) then
        self.availableDungeonCount=self.availableDungeonCount+1
        for _,boss in ipairs(dungeon) do
          if type(boss)=="table" then
            -- The newer Classic/TBC tables use ALL/Horde/Alliance lists;
            -- the original 3.3.5 WotLK tables keep their shared drops directly
            -- in the numeric portion of each boss table.
            local drops=boss[faction] or boss.ALL or boss.BOTH or boss
            if type(drops)=="table" then
              for _,itemID in ipairs(drops) do
                addItem(self,itemID,{
                  guide=baseSource.guide,dungeon=baseSource.dungeon,dungeonmap=baseSource.dungeonmap,
                  boss=boss.boss,bossname=boss.name,heroic=baseSource.heroic,normal=baseSource.normal,
                  expansionLevel=baseSource.expansionLevel,minLevel=baseSource.minLevel,maxLevel=baseSource.maxLevel,
                })
              end
            end
          end
        end
      else
        self.filteredDungeonCount=self.filteredDungeonCount+1
      end
    end
  end
  self.ResultsCache={}
  self.cacheOrder={}
  for itemID in pairs(self.itemSources) do self.cacheOrder[#self.cacheOrder+1]=itemID end
  table.sort(self.cacheOrder)
  self.cacheCursor=1
  ZGV:Fire("ZGV_GEAR_DATABASE_READY",self.items_in_guides)
  return self.items_in_guides
end

function GearFinder:GetItemScore(itemID,invslot,link,verbose)
  local source=self.items_in_guides[tonumber(itemID)]
  if not source then return -1,"not_in_guides","item is not present in loaded gear guides" end
  return ItemScore:GetItemScore(itemID,invslot,link,nil,verbose)
end

function GearFinder:GetBestItemsForSlot(invslot,count,verbose,itemIDOrder)
  count=tonumber(count) or 10
  local key=table.concat({tostring(ItemScore.playerclass),tostring(ItemScore.playerspec),tostring(ItemScore.playerlevel),tostring(invslot)},":")
  if not verbose and not itemIDOrder and self.ResultsCache[key] then return self.ResultsCache[key] end
  local result={}
  for itemID,source in pairs(self.items_in_guides) do
    local score,code,reason=self:GetItemScore(itemID,invslot,nil,verbose)
    if score and score>0 then
      local info=ZGV.Compat.Item:GetInfo(itemID)
      result[#result+1]={item=itemID,itemID=itemID,score=score,source=source,code=code,reason=reason,name=info.name,link=info.itemLink,texture=info.texture}
    end
  end
  if itemIDOrder then table.sort(result,function(a,b) return a.itemID<b.itemID end) else table.sort(result,function(a,b) return a.score>b.score end) end
  while #result>count do table.remove(result) end
  if not verbose and not itemIDOrder then self.ResultsCache[key]=result end
  return result
end

function GearFinder:GetResultsForSlot(invslot,nocache)
  if nocache then self.ResultsCache={} end
  local itemOne,itemTwo=ItemScore:GetItemInSlot(invslot)
  local scoreOne=itemOne and ItemScore:GetItemScore(itemOne,invslot) or 0
  local scoreTwo=itemTwo and ItemScore:GetItemScore(itemTwo,invslot) or 0
  return {owned={itemOne,itemTwo},ownedScore=math.max(tonumber(scoreOne) or 0,tonumber(scoreTwo) or 0),items=self:GetBestItemsForSlot(invslot,10)}
end

function GearFinder:ScoreDungeonItems()
  local upgrades=ItemScore.Upgrades
  if not upgrades then return {} end
  upgrades:ScoreEquippedItems()
  local results={}
  local missing=false
  for itemID,sources in pairs(self.itemSources) do
    local details=ItemScore:GetItemDetails(itemID)
    if details then
      local isUpgrade,slot,change,score=upgrades:IsUpgrade(details)
      if isUpgrade then
        results[#results+1]={itemID=itemID,itemLink=details.itemlink,name=details.name,texture=details.texture,slot=slot,delta=change,score=score,sources=sources}
      end
    else missing=true end
  end
  table.sort(results,function(a,b) return a.delta>b.delta end)
  self.UpgradeQueue=results
  if missing then self:PrepareCache(18) end
  ZGV:Fire("ZGV_GEAR_FINDER_RESULTS",results)
  return results
end

function GearFinder:PrepareCache(limit)
  if self.cachePending or not self.cacheOrder then return end
  limit=tonumber(limit) or 12
  local queued=0
  while self.cacheCursor<=#self.cacheOrder and queued<limit do
    local itemID=self.cacheOrder[self.cacheCursor]
    self.cacheCursor=self.cacheCursor+1
    if not ZGV.Compat.Item:GetInfo(itemID).ready then
      ZGV.Compat.Item:RequestInfo(itemID,function() GearFinder:QueueRender() end)
      queued=queued+1
    end
  end
  if queued>0 or self.cacheCursor<=#self.cacheOrder then
    self.cachePending=true
    ZGV.Compat.Timer:After(.35,function()
      GearFinder.cachePending=false
      GearFinder:ScoreDungeonItems()
      if GearFinder.frame and GearFinder.frame:IsShown() then GearFinder:Render() end
    end)
  end
end

function GearFinder:QueueRender()
  if self.renderPending then return end
  self.renderPending=true
  ZGV.Compat.Timer:After(.20,function()
    GearFinder.renderPending=false
    GearFinder:ScoreDungeonItems()
    if GearFinder.frame and GearFinder.frame:IsShown() then GearFinder:Render() end
  end)
end

function GearFinder:CleanResultsCache() self.ResultsCache={} end

local function rowText(parent)
  local text=parent:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
  text:SetPoint("LEFT",parent,"LEFT",31,0) text:SetPoint("RIGHT",parent,"RIGHT",-5,0)
  text:SetJustifyH("LEFT") return text
end

function GearFinder:CreateFrame()
  if self.frame then return self.frame end
  local frame=CreateFrame("Frame","ZygorGearFinder",UIParent)
  frame:SetWidth(430) frame:SetHeight(330) frame:SetPoint("CENTER",UIParent,"CENTER",250,20)
  frame:SetFrameStrata("DIALOG") frame:SetToplevel(true) frame:SetMovable(true) frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton") frame:SetScript("OnDragStart",function(self) self:StartMoving() end) frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
  frame:SetBackdrop({bgFile=ZGV.SKINDIR.."white",edgeFile=ZGV.SKINDIR.."white",edgeSize=1}) frame:SetBackdropColor(.07,.07,.07,.97) frame:SetBackdropBorderColor(.24,.24,.24,1)
  local title=frame:CreateFontString(nil,"ARTWORK","GameFontNormal")
  title:SetPoint("TOPLEFT",frame,"TOPLEFT",12,-12) title:SetText("Dungeon Gear Finder") frame.title=title
  local status=frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
  status:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-5) status:SetWidth(340) status:SetJustifyH("LEFT") frame.status=status
  local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton") close:SetPoint("TOPRIGHT",frame,"TOPRIGHT",2,2) close:SetScript("OnClick",function() frame:Hide() end)
  local refresh=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate") refresh:SetWidth(75) refresh:SetHeight(21) refresh:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-31,-8) refresh:SetText("Refresh") refresh:SetScript("OnClick",function() GearFinder:CleanResultsCache() GearFinder:Render() end)
  frame.rows={}
  for index=1,8 do
    local row=CreateFrame("Button",nil,frame)
    row:SetHeight(29) row:SetPoint("TOPLEFT",frame,"TOPLEFT",10,-54-(index-1)*31) row:SetPoint("TOPRIGHT",frame,"TOPRIGHT",-10,-54-(index-1)*31)
    row:SetBackdrop({bgFile=ZGV.SKINDIR.."white"})
    local icon=row:CreateTexture(nil,"ARTWORK") icon:SetPoint("LEFT",row,"LEFT",4,0) icon:SetWidth(23) icon:SetHeight(23) row.icon=icon
    row.label=rowText(row)
    row:SetScript("OnEnter",function(self)
      if self.result and self.result.itemLink then GameTooltip:SetOwner(self,"ANCHOR_RIGHT") GameTooltip:SetHyperlink(self.result.itemLink) GameTooltip:AddLine(self.result.sources[1] and self.result.sources[1].guide or "Dungeon drop",.7,.8,1) GameTooltip:Show() end
    end)
    row:SetScript("OnLeave",function() GameTooltip:Hide() end)
    row:SetScript("OnClick",function(self)
      if self.result and self.result.sources[1] then ZGV:Fire("ZGV_GEAR_FINDER_SOURCE",self.result.sources[1],self.result) end
    end)
    row:Hide() frame.rows[index]=row
  end
  frame:Hide() self.frame=frame
  return frame
end

function GearFinder:Render()
  local frame=self:CreateFrame()
  local results=self:ScoreDungeonItems()
  local scope=("%d level-appropriate dungeons; %d filtered"):format(self.availableDungeonCount or 0,self.filteredDungeonCount or 0)
  frame.status:SetText(#results>0 and ("Best cached upgrades from "..scope..":") or ("Caching drops from "..scope.."."))
  for index,row in ipairs(frame.rows) do
    local result=results[index]
    row.result=result
    if result then
      row.icon:SetTexture(result.texture)
      local source=result.sources[1] or {}
      row.label:SetText(('%s  |cff66ff66+%.1f|r  |cffaaaaaa%s|r'):format(result.name or result.itemLink,result.delta,source.guide or "Dungeon drop"))
      row:SetBackdropColor(.11,.11,.11,index%2==0 and .7 or .45) row:Show()
    else row:Hide() end
  end
end

function GearFinder:Show()
  local frame=self:CreateFrame()
  frame:Show()
  self:Render()
end

function GearFinder:ShowFinder()
  local frame=self:CreateFrame()
  if frame:IsShown() then
    frame:Hide()
  else
    self:Show()
  end
  self.MainFrame=frame
  return frame
end

function GearFinder:OnStartup()
  self:ParseItemDatabase()
  self:AttachFrame()
end

function GearFinder:OnEvent(event)
  if event=="PLAYER_LOGIN" then
    self:AttachFrame()
  elseif event=="PLAYER_LEVEL_UP" then
    self:ParseItemDatabase()
    self:ScoreDungeonItems()
    if self.frame and self.frame:IsShown() then self:Render() end
  end
end

ZGV:RegisterCallback("ZGV_ITEM_SCORE_RULES_CHANGED",GearFinder,"CleanResultsCache")
ZGV:RegisterEvent("PLAYER_LEVEL_UP",GearFinder,"OnEvent")
ZGV:RegisterEvent("PLAYER_LOGIN",GearFinder,"OnEvent")
