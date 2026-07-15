#!/usr/bin/env python3
"""Export persisted Zygor diagnostics to the WoW client's Logs directory.

WoW addons are sandboxed and cannot write arbitrary files.  The viewer writes
diagnostics to its SavedVariables; this tool is the host-side bridge that turns
that flushed data into a normal client log after /reload or logout.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any, Sequence


class LuaValueReader:
    """Small reader for the table-only Lua syntax emitted by SavedVariables."""

    def __init__(self, text: str) -> None:
        self.text = text
        self.index = 0

    def skip(self) -> None:
        while self.index < len(self.text):
            if self.text.startswith("--", self.index):
                newline = self.text.find("\n", self.index + 2)
                self.index = len(self.text) if newline < 0 else newline + 1
            elif self.text[self.index].isspace():
                self.index += 1
            else:
                return

    def take(self, expected: str) -> None:
        self.skip()
        if not self.text.startswith(expected, self.index):
            raise ValueError(f"expected {expected!r} at offset {self.index}")
        self.index += len(expected)

    def string(self) -> str:
        self.skip()
        quote = self.text[self.index]
        if quote not in "\"'":
            raise ValueError(f"expected string at offset {self.index}")
        self.index += 1
        value: list[str] = []
        while self.index < len(self.text):
            char = self.text[self.index]
            self.index += 1
            if char == quote:
                return "".join(value)
            if char != "\\":
                value.append(char)
                continue
            if self.index >= len(self.text):
                break
            escaped = self.text[self.index]
            self.index += 1
            aliases = {"a": "\a", "b": "\b", "f": "\f", "n": "\n", "r": "\r", "t": "\t", "v": "\v"}
            if escaped.isdigit():
                digits = escaped
                while self.index < len(self.text) and len(digits) < 3 and self.text[self.index].isdigit():
                    digits += self.text[self.index]
                    self.index += 1
                value.append(chr(min(int(digits), 255)))
            else:
                value.append(aliases.get(escaped, escaped))
        raise ValueError("unterminated Lua string")

    def identifier(self) -> str:
        self.skip()
        start = self.index
        while self.index < len(self.text) and (self.text[self.index].isalnum() or self.text[self.index] == "_"):
            self.index += 1
        if start == self.index:
            raise ValueError(f"expected identifier at offset {self.index}")
        return self.text[start:self.index]

    def value(self) -> Any:
        self.skip()
        if self.index >= len(self.text):
            raise ValueError("unexpected end of input")
        char = self.text[self.index]
        if char == "{":
            return self.table()
        if char in "\"'":
            return self.string()
        if char.isdigit() or char in "+-.":
            start = self.index
            while self.index < len(self.text) and self.text[self.index] in "+-.0123456789eE":
                self.index += 1
            raw = self.text[start:self.index]
            return float(raw) if any(marker in raw for marker in ".eE") else int(raw)
        name = self.identifier()
        if name == "true":
            return True
        if name == "false":
            return False
        if name == "nil":
            return None
        return name

    def table(self) -> dict[Any, Any]:
        self.take("{")
        result: dict[Any, Any] = {}
        array_index = 1
        while True:
            self.skip()
            if self.index >= len(self.text):
                raise ValueError("unterminated Lua table")
            if self.text[self.index] == "}":
                self.index += 1
                return result
            key: Any | None = None
            checkpoint = self.index
            if self.text[self.index] == "[":
                self.index += 1
                key = self.value()
                self.take("]")
                self.take("=")
            else:
                try:
                    candidate = self.identifier()
                    self.skip()
                    if self.index < len(self.text) and self.text[self.index] == "=":
                        self.index += 1
                        key = candidate
                    else:
                        self.index = checkpoint
                except ValueError:
                    self.index = checkpoint
            parsed = self.value()
            if key is None:
                key = array_index
                array_index += 1
            result[key] = parsed
            self.skip()
            if self.index < len(self.text) and self.text[self.index] in ",;":
                self.index += 1


def read_saved_variables(path: Path) -> dict[Any, Any]:
    text = path.read_text(encoding="utf-8", errors="replace")
    start = text.find("{")
    if start < 0:
        raise ValueError("SavedVariables file contains no table")
    reader = LuaValueReader(text[start:])
    value = reader.value()
    if not isinstance(value, dict):
        raise ValueError("SavedVariables root is not a table")
    return value


def diagnostics_entries(root: dict[Any, Any], all_sessions: bool = False) -> list[dict[str, Any]]:
    global_data = root.get("global")
    diagnostics = global_data.get("diagnostics") if isinstance(global_data, dict) else None
    raw_entries = diagnostics.get("entries") if isinstance(diagnostics, dict) else None
    if not isinstance(raw_entries, dict):
        raw_entries = diagnostics.get("errors") if isinstance(diagnostics, dict) else {}
    entries: list[dict[str, Any]] = []
    if isinstance(raw_entries, dict):
        for key in sorted((key for key in raw_entries if isinstance(key, int))):
            entry = raw_entries[key]
            if isinstance(entry, dict):
                entries.append(entry)
    current_session = diagnostics.get("currentSession") if isinstance(diagnostics, dict) else None
    if current_session and not all_sessions:
        session_entries = [entry for entry in entries if entry.get("session") == current_session]
        # SavedVariables created by builds before session tagging have no
        # session field.  Keep them exportable instead of producing an empty
        # log during the one-time upgrade reload.
        if session_entries:
            return session_entries
    return entries


def find_saved_variables(client_root: Path) -> Path:
    candidates = list((client_root / "WTF" / "Account").glob("*/SavedVariables/ZygorGuidesViewer.lua"))
    if not candidates:
        raise FileNotFoundError("no account-level ZygorGuidesViewer.lua was found below WTF/Account")
    return max(candidates, key=lambda path: path.stat().st_mtime)


def render(entries: list[dict[str, Any]], source: Path) -> str:
    lines = [f"# Zygor diagnostics exported from {source}", f"# entries={len(entries)}"]
    for entry in entries:
        timestamp = str(entry.get("time", "unknown"))
        level = str(entry.get("level", "error"))
        context = str(entry.get("context", "runtime"))
        message = str(entry.get("message", "")).replace("\r\n", "\n").replace("\r", "\n")
        session = str(entry.get("session", "legacy"))
        correlation = str(entry.get("correlation", "legacy"))
        # Keep the long-standing "[level] context: message" prefix intact so
        # existing log searches and tooling continue to work; the session is
        # appended as additional, machine-readable context.
        lines.append(f"{timestamp} [{level}] {context}: {message} [session={session} correlation={correlation}]")
    return "\n".join(lines) + "\n"


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client-root", type=Path, default=Path("/mnt/games/ChromieCraft"))
    parser.add_argument("--saved-variables", type=Path, help="explicit account-level Zygor SavedVariables file")
    parser.add_argument("--output", type=Path, help="output log path (default: <client-root>/Logs/ZygorGuidesViewer.log)")
    parser.add_argument("--all-sessions", action="store_true", help="export retained diagnostics from every client session")
    args = parser.parse_args(argv)
    client_root = args.client_root.resolve()
    source = args.saved_variables.resolve() if args.saved_variables else find_saved_variables(client_root)
    output = args.output.resolve() if args.output else client_root / "Logs" / "ZygorGuidesViewer.log"
    entries = diagnostics_entries(read_saved_variables(source), all_sessions=args.all_sessions)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render(entries, source), encoding="utf-8")
    print(f"Exported {len(entries)} entries to {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
