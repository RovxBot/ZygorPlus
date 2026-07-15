# Build-12340 release acceptance matrix

This checklist is the live evidence required to change a row in
`release_parity.json` from `live_status: "pending"` to `"passed"`. Record the
client build, package SHA-256, profile type, and `/zgvprobe capture <name>`
checkpoint beside each result. A failed check remains pending with a linked
diagnostic correlation ID; do not mark it passed with a workaround.

| Scenario | Fresh profile | Migrated profile | Required evidence |
| --- | --- | --- | --- |
| Alliance and Horde guide flow | Yes | Yes | Select/advance/branch/include/next; verify catalog count/category/menu history. |
| Viewer and menu visuals | Yes | Yes | Reference-vs-port screenshots: viewer, menu/search, widget, action bar, tooltips; no white/missing texture or clipping. |
| Quest progress | Yes | Yes | Accept, kill, collect, direct combat kill, turn-in; compare counters in viewer/widget/action bar and after reload. |
| Navigation and POI | Yes | Yes | `goto`, multizone, taxi, arrival, map/minimap/arrow bearing, TomTom present and absent, filtered/local-guidance POI. |
| Questie coexistence | Yes | Yes | Questie loaded before/after ZGV; toggle autoaccept/autocomplete during quest and gossip frames; verify no shared-watch mutation. |
| Automation and protected actions | Yes | Yes | Accept/complete/gossip/action bar in and out of combat; inspect deferred-action diagnostics. |
| Talents, trainers, professions | Yes | Yes | Every class including Death Knight; trainer rank/cost/availability, profession and talent/glyph UI. |
| Gear and gold workflows | Yes | Yes | Quest rewards, finder/upgrades/equip safeguard, auction scan, crafting, farming, gathering, shopping and posting. |
| Creature/tutorial/notifications | Yes | Yes | Model controls/fallback, full tutorial completion, toast queue/history and persisted notification entries. |
| Sync v2 | Two matching installs | Two matching installs | Explicit master/slave activation, handshake, follow state, completion, reconnect/resync, content mismatch feedback. |
| Diagnostics and export | Yes | Yes | `/reload` and logout; `/zygor report`; watcher writes atomic log with expected session/correlation IDs. |
| Clean install/package | Yes | N/A | Strict validator, parity gate, deterministic archive SHA, only five release addons enabled. |

Use named capture points such as `viewer-layout`, `questie-on`,
`navigation-taxi`, `trainer-dk`, `auction`, `sync-handshake`,
`sync-mismatch`, and `logout-export`. Screenshots are a required companion to
the passive probe for visual rows; the probe records geometry and API state but
does not capture pixels.
