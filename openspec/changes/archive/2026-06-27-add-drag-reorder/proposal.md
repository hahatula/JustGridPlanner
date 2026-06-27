## Why

Local planned items can be added, persisted, and removed, but their order is fixed (newest-first). Planning a grid is fundamentally about arranging upcoming posts, so the user needs to reorder them. Phase 7 of `/docs/08-task-breakdown.md` adds drag-to-reorder for local planned items, keeps Instagram items locked in place, and persists the new order. Per `/docs/06-ui-ux-rules.md` only local items may be dragged, and per `/docs/10-decisions.md` Decision 007 planned items stay on top.

## What Changes

- Make **local tiles draggable** and let the user drop one onto another local tile to reorder it. Reordering happens **only within the local (planned) block** that sits on top; Instagram tiles are not draggable and are not drop targets, so they keep their original order and planned items stay above them (`/docs/01-business-logic.md`, `/docs/10-decisions.md` Decision 007).
- Add **`GridPlannerViewModel.moveLocalItem(withID:beforeID:)`** that reorders the local items (guarding that both the dragged and target items are local), renumbers `orderIndex`, and persists.
- Thread an `onMove` closure from the tab views through `GridPlannerView`; attach `.draggable`/`.dropDestination` to local cells only, keeping `GridPlannerView` presentation-only.
- Persisted order means a reorder survives an app restart, validated independently on the Posts and Reels tabs.

## Capabilities

### New Capabilities
- `reorder-local-items`: Drag-and-drop reordering of local planned items within the top block, with Instagram items locked in place and the new order persisted.

### Modified Capabilities
<!-- None. Reorder is additive: it changes orderIndex values that grid-display already sorts by, persists via the existing local-persistence save path, and does not alter gallery-import, remove-local-items, grid-models, or app-shell requirements. -->

## Impact

- **Modified code**: `Views/GridCellView.swift` (make local tiles a drag source + drop target via an `onMove` closure), `Views/GridPlannerView.swift` (accept and forward `onMove` to local cells), `Views/PostsGridView.swift` + `Views/ReelsGridView.swift` (pass `viewModel.moveLocalItem`), `ViewModels/GridPlannerViewModel.swift` (`moveLocalItem(withID:beforeID:)`).
- **Storage**: a reorder rewrites `Documents/metadata/<grid>.json` via the existing persist path; no new files or format change.
- **Dependencies**: none added. SwiftUI drag-and-drop (`.draggable`/`.dropDestination`) only.
- **Tech stack**: no deviation from `/docs/02-tech-stack.md`.

## Non-goals

- **No reordering of Instagram items** — they are locked and keep their Instagram order (`/docs/01-business-logic.md`); they are neither draggable nor drop targets.
- **No moving a local item below Instagram items** — planned items stay on top (`/docs/10-decisions.md` Decision 007); only intra-local reordering is supported.
- **No live "shuffle" animation while dragging** — this phase reorders on drop (drag a tile, release on a destination tile). A live-reordering animation is optional polish for Phase 13.
- **No cross-grid drag** (Posts ↔ Reels), no multi-item drag.
- **No Instagram sync/refresh, account UI** — Phases 8–10.
- Nothing from `/docs/11-out-of-scope.md`.
