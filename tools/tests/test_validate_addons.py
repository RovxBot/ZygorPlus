from __future__ import annotations

import json
import struct
import tempfile
import unittest
from pathlib import Path

import sys

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))

from package_release import collect_files, load_manifest, requires_live_parity, write_zip  # noqa: E402
from validate_addons import parse_texture, resolve_exact_case, validate  # noqa: E402
from export_zgv_diagnostics import diagnostics_entries, read_saved_variables, render  # noqa: E402
from check_release_parity import evaluate as evaluate_release_parity  # noqa: E402
from watch_zgv_diagnostics import export_once  # noqa: E402


class ValidatorTests(unittest.TestCase):
    def test_exact_case_resolution(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "Files.xml").write_text("<Ui></Ui>", encoding="utf-8")
            resolved, problem = resolve_exact_case(root, "Files.xml")
            self.assertEqual(resolved, root / "Files.xml")
            self.assertIsNone(problem)
            resolved, problem = resolve_exact_case(root, "files.xml")
            self.assertIsNone(resolved)
            self.assertIn("case mismatch", problem or "")

    def test_tga_dimensions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            texture = root / "sample.tga"
            header = bytearray(18)
            struct.pack_into("<HH", header, 12, 256, 128)
            texture.write_bytes(header)
            result = parse_texture(texture, root)
            self.assertEqual((result.width, result.height), (256, 128))
            self.assertTrue(result.power_of_two)

    def test_blp_dimensions_and_npot(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            texture = root / "sample.blp"
            header = bytearray(20)
            header[:4] = b"BLP2"
            struct.pack_into("<II", header, 12, 10, 5)
            texture.write_bytes(header)
            result = parse_texture(texture, root)
            self.assertEqual(result.format, "BLP2")
            self.assertEqual((result.width, result.height), (10, 5))
            self.assertFalse(result.power_of_two)

    def test_validation_catches_references_api_and_catalog(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            addon.mkdir()
            (addon / "Example.toc").write_text("## Interface: 30300\nFiles.xml\n", encoding="utf-8")
            (addon / "Files.xml").write_text('<Ui><Script file="Main.lua"/></Ui>\n', encoding="utf-8")
            (addon / "Main.lua").write_text(
                'local ignored = "C_Map" -- C_QuestLog\n'
                'local bad = C_Map\n'
                'frame:SetShown(true)\n'
                'button:SetEnabled(true)\n'
                'CooldownFrame_Set(cooldown, 0, 1, 1)\n'
                'local questID = GetQuestID()\n'
                'button:SetAttribute("type", "petaction")\n'
                'attributes.type="petaction"\n'
                'local secure = CreateFrame("Button", "Secure", UIParent, "SecureActionButtonTemplate")\n'
                'secure:SetScript("OnClick", function() end)\n'
                'ZGV.Compat.UI:SetShown(frame, true)\n'
                'ZGV.Compat.UI:SetEnabled(button, true)\n'
                'ZGV:RegisterGuide("One",{},[[\nnext Missing\n]])\n'
                'ZGV:RegisterGuide("Tag test",{},[[\ncollect Test |unhandledtag value\n]])\n'
                'ZGV:RegisterGuide("One",{},[[]])\n',
                encoding="utf-8",
            )
            result = validate(root, ["Example"])
            codes = [issue.code for issue in result.issues]
            self.assertIn("C_NAMESPACE", codes)
            self.assertIn("GUIDE_DUPLICATE", codes)
            self.assertIn("GUIDE_UNRESOLVED", codes)
            self.assertIn("GUIDE_UNSUPPORTED_TAG", codes)
            self.assertEqual(codes.count("C_NAMESPACE"), 1)
            self.assertEqual(codes.count("POST_WRATH_WIDGET_API"), 2)
            self.assertEqual(codes.count("POST_WRATH_COOLDOWN_API"), 1)
            self.assertEqual(codes.count("POST_WRATH_QUEST_API"), 1)
            self.assertEqual(codes.count("POST_WRATH_SECURE_ACTION"), 2)
            self.assertEqual(codes.count("SECURE_ONCLICK_OVERRIDE"), 1)

    def test_release_whitelist_excludes_dev_files(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            (addon / "Dev").mkdir(parents=True)
            (addon / "@eaDir").mkdir()
            (addon / "Example.toc").write_text("## Interface: 30300\nMain.lua\n", encoding="utf-8")
            (addon / "Main.lua").write_text("return\n", encoding="utf-8")
            (addon / "Dev" / "Probe.lua").write_text("return\n", encoding="utf-8")
            (addon / "@eaDir" / "junk").write_text("junk", encoding="utf-8")
            manifest_path = root / "release.json"
            manifest_path.write_text(json.dumps({
                "schema": 1,
                "name": "Example",
                "version": "test",
                "addon_roots": ["Example"],
                "exclude_globs": ["*/Dev/*"],
            }), encoding="utf-8")
            manifest = load_manifest(manifest_path)
            self.assertEqual(manifest["release_channel"], "stable")
            selected = [name for _, name in collect_files(root, manifest)]
            self.assertEqual(selected, ["Example/Example.toc", "Example/Main.lua"])

    def test_release_channel_controls_live_parity_requirement(self) -> None:
        self.assertTrue(requires_live_parity({"release_channel": "stable"}))
        self.assertFalse(requires_live_parity({"release_channel": "alpha"}))

    def test_invalid_release_channel_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            manifest_path = Path(temporary) / "release.json"
            manifest_path.write_text(json.dumps({
                "schema": 1,
                "name": "Example",
                "version": "1.0.0",
                "release_channel": "preview",
                "addon_roots": ["Example"],
            }), encoding="utf-8")
            with self.assertRaisesRegex(SystemExit, "release_channel"):
                load_manifest(manifest_path)

    def test_validation_uses_release_exclusions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            (addon / "Imported").mkdir(parents=True)
            (addon / "Example.toc").write_text("## Interface: 30300\nMain.lua\n", encoding="utf-8")
            (addon / "Main.lua").write_text("return\n", encoding="utf-8")
            (addon / "Imported" / "Retail.lua").write_text("C_Item.GetItemInfo(1)\n", encoding="utf-8")
            result = validate(root, ["Example"], exclude_globs=["Example/Imported/*"])
            self.assertNotIn("C_NAMESPACE", [issue.code for issue in result.issues])
            self.assertEqual(result.stats["lua_files"], 1)

    def test_catalog_runtime_groups_allow_faction_alternatives(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for addon_name in ("Core", "Alliance", "Horde"):
                addon = root / addon_name
                addon.mkdir()
                (addon / f"{addon_name}.toc").write_text("## Interface: 30300\nMain.lua\n", encoding="utf-8")
                guide = 'ZGV:RegisterGuide("Shared title",{},[[]])\n' if addon_name != "Core" else "return\n"
                (addon / "Main.lua").write_text(guide, encoding="utf-8")
            result = validate(root, ["Core", "Alliance", "Horde"], catalog_groups=[
                ["Core", "Alliance"],
                ["Core", "Horde"],
            ])
            self.assertNotIn("GUIDE_DUPLICATE", [issue.code for issue in result.issues])

    def test_malformed_xml_is_an_error(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            addon.mkdir()
            (addon / "Example.toc").write_text("## Interface: 30300\nBad.xml\n", encoding="utf-8")
            (addon / "Bad.xml").write_text("<Ui><Frame></Ui>", encoding="utf-8")
            result = validate(root, ["Example"])
            self.assertIn("XML_PARSE", [issue.code for issue in result.issues])

    def test_required_dependency_must_be_whitelisted(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            addon.mkdir()
            (addon / "Example.toc").write_text(
                "## Interface: 30300\n## RequiredDeps: MissingLibrary\nMain.lua\n",
                encoding="utf-8",
            )
            (addon / "Main.lua").write_text("return\n", encoding="utf-8")
            result = validate(root, ["Example"])
            self.assertIn("DEPENDENCY_NOT_WHITELISTED", [issue.code for issue in result.issues])

    def test_deterministic_zip(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "Main.lua"
            source.write_text("return\n", encoding="utf-8")
            first = root / "first.zip"
            second = root / "second.zip"
            first_hash, _ = write_zip(first, [(source, "Example/Main.lua")])
            second_hash, _ = write_zip(second, [(source, "Example/Main.lua")])
            self.assertEqual(first_hash, second_hash)
            self.assertEqual(first.read_bytes(), second.read_bytes())

    def test_registration_filter_models_runtime_catalog(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            addon.mkdir()
            (addon / "Example.toc").write_text("## Interface: 30300\nGuides.lua\n", encoding="utf-8")
            (addon / "Guides.lua").write_text(
                'ZGV:RegisterGuide("Old one",{},[[\nnext Missing old guide\n]])\n'
                'ZGV:RegisterGuide("Keep one",{},[[\nnext Keep two\n]])\n'
                'ZGV:RegisterGuide("Keep two",{},[[]])\n',
                encoding="utf-8",
            )
            result = validate(root, ["Example"], guide_filters=[{
                "glob": "Example/Guides.lua",
                "title_prefix": "Keep ",
                "expected": 2,
            }])
            codes = [issue.code for issue in result.issues]
            self.assertNotIn("GUIDE_UNRESOLVED", codes)
            self.assertEqual(result.stats["guides"], 2)
            self.assertEqual(result.stats["guides_filtered"], 1)

    def test_registration_filter_can_limit_first_title_segment(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            addon = root / "Example"
            addon.mkdir()
            (addon / "Example.toc").write_text("## Interface: 30300\nDailies.lua\n", encoding="utf-8")
            (addon / "Dailies.lua").write_text(
                'ZGV:RegisterGuide("Dailies\\\\Keep\\\\One",{},[[\nnext Dailies\\Keep\\Two\n]])\n'
                'ZGV:RegisterGuide("Dailies\\\\Other\\\\Hidden",{},[[\nnext Missing hidden guide\n]])\n'
                'ZGV:RegisterGuide("Dailies\\\\Keep\\\\Two",{},[[]])\n',
                encoding="utf-8",
            )
            result = validate(root, ["Example"], guide_filters=[{
                "glob": "Example/Dailies.lua",
                "title_prefix": "Dailies\\",
                "allowed_first_segments": ["Keep"],
                "expected": 2,
            }])
            codes = [issue.code for issue in result.issues]
            self.assertNotIn("GUIDE_UNRESOLVED", codes)
            self.assertNotIn("GUIDE_FILTER_COUNT", codes)
            self.assertEqual([entry["title"] for entry in result.catalog["guides"]], [
                "Dailies\\Keep\\One",
                "Dailies\\Keep\\Two",
            ])

    def test_diagnostics_export_reads_saved_variable_table(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary) / "ZygorGuidesViewer.lua"
            source.write_text(
                'ZygorGuidesViewerWotLKSettings = {\n'
                '  ["global"] = { ["diagnostics"] = { ["entries"] = {\n'
                '    { ["time"] = "2026-07-12 10:00:00", ["level"] = "info", ["context"] = "guide", ["message"] = "selected\\nA guide" },\n'
                '  } } }\n'
                '}\n',
                encoding="utf-8",
            )
            entries = diagnostics_entries(read_saved_variables(source))
            self.assertEqual(len(entries), 1)
            self.assertEqual(entries[0]["message"], "selected\nA guide")
            report = render(entries, source)
            self.assertIn("[info] guide: selected\nA guide", report)

    def test_diagnostics_watcher_exports_atomically(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "ZygorGuidesViewer.lua"
            output = root / "Logs" / "ZygorGuidesViewer.log"
            source.write_text(
                'ZygorGuidesViewerWotLKSettings = { global = { diagnostics = { currentSession = "s", entries = {\n'
                '  { session = "s", time = "now", level = "info", context = "sync", message = "ok", correlation = "s:1" },\n'
                '} } } }\n',
                encoding="utf-8",
            )
            self.assertEqual(export_once(source, output), 1)
            text = output.read_text(encoding="utf-8")
            self.assertIn("correlation=s:1", text)
            self.assertFalse(list(output.parent.glob(f".{output.name}.*")))

    def test_release_parity_registry_requires_live_evidence_only_at_release(self) -> None:
        registry = TOOLS / "release_parity.json"
        self.assertEqual(evaluate_release_parity(registry, require_live=False), [])
        errors = evaluate_release_parity(registry, require_live=True)
        self.assertTrue(any("live acceptance is pending" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
