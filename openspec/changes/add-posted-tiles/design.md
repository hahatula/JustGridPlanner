## Context

Phase 12 (`posted-grid-import`) ends with `ScreenshotImportView.onComplete([String])` returning saved tile paths; nothing consumes them. The `GridPlannerViewModel` (Phase 10) holds items, persists `source == .local` only, and has a mock-backed `refresh()` (`isRefreshing`/`refreshError`, `sync: InstagramSyncService = MockInstagramSyncService()`). Phase 13 of `/docs/08-task-breakdown.md` makes imported tiles into persisted locked posted items and replaces the mock with the manual provider, so posted media truly comes from the screenshot import (`/docs/10-decisions.md` Decision 008).

## Goals / Non-Goals

**Goals:**
- Turn imported tiles into 9 locked posted items, merged below the local planned items, replacing any previous posted block (and deleting its files).
- Persist posted tiles (file-backed) and restore them on launch.
- Implement the `InstagramSyncService` boundary with a manual provider; retire the mock refresh.

**Non-Goals:**
- Real API/auth, new capture UI (Phase 12), reorder/remove of posted items, polished visuals (Phase 14). See proposal Non-goals.

## Decisions

### Decision 1: `importPostedTiles(_:)` owns create → replace → delete-old → persist
- **Choice**: `func importPostedTiles(_ paths: [String])`: build a `GridItem` per path (`source: .instagram`, `gridType`, `localImagePath: path`, generated `id`, `orderIndex` in tile order); delete the image files of the *current* posted items (reusing `LocalStorageService.deleteImage`); set `items = renumbered(items.filter { $0.source == .local } + newPosted)`; `persist()`. Mark a successful import on the settings store (`lastSuccessfulRefreshAt`).
- **Rationale**: One method performs the whole replace so re-import never duplicates or orphans (`posted-tiles`). Filtering to `.local` then appending keeps the planned block on top in order (Decision 007). Reusing Phase 6's file delete avoids accumulating old screenshots.
- **Alternatives**: Append + dedupe — rejected; replace is the documented "refresh" semantics.

### Decision 2: Persist file-backed items; restore posted on launch
- **Choice**: `persist()` saves `items.filter { $0.localImagePath != nil }` (local planned + imported posted). `init` loads the local items synchronously and merges the posted items via the sync service in a `Task` (`await sync.fetchPostedMedia`), so the grid shows planned items immediately and posted items a moment later.
- **Rationale**: Both local and posted tiles are real on-device files, so both should survive a restart (`local-persistence` modified). Loading posted through the service exercises the boundary and matches how a future real API would load (async). `metadata/<grid>.json` already stores `[GridItem]`; it now holds both sources.
- **Alternatives**: Load posted synchronously in `init` from storage — simpler but bypasses the boundary; using the service keeps the seam a real API can replace.

### Decision 3: `ManualInstagramImportService: InstagramSyncService`
- **Choice**: `fetchPostedMedia(forUsername:gridType:) async -> [GridItem]` returns `storage.loadItems(for: gridType).filter { $0.source == .instagram }` (the persisted imported tiles). The username is ignored. Injected as the view model's default `sync` in place of `MockInstagramSyncService`.
- **Rationale**: Implements the `InstagramSyncService` boundary "with the manual-import provider" (`/docs/08` Phase 13) — the read side of posted media is "load what was imported." A future real API replaces this one type with no view-model change (Decision 004/008).
- **Alternatives**: Drop the protocol and read storage directly — loses the documented boundary; rejected.

### Decision 4: Retire the mock refresh; the import button is the refresh
- **Choice**: Remove `refresh(username:)`, `isRefreshing`, `refreshError`, and the `RefreshButton` from the tabs. The Phase-12 `PostedImportButton`'s `onComplete` is wired to `importPostedTiles`; re-running the import is "refresh". `MockInstagramSyncService` is no longer the runtime provider (kept only as a fixture / future reference).
- **Rationale**: "Refresh means re-importing a newer screenshot" (`/docs/06`, `/docs/08` Phase 13). A separate async-reload button would be redundant and misleading now that there is no background fetch. This is why `grid-refresh` loses its fetch-specific requirements.
- **Alternatives**: Keep the refresh button as a reload — redundant with import; rejected.

## Risks / Trade-offs

- **[Risk] Async posted-load on launch shows planned items before posted ones appear.** → Mitigation: loading from local storage is near-instant; acceptable, and avoids blocking `init`.
- **[Risk] Reworking just-shipped Phase 10 refresh is churn.** → Mitigation: it is the intended evolution per the approved docs; the boundary and merge logic are reused, only the trigger and provider change.
- **[Trade-off] Posted items now persist (more files on disk).** → Acceptable and desired; re-import deletes the replaced tiles, and Phase 6's delete handles removed locals.
- **[Note] `MockInstagramSyncService` becomes dormant.** → Kept as a fixture / placeholder for the future real-API path; not wired into the running app.

## Migration Plan

Additive to the model (instagram items may now have a `localImagePath`); the metadata file simply carries more items. Rollback = restore the mock `refresh()`/`RefreshButton`, revert `persist()` to local-only, and drop `importPostedTiles`/`ManualInstagramImportService`. Existing `metadata/<grid>.json` files (local-only) still load.

## Open Questions

- None blocking. Consolidating the import button's label/placement with the account controls is Phase 14 polish.
