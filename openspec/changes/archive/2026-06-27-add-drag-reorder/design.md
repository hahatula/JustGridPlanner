## Context

The `GridPlannerViewModel` owns each grid's items (local planned on top, Instagram below), maintaining `orderIndex == array position` and persisting local items. `GridPlannerView`/`GridCellView` are presentation-only, fed data plus an `onDelete` closure (Phase 6). Phase 7 of `/docs/08-task-breakdown.md` adds drag-to-reorder for local items. Constraints: only local items are draggable (`/docs/06-ui-ux-rules.md`); Instagram items keep their order and planned items stay on top (`/docs/01-business-logic.md`, `/docs/10-decisions.md` Decision 007).

## Goals / Non-Goals

**Goals:**
- Drag a local tile onto another local tile to reorder it; persist the new order; works per-grid.
- Instagram items are not draggable, not drop targets, and keep their order.
- Keep storage/order logic in the view model; `GridPlannerView`/`GridCellView` stay presentation-only.

**Non-Goals:**
- Live shuffle animation, moving locals below Instagram, cross-grid/multi-item drag, Instagram reordering. See proposal Non-goals.

## Decisions

### Decision 1: `.draggable` / `.dropDestination` drop-to-insert (not a live DropDelegate)
- **Choice**: Local cells get `.draggable(item.id)` (the `String` id is `Transferable`) and `.dropDestination(for: String.self)` that, on drop, calls `onMove(droppedID, item.id)`. Reordering happens once, on drop — no live "items shuffle as you drag" animation.
- **Rationale**: `.draggable`/`.dropDestination` is the modern, robust SwiftUI drag-and-drop API and works in `LazyVGrid` without a custom `DropDelegate` or `@State` drag tracking. Drop-to-insert is simple and reliable; the live-shuffle effect is polish, deferred to Phase 13.
- **Alternatives**: `.onDrag` + a custom `DropDelegate` for live reordering — nicer feel but materially more code and edge cases (especially with the locked-items constraint); rejected for this phase. `.onMove` — only works in `List`, not `LazyVGrid`; not applicable.

### Decision 2: Only local cells are drag sources and drop targets
- **Choice**: `GridCellView` attaches `.draggable`/`.dropDestination` only when it has an `onMove` handler, which `GridPlannerView` supplies only for local items (`item.isLocked ? nil : …`), mirroring the Phase 6 `onDelete` pattern. Instagram cells get neither.
- **Rationale**: Enforces "dragging only works for local items" and "planned on top" structurally — you cannot start a drag on an Instagram tile, and you cannot drop onto one, so a local item can never move into the Instagram region. The cell never decides the rule; the parent does.
- **Alternatives**: Make all cells drop targets and reject invalid drops in the model — rejected; pushing the rule into the cell wiring is simpler and prevents the drop visually.

### Decision 3: `moveLocalItem(withID:beforeID:)` reorders the local block in the view model
- **Choice**: `func moveLocalItem(withID draggedID: String, beforeID targetID: String)`: ignore if equal; resolve both items and require both `!isLocked`; split `items` into `locals` (in order) and `others`; `locals.move(fromOffsets: [from], toOffset: to > from ? to + 1 : to)` so the dragged item lands at the target's position; set `items = renumbered(locals + others)`; `persist()`.
- **Rationale**: One place owns the reorder + renumber + persist, keeping the array-index == `orderIndex` invariant and "local block on top" (locals always precede others). Guarding both ids as local is defense-in-depth even though the UI only offers drags between local tiles.
- **Alternatives**: Mutate an `items` binding from the view — rejected; order/persistence logic belongs in the model.

### Decision 4: `onMove` closure threads through the presentation views
- **Choice**: `GridCellView` gains `var onMove: ((_ draggedID: String) -> Void)?` used by its `.dropDestination`; `GridPlannerView` gains `onMove: (_ draggedID: String, _ targetID: String) -> Void` and supplies each local cell a handler bound to that cell's id. Tab views pass `{ viewModel.moveLocalItem(withID: $0, beforeID: $1) }`.
- **Rationale**: Same presentation-only layering as Phase 6's `onDelete`; the views carry data + callbacks, the model owns state.

## Risks / Trade-offs

- **[Risk] No live shuffle makes the drag feel less "Instagram-like."** → Mitigation: functional drop-to-insert now; live animation is an isolated Phase 13 polish that won't change the model API.
- **[Risk] Dropping "after the last local item" has no obvious target** (drops insert *before* a tile). → Mitigation: acceptable for a small personal grid; can add an end-of-block drop affordance later. Reordering among existing tiles fully covers the common case.
- **[Risk] `LazyVGrid` drag-and-drop can be finicky on first drag.** → Mitigation: use the standard `.draggable`/`.dropDestination` APIs; verify on device/simulator for both tabs.
- **[Trade-off] Persist on every drop.** → Cheap: the metadata is tiny and a drop is a discrete user action (not continuous).

## Migration Plan

Additive. Rollback = remove `moveLocalItem`, the `onMove` plumbing, and the `.draggable`/`.dropDestination` modifiers; no stored-format change (reorder writes the same array in a new order via the existing persist path).

## Open Questions

- None blocking. Live-shuffle animation and an end-of-block drop target are deferred polish (Phase 13).
