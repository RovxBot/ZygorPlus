# Zygor 3.3.5a development tools

These tools are intentionally separate from the release addons. The port auditor
and validator are read-only; the packager reads only explicitly whitelisted addon
roots; and the capability probe is a development addon that is disabled by
default. Packaging never modifies an addon source tree and rejects an output path
inside one.

`release.json` selects the deployable directories below `ZygorGuidesViewer`.
The adjacent upstream source/reference files remain available for porting work,
but are deliberately excluded from the 3.3.5a release when they require modern
XML or APIs.

## Audit the source port inventory

Run the deterministic source-to-target inventory gate from the repository root:

```bash
python3 tools/audit_port.py
```

The auditor hashes every file below `ZygorGuidesViewerClassicTBCAnniv` and
automatically recognizes an identical data/media payload anywhere in the five
release addon roots. Lua and XML are stricter: an identical copy counts as
`exact` only when it is reachable from that addon's real TOC/XML load closure.
Dormant reference code therefore still needs an explicit replacement or
exclusion disposition. Every remaining source file must match exactly one rule
in `tools/port_dispositions.json`. The command fails when a source file is
unclassified, rules overlap, a rule no longer matches a file requiring a
disposition, an executable replacement is not in the load closure, a declared
source/replacement path is missing or mis-cased, or the expected 864-file source
inventory changes.

Disposition meanings are deliberately strict:

- `adapted`: the source payload was intentionally changed for this port and the
  declared target file exists.
- `replaced`: an obsolete source artifact has a concrete declared successor.
- `intentional_exclusion`: the file has a reviewed reason not to ship or load.
- `pending`: physical or candidate replacement code exists, but functional
  parity has not been proved. Pending work is accounted for without claiming it
  is complete.

The default command gates inventory integrity while reporting the pending count.
Use the stricter completion policy when CI must reject any unresolved port work:

```bash
python3 tools/audit_port.py --fail-on-pending
```

Machine-readable CI output is available without writing a report file:

```bash
python3 tools/audit_port.py --json
```

## Validate the bundle

From the repository root:

```bash
python3 tools/validate_addons.py
```

The default roots come from `tools/release.json`. The validator checks:

- every release-selected top-level TOC targets interface `30300` and every
  TOC/XML file reference exists with exact on-disk capitalization; required
  dependencies must be in the bundle whitelist and XML must be well-formed;
- release-selected Lua source for retail/TBC API leakage outside a `Compat` directory and for
  syntax constructs unavailable to Lua 5.1;
- XML for unsupported mixins, `parentKey`, `KeyValues`, mask/atlas attributes,
  and modern inherited templates;
- Lua syntax with `luac5.1` or `lua5.1` when either executable is installed;
- TGA and BLP headers, dimensions, power-of-two status, and unusually large
  textures;
- statically registered guide/include names, duplicate definitions, `next`,
  `leechsteps`, and `include` references.

`catalog_runtime_groups` in `release.json` models the two real load graphs
(Common + Alliance and Common + Horde), so equivalent faction-specific guide
titles are not falsely reported as simultaneously loaded duplicates. The two
`guide_registration_filters` mirror the checked-in legacy Wrath wrappers, so only
their accepted registrations and links enter each catalog. A filter may accept a
simple `title_prefix`, or further restrict the first guide-title path component
with `allowed_first_segments`; the latter models the Wrath daily category
whitelists. Expected counts are five leveling guides per faction, 69 Alliance
daily guides, and 63 Horde daily guides.

Useful variants:

```bash
# Machine-readable CI, texture, and guide-catalog report (printed to stdout)
python3 tools/validate_addons.py --json

# Full texture inventory
python3 tools/validate_addons.py --texture-report

# Treat reporting warnings as CI failures
python3 tools/validate_addons.py --strict

# Inspect one tree without changing release.json
python3 tools/validate_addons.py --addon ZygorGuidesViewer
```

Exit status is nonzero for validation errors, and also for warnings under
`--strict`. Static guide scanning is deliberately conservative: dynamic guide
names cannot be proven. If a real release guide is dynamic, convert it to a stable
literal registration rather than weakening the release gate.

## Build a private release

Review and update the version in `tools/release.json`, then inspect the exact file
set before writing anything:

```bash
python3 tools/package_release.py --dry-run
```

Create the deterministic archive and adjacent SHA-256 file:

```bash
python3 tools/package_release.py
```

