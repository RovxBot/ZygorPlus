from __future__ import annotations

import re
import unittest
import xml.etree.ElementTree as ElementTree
from pathlib import Path

import sys

TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
BUNDLE = REPO / "ZygorGuidesViewerNew"
ADDON = BUNDLE / "ZygorGuidesViewer"
SOURCE = REPO / "ZygorGuidesViewerClassicTBCAnniv"
sys.path.insert(0, str(TOOLS))

from validate_addons import _mask_lua_comments_and_strings  # noqa: E402


def loaded_files(addon_root: Path) -> set[Path]:
    """Return the exact TOC/XML load closure for one addon."""
    pending = [addon_root / f"{addon_root.name}.toc"]
    seen: set[Path] = set()
    while pending:
        path = pending.pop()
        path = path.resolve()
        if path in seen:
            continue
        seen.add(path)
        if path.suffix.lower() == ".toc":
            for raw in path.read_text(encoding="utf-8-sig").splitlines():
                value = raw.strip()
                if value and not value.startswith("##") and not value.startswith("#"):
                    pending.append(path.parent / value.replace("\\", "/"))
        elif path.suffix.lower() == ".xml":
            root = ElementTree.fromstring(path.read_text(encoding="utf-8-sig"))
            for element in root.iter():
                reference = element.attrib.get("file")
                if reference:
                    pending.append(path.parent / reference.replace("\\", "/"))
    return seen


class LibraryContractTests(unittest.TestCase):
    def test_loaded_runtime_has_no_lookup_for_pruned_libraries(self) -> None:
        closure = loaded_files(ADDON)
        lua_files = sorted(path for path in closure if path.suffix.lower() == ".lua")
        self.assertGreater(len(lua_files), 50)
        self.assertIn((ADDON / "Libs/Astrolabe/Astrolabe.lua").resolve(), closure)
        self.assertIn((ADDON / "Libs/LibGratuity-3.0/LibGratuity-3.0.lua").resolve(), closure)

        lookups: set[str] = set()
        forbidden_globals = re.compile(
            r"(?<![.\w])(?:HereBeDragons|HBDPins|AceConfig|AceGUI|LibHash|LibDeflate|LibGraph)(?!\w)"
        )
        for path in lua_files:
            if "Libs" in path.relative_to(ADDON).parts:
                continue
            text = path.read_text(encoding="utf-8-sig")
            masked = _mask_lua_comments_and_strings(text, preserve_strings=True)
            lookups.update(
                match.group(2)
                for match in re.finditer(
                    r"\bLibStub\s*(?:\(|:GetLibrary\s*\()\s*(['\"])([^'\"]+)\1",
                    masked,
                )
            )
            match = forbidden_globals.search(_mask_lua_comments_and_strings(text))
            self.assertIsNone(match, f"{path.relative_to(ADDON)} requires pruned global {match.group(0) if match else ''}")

        self.assertEqual(lookups, {"LibGratuity-3.0"})

    def test_navigation_replacement_preserves_live_legacy_surface(self) -> None:
        navigation = (ADDON / "Navigation.lua").read_text(encoding="utf-8")
        taxi = (ADDON / "Compat/Taxi.lua").read_text(encoding="utf-8")
        routes = (ADDON / "Data-WotLK/Routes.lua").read_text(encoding="utf-8")
        npc_data = (ADDON / "Data-WotLK/NPCData.lua").read_text(encoding="utf-8")

        for contract in (
            "function ZGV.LibRover:FindRoute",
            "function ZGV.LibRover:GetPlayerPosition",
            "function ZGV.LibRover:CanFlyAt",
            "_G.LibRover=ZGV.LibRover",
        ):
            self.assertIn(contract, navigation)
        for contract in (
            "function Taxi:Capture",
            "function Taxi:Take",
            "function Taxi:GetTaxis",
            "function Taxi:Startup",
            "_G.LibTaxi = Taxi",
        ):
            self.assertIn(contract, taxi)

        # Every build-12340 travel item retained from the source data is on the
        # replacement rover contract, while inn locations are supplied by the
        # loaded NPC dataset consumed by WhoWhere.
        for item_id in (6948, 22631, 22589, 22632, 22630, 18984, 18986):
            self.assertRegex(routes, rf"\{{item={item_id}(?:,|\}})")
        self.assertIn('["Innkeeper"] = [[', npc_data)

    def test_empty_source_floor_and_indoor_payloads_are_not_missing_data(self) -> None:
        floor_text = (SOURCE / "Libs-TBC/LibRover-1.0/data_floorcrossings.lua").read_text(encoding="utf-8")
        indoor_text = (SOURCE / "Libs-TBC/LibRover-1.0/data_indoors.lua").read_text(encoding="utf-8")
        self.assertRegex(floor_text, r"data\.basenodes\.FloorCrossings\s*=\s*\{\s*\}")
        self.assertRegex(indoor_text, r"data\.basenodes\.indoorzones\s*=\s*\{\s*\}")


if __name__ == "__main__":
    unittest.main()
