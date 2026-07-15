from __future__ import annotations

import shutil
import subprocess
import unittest
from pathlib import Path


TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"


class DashboardWidgetTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
    def test_headless_dashboard_contracts(self) -> None:
        completed = subprocess.run(
            [shutil.which("lua") or "lua", str(TOOLS / "tests" / "lua" / "test_dashboard_widgets.lua"), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn("dashboard widget headless tests passed", completed.stdout)

    def test_toc_order_and_accessibility(self) -> None:
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        self.assertLess(toc.index("UI.lua"), toc.index("UIWidgetsCompat.lua"))
        self.assertLess(toc.index("Widgets.lua"), toc.index("DashboardWidgets.lua"))
        core = (ADDON / "Core.lua").read_text(encoding="utf-8")
        viewer = (ADDON / "ModernViewer.lua").read_text(encoding="utf-8")
        self.assertIn('command=="widgets"', core)
        self.assertIn('"Dashboard Widgets"', viewer)

    def test_secure_action_contract_and_guide_ids(self) -> None:
        compatibility = (ADDON / "UIWidgetsCompat.lua").read_text(encoding="utf-8")
        dashboard = (ADDON / "DashboardWidgets.lua").read_text(encoding="utf-8")
        self.assertIn('type = "pet", action = slot', compatibility)
        self.assertIn('RunOutOfCombat("ui-action:"', compatibility)
        self.assertNotIn('SetAttribute("type", "petaction")', compatibility)
        self.assertIn("self.guide.id or self.guide.title", dashboard)
        self.assertIn("suggestions.guide.id or suggestions.guide.title", dashboard)

    def test_retail_dashboard_namespaces_are_not_loaded(self) -> None:
        dashboard = (ADDON / "DashboardWidgets.lua").read_text(encoding="utf-8")
        for namespace in ("C_CovenantCallings", "C_ChallengeMode", "C_MythicPlus", "C_WowTokenPublic", "C_DateAndTime"):
            self.assertNotIn(namespace, dashboard)


if __name__ == "__main__":
    unittest.main()

