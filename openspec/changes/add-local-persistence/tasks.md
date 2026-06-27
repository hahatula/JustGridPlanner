## 1. Confirm scope before changing files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm `LocalStorageService` has only image-file methods and `GridPlannerViewModel` seeds from `SampleData` with no load/save (`grep -RIn "saveItems\|loadItems\|metadata" InstagramGridPlanner/` returns nothing). Record in apply notes.
  - **Acceptance**: One-line note "No metadata persistence yet."
- [x] 1.2 Confirm scope: add JSON metadata save/load for **local items only**, load on launch, graceful missing/corrupted handling — explicitly NOT remove (Phase 6), reorder (Phase 7), sync (Phase 9), or `AppSettings` (Phase 8).
  - **Acceptance**: Scope restated in apply notes.

## 2. Add metadata save/load to `LocalStorageService`

- [x] 2.1 Add a private `JSONEncoder`/`JSONDecoder` pair configured with `.dateEncodingStrategy = .iso8601` / `.dateDecodingStrategy = .iso8601`, and a helper that maps a `GridType` to `metadata/<rawValue>.json` under Documents.
  - **Acceptance**: Compiles. Dates encode as ISO-8601 strings.
- [x] 2.2 Add `func saveItems(_ items: [GridItem], for gridType: GridType) throws`: create `metadata/` if needed and write the JSON array atomically to the grid's file.
  - **Acceptance**: After saving, the file exists and contains a JSON array of the given items.
- [x] 2.3 Add `func loadItems(for gridType: GridType) -> [GridItem]`: read and decode the grid's file; return `[]` (never throw) when the file is missing, unreadable, or contains invalid JSON.
  - **Acceptance**: Round-trips saved items; returns `[]` for a missing file and for a file containing invalid JSON.

## 3. Load and save in `GridPlannerViewModel`

- [x] 3.1 Change `init` to load persisted local items via `storage.loadItems(for: gridType)` (sorted by `orderIndex`). In `#if DEBUG`, append the sample **Instagram placeholders** only (`SampleData…filter { $0.source == .instagram }`); in release, append nothing. Renumber so local items stay on top.
  - **Acceptance**: With saved local items present, a new view model restores them on top, above any DEBUG Instagram placeholders. With none saved, it starts with just the placeholders (DEBUG) or empty (release).
- [x] 3.2 Add a private `persist()` that calls `storage.saveItems(items.filter { $0.source == .local }, for: gridType)` (ignoring/​logging any error in DEBUG), and call it at the end of `addLocalImages`.
  - **Acceptance**: After `addLocalImages`, the metadata file contains the new local item(s) and no Instagram items.

## 4. Build and verify

- [x] 4.1 Add a temporary `#if DEBUG` sanity check asserting the full cycle without the picker: build a tiny JPEG, `addLocalImages([data])` on a `posts` view model, then construct a **new** `posts` view model and confirm it restores that local item (same `localImagePath`, on top); also confirm the saved file excludes Instagram items, that a corrupted file makes `loadItems` return `[]`, and that the image file still exists after reload.
  - **Acceptance**: Runs without assertion failure when launched in the simulator.
- [x] 4.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 4.3 Manual persistence test in the simulator:
  - **Manual test**:
    1. On Posts, import an image via the toolbar "+"; it appears on top.
    2. Terminate the app (`xcrun simctl terminate`) and relaunch.
    3. The imported image is still there, on top, showing its image.
    4. Repeat on Reels; Posts and Reels persist independently.
- [x] 4.4 Remove the temporary sanity check from 4.1 and rebuild.
  - **Acceptance**: Production code contains only the intended changes; build still succeeds.
- [x] 4.5 (Incidental) While verifying restored images, fix image-cell sizing: give each tile an exact size via `GeometryReader` in `GridPlannerView` and render the image with a `UIImageView` aspect-fill in `GridCellView` (SwiftUI's `Image.scaledToFill()` mis-sized some imported JPEGs in `LazyVGrid`).
  - **Manual test**: A restored/imported image fills its 3:4 (Posts) / 9:16 (Reels) tile, cover-cropped, with no empty space — verified by injecting a known image into `metadata/posts.json` + `images/` and relaunching.

## 5. Negative checks

- [x] 5.1 Confirm no later-phase concerns leaked in: `grep -RIn "deleteImage\|onMove\|\.draggable\|swipeActions\|InstagramSyncService\|AppSettings\|selectedInstagramUsername" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: No remove/reorder/sync/settings code.
- [x] 5.2 Confirm only local items are persisted: in the sanity check (or by inspecting a saved file), the metadata JSON contains no object with `"source" : "instagram"`.
  - **Acceptance**: Saved metadata is local-only.

## 6. Source control & reporting

- [x] 6.1 Stage the modified service and view model.
  - **Acceptance**: `git status` shows `LocalStorageService.swift` and `GridPlannerViewModel.swift` modified.
- [x] 6.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps, known limitations (no remove/reorder/sync yet; orphaned files until Phase 6), and which requirements remain (Phases 6–13).
  - **Acceptance**: Summary lists changed files and confirms the `local-persistence` scenarios pass.
- [x] 6.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; import an image; terminate and relaunch (or the `xcrun simctl terminate … && launch` commands) and confirm it persists; note where the JSON lives (`Documents/metadata/<grid>.json`) and that Instagram placeholders are DEBUG-only and not persisted.
  - **Acceptance**: A reader can follow the guide to confirm persistence across a relaunch.
