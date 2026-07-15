from __future__ import annotations

import shutil
import subprocess
import unittest
from pathlib import Path


TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent


class WotLKRuntimeTests(unittest.TestCase):
    def run_lua(self, script: str, success: str) -> None:
        lua = shutil.which("lua5.1") or shutil.which("lua")
        if not lua:
            self.skipTest("Lua interpreter is unavailable")
        completed = subprocess.run(
            [lua, str(TOOLS / "tests" / "lua" / script), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn(success, completed.stdout)

    def test_talent_sequences_and_weapon_unlocks(self) -> None:
        self.run_lua("test_wotlk_talents.lua", "WotLK talent and weapon tests passed")

    def test_classic_talent_advisor_ui_contract(self) -> None:
        self.run_lua("test_talent_advisor_ui.lua", "talent advisor UI tests passed")

    def test_profession_compatibility_contract(self) -> None:
        self.run_lua("test_profession_compat.lua", "profession compatibility tests passed")

    def test_quest_and_auction_compatibility_contracts(self) -> None:
        self.run_lua("test_quest_auction_compat.lua", "quest and auction compatibility tests passed")

    def test_questie_automation_coexistence(self) -> None:
        self.run_lua("test_questie_automation.lua", "Questie automation coexistence tests passed")

    def test_abandonment_requires_confirmation(self) -> None:
        self.run_lua("test_automation_abandon.lua", "automation abandon confirmation tests passed")

    def test_runtime_quest_completion_and_catalog_sorting(self) -> None:
        self.run_lua(
            "test_runtime_catalog.lua",
            "runtime quest completion and catalog sorting tests passed",
        )

    def test_name_and_id_buff_tags(self) -> None:
        self.run_lua("test_buff_tag_conditions.lua", "buff tag condition tests passed")

    def test_gear_upgrade_tooltips(self) -> None:
        self.run_lua("test_upgrade_tooltip.lua", "gear upgrade tooltip tests passed")

    def test_gear_finder_character_button(self) -> None:
        self.run_lua("test_gear_finder_button.lua", "gear finder character button tests passed")

    def test_classic_options_contract(self) -> None:
        self.run_lua("test_options_contract.lua", "Classic options contract tests passed")

    def test_known_taxis_and_alternate_city_entries_replan(self) -> None:
        self.run_lua(
            "test_navigation_routes.lua",
            "navigation taxi and city-arrival tests passed",
        )

    def test_release_hardening_contracts(self) -> None:
        self.run_lua("test_release_hardening.lua", "release hardening Lua tests passed")


if __name__ == "__main__":
    unittest.main()
