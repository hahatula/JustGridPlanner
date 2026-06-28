## Context

Per `/docs/10-decisions.md` Decision 008, posted media is brought in by a user screenshot, not an API. Phase 12 of `/docs/08-task-breakdown.md` builds the capture pipeline; Phase 13 turns the output into locked grid items. The app already has `AppSettingsStore.selectedUsername`, `LocalStorageService.saveImageData(_:) -> String`, `PhotosPicker` usage (gallery import), and the per-grid tab views with a toolbar.

## Goals / Non-Goals

**Goals:**
- Open the selected account's profile; import a screenshot (no permission); align a 3×3 overlay; split into 9 saved tile images, per grid.
- Keep the crop math correct and the interaction simple/reliable.

**Non-Goals:**
- Grid integration / locked items / persistence-as-posted / merge (Phase 13), real API/auth/scraping, grid auto-detection, partial-row handling. See proposal Non-goals.

## Decisions

### Decision 1: Multi-step `ScreenshotImportView(gridType:onComplete:)`
- **Choice**: A single view with `@State` steps — **intro** ("Open Instagram" + instructions + "Import Screenshot") → **crop** (screenshot + overlay + "Split") → **review** (the 9 tiles + "Use these" / "Retake"). `onComplete([String])` returns the saved tile relative paths; the launching tab passes the `gridType` (sets the aspect ratio) and an `onComplete` that, this phase, just dismisses. Launched as a sheet from a per-tab toolbar button (`PostedImportButton`).
- **Rationale**: One self-contained flow keeps the pipeline together and testable; per-grid launch supplies the aspect ratio. Deferring `onComplete` wiring lets Phase 13 plug in grid creation without touching this view.
- **Alternatives**: A navigation push per step — heavier; a sheet with internal steps is simpler.

### Decision 2: Open the profile via the `https` universal link
- **Choice**: `InstagramProfileLink` builds `https://instagram.com/<username>` and opens it with `@Environment(\.openURL)`. No `instagram://` custom scheme.
- **Rationale**: The universal link opens the Instagram app if installed, else Safari — same result without adding `LSApplicationQueriesSchemes` to a generated Info.plist or handling `canOpenURL`. Requires a selected account (else prompt). No login/API/scraping (Decision 008, `/docs/07`).
- **Alternatives**: `instagram://user?username=…` — needs Info.plist query schemes and a fallback; unnecessary complexity.

### Decision 3: Aspect-locked 3×3 overlay; drag-to-move + pinch-to-resize
- **Choice**: `CropOverlay` is a rectangle locked to the grid aspect (Posts 3:4, Reels 9:16) with two interior vertical and two horizontal lines (the 3×3) and a dimmed exterior. A `DragGesture` moves it and a `MagnificationGesture` resizes it (keeping aspect), both clamped to the displayed image's bounds. State: `center` and `size` in the display view's coordinate space.
- **Rationale**: **A 3×3 block of tiles has the same aspect ratio as one tile** (3 wide × 3 tall of a `w:h` tile = `3w:3h = w:h`), so locking the whole overlay to the tile aspect guarantees square-thirds tiles after splitting and removes a degree of freedom from the interaction. Drag + pinch is more robust than corner handles and avoids fiddly hit-testing.
- **Alternatives**: Free-aspect rectangle with 4 corner handles — more controls, easy to produce distorted tiles; rejected. Auto-detect the grid — brittle CV; rejected.

### Decision 4: `GridSplitter` — coordinate mapping then equal-thirds crop
- **Choice**: A pure helper with two parts:
  1. **Map** the overlay rect (view coordinates) to image-pixel coordinates: given the image's pixel size and the `aspect-fit` display frame (scale `s = min(viewW/imgW, viewH/imgH)`, displayed origin centered), `pixelRect = (overlayRect − displayOrigin) / s`, clamped to the image bounds.
  2. **Split**: crop the `pixelRect` from the `CGImage`, then divide into 3 columns × 3 rows of equal size, cropping nine sub-images in row-major order; encode each to JPEG and save via `LocalStorageService.saveImageData`, returning the nine relative paths.
- **Rationale**: Isolating the math in a pure function makes the error-prone coordinate transform unit-testable (known image + known rect → known tile pixels) independent of the gestures. `CGImage.cropping(to:)` works in pixel space, so we convert once. Instagram's ~1px inter-tile gaps are negligible at preview size and ignored.
- **Alternatives**: Crop in UIKit points and fight `UIImage.scale`/orientation — error-prone; working in `CGImage` pixels is unambiguous (screenshots are orientation-`up`).

### Decision 5: Per-tab toolbar entry button
- **Choice**: `PostedImportButton` (e.g. `square.and.arrow.down`) presents the import sheet for the tab's `gridType`. Placed beside the existing account/refresh controls.
- **Rationale**: The import is grid-specific (aspect), so a per-tab entry is natural; mirrors `GalleryImportButton`. Phase 13/14 will reconcile this with the Phase-10 refresh control (refresh → re-import); for now it is a distinct button so Phase 12 is self-contained and testable.

## Risks / Trade-offs

- **[Risk] The view→pixel coordinate mapping is the classic source of off-by-scale bugs** (the same family as the Phase-5 image sizing). → Mitigation: a deterministic DEBUG check feeds a known image + overlay rect through `GridSplitter` and asserts nine tiles of the expected pixel sizes/positions; the gestures are then a thin layer over a verified transform.
- **[Risk] Gesture interaction (drag + pinch simultaneously) can be finicky.** → Mitigation: combine via `.simultaneousGesture`, clamp aggressively, keep the overlay aspect-locked so there are only 3 DOF (x, y, scale).
- **[Trade-off] Saved tiles are orphaned until Phase 13 consumes them.** → Acceptable for a dev build; Phase 13 wires `onComplete` and Phase 6's delete already removes unused local files. Noted.
- **[Trade-off] v1 assumes a clean 3×3.** → Acceptable; the user crops to the first 9 tiles. Partial rows/pinned posts are out of scope.

## Migration Plan

Additive. Rollback = delete the new files and the import toolbar button; no model or storage-format change (tiles are ordinary JPEGs under `Documents/images/`). No grid behavior changes until Phase 13.

## Open Questions

- None blocking. The import button vs. the Phase-10 refresh button is reconciled in Phase 13 (refresh becomes re-import). Whether the overlay should snap to detected edges is possible Phase-14 polish.
