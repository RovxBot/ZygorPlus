#!/usr/bin/env python3
"""Audit the Classic TBC Anniversary source-to-WotLK port inventory.

The audit is read-only.  Byte-identical payloads are discovered automatically
across every configured target addon.  Every remaining source file must match
exactly one explicit disposition rule in ``port_dispositions.json``.
"""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import xml.etree.ElementTree as ElementTree
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path, PurePosixPath
from typing import Sequence


ALLOWED_DISPOSITIONS = {
    "adapted",
    "replaced",
    "intentional_exclusion",
    "pending",
}

EXECUTABLE_SOURCE_SUFFIXES = {".lua", ".xml"}
EXECUTABLE_TARGET_SUFFIXES = {".lua", ".xml", ".toc"}


@dataclass(frozen=True)
class AuditIssue:
    code: str
    path: str
    message: str
    rule: str | None = None


@dataclass
class PortAuditResult:
    source_root: str
    target_roots: list[str]
    source_files: int
    target_files: int
    exact_payload_files: int
    dispositions: dict[str, int]
    rules: int
    matched_rules: int
    issues: list[AuditIssue]
    exact_matches: dict[str, list[str]]
    classified_files: dict[str, str]

    @property
    def errors(self) -> int:
        return len(self.issues)

    @property
    def pending(self) -> int:
        return self.dispositions.get("pending", 0)

    @property
    def accounted_files(self) -> int:
        return self.exact_payload_files + sum(self.dispositions.values())

    def to_json(self) -> dict[str, object]:
        return {
            "schema": 1,
            "source_root": self.source_root,
            "target_roots": self.target_roots,
            "summary": {
                "errors": self.errors,
                "source_files": self.source_files,
                "target_files": self.target_files,
                "accounted_files": self.accounted_files,
                "exact_payload": self.exact_payload_files,
                **self.dispositions,
                "rules": self.rules,
                "matched_rules": self.matched_rules,
            },
            "issues": [asdict(issue) for issue in self.issues],
            "exact_matches": self.exact_matches,
            "classified_files": self.classified_files,
        }


def _safe_relative(value: object, field: str) -> tuple[str | None, str | None]:
    if not isinstance(value, str) or not value.strip():
        return None, f"{field} must be a non-empty string"
    normalised = value.strip().replace("\\", "/")
    candidate = PurePosixPath(normalised)
    if candidate.is_absolute() or ".." in candidate.parts:
        return None, f"{field} must be a safe relative path"
    return candidate.as_posix(), None


def _resolve_exact_case(base: Path, relative: str) -> tuple[Path | None, str | None]:
    current = base
    for part in PurePosixPath(relative).parts:
        if not current.is_dir():
            return None, f"parent directory does not exist: {current}"
        try:
            entries = {entry.name: entry for entry in current.iterdir()}
        except OSError as exc:
            return None, f"cannot inspect parent directory: {exc}"
        if part in entries:
            current = entries[part]
            continue
        folded = sorted(name for name in entries if name.casefold() == part.casefold())
        if folded:
            return None, f"case mismatch: referenced '{part}', disk has '{folded[0]}'"
        return None, f"missing path component '{part}'"
    return current, None


