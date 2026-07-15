#!/usr/bin/env python3
"""Read-only static validation for the Zygor 3.3.5a addon bundle.

The validator deliberately uses only Python's standard library.  It can run on a
development machine without a WoW client and never writes to an addon tree.
"""

from __future__ import annotations

import argparse
import fnmatch
import html
import json
import re
import shutil
import struct
import subprocess
import sys
import xml.etree.ElementTree as ElementTree
from collections import Counter, defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path, PurePosixPath
from typing import Iterator, Sequence


TEXTURE_SUFFIXES = {".tga", ".blp"}

# Calls in Compat are intentional adapters.  Everywhere else these are either
# unavailable in 3.3.5a or a strong indication that retail/TBC code leaked in.
FORBIDDEN_IDENTIFIERS = (
    # The old localization layer intentionally defines C_RED/C_GREEN/etc. as
    # color constants; exclude those from the modern C_* namespace gate.
    (re.compile(r"\bC_(?!(?:RED|GREEN|WHITE|GRAY)\b)[A-Za-z][A-Za-z0-9_]*\b"), "C_NAMESPACE"),
    (re.compile(r"\bEnum\s*\."), "ENUM_NAMESPACE"),
    (re.compile(r"\bWOW_PROJECT(?:_ID|_[A-Z0-9_]+)?\b"), "WOW_PROJECT"),
    (re.compile(r"\bMapCanvas(?:Mixin|Frame|DataProviderMixin|PinMixin)?\b"), "MAP_CANVAS"),
    (re.compile(r"\b(?:ScrollUtil|EventRegistry|Settings)\s*\."), "RETAIL_FRAMEWORK"),
    (re.compile(r"\b(?:BackdropTemplate|NineSlicePanelTemplate)\b"), "MODERN_TEMPLATE"),
    (re.compile(r"\bGetMouseFoci\s*\("), "MODERN_MOUSE_API"),
    (re.compile(r"\b(?:SetAtlas|CreateMaskTexture|AddMaskTexture|SetMask|SetRotation)\s*\("), "MODERN_TEXTURE_API"),
    (re.compile(r"(?<![A-Za-z0-9_.])(?<!function )(?!ZGV\.Compat\.UI\b)[A-Za-z_][A-Za-z0-9_.]*:SetShown\s*\("), "POST_WRATH_WIDGET_API"),
    (re.compile(r"(?<![A-Za-z0-9_.])(?<!function )(?!ZGV\.Compat\.UI\b)[A-Za-z_][A-Za-z0-9_.]*:SetEnabled\s*\("), "POST_WRATH_WIDGET_API"),
    (re.compile(r"\bCooldownFrame_Set\s*\("), "POST_WRATH_COOLDOWN_API"),
    (re.compile(r"\bGetQuestID\s*\("), "POST_WRATH_QUEST_API"),
)

# These contracts depend on string-literal values, so scan a second source view
# that removes comments but preserves strings.  Keeping them separate avoids
# interpreting arbitrary guide prose as an API token.
FORBIDDEN_STRING_CONTRACTS = (
    # Build 12340 secure buttons execute pet-bar slots with type="pet" and
    # the numeric slot in the "action" attribute.  "petaction" is a modern
    # action type and silently produces a dead button on Wrath clients.
    (re.compile(
        r"(?:\bSetAttribute\s*\(\s*['\"]type['\"]\s*,\s*['\"]petaction['\"]"
        r"|\b[A-Za-z_][A-Za-z0-9_]*\.type\s*=\s*['\"]petaction['\"])",
        re.IGNORECASE,
    ), "POST_WRATH_SECURE_ACTION"),
    # SecureActionButtonTemplate implements its protected action in OnClick.
    # Replacing that script disables the secure handler on build 12340; use a
    # PreClick/PostClick hook for unprotected bookkeeping around it.
    (re.compile(
        r"\b([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?:_G\.)?CreateFrame\s*\("
        r"[^\r\n;]*['\"]SecureActionButtonTemplate['\"][^\r\n;]*\)"
        r"[\s\S]*?\b\1:SetScript\s*\(\s*['\"]OnClick['\"]",
        re.IGNORECASE,
    ), "SECURE_ONCLICK_OVERRIDE"),
)

LUA_52_SYNTAX = (
    (re.compile(r"::\s*[A-Za-z_][A-Za-z0-9_]*\s*::"), "goto labels"),
    (re.compile(r"\bcontinue\b"), "continue keyword"),
    (re.compile(r"(?<!/)//(?!=)"), "floor-division operator"),
    (re.compile(r"(?:<<|>>|(?<![~<>=])~(?![=]))"), "bitwise operator"),
)

XML_REFERENCE_RE = re.compile(
    r"<(?:Script|Include)\b[^>]*\bfile\s*=\s*(['\"])(.*?)\1",
    re.IGNORECASE | re.DOTALL,
)

XML_FORBIDDEN = (
    (re.compile(r"\bparentKey\s*=", re.IGNORECASE), "XML_PARENT_KEY", "parentKey is unavailable in 3.3.5a"),
    (re.compile(r"\bmixins\s*=", re.IGNORECASE), "XML_MIXINS", "XML mixins are unavailable in 3.3.5a"),
    (re.compile(r"<\s*KeyValues\b", re.IGNORECASE), "XML_KEY_VALUES", "KeyValues is unavailable in 3.3.5a"),
    (re.compile(r"<\s*MaskTexture\b|\batlas\s*=", re.IGNORECASE), "XML_MODERN_TEXTURE", "mask/atlas XML is unavailable in 3.3.5a"),
    (re.compile(r"\b(?:BackdropTemplate|MapCanvas\w*Template)\b"), "XML_MODERN_TEMPLATE", "modern inherited template is unavailable in 3.3.5a"),
)

