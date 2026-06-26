## 1. Confirm scope before adding files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm Phase 3 grid views/models exist and that `ViewModels/` and `Services/` hold only `.gitkeep` (`grep -RIn "GridPlannerViewModel\|LocalStorageService\|PhotosPicker" InstagramGridPlanner/` returns nothing). Record in apply notes.
  - **Acceptance**: One-line note "No view model / storage service / picker yet."
- [x] 1.2 Confirm scope: add gallery import (picker + storage + view model + insert-at-top + image display) — explicitly NOT persistence (Phase 5), remove (Phase 6), reorder (Phase 7), or sync (Phase 9).
  - **Acceptance**: Scope restated in apply notes.

## 2. Add `LocalStorageService` (image files)

- [x] 2.1 Create `InstagramGridPlanner/Services/LocalStorageService.swift`: a class with a `static let shared`, `func saveImageData(_ data: Data) throws -> String` that re-encodes to JPEG (~0.9), writes `images/<uuid>.jpg` under the app Documents directory (creating `images/` if needed), and returns the relative path.
  - **Acceptance**: Compiles. Returns a path like `images/<uuid>.jpg`; the file exists on disk after the call.
- [x] 2.2 Add `func imageURL(for item: GridItem) -> URL?` returning the absolute Documents file URL for a local item with a `localImagePath`, and `nil` for non-local items or a missing path.
  - **Acceptance**: A local item with a saved path resolves to an existing file URL; an Instagram item returns `nil`.

## 3. Add `GridPlannerViewModel`

- [x] 3.1 Create `InstagramGridPlanner/ViewModels/GridPlannerViewModel.swift`: an `@Observable` class `GridPlannerViewModel(gridType: GridType, storage: LocalStorageService = .shared)` exposing `var items: [GridItem]`. In `#if DEBUG`, seed `items` from `SampleData` for the grid type; otherwise start empty.
  - **Acceptance**: Compiles. A Posts view model in DEBUG starts with the sample posts items.
- [x] 3.2 Add `func addLocalImages(_ datas: [Data])` that, for each `Data` (in order): saves it via `storage.saveImageData`, builds a `GridItem(source: .local, gridType: gridType, id: UUID().uuidString, localImagePath: <saved>)`, and prepends the new items to `items`, then renumbers every item's `orderIndex` to its array index (new items on top, picked order preserved). Skip any image that fails to save without aborting the rest.
  - **Acceptance**: After adding N images to a grid with M items, the grid has M+N items, the new ones occupy the first N positions in picked order, and `orderIndex` equals array index for all.
  - **Manual test**: In a temporary `#if DEBUG` check, call `addLocalImages([jpegData])` and assert the first item is `.local`, `isLocked == false`, `orderIndex == 0`, and has a non-nil `localImagePath`.

## 4. Add the gallery import control (outside the grid)

- [x] 4.1 Create `InstagramGridPlanner/Views/GalleryImportButton.swift`: a `View` taking a `GridPlannerViewModel` that renders a `PhotosPicker(selection:matching: .images)` (multiple selection allowed) as a toolbar-style `Image(systemName: "plus")` button. Do not pass a `photoLibrary:` so the out-of-process picker is used (no permission prompt).
  - **Acceptance**: Compiles. Tapping presents the system photo picker with no permission alert.
- [x] 4.2 On selection change, load each `PhotosPickerItem` to `Data` via `loadTransferable(type: Data.self)` in a `Task`, collect the successfully-loaded `Data` in order, call `viewModel.addLocalImages(_:)`, then clear the selection.
  - **Acceptance**: Selecting images results in `addLocalImages` being called with one `Data` per selected image, in selection order.

## 5. Wire the tabs to the view model

- [x] 5.1 Update `Views/PostsGridView.swift`: hold `@State private var viewModel = GridPlannerViewModel(gridType: .posts)`, pass `viewModel.items` to `GridPlannerView`, keep `.navigationTitle("Posts")`, and add `GalleryImportButton(viewModel: viewModel)` to the navigation toolbar (trailing). Remove the old `#if DEBUG SampleData` seeding from the view (the view model owns it now).
  - **Acceptance**: Posts tab shows the grid plus a "+" toolbar button; importing adds to the Posts grid.
