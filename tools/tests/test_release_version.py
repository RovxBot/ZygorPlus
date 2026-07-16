from __future__ import annotations

import unittest
from pathlib import Path

import sys

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))

from next_release_version import next_release_version, parse_version  # noqa: E402


class NextReleaseVersionTests(unittest.TestCase):
    def test_uses_base_version_when_the_series_has_no_tag(self) -> None:
        refs = [
            "deadbeef\trefs/tags/v0.1.12",
            "deadbeef\trefs/tags/v0.2.0",
        ]
        self.assertEqual(next_release_version("0.1.13", refs), "0.1.13")

    def test_increments_past_the_highest_existing_patch(self) -> None:
        refs = [
            "deadbeef\trefs/tags/v0.1.13",
            "deadbeef\trefs/tags/v0.1.15",
            "deadbeef\trefs/tags/v0.1.14",
        ]
        self.assertEqual(next_release_version("0.1.13", refs), "0.1.16")

    def test_ignores_other_series_and_non_final_tags(self) -> None:
        refs = [
            "deadbeef\trefs/tags/v0.2.999",
            "deadbeef\trefs/tags/v1.1.999",
            "deadbeef\trefs/tags/v0.1.999-alpha.1",
            "deadbeef\trefs/tags/not-a-release",
        ]
        self.assertEqual(next_release_version("0.1.13", refs), "0.1.13")

    def test_rejects_non_semantic_base_version(self) -> None:
        with self.assertRaisesRegex(ValueError, "X.Y.Z"):
            parse_version("0.1")


if __name__ == "__main__":
    unittest.main()
