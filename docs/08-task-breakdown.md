# Task Breakdown

## Goal

Implement the complete personal Instagram grid planner in small, controlled steps.

The first complete product must include both local planning and posted Instagram media refresh behavior.

## Phase 1 — Project Skeleton

- Create SwiftUI app structure
- Add main tab navigation
- Add Posts tab placeholder
- Add Reels tab placeholder
- Add basic project folders:
  - Models
  - Views
  - ViewModels
  - Services
  - Utilities

## Phase 2 — Core Models

- Add grid type model
- Add grid item source model
- Add grid item model
- Add locked/unlocked behavior
- Add sample/mock data for development

## Phase 3 — Local Grid Display

- Implement reusable grid view
- Display 3-column grid
- Support Posts grid
- Support Reels grid
- Display local and Instagram/mock items differently
- Show locked indicator for Instagram items

## Phase 4 — Gallery Import

- Add iPhone gallery image picker
- Add selected images to the active grid
- Copy selected images into local app storage
- Create local grid item metadata

## Phase 5 — Local Persistence

- Save grid metadata locally
- Load grid metadata on app launch
- Keep imported image files in app storage
- Handle missing/corrupted local files gracefully

## Phase 6 — Remove Local Items

- Add remove action for local planned items
- Prevent normal remove action for Instagram items
- Delete local image files when safe
- Persist changes after removal

## Phase 7 — Drag Reorder

- Allow drag reorder for local planned items
- Prevent drag reorder for Instagram items
- Persist updated order
- Validate behavior separately for Posts and Reels tabs

## Phase 8 — Account Selection

- Add app settings model
- Add selected Instagram username field
- Normalize username input
- Save selected username locally
- Load selected username on app launch
- Show current target account in the UI
- Pass selected username into refresh logic
- Handle empty username state

## Phase 9 — Instagram Service Boundary

- Define Instagram sync service interface
- Add mock Instagram sync implementation
- Return mock posted posts and reels
- Convert synced media into locked grid items
- Keep service separate from UI

## Phase 10 — Refresh Merge Logic

- Implement refresh behavior
- Replace/update Instagram-posted items
- Keep manually added local planned items
- Preserve local planned order
- Add manual tests for refresh behavior

## Phase 11 — Real Instagram Integration Research

- Confirm official Instagram API requirements
- Confirm account type requirements
- Confirm available media fields
- Confirm post/reel separation options
- Document exact setup steps

## Phase 12 — Real Instagram Sync Implementation

- Add authentication if needed
- Fetch posted media from official API
- Cache thumbnails locally
- Update Posts grid
- Update Reels grid
- Keep manual planned items after refresh

## Phase 13 — Final Polish

- Empty states
- Error states
- Loading states
- Refresh button states
- Basic settings if needed
- Final manual testing