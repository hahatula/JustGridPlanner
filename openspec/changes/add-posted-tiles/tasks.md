## 1. Confirm scope before changing files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm Phase 12's `ScreenshotImportView`/`PostedImportButton` produce tile paths via `onComplete([String])`, and that the view model still persists `.local` only and has the mock `refresh()`. Record in apply notes.
  - **Acceptance**: One-line note "Phase 12 import present; VM persists local-only with mock refresh."
- [x] 1.2 Confirm scope: imported tiles → locked posted items, merge below local, persist, re-import replaces; replace the mock refresh with the manual provider — explicitly NOT real API/auth, new capture UI, or posted-item reorder/remove.
  - **Acceptance**: Scope restated in apply notes.

## 2. Resolve local files for any item; add the manual provider

- [x] 2.1 Update `LocalStorageService.imageURL(for:)` to resolve any item that has a `localImagePath` (not only `source == .local`), so imported posted tiles (instagram + localImagePath) display and can be deleted.
  - **Acceptance**: A posted item with a `localImagePath` resolves to its file URL; an item without a `localImagePath` returns `nil`.
- [x] 2.2 Create `Services/ManualInstagramImportService.swift`: `struct ManualInstagramImportService: InstagramSyncService` whose `fetchPostedMedia(forUsername:gridType:)` returns `storage.loadItems(for: gridType).filter { $0.source == .instagram }`. Import only `Foundation`.
  - **Acceptance**: Returns the persisted imported posted tiles for a grid; no SwiftUI/UIKit import.

## 3. Import, persist, and restore posted tiles in the view model

- [x] 3.1 Change `persist()` to save `items.filter { $0.localImagePath != nil }` (local planned + imported posted), and change `init` to load local items synchronously and load posted items via `sync.fetchPostedMedia` in a `Task`, merging `renumbered(locals + posted)`. Default `sync = ManualInstagramImportService()`.
  - **Acceptance**: A fresh view model restores both local planned items and previously imported posted items (planned on top).
- [x] 3.2 Add `func importPostedTiles(_ paths: [String])`: delete the current posted items' image files (`storage.deleteImage`), build a locked `GridItem` per path (`source: .instagram`, `gridType`, `localImagePath: path`, `id: UUID().uuidString`), set `items = renumbered(items.filter { $0.source == .local } + newPosted)`, and `persist()`.
  - **Acceptance**: After import the grid has the local items on top and the 9 posted tiles below; a second import replaces (not appends) the posted tiles and removes the old tile files.
- [x] 3.3 Remove the mock refresh path: delete `refresh(username:)`, `isRefreshing`, `refreshError`, and the `MockInstagramSyncService` default. Set `lastSuccessfulRefreshAt` on a successful import (via the settings store, wired from the view).
  - **Acceptance**: No `refresh()`/`isRefreshing`/`refreshError` remain; the mock is not the runtime provider.

## 4. Wire the tabs

- [x] 4.1 In `PostsGridView` and `ReelsGridView`, set the `PostedImportButton`'s `onComplete` to `{ viewModel.importPostedTiles($0); settingsStore.markRefreshed() }`, and remove the `RefreshButton` and the refresh error alert.
  - **Acceptance**: Importing on a tab places the posted tiles in that grid below the local items; no refresh button remains.

## 5. Build and verify

- [x] 5.1 Add a temporary `#if DEBUG` sanity check (in a `Task`): save two local items, then call `importPostedTiles([nine saved tile paths])`; assert the grid has the two locals on top and nine `source == .instagram` `isLocked` items below; import a second set and assert the count stays nine posted (replaced) and the old tile files are gone; assert a fresh view model restores both locals and posted (planned on top).
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 5.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 5.3 Manual test in the simulator:
  - **Manual test**:
    1. Import a screenshot on Posts (Phase 12 flow) → nine posted tiles appear **below** the local planned tiles, locked (lock badge), with no delete/drag.
    2. Relaunch → the posted tiles are restored, still below the local items.
    3. Re-import a different screenshot → the posted tiles are replaced (still nine), local items unchanged.
    4. Repeat on Reels; confirm Posts is unaffected.
- [x] 5.4 Remove the temporary sanity check from 5.1 and rebuild.
  - **Acceptance**: Production code contains only the intended changes; build still succeeds.

## 6. Negative checks

- [x] 6.1 Confirm posted items stay locked: `grid-display`/cell behavior shows no delete (×) or drag for `source == .instagram` items (already driven by `isLocked`; verify in the diff and manually).
  - **Acceptance**: Posted tiles show the lock badge and offer no delete/reorder.
- [x] 6.2 Confirm the mock is no longer wired and no networking leaked in: `grep -RIn "MockInstagramSyncService(\|URLSession\|OAuth" InstagramGridPlanner/` shows the mock is not constructed in the runtime flow (only in fixtures/tests, if kept) and no network code.
  - **Acceptance**: Manual provider is the runtime `InstagramSyncService`; no real network.

## 7. Source control & reporting

- [x] 7.1 Stage the new and modified files.
  - **Acceptance**: `git status` shows `ManualInstagramImportService.swift` added and `GridPlannerViewModel.swift`, `LocalStorageService.swift`, `PostsGridView.swift`, `ReelsGridView.swift` modified (and `RefreshButton.swift` removed if deleted).
- [x] 7.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps, known limitations (re-import replaces all 9; posted items only change by re-import; visual polish is Phase 14), and which requirements remain (Phase 14).
  - **Acceptance**: Summary lists changed files and confirms the `posted-tiles` scenarios pass and the `local-persistence`/`grid-refresh` modifications hold.
- [x] 7.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; import a screenshot → posted tiles appear below planned items, locked; relaunch persists them; re-import replaces them; both tabs.
  - **Acceptance**: A reader can follow the guide to exercise posted-tile integration end to end.
