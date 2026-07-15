from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

import sys

TOOLS = Path(__file__).resolve().parents[1]
REPO = TOOLS.parent
REFERENCE_SOURCE = REPO / "ZygorGuidesViewerClassicTBCAnniv"
sys.path.insert(0, str(TOOLS))

from audit_port import audit  # noqa: E402


class PortAuditTests(unittest.TestCase):
    def make_tree(
        self,
        root: Path,
        source_files: dict[str, str],
        target_files: dict[str, str],
        rules: list[dict[str, object]],
        expected_source_files: int | None = None,
        target_toc_entries: list[str] | None = None,
    ) -> Path:
        source = root / "Source"
        target = root / "Bundle" / "Target"
        source.mkdir(parents=True)
        target.mkdir(parents=True)
        for relative, content in source_files.items():
            path = source / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
        for relative, content in target_files.items():
            path = target / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding="utf-8")
        if target_toc_entries is None:
            target_toc_entries = [
                relative for relative in target_files
                if Path(relative).suffix.lower() in {".lua", ".xml"}
            ]
        (target / "Target.toc").write_text(
            "## Interface: 30300\n" + "\n".join(target_toc_entries) + "\n",
            encoding="utf-8",
        )
        manifest = root / "manifest.json"
        manifest.write_text(json.dumps({
            "schema": 1,
            "source_root": "Source",
            "bundle_root": "Bundle",
            "expected_source_files": expected_source_files if expected_source_files is not None else len(source_files),
            "target_roots": ["Target"],
            "rules": rules,
        }), encoding="utf-8")
        return manifest

    def test_exact_payloads_are_automatic_and_adaptation_is_explicit(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"Exact.lua": "same", "Changed.lua": "old"},
                {"Moved.lua": "same", "Changed.lua": "new"},
                [{
                    "id": "adapt-changed",
                    "disposition": "adapted",
                    "reason": "client-specific rewrite",
                    "source_paths": ["Changed.lua"],
                    "replacement_targets": ["Target/Changed.lua"],
                }],
            )
            result = audit(root, manifest)
            self.assertEqual(result.issues, [])
            self.assertEqual(result.exact_payload_files, 1)
            self.assertEqual(result.exact_matches["Exact.lua"], ["Target/Moved.lua"])
            self.assertEqual(result.dispositions["adapted"], 1)
            self.assertEqual(result.accounted_files, 2)

    def test_unclassified_source_and_stale_rule_are_errors(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"Exact.lua": "same", "Unknown.lua": "source"},
                {"Exact.lua": "same", "Other.lua": "target"},
                [{
                    "id": "stale-exact-rule",
                    "disposition": "pending",
                    "reason": "this should be removed once exact",
                    "source_paths": ["Exact.lua"],
                }],
            )
            result = audit(root, manifest)
            codes = [issue.code for issue in result.issues]
            self.assertIn("SOURCE_UNCLASSIFIED", codes)
            self.assertIn("RULE_MATCHES_NOTHING", codes)

    def test_unloaded_identical_lua_and_xml_require_explicit_replacements(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {
                    "Dormant.lua": "return 'legacy'",
                    "Dormant.xml": '<Ui xmlns="http://www.blizzard.com/wow/ui/"/>',
                },
                {
                    "Reference/Dormant.lua": "return 'legacy'",
                    "Reference/Dormant.xml": '<Ui xmlns="http://www.blizzard.com/wow/ui/"/>',
                    "Runtime.lua": "return 'wotlk'",
                },
                [{
                    "id": "replace-dormant-runtime",
                    "disposition": "replaced",
                    "reason": "byte-identical reference files are deliberately not executable",
                    "source_paths": ["Dormant.lua", "Dormant.xml"],
                    "replacement_targets": ["Target/Runtime.lua"],
                }],
                target_toc_entries=["Runtime.lua"],
            )
            result = audit(root, manifest)
            self.assertEqual(result.issues, [])
            self.assertEqual(result.exact_payload_files, 0)
            self.assertEqual(result.dispositions["replaced"], 2)
            self.assertNotIn("Dormant.lua", result.exact_matches)
            self.assertNotIn("Dormant.xml", result.exact_matches)

    def test_unloaded_identical_executable_without_disposition_is_unclassified(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"Dormant.lua": "return 'same'"},
                {"Reference/Dormant.lua": "return 'same'", "Runtime.lua": "return true"},
                [],
                target_toc_entries=["Runtime.lua"],
            )
            result = audit(root, manifest)
            self.assertEqual(result.exact_payload_files, 0)
            self.assertIn("SOURCE_UNCLASSIFIED", [issue.code for issue in result.issues])

    def test_executable_replacement_must_be_in_the_load_closure(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"Changed.lua": "old"},
                {"Dormant.lua": "new", "Runtime.lua": "loaded"},
                [{
                    "id": "bad-dormant-replacement",
                    "disposition": "replaced",
                    "reason": "an unloaded successor is not a runtime replacement",
                    "source_paths": ["Changed.lua"],
                    "replacement_targets": ["Target/Dormant.lua"],
                }],
                target_toc_entries=["Runtime.lua"],
            )
            codes = [issue.code for issue in audit(root, manifest).issues]
            self.assertIn("REPLACEMENT_NOT_LOADED", codes)
            self.assertIn("RULE_EXECUTABLE_REPLACEMENT_REQUIRED", codes)

    def test_ambiguous_rules_are_errors(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"Code/Feature.lua": "source"},
                {"Main.lua": "target"},
                [
                    {
                        "id": "broad",
                        "disposition": "pending",
                        "reason": "broad pending group",
                        "source_globs": ["Code/**"],
                    },
                    {
                        "id": "specific",
                        "disposition": "pending",
                        "reason": "specific pending file",
                        "source_paths": ["Code/Feature.lua"],
                    },
                ],
            )
            result = audit(root, manifest)
            codes = [issue.code for issue in result.issues]
            self.assertIn("SOURCE_AMBIGUOUS", codes)
            self.assertEqual(codes.count("RULE_MATCHES_NOTHING"), 2)

    def test_missing_or_outside_replacement_is_an_error(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"Changed.lua": "source"},
                {"Other.lua": "target"},
                [{
                    "id": "bad-replacement",
                    "disposition": "replaced",
                    "reason": "replacement must exist in a configured root",
                    "source_paths": ["Changed.lua"],
                    "replacement_targets": ["NotTarget/Missing.lua", "Target/Missing.lua"],
                }],
            )
            codes = [issue.code for issue in audit(root, manifest).issues]
            self.assertIn("REPLACEMENT_OUTSIDE_TARGETS", codes)
            self.assertIn("REPLACEMENT_MISSING", codes)

    def test_source_inventory_count_drift_is_an_error(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = self.make_tree(
                root,
                {"One.lua": "source"},
                {"One.lua": "source"},
                [],
                expected_source_files=2,
            )
            self.assertIn("SOURCE_FILE_COUNT", [issue.code for issue in audit(root, manifest).issues])

    @unittest.skipUnless(REFERENCE_SOURCE.is_dir(), "requires the local Classic/TBC reference corpus")
    def test_repository_inventory_is_fully_classified(self) -> None:
        result = audit(REPO, TOOLS / "port_dispositions.json")
        self.assertEqual(result.issues, [])
        self.assertEqual(result.source_files, 864)
        self.assertEqual(result.accounted_files, result.source_files)
        self.assertGreater(result.exact_payload_files, 0)
        for disposition in ("adapted", "replaced", "intentional_exclusion"):
            self.assertGreater(result.dispositions[disposition], 0)
        self.assertEqual(result.dispositions["pending"], 0)

    @unittest.skipUnless(REFERENCE_SOURCE.is_dir(), "requires the local Classic/TBC reference corpus")
    def test_repository_dormant_viewer_sources_are_not_exact_runtime_ports(self) -> None:
        result = audit(REPO, TOOLS / "port_dispositions.json")
        expected_rule = "replace-unloaded-anniversary-skin-shell"
        for relative in (
            "Skins/Skins.xml",
            "Skins/Default/Skin.lua",
            "Skins/Default/Skin.xml",
            "Skins/Default/ViewerFrame.lua",
            "Skins/Default/ViewerFrame.xml",
            "Skins/Default/Midnight/Style.lua",
        ):
            self.assertNotIn(relative, result.exact_matches)
            self.assertEqual(result.classified_files.get(relative), expected_rule)


if __name__ == "__main__":
    unittest.main()
