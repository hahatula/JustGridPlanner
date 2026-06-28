## Why

Posted Instagram media can't be fetched (no API for arbitrary accounts; scraping is forbidden — Phase 11, `/docs/10-decisions.md` Decision 008). The agreed approach is a **user-driven screenshot import**: the user screenshots their profile grid, and the app crops and splits it into posted tiles. Phase 12 of `/docs/08-task-breakdown.md` builds that capture pipeline — open Instagram, import a screenshot, align a draggable 3×3 overlay, and split into 9 tile images. (Turning those tiles into locked grid items and merging them is **Phase 13**.)

## What Changes

- Add an **"Open Instagram"** action that opens the selected account's profile (`https://instagram.com/<username>`, which routes to the Instagram app if installed) so the user can screenshot their grid. It requires a selected account.
- Add a **screenshot import flow** (`ScreenshotImportView`, parameterized by `GridType`): a short instruction, an "Import Screenshot" button using **`PhotosPicker`** (images only, no photo-library permission prompt), then a crop step.
- Add a **draggable, pinch-resizable 3×3 crop overlay** (aspect-locked to the grid — 3:4 for Posts, 9:16 for Reels) that the user aligns to the grid in the screenshot.
- **Split** the aligned region evenly into **9 tile images**, save them to local storage (reusing `LocalStorageService.saveImageData`), and show a preview of the result.
- Add a per-tab **toolbar button** to launch the import flow.

The flow ends by handing back the 9 saved tile paths via a completion callback; **wiring them into the grid as locked posted items is Phase 13** (so this phase has no grid change yet).

## Capabilities

### New Capabilities
- `posted-grid-import`: The capture pipeline for posted media — open the profile, import a screenshot, align a 3×3 crop overlay, and split it into 9 saved tile images per grid.

### Modified Capabilities
<!-- None at the spec level. The import flow is additive; it does not change grid-refresh, account-selection, gallery-import, or other requirements. Phase 13 will reconcile refresh with re-import. -->

## Impact

- **New code**: `Views/ScreenshotImportView.swift` (the flow), `Views/CropOverlay.swift` (draggable/resizable 3×3 overlay), `Utilities/GridSplitter.swift` (crop-rect → 9 tile images + view↔image coordinate mapping), `Utilities/InstagramProfileLink.swift` (profile URL + open), `Views/PostedImportButton.swift` (toolbar entry).
- **Modified code**: `Views/PostsGridView.swift` + `Views/ReelsGridView.swift` (add the import toolbar button). Reuses `LocalStorageService.saveImageData` and `AppSettingsStore.selectedUsername`.
- **Storage**: saved tile images live under `Documents/images/` like other local images. (Until Phase 13 consumes them, test runs may leave tile files behind.)
- **Dependencies**: none added — SwiftUI, PhotosUI, UIKit/CoreGraphics (for cropping).
- **Permissions**: none — `PhotosPicker` needs no photo-library permission; opening an `https` profile link needs no entitlement.
- **Tech stack**: matches `/docs/02-tech-stack.md`; honors the Instagram rules (manual import, no API/scraping/login).

## Non-goals

- **No grid integration** — converting the 9 tiles into locked posted `GridItem`s, persisting them, and merging below the local block is **Phase 13**.
- **No `instagram://` custom-scheme deep link** — opening `https://instagram.com/<username>` (a universal link) reaches the app without needing `LSApplicationQueriesSchemes`/Info.plist changes.
- **No auto-detection of the grid** in the screenshot — the user aligns the overlay manually (more reliable than computer vision).
- **No auto-grab of the "latest" screenshot** — that needs full photo-library permission; the user picks the screenshot via `PhotosPicker`.
- **No real Instagram API, networking, auth, or scraping** — forbidden / not needed (`/docs/07-agent-workflow.md`).
- **No handling of partial rows, pinned posts, or non-3×3 layouts** — v1 assumes a 3×3 region; the user crops to the first 9 tiles.
- Nothing from `/docs/11-out-of-scope.md`.
