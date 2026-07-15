local repo = assert(arg[1], "repository path required")

ZygorGuidesViewer = {
  UI = {},
  F = {},
  AddMessageHandler = function() end,
}
ZGV = ZygorGuidesViewer

dofile(repo .. "/ZygorGuidesViewerNew/ZygorGuidesViewer/ModernViewer.lua")

local UI = ZygorGuidesViewer.UI
assert(type(UI.MeasureGoalRow) == "function", "viewer row measurement contract missing")
assert(type(UI.CalculateGuideHeight) == "function", "viewer auto-height contract missing")
assert(type(UI.PrepareViewerLayout) == "function", "viewer layout migration contract missing")
assert(UI.StepIconColumns.accept == 5 and UI.StepIconColumns.turnin == 6, "quest step atlas columns differ from the Classic viewer")
assert(UI.StepIconColumns["goto"] == 12 and UI.StepIconColumns.talk == 13, "navigation/talk step atlas columns differ from the Classic viewer")

local short = UI:MeasureGoalRow("Talk to Khadgar", 300)
local wrapped = UI:MeasureGoalRow("Travel through the city and speak with the quest giver beside the northern entrance before continuing", 190)
assert(short == 26, "a single Classic step line should use the compact row height")
assert(wrapped > short, "long step text should wrap and increase its row height")

local one = UI:CalculateGuideHeight({ short })
local three = UI:CalculateGuideHeight({ short, short, wrapped })
assert(one >= 155 and one < three, "viewer height must follow the rendered step lines")
assert(three <= 720, "viewer auto-height must remain bounded")

local placeholder = { width = 400, height = 420, layoutVersion = 2, autoHeight = true }
UI:PrepareViewerLayout(placeholder)
assert(placeholder.width == 340, "the persisted placeholder minimum should migrate to the Classic width")
assert(placeholder.height == 155, "the persisted placeholder minimum should migrate to the compact height")
assert(placeholder.autoHeight == true and placeholder.layoutVersion == 2 and placeholder.classicLayoutMigrated, "Classic auto-height migration was not recorded")

local custom = { width = 372, height = 245 }
UI:PrepareViewerLayout(custom)
assert(custom.width == 372, "a custom viewer width must be preserved")
assert(custom.height == 245, "a custom viewer height must be preserved")

print("viewer layout contract passed")
