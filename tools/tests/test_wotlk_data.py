from __future__ import annotations

import shutil
import subprocess
import unittest
import json
import re
from pathlib import Path


TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"
SOURCE = REPO / "ZygorGuidesViewerClassicTBCAnniv" / "Data-TBC" / "Chains.lua"
TARGET = ADDON / "Data-WotLK" / "QuestChainsClassicTBC.lua"
NPC_SOURCE = REPO / "ZygorGuidesViewerClassicTBCAnniv" / "Data-TBC" / "NPCData.lua"
NPC_TARGET = ADDON / "Data-WotLK" / "NPCData.lua"
PORT_MANIFEST = TOOLS / "port_dispositions.json"


class WotLKDataTests(unittest.TestCase):
    @unittest.skipUnless(SOURCE.is_file(), "requires the local Classic/TBC reference corpus")
    def test_classic_tbc_chain_payload_is_exact(self) -> None:
        self.assertEqual(TARGET.read_bytes(), SOURCE.read_bytes())

    def test_chain_load_order(self) -> None:
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        self.assertLess(toc.index(r"Data-WotLK\QuestChains.lua"), toc.index("ChainsParser.lua"))
        self.assertLess(toc.index("ChainsParser.lua"), toc.index(r"Data-WotLK\QuestChainsClassicTBC.lua"))

    @unittest.skipUnless(NPC_SOURCE.is_file(), "requires the local Classic/TBC reference corpus")
    def test_npc_payload_is_preserved_after_line_ending_normalization(self) -> None:
        source = NPC_SOURCE.read_bytes().replace(b"\r\n", b"\n")
        target = NPC_TARGET.read_bytes().replace(b"\r\n", b"\n")
        self.assertEqual(target, source)

    def test_progression_uses_full_wotlk_level_range(self) -> None:
        path = ADDON / "Data-WotLK" / "Progression.lua"
        text = path.read_text(encoding="utf-8")
        block = text.split("local xpForCurrentLevel={", 1)[1].split("}", 1)[0]
        values = [int(value) for value in re.findall(r"\d+", block)]
        self.assertEqual(len(values), 79)
        self.assertEqual(values[0], 400)
        self.assertEqual(values[59], 290000)  # level 60 -> 61, Wrath-reduced
        self.assertEqual(values[68], 717000)  # level 69 -> 70
        self.assertEqual(values[69], 1523800)  # level 70 -> 71
        self.assertEqual(values[78], 1670800)  # level 79 -> 80
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        self.assertIn(r"Data-WotLK\Progression.lua", toc)

    def test_live_profession_contract_covers_wrath_recipes(self) -> None:
        profession = (ADDON / "Compat" / "Profession.lua").read_text(encoding="utf-8")
        for contract in (
            "GetTradeSkillRecipeLink",
            "GetTradeSkillItemLink",
            "GetTradeSkillNumMade",
            "GetTradeSkillNumReagents",
            "GetTradeSkillReagentItemLink",
            "function Profession:RefreshRecipes",
            "function Profession:Craft",
            '[773] = { name = "Inscription"',
            "function Legacy:KnowsRecipe",
        ):
            self.assertIn(contract, profession)
        self.assertIn('Compat:RegisterEvent("TRADE_SKILL_UPDATE"', profession)

    def test_dungeon_preview_uses_wotlk_ids_and_retained_artwork(self) -> None:
        preview = (ADDON / "DungeonPreview.lua").read_text(encoding="utf-8")
        self.assertIn('[189]={name="Scarlet Monastery"', preview)
        self.assertIn('[289]={name="Scholomance"', preview)
        self.assertNotIn("[1004]=", preview)
        self.assertNotIn("[1007]=", preview)
        images = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer_GuidesCommon" / "Images" / "Dungeons"
        for filename, _, both in re.findall(r'floor\("([^"]+)","([^"]+)"(,true)?\)', preview):
            suffixes = ["both"] if both else ["alliance", "horde"]
            for suffix in suffixes:
                self.assertTrue((images / f"{filename}-{suffix}.blp").is_file(), (filename, suffix))

    def test_tbc_data_and_non_gold_code_have_per_file_dispositions(self) -> None:
        manifest = json.loads(PORT_MANIFEST.read_text(encoding="utf-8"))
        for rule in manifest["rules"]:
            if rule["disposition"] != "pending":
                continue
            paths = list(rule.get("source_paths", [])) + list(rule.get("source_globs", []))
            self.assertFalse(any(path.startswith("Data-TBC/") for path in paths), rule["id"])
            self.assertFalse(any(path.startswith("Code-TBC/") and not path.startswith("Code-TBC/GoldUI/") for path in paths), rule["id"])

    @unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
    def test_faction_and_merged_chain_contracts(self) -> None:
        completed = subprocess.run(
            [shutil.which("lua") or "lua", str(TOOLS / "tests" / "lua" / "test_wotlk_chains.lua"), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn("WotLK quest chain tests passed", completed.stdout)


if __name__ == "__main__":
    unittest.main()
