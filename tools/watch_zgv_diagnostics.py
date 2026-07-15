#!/usr/bin/env python3
"""Watch flushed Zygor SavedVariables and atomically refresh the client log.

Run this beside a development client.  Addons cannot write Logs directly;
after /reload or logout WoW flushes SavedVariables and this host process writes
``Logs/ZygorGuidesViewer.log`` without ever changing addon data.
"""

from __future__ import annotations

import argparse
import os
import tempfile
import time
from pathlib import Path
from typing import Sequence

from export_zgv_diagnostics import diagnostics_entries, find_saved_variables, read_saved_variables, render


def source_signature(path: Path) -> tuple[int, int]:
    stat = path.stat()
    return stat.st_mtime_ns, stat.st_size


def export_once(source: Path, output: Path, all_sessions: bool = False) -> int:
    entries = diagnostics_entries(read_saved_variables(source), all_sessions=all_sessions)
    output.parent.mkdir(parents=True, exist_ok=True)
    rendered = render(entries, source)
    handle_name: str | None = None
    try:
        with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=output.parent, prefix=f".{output.name}.", delete=False) as handle:
            handle.write(rendered)
            handle.flush()
            os.fsync(handle.fileno())
            handle_name = handle.name
        os.replace(handle_name, output)
    finally:
        if handle_name and Path(handle_name).exists():
            Path(handle_name).unlink()
    return len(entries)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client-root", type=Path, default=Path("/mnt/games/ChromieCraft"))
    parser.add_argument("--saved-variables", type=Path, help="explicit account-level Zygor SavedVariables file")
    parser.add_argument("--output", type=Path, help="output log path (default: <client-root>/Logs/ZygorGuidesViewer.log)")
    parser.add_argument("--interval", type=float, default=1.0, help="polling interval in seconds (default: 1)")
    parser.add_argument("--all-sessions", action="store_true", help="export retained diagnostics from every session")
    parser.add_argument("--once", action="store_true", help="export once and exit")
    args = parser.parse_args(argv)
    if args.interval <= 0:
        parser.error("--interval must be positive")
    client_root = args.client_root.resolve()
    output = args.output.resolve() if args.output else client_root / "Logs" / "ZygorGuidesViewer.log"
    explicit_source = args.saved_variables.resolve() if args.saved_variables else None

    last_signature: tuple[Path, tuple[int, int]] | None = None
    while True:
        try:
            source = explicit_source or find_saved_variables(client_root)
            signature = (source, source_signature(source))
            if signature != last_signature:
                count = export_once(source, output, all_sessions=args.all_sessions)
                last_signature = signature
                print(f"Exported {count} entries to {output}")
            if args.once:
                return 0
        except (FileNotFoundError, OSError, ValueError) as exc:
            # A client flush may be observed mid-write.  Do not truncate the
            # last good log; retry the immutable SavedVariables snapshot.
            if args.once:
                print(f"Unable to export diagnostics: {exc}")
                return 1
            print(f"Waiting for readable Zygor diagnostics: {exc}")
        try:
            time.sleep(args.interval)
        except KeyboardInterrupt:
            return 0


if __name__ == "__main__":
    raise SystemExit(main())
