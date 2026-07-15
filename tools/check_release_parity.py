#!/usr/bin/env python3
"""Enforce the feature-level release parity registry.

Source-file accounting answers whether an upstream file was considered.  This
gate answers the release question: every active player-facing capability has a
local implementation, automated evidence, a live-client acceptance scenario,
and no unreviewed omission.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Sequence


def evaluate(registry_path: Path, require_live: bool = True) -> list[str]:
    try:
        registry = json.loads(registry_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return [f"cannot read parity registry: {exc}"]
    if registry.get("schema") != 1:
        return ["parity registry schema must be 1"]
    features = registry.get("features")
    if not isinstance(features, list) or not features:
        return ["parity registry must contain features"]
    root = registry_path.parent.parent
    # Implementation paths are written relative to the deployable addon
    # bundle. The public repository uses the bundle root from release.json,
    # while older private worktrees used ZygorGuidesViewerNew.
    evidence_roots = [root]
    manifest_path = registry_path.parent / "release.json"
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        manifest = {}
    bundle_root = manifest.get("bundle_root") if isinstance(manifest, dict) else None
    if isinstance(bundle_root, str) and bundle_root:
        evidence_roots.append(root / bundle_root)
    evidence_roots.append(root / "ZygorGuidesViewerNew")
    errors: list[str] = []
    seen: set[str] = set()
    for index, feature in enumerate(features, 1):
        if not isinstance(feature, dict):
            errors.append(f"feature {index} is not an object")
            continue
        identifier = feature.get("id")
        if not isinstance(identifier, str) or not identifier:
            errors.append(f"feature {index} has no id")
            continue
        if identifier in seen:
            errors.append(f"duplicate feature id: {identifier}")
        seen.add(identifier)
        for field in ("implementation", "automated"):
            values = feature.get(field)
            if not isinstance(values, list) or not values or not all(isinstance(value, str) and value for value in values):
                errors.append(f"{identifier}: {field} must be a non-empty string list")
                continue
            for value in values:
                # Addon implementation paths are expressed relative to the
                # shipped bundle; tooling evidence is expressed relative to
                # the repository root.
                if not any((candidate / value).exists() for candidate in evidence_roots):
                    errors.append(f"{identifier}: missing {field} evidence {value}")
        if not isinstance(feature.get("live_scenario"), str) or not feature["live_scenario"].strip():
            errors.append(f"{identifier}: missing live_scenario")
        if feature.get("status") not in {"implemented", "validated"}:
            errors.append(f"{identifier}: unresolved implementation status {feature.get('status')!r}")
        if require_live and feature.get("live_status") != "passed":
            errors.append(f"{identifier}: live acceptance is {feature.get('live_status', 'missing')}")
    exclusions = registry.get("reviewed_exclusions")
    if not isinstance(exclusions, list):
        errors.append("reviewed_exclusions must be a list")
    else:
        for exclusion in exclusions:
            if not isinstance(exclusion, dict) or not isinstance(exclusion.get("id"), str) or not isinstance(exclusion.get("reason"), str):
                errors.append("every reviewed exclusion needs id and reason")
    return errors


def main(argv: Sequence[str] | None = None) -> int:
    tools_root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, default=tools_root / "release_parity.json")
    parser.add_argument("--allow-live-pending", action="store_true", help="check implementation evidence without asserting live-client completion")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(argv)
    errors = evaluate(args.registry.resolve(), require_live=not args.allow_live_pending)
    if args.json:
        print(json.dumps({"ok": not errors, "errors": errors}, indent=2))
    elif errors:
        print("Release parity gate: BLOCKED")
        for error in errors:
            print(f"- {error}")
    else:
        print("Release parity gate: PASS")
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