def _files(root: Path) -> list[Path]:
    return sorted(
        (path for path in root.rglob("*") if path.is_file()),
        key=lambda path: path.relative_to(root).as_posix(),
    )


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _target_load_closure(target_name: str, target_root: Path) -> tuple[set[str], list[AuditIssue]]:
    """Resolve files actually reachable from an addon's TOC/XML load graph."""
    issues: list[AuditIssue] = []
    loaded: set[str] = set()
    pending: list[str] = []
    toc_relative = f"{PurePosixPath(target_name).name}.toc"
    toc_path, problem = _resolve_exact_case(target_root, toc_relative)
    if problem or toc_path is None or not toc_path.is_file():
        issues.append(AuditIssue(
            "TARGET_TOC_MISSING",
            f"{target_name}/{toc_relative}",
            problem or "target addon TOC is missing",
        ))
        return loaded, issues

    loaded.add(f"{target_name}/{toc_relative}")
    try:
        toc_lines = toc_path.read_text(encoding="utf-8-sig").splitlines()
    except (OSError, UnicodeError) as exc:
        issues.append(AuditIssue("TARGET_TOC_READ", f"{target_name}/{toc_relative}", str(exc)))
        return loaded, issues
    for raw_line in toc_lines:
        line = raw_line.strip()
        if line and not line.startswith("#"):
            pending.append(line.replace("\\", "/"))

    # WoW discovers Bindings.xml by its reserved name even when it is not a
    # literal TOC entry.
    bindings, bindings_problem = _resolve_exact_case(target_root, "Bindings.xml")
    if not bindings_problem and bindings is not None and bindings.is_file():
        pending.append("Bindings.xml")

    inspected: set[str] = set()
    while pending:
        raw_relative = pending.pop(0)
        relative, invalid = _safe_relative(raw_relative, "target load entry")
        if invalid or relative is None:
            issues.append(AuditIssue(
                "TARGET_LOAD_PATH_INVALID",
                f"{target_name}/{raw_relative}",
                invalid or "invalid load path",
            ))
            continue
        if relative in inspected:
            continue
        inspected.add(relative)
        resolved, resolution_problem = _resolve_exact_case(target_root, relative)
        target_relative = f"{target_name}/{relative}"
        if resolution_problem or resolved is None or not resolved.is_file():
            issues.append(AuditIssue(
                "TARGET_LOAD_MISSING",
                target_relative,
                resolution_problem or "TOC/XML load target is missing",
            ))
            continue
        loaded.add(target_relative)
        if resolved.suffix.lower() != ".xml":
            continue
        try:
            root = ElementTree.fromstring(resolved.read_text(encoding="utf-8-sig"))
        except (OSError, UnicodeError, ElementTree.ParseError) as exc:
            issues.append(AuditIssue("TARGET_LOAD_XML", target_relative, str(exc)))
            continue
        parent = PurePosixPath(relative).parent
        for element in root.iter():
            if element.tag.rsplit("}", 1)[-1] not in {"Script", "Include"}:
                continue
            child = element.attrib.get("file")
            if child:
                pending.append((parent / PurePosixPath(child.replace("\\", "/"))).as_posix())
    return loaded, issues


def _rule_matches(relative: str, rule: dict[str, object]) -> bool:
    paths = rule.get("source_paths", [])
    globs = rule.get("source_globs", [])
    return relative in paths or any(
        isinstance(pattern, str) and fnmatch.fnmatchcase(relative, pattern)
        for pattern in globs
    )


