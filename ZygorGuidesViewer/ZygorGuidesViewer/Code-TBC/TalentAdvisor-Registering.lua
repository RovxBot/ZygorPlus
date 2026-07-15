-- Loaded compatibility facade for the Anniversary registration parser.
-- It lets old WotLK/Classic build packs register against ZygorTalentAdvisor
-- while retaining Talent.lua as the single parser/compiler implementation.
local _,ZGV=...
if not ZGV then ZGV=_G.ZygorGuidesViewer end
local Advisor=ZGV and ZGV.TalentAdvisor
local Talent=ZGV and ZGV.Talent
if not Advisor or not Talent then return end

Advisor.registeredBuilds=Advisor.registeredBuilds or {}

function Advisor:RegisterBuild(class,title,first,second,third)
  -- Integrated Anniversary builds used (class,title,statweights,build,glyphs),
  -- while the original Wrath addon used (class,title,build,glyphs).
  local statweights,build,glyphs
  if third~=nil or type(first)=="number" then statweights,build,glyphs=first,second,third
  else build,glyphs=first,second end
  local record=Talent:RegisterBuild(class,title,build,glyphs)
  record.statweights=statweights
  self.registeredBuilds[record.id]=record
  self.BuildsInstalled=true
  return record
end

function Advisor:PruneRegisteredBuilds()
  local _,class=UnitClass("player")
  local available={}
  for _,build in ipairs(Talent.builds) do
    if build.class==class or (class=="HUNTER" and build.petType) then available[build.id]=build end
  end
  self.registeredBuilds=available
  return available
end

function Advisor:ParseLines(text,multi)
  local result={}
  for sourceLine in (tostring(text or "").."\n"):gmatch("(.-)\r?\n") do
    local line=sourceLine:gsub("//.*$",""):gsub("%-%-.*$",""):gsub("^%s+",""):gsub("%s+$",""):gsub("/%d+",""):gsub("||","|")
    if line~="" then
      local count,name
      if multi then count,name=line:match("^(%d+)%s*[%*x]?%s+(.+)$") end
      count=tonumber(count) or 1
      name=name or line
      for _=1,count do result[#result+1]=name end
    end
  end
  return result
end

function Advisor:ParseTextTalents(text,pet)
  local raw=self:ParseLines(text,true)
  local class=pet and ("PET "..tostring(Talent:GetPetType() or "")) or select(2,UnitClass("player"))
  local temporary={id="compat-parser:"..tostring(class)..":"..tostring(text),class=pet and nil or class,petType=pet and class:match("^PET (.+)") or nil,title="Compatibility parser",raw=raw}
  local compiled,reason=Talent:Compile(temporary)
  return compiled and compiled.sequence or nil,reason or (compiled and compiled.issues[1])
end

-- External build addons commonly resolve this global once, then call
-- :RegisterBuild repeatedly.  Keep it pointing at the loaded facade except
-- while ZygorTalentAdvisor/Builds/BeginRegistration.lua installs its proxy.
_G.ZygorTalentAdvisor=Advisor
_G.ZTA=Advisor
