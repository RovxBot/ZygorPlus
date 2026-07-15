local repo = assert(arg[1], "repository path is required")
local file = repo .. "/ZygorGuidesViewerNew/ZygorGuidesViewer/Compat/Profession.lua"

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(("%s: expected %s, got %s"):format(label, tostring(expected), tostring(actual)), 2) end
end

local services,events={},{}
local Compat={}
function Compat:CreateService(name) local service={} services[name]=service self[name]=service return service end
function Compat:RegisterEvent(event,owner,method) events[event]={owner=owner,method=method} end
function Compat.Bool(value) return value and true or false end
function Compat:Result(ok,code,data) data=data or {} data.ok=ok and true or false data.code=code return data end
ZygorGuidesViewer={Compat=Compat}

local spellNames={
  [2259]={"Alchemy",nil,"alchemy-icon"},
  [45357]={"Inscription",nil,"inscription-icon"},
}
function GetSpellInfo(id)
  local values=spellNames[id]
  if values then return values[1],values[2],values[3] end
end
function GetNumSkillLines() return 3 end
function GetSkillLineInfo(index)
  if index==1 then return "Professions",true,true,0,0,0,0,false end
  if index==2 then return "Alchemy",false,false,375,2,5,450,true end
  if index==3 then return "Inscription",false,false,410,0,0,450,true end
end

function GetTradeSkillLine() return "Alchemy",400,450 end
function GetNumTradeSkills() return 2 end
function GetTradeSkillInfo(index)
  if index==1 then return "Potions", "header", nil, true end
  return "Runic Healing Potion", "optimal", 7, false
end
function GetTradeSkillRecipeLink(index)
  if index==2 then return "|cffffd000|Henchant:53042|h[Runic Healing Potion]|h|r" end
end
function GetTradeSkillItemLink(index)
  if index==2 then return "|cff1eff00|Hitem:33447:0:0:0:0:0:0:0|h[Runic Healing Potion]|h|r" end
end
function GetTradeSkillNumMade(index) if index==2 then return 2,4 end end
function GetTradeSkillNumReagents(index) return index==2 and 2 or 0 end
function GetTradeSkillReagentInfo(index,reagent)
  if reagent==1 then return "Goldclover","gold-icon",2,9 end
  return "Imbued Vial","vial-icon",1,4
end
function GetTradeSkillReagentItemLink(index,reagent)
  local id=reagent==1 and 36901 or 40411
  return "|cffffffff|Hitem:"..id..":0:0:0:0:0:0:0|h[reagent]|h|r"
end
local craftIndex,craftCount
function DoTradeSkill(index,count) craftIndex,craftCount=index,count end
function GetItemCount(id) return id==33447 and 1 or 0 end

dofile(file)
local Profession=assert(services.Profession)
local all=Profession:GetAll()
assertEqual(#all,2,"legacy skill tuple count")
assertEqual(all[1].name,"Alchemy","legacy tuple name")
assertEqual(all[1].skillLevel,375,"legacy tuple rank")
assertEqual(all[1].temporaryBonus,2,"legacy tuple temporary points")
assertEqual(all[1].skillModifier,5,"legacy tuple modifier")
assertEqual(all[1].maxSkillLevel,450,"legacy tuple maximum")
assertEqual(all[1].skillLine,171,"legacy tuple skill line")
assertEqual(Profession:GetSkill(773).skillLevel,410,"legacy Inscription lookup")

local cache=Profession:RefreshRecipes()
local recipe=assert(cache[53042],"recipe spell cache missing")
assertEqual(Profession.recipeByProduct[33447],recipe,"product cache")
assertEqual(recipe.productID,33447,"recipe product")
assertEqual(recipe.numMade[1],2,"minimum made")
assertEqual(recipe.numMade[2],4,"maximum made")
assertEqual(#recipe.reagents,2,"reagent count")
assertEqual(recipe.reagents[1].itemID,36901,"first reagent item")
assertEqual(recipe.reagents[1].required,2,"first reagent required")
assertEqual(recipe.reagents[1].owned,9,"first reagent owned")
assertEqual(Profession:FindRecipe(33447),recipe,"find by product")
assertEqual(Profession:FindRecipe("Runic Healing Potion"),recipe,"find by name")

local result=ZygorGuidesViewer:PerformTradeSkill(53042,3)
assertEqual(result.ok,true,"explicit craft facade result")
assertEqual(result.code,"craft_requested","explicit craft facade code")
assertEqual(craftIndex,2,"explicit craft index")
assertEqual(craftCount,3,"explicit craft count")

craftIndex,craftCount=nil,nil
local goalResult=ZygorGuidesViewer:PerformTradeSkillGoal({targetID=33447,count=3})
assertEqual(goalResult.ok,true,"goal craft result")
assertEqual(craftIndex,2,"goal craft index")
assertEqual(craftCount,2,"goal craft subtracts owned products")

GetTradeSkillLine=function() return nil end
local closed=Profession:Craft(53042,1)
assertEqual(closed.ok,false,"closed profession rejects craft")
assertEqual(closed.code,"trade_skill_closed","closed profession code")

print("profession compatibility tests passed")
