## Context

After Phase 5 the `GridPlannerViewModel` owns each grid's items, persists local ones, and restores them on launch; `LocalStorageService` saves/loads metadata and image files; `GridCellView` renders a tile (lock badge for Instagram). Nothing can remove an item. Phase 6 of `/docs/08-task-breakdown.md` adds removal of local items plus deletion of their files. `/docs/06-ui-ux-rules.md` calls for a visible delete action on local tiles; `/docs/01-business-logic.md` keeps Instagram items locked.

## Goals / Non-Goals

**Goals:**
- A visible delete control on local tiles; tapping it removes the item, deletes its file, and persists.
- Instagram items remain unremovable (no control, and a guard in the model).
- Keep storage logic in the service and grid state in the view model; `GridPlannerView` stays presentation-only.

**Non-Goals:**
- Confirmation/undo, reorder (Phase 7), Instagram items/sync, edit-mode/multi-select. See proposal Non-goals.

## Decisions

### Decision 1: Always-visible × badge on local tiles
- **Choice**: Local cells render a small tappable × badge (an `xmark` in a circular background) in the top-trailing corner — the same slot the lock badge occupies for Instagram items (the two are mutually exclusive, so they never collide). The badge is a `Button` that calls an `onDelete` closure.
- **Rationale**: Implements `/docs/06-ui-ux-rules.md` ("Local planned items should show delete action") with the most discoverable affordance, per the chosen UX. Reusing the top-trailing slot keeps the layout simple.
- **Alternatives**: Long-press context menu — cleaner preview but less discoverable; edit-mode toggle — extra state. Both rejected in favor of the selected always-visible control.

### Decision 2: `onDelete` closure threads through the presentation views
- **Choice**: `GridCellView` gains `onDelete: (() -> Void)?` — when non-nil it shows the × badge. `GridPlannerView` gains `onDelete: (GridItem) -> Void` and passes `item.isLocked ? nil : { onDelete(item) }` to each cell. The tab views pass `{ viewModel.removeLocalItem($0) }`.
- **Rationale**: Keeps `GridPlannerView`/`GridCellView` presentation-only (data + callbacks, no view-model dependency), consistent with the Phase 3/4 layering. The cell never decides business rules — it only shows the badge when given a delete handler (which the parent supplies only for local items).
- **Alternatives**: Inject the view model into the grid — rejected; couples presentation to the model.

### Decision 3: `removeLocalItem` on the view model owns the sequence
- **Choice**: `GridPlannerViewModel.removeLocalItem(_ item: GridItem)`: `guard !item.isLocked`; call `storage.deleteImage(for: item)`; `items.removeAll { $0.id == item.id }`; renumber; `persist()`.
- **Rationale**: One place performs delete-file → update-state → persist, and the `isLocked` guard is defense-in-depth so an Instagram item can never be removed even if a caller misbehaves. Renumbering preserves the array-index == `orderIndex` invariant used since Phase 4.
- **Alternatives**: Remove in the view, delete file in the view — rejected; storage/business logic belongs in the model/service.

### Decision 4: `LocalStorageService.deleteImage(for:)` is graceful
- **Choice**: `func deleteImage(for item: GridItem)` resolves `imageURL(for:)` and removes the file with `try?` (no throw). Non-local items or a missing file are no-ops.
- **Rationale**: Implements "delete local image files when safe": each import writes a unique `images/<uuid>.jpg`, so no other item shares the file; a missing file must not block removal (`/docs/08`). Keeping it non-throwing means the view model's removal always completes.
- **Alternatives**: Throwing delete with caller handling — rejected; nothing actionable to do on a missing file.

### Decision 5: No confirmation dialog
- **Choice**: Tapping × removes immediately, no confirm.
- **Rationale**: Low-stakes — the item is a copy; the original photo remains in the user's gallery and can be re-imported. Matches the quick, always-visible control. A confirmation can be added in Phase 13 if it proves too easy to mis-tap.

## Risks / Trade-offs

- **[Risk] Accidental tap deletes a planned item and its file.** → Mitigation: non-destructive to the user's real photo (re-importable); revisit confirmation in Phase 13 if needed.
- **[Risk] The × badge adds a control to the otherwise-clean grid preview.** → Mitigation: deliberately chosen for discoverability; it is small and only on local tiles. (Edit-mode remains an option later.)
- **[Trade-off] No undo.** → Acceptable for a personal planning app; out of scope.

## Migration Plan

Additive. Rollback = remove `removeLocalItem`/`deleteImage`, the `onDelete` plumbing, and the × badge; no stored-format change (removal just writes a shorter array via the existing persist path). Already-orphaned files from earlier phases are not retroactively cleaned, but new removals delete their files.

## Open Questions

- None blocking. Confirmation-on-delete is intentionally deferred to Phase 13.