Output defaults to `tools/dist/ZygorGuidesViewer-WotLK-<version>.zip`. ZIP entry
order and timestamps are fixed, so unchanged inputs produce an identical digest.
The package contains only `addon_roots` from `release.json`; `@eaDir`, development
folders, tests, source-art files, editor backups, logs, and Python files are
excluded. Symlinks are rejected. Packaging is blocked when validation or the
feature-parity gate has errors. `--skip-validation` exists only to inspect
incomplete development bundles and must not be used for a release.

## Create a GitHub release

The **Create release** GitHub Actions workflow is the public release profile.
It is intentionally manual. Before triggering it, commit and push the final
sources with a semantic version (for example `0.1.13`) in `release.json`, then
select that commit's branch in **Actions → Create release → Run workflow**. The
workflow derives and checks availability of the matching `v0.1.13` tag, runs the complete
automated suite and strict validation/parity gates, builds the deterministic ZIP
and checksum, preserves them as workflow artifacts, creates and pushes an
annotated release tag, then creates the GitHub Release with generated notes. It
refuses an existing release or tag and never creates a tag until every gate has
passed.

The workflow requires the repository's Actions `GITHUB_TOKEN` to have
**Contents: write** permission. It never publishes if the strict parity registry
still has a pending live-client scenario.

## Feature-parity release gate

`release_parity.json` records every active Classic Anniversary capability with
its WotLK implementation, automated evidence, and a specific live-client
scenario. It complements the source-file audit: accounting for a source file is
not proof that an interaction works on a 3.3.5a client.

```bash
# Development: check the registry and automated evidence.
python3 tools/check_release_parity.py --allow-live-pending

# Release: also require every recorded live scenario to be marked passed.
python3 tools/check_release_parity.py
```

The deterministic packager runs the strict form automatically. Update a row's
`live_status` only after its stated fresh/migrated-profile scenario has actually
passed, preventing an untested client interaction from shipping.

The complete fresh/migrated profile matrix, expected probe captures, and visual
baseline requirements are in [release_acceptance.md](release_acceptance.md).

## Run the build-12340 capability probe

1. Copy `tools/ZGV335Probe` into the client's `Interface/AddOns` directory.
2. Enable **ZGV 3.3.5a Capability Probe** at the character-selection addon screen.
   It is disabled by default because it is not part of the release.
3. Log in, open the quest log, gossip, taxi, merchant, bank, talent/glyph,
   profession, and Auction House frames, and change zones at least once.
4. Run `/zgvprobe snapshot`, then `/reload` or log out normally to flush
   SavedVariables.
5. Preserve
   `WTF/Account/<account>/SavedVariables/ZGV335Probe.lua` as the capability report.

Commands:

- `/zgvprobe show` prints a compact build/API/event summary.
- `/zgvprobe snapshot` refreshes API, widget, and texture-method capabilities.
- `/zgvprobe capture <name>` records a named release-matrix checkpoint with
  viewer/arrow geometry, guide state, navigation bearing, Questie settings,
  sync role/peer count, and auction/talent/trainer/profession window state.
- `/zgvprobe events on|off` controls passive safe-event recording.
- `/zgvprobe note <text>` adds a short test note to the current session.
- `/zgvprobe clear` removes prior probe sessions and immediately starts a new one.

The probe retains at most ten sessions. It records event argument types and short
scalar samples, not chat traffic. It never accepts/turns in quests, selects
gossip, uses taxis, learns talents, sends messages, configures a secure action, or
clicks protected controls. Texture file dimensions are an offline concern and are
reported by `validate_addons.py`; the in-client probe checks widget methods,
built-in texture loading, and four/eight-coordinate `SetTexCoord` behavior.

## Export in-game diagnostics

The WoW 3.3.5a sandbox cannot write to arbitrary files, including `Logs/`.
Zygor therefore persists structured runtime, navigation, and progress entries in
its SavedVariables. After `/reload` or logout flushes them, export a readable
client log with:

```bash
python3 tools/export_zgv_diagnostics.py --client-root /mnt/games/ChromieCraft
```

This writes `/mnt/games/ChromieCraft/Logs/ZygorGuidesViewer.log`. Use `/zygor
report` for the same diagnostics in game.

For automatic development export after every flushed `/reload` or logout, keep
the host watcher running in another terminal:

```bash
python3 tools/watch_zgv_diagnostics.py --client-root /mnt/games/ChromieCraft
```

The watcher tolerates a SavedVariables file observed mid-flush and atomically
replaces the log so readers never see a partial report. Use `--once` for one
atomic export.

## Tool self-tests

```bash
python3 -m unittest discover -s tools/tests -v
```
