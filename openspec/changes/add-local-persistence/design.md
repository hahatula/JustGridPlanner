## Context

Phase 4 added `LocalStorageService` (image files only) and `GridPlannerViewModel` (in-memory items, DEBUG-seeded from `SampleData`, mutated by `addLocalImages`). Nothing is written for the item list, so imports vanish on relaunch. Phase 5 of `/docs/08-task-breakdown.md` adds JSON metadata save/load. `/docs/02-tech-stack.md` fixes the approach (local JSON metadata + image files in Documents; SwiftData explicitly later). `/docs/05-data-model.md` shows ISO-8601 dates. `/docs/01-business-logic.md` separates local items (stored locally) from Instagram items (refreshed from sync).

## Goals / Non-Goals

**Goals:**
- Save each grid's local items to JSON and restore them on launch so imports survive restarts.
- Tolerate missing/corrupted metadata and missing image files without crashing.
- Keep the storage concern in `LocalStorageService`, out of the views and the model.

**Non-Goals:**
- Remove/delete (Phase 6), reorder persistence semantics with Instagram interleaving (Phase 7), Instagram sync/persistence (Phase 9), `AppSettings` (Phase 8), schema migration, SwiftData, cloud/backup. See proposal Non-goals.

## Decisions

### Decision 1: Persist local items only, one JSON file per grid
- **Choice**: Save items with `source == .local` to `Documents/metadata/<gridType>.json` (`metadata/posts.json`, `metadata/reels.json`) as a JSON array of `GridItem`.
- **Rationale**: `/docs/01-business-logic.md` treats local items as the on-device user data and Instagram items as sync-derived; persisting Instagram (currently mock) items would store data that Phase 9 sync will replace. One file per grid matches the independent-grids model (`/docs/01`) and the per-grid `GridPlannerViewModel`.
- **Alternatives**: Persist the whole list (local + Instagram) — rejected; stores soon-to-be-replaced mock data and contradicts the business model. A single combined file — rejected; per-grid files are simpler for a per-grid view model.

### Decision 2: Extend `LocalStorageService` with `saveItems`/`loadItems`
- **Choice**: `func saveItems(_ items: [GridItem], for gridType: GridType) throws` (creates `metadata/`, writes atomically) and `func loadItems(for gridType: GridType) -> [GridItem]` (returns `[]` on missing file or any decode error — non-throwing). A shared `JSONEncoder`/`JSONDecoder` configured with `.iso8601` date strategy.
- **Rationale**: Keeps file I/O in the documented `LocalStorageService` (`/docs/04`). `loadItems` returning `[]` directly encodes the "handle missing/corrupted gracefully" requirement at the boundary, so callers never deal with load errors. ISO-8601 matches `/docs/05` and is portable/human-readable.
- **Alternatives**: Throwing `loadItems` — rejected; every caller would reimplement the same empty-on-failure fallback. Default (numeric) date encoding — rejected; diverges from the documented format.

### Decision 3: View model loads on init and saves after each mutation
- **Choice**: `GridPlannerViewModel.init` sets `items` to the loaded local items (sorted by `orderIndex`) plus, in DEBUG only, the sample **Instagram placeholders**, then renumbers (local on top). A private `persist()` writes `items.filter { $0.source == .local }` via `storage.saveItems`, called at the end of `addLocalImages` (and future mutations).
- **Rationale**: Loading at init satisfies "load on launch"; persisting in mutation methods keeps writes explicit and avoids a write on every launch. Filtering to local in one place enforces Decision 1. Keeping Instagram placeholders in DEBUG preserves visual context until Phase 9 sync provides real ones; the sample *local* items become preview-only (they were a stand-in that persistence now supersedes).
- **Alternatives**: A `didSet` on `items` to auto-persist — rejected; it would also fire during init (writing on launch) and needs guarding. Persist from the view — rejected; storage in the UI layer.

### Decision 4: Missing/corrupted files degrade, never delete
- **Choice**: Corrupted/absent metadata → `loadItems` yields `[]`. A restored local item whose image file is gone stays in the grid and shows the placeholder (already the `GridCellView` behavior — `UIImage(contentsOfFile:)` returns `nil`). The app never auto-deletes items for missing files in this phase.
- **Rationale**: Directly implements "handle missing/corrupted local files gracefully" (`/docs/08`). Non-destructive: a temporarily unreadable file must not lose the user's planned item; explicit removal is Phase 6.
- **Alternatives**: Prune items with missing files on load — rejected; risks deleting user data on transient errors and pre-empts Phase 6.

## Risks / Trade-offs

- **[Risk] Orphaned image files** (Phase 4 imports written before this phase, or future removed items) accumulate in `Documents/images/`. → Mitigation: harmless for a personal app; Phase 6 introduces file deletion. Not addressed here.
- **[Risk] A corrupt metadata file silently loses persisted items** (loads as empty). → Mitigation: acceptable for a personal, no-prior-data app; atomic writes minimise corruption. Schema versioning/migration is a documented non-goal.
- **[Trade-off] Synchronous JSON writes on the main actor after import.** → Acceptable: the metadata is small (a handful of items); image encoding (the heavier work) already happened in `saveImageData`.
- **[Trade-off] DEBUG grid no longer shows sample *local* items in the running app** (only Instagram placeholders + real imported items). → Acceptable and more honest; previews still use full `SampleData`.

## Migration Plan

Greenfield format — no prior metadata files exist, so first `loadItems` returns `[]`. Rollback = delete `saveItems`/`loadItems` and revert the view model init; on-disk `metadata/` files are simply ignored. Image files and their format are unchanged.

## Open Questions

- None blocking. The `metadata/<grid>.json` layout and ISO-8601 encoding are settled here; reorder/refresh interaction with persistence is a Phase 7/10 concern.
