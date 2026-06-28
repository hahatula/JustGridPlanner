## 1. Confirm scope before adding files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm there is no import flow yet (`grep -RIn "ScreenshotImport\|CropOverlay\|GridSplitter\|InstagramProfileLink" InstagramGridPlanner/` returns nothing) and that `LocalStorageService.saveImageData` and `AppSettingsStore.selectedUsername` exist to reuse. Record in apply notes.
  - **Acceptance**: One-line note "No posted-import flow yet; reuse saveImageData + selectedUsername."
- [x] 1.2 Confirm scope: capture pipeline only (open profile, import screenshot, 3×3 crop overlay, split into 9 saved tiles) — explicitly NOT grid integration / locked items / merge (Phase 13), real API/auth/scraping, or grid auto-detection.
  - **Acceptance**: Scope restated in apply notes.

## 2. Add the profile link helper

- [x] 2.1 Create `Utilities/InstagramProfileLink.swift`: `enum InstagramProfileLink { static func url(forUsername: String) -> URL? }` building `https://instagram.com/<username>` (username already normalized, no `@`). Return `nil` for empty.
  - **Acceptance**: `url(forUsername: "olgo.js")` is `https://instagram.com/olgo.js`; empty returns `nil`.

## 3. Add the split + coordinate mapping (`GridSplitter`)

- [x] 3.1 Create `Utilities/GridSplitter.swift`. Add a mapping function: given the image pixel size, the view size, and the overlay rect (in the aspect-fit display's view coordinates), return the corresponding pixel `CGRect` — `scale = min(viewW/imgW, viewH/imgH)`, displayed origin centered, `pixelRect = (overlayRect − displayOrigin) / scale`, clamped to image bounds.
  - **Acceptance**: For a known image/view/overlay, the mapping returns the expected pixel rect (covered by a unit-style DEBUG check).
- [x] 3.2 Add `func split(_ image: UIImage, pixelRect: CGRect) -> [UIImage]`: crop the `CGImage` to `pixelRect`, then divide into 3 columns × 3 rows of equal size and return **nine** sub-images in row-major (left→right, top→bottom) order.
  - **Acceptance**: Returns exactly 9 images; each is ~⅓ × ⅓ of the cropped region; ordering is row-major.
- [x] 3.3 Add a save helper that encodes the nine tiles to JPEG and stores them via `LocalStorageService.saveImageData`, returning the nine relative paths.
  - **Acceptance**: Nine files exist under `Documents/images/` after saving and the returned paths resolve to them.

## 4. Add the crop overlay

- [x] 4.1 Create `Views/CropOverlay.swift`: a `View` over the displayed screenshot showing a rectangle locked to a given aspect ratio (3:4 / 9:16) with two interior vertical and two horizontal lines (3×3) and a dimmed exterior. State: `center` + `size`.
  - **Acceptance**: Renders an aspect-locked 3×3 frame; the exterior is dimmed.
- [x] 4.2 Add a `DragGesture` (move) and a `MagnificationGesture` (resize, aspect-kept) via `.simultaneousGesture`, clamping the frame to the displayed image bounds.
  - **Acceptance**: The frame can be moved and resized but cannot leave the image or change aspect.

## 5. Add the import flow

- [x] 5.1 Create `Views/ScreenshotImportView.swift`: `ScreenshotImportView(gridType: GridType, onComplete: ([String]) -> Void)` with `@State` steps. **Intro**: an "Open Instagram" button (uses `InstagramProfileLink` + `@Environment(\.openURL)`, requires `@Environment(AppSettingsStore.self).selectedUsername`, else prompts to set an account) and an "Import Screenshot" `PhotosPicker` (images only).
  - **Acceptance**: "Open Instagram" opens the profile (or prompts when no account); "Import Screenshot" loads a chosen image into the crop step with no permission alert.
- [x] 5.2 **Crop step**: show the imported image (aspect-fit in a `GeometryReader`) with `CropOverlay` (aspect = the grid's tile ratio) and a "Split" action that maps the overlay via `GridSplitter`, splits + saves nine tiles, and advances to review.
  - **Acceptance**: Tapping "Split" produces nine saved tiles from the aligned region.
- [x] 5.3 **Review step**: show the nine tiles in a 3×3 preview with "Use these" (calls `onComplete(paths)` and dismisses) and "Retake" (back to intro).
  - **Acceptance**: Review shows the nine tiles; "Use these" returns them to the caller.

## 6. Add the entry point and wire the tabs

- [x] 6.1 Create `Views/PostedImportButton.swift`: a toolbar button (`square.and.arrow.down`) that presents `ScreenshotImportView(gridType:)` as a sheet for a given grid type.
  - **Acceptance**: Compiles; tapping presents the import sheet.
- [x] 6.2 Add `PostedImportButton(gridType: .posts/.reels)` to `PostsGridView` and `ReelsGridView` toolbars. For this phase, pass an `onComplete` that just dismisses (Phase 13 wires it into the grid).
  - **Acceptance**: Both tabs show the import button and can run the flow end to end (producing saved tiles), with no grid change yet.

## 7. Build and verify

- [x] 7.1 Add a temporary `#if DEBUG` sanity check for `GridSplitter`: build a known test image, run the mapping for a known view/overlay, then `split` and assert nine images, expected sizes (~⅓×⅓ of the mapped region), and row-major order; save and assert nine files exist.
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 7.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 7.3 Manual test in the simulator:
  - **Manual test**:
    1. Set an account; on Posts tap the import button.
    2. "Open Instagram" opens the profile (Safari/IG); take a screenshot in the simulator (or use a prepared grid image).
    3. "Import Screenshot" → pick the image (no permission prompt).
    4. Align the 3×3 overlay over the grid (drag + pinch); tap Split.
    5. Review shows nine tiles cropped from the region; "Use these" dismisses.
    6. Repeat on Reels — overlay is 9:16.
- [x] 7.4 Remove the temporary sanity check from 7.1 and rebuild.
  - **Acceptance**: Production code contains only the intended files; build still succeeds.

## 8. Negative checks

- [x] 8.1 Confirm no permission key and no networking/scraping: `grep -RIn "NSPhotoLibrary\|URLSession\|WKWebView\|OAuth\|scrap\|instagram://" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: No photo-library permission, no real network, no custom-scheme deep link, no scraping.
- [x] 8.2 Confirm no grid integration leaked in (that is Phase 13): `grep -RIn "source: .instagram\|InstagramSyncService" InstagramGridPlanner/Views/ScreenshotImportView.swift` returns no matches.
  - **Acceptance**: This phase produces tile images only; it does not create grid items.

## 9. Source control & reporting

- [x] 9.1 Stage the new and modified files.
  - **Acceptance**: `git status` shows the new `ScreenshotImportView`/`CropOverlay`/`GridSplitter`/`InstagramProfileLink`/`PostedImportButton` files added and `PostsGridView.swift`/`ReelsGridView.swift` modified.
- [x] 9.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps (with a note that the crop is interactive), known limitations (no grid integration yet; orphan tiles until Phase 13; assumes 3×3), and which requirements remain (Phases 13–14).
  - **Acceptance**: Summary lists changed files and confirms the `posted-grid-import` scenarios pass.
- [x] 9.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; set an account; import button → Open Instagram → screenshot → Import Screenshot → align the 3×3 overlay → Split → review nine tiles; both tabs (Posts 3:4, Reels 9:16).
  - **Acceptance**: A reader can follow the guide to exercise the capture pipeline end to end.
