#!/usr/bin/env python3
"""Select the next unused patch version in a release series.

Read ``git ls-remote --tags --refs`` output from standard input and print the
version to publish.  The base version sets the major/minor release series and
the lowest patch that may be selected.
"""

from __future__ import annotations

import argparse
import re
import sys
from collections.abc import Iterable


VERSION_PATTERN = re.compile(r"(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)\Z")
TAG_PATTERN = re.compile(r"refs/tags/v(?P<version>.+)\Z")


def parse_version(value: str) -> tuple[int, int, int]:
    """Parse a final semantic version without prerelease/build suffixes."""
    match = VERSION_PATTERN.fullmatch(value)
    if match is None:
        raise ValueError(f"version must be X.Y.Z; found {value!r}")
    return tuple(int(match.group(key)) for key in ("major", "minor", "patch"))


def next_release_version(base_version: str, remote_refs: Iterable[str]) -> str:
    """Return the first available patch at or above *base_version*.

    Only final ``vX.Y.Z`` tags in the base version's major/minor series count.
    This deliberately ignores prerelease-style tags and unrelated release
    series, so a maintainer can begin a new major or minor series by updating
    ``tools/release.json``.
    """
    major, minor, base_patch = parse_version(base_version)
    highest_patch: int | None = None

    for line in remote_refs:
        ref = line.strip().split()[-1] if line.strip() else ""
        tag_match = TAG_PATTERN.fullmatch(ref)
        if tag_match is None:
            continue
        try:
            tag_major, tag_minor, tag_patch = parse_version(tag_match.group("version"))
        except ValueError:
            continue
        if (tag_major, tag_minor) != (major, minor):
            continue
        highest_patch = tag_patch if highest_patch is None else max(highest_patch, tag_patch)

    patch = base_patch if highest_patch is None else max(base_patch, highest_patch + 1)
    return f"{major}.{minor}.{patch}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-version", required=True, help="minimum X.Y.Z version for the release series")
    args = parser.parse_args()
    try:
        print(next_release_version(args.base_version, sys.stdin))
    except ValueError as exc:
        parser.error(str(exc))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
