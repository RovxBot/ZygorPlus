-- Anniversary PointerMap helpers delegated to DungeonPreview and Navigation.
local _,ZGV=...
if type(ZGV)~="table" then ZGV=_G.ZygorGuidesViewer end
local PointerMap=ZGV and ZGV.PointerMap
if type(PointerMap)~="table" then return end
PointerMap.IconPool=PointerMap.IconPool or {}

if type(PointerMap.ParsePoints)~="function" then
  function PointerMap:ParsePoints() return self.Instances end
end
if type(PointerMap.GetIconFromPool)~="function" then
  function PointerMap:GetIconFromPool()
    local navigation=ZGV.Navigation
    if not navigation or type(navigation.EnsureMapPins)~="function" then return nil end
    local index=#(navigation.mapPins or {})+1
    navigation:EnsureMapPins(index)
    local icon=navigation.mapPins and navigation.mapPins[index]
    if icon then self.IconPool[#self.IconPool+1]=icon end
    return icon
  end
end
if type(PointerMap.RemoveAllIcons)~="function" then
  function PointerMap:RemoveAllIcons()
    if ZGV.Navigation and type(ZGV.Navigation.ClearExternalMarkers)=="function" then
      ZGV.Navigation:ClearExternalMarkers("Code-TBC.PointerMap")
    end
    for index=#self.IconPool,1,-1 do self.IconPool[index]=nil end
    return true
  end
end
if type(PointerMap.CacheTexture)~="function" then
  function PointerMap:CacheTexture(index,texture)
    self.TextureCache=self.TextureCache or {}
    self.TextureCache[index]=texture
    return texture
  end
end
if type(PointerMap.UpdateDevSettings)~="function" then
  function PointerMap:UpdateDevSettings() return self:UpdateSettings() end
end
if type(PointerMap.ShowLine)~="function" then
  function PointerMap:ShowLine(x1,y1,x2,y2)
    local navigation=ZGV.Navigation
    local map=ZGV.Compat and ZGV.Compat.Map and ZGV.Compat.Map:GetSelected()
    if not navigation or not map or type(navigation.UpdateMapLines)~="function" then return false,"map unavailable" end
    if type(navigation.CreateMapPin)=="function" then navigation:CreateMapPin() end
    navigation:UpdateMapLines({
      {key=map.key,continent=map.continent,zone=map.zone,x=x1,y=y1},
      {key=map.key,continent=map.continent,zone=map.zone,x=x2,y=y2},
    })
    return true
  end
end
if type(PointerMap.EventHandler)~="function" then
  function PointerMap.EventHandler(_,event) return PointerMap:OnEvent(event) end
end

ZGV.CodeTBCCompat=ZGV.CodeTBCCompat or {}
ZGV.CodeTBCCompat.PointerMap=PointerMap
