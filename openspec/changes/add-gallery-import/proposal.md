## Why

The grid now renders items (Phase 3), but every item is fixed sample data — the user cannot add anything. Phase 4 of `/docs/08-task-breakdown.md` delivers the first real user action: pick images from the iPhone gallery, copy them into the app's local storage, and show them as planned items at the top of the active grid. This is the core of the product ("add local planned images from my iPhone gallery" — `/docs/00-project-brief.md`) and unblocks persistence (Phase 5), remove (Phase 6), and reorder (Phase 7).

## What Changes

- Add a **`GridPlannerViewModel`** (deferred from Phase 3) that owns one grid's `items` and the add logic. Each tab holds its own instance — Posts and Reels are independent grids (`/docs/01-business-logic.md`).
- Add gallery import via SwiftUI **`PhotosPicker`** (`/docs/02-tech-stack.md`), triggered from a button in the navigation toolbar — **outside the grid**, never an in-grid cell (`/docs/10-decisions.md` Decision 007). Multiple selection is allowed.
- Add a **`LocalStorageService`** that copies picked image data into the app's Documents directory (`images/<uuid>.jpg`) and resolves a stored relative path back to a file URL (`/docs/04-architecture.md`). Only the image-file responsibilities land here now; metadata save/load is Phase 5.
- On import, create a local `GridItem` (`source: .local`, `gridType` = the active tab, `localImagePath` = the stored relative path, generated `id`) and **insert it at the top** of the grid, renumbering `orderIndex` so planned items stay above posted ones (`/docs/10-decisions.md` Decision 007).
- Make **`GridCellView` display the actual local image** from storage (with the placeholder as fallback), so imported images are visible.
- Remove the `Services/` and `ViewModels/` `.gitkeep` placeholders now that real files land there.

## Capabilities

### New Capabilities
- `gallery-import`: Choosing images from the iPhone gallery, copying them into local app storage, creating local `GridItem` metadata, and inserting them at the top of the active grid — driven by a `GridPlannerViewModel` and a `LocalStorageService`, from a control outside the grid.

### Modified Capabilities
- `grid-display`: The Phase-3 "Display-only grid in this phase" requirement (no add affordance, no storage access) is removed — the grid now hosts an out-of-grid add control and reads local image files to display them. Remove/reorder and Instagram sync remain out of scope (Phases 6/7/9).

## Impact

- **New code**: `InstagramGridPlanner/ViewModels/GridPlannerViewModel.swift`, `InstagramGridPlanner/Services/LocalStorageService.swift`, `InstagramGridPlanner/Views/GalleryImportButton.swift` (reusable toolbar `PhotosPicker` used by both tabs).
- **Modified code**: `Views/PostsGridView.swift` and `Views/ReelsGridView.swift` (own a `GridPlannerViewModel`, add the toolbar import button), `Views/GridCellView.swift` (load and show the local image). `GridPlannerView` keeps its `(gridType:items:)` shape, now fed by the view model.
- **Removed**: `Services/.gitkeep`, `ViewModels/.gitkeep` (and their pbxproj membership exceptions).
- **Dependencies**: None third-party. Adds `import PhotosUI` (system framework). `PhotosPicker` requires **no** `NSPhotoLibraryUsageDescription` and no entitlement — it runs out-of-process and returns only the selected items.
- **Storage**: Images written under `Documents/images/`. No metadata file yet (Phase 5).
- **Tech stack**: No deviation from `/docs/02-tech-stack.md`.

## Non-goals

- **No metadata persistence across app restart** — Phase 5. Imported image *files* are written to disk now, but the in-memory item list is not saved/loaded yet, so the grid resets on relaunch (and freshly copied files may be orphaned until Phase 5/6). `/docs/03-requirements.md` lists "persist after app restart" under gallery import, but `/docs/08-task-breakdown.md` assigns it to Phase 5.
- **No remove / delete** — Phase 6 (the `LocalStorageService` delete method and the cell delete action come then). `/docs/03` lists "be removable" under gallery import, but it is Phase 6 per the task breakdown.
- **No drag/reorder** of imported items — Phase 7.
- **No Instagram sync, mock, or refresh** — Phases 9/10. Instagram items remain sample placeholders.
- **No account/username UI or `AppSettings`** — Phase 8.
- **No polished empty-state message** ("Add photos from your gallery…") — Phase 13; an empty grid simply renders empty (with the add button still available in the toolbar).
- **No video import** — picker is limited to images (reels use an image/thumbnail per `/docs/03-requirements.md`).
- **No thumbnail caching / downsampling optimization** — later polish (Phase 13); cells load the stored image directly.
- Nothing from `/docs/11-out-of-scope.md`.
