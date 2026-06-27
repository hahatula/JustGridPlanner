## Why

Phase 4 lets the user import images, but the grid lives only in memory — relaunch the app and every imported item is gone (the copied files orphan on disk). Phase 5 of `/docs/08-task-breakdown.md` makes planned items durable: save the grid metadata locally, load it on launch, and degrade gracefully when a file is missing or corrupted. This delivers the long-promised "persist after app restart" requirement (`/docs/03-requirements.md`) and is the foundation for remove (Phase 6), reorder (Phase 7), and the refresh merge (Phase 10).

## What Changes

- Extend **`LocalStorageService`** with grid-metadata methods: `saveItems(_:for:)` writes a grid's items to a JSON file under `Documents/metadata/<grid>.json`, and `loadItems(for:)` reads them back — returning an empty list (never crashing) when the file is missing or corrupted (`/docs/02-tech-stack.md`: local JSON metadata).
- Persist **local planned items only**. Per `/docs/01-business-logic.md`, local items are "stored locally on device" while Instagram items are "refreshed from Instagram sync" — so only the user's local items are written to disk; Instagram items are not persisted (they will come from sync in Phase 9).
- **`GridPlannerViewModel`** loads its persisted local items on init and saves after every mutation (currently `addLocalImages`). In DEBUG it still seeds the sample **Instagram placeholders** for visual context; the sample *local* items become preview-only.
- Encode/decode `GridItem` JSON with **ISO-8601 dates** to match the documented format (`/docs/05-data-model.md`).
- **Handle missing/corrupted local files gracefully**: corrupt/absent metadata loads as empty; a local item whose image file is missing keeps showing the placeholder (already handled in `GridCellView`) and is not auto-deleted.

## Capabilities

### New Capabilities
- `local-persistence`: Saving each grid's local planned items to on-device JSON, loading them on launch, keeping the imported image files, and tolerating missing/corrupted files — so planned items survive app restarts.

### Modified Capabilities
<!-- None. Persistence is additive; no existing requirement (gallery-import, grid-display, grid-models, app-shell) changes behavior or is contradicted. -->

## Impact

- **Modified code**: `InstagramGridPlanner/Services/LocalStorageService.swift` (add `saveItems`/`loadItems` + a JSON encoder/decoder configured for ISO-8601), `InstagramGridPlanner/ViewModels/GridPlannerViewModel.swift` (load on init, persist on mutation, seed only Instagram placeholders in DEBUG).
- **Incidental fix** (found while verifying restored images): `Views/GridPlannerView.swift` and `Views/GridCellView.swift` — give each tile an exact size (computed via `GeometryReader`) and render the image with a `UIImageView`-backed aspect-fill, because SwiftUI's `Image.scaledToFill()` mis-sized image cells inside `LazyVGrid` for some imported JPEGs. This makes the `gallery-import` "image fills the tile" requirement reliably hold; no spec change.
- **New files**: none in the app target (only new on-disk artifacts: `Documents/metadata/posts.json`, `Documents/metadata/reels.json`).
- **Storage**: image files unchanged (`Documents/images/`); metadata added under `Documents/metadata/`.
- **Dependencies**: none added. Foundation `Codable`/`JSONEncoder` only.
- **Tech stack**: matches `/docs/02-tech-stack.md` (local JSON metadata; no SwiftData, no backend).

## Non-goals

- **No remove/delete** of items or image files — Phase 6 (`LocalStorageService` will get a delete method then).
- **No drag/reorder** persistence beyond what `orderIndex` already captures — Phase 7 (interleaving local items below Instagram items is revisited there).
- **No Instagram sync, mock, or refresh** — Phases 9/10. Instagram items are not persisted; sample placeholders remain DEBUG-only.
- **No `AppSettings` persistence** (`selectedInstagramUsername`, `lastSuccessfulRefreshAt`, `activeGridType`) — Phase 8.
- **No migration / schema-versioning** of the JSON — greenfield format; if decoding fails the grid starts empty (acceptable for a personal app, no prior data).
- **No SwiftData / database** — explicitly deferred (`/docs/02-tech-stack.md`).
- **No iCloud / cross-device sync, no backup** — out of scope (`/docs/11-out-of-scope.md`).
- Nothing else from `/docs/11-out-of-scope.md`.
