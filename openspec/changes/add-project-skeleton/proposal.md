## Why

The repository currently has no application code — only `/docs` and the OpenSpec workspace. Before any feature work (grid display, gallery import, Instagram sync) can begin, we need a runnable SwiftUI iOS app skeleton with the agreed folder layout and the two-tab navigation (Posts / Reels). Phase 1 of `/docs/08-task-breakdown.md` defines exactly this scope and unblocks all subsequent phases.

## What Changes

- Create a new native iOS SwiftUI Xcode project named `InstagramGridPlanner` targeting iPhone only.
- Add the app entry point (`@main` `App` struct) and a root `MainTabView` with two tabs: **Posts** and **Reels**.
- Add a `PostsGridView` placeholder and a `ReelsGridView` placeholder (each rendering a simple "Coming soon" message). No models, services, or storage in this change.
- Create the empty folder structure under `InstagramGridPlanner/`: `App/`, `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/` (kept with `.gitkeep` so empty folders persist).
- Ensure the project builds and launches in the iOS Simulator and shows the tab bar with both tabs selectable.

## Capabilities

### New Capabilities
- `app-shell`: The app's top-level skeleton — entry point, root tab navigation, and Posts/Reels placeholder screens that subsequent phases will flesh out.

### Modified Capabilities
<!-- None — this is the first capability in the project. -->

## Impact

- **New code**: Xcode project files (`InstagramGridPlanner.xcodeproj`), `InstagramGridPlannerApp.swift`, `MainTabView.swift`, `PostsGridView.swift` (placeholder), `ReelsGridView.swift` (placeholder), empty `Models/`, `ViewModels/`, `Services/`, `Utilities/` folders.
- **Dependencies**: None added. SwiftUI only. No third-party packages.
- **Affected systems**: None — greenfield. No existing storage, network, or data to migrate.
- **Tech stack**: Matches `/docs/02-tech-stack.md` (Swift + SwiftUI + iPhone-only). No deviation.

## Non-goals

- No data models (`GridType`, `GridItemSource`, `GridItem`, `AppSettings`) — Phase 2.
- No grid rendering, no 3-column layout, no item cells — Phase 3.
- No PhotosPicker / gallery import — Phase 4.
- No persistence, no `LocalStorageService` — Phase 5.
- No drag/reorder, no remove actions — Phases 6–7.
- No account / username field, no Settings UI — Phase 8.
- No `InstagramSyncService`, no mock data, no refresh logic — Phases 9–10.
- No items from `/docs/11-out-of-scope.md` (auto-posting, scheduling, analytics, multi-account, backend, login, etc.).
