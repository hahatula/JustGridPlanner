# Architecture

The app is a local-first SwiftUI iOS app.

## Layers

1. SwiftUI Views

2. ViewModels

3. Local storage services

4. Optional Instagram sync service

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

Responsibilities:

- Fetch posted media from Instagram API

- Convert API response into locked grid items

- Not responsible for UI ordering