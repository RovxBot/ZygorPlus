#!/usr/bin/env python3
"""Create a deterministic ZIP from the explicit Zygor addon whitelist."""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import sys
import zipfile
from pathlib import Path, PurePosixPath
from typing import Sequence

from check_release_parity import evaluate as evaluate_release_parity
from validate_addons import resolve_exact_case, validate


FIXED_ZIP_TIME = (2000, 1, 1, 0, 0, 0)


def load_manifest(path: Path) -> dict[str, object]:
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise SystemExit(f"cannot read release manifest {path}: {exc}")
    except json.JSONDecodeError as exc:
        raise SystemExit(f"invalid release manifest {path}: {exc}")
    if manifest.get("schema") != 1:
        raise SystemExit("release manifest schema must be 1")
    for key in ("name", "version"):
        value = manifest.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9._-]+", value):
            raise SystemExit(f"release manifest {key} must contain only letters, digits, dot, underscore, and hyphen")
    bundle_root = manifest.get("bundle_root")
    if bundle_root is not None:
        if not isinstance(bundle_root, str) or not bundle_root:
            raise SystemExit("release manifest bundle_root must be a non-empty relative directory path")
        pure = PurePosixPath(bundle_root)
        if pure.is_absolute() or ".." in pure.parts or bundle_root in (".", ".."):
            raise SystemExit(f"release manifest bundle_root is unsafe: {bundle_root!r}")
    roots = manifest.get("addon_roots")
    if not isinstance(roots, list) or not roots or not all(isinstance(root, str) and root for root in roots):
        raise SystemExit("release manifest addon_roots must be a non-empty string list")
    if len(set(roots)) != len(roots):
        raise SystemExit("release manifest addon_roots contains duplicates")
    for root in roots:
        pure = PurePosixPath(root)
        if pure.is_absolute() or len(pure.parts) != 1 or root in (".", ".."):
            raise SystemExit(f"addon root must be one top-level directory name: {root!r}")
    groups = manifest.get("catalog_runtime_groups")
    if groups is not None:
        if not isinstance(groups, list) or not groups or not all(isinstance(group, list) and group and all(isinstance(item, str) for item in group) for group in groups):
            raise SystemExit("release manifest catalog_runtime_groups must be a non-empty list of non-empty string lists")
        unknown = sorted({item for group in groups for item in group if item not in roots})
        if unknown:
            raise SystemExit(f"catalog_runtime_groups contains roots outside addon_roots: {', '.join(unknown)}")
        uncovered = sorted(set(roots) - {item for group in groups for item in group})
        if uncovered:
            raise SystemExit(f"addon roots missing from catalog_runtime_groups: {', '.join(uncovered)}")
    filters = manifest.get("guide_registration_filters")
    if filters is not None:
        if not isinstance(filters, list) or not all(isinstance(rule, dict) for rule in filters):
            raise SystemExit("release manifest guide_registration_filters must be a list of objects")
        seen_globs: set[str] = set()
        for rule in filters:
            pattern = rule.get("glob")
            prefix = rule.get("title_prefix")
            expected = rule.get("expected")
            allowed = rule.get("allowed_first_segments")
            if not isinstance(pattern, str) or not pattern or not isinstance(prefix, str):
                raise SystemExit("each guide registration filter needs non-empty glob and title_prefix strings")
            if expected is not None and (not isinstance(expected, int) or expected < 0):
                raise SystemExit("guide registration filter expected must be a non-negative integer")
            if allowed is not None and (
                not isinstance(allowed, list)
                or not allowed
                or not all(isinstance(segment, str) and segment and "\\" not in segment for segment in allowed)
                or len(set(allowed)) != len(allowed)
            ):
                raise SystemExit("guide registration filter allowed_first_segments must be a non-empty list of unique path-segment strings")
            if pattern in seen_globs:
                raise SystemExit(f"duplicate guide registration filter glob: {pattern}")
            seen_globs.add(pattern)
            first_part = PurePosixPath(pattern).parts[0] if PurePosixPath(pattern).parts else ""
            if first_part not in roots:
                raise SystemExit(f"guide registration filter is outside addon_roots: {pattern}")
    return manifest


def resolve_bundle_root(repo_root: Path, manifest: dict[str, object]) -> Path:
    raw = manifest.get("bundle_root")
    if raw is None:
        return repo_root
    source_root, problem = resolve_exact_case(repo_root, str(raw))
    if problem or source_root is None or not source_root.is_dir():
        raise SystemExit(f"release bundle_root is invalid: {problem or 'not a directory'}")
    return source_root


def _matches_exclude(relative: str, patterns: Sequence[str]) -> bool:
    parts = PurePosixPath(relative).parts
    if any(part.casefold() == "@eadir" for part in parts):
        return True
    return any(fnmatch.fnmatchcase(relative, pattern) or fnmatch.fnmatchcase(PurePosixPath(relative).name, pattern) for pattern in patterns)


def collect_files(repo_root: Path, manifest: dict[str, object]) -> list[tuple[Path, str]]:
    patterns = manifest.get("exclude_globs", [])
    if not isinstance(patterns, list) or not all(isinstance(pattern, str) for pattern in patterns):
        raise SystemExit("release manifest exclude_globs must be a string list")
    source_root = resolve_bundle_root(repo_root, manifest)
    files: list[tuple[Path, str]] = []
    for addon_name in manifest["addon_roots"]:  # type: ignore[index]
        addon_root, problem = resolve_exact_case(source_root, str(addon_name))
        if problem or addon_root is None or not addon_root.is_dir():
            raise SystemExit(f"whitelisted addon root is invalid: {addon_name}: {problem or 'not a directory'}")
        primary_toc, toc_problem = resolve_exact_case(addon_root, f"{addon_root.name}.toc")
        if toc_problem or primary_toc is None or not primary_toc.is_file():
            raise SystemExit(f"whitelisted addon root has no correctly named primary TOC: {addon_name}")
        for source in addon_root.rglob("*"):
            if source.is_symlink():
                raise SystemExit(f"symlinks are forbidden in releases: {source.relative_to(repo_root)}")
            if not source.is_file():
                continue
            archive_name = source.relative_to(source_root).as_posix()
            if _matches_exclude(archive_name, patterns):
                continue
            files.append((source, archive_name))
    files.sort(key=lambda pair: pair[1].encode("utf-8"))
    if not files:
        raise SystemExit("release whitelist selected no files")
    return files


def write_zip(output: Path, files: Sequence[tuple[Path, str]]) -> tuple[str, int]:
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + ".tmp")
    digest = hashlib.sha256()
    try:
        with zipfile.ZipFile(temporary, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for source, archive_name in files:
                info = zipfile.ZipInfo(archive_name, FIXED_ZIP_TIME)
                info.compress_type = zipfile.ZIP_DEFLATED
                info.create_system = 3
                info.external_attr = (0o100644 & 0xFFFF) << 16
                with source.open("rb") as handle:
                    archive.writestr(info, handle.read(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
        os.replace(temporary, output)
    finally:
        if temporary.exists():
            temporary.unlink()
    with output.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    checksum = digest.hexdigest()
    checksum_path = output.with_suffix(output.suffix + ".sha256")
    checksum_path.write_text(f"{checksum}  {output.name}\n", encoding="ascii")
    return checksum, output.stat().st_size


def main(argv: Sequence[str] | None = None) -> int:
    tools_root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=tools_root.parent)
    parser.add_argument("--manifest", type=Path, default=tools_root / "release.json")
    parser.add_argument("--output", type=Path, help="ZIP path (default: tools/dist/<name>-<version>.zip)")
    parser.add_argument("--dry-run", action="store_true", help="list selected files without writing")
    parser.add_argument("--skip-validation", action="store_true", help="package despite validator errors (development only)")
    args = parser.parse_args(argv)

    repo_root = args.repo_root.resolve()
    manifest_path = args.manifest if args.manifest.is_absolute() else (repo_root / args.manifest).resolve()
    manifest = load_manifest(manifest_path)
    addons = [str(value) for value in manifest["addon_roots"]]  # type: ignore[index]
    bundle_root = resolve_bundle_root(repo_root, manifest)
    files = collect_files(repo_root, manifest)

    if not args.skip_validation:
        groups = manifest.get("catalog_runtime_groups")
        filters = manifest.get("guide_registration_filters")
        result = validate(
            bundle_root,
            addons,
            catalog_groups=groups if isinstance(groups, list) else None,
            guide_filters=filters if isinstance(filters, list) else None,
            exclude_globs=manifest.get("exclude_globs") if isinstance(manifest.get("exclude_globs"), list) else None,
        )
        if result.errors or result.warnings:
            print(f"release blocked: validator found {result.errors} error(s) and {result.warnings} warning(s)", file=sys.stderr)
            print("run: python3 tools/validate_addons.py --strict", file=sys.stderr)
            return 1
        parity_errors = evaluate_release_parity(tools_root / "release_parity.json", require_live=True)
        if parity_errors:
            print("release blocked: feature parity gate is incomplete", file=sys.stderr)
            for error in parity_errors:
                print(f"- {error}", file=sys.stderr)
            print("run: python3 tools/check_release_parity.py", file=sys.stderr)
            return 1

    total_bytes = sum(path.stat().st_size for path, _ in files)
    if args.dry_run:
        for _, archive_name in files:
            print(archive_name)
        print(f"Dry run: {len(files)} files, {total_bytes} source bytes, no archive written")
        return 0

    name = str(manifest.get("name", "ZygorGuidesViewer-WotLK"))
    version = str(manifest.get("version", "dev"))
    output = args.output or tools_root / "dist" / f"{name}-{version}.zip"
    if not output.is_absolute():
        output = (Path.cwd() / output).resolve()
    for addon_name in addons:
        addon_root = (bundle_root / addon_name).resolve()
        try:
            output.relative_to(addon_root)
        except ValueError:
            continue
        raise SystemExit(f"output must not be written inside an addon source tree: {output}")
    checksum, size = write_zip(output, files)
    print(f"Created {output} ({len(files)} files, {size} bytes)")
    print(f"SHA-256 {checksum}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
