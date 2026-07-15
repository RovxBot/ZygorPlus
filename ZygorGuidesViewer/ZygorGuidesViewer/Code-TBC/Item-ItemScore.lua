-- Legacy slot/build helpers delegated to the WotLK ItemScore evaluator.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local ItemScore=ZGV and ZGV.ItemScore
if type(ItemScore)~="table" then return end

if type(ItemScore.SetDualWield)~="function" then
  function ItemScore:SetDualWield()
    if type(self.SetFilters)=="function" then self:SetFilters(self.playerclass,self.playerspec,self.playerlevel) end
    self.playerDualWield=self.playerdualwield and true or false
    self.playerDualTwohanders=self.playerdual2h and true or false
    return self.playerDualWield,self.playerDualTwohanders
  end
end

if type(ItemScore.GetValidSlots)~="function" then
  function ItemScore:GetValidSlots(item)
    if type(item)~="table" then return nil end
    local equipLocation=item.type or item.equipslot
    local candidates=type(self.GetSlotCandidates)=="function" and self:GetSlotCandidates(equipLocation) or {}
    local first,second=candidates and candidates[1],candidates and candidates[2]
    first=first or (self.TypeToSlot and self.TypeToSlot[equipLocation])
    if equipLocation=="INVTYPE_WEAPON" and not self.playerdualwield then second=nil end
    return first,second,equipLocation=="INVTYPE_2HWEAPON"
  end
end

if type(ItemScore.SetData)~="function" then
  function ItemScore:SetData()
    self.Builds,self.Defaults={},{}
    for class,specs in pairs(self.rules or {}) do
      self.Builds[class],self.Defaults[class]={},{}
      for index,data in ipairs(specs) do
        local role=tostring(data.role or ("spec "..index))
        self.Builds[class][index]=role:sub(1,1):upper()..role:sub(2)
        self.Defaults[class][index]={}
        for stat,weight in pairs(data.weights or data.stats or {}) do
          self.Defaults[class][index][#self.Defaults[class][index]+1]={name=stat,weight=weight}
        end
        table.sort(self.Defaults[class][index],function(left,right) return left.name<right.name end)
      end
    end
    return self.Builds,self.Defaults
  end
end

ItemScore:SetData()
ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.ItemScore=ItemScore
