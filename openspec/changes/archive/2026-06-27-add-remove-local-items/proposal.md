## Why

The user can now add and persist local planned items, but there is no way to remove one — a wrong pick stays forever, and Phase 5 leaves the copied image files behind. Phase 6 of `/docs/08-task-breakdown.md` adds removal: a delete control on local tiles, deletion of the backing image file, and persistence of the change. It also closes the orphaned-files gap from Phase 5. Instagram items must stay locked (`/docs/01-business-logic.md`).

## What Changes

- Add an **always-visible delete control (× badge)** in the corner of every **local** tile (`/docs/06-ui-ux-rules.md`: "Local planned items should show delete action"). Tapping it removes that item. Instagram tiles show the existing lock badge and **no** delete control.
- Add **`GridPlannerViewModel.removeLocalItem(_:)`** that guards against removing Instagram items, deletes the item's image file, removes it from the grid, renumbers `orderIndex`, and persists.
- Add **`LocalStorageService.deleteImage(for:)`** that deletes the file referenced by a local item's `localImagePath` (gracefully — a missing file is not an error). Each import writes a unique file, so deleting on removal is always safe.
- Thread an `onDelete` closure from the tab views (which own the view model) through `GridPlannerView` to local cells only, keeping `GridPlannerView` presentation-only.

## Capabilities

### New Capabilities
- `remove-local-items`: Removing a local planned item via a delete control on its tile — deleting the backing image file, updating the grid, and persisting — while keeping Instagram items locked and unremovable.

### Modified Capabilities
<!-- None. Removal is additive; it does not change gallery-import, grid-display, grid-models, local-persistence, or app-shell requirements (local-persistence simply persists the now-shorter list via the existing save path). -->

## Impact

- **Modified code**: `Views/GridCellView.swift` (delete × badge for local items, via an `onDelete` closure), `Views/GridPlannerView.swift` (accept and forward `onDelete` to local cells), `Views/PostsGridView.swift` + `Views/ReelsGridView.swift` (pass `viewModel.removeLocalItem`), `ViewModels/GridPlannerViewModel.swift` (`removeLocalItem`), `Services/LocalStorageService.swift` (`deleteImage(for:)`).
- **Storage**: removing an item deletes its file under `Documents/images/` and rewrites `Documents/metadata/<grid>.json` (via the existing persist path).
- **Dependencies**: none added. SwiftUI + Foundation only.
- **Tech stack**: no deviation from `/docs/02-tech-stack.md`.

## Non-goals

- **No removal of Instagram items** — they are locked (`/docs/01-business-logic.md`); the delete control is never shown for them and `removeLocalItem` ignores them.
- **No confirmation dialog** — removal is low-stakes (the item is a copy; the original stays in the user's gallery and can be re-imported). Can be revisited in Phase 13 if desired.
- **No undo / trash** — a removed item and its file are gone; out of scope.
- **No drag/reorder** — Phase 7.
- **No Instagram sync, refresh, account UI** — Phases 8–10.
- **No bulk delete / edit mode / multi-select** — single-tap per item only.
- Nothing from `/docs/11-out-of-scope.md`.
