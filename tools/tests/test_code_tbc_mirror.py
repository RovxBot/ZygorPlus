from __future__ import annotations

import json
import re
import shutil
import subprocess
import unittest
import xml.etree.ElementTree as ElementTree
from pathlib import Path


REPO = Path(__file__).resolve().parents[2]
ADDON = REPO / "ZygorGuidesViewer" / "ZygorGuidesViewer"
SOURCE = REPO / "ZygorGuidesViewerClassicTBCAnniv" / "Code-TBC"
MIRROR = ADDON / "Code-TBC"
MANIFEST = REPO / "tools" / "port_dispositions.json"
ASSIGNED = (
    "Faction.lua",
    "Goal.lua",
    "InitialFlightPaths.lua",
    "Item-DataTables.lua",
    "Item-GearFinder.lua",
    "Item-ItemScore.lua",
    "PointerMap.lua",
    "Profession.lua",
    "QuestAutoAccept.lua",
    "QuestDB.lua",
    "QuestTracking.lua",
)
LOAD_ORDER = (
    "QuestTracking.lua",
    "Faction.lua",
    "Profession.lua",
    "QuestAutoAccept.lua",
    "QuestDB.lua",
    "Goal.lua",
    "PointerMap.lua",
    "Item-DataTables.lua",
    "Item-ItemScore.lua",
    "Item-GearFinder.lua",
    "InitialFlightPaths.lua",
)


def load_closure() -> set[str]:
    pending = [
        line.strip().replace("\\", "/")
        for line in (ADDON / "ZygorGuidesViewer.toc").read_text(encoding="utf-8-sig").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]
    loaded: set[str] = set()
    while pending:
        relative = pending.pop(0)
        if relative in loaded:
            continue
        path = ADDON / relative
        if not path.is_file():
            raise AssertionError(f"load closure references missing file: {relative}")
        loaded.add(relative)
        if path.suffix.lower() != ".xml":
            continue
        root = ElementTree.fromstring(path.read_text(encoding="utf-8-sig"))
        for element in root.iter():
            if element.tag.rsplit("}", 1)[-1] not in {"Script", "Include"}:
                continue
            child = element.attrib.get("file")
            if child:
                pending.append((Path(relative).parent / child.replace("\\", "/")).as_posix())
    return loaded


@unittest.skipUnless(SOURCE.is_dir(), "requires the local Classic/TBC reference corpus")
class CodeTBCMirrorTests(unittest.TestCase):
    def test_all_assigned_source_paths_have_loaded_same_path_shims(self) -> None:
        closure = load_closure()
        self.assertIn("Code-TBC/files.xml", closure)
        for name in ASSIGNED:
            self.assertTrue((SOURCE / name).is_file(), name)
            self.assertTrue((MIRROR / name).is_file(), name)
            self.assertIn(f"Code-TBC/{name}", closure, name)

    def test_nested_manifest_preserves_upstream_load_order(self) -> None:
        root = ElementTree.fromstring((MIRROR / "files.xml").read_text(encoding="utf-8"))
        scripts = [
            element.attrib["file"].replace("\\", "/")
            for element in root.iter()
            if element.tag.rsplit("}", 1)[-1] == "Script" and "file" in element.attrib
        ]
        self.assertEqual(scripts, list(LOAD_ORDER))
        self.assertFalse(any(name.startswith("TalentAdvisor") for name in scripts))

    def test_shims_do_not_register_duplicate_modules_or_use_modern_namespaces(self) -> None:
        forbidden = ("RegisterModule", "C_QuestLog", "C_Spell", "CreateFromMixins", "SetAtlas", "GetSpecialization")
        for name in ASSIGNED:
            text = (MIRROR / name).read_text(encoding="utf-8")
            for token in forbidden:
                self.assertNotIn(token, text, (name, token))

    def test_every_explicit_source_method_remains_callable(self) -> None:
        target_files = {
            "Faction.lua": (ADDON / "Faction.lua", MIRROR / "Faction.lua"),
            "Goal.lua": (ADDON / "Goal.lua", MIRROR / "Goal.lua"),
            "Item-GearFinder.lua": (ADDON / "Item-GearFinder.lua", MIRROR / "Item-GearFinder.lua"),
            "Item-ItemScore.lua": (ADDON / "Item-ItemScore.lua", MIRROR / "Item-ItemScore.lua"),
            "PointerMap.lua": (ADDON / "DungeonPreview.lua", MIRROR / "PointerMap.lua"),
            "Profession.lua": (ADDON / "Compat/Profession.lua", MIRROR / "Profession.lua"),
            "QuestAutoAccept.lua": (ADDON / "QuestAutoAccept.lua", MIRROR / "QuestAutoAccept.lua"),
            "QuestDB.lua": (ADDON / "QuestDB.lua", MIRROR / "QuestDB.lua"),
            "QuestTracking.lua": (ADDON / "QuestTracking.lua", MIRROR / "QuestTracking.lua"),
        }
        public_receivers = {
            "Faction.lua": {"Faction"}, "Goal.lua": {"Goal"}, "Item-GearFinder.lua": {"GearFinder"},
            "Item-ItemScore.lua": {"ItemScore"}, "PointerMap.lua": {"PointerMap"},
            "Profession.lua": {"ZGV", "ZGVP"}, "QuestAutoAccept.lua": {"ZGV"},
            "QuestDB.lua": {"QuestDB"}, "QuestTracking.lua": {"ZGV"},
        }
        definition = re.compile(r"\bfunction\s+([A-Za-z_][\w.]*)[.:]([A-Za-z_]\w*)\s*\(")
        alias = re.compile(r"\b[A-Za-z_][\w.]*\.([A-Za-z_]\w*)\s*=\s*[A-Za-z_][\w.]*")
        for source_name, candidates in target_files.items():
            source_methods = {
                method for receiver, method in definition.findall((SOURCE / source_name).read_text(encoding="utf-8"))
                if receiver in public_receivers[source_name]
            }
            target_text = "\n".join(path.read_text(encoding="utf-8") for path in candidates)
            target_methods = {method for _, method in definition.findall(target_text)} | set(alias.findall(target_text))
            self.assertEqual(source_methods - target_methods, set(), source_name)

    def test_audit_rules_name_each_loaded_same_path_replacement(self) -> None:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        for name in ASSIGNED:
            source = f"Code-TBC/{name}"
            matches = [rule for rule in manifest["rules"] if source in rule.get("source_paths", [])]
            self.assertEqual(len(matches), 1, source)
            self.assertIn(f"ZygorGuidesViewer/{source}", matches[0].get("replacement_targets", []), source)

    def test_lua_facades_delegate_to_root_services(self) -> None:
        lua = shutil.which("lua5.1") or shutil.which("lua") or "/tmp/lua51-bin/lua5.1"
        if not Path(lua).is_file() and not shutil.which(lua):
            self.skipTest("Lua 5.1 interpreter is unavailable")
        completed = subprocess.run(
            [lua, str(REPO / "tools/tests/lua/test_code_tbc_mirror.lua"), str(REPO)],
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stdout + completed.stderr)
        self.assertIn("Code-TBC mirror compatibility tests passed", completed.stdout)


if __name__ == "__main__":
    unittest.main()
