# Build-12340 release acceptance matrix

This checklist is the live evidence required to change a row in
`release_parity.json` from `live_status: "pending"` to `"passed"` for a
**stable** release. An alpha may be published as an explicitly labelled GitHub
pre-release while rows remain pending, but it must not relabel or imply that
the outstanding live scenarios have passed. Record the client build, package
SHA-256, profile type, and `/zgvprobe capture <name>` checkpoint beside each
result. A failed check remains pending with a linked diagnostic correlation ID;
do not mark it passed with a workaround.

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

## Capture discipline

`/zgvprobe capture <name>` records the state that already exists at that exact
moment; it does **not** open a window, travel, change a Questie setting, advance
a guide, or exercise a feature. Perform the stated interaction first, leave the
relevant window or route visible where applicable, then capture it. A capture
for `auction`, `trainer-dk`, or `sync-handshake` is not evidence for that row if
the recorded Auction, Trainer, or peer state is absent.

For the current profile, use this minimum order:

1. Open the Viewer menu; use search, open a category, toggle a favourite, then
   revisit it through history. Capture `viewer-menu` while the menu is open and
   retain a screenshot.
2. Accept or advance a real quest, kill/collect one objective, then turn it in.
   Capture `quest-progress` while the objective counter is visible in the
   viewer/widget/action bar.
3. Enable Questie's auto-accept and auto-complete options, open a quest or
   gossip dialog, and capture `questie-on`. Disable them again and capture
   `questie-off`; repeat on a profile where Questie was loaded before ZGV.
4. Open the Blizzard talent window and the Zygor advisor, inspect a build and
   glyph recommendation, then capture `talent-<class>`. Open an actual class or
   profession trainer before `trainer-<class>` / `trainer-profession`.
5. Open the Auction House before `auction`, and capture `gear-gold` only after
   exercising an upgrade/finder result plus the intended gold workflow.
6. Open the taxi map, select or complete a multi-leg route, and retain the map,
   minimap, and arrow screenshots before `navigation-taxi`. Use a separately
   filtered POI before `navigation-poi`.
7. For Sync v2, use two matching New installs and capture after the handshake,
   reconnect/resync, and mismatch feedback—not merely while Sync is inactive.

## Evidence log

### 2026-07-15 — ChromieCraft 3.3.5a build 12340, existing profile

**Status: partial evidence only; no release-parity row is passed by this
entry.** The deployed addon package checksum was not captured, and this is not
a clean-profile or two-client run.

- Probe session 3 recorded seven checkpoints: `viewer-menu`,
  `quest-progress`, `questie-on`, `talent-shaman`, `trainer-profession`,
  `gear-gold`, and `navigation-taxi`.
- The session recorded real client activity: two `QUEST_ACCEPTED`, two
  `QUEST_COMPLETE`, six `QUEST_FINISHED`, 29 `QUEST_LOG_UPDATE`, three
  `GOSSIP_SHOW`, 19 combat enter/leave pairs, six `SKILL_LINES_CHANGED`, and
  one `TAXIMAP_OPENED` event.
- At each named checkpoint ZGV was loaded on the Nagrand (64-65) guide at step
  40, with a direct 112-yard route. Questie was loaded but both automation
  options were false; Sync v2 was inactive (`role=off`, `peers=0`).
- No checkpoint was taken with the talent, trainer, auction, trade-skill,
  quest, or gossip window visible. Consequently these checkpoints do not
  validate those UI/workflow rows, and `questie-on` does not validate Questie
  suppression.
- ZGV diagnostic session `20260715-123915-10287379` contains 111 information
  entries and **zero** errors or warnings. The probe's 105
  `ADDON_ACTION_BLOCKED` events name `CompactRaidFrame` / `CompactPartyFrame`,
  not a ZGV protected action.

The older diagnostics history contains resolved pre-candidate ItemScore,
talent-advisor, inventory, and guide-parser faults. It is retained for
regression investigation but is not evidence of an error in the clean session
above.
