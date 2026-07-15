from __future__ import annotations

import json
import re
import shutil
import subprocess
import unittest
import xml.etree.ElementTree as ElementTree
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
SOURCE = REPO / "ZygorGuidesViewerClassicTBCAnniv"
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"
TOOLS = REPO / "tools"


class RootSourceFacadeTests(unittest.TestCase):
    @unittest.skipUnless(SOURCE.is_dir(), "requires the local Classic/TBC reference corpus")
    def test_only_product_packaging_root_files_remain_physically_excluded(self) -> None:
        missing = {
            path.name for path in SOURCE.iterdir()
            if path.is_file() and not (ADDON / path.name).is_file()
        }
        self.assertEqual(missing, {
            "Licence.lua",
            "ZygorGuidesViewerClassicTBCAnniv.toc",
            "ZygorGuidesViewerClassicTBCAnniv_TBC.toc",
            "ZygorGuidesViewerClassicTBCAnniv_Vanilla.toc",
        })

    def test_literal_facades_are_in_one_loaded_post_implementation_closure(self) -> None:
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8-sig")
        self.assertEqual(toc.count("files-TBC.xml"), 1)
        for implementation in ("ModernActionBar.lua", "ModernNotifications.lua", "WhoWhere.lua", "Telemetry.lua"):
            self.assertLess(toc.index(implementation), toc.index("files-TBC.xml"))

        root = ElementTree.parse(ADDON / "files-TBC.xml").getroot()
        entries = [
            element.attrib["file"].replace("\\", "/")
            for element in root.iter()
            if element.tag.rsplit("}", 1)[-1] in {"Script", "Include"} and "file" in element.attrib
        ]
        for name in ("ActionBar.lua", "BugReport.lua", "ErrorLogger.lua", "Localizers.lua", "Log.lua", "MacroGuide.lua", "NotificationCenter.lua"):
            self.assertIn(name, entries)
        self.assertIn("Code-TBC/files.xml", entries)

    @unittest.skipUnless(SOURCE.is_dir(), "requires the local Classic/TBC reference corpus")
    def test_source_public_method_inventory_is_preserved(self) -> None:
        method_pattern = re.compile(
            r"^\s*function\s+[A-Za-z_][A-Za-z0-9_.]*[.:]([A-Za-z_][A-Za-z0-9_]*)\s*\(",
            re.MULTILINE,
        )
        counterparts = {
            "ActionBar.lua": ("ModernActionBar.lua", "ActionBar.lua"),
            "BugReport.lua": ("BugReport.lua",),
            "ErrorLogger.lua": ("ErrorLogger.lua",),
            "Localizers.lua": ("Localizers.lua",),
            "Log.lua": ("Log.lua",),
            "MacroGuide.lua": ("MacroGuide.lua",),
            "NotificationCenter.lua": ("ModernNotifications.lua", "NotificationCenter.lua"),
        }
        for source_name, target_names in counterparts.items():
            source_methods = set(method_pattern.findall((SOURCE / source_name).read_text(encoding="utf-8-sig")))
            target_methods: set[str] = set()
            for target_name in target_names:
                target_methods.update(method_pattern.findall((ADDON / target_name).read_text(encoding="utf-8-sig")))
            self.assertFalse(source_methods - target_methods, (source_name, sorted(source_methods - target_methods)))

        combined = "\n".join((ADDON / name).read_text(encoding="utf-8") for name in (
            "ModernActionBar.lua", "ActionBar.lua", "BugReport.lua", "ErrorLogger.lua",
            "Localizers.lua", "Log.lua", "MacroGuide.lua", "ModernNotifications.lua", "NotificationCenter.lua",
        ))
        for method in (
            "IsExpandingRight", "Initialise", "SetActionButtons", "SetButton", "CreateGoaltype", "ClearBar",
            "GetReport_Flavor", "GetReport", "GenerateAndShow", "SaveDump", "FormatDumpForUpload", "GetDumpBody",
            "ErrorLogger_GetErrors", "GetTranslatedNPC", "FindNPCIdByName", "GetQuestDataFromTooltip", "GetQuestData",
            "SetSize", "Trim", "Add", "Print", "Dump", "ActionButtonPrepare", "LocateMacro", "MacroExists",
            "CreateMacro", "NotifyAboutUpdates", "DeleteMacro", "Update", "PlaceOnBar", "AddEntry",
            "RemoveEntriesByType", "RemoveEntry", "GetEntry", "UpdatePosition", "ShowSpecial", "ShowOne",
            "ShowAll", "ShowSub", "ClearNotifications", "LoadNotifications", "SaveNotifications", "HandleQueue",
            "ApplySkin", "CheckDynamicNotifications", "EventsTrigger", "QuestResetTrigger", "OrientationTrigger",
        ):
            self.assertIn(method, combined, method)

        macro = (ADDON / "MacroGuide.lua").read_text(encoding="utf-8")
        for unsafe in ("PickupMacro(", "EditMacro(", "DeleteMacro(self.name", "PlaceAction("):
            self.assertNotIn(unsafe, macro)
        action = (ADDON / "ActionBar.lua").read_text(encoding="utf-8")
        self.assertNotIn('SetScript("OnClick"', action)

    def test_manifest_names_loaded_facades_and_explicit_packaging_exclusions(self) -> None:
        manifest = json.loads((TOOLS / "port_dispositions.json").read_text(encoding="utf-8"))
        rules = {rule["id"]: rule for rule in manifest["rules"]}
        self.assertEqual(rules["adapt-root-files-tbc-loader"]["disposition"], "adapted")
        self.assertEqual(rules["exclude-anniversary-source-tocs"]["disposition"], "intentional_exclusion")
        self.assertEqual(rules["exclude-anniversary-licence-gates"]["disposition"], "intentional_exclusion")
        for rule_id, facade in (
            ("replace-root-secure-action-layer", "ZygorGuidesViewer/ActionBar.lua"),
            ("replace-root-diagnostics-reporting", "ZygorGuidesViewer/BugReport.lua"),
            ("replace-root-localization-cache", "ZygorGuidesViewer/Localizers.lua"),
            ("replace-root-notification-center", "ZygorGuidesViewer/NotificationCenter.lua"),
        ):
            self.assertIn(facade, rules[rule_id]["replacement_targets"])

    def test_facades_execute_headlessly_under_lua_51(self) -> None:
        lua = shutil.which("lua5.1") or shutil.which("lua")
        if not lua:
            self.skipTest("Lua 5.1 runtime is unavailable")
        result = subprocess.run(
            [lua, str(TOOLS / "tests" / "lua" / "test_root_source_facades.lua"), str(REPO)],
            cwd=REPO, text=True, capture_output=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("root source facade headless tests passed", result.stdout)


if __name__ == "__main__":
    unittest.main()
