## Context

Phase 3 left `GridPlannerView` as a pure presentation view fed by static `SampleData`, and explicitly deferred a view model until there was mutable state to own. Phase 4 introduces that state: importing images from the gallery. `ViewModels/` and `Services/` still contain only `.gitkeep`. The relevant `/docs`: `PhotosPicker` for import (`/docs/02`), `LocalStorageService` owns image files + metadata (`/docs/04`), planned items on top and add control outside the grid (`/docs/10` Decisions 007), each grid independent (`/docs/01`).

## Goals / Non-Goals

**Goals:**
- Pick one or more images from the gallery and add them to the active grid as local planned items, on top.
- Copy picked images into the app Documents directory; reference them by a relative `localImagePath`.
- Display the imported image in its cell.
- Own grid state in a `GridPlannerViewModel`, keeping storage and import logic out of the views.

**Non-Goals:**
- Metadata persistence across restart (Phase 5), remove/delete (Phase 6), drag/reorder (Phase 7), Instagram sync (Phase 9), account UI (Phase 8), empty-state polish (Phase 13), video import, thumbnail caching. See proposal Non-goals.

## Decisions

### Decision 1: Introduce `GridPlannerViewModel` now, one per grid
- **Choice**: An `@Observable` (iOS 17) class `GridPlannerViewModel(gridType:)` owning `var items: [GridItem]` and the add logic. Each tab view holds its own via `@State private var viewModel = GridPlannerViewModel(gridType: .posts/.reels)`. `GridPlannerView` keeps its pure `(gridType:items:)` shape and is fed `viewModel.items`.
- **Rationale**: This is the mutation point Phase 3 said would justify the view model (`/docs/04` `GridPlannerViewModel`). One instance per grid honors "each grid has its own list" (`/docs/01`). `@Observable` is the modern iOS-17 choice and re-renders the grid when `items` changes. Keeping `GridPlannerView` presentation-only avoids churn.
- **Alternatives**: Hold `@State var items` directly in the view — rejected; storage/import logic would leak into the view, against `/docs/07` ("keep business logic in view models and services").

### Decision 2: Split picker plumbing (View) from add logic (view model)
- **Choice**: The view converts `PhotosPickerItem`s to raw `Data` (async `loadTransferable(type: Data.self)`); the view model exposes `addLocalImages(_ datas: [Data])` that writes files, builds `GridItem`s, and inserts them. The picker UI is a small reusable `GalleryImportButton(viewModel:)` placed in each tab's toolbar.
- **Rationale**: Keeps the view model independent of PhotosUI, so the core add behavior (copy → metadata → insert-at-top) is exercisable from a DEBUG sanity check with plain `Data`, without driving the picker (which cannot be scripted in the simulator). `GalleryImportButton` removes duplication between the two tabs.
- **Alternatives**: Pass `PhotosPickerItem`s into the view model — rejected; couples the model to PhotosUI and makes it untestable without UI.

### Decision 3: `LocalStorageService` — image files only for this phase
- **Choice**: `LocalStorageService` with `saveImageData(_ data: Data) throws -> String` (writes `images/<uuid>.jpg` under Documents, creating the dir; returns the relative path) and `imageURL(for item: GridItem) -> URL?` (resolves a local item's `localImagePath` to an absolute file URL, `nil` otherwise). A shared instance is used, and the view model accepts one for injection (default `.shared`). The delete method is deferred to Phase 6.
- **Rationale**: Matches the `LocalStorageService` named in `/docs/04`; this phase only needs file write + resolve. Keeping it a real service keeps file I/O out of views and the model. Phase 5 will add `saveGrid`/`loadGrid` metadata methods to the same service.
- **Alternatives**: Write files from the view model directly — rejected; mixes storage into the model. A separate `ImageStorageService` — rejected; diverges from the documented single `LocalStorageService`.

### Decision 4: Normalize imported images to JPEG
- **Choice**: On save, decode the picked `Data` with `UIImage` and re-encode to JPEG (quality ~0.9) before writing `images/<uuid>.jpg`.
- **Rationale**: Gallery assets may be HEIC/PNG; normalizing to JPEG gives a predictable extension and broad compatibility, and matches the documented path example `images/local-001.jpg` (`/docs/05`). Quality 0.9 keeps the grid preview faithful at modest file size.
- **Alternatives**: Store raw bytes with the original type — rejected; unknown/odd extensions and HEIC display edge cases. Lossless PNG — rejected; much larger files for photos.

### Decision 5: Insert at top by rebuilding `orderIndex` from array position
- **Choice**: The view model keeps `items` in display order (index 0 = top-left) and sets each item's `orderIndex` to its array index. `addLocalimages` prepends the new items (in picked order) and renumbers. Instagram items keep their relative order (never reordered among themselves).
- **Rationale**: Implements "planned items on top, newest first" (`/docs/10` Decision 007) with a single, obvious model: array order is the grid. Renumbering is trivial at personal-use item counts.
- **Alternatives**: Give new items `minOrderIndex - 1` without touching others — rejected; indices drift negative and the array/order relationship gets implicit.

### Decision 6: `GridCellView` loads the local image from disk
- **Choice**: For a local item, `GridCellView` resolves the file URL via `LocalStorageService.shared.imageURL(for:)` and loads the `UIImage` in a `.task` keyed on `item.id` (off the main thread), storing it in `@State`. It shows the image when available and falls back to the existing tinted placeholder when the item is not local, has no path, or the file is missing/unreadable. Instagram items keep the placeholder (remote thumbnails are Phase 9/12).
- **Rationale**: Imported images must be visible to confirm the feature. Resolving a relative path to a URL is a thin storage utility, acceptable to call from the cell; no business rule lives there. Graceful fallback also covers `SampleData`'s non-existent paths.
- **Alternatives**: Inject a `(GridItem) -> URL?` resolver into the grid/cell — cleaner decoupling but more plumbing; revisit if the coupling bites. Preload images in the view model — rejected; the model would hold `UIImage`s and bloat.

## Risks / Trade-offs

- **[Risk] No metadata persistence yet → copied files orphan and the grid resets on relaunch.** → Mitigation: Intended phase split; Phase 5 persists the item list and Phase 6 deletes files. Documented as a known limitation.
- **[Risk] Loading full-size images per cell could spike memory with many large photos.** → Mitigation: JPEG re-encode on save reduces size; downsampling/caching is deferred to Phase 13; personal use implies modest counts. Loading happens off the main thread.
- **[Risk] `PhotosPicker` interaction cannot be scripted in the simulator.** → Mitigation: The add logic is testable via `addLocalImages([Data])` in a DEBUG check; the picker itself is a documented manual test.
- **[Trade-off] `GridCellView` references `LocalStorageService.shared`.** → Acceptable coupling for a personal app; only a path→URL lookup, no business logic. A resolver injection is the noted escape hatch.

## Migration Plan

Additive. New files under `ViewModels/` and `Services/`; `.gitkeep`s (and their pbxproj exceptions) removed there. Rollback = delete the new files, restore the `.gitkeep`s, and revert the view changes; no data model or stored-format changes (no metadata file is written yet).

## Open Questions

- None blocking. The `Documents/images/` layout and JPEG normalization are settled here; metadata file format is a Phase 5 decision.
