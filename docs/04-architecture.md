# Architecture

The app is a local-first SwiftUI iOS app.

## Layers

1. SwiftUI Views

2. ViewModels

3. Local storage services

4. Instagram sync service (manual screenshot import; see `/docs/10-decisions.md` Decision 008)

## Suggested Folder Structure

InstagramGridPlanner/

  App/

  Models/

  Views/

  ViewModels/

  Services/

  Utilities/

## Main Components

### MainTabView

Contains:

- PostsGridView

- ReelsGridView

### GridPlannerView

Reusable grid screen for posts and reels.

Responsibilities:

- Display grid items

- Support dragging local items

- Prevent dragging Instagram items

- Support removing local items

- Add new local items from PhotosPicker

### GridPlannerViewModel

Responsibilities:

- Own grid state

- Add local media

- Remove local media

- Reorder local media

- Refresh Instagram media

- Save/load state

### LocalStorageService

Responsibilities:

- Save metadata

- Load metadata

- Store imported image files

- Delete local image files when needed

### InstagramSyncService

Boundary for obtaining already-posted Instagram media. The primary implementation
is a manual screenshot import (`/docs/10-decisions.md` Decision 008); a real-API
implementation remains a possible future option behind the same interface
(Decision 004).

Responsibilities:

- Provide posted media for a grid (from the manual screenshot import, or a real API later)

- Convert the source media into locked grid items (`source = instagram`)

- Not responsible for UI ordering

### ScreenshotImportView (and tile splitter)

Responsibilities:

- Open the Instagram profile and guide the user to screenshot the 3×3 grid

- Import a screenshot via PhotosPicker (no photo-library permission prompt)

- Show a draggable 3×3 overlay and split the cropped region into 9 tile images

- Hand the split tiles to the `InstagramSyncService` boundary as locked posted items backed by local image files