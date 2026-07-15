from __future__ import annotations

import json
import shutil
import subprocess
import unittest
from pathlib import Path


TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"


class VisualsCompatTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
    def test_recursive_renderer_headless(self) -> None:
        completed = subprocess.run(
            [shutil.which("lua") or "lua", str(TOOLS / "tests" / "lua" / "test_visuals_compat.lua"), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn("visuals compatibility headless tests passed", completed.stdout)

    def test_toc_order_and_known_vocabulary(self) -> None:
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        self.assertLess(toc.index("UIWidgetsCompat.lua"), toc.index("VisualsCompat.lua"))
        self.assertLess(toc.index("VisualsCompat.lua"), toc.index("ModernViewer.lua"))
        source = (ADDON / "VisualsCompat.lua").read_text(encoding="utf-8")
        for element_type in (
            "generic", "title", "banner", "text", "item", "list", "columns",
            "content", "guideslist", "section", "roadmap_section", "separator",
        ):
            self.assertIn(f"{element_type} = true", source)
        self.assertNotIn("C_", source)

    def test_manifest_closes_visuals_disposition(self) -> None:
        manifest = json.loads((TOOLS / "port_dispositions.json").read_text(encoding="utf-8"))
        rule = next(rule for rule in manifest["rules"] if "UiWidgets/Visuals.lua" in rule.get("source_paths", []))
        self.assertEqual(rule["id"], "replace-ui-visual-renderer")
        self.assertEqual(rule["disposition"], "replaced")
        self.assertIn("ZygorGuidesViewer/VisualsCompat.lua", rule["replacement_targets"])

    def test_item_and_guide_actions_are_sanitized(self) -> None:
        source = (ADDON / "VisualsCompat.lua").read_text(encoding="utf-8")
        self.assertIn("local function safeItemLink", source)
        self.assertIn("ZGV.Runtime:SelectGuide(key)", source)
        self.assertNotIn("GameTooltip:SetHyperlink(tostring", source)


if __name__ == "__main__":
    unittest.main()

