## 1. Confirm scope before changing files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm there is no removal yet (`grep -RIn "removeLocalItem\|deleteImage\|onDelete" InstagramGridPlanner/` returns nothing) and that `GridCellView` currently shows only the lock badge. Record in apply notes.
  - **Acceptance**: One-line note "No removal yet."
- [x] 1.2 Confirm scope: add delete control + file deletion + persisted removal for **local** items only — explicitly NOT reorder (Phase 7), Instagram removal/sync (Phases 9–10), confirmation/undo, or multi-select.
  - **Acceptance**: Scope restated in apply notes.

## 2. Add file deletion to `LocalStorageService`

- [x] 2.1 Add `func deleteImage(for item: GridItem)`: resolve `imageURL(for:)` and remove the file with `try?` (no throw). A non-local item or a missing file is a safe no-op.
  - **Acceptance**: Deleting an existing local item's file removes it; calling for an Instagram item or a missing file does nothing and does not crash.

## 3. Add `removeLocalItem` to `GridPlannerViewModel`

- [x] 3.1 Add `func removeLocalItem(_ item: GridItem)`: `guard !item.isLocked` (ignore Instagram), call `storage.deleteImage(for: item)`, remove it from `items` by `id`, renumber `orderIndex`, then `persist()`.
  - **Acceptance**: Removing a local item drops it from `items`, deletes its file, renumbers the rest, and rewrites the metadata file. Calling with an Instagram item is a no-op (item stays, nothing deleted).

## 4. Add the delete control to `GridCellView`

- [x] 4.1 Add `let onDelete: (() -> Void)?` to `GridCellView`. When non-nil, overlay a tappable × badge (`xmark` in a circular background) in the **top-trailing** corner — the same slot the lock badge uses (they are mutually exclusive: Instagram → lock, local → ×).
  - **Acceptance**: A cell given an `onDelete` shows a tappable × and no lock; an Instagram cell (no `onDelete`) shows the lock and no ×.
- [x] 4.2 Update the `#Preview`s to pass `onDelete` for the local preview and `nil` for the locked preview.
  - **Acceptance**: Previews render the × (local) and lock (Instagram) states.

## 5. Wire `GridPlannerView` and the tabs

- [x] 5.1 Add `let onDelete: (GridItem) -> Void` to `GridPlannerView`; pass `item.isLocked ? nil : { onDelete(item) }` into each `GridCellView`.
  - **Acceptance**: Local cells receive a delete handler; Instagram cells receive `nil`.
- [x] 5.2 In `PostsGridView` and `ReelsGridView`, pass `onDelete: { viewModel.removeLocalItem($0) }` to `GridPlannerView`.
  - **Acceptance**: Tapping a local tile's × removes it from that tab's grid.

## 6. Build and verify

- [x] 6.1 Add a temporary `#if DEBUG` sanity check: on a `posts` view model, `addLocalImages([jpeg])`, capture the new item's `localImagePath`, then `removeLocalItem(it)` and assert the item is gone from `items`, its file no longer exists, and a fresh `posts` view model does not restore it. Also assert `removeLocalItem` on a sample Instagram item leaves `items` unchanged.
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 6.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 6.3 Manual test in the simulator:
  - **Manual test**:
    1. Import an image on Posts; it appears on top with a × badge; Instagram tiles show a lock and no ×.
    2. Tap the × on the imported tile — it disappears; the rest keep order.
    3. Relaunch — the removed item does not come back.
    4. Tapping an Instagram tile offers no delete; it cannot be removed.
- [x] 6.4 Remove the temporary sanity check from 6.1 and rebuild.
  - **Acceptance**: Production code contains only the intended changes; build still succeeds.

## 7. Negative checks

- [x] 7.1 Confirm no later-phase concerns leaked in: `grep -RIn "onMove\|\.draggable\|InstagramSyncService\|AppSettings\|selectedInstagramUsername" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: No reorder/sync/settings code.
- [x] 7.2 Confirm the Instagram guard exists: `removeLocalItem` early-returns for `isLocked` items (covered by the 6.1 assertion and visible in the diff).
  - **Acceptance**: Instagram items provably cannot be removed.

## 8. Source control & reporting

- [x] 8.1 Stage the modified files.
  - **Acceptance**: `git status` shows `LocalStorageService.swift`, `GridPlannerViewModel.swift`, `GridCellView.swift`, `GridPlannerView.swift`, `PostsGridView.swift`, `ReelsGridView.swift` modified.
- [x] 8.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps, known limitations (no undo/confirm; orphaned files from earlier phases not retroactively cleaned), and which requirements remain (Phases 7–13).
  - **Acceptance**: Summary lists changed files and confirms the `remove-local-items` scenarios pass.
- [x] 8.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; import an image, tap its ×, confirm it's gone and stays gone after relaunch, and that Instagram tiles can't be deleted.
  - **Acceptance**: A reader can follow the guide to exercise removal end-to-end.
