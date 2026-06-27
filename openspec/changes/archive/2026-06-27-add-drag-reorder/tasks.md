## 1. Confirm scope before changing files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm there is no reorder yet (`grep -RIn "draggable\|dropDestination\|moveLocalItem\|onMove" InstagramGridPlanner/` returns nothing) and that local cells already have the `onDelete` pattern to mirror. Record in apply notes.
  - **Acceptance**: One-line note "No reorder yet; mirror the onDelete plumbing."
- [x] 1.2 Confirm scope: drag-reorder **local** items within the top block only, Instagram locked, persist the order — explicitly NOT moving locals below Instagram, live-shuffle animation, cross-grid/multi-item drag, or sync (Phases 8–10).
  - **Acceptance**: Scope restated in apply notes.

## 2. Add `moveLocalItem(withID:beforeID:)` to `GridPlannerViewModel`

- [x] 2.1 Add `func moveLocalItem(withID draggedID: String, beforeID targetID: String)`: return if `draggedID == targetID`; resolve both items in `items` and require both `!isLocked`; split into `locals` (order preserved) and `others`; move the dragged local to the target's index (`locals.move(fromOffsets: [from], toOffset: to > from ? to + 1 : to)`); set `items = renumbered(locals + others)`; `persist()`.
  - **Acceptance**: Moving a local item changes its position among the locals, keeps Instagram items in their relative order below, renumbers `orderIndex`, and rewrites the metadata file. A move referencing an Instagram id is a no-op.

## 3. Make local cells draggable drop targets in `GridCellView`

- [x] 3.1 Add `var onMove: ((_ draggedID: String) -> Void)?` to `GridCellView`. When non-nil, attach `.draggable(item.id)` (the `String` id) and `.dropDestination(for: String.self) { ids, _ in if let first = ids.first { onMove(first) }; return true }`.
  - **Acceptance**: A cell given `onMove` is draggable and accepts a dropped id; a cell without it (Instagram) is neither draggable nor a drop target.
- [x] 3.2 Keep the existing `onDelete` × badge and lock badge unchanged; ensure the drag does not interfere with the × button tap.
  - **Acceptance**: Local cells still show the × and are draggable; Instagram cells still show the lock and are inert.

## 4. Wire `GridPlannerView` and the tabs

- [x] 4.1 Add `let onMove: (_ draggedID: String, _ targetID: String) -> Void` to `GridPlannerView`; pass each local cell `onMove: item.isLocked ? nil : { onMove($0, item.id) }` and `nil` for Instagram cells.
  - **Acceptance**: Local cells get a move handler bound to their own id; Instagram cells get `nil`.
- [x] 4.2 In `PostsGridView` and `ReelsGridView`, pass `onMove: { viewModel.moveLocalItem(withID: $0, beforeID: $1) }` to `GridPlannerView`.
  - **Acceptance**: Dragging a local tile onto another on either tab reorders that grid.

## 5. Build and verify

- [x] 5.1 Add a temporary `#if DEBUG` sanity check on a `posts` view model: add three local images, capture their ids, `moveLocalItem` the first to the third's position, and assert the local order changed as expected, Instagram placeholders kept their relative order below the locals, every local is still above every Instagram, and a fresh `posts` view model restores the new order. Also assert a move with an Instagram id is a no-op.
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 5.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 5.3 Manual test in the simulator (both tabs):
  - **Manual test**:
    1. Import 2–3 images on Posts so there are several local tiles on top.
    2. Long-press a local tile and drag it onto another local tile; on release it takes that position; the others shift.
    3. Confirm an Instagram tile cannot be dragged and is not a drop target (a local item cannot be placed below the Instagram block).
    4. Relaunch — the new order persists.
    5. Repeat on the Reels tab; confirm Posts order is unaffected.
- [x] 5.4 Remove the temporary sanity check from 5.1 and rebuild.
  - **Acceptance**: Production code contains only the intended changes; build still succeeds.

## 6. Negative checks

- [x] 6.1 Confirm no later-phase concerns leaked in: `grep -RIn "InstagramSyncService\|AppSettings\|selectedInstagramUsername" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: No sync/settings code.
- [x] 6.2 Confirm the locked guard: `moveLocalItem` early-returns when either id resolves to an `isLocked` item (covered by the 5.1 assertion and visible in the diff).
  - **Acceptance**: Instagram items provably cannot be reordered.

## 7. Source control & reporting

- [x] 7.1 Stage the modified files.
  - **Acceptance**: `git status` shows `GridPlannerViewModel.swift`, `GridCellView.swift`, `GridPlannerView.swift`, `PostsGridView.swift`, `ReelsGridView.swift` modified.
- [x] 7.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps (both tabs), known limitations (drop-to-insert, no live shuffle; no drop after last local; planned stay on top), and which requirements remain (Phases 8–13).
  - **Acceptance**: Summary lists changed files and confirms the `reorder-local-items` scenarios pass.
- [x] 7.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; import a few images; long-press + drag one local tile onto another to reorder; confirm Instagram tiles don't move and the order persists after relaunch, on both tabs.
  - **Acceptance**: A reader can follow the guide to exercise reordering end-to-end.