REGISTRATION_RE = re.compile(
    r"(?:\bZygorGuidesViewer\b|\bZGV\b)\s*[:.]\s*"
    r"(RegisterGuide|RegisterInclude)\s*\(\s*(['\"])((?:\\.|(?!\2).)*)\2",
    re.DOTALL,
)

# This mirrors the WotLK parser's accepted pipe vocabulary.  It makes a typo
# in any registered guide a release error rather than silently retaining an
# inert tag until a player reaches that step.
GUIDE_TAG_RE = re.compile(r"\|([A-Za-z][A-Za-z0-9_]*)")
KNOWN_GUIDE_TAGS = {
    "a", "t", "c", "k", "get", "goldcollect", "flightpath", "fpath", "quest", "at", "ggoto",
    "accept", "turnin", "talk", "kill", "collect", "click", "clicknpc", "buy", "use", "equip", "unequip", "learn", "trainer", "vendor", "home", "hearth", "fly", "taxi", "ding", "complete", "condition", "confirm", "achieve", "achievesub", "earn", "rep", "repcollect", "skill", "skillmax", "craft", "create", "cast", "trash", "discover", "goal", "havebuff", "nobuff", "havequest", "nothavequest", "notcompleted", "goto", "map", "abandon", "activepet", "gossip", "petaction", "avoid", "gotonpc", "bank", "goldtracker",
    "only", "if", "stickyif", "mapmarker", "markmaker", "q", "tip", "next", "loadguide", "itemcount", "script", "autoscript", "execute", "updatescript", "macro", "or", "future", "instant", "daily", "repeatable", "noobsolete", "more", "showtext", "killcount", "sticky", "important", "override", "ordcount", "noordinal", "usebank", "usename", "grouprole", "buttonicon", "countexpr", "model", "modelnpc", "modeldisplay", "nomodels", "simulate", "blizztooltip", "n", "h", "hide", "opt", "optional", "required", "noway", "nowayinzone", "notravel", "direct", "gotoontaxi", "walk", "zombiewalk", "invehicle", "outvehicle", "indoors", "outdoors", "equipped", "unequipped", "from", "multiq", "autoacceptany", "autoturninany", "noautoaccept", "noautogossip", "notinsticky", "mapicon", "delay", "nohearth", "travelcfg", "label", "title", "path", "step", "stickystart", "stickystop", "blockstart", "blockend", "travelfor",
    # Established legacy prose separators; Parser converts them to tooltips.
    "it", "they",
}


def _guide_tag_issues(text: str, path: str, base_line: int = 1) -> Iterator[Issue]:
    for match in GUIDE_TAG_RE.finditer(text):
        tag = match.group(1).lower()
        # |cff... and |r are WoW colour markup embedded in prose, not DSL.
        if tag == "r" or re.match(r"^c[0-9a-f]{8}", tag):
            continue
        if tag not in KNOWN_GUIDE_TAGS:
            yield Issue("error", "GUIDE_UNSUPPORTED_TAG", path, base_line + _line_number(text, match.start()) - 1, f"unsupported guide tag |{match.group(1)}")


@dataclass(frozen=True)
class Issue:
    severity: str
    code: str
    path: str
    line: int
    message: str


@dataclass(frozen=True)
class TextureInfo:
    path: str
    format: str
    width: int | None
    height: int | None
    power_of_two: bool | None
    error: str | None = None


@dataclass
class ValidationResult:
    repo_root: str
    addons: list[str]
    issues: list[Issue]
    textures: list[TextureInfo]
    stats: dict[str, int]
    catalog: dict[str, list[dict[str, object]]]

    @property
    def errors(self) -> int:
        return sum(issue.severity == "error" for issue in self.issues)

    @property
    def warnings(self) -> int:
        return sum(issue.severity == "warning" for issue in self.issues)

    def to_json(self) -> dict[str, object]:
        return {
            "schema": 1,
            "repo_root": self.repo_root,
            "addons": self.addons,
            "summary": {
                "errors": self.errors,
                "warnings": self.warnings,
                **self.stats,
            },
            "issues": [asdict(issue) for issue in self.issues],
            "textures": [asdict(texture) for texture in self.textures],
            "catalog": self.catalog,
        }