def _load_manifest(path: Path) -> tuple[dict[str, object] | None, list[AuditIssue]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        return None, [AuditIssue("MANIFEST_READ", path.as_posix(), str(exc))]
    if not isinstance(data, dict):
        return None, [AuditIssue("MANIFEST_TYPE", path.as_posix(), "manifest root must be an object")]
    if data.get("schema") != 1:
        return None, [AuditIssue("MANIFEST_SCHEMA", path.as_posix(), "schema must be 1")]
    return data, []


def audit(repo_root: Path, manifest_path: Path) -> PortAuditResult:
    """Return a complete source inventory audit without modifying the tree."""
    repo_root = repo_root.resolve()
    manifest, issues = _load_manifest(manifest_path)
    if manifest is None:
        return PortAuditResult("", [], 0, 0, 0, {}, 0, 0, issues, {}, {})

    source_value, problem = _safe_relative(manifest.get("source_root"), "source_root")
    if problem:
        issues.append(AuditIssue("SOURCE_ROOT_INVALID", str(manifest_path), problem))
        source_value = ""
    bundle_value, problem = _safe_relative(manifest.get("bundle_root"), "bundle_root")
    if problem:
        issues.append(AuditIssue("BUNDLE_ROOT_INVALID", str(manifest_path), problem))
        bundle_value = ""

    source_root = repo_root / (source_value or "__invalid_source__")
    bundle_root = repo_root / (bundle_value or "__invalid_bundle__")
    if not source_root.is_dir():
        issues.append(AuditIssue("SOURCE_ROOT_MISSING", source_value or "", "source root is not a directory"))
    if not bundle_root.is_dir():
        issues.append(AuditIssue("BUNDLE_ROOT_MISSING", bundle_value or "", "bundle root is not a directory"))

    target_values = manifest.get("target_roots")
    if not isinstance(target_values, list) or not target_values:
        issues.append(AuditIssue("TARGET_ROOTS_INVALID", str(manifest_path), "target_roots must be a non-empty list"))
        target_values = []
    target_roots: list[tuple[str, Path]] = []
    seen_target_names: set[str] = set()
    for raw_target in target_values:
        target, invalid = _safe_relative(raw_target, "target_roots entry")
        if invalid:
            issues.append(AuditIssue("TARGET_ROOT_INVALID", str(raw_target), invalid))
            continue
        assert target is not None
        if target in seen_target_names:
            issues.append(AuditIssue("TARGET_ROOT_DUPLICATE", target, "target root is declared more than once"))
            continue
        seen_target_names.add(target)
        resolved, resolution_problem = _resolve_exact_case(bundle_root, target) if bundle_root.is_dir() else (None, "bundle root missing")
        if resolution_problem or resolved is None or not resolved.is_dir():
            issues.append(AuditIssue("TARGET_ROOT_MISSING", target, resolution_problem or "target root is not a directory"))
            continue
        target_roots.append((target, resolved))

    source_files = _files(source_root) if source_root.is_dir() else []
    source_by_relative = {path.relative_to(source_root).as_posix(): path for path in source_files}
    expected_source_files = manifest.get("expected_source_files")
    if not isinstance(expected_source_files, int) or expected_source_files < 0:
        issues.append(AuditIssue("EXPECTED_SOURCE_FILES_INVALID", str(manifest_path), "expected_source_files must be a non-negative integer"))
    elif len(source_files) != expected_source_files:
        issues.append(AuditIssue(
            "SOURCE_FILE_COUNT",
            source_value or "",
            f"expected {expected_source_files} source files, found {len(source_files)}",
        ))

    target_files: list[tuple[str, Path]] = []
    loaded_target_files: set[str] = set()
    for target_name, target_root in target_roots:
        closure, closure_issues = _target_load_closure(target_name, target_root)
        loaded_target_files.update(closure)
        issues.extend(closure_issues)
        for path in _files(target_root):
            target_files.append((f"{target_name}/{path.relative_to(target_root).as_posix()}", path))

    target_hashes: dict[str, list[str]] = defaultdict(list)
    for relative, path in target_files:
        try:
            target_hashes[_sha256(path)].append(relative)
        except OSError as exc:
            issues.append(AuditIssue("TARGET_FILE_READ", relative, str(exc)))

    exact_matches: dict[str, list[str]] = {}
    requires_disposition: dict[str, Path] = {}
    for relative, path in source_by_relative.items():
        try:
            matches = target_hashes.get(_sha256(path), [])
        except OSError as exc:
            issues.append(AuditIssue("SOURCE_FILE_READ", relative, str(exc)))
            continue
        if path.suffix.lower() in EXECUTABLE_SOURCE_SUFFIXES:
            # A dormant byte-for-byte copy is reference material, not a
            # runtime port.  Lua/XML only qualifies as automatic `exact` when
            # the matching target is reachable from the addon's real load
            # graph.
            loadable_matches = [match for match in matches if match in loaded_target_files]
        else:
            loadable_matches = matches
        if loadable_matches:
            exact_matches[relative] = sorted(loadable_matches)
        else:
            requires_disposition[relative] = path

    raw_rules = manifest.get("rules")
    if not isinstance(raw_rules, list):
        issues.append(AuditIssue("RULES_INVALID", str(manifest_path), "rules must be a list"))
        raw_rules = []

    valid_rules: list[dict[str, object]] = []
    seen_rule_ids: set[str] = set()
    for index, raw_rule in enumerate(raw_rules, 1):
        if not isinstance(raw_rule, dict):
            issues.append(AuditIssue("RULE_TYPE", str(manifest_path), f"rule {index} must be an object"))
            continue
        rule_id = raw_rule.get("id")
        if not isinstance(rule_id, str) or not rule_id.strip():
            issues.append(AuditIssue("RULE_ID", str(manifest_path), f"rule {index} requires a non-empty id"))
            continue
        if rule_id in seen_rule_ids:
            issues.append(AuditIssue("RULE_ID_DUPLICATE", str(manifest_path), "rule id is duplicated", rule_id))
            continue
        seen_rule_ids.add(rule_id)
        disposition = raw_rule.get("disposition")
        if disposition not in ALLOWED_DISPOSITIONS:
            issues.append(AuditIssue(
                "RULE_DISPOSITION",
                str(manifest_path),
                f"disposition must be one of {', '.join(sorted(ALLOWED_DISPOSITIONS))}",
                rule_id,
            ))
            continue
        reason = raw_rule.get("reason")
        if not isinstance(reason, str) or not reason.strip():
            issues.append(AuditIssue("RULE_REASON", str(manifest_path), "rule requires a non-empty reason", rule_id))

        paths = raw_rule.get("source_paths", [])
        globs = raw_rule.get("source_globs", [])
        if not isinstance(paths, list) or not all(isinstance(value, str) for value in paths):
            issues.append(AuditIssue("RULE_PATHS", str(manifest_path), "source_paths must be a list of strings", rule_id))
            paths = []
        if not isinstance(globs, list) or not all(isinstance(value, str) for value in globs):
            issues.append(AuditIssue("RULE_GLOBS", str(manifest_path), "source_globs must be a list of strings", rule_id))
            globs = []
        if not paths and not globs:
            issues.append(AuditIssue("RULE_MATCHERS", str(manifest_path), "rule requires source_paths or source_globs", rule_id))

        normalised_paths: list[str] = []
        for raw_path in paths:
            relative, invalid = _safe_relative(raw_path, "source_paths entry")
            if invalid:
                issues.append(AuditIssue("RULE_SOURCE_PATH_INVALID", raw_path, invalid, rule_id))
                continue
            assert relative is not None
            normalised_paths.append(relative)
            if relative not in source_by_relative:
                issues.append(AuditIssue("RULE_SOURCE_PATH_MISSING", relative, "declared source path does not exist with exact case", rule_id))

        normalised_globs: list[str] = []
        for raw_glob in globs:
            relative, invalid = _safe_relative(raw_glob, "source_globs entry")
            if invalid:
                issues.append(AuditIssue("RULE_SOURCE_GLOB_INVALID", raw_glob, invalid, rule_id))
                continue
            assert relative is not None
            normalised_globs.append(relative)
            if not any(fnmatch.fnmatchcase(source, relative) for source in source_by_relative):
                issues.append(AuditIssue("RULE_SOURCE_GLOB_EMPTY", relative, "glob matches no source file", rule_id))

        replacement_targets = raw_rule.get("replacement_targets", [])
        if not isinstance(replacement_targets, list) or not all(isinstance(value, str) for value in replacement_targets):
            issues.append(AuditIssue("RULE_REPLACEMENTS", str(manifest_path), "replacement_targets must be a list of strings", rule_id))
            replacement_targets = []
        if disposition in {"adapted", "replaced"} and not replacement_targets:
            issues.append(AuditIssue("RULE_REPLACEMENT_REQUIRED", str(manifest_path), "adapted/replaced rules require replacement_targets", rule_id))
        if disposition in {"pending", "intentional_exclusion"} and replacement_targets:
            issues.append(AuditIssue(
                "RULE_REPLACEMENT_NOT_ALLOWED",
                str(manifest_path),
                "pending/intentional_exclusion rules must not assert replacement targets",
                rule_id,
            ))
        normalised_replacements: list[str] = []
        loaded_executable_replacement = False
        for raw_replacement in replacement_targets:
            replacement, invalid = _safe_relative(raw_replacement, "replacement_targets entry")
            if invalid:
                issues.append(AuditIssue("REPLACEMENT_INVALID", raw_replacement, invalid, rule_id))
                continue
            assert replacement is not None
            normalised_replacements.append(replacement)
            first_part = PurePosixPath(replacement).parts[0] if PurePosixPath(replacement).parts else ""
            if first_part not in seen_target_names:
                issues.append(AuditIssue("REPLACEMENT_OUTSIDE_TARGETS", replacement, "replacement is outside configured target roots", rule_id))
                continue
            resolved, resolution_problem = _resolve_exact_case(bundle_root, replacement) if bundle_root.is_dir() else (None, "bundle root missing")
            if resolution_problem or resolved is None or not resolved.exists():
                issues.append(AuditIssue("REPLACEMENT_MISSING", replacement, resolution_problem or "replacement does not exist", rule_id))
                continue
            if resolved.suffix.lower() in EXECUTABLE_TARGET_SUFFIXES:
                if replacement not in loaded_target_files:
                    issues.append(AuditIssue(
                        "REPLACEMENT_NOT_LOADED",
                        replacement,
                        "executable replacement is absent from the target TOC/XML load closure",
                        rule_id,
                    ))
                else:
                    loaded_executable_replacement = True

        matched_source_paths = [
            source for source in source_by_relative
            if _rule_matches(source, {"source_paths": normalised_paths, "source_globs": normalised_globs})
        ]
        if disposition in {"adapted", "replaced"} and any(
            source_by_relative[source].suffix.lower() in EXECUTABLE_SOURCE_SUFFIXES
            for source in matched_source_paths
        ) and not loaded_executable_replacement:
            issues.append(AuditIssue(
                "RULE_EXECUTABLE_REPLACEMENT_REQUIRED",
                str(manifest_path),
                "Lua/XML source dispositions require at least one executable replacement in the target load closure",
                rule_id,
            ))

        rule = dict(raw_rule)
        rule["source_paths"] = normalised_paths
        rule["source_globs"] = normalised_globs
        rule["replacement_targets"] = normalised_replacements
        valid_rules.append(rule)

    matches_by_rule: Counter[str] = Counter()
    classified_files: dict[str, str] = {}
    disposition_counts: Counter[str] = Counter()
    for relative in sorted(requires_disposition):
        matching = [rule for rule in valid_rules if _rule_matches(relative, rule)]
        if not matching:
            issues.append(AuditIssue(
                "SOURCE_UNCLASSIFIED",
                relative,
                "source file is not a loadable exact payload and has no disposition rule",
            ))
            continue
        if len(matching) > 1:
            ids = ", ".join(str(rule["id"]) for rule in matching)
            issues.append(AuditIssue("SOURCE_AMBIGUOUS", relative, f"matches multiple disposition rules: {ids}"))
            continue
        rule = matching[0]
        rule_id = str(rule["id"])
        disposition = str(rule["disposition"])
        matches_by_rule[rule_id] += 1
        classified_files[relative] = rule_id
        disposition_counts[disposition] += 1

    for rule in valid_rules:
        rule_id = str(rule["id"])
        if not matches_by_rule[rule_id]:
            issues.append(AuditIssue(
                "RULE_MATCHES_NOTHING",
                str(manifest_path),
                "rule matches no source file requiring disposition; remove or update the stale rule",
                rule_id,
            ))

    return PortAuditResult(
        source_root=source_value or "",
        target_roots=[name for name, _ in target_roots],
        source_files=len(source_files),
        target_files=len(target_files),
        exact_payload_files=len(exact_matches),
        dispositions={name: disposition_counts.get(name, 0) for name in sorted(ALLOWED_DISPOSITIONS)},
        rules=len(raw_rules),
        matched_rules=len(matches_by_rule),
        issues=issues,
        exact_matches=exact_matches,
        classified_files=classified_files,
    )


def _summary(result: PortAuditResult) -> str:
    status = "PASS" if not result.errors else "FAIL"
    values = " ".join(
        f"{name}={result.dispositions.get(name, 0)}"
        for name in ("adapted", "replaced", "intentional_exclusion", "pending")
    )
    return (
        f"Port audit: {status} errors={result.errors} source={result.source_files} "
        f"accounted={result.accounted_files} exact={result.exact_payload_files} "
        f"{values} target={result.target_files} rules={result.matched_rules}/{result.rules}"
    )


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    default_repo = Path(__file__).resolve().parents[1]
    parser.add_argument("--repo-root", type=Path, default=default_repo, help="repository root")
    parser.add_argument(
        "--manifest",
        type=Path,
        default=Path(__file__).resolve().with_name("port_dispositions.json"),
        help="port disposition manifest",
    )
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument(
        "--fail-on-pending",
        action="store_true",
        help="also return failure while any source files remain pending",
    )
    args = parser.parse_args(argv)

    result = audit(args.repo_root, args.manifest)
    if args.json:
        payload = result.to_json()
        payload["summary"]["pending_policy_failed"] = bool(args.fail_on_pending and result.pending)
        print(json.dumps(payload, indent=2, sort_keys=True))
    else:
        for issue in result.issues:
            rule = f" [{issue.rule}]" if issue.rule else ""
            print(f"ERROR {issue.code:<28} {issue.path}{rule}: {issue.message}")
        print(_summary(result))
        if args.fail_on_pending and result.pending:
            print(f"ERROR PENDING_PORT_WORK: {result.pending} source files remain pending")
    return 1 if result.errors or (args.fail_on_pending and result.pending) else 0


if __name__ == "__main__":
    raise SystemExit(main())
