from __future__ import annotations

import shutil
import subprocess
import unittest
import json
from pathlib import Path


TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"


class GoldAppraiserTests(unittest.TestCase):
    @unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
    def test_headless_appraiser_contracts(self) -> None:
        completed = subprocess.run(
            [shutil.which("lua") or "lua", str(TOOLS / "tests" / "lua" / "test_gold_appraiser.lua"), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn("gold appraiser headless tests passed", completed.stdout)

    def test_toc_loads_model_before_ui(self) -> None:
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        self.assertLess(toc.index("GoldAppraiser.lua"), toc.index("ModernGoldTracker.lua"))

    def test_bid_and_post_are_guarded_user_actions(self) -> None:
        model = (ADDON / "GoldAppraiser.lua").read_text(encoding="utf-8")
        ui = (ADDON / "ModernGoldTracker.lua").read_text(encoding="utf-8")
        self.assertGreaterEqual(model.count('userInitiated ~= true'), 2)
        self.assertIn("Appraiser:Bid(self.selectedAuction, true)", ui)
        self.assertIn("Appraiser:Post(options, true)", ui)
        self.assertIn("Appraiser:StartFullScan(true, true)", ui)
        self.assertIn("Appraiser:LoadGoldGuide(item, true)", ui)
        self.assertNotIn("PlaceAuctionBid", ui)
        self.assertNotIn("StartAuction", ui)
        self.assertNotIn("PickupContainerItem", model + ui)
        self.assertNotIn("PickupItem", model + ui)

    @unittest.skipUnless((REPO / "ZygorGuidesViewerClassicTBCAnniv").is_dir(), "requires the local Classic/TBC reference corpus")
    def test_every_gold_source_has_a_concrete_replacement(self) -> None:
        manifest = json.loads((TOOLS / "port_dispositions.json").read_text(encoding="utf-8"))
        mapped: dict[str, dict[str, object]] = {}
        for rule in manifest["rules"]:
            for source in rule.get("source_paths", []):
                if source.startswith("GoldUI/") or source.startswith("Code-TBC/GoldUI/"):
                    mapped[source] = rule
        source_root = REPO / "ZygorGuidesViewerClassicTBCAnniv"
        expected = {
            path.relative_to(source_root).as_posix()
            for folder in (source_root / "GoldUI", source_root / "Code-TBC" / "GoldUI")
            for path in folder.rglob("*")
            if path.is_file()
        }
        self.assertEqual(set(mapped), expected)
        for source, rule in mapped.items():
            self.assertEqual(rule["disposition"], "replaced", source)
            self.assertTrue(rule.get("replacement_targets"), source)


if __name__ == "__main__":
    unittest.main()
