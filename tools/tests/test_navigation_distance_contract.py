from __future__ import annotations

import re
import shutil
import subprocess
import unittest
from pathlib import Path


TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
ADDON = REPO / "ZygorGuidesViewerNew" / "ZygorGuidesViewer"


class NavigationDistanceContractTests(unittest.TestCase):
    def test_unknown_and_measured_distance_behavior(self) -> None:
        lua = shutil.which("lua5.1") or shutil.which("lua")
        if not lua:
            self.skipTest("Lua interpreter is unavailable")
        completed = subprocess.run(
            [lua, str(TOOLS / "tests" / "lua" / "test_navigation_distance_contract.lua"), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn("navigation distance contract tests passed", completed.stdout)

    def test_normalised_fallback_cannot_masquerade_as_yards(self) -> None:
        map_source = (ADDON / "Compat" / "Map.lua").read_text(encoding="utf-8")
        match = re.search(
            r'return Compat:Result\(true, "normalised_map", \{(?P<body>.*?)\n\s*\}\)',
            map_source,
            re.DOTALL,
        )
        self.assertIsNotNone(match, "normalised-map result block is missing")
        body = match.group("body") if match else ""
        self.assertIn("distanceKnown = false", body)
        self.assertIn("normalisedDistance =", body)
        self.assertNotRegex(body, r"\bdistance\s*=")
        self.assertNotRegex(body, r"\*\s*10000\b")
        self.assertGreaterEqual(map_source.count("distanceKnown = true"), 2)

    def test_navigation_filters_unknown_distance_but_keeps_bearing(self) -> None:
        navigation = (ADDON / "Navigation.lua").read_text(encoding="utf-8")
        self.assertIn(
            'result.distanceKnown==true and type(result.distance)=="number"',
            navigation,
        )
        self.assertIn('type(result.xDelta)~="number"', navigation)
        self.assertIn('type(result.yDelta)~="number"', navigation)
        self.assertIn(
            'state and state.visible and type(state.direction)=="number"',
            navigation,
        )
        self.assertNotIn(
            'type(state.distance)=="number" and type(state.direction)=="number"',
            navigation,
        )

        modern_arrow = (ADDON / "ModernArrow.lua").read_text(encoding="utf-8")
        legacy_ui = (ADDON / "UI.lua").read_text(encoding="utf-8")
        self.assertRegex(
            modern_arrow,
            r'type\(state\.distance\)\s*==\s*"number"\s*and\s*string\.format\("%\.0f yards"',
        )
        self.assertRegex(
            legacy_ui,
            r'type\((?:state|arrow)\.distance\)\s*==\s*"number"\s*and\s*string\.format\("%\.0f yards"',
        )


if __name__ == "__main__":
    unittest.main()
