from __future__ import annotations

import json
import re
import unittest
import xml.etree.ElementTree as ElementTree
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"
TOC = ADDON / "ZygorGuidesViewer.toc"
MANIFEST = REPO / "tools" / "port_dispositions.json"


def toc_entries(path: Path) -> list[str]:
    entries: list[str] = []
    for raw_line in path.read_text(encoding="utf-8-sig").splitlines():
        line = raw_line.strip()
        if line and not line.startswith("#"):
            entries.append(line.replace("\\", "/"))
    return entries


def xml_entries(path: Path) -> list[str]:
    root = ElementTree.fromstring(path.read_text(encoding="utf-8-sig"))
    entries: list[str] = []
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] not in {"Script", "Include"}:
            continue
        value = element.attrib.get("file")
        if value:
            entries.append(value.replace("\\", "/"))
    return entries


def load_closure() -> set[str]:
    """Resolve executable files through the primary TOC and nested XML."""
    pending = toc_entries(TOC)
    # Bindings.xml is a client-recognised addon entry point, not a TOC line.
    if (ADDON / "Bindings.xml").is_file():
        pending.append("Bindings.xml")
    closure: set[str] = set()
    while pending:
        relative = pending.pop(0)
        if relative in closure:
            continue
        path = ADDON / relative
        if not path.is_file():
            raise AssertionError(f"load closure references missing file: {relative}")
        closure.add(relative)
        if path.suffix.lower() == ".xml":
            for child in xml_entries(path):
                pending.append((Path(relative).parent / child).as_posix())
    return closure


def source(closure: set[str], relative: str) -> str:
    if relative not in closure:
        raise AssertionError(f"contract file is not in executable load closure: {relative}")
    return (ADDON / relative).read_text(encoding="utf-8-sig")


class RootRuntimeContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.closure = load_closure()

    def test_root_replacement_targets_are_executable(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        checked = 0
        for rule in manifest["rules"]:
            if not rule["id"].startswith(("adapt-root-", "replace-root-")):
                continue
            for target in rule.get("replacement_targets", []):
                prefix = "ZygorGuidesViewer/"
                if target.startswith(prefix):
                    self.assertIn(target[len(prefix) :], self.closure, (rule["id"], target))
                    checked += 1
        self.assertGreaterEqual(checked, 20)

    def test_numeric_quest_and_item_progress_reaches_the_viewer(self) -> None:
        quest = source(self.closure, "Compat/Quest.lua")
        runtime = source(self.closure, "Runtime.lua")
        viewer = source(self.closure, "ModernViewer.lua")
        self.assertIn("GetQuestLogLeaderBoard(objective_index, quest_index)", quest)
        self.assertIn("current = current", quest)
        self.assertIn("required = required", quest)
        self.assertIn("function Runtime:GetGoalProgress", runtime)
        self.assertIn("source=\"quest\"", runtime)
        self.assertIn("source=\"items\"", runtime)
        self.assertRegex(viewer, r"state\.current\s*\.\.\s*\"/\"\s*\.\.\s*state\.required")

    def test_questie_coexistence_does_not_take_over_shared_watch_state(self) -> None:
        database = source(self.closure, "Database.lua")
        tracking = source(self.closure, "QuestTracking.lua")
        bridge = source(self.closure, "Compat/ModernBridge.lua")
        self.assertRegex(database, r"tracking=\{\s*enabled=true,\s*watchActive=false")
        self.assertIn('IsAddOnLoaded("Questie-335")', tracking)
        self.assertIn("profile.watchActive and not questieLoaded", tracking)
        self.assertNotRegex(bridge, r"_G\.C_[A-Za-z][A-Za-z0-9_]*\s*=")

    def test_abandoned_quests_are_recorded_only_after_confirmation(self) -> None:
        automation = source(self.closure, "Automation.lua")
        tracking = source(self.closure, "QuestTracking.lua")
        self.assertIn('hooksecurefunc("SetAbandonQuest"', automation)
        self.assertIn('hooksecurefunc("AbandonQuest"', automation)
        self.assertIn("function Automation:ConfirmAbandon()", automation)
        self.assertNotIn("function Automation:OnQuestLogUpdate()", automation)
        self.assertIn("ZGV.Automation:ConfirmAbandon()", tracking)

    def test_navigation_contract_has_routes_lines_and_corrected_arrow_math(self) -> None:
        navigation = source(self.closure, "Navigation.lua")
        arrow = source(self.closure, "ModernArrow.lua")
        self.assertIn("function Navigation:GetRouteInstructions", navigation)
        self.assertIn("function Navigation:UpdateMapLines", navigation)
        self.assertIn("function Navigation:UpdateMinimapLines", navigation)
        self.assertIn("direction=-direction", navigation)
        self.assertIn("if x<0 and y>=0 then", navigation)
        self.assertIn("local function routeSummary", arrow)
        self.assertIn("local mirrored = sequence > 150", arrow)

    def test_diagnostics_are_bounded_persistent_and_user_accessible(self) -> None:
        core = source(self.closure, "Core.lua")
        database = source(self.closure, "Database.lua")
        maintenance = source(self.closure, "Maintenance.lua")
        self.assertIn("self.db.global.diagnostics.entries", core)
        self.assertIn("if #self.Diagnostics>500", core)
        self.assertIn('command=="report"', core)
        self.assertIn("diagnostics={errors={},entries={}}", database)
        self.assertIn("function Maintenance:Report", maintenance)
        self.assertIn("Compat/LoadDiagnostics.lua", self.closure)
        self.assertIn("Compat/LoadDiagnosticsEnd.lua", self.closure)

    def test_secure_action_bar_preserves_blizzards_click_handler(self) -> None:
        action_bar = source(self.closure, "ModernActionBar.lua")
        automation = source(self.closure, "Automation.lua")
        self.assertIn('attributes.type="pet"; attributes.action=slot', action_bar)
        self.assertIn('button:SetScript("PostClick"', action_bar)
        self.assertNotIn('button:SetScript("OnClick"', action_bar)
        self.assertIn('"SecureHandlerStateTemplate"', action_bar)
        self.assertIn('RegisterStateDriver(frame,"visibility","[combat] hide; show")', action_bar)
        self.assertIn('retryOutOfCombat("refresh"', action_bar)
        self.assertNotIn("config.hideInCombat and InCombatLockdown()", action_bar)
        self.assertNotIn('CreateSecureActionButton("ZygorGuidesViewerActionButton"', automation)
        self.assertNotIn('SetPoint("CENTER",UIParent,"CENTER",0,-180)', automation)
        self.assertIn('return ZGV.ActionBar:Refresh()', automation)

    def test_guide_menu_uses_the_classic_grouped_options_layout(self) -> None:
        menu = source(self.closure, "ModernGuideMenu.lua")
        options = source(self.closure, "Options.lua")
        self.assertIn('self.listPane:SetWidth(603)', menu)
        self.assertIn('"OPTION:" .. group.id', menu)
        self.assertIn("ZGV.Options:GetGroups()", menu)
        self.assertIn("ZGV.Options:GetValueText(option)", menu)
        self.assertIn("ZGV.Options:Activate(self.option, reverse)", menu)
        self.assertNotIn('local settings = {', menu)
        self.assertIn("function Menu:GetFolderResults", menu)
        self.assertIn('self.section = "FOLDER:" .. path', menu)
        self.assertNotIn("table.sort(ordered)", menu)
        for group in ("display", "stepdisplay", "automation", "actionbuttons", "travelsystem", "maps", "notifications", "gear", "talents", "gold", "extras", "about"):
            self.assertIn(f'id="{group}"', options)
        self.assertIn("InterfaceOptions_AddCategory(panel)", options)
        self.assertIn('ZGV:OpenOptions("display")', options)


if __name__ == "__main__":
    unittest.main()
