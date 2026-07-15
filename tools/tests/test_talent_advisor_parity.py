from __future__ import annotations

import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
ADDON = ROOT / "ZygorGuidesViewer" / "ZygorGuidesViewer"
BUILDS = ROOT / "ZygorGuidesViewer" / "ZygorTalentAdvisor" / "Builds" / "LegacyWotLKBuilds.lua"


class TalentAdvisorParityTests(unittest.TestCase):
    def test_deferred_build_12340_initialization_contract(self) -> None:
        source = (ADDON / "Talent.lua").read_text(encoding="utf-8")
        self.assertIn('LoadAddOn,"Blizzard_TalentUI"', source)
        self.assertIn('"PLAYER_ALIVE"', source)
        self.assertIn('"PLAYER_TALENT_UPDATE"', source)
        self.assertIn('"PLAYER_ENTERING_WORLD"', source)
        self.assertIn("initialization deferred", source)
        self.assertIn("self:InitializeBuilds(event)", source)
        self.assertIn("StartInitializationRetry", source)
        self.assertIn('SetScript("OnUpdate"', source)

    def test_classic_popout_and_talent_frame_contracts_are_loaded(self) -> None:
        source = (ADDON / "ModernTalentAdvisor.lua").read_text(encoding="utf-8")
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        self.assertLess(toc.index("Talent.lua"), toc.index("ModernTalentAdvisor.lua"))
        for contract in (
            "UI-GearManager-Border",
            "UI-GearManager-Title-Background",
            "ZygorTalentAdvisorPopoutButton",
            "popout-v2",
            "popout-noclose",
            "ResizeForSuggestions",
            "UIDropDownMenu_Initialize",
            "UIPanelScrollFrameTemplate",
            "PreviewSuggestions",
            "AddPreviewTalentPoints",
            "zta_hints",
            "ZygorDesiredRank",
            "ApplyDocking",
            "Talent Advisor Settings",
            "GetPetBuilds",
        ):
            self.assertIn(contract, source)

    def test_source_equivalent_compatibility_paths_are_loaded(self) -> None:
        toc = (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8")
        expected = (
            "Code-TBC/TalentAdvisor.lua",
            "Code-TBC/TalentAdvisor-Registering.lua",
            "Code-TBC/TalentAdvisor-Popout.xml",
        )
        for path in expected:
            self.assertIn(path.replace("/", "\\"), toc)
            self.assertTrue((ADDON / path).is_file())
        popout_xml = (ADDON / "Code-TBC" / "TalentAdvisor-Popout.xml").read_text(encoding="utf-8")
        self.assertIn('Script file="TalentAdvisor-Popout.lua"', popout_xml)
        self.assertNotIn("mixin=", popout_xml)
        self.assertNotIn("parentKey=", popout_xml)
        self.assertTrue((ADDON / "Code-TBC" / "TalentAdvisor-Popout.lua").is_file())

        registering = (ADDON / "Code-TBC" / "TalentAdvisor-Registering.lua").read_text(encoding="utf-8")
        facade = (ADDON / "Code-TBC" / "TalentAdvisor.lua").read_text(encoding="utf-8")
        popout = (ADDON / "Code-TBC" / "TalentAdvisor-Popout.lua").read_text(encoding="utf-8")
        self.assertIn("function Advisor:RegisterBuild", registering)
        self.assertIn("function Advisor:SetCurrentBuild", facade)
        self.assertIn("function Advisor:UpdateSuggestions", facade)
        self.assertIn("function _G.ZygorTalentAdvisorPopout_Toggle", popout)

    def test_talent_spending_remains_an_explicit_advisor_click(self) -> None:
        source = (ADDON / "ModernTalentAdvisor.lua").read_text(encoding="utf-8")
        self.assertNotIn("LearnTalent =", source)
        self.assertNotIn('PlayerTalentFrameLearnButton:SetScript("OnClick"', source)
        self.assertIn('learn:SetScript("OnClick"', source)
        self.assertIn("StaticPopup_Show", source)
        self.assertIn("Blizzard's Learn button", source)

    def test_settings_keybind_and_build_corpus_are_present(self) -> None:
        database = (ADDON / "Database.lua").read_text(encoding="utf-8")
        bindings = (ADDON / "Bindings.xml").read_text(encoding="utf-8")
        options = (ADDON / "Options.lua").read_text(encoding="utf-8")
        for key in ("enabled", "hints", "rankPreview", "docked", "autoOpen", "confirmLearn", "forceBuild"):
            self.assertRegex(database, rf"\b{re.escape(key)}\s*=")
        self.assertIn("ZYGORTALENTADVISOR_OPENPOPUP", bindings)
        self.assertIn('id="talents",label="Talent Advisor"', options)
        self.assertIn('action="talentAdvisor"', options)
        self.assertIn('path={"talent","rankPreview"}', options)

        builds = BUILDS.read_text(encoding="utf-8")
        registrations = re.findall(r'ZygorTalentAdvisor:RegisterBuild\("([A-Za-z ]+)"', builds)
        release = [name for name, title in re.findall(r'ZygorTalentAdvisor:RegisterBuild\("([A-Za-z ]+)","([^"]+)"', builds) if "debug" not in title.lower()]
        self.assertEqual(len(release), 67)
        self.assertTrue({"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}.issubset(set(registrations)))
        self.assertIn("PET Ferocity", registrations)
        self.assertIn("PET Tenacity", registrations)
        self.assertIn("PET Cunning", registrations)


if __name__ == "__main__":
    unittest.main()
