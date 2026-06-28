## Why

Phase 12 captures a screenshot and produces 9 tile images, but nothing puts them in the grid yet. Phase 13 of `/docs/08-task-breakdown.md` finishes the manual-import path: turn those tiles into **locked posted grid items**, merge them below the local planned items, persist them, and make **"refresh" mean re-importing a newer screenshot** — replacing the development mock with the real (manual) provider behind the `InstagramSyncService` boundary (`/docs/10-decisions.md` Decision 008).

## What Changes

- Add a **`ManualInstagramImportService: InstagramSyncService`** that implements the boundary by returning the **persisted imported posted tiles** for a grid (the future real-API implementation would replace it without UI changes).
- Add **`GridPlannerViewModel.importPostedTiles(_:)`**: build 9 locked items (`source = .instagram`, `localImagePath` = each tile) from the imported paths, replace the grid's posted block (`renumbered(localItems + postedTiles)` — planned-on-top, Decision 007), delete the previous posted tiles' image files, and persist. Set `lastSuccessfulRefreshAt`.
- **Wire Phase 12's import** (`PostedImportButton` / `ScreenshotImportView.onComplete`) to `importPostedTiles`.
- **Persist posted tiles**: the view model now persists items **backed by a local file** (local planned + imported posted), and restores them on launch (posted via the service, async).
- **Replace the Phase 10 mock refresh**: remove the mock-backed `RefreshButton` and `refresh()`; the import button is now the single control for updating posted media ("refresh" = re-import). `MockInstagramSyncService` is retired from the active flow (the boundary stays for a future real API).

## Capabilities

### New Capabilities
- `posted-tiles`: Imported screenshot tiles become locked posted grid items, merged below the local planned items, replaced on re-import, and persisted across launches.

### Modified Capabilities
- `local-persistence`: persistence now keeps **items backed by a local file** (local planned *and* imported posted), not only `source == .local` items.
- `grid-refresh`: "refresh" now means **re-importing a screenshot** (the manual import), replacing the async mock fetch; the fetch-specific requirements (account-required, async failure/error, loading spinner) move to the import flow (`posted-grid-import`) and `posted-tiles`.

## Impact

- **New code**: `Services/ManualInstagramImportService.swift`.
- **Modified code**: `ViewModels/GridPlannerViewModel.swift` (`importPostedTiles`, persist file-backed items, load posted on launch, drop `refresh`/`isRefreshing`/`refreshError`/mock default), `Views/PostsGridView.swift` + `Views/ReelsGridView.swift` (wire the import button's `onComplete`; remove the `RefreshButton`).
- **Removed from active use**: `Views/RefreshButton.swift` and `MockInstagramSyncService` as the runtime provider (files may remain as future-API scaffolding / fixtures).
- **Storage**: posted tiles persist in `metadata/<grid>.json` alongside local items (all are file-backed). Re-import deletes the old tile files (no orphans). `GridItem` instagram items may now carry a `localImagePath` (`/docs/05-data-model.md`).
- **Dependencies**: none added.
- **Tech stack**: matches `/docs/02-tech-stack.md`; honors `/docs/07-agent-workflow.md` (manual import, no API/scraping/login).

## Non-goals

- **No real Instagram API / networking / auth** — Phase 12 (OUTDATED) / future; the boundary is kept for it.
- **No new capture UI** — the screenshot capture/crop/split is Phase 12; this phase only consumes its output.
- **No reordering or removing of posted items** — they stay locked (no drag, no delete) per `/docs/01-business-logic.md`; only re-import replaces them.
- **No partial updates** — a re-import replaces all 9 posted tiles for that grid.
- **No polished empty/loading/error visuals** — Phase 14.
- Nothing from `/docs/11-out-of-scope.md`.
