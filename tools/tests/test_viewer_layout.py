from __future__ import annotations

import shutil
import subprocess
import unittest
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
LUA_TEST = REPO / "tools" / "tests" / "lua" / "test_viewer_layout.lua"
VIEWER = REPO / "ZygorGuidesViewerNew" / "ZygorGuidesViewer" / "ModernViewer.lua"


class ViewerLayoutTests(unittest.TestCase):
    def test_classic_frame_and_skin_contracts_are_executable(self) -> None:
        source = VIEWER.read_text(encoding="utf-8")
        self.assertIn('CreateFrame("Frame", "ZygorGuidesViewerFrame", UIParent)', source)
        self.assertIn('skin("WindowBottomBackdrop"', source)
        self.assertIn('skin("TabsDecor"', source)
        self.assertIn("frame.bodyBack = bodyBack", source)
        self.assertIn("self.visibleGoalRows", source)
        self.assertIn('handle:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, -2)', source)
        self.assertIn("heightLimit = math.min(heightLimit, frame:GetHeight() or heightLimit)", source)
        self.assertNotIn("math.max(400, viewer.width", source)
        self.assertNotIn('addResizer("BOTTOM", "BOTTOM", "BOTTOM", 1000', source)

    def test_compact_wrapped_auto_height_contract(self) -> None:
        lua = shutil.which("lua5.1") or shutil.which("lua")
        if not lua:
            self.skipTest("Lua 5.1 runtime is unavailable")
        result = subprocess.run(
            [lua, str(LUA_TEST), str(REPO)],
            cwd=REPO,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("viewer layout contract passed", result.stdout)


if __name__ == "__main__":
    unittest.main()