- [x] 5.2 Update `Views/ReelsGridView.swift` the same way with `.reels` and `.navigationTitle("Reels")`.
  - **Acceptance**: Reels tab shows the grid plus a "+" toolbar button; importing adds to the Reels grid only.

## 6. Display the imported image in the cell

- [x] 6.1 Update `Views/GridCellView.swift`: for a local item, resolve `LocalStorageService.shared.imageURL(for:)` and load the `UIImage` in a `.task` (keyed on `item.id`, off the main thread) into `@State`. Show the image cover-scaled and centered, **clipped to the tile** so it keeps the tile size and never overflows (`Color.clear` base + `Image…resizable().scaledToFill()` overlay + `.clipped()`); otherwise fall back to the tinted placeholder. Keep the lock badge logic unchanged (driven by `item.isLocked`).
  - **Acceptance**: A local item with a real file shows its image filling the tile (cover, centered, no overflow into neighbouring cells); a missing file (e.g. `SampleData`) shows the placeholder; Instagram items show the placeholder + lock badge.

## 7. Build, run, and verify

- [x] 7.1 Add a temporary `#if DEBUG` sanity check asserting: `LocalStorageService.saveImageData` writes a resolvable file; `imageURL(for:)` returns it; and `GridPlannerViewModel.addLocalImages([jpegData])` prepends a `.local`, unlocked item at `orderIndex 0`. Use a tiny generated `UIImage` for the bytes.
  - **Acceptance**: Runs without assertion failure when launched in the simulator.
- [x] 7.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 7.3 Run on the simulator and manually verify the picker flow:
  - **Manual test**:
    1. On the Posts tab, tap the toolbar "+"; the system photo picker opens with **no** permission prompt.
    2. Select one or more images; they appear at the **top** of the Posts grid as real images (3:4 tiles), above the locked Instagram placeholders.
    3. Switch to Reels, import an image; it appears only in Reels (9:16), not in Posts.
    4. No crash; no network.
- [x] 7.4 Capture a screenshot of the Posts grid after importing at least one image.
  - **Acceptance**: Screenshot shows the imported image as the first tile.
- [x] 7.5 Remove the temporary sanity check from 7.1 and rebuild.
  - **Acceptance**: Production code contains only the intended files; build still succeeds.

## 8. Negative checks

- [x] 8.1 Confirm no later-phase concerns leaked in: `grep -RIn "onDrag\|onMove\|\.draggable\|swipeActions\|InstagramSyncService\|loadGrid\|saveGrid\|deleteImage" InstagramGridPlanner/` returns no matches (no reorder, no metadata persistence, no remove, no sync).
  - **Acceptance**: No matches.
- [x] 8.2 Confirm no photo-library permission key was added: `grep -RIn "NSPhotoLibrary" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: No `NSPhotoLibraryUsageDescription` present (the out-of-process picker needs none).

## 9. Source control & reporting

- [x] 9.1 Delete `Services/.gitkeep` and `ViewModels/.gitkeep` (and their pbxproj membership exceptions) now that real files live there. Stage all new/modified files.
  - **Acceptance**: `git status` shows the two `.gitkeep`s removed, the new service/view-model/button files added, and the modified views.
- [x] 9.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps (with screenshot), known limitations (no persistence/remove/reorder/sync yet), and which requirements remain (Phases 5–13).
  - **Acceptance**: Summary lists every changed file and confirms the `gallery-import` scenarios pass.
- [x] 9.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; tap the toolbar "+" and pick images; verify they land on top as real images and that Posts/Reels are independent; the exact `xcodebuild` build command; and the note that imported items do not survive relaunch yet (Phase 5) and cannot be removed yet (Phase 6).
  - **Acceptance**: A reader can follow the guide to exercise import end-to-end and knows the current limitations.
