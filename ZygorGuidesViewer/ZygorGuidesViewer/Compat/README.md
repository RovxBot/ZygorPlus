# 3.3.5a compatibility layer

Load `Compat.xml` before localization, the guide engine, UI modules, and data
companions. `Bootstrap.lua` creates `ZygorGuidesViewer`/`ZGV` only when neither
already exists, then exposes every game-domain adapter below `ZGV.Compat`.
Blizzard quest, item, map, talent, auction, and chat globals are never replaced.

## Service contract

The compatibility API is versioned by `ZGV.Compat.API_VERSION` (currently `1`).
Read operations return named records; explicit actions return records with at
least `ok` and `code` fields.

- `Client`: build, capability, player, and addon metadata/load records.
- `Timer`: cancellable `NewTimer`, `After`, and `NewTicker` handles driven by a
  single `OnUpdate` frame. `Pump(now)` supports headless tests.
- `Quest`: normalized log entries/objectives and an asynchronous completed-quest
  cache. Call `RefreshCompleted`; inspect `GetCompletion` for `known`, `state`,
  and `stale`. Topics: `QUEST_LOG_CACHE_UPDATED` and
  `QUEST_COMPLETED_CACHE_UPDATED`.
- `Gossip`: normalized option and quest records. `ResolveOption`/`ResolveQuest`
  return `missing` or `ambiguous`; selection never guesses among candidates.
- `Item`, `Container`, `Spell`, `Talent`, and `Profession`: cold-cache-aware
  item data, bag records/actions, pre-6.0 spell tuples, Wrath dual-spec/pet
  talents/glyphs, and legacy profession/trade-skill records.
- `Map`: captures/restores the selected legacy world-map state, resolves stable
  keys through `ZGV.Data.Maps`, reads player coordinates without leaving the map
  changed, and uses `Astrolabe:ComputeDistance` when available.
- `Taxi`: snapshots nodes on `TAXIMAP_OPENED`, retains known nodes, and merges
  optional `ZGV.Data.Taxi` records. Taking a flight is always explicit.
- `Auction`: normalizes the build-12340 auction tuple, honours query throttling,
  and exposes explicit query/bid/post actions.
- `Chat`: validates the 16-byte prefix and legacy 254-byte combined packet limit, wraps
  `RegisterAddonMessagePrefix`/`SendAddonMessage`, and dispatches normalized
  `CHAT_MSG_ADDON` packets. Use `Listen(prefix, owner, method)` for sync.
- `Tooltip`: scans hyperlinks, items, spells, units, and selected quest-log
  items with a dedicated hidden `GameTooltip`; it never reuses `GameTooltip`.
- `UI`: missing-widget-method helpers, a checked-in atlas registry hook,
  eight-coordinate texture rotation, secure button construction, and keyed
  operations deferred until `PLAYER_REGEN_ENABLED`.

`ZGV.Compat:On(topic, owner, method)` and `:Off(token)` provide the common local
callback bus. The event dispatcher and timers report callback errors through
the client's error handler without aborting other consumers.

## Runtime assumptions

- Stock Wrath of the Lich King 3.3.5a, interface `30300`, build `12340`.
- `QueryQuestsCompleted` is rate-limited and only becomes readable after
  `QUEST_QUERY_COMPLETE`; the last successful table remains available as stale
  data after a timeout or query error.
- Legacy gossip tuples have no stable gossip-option or quest IDs. Text/index
  matching is re-evaluated immediately before selection, and duplicate text is
  intentionally rejected unless the caller also supplies an index.
- World-map APIs mutate global selection. The map service restores area/zoom and
  dungeon floor after temporary coordinate queries, although the client may
  still emit `WORLD_MAP_UPDATE` while that happens.
- Taxi node APIs contain useful data only while the taxi map is open. Static
  nodes and cross-map routes belong in the versioned `ZGV.Data` datasets.
- Item information can be absent until the client cache receives it. `Item` uses
  bounded polling because build 12340 has no dependable modern item-load API.
- Protected actions still require a hardware event where Blizzard requires one.
  Deferring frame attributes until combat ends prevents taint but cannot create
  permission to automate a protected action.
- Questie's **Options > Auto > Auto Accept Quests** and **Auto Complete Quests**
  settings own their corresponding NPC quest dialogs when enabled. Zygor then
  suppresses overlapping quest and gossip actions without changing either
  addon's saved settings; its automation resumes when those Questie settings are
  disabled. Questie defaults both settings to disabled.