def _line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def _relative(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return path.as_posix()


def _is_power_of_two(value: int) -> bool:
    return value > 0 and value & (value - 1) == 0


def _normalise_reference(reference: str) -> tuple[str | None, str | None]:
    """Return a safe POSIX relative path and an optional error."""
    value = reference.strip().replace("\\", "/")
    while value.startswith("./"):
        value = value[2:]
    candidate = PurePosixPath(value)
    if not value:
        return None, "empty reference"
    if candidate.is_absolute() or re.match(r"^[A-Za-z]:", value):
        return None, "absolute paths are not allowed"
    if ".." in candidate.parts:
        return None, "parent traversal is not allowed"
    return candidate.as_posix(), None


def resolve_exact_case(base: Path, reference: str) -> tuple[Path | None, str | None]:
    """Resolve *reference* and diagnose case mismatches on every path segment."""
    normalised, invalid = _normalise_reference(reference)
    if invalid:
        return None, invalid
    assert normalised is not None
    current = base
    for part in PurePosixPath(normalised).parts:
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


def _matches_exclude(relative: str, patterns: Sequence[str]) -> bool:
    """Match the release packager's exclusion rules for one repository path."""
    parts = PurePosixPath(relative).parts
    if any(part.casefold() == "@eadir" for part in parts):
        return True
    return any(
        fnmatch.fnmatchcase(relative, pattern)
        or fnmatch.fnmatchcase(PurePosixPath(relative).name, pattern)
        for pattern in patterns
    )


def _toc_entries(text: str) -> Iterator[tuple[int, str]]:
    for line_number, raw_line in enumerate(text.splitlines(), 1):
        line = raw_line.strip().lstrip("\ufeff")
        if not line or line.startswith("#"):
            continue
        yield line_number, line


def _toc_interface(text: str) -> str | None:
    match = re.search(r"^\ufeff?##\s*Interface\s*:\s*([^\r\n]+)", text, re.MULTILINE | re.IGNORECASE)
    return match.group(1).strip() if match else None


def _toc_required_dependencies(text: str) -> list[str]:
    dependencies: list[str] = []
    for match in re.finditer(r"^\ufeff?##\s*(?:RequiredDeps|Dependencies)\s*:\s*([^\r\n]+)", text, re.MULTILINE | re.IGNORECASE):
        dependencies.extend(value.strip() for value in match.group(1).split(",") if value.strip())
    return dependencies


def _mask_lua_comments_and_strings(text: str, preserve_strings: bool = False) -> str:
    """Blank Lua comments/strings while retaining newlines and character offsets.

    This is a small lexer, not a parser.  It understands quoted and long-bracket
    strings/comments, which is enough to keep guide DSL text out of API scans.
    """
    out = list(text)
    length = len(text)
    index = 0

    def blank(start: int, end: int) -> None:
        for pos in range(start, end):
            if out[pos] not in "\r\n":
                out[pos] = " "

    def long_open(at: int) -> tuple[int, str] | None:
        match = re.match(r"\[(=*)\[", text[at:])
        if not match:
            return None
        return len(match.group(0)), "]" + match.group(1) + "]"

    while index < length:
        if text.startswith("--", index):
            opened = long_open(index + 2)
            if opened:
                open_len, closer = opened
                end = text.find(closer, index + 2 + open_len)
                end = length if end < 0 else end + len(closer)
                blank(index, end)
                index = end
            else:
                end = text.find("\n", index + 2)
                end = length if end < 0 else end
                blank(index, end)
                index = end
            continue
        char = text[index]
        if char in "'\"":
            quote = char
            end = index + 1
            while end < length:
                if text[end] == "\\":
                    end += 2
                    continue
                end += 1
                if text[end - 1] == quote:
                    break
            if not preserve_strings:
                blank(index, min(end, length))
            index = end
            continue
        opened = long_open(index)
        if opened:
            open_len, closer = opened
            end = text.find(closer, index + open_len)
            end = length if end < 0 else end + len(closer)
            if not preserve_strings:
                blank(index, end)
            index = end
            continue
        index += 1
    return "".join(out)


def _mask_xml_comments(text: str) -> str:
    def replace(match: re.Match[str]) -> str:
        return "".join(char if char in "\r\n" else " " for char in match.group(0))

    return re.sub(r"<!--.*?-->", replace, text, flags=re.DOTALL)


def _lua_unescape(value: str) -> str:
    replacements = {
        "a": "\a",
        "b": "\b",
        "f": "\f",
        "n": "\n",
        "r": "\r",
        "t": "\t",
        "v": "\v",
        "\\": "\\",
        '"': '"',
        "'": "'",
    }
    output: list[str] = []
    index = 0
    while index < len(value):
        if value[index] != "\\" or index + 1 >= len(value):
            output.append(value[index])
            index += 1
            continue
        next_char = value[index + 1]
        if next_char.isdigit():
            match = re.match(r"[0-9]{1,3}", value[index + 1 :])
            assert match
            output.append(chr(min(int(match.group(0), 10), 255)))
            index += 1 + len(match.group(0))
        else:
            output.append(replacements.get(next_char, next_char))
            index += 2
    return "".join(output)


def parse_texture(path: Path, repo_root: Path) -> TextureInfo:
    suffix = path.suffix.lower()
    width: int | None = None
    height: int | None = None
    format_name = suffix.lstrip(".").upper()
    error: str | None = None
    try:
        with path.open("rb") as handle:
            header = handle.read(32)
        if suffix == ".tga":
            if len(header) < 18:
                raise ValueError("header is shorter than 18 bytes")
            width, height = struct.unpack_from("<HH", header, 12)
        elif suffix == ".blp":
            if len(header) < 20:
                raise ValueError("header is shorter than 20 bytes")
            magic = header[:4]
            if magic not in (b"BLP1", b"BLP2"):
                raise ValueError(f"unsupported BLP magic {magic!r}")
            format_name = magic.decode("ascii")
            width, height = struct.unpack_from("<II", header, 12)
        else:
            raise ValueError("unsupported texture extension")
        if not width or not height:
            raise ValueError(f"invalid dimensions {width}x{height}")
    except (OSError, ValueError, struct.error) as exc:
        error = str(exc)
        width = height = None
    pot = None if width is None or height is None else _is_power_of_two(width) and _is_power_of_two(height)
    return TextureInfo(_relative(path, repo_root), format_name, width, height, pot, error)


def _find_lua51_compiler(explicit: str | None = None) -> str | None:
    candidates = [explicit] if explicit else ["luac5.1", "luac-5.1", "lua5.1"]
    for candidate in candidates:
        if candidate and shutil.which(candidate):
            return shutil.which(candidate)
    return None


def _compile_lua(path: Path, compiler: str) -> str | None:
    command = [compiler, "-p", str(path)] if "luac" in Path(compiler).name else [compiler, "-e", f"assert(loadfile({str(path)!r}))"]
    process = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if process.returncode == 0:
        return None
    return (process.stderr or process.stdout).strip()


def _approved_compat_path(lua_path: Path, addon_root: Path) -> bool:
    relative_parts = lua_path.relative_to(addon_root).parts
    return any(part.casefold() == "compat" for part in relative_parts[:-1]) or lua_path.stem.casefold().startswith("compat")


def _extract_registrations(text: str, uncommented: str | None = None) -> Iterator[tuple[str, str, int, int]]:
    if uncommented is None:
        uncommented = _mask_lua_comments_and_strings(text, preserve_strings=True)
    for match in REGISTRATION_RE.finditer(uncommented):
        yield match.group(1), _lua_unescape(match.group(3)), _line_number(text, match.start()), match.start()


def _blank_ranges(text: str, ranges: Sequence[tuple[int, int]]) -> str:
    output = list(text)
    for start, end in ranges:
        for index in range(max(start, 0), min(end, len(output))):
            if output[index] not in "\r\n":
                output[index] = " "
    return "".join(output)


def _guide_filter_accepts(title: str, rule: dict[str, object]) -> bool:
    prefix = str(rule["title_prefix"])
    if not title.startswith(prefix):
        return False
    allowed = rule.get("allowed_first_segments")
    if not isinstance(allowed, tuple):
        return True
    remainder = title[len(prefix) :]
    first_segment = remainder.split("\\", 1)[0]
    return first_segment in allowed


def _extract_guide_references(text: str, *, preprocessed: bool = False) -> Iterator[tuple[str, str, int]]:
    uncommented = text if preprocessed else _mask_lua_comments_and_strings(text, preserve_strings=True)
    # Header-level next="..." references.
    for match in re.finditer(r"\bnext\s*=\s*(['\"])((?:\\.|(?!\1).)*)\1", uncommented):
        yield "next", _lua_unescape(match.group(2)).strip(), _line_number(text, match.start())
    # DSL top-level references.  Anchoring prevents |next step labels from being
    # mistaken for guide transitions.
    for match in re.finditer(r"^[ \t]*next[ \t]+([^\r\n]+?)[ \t]*$", uncommented, re.MULTILINE):
        value = match.group(1).strip().strip('"\'')
        if value and not value.startswith("-"):
            # Guide DSL bodies are long-bracket strings, so their path
            # separators are literal rather than Lua escape sequences. The
            # runtime normalizes doubled separators to a single path boundary.
            yield "next", value.replace("\\\\", "\\"), _line_number(text, match.start())
    for match in re.finditer(r"^[ \t]*leechsteps[ \t]+(['\"])((?:\\.|(?!\1).)*)\1", uncommented, re.MULTILINE):
        yield "leechsteps", match.group(2).strip().replace("\\\\", "\\"), _line_number(text, match.start())
    for match in re.finditer(r"^[ \t]*include[ \t]+(['\"]?)([^\s\r\n|]+)\1", uncommented, re.MULTILINE):
        yield "include", match.group(2).strip().replace("\\\\", "\\"), _line_number(text, match.start())


def validate(
    repo_root: Path,
    addon_names: Sequence[str],
    *,
    lua_compiler: str | None = None,
    max_texture_dimension: int = 2048,
    catalog_groups: Sequence[Sequence[str]] | None = None,
    guide_filters: Sequence[dict[str, object]] | None = None,
    exclude_globs: Sequence[str] | None = None,
) -> ValidationResult:
    repo_root = repo_root.resolve()
    issues: list[Issue] = []
    textures: list[TextureInfo] = []
    stats: Counter[str] = Counter()
    compiler = _find_lua51_compiler(lua_compiler)
    exclude_patterns=tuple(exclude_globs or ())
    if not all(isinstance(pattern, str) for pattern in exclude_patterns):
        raise ValueError("exclude_globs must contain only strings")
    all_lua: list[tuple[Path, Path]] = []
    guide_definitions: defaultdict[str, list[tuple[str, int, str]]] = defaultdict(list)
    include_definitions: defaultdict[str, list[tuple[str, int, str]]] = defaultdict(list)
    guide_references: list[tuple[str, str, str, int, str]] = []
    normalised_filters: list[dict[str, object]] = []
    matched_filters: set[int] = set()
    addon_case_map = {name.casefold(): name for name in addon_names}

    for filter_index, rule in enumerate(guide_filters or []):
        pattern = rule.get("glob") if isinstance(rule, dict) else None
        prefix = rule.get("title_prefix") if isinstance(rule, dict) else None
        expected = rule.get("expected") if isinstance(rule, dict) else None
        allowed = rule.get("allowed_first_segments") if isinstance(rule, dict) else None
        allowed_valid = allowed is None or (
            isinstance(allowed, list)
            and bool(allowed)
            and all(isinstance(segment, str) and segment and "\\" not in segment for segment in allowed)
            and len(set(allowed)) == len(allowed)
        )
        if not isinstance(pattern, str) or not pattern or not isinstance(prefix, str) or not allowed_valid or (expected is not None and (not isinstance(expected, int) or expected < 0)):
            issues.append(Issue("error", "GUIDE_FILTER_CONFIG", "tools/release.json", 0, f"invalid guide_registration_filters entry {filter_index + 1}"))
            continue
        normalised_filters.append({
            "index": filter_index,
            "glob": pattern,
            "title_prefix": prefix,
            "expected": expected,
            "allowed_first_segments": tuple(allowed) if isinstance(allowed, list) else None,
        })

    for addon_name in addon_names:
        resolved_addon, addon_problem = resolve_exact_case(repo_root, addon_name)
        addon_root = resolved_addon if resolved_addon is not None else repo_root / addon_name
        if addon_problem or not addon_root.is_dir():
            code = "ADDON_CASE" if addon_problem and addon_problem.startswith("case mismatch") else "ADDON_MISSING"
            message = addon_problem or "whitelisted addon directory does not exist"
            issues.append(Issue("error", code, addon_name, 0, message))
            continue
        top_tocs = sorted(
            (path for path in addon_root.glob("*.toc") if not _matches_exclude(_relative(path, repo_root), exclude_patterns)),
            key=lambda item: item.name.casefold(),
        )
        if not top_tocs:
            issues.append(Issue("error", "TOC_MISSING", addon_name, 0, "addon has no top-level .toc file"))
        expected_toc = addon_root / f"{addon_root.name}.toc"
        primary_toc, primary_problem = resolve_exact_case(addon_root, expected_toc.name)
        if primary_problem or primary_toc is None or not primary_toc.is_file():
            detail = f": {primary_problem}" if primary_problem else ""
            issues.append(Issue("error", "PRIMARY_TOC_MISSING", addon_name, 0, f"WoW requires {expected_toc.name} to match the addon directory exactly{detail}"))
        for toc_path in top_tocs:
            stats["toc_files"] += 1
            try:
                toc_text = toc_path.read_text(encoding="utf-8-sig", errors="replace")
            except OSError as exc:
                issues.append(Issue("error", "TOC_READ", _relative(toc_path, repo_root), 0, str(exc)))
                continue
            interface = _toc_interface(toc_text)
            if interface != "30300":
                issues.append(Issue("error", "INTERFACE", _relative(toc_path, repo_root), 1, f"expected Interface 30300, found {interface or 'none'}"))
            for dependency in _toc_required_dependencies(toc_text):
                stats["required_dependencies"] += 1
                expected_dependency = addon_case_map.get(dependency.casefold())
                if dependency.startswith("Blizzard_"):
                    continue
                if expected_dependency is None:
                    issues.append(Issue("error", "DEPENDENCY_NOT_WHITELISTED", _relative(toc_path, repo_root), 1, f"required dependency '{dependency}' is not in the release addon whitelist"))
                elif dependency != expected_dependency:
                    issues.append(Issue("error", "DEPENDENCY_CASE", _relative(toc_path, repo_root), 1, f"required dependency uses '{dependency}', expected exact case '{expected_dependency}'"))
            for line_number, reference in _toc_entries(toc_text):
                resolved, problem = resolve_exact_case(addon_root, reference)
                if problem:
                    code = "REFERENCE_CASE" if problem.startswith("case mismatch") else "REFERENCE_MISSING"
                    issues.append(Issue("error", code, _relative(toc_path, repo_root), line_number, f"{reference}: {problem}"))
                elif resolved and not resolved.is_file():
                    issues.append(Issue("error", "REFERENCE_NOT_FILE", _relative(toc_path, repo_root), line_number, f"{reference} does not resolve to a file"))
                elif resolved and _matches_exclude(_relative(resolved, repo_root), exclude_patterns):
                    issues.append(Issue("error", "REFERENCE_EXCLUDED", _relative(toc_path, repo_root), line_number, f"{reference} is excluded from the release"))

        xml_paths = sorted(path for path in addon_root.rglob("*.xml") if not _matches_exclude(_relative(path, repo_root), exclude_patterns))
        for xml_path in xml_paths:
            stats["xml_files"] += 1
            try:
                xml_text = xml_path.read_text(encoding="utf-8-sig", errors="replace")
            except OSError as exc:
                issues.append(Issue("error", "XML_READ", _relative(xml_path, repo_root), 0, str(exc)))
                continue
            try:
                ElementTree.fromstring(xml_text)
            except ElementTree.ParseError as exc:
                line_number = exc.position[0] if getattr(exc, "position", None) else 0
                issues.append(Issue("error", "XML_PARSE", _relative(xml_path, repo_root), line_number, str(exc)))
            active_xml = _mask_xml_comments(xml_text)
            if active_xml.count("<Ui") and not re.search(r"</Ui\s*>", active_xml, re.IGNORECASE):
                issues.append(Issue("warning", "XML_UI_CLOSE", _relative(xml_path, repo_root), 1, "<Ui> document has no visible closing </Ui> tag"))
            for pattern, code, message in XML_FORBIDDEN:
                for match in pattern.finditer(active_xml):
                    issues.append(Issue("error", code, _relative(xml_path, repo_root), _line_number(xml_text, match.start()), message))
            for match in XML_REFERENCE_RE.finditer(active_xml):
                reference = html.unescape(match.group(2))
                resolved, problem = resolve_exact_case(xml_path.parent, reference)
                line_number = _line_number(xml_text, match.start())
                if problem:
                    code = "REFERENCE_CASE" if problem.startswith("case mismatch") else "REFERENCE_MISSING"
                    issues.append(Issue("error", code, _relative(xml_path, repo_root), line_number, f"{reference}: {problem}"))
                elif resolved and not resolved.is_file():
                    issues.append(Issue("error", "REFERENCE_NOT_FILE", _relative(xml_path, repo_root), line_number, f"{reference} does not resolve to a file"))
                elif resolved and _matches_exclude(_relative(resolved, repo_root), exclude_patterns):
                    issues.append(Issue("error", "REFERENCE_EXCLUDED", _relative(xml_path, repo_root), line_number, f"{reference} is excluded from the release"))

        for lua_path in sorted(path for path in addon_root.rglob("*.lua") if not _matches_exclude(_relative(path, repo_root), exclude_patterns)):
            stats["lua_files"] += 1
            all_lua.append((addon_root, lua_path))
            relative_lua = _relative(lua_path, repo_root)
            try:
                lua_text = lua_path.read_text(encoding="utf-8-sig", errors="replace")
            except OSError as exc:
                issues.append(Issue("error", "LUA_READ", relative_lua, 0, str(exc)))
                continue
            masked = _mask_lua_comments_and_strings(lua_text)
            approved = _approved_compat_path(lua_path, addon_root)
            if not approved:
                for pattern, code in FORBIDDEN_IDENTIFIERS:
                    matches_by_token: defaultdict[str, list[re.Match[str]]] = defaultdict(list)
                    for match in pattern.finditer(masked):
                        matches_by_token[match.group(0).strip()].append(match)
                    for token, matches in sorted(matches_by_token.items()):
                        first = matches[0]
                        count_note = f" ({len(matches)} occurrences in file)" if len(matches) > 1 else ""
                        issues.append(Issue("error", code, relative_lua, _line_number(lua_text, first.start()), f"modern API/token outside Compat: {token}{count_note}"))
                strings_preserved = _mask_lua_comments_and_strings(lua_text, preserve_strings=True)
                for pattern, code in FORBIDDEN_STRING_CONTRACTS:
                    for match in pattern.finditer(strings_preserved):
                        issues.append(Issue(
                            "error",
                            code,
                            relative_lua,
                            _line_number(lua_text, match.start()),
                            f"post-Wrath secure action contract: {match.group(0).strip()}",
                        ))
            for pattern, description in LUA_52_SYNTAX:
                for match in pattern.finditer(masked):
                    issues.append(Issue("error", "LUA51_SYNTAX", relative_lua, _line_number(lua_text, match.start()), f"not valid Lua 5.1 syntax: {description}"))
            if compiler:
                compile_error = _compile_lua(lua_path, compiler)
                if compile_error:
                    issues.append(Issue("error", "LUA_COMPILE", relative_lua, 0, compile_error))

            catalog_text = _mask_lua_comments_and_strings(lua_text, preserve_strings=True)
            registrations = list(_extract_registrations(lua_text, catalog_text))
            matching_rules = [rule for rule in normalised_filters if fnmatch.fnmatchcase(relative_lua, str(rule["glob"]))]
            active_rule = matching_rules[0] if matching_rules else None
            if len(matching_rules) > 1:
                issues.append(Issue("error", "GUIDE_FILTER_OVERLAP", relative_lua, 0, "multiple guide registration filters match this file"))
            reference_text = catalog_text
            accepted_offsets: set[int] | None = None
            if active_rule:
                matched_filters.add(int(active_rule["index"]))
                prefix = str(active_rule["title_prefix"])
                guide_regs = [registration for registration in registrations if registration[0] == "RegisterGuide"]
                accepted = [registration for registration in guide_regs if _guide_filter_accepts(registration[1], active_rule)]
                accepted_offsets = {registration[3] for registration in accepted}
                stats["guides_filtered"] += len(guide_regs) - len(accepted)
                expected = active_rule.get("expected")
                if isinstance(expected, int) and len(accepted) != expected:
                    segment_note = f" and allowed first segments {list(active_rule['allowed_first_segments'])}" if active_rule.get("allowed_first_segments") else ""
                    issues.append(Issue("error", "GUIDE_FILTER_COUNT", relative_lua, 0, f"filter expected {expected} guides with prefix '{prefix}'{segment_note}, found {len(accepted)}"))
                excluded_ranges: list[tuple[int, int]] = []
                for index, registration in enumerate(guide_regs):
                    if registration[3] in accepted_offsets:
                        continue
                    end = guide_regs[index + 1][3] if index + 1 < len(guide_regs) else len(lua_text)
                    excluded_ranges.append((registration[3], end))
                reference_text = _blank_ranges(catalog_text, excluded_ranges)

            for kind, name, line_number, offset in registrations:
                if kind == "RegisterGuide" and accepted_offsets is not None and offset not in accepted_offsets:
                    continue
                target = guide_definitions if kind == "RegisterGuide" else include_definitions
                target[name].append((relative_lua, line_number, addon_name))
            for kind, target_name, line_number in _extract_guide_references(reference_text, preprocessed=True):
                guide_references.append((kind, target_name, relative_lua, line_number, addon_name))
            # Scan only registered guide bodies. Data tables and Lua item links
            # use pipes too, but are not part of the guide DSL grammar.
            active_guides = [entry for entry in registrations if entry[0] == "RegisterGuide" and (accepted_offsets is None or entry[3] in accepted_offsets)]
            ordered_offsets = sorted(entry[3] for entry in registrations)
            for _, _, line_number, offset in active_guides:
                next_offsets = [candidate for candidate in ordered_offsets if candidate > offset]
                body = catalog_text[offset : next_offsets[0] if next_offsets else len(catalog_text)]
                for issue in _guide_tag_issues(body, relative_lua, line_number):
                    issues.append(issue)

        for texture_path in sorted(
            (path for path in addon_root.rglob("*") if path.is_file() and path.suffix.lower() in TEXTURE_SUFFIXES and not _matches_exclude(_relative(path, repo_root), exclude_patterns)),
            key=lambda item: item.as_posix().casefold(),
        ):
            texture = parse_texture(texture_path, repo_root)
            textures.append(texture)
            stats["textures"] += 1
            if texture.error:
                issues.append(Issue("error", "TEXTURE_HEADER", texture.path, 0, texture.error))
            elif texture.width and texture.height:
                if not texture.power_of_two:
                    issues.append(Issue("warning", "TEXTURE_NPOT", texture.path, 0, f"non-power-of-two texture: {texture.width}x{texture.height}"))
                if max(texture.width, texture.height) > max_texture_dimension:
                    issues.append(Issue("warning", "TEXTURE_LARGE", texture.path, 0, f"{texture.width}x{texture.height} exceeds reporting threshold {max_texture_dimension}"))

    if not compiler and all_lua:
        issues.append(Issue("warning", "LUA51_COMPILER_MISSING", "tools", 0, "luac5.1/lua5.1 was not found; lexical Lua 5.1 checks ran, bytecode syntax compilation did not"))

    for rule in normalised_filters:
        if int(rule["index"]) not in matched_filters:
            issues.append(Issue("error", "GUIDE_FILTER_UNMATCHED", "tools/release.json", 0, f"guide filter glob matched no Lua file: {rule['glob']}"))

    stats["guides"] = sum(len(locations) for locations in guide_definitions.values())
    stats["includes"] = sum(len(locations) for locations in include_definitions.values())
    stats["guide_references"] = len(guide_references)

    if catalog_groups is None:
        alliance = [name for name in addon_names if name.endswith("_GuidesAlliance")]
        horde = [name for name in addon_names if name.endswith("_GuidesHorde")]
        neutral = [name for name in addon_names if name not in alliance and name not in horde]
        if alliance and horde:
            catalog_groups = [neutral + alliance, neutral + horde]
        else:
            catalog_groups = [list(addon_names)]
    runtime_groups: list[tuple[str, set[str]]] = []
    for index, group in enumerate(catalog_groups, 1):
        filtered = {name for name in group if name in addon_names}
        if filtered:
            runtime_groups.append((f"catalog-{index}", filtered))
    if not runtime_groups:
        runtime_groups = [("catalog-1", set(addon_names))]

    duplicate_keys: set[tuple[str, str, tuple[tuple[str, int, str], ...]]] = set()
    for group_name, group in runtime_groups:
        for title, all_locations in sorted(guide_definitions.items()):
            locations = [location for location in all_locations if location[2] in group]
            if len(locations) > 1:
                key = ("guide", title, tuple(locations))
                if key not in duplicate_keys:
                    duplicate_keys.add(key)
                    details = ", ".join(f"{path}:{line}" for path, line, _ in locations)
                    issues.append(Issue("error", "GUIDE_DUPLICATE", locations[0][0], locations[0][1], f"guide '{title}' is registered {len(locations)} times in {group_name}: {details}"))
        for name, all_locations in sorted(include_definitions.items()):
            locations = [location for location in all_locations if location[2] in group]
            if len(locations) > 1:
                key = ("include", name, tuple(locations))
                if key not in duplicate_keys:
                    duplicate_keys.add(key)
                    details = ", ".join(f"{path}:{line}" for path, line, _ in locations)
                    issues.append(Issue("error", "INCLUDE_DUPLICATE", locations[0][0], locations[0][1], f"include '{name}' is registered {len(locations)} times in {group_name}: {details}"))

    for kind, target_name, source_path, line_number, source_addon in guide_references:
        relevant_groups = [(name, group) for name, group in runtime_groups if source_addon in group]
        definitions = include_definitions if kind == "include" else guide_definitions
        missing_groups = []
        for group_name, group in relevant_groups:
            if not any(location[2] in group for location in definitions.get(target_name, [])):
                missing_groups.append(group_name)
        if missing_groups:
            code = "INCLUDE_UNRESOLVED" if kind == "include" else "GUIDE_UNRESOLVED"
            noun = "include" if kind == "include" else f"{kind} target"
            issues.append(Issue("error", code, source_path, line_number, f"{noun} '{target_name}' has no definition in {', '.join(missing_groups)}"))

    catalog = {
        "guides": [
            {"title": title, "path": path, "line": line, "addon": addon}
            for title, locations in sorted(guide_definitions.items())
            for path, line, addon in locations
        ],
        "includes": [
            {"name": name, "path": path, "line": line, "addon": addon}
            for name, locations in sorted(include_definitions.items())
            for path, line, addon in locations
        ],
    }
    issues.sort(key=lambda issue: (issue.path.casefold(), issue.line, issue.severity, issue.code, issue.message))
    textures.sort(key=lambda texture: texture.path.casefold())
    return ValidationResult(str(repo_root), list(addon_names), issues, textures, dict(sorted(stats.items())), catalog)


def _load_manifest_config(repo_root: Path, manifest: Path | None) -> tuple[list[str], list[list[str]] | None, list[dict[str, object]] | None, list[str] | None, Path]:
    manifest_path = manifest or repo_root / "tools" / "release.json"
    if not manifest_path.is_absolute():
        manifest_path = repo_root / manifest_path
    try:
        data = json.loads(manifest_path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise SystemExit(f"cannot read release manifest {manifest_path}: {exc}")
    except json.JSONDecodeError as exc:
        raise SystemExit(f"invalid release manifest {manifest_path}: {exc}")
    if data.get("schema") != 1:
        raise SystemExit(f"release manifest {manifest_path} schema must be 1")
    bundle_root = repo_root
    raw_bundle_root = data.get("bundle_root")
    if raw_bundle_root is not None:
        if not isinstance(raw_bundle_root, str) or not raw_bundle_root:
            raise SystemExit(f"release manifest {manifest_path} has invalid bundle_root")
        resolved, problem = resolve_exact_case(repo_root, raw_bundle_root)
        if problem or resolved is None or not resolved.is_dir():
            raise SystemExit(f"release manifest {manifest_path} bundle_root is invalid: {problem or 'not a directory'}")
        bundle_root = resolved
    addons = data.get("addon_roots")
    if not isinstance(addons, list) or not addons or not all(isinstance(item, str) and item for item in addons):
        raise SystemExit(f"release manifest {manifest_path} has invalid addon_roots")
    selected = list(addons)
    groups = data.get("catalog_runtime_groups")
    if groups is not None and (not isinstance(groups, list) or not all(isinstance(group, list) and all(isinstance(item, str) for item in group) for group in groups)):
        raise SystemExit(f"release manifest {manifest_path} has invalid catalog_runtime_groups")
    if groups is None:
        groups = None
    filters = data.get("guide_registration_filters")
    if filters is not None and (not isinstance(filters, list) or not all(isinstance(rule, dict) for rule in filters)):
        raise SystemExit(f"release manifest {manifest_path} has invalid guide_registration_filters")
    if filters is None:
        filters = None
    excludes = data.get("exclude_globs")
    if excludes is not None and (not isinstance(excludes, list) or not all(isinstance(pattern, str) for pattern in excludes)):
        raise SystemExit(f"release manifest {manifest_path} has invalid exclude_globs")
    if excludes is None:
        excludes = None
    return selected, groups, filters, excludes, bundle_root


def _print_human(result: ValidationResult, texture_report: bool, quiet: bool) -> None:
    if not quiet:
        for issue in result.issues:
            location = issue.path + (f":{issue.line}" if issue.line else "")
            print(f"{issue.severity.upper():7} {issue.code:24} {location}: {issue.message}")
    if texture_report:
        print("\nTexture report")
        for texture in result.textures:
            dimensions = f"{texture.width}x{texture.height}" if texture.width and texture.height else "unreadable"
            pot = "POT" if texture.power_of_two else "NPOT" if texture.power_of_two is False else "unknown"
            suffix = f" ({texture.error})" if texture.error else ""
            print(f"{texture.format:4} {dimensions:12} {pot:7} {texture.path}{suffix}")
    summary = " ".join(f"{key}={value}" for key, value in sorted(result.stats.items()))
    print(f"Validation: {result.errors} error(s), {result.warnings} warning(s); {summary}")


def main(argv: Sequence[str] | None = None) -> int:
    script_root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=script_root.parent, help="repository root (default: parent of tools)")
    parser.add_argument("--addon", action="append", dest="addons", help="addon root to validate; repeat to override release.json")
    parser.add_argument("--manifest", type=Path, help="manifest used to select default addon roots")
    parser.add_argument("--lua-compiler", help="explicit luac5.1 or lua5.1 executable")
    parser.add_argument("--max-texture-dimension", type=int, default=2048, help="warn above this dimension (default: 2048)")
    parser.add_argument("--texture-report", action="store_true", help="print every TGA/BLP dimension")
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument("--quiet", action="store_true", help="hide individual issues in human output")
    parser.add_argument("--strict", action="store_true", help="return failure for warnings as well as errors")
    args = parser.parse_args(argv)

    repo_root = args.repo_root.resolve()
    if args.addons:
        addons = args.addons
        manifest_groups = None
        manifest_filters = None
        manifest_excludes = None
        bundle_root = repo_root
    else:
        addons, manifest_groups, manifest_filters, manifest_excludes, bundle_root = _load_manifest_config(repo_root, args.manifest)
    result = validate(
        bundle_root,
        addons,
        lua_compiler=args.lua_compiler,
        max_texture_dimension=args.max_texture_dimension,
        catalog_groups=None if args.addons else manifest_groups,
        guide_filters=None if args.addons else manifest_filters,
        exclude_globs=None if args.addons else manifest_excludes,
    )
    if args.json:
        print(json.dumps(result.to_json(), indent=2, sort_keys=True))
    else:
        _print_human(result, args.texture_report, args.quiet)
    return 1 if result.errors or (args.strict and result.warnings) else 0


if __name__ == "__main__":
    raise SystemExit(main())
