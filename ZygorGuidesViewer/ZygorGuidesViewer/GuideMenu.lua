-- Behavioural half of the Classic Guide Menu, layered over ModernGuideMenu's
-- 825x630 Classic Starlight frame.  Keeping one frame avoids two competing
-- menus while preserving every legacy entry point used by the viewer/skins.
local _, namespace = ...
local ZGV = (type(namespace)=="table" and (namespace.ZygorGuidesViewer or namespace.ZGV)) or _G.ZygorGuidesViewer or ZygorGuidesViewer
local Menu=ZGV and ZGV.GuideMenu
if type(Menu)~="table" then return end

local STATUS_COLORS={
  SUGGESTED={hex="#ffffffff"},VALID={hex="#ffffffff"},COMPLETE={hex="#808080ff"},OUTLEVELED={hex="#aaaaaaff"},INVALID={hex="#e60000ff"},
}
for _,entry in pairs(STATUS_COLORS) do
  entry.r,entry.g,entry.b,entry.a=ZGV.F.HTMLColor(entry.hex)
  entry.code="|c"..entry.hex:sub(8,9)..entry.hex:sub(2,7)
end
Menu.STATUS_COLORS=STATUS_COLORS
Menu.Guides=Menu.Guides or {}
Menu.searchHistory=Menu.searchHistory or {}

local sectionFor={Home="HOME",Featured="FEATURED",Current="CURRENT",Recent="RECENT",Suggested="SUGGESTED",Favourites="FAVOURITES",Options="SETTINGS",Settings="SETTINGS"}
local function titlePath(guide) return guide and (guide.menuPath or guide.path or guide.guidepath or "") or "" end
local function normalizePath(path)
  path=tostring(path or "")
  return sectionFor[path] or (path=="QuestSearch" and "SEARCH") or (path~="" and "CATEGORY:"..path) or "HOME"
end

function Menu:CreateRequestFrame()
  -- The old request panel stored an offline report; retain that useful action
  -- without injecting another frame into the three-pane menu.
  self.Request=self.Request or {shown=false}
  return self.Request
end
function Menu:HideRequestFrame() if self.Request then self.Request.shown=false end end
function Menu:FormatDumpForUpload(content,headers)
  local text="%%BUG_REPORT_START%%\n"
  text=text.."bug_report_version="..tostring(ZGV.version).."\n"
  text=text.."bug_report_time="..tostring(time()).."\n"
  text=text.."bug_report_guiderequest="..tostring(content or "").."\n"
  if headers then text=text..tostring(headers) end
  return text.."\n---->>\n\n<<----\n%%BUG_REPORT_END%%"
end
function Menu:SaveDump(text,timestamp,headers)
  ZGV.db.global.bugreports=ZGV.db.global.bugreports or {}
  ZGV.db.global.bugreports[timestamp or time()]=self:FormatDumpForUpload(text,headers)
end

function Menu:ShowHome() self.GuideCategory=nil; self:Show("HOME") end
function Menu:AddSearchHistory(query,count)
  query=tostring(query or ""); if query=="" then return end
  local history=ZGV.db.profile.searchhistory or {}; ZGV.db.profile.searchhistory=history
  for index=#history,1,-1 do if history[index].text==query or history[index]==query then table.remove(history,index) end end
  table.insert(history,1,{text=query,count=count or 0,time=time()})
  while #history>50 do table.remove(history) end
  self.searchHistory=history
end
function Menu:SearchHistory_Commit() return self:Search() end

function Menu:Search()
  self:Create()
  local query=self.search and self.search:GetText() or ""
  local questID=query:match("^quest:(%d+)$")
  if questID then return self:SearchQuest(tonumber(questID)) end
  self.section="ALL"; self.resultOffset=0; self.search_lastquery=query; self:AddSearchHistory(query,0); self:Refresh()
  local count=#(self:GetResults() or {}); self:AddSearchHistory(query,count)
  if count==0 and query~="" then self:CreateRequestFrame().shown=true else self:HideRequestFrame() end
  return count
end

function Menu:SearchQuest(questID)
  self:Create(); self.section="QUEST:"..tostring(questID); self.resultOffset=0
  self.GetResultsForLegacyQuest=self.GetResultsForLegacyQuest or self.GetResults
  self.GetResults=function(menu)
    if menu.section:match("^QUEST:") then
      local result,id={},tonumber(menu.section:match("^QUEST:(%d+)"))
      for _,guide in ipairs(ZGV.Catalog.sorted or {}) do
        if tostring(guide.raw or ""):find("|q%s*"..tostring(id).."[^%d]",1) or tostring(guide.raw or ""):find("|q%s*"..tostring(id).."$",1) then result[#result+1]=guide end
      end
      return result
    end
    return menu:GetResultsForLegacyQuest()
  end
  self:Refresh(); return self:GetResults()
end

function Menu:ShowGuides(path,iscurrent)
  self.GuideCategory=path
  self:Show(normalizePath(path))
end
function Menu:ShowParent()
  local path=tostring(self.GuideCategory or "")
  local parent=path:match("^(.*)\\[^\\]+$")
  return self:ShowGuides(parent or "")
end
function Menu:OpenGuide(guide) return self:ActivateGuide(guide) end
function Menu:ShowCurrent() return self:Show("CURRENT") end
function Menu:ShowRecent() return self:Show("RECENT") end
function Menu:FindSuggestedGuides()
  local result={}; local suggested=ZGV.Runtime:ChooseSuggestedGuide()
  if suggested then result[#result+1]=suggested end
  return result
end
function Menu:ShowSuggested() return self:Show("SUGGESTED") end
function Menu:ShowFavourites() return self:Show("FAVOURITES") end
function Menu:Update() return self:Refresh() end
function Menu:SetFocusedRow(row) self.CurrentRow=row; if row and row.guide then self:Select(row.guide) end end
function Menu:ActivateGuide(guide)
  if type(guide)=="table" and ZGV.Runtime:SelectGuide(guide) then
    if self.frame then self.frame:Hide() end
    if ZGV.UI then ZGV.UI:ShowViewer() end
    return true
  end
  return false
end
function Menu:ShowRowMouseOver(row) if row and row.guide then self:Select(row.guide) end end
function Menu:HideRowMouseOver() end
function Menu:ShowFolderDetails(group)
  self.GuideCategory=type(group)=="table" and (group.fullpath or group.name) or group
  return self:ShowGuides(self.GuideCategory)
end
function Menu:ShowGuideDetails(guide) self:Create(); self:Select(guide); return guide end
function Menu:ShowQuestDetails(quest) return self:SearchQuest(quest and (quest.questid or quest.id) or 0) end
function Menu:AnyGuideValid(group)
  local prefix=type(group)=="table" and (group.fullpath or group.name) or tostring(group or "")
  for _,guide in ipairs(ZGV.Catalog.sorted or {}) do
    if (guide.menuTitle or guide.title):find(prefix,1,true)==1 and ZGV.Conditions:EvaluateHeader(guide,"condition_visible",true) then return true end
  end
  return false
end
function Menu:ShowMissingPopup(row)
  self:CreateRequestFrame().shown=true
  if ZGV.Print then ZGV:Print("This guide is not installed. Search request saved for upload.") end
end

function Menu:Open(path,iscurrent,...)
  self.CurrentPath=path or "Home"
  if path=="QuestSearch" then return self:SearchQuest(...) end
  return self:Show(normalizePath(path))
end
