## 1. Confirm scope before adding files

- [x] 1.1 Re-inspect per `/AGENTS.md` "Existing Code Awareness": confirm the Phase 2 models exist (`GridItem`, `GridType`, `GridItemSource`, `SampleData`) and there is no grid/cell view yet (`grep -RIn "GridPlannerView\|GridCellView\|LazyVGrid" InstagramGridPlanner/` returns nothing). Record in apply notes.
  - **Acceptance**: One-line note "Models present; no grid view exists yet."
- [x] 1.2 Confirm this change adds **only** the display grid (`GridPlannerView`, `GridCellView`) and wires the two tabs — explicitly NOT add/remove/reorder (Phases 4/6/7), persistence (Phase 5), a view model (Phase 4), or sync (Phase 9).
  - **Acceptance**: Scope restated in apply notes.

## 2. Add `GridCellView`

- [x] 2.1 Create `InstagramGridPlanner/Views/GridCellView.swift`: a `View` taking a single `GridItem` that fills its tile with a placeholder (tinted background + an SF Symbol) using `.fill`/`.clipped()`. The cell fills whatever portrait tile the parent grid sizes it to (the grid applies the aspect ratio).
  - **Acceptance**: Compiles. Cell fills its tile with no distortion regardless of available width.
- [x] 2.2 Give local (planned) and Instagram (locked) items visually distinct treatments (e.g. different tint), and overlay a lock indicator (`Image(systemName: "lock.fill")`) in a corner **only** when `item.isLocked` is true. Read `item.isLocked`; do not re-derive from `source` in the view.
  - **Acceptance**: An `.instagram` item shows the lock overlay; a `.local` item does not.
- [x] 2.3 Add `#Preview`s showing one locked and one unlocked cell.
  - **Acceptance**: Canvas renders both states.

## 3. Add `GridPlannerView`

- [x] 3.1 Create `InstagramGridPlanner/Views/GridPlannerView.swift`: `GridPlannerView(gridType: GridType, items: [GridItem])` rendering a `ScrollView` + `LazyVGrid` with three flexible columns and ~1pt spacing, one `GridCellView` per item.
  - **Acceptance**: Compiles. Renders 3 columns.
- [x] 3.2 Declare the columns using the fully qualified `SwiftUI.GridItem` (e.g. `Array(repeating: SwiftUI.GridItem(.flexible(), spacing: 1), count: 3)`) to avoid the collision with the model `GridItem`.
  - **Acceptance**: Builds with no "ambiguous"/"extra argument" errors from the name clash.
- [x] 3.3 For display, compute `items.filter { $0.gridType == gridType }.sorted { $0.orderIndex < $1.orderIndex }`. Do not mutate the input. Use `GridItem.id` for `ForEach` identity.
  - **Acceptance**: Cells appear in ascending `orderIndex`; passing a mixed-`gridType` array shows only matching items.
- [x] 3.4 Derive the tile aspect ratio from `gridType` in the view layer — `.posts → 3.0/4.0`, `.reels → 9.0/16.0` — and apply it to each cell via `.aspectRatio(tileAspectRatio, contentMode: .fill).clipped()`. Do not store the ratio on the model.
  - **Acceptance**: Posts tiles render 3:4; Reels tiles render 9:16; both fill the cell without stretching the placeholder.
- [x] 3.5 Add `#Preview`s for both grids using `SampleData.posts` and `SampleData.reels`.
  - **Acceptance**: Canvas shows a 3-column grid with mixed locked/unlocked cells for each (Posts 3:4, Reels 9:16).

## 4. Wire the tabs

- [x] 4.1 Replace the placeholder body of `InstagramGridPlanner/Views/PostsGridView.swift` with `GridPlannerView(gridType: .posts, items:)` inside the existing `NavigationStack`, keeping `.navigationTitle("Posts")`. Seed items from `SampleData.posts` under `#if DEBUG`, else `[]`.
  - **Acceptance**: Posts tab shows the grid under the "Posts" title in a Debug run.
- [x] 4.2 Do the same for `InstagramGridPlanner/Views/ReelsGridView.swift` with `.reels`, `SampleData.reels`, and `.navigationTitle("Reels")`.
  - **Acceptance**: Reels tab shows the grid under the "Reels" title.
- [x] 4.3 Keep each view's existing `#Preview`.
  - **Acceptance**: Both previews still render.

## 5. Build, run, and manually verify

- [x] 5.1 Clean build the `InstagramGridPlanner` scheme for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 5.2 Run on the iPhone simulator and verify visually.
  - **Manual test**:
    1. Posts tab shows a 3-column grid of 3:4 portrait tiles (DEBUG sample items).
    2. Instagram items show a lock indicator; local items do not.
    3. Cells appear in ascending `orderIndex` — local planned items on top, already-posted Instagram items below.
    4. Switch to Reels — its 3-column grid renders 9:16 portrait tiles with the same locked/unlocked treatment.
    5. No add/delete/reorder controls are present; no crash, no network activity.
- [x] 5.3 Capture a screenshot of each tab to confirm the locked vs unlocked treatment is visible.
  - **Acceptance**: Screenshots show 3 columns and a visible lock indicator on Instagram cells.

## 6. Negative checks

- [x] 6.1 Confirm no later-phase concerns leaked in: `grep -RIn "PhotosPicker\|onDrag\|onMove\|\.draggable\|swipeActions\|deleteItem\|LocalStorageService\|InstagramSyncService\|URLSession\|FileManager" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: No add/remove/reorder/storage/sync code present.
- [x] 6.2 Confirm the lock rule is not re-implemented in views: `grep -RIn "== .instagram\|source == " InstagramGridPlanner/Views/` returns no matches (views use `isLocked`).
  - **Acceptance**: Views rely on `item.isLocked`, not a re-derived rule.

## 7. Source control & reporting

- [x] 7.1 Stage the new and modified view files.
  - **Acceptance**: `git status` shows `GridPlannerView.swift` and `GridCellView.swift` added and `PostsGridView.swift`/`ReelsGridView.swift` modified.
- [x] 7.2 Write the apply-phase summary per `/docs/07-agent-workflow.md` "Implementation Rules": what changed, files changed, manual test steps (with screenshots), known limitations, and which requirements remain (Phases 4–13).
  - **Acceptance**: Summary lists every changed file, confirms the `grid-display` scenarios pass, and notes that import/persistence/remove/reorder/sync remain (expected).
- [x] 7.3 Include a **"How to test this change"** guide in the apply summary so the user can re-verify the applied change without re-deriving the steps. The guide MUST cover:
  - **Open in Xcode**: `open InstagramGridPlanner.xcodeproj`, pick an iPhone 17 simulator, press ⌘R; live-preview each grid view in the canvas (DEBUG `#Preview` uses `SampleData`).
  - **Command line**: the exact `xcodebuild … -destination 'platform=iOS Simulator,name=iPhone 17' clean build` command, plus the `xcrun simctl boot/install/launch` sequence and `xcrun simctl io … screenshot` to capture each tab.
  - **Manual checklist** mapping to the `grid-display` scenarios: 3 columns; Posts tiles 3:4 and Reels tiles 9:16; lock indicator on Instagram items only; cells in ascending `orderIndex`; no add/delete/reorder controls; no crash/network.
  - **Expected result vs. limitation**: cells are tinted placeholders (no real images yet — Phase 4/9); Release builds show an empty grid (sample data is DEBUG-only).
  - **Acceptance**: A reader following the guide can build, launch, and confirm every `grid-display` scenario from a clean checkout.
