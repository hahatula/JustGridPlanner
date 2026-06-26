# app-shell Specification

## Purpose
TBD - created by archiving change add-project-skeleton. Update Purpose after archive.
## Requirements
### Requirement: SwiftUI app entry point
The app SHALL provide a single SwiftUI `@main` `App` entry point named `InstagramGridPlannerApp` whose `body` returns a `WindowGroup` containing `MainTabView` as the root view.

#### Scenario: App launches on a clean install
- **WHEN** the app is built and run on an iOS 17+ device or simulator for the first time
- **THEN** the app launches without crashing and presents `MainTabView` as the visible root view

#### Scenario: Single composition root
- **WHEN** a developer inspects `InstagramGridPlannerApp.body`
- **THEN** it contains exactly one `WindowGroup` whose content is a `MainTabView()` instance and no other top-level views

### Requirement: Two-tab main navigation
The app SHALL provide a `MainTabView` containing exactly two tabs — a **Posts** tab and a **Reels** tab — using SwiftUI `TabView`. No additional tabs SHALL be present.

#### Scenario: Both tabs are visible
- **WHEN** the user launches the app
- **THEN** a tab bar is visible at the bottom of the screen showing exactly two tab items labeled "Posts" and "Reels"

#### Scenario: Tab switching works
- **WHEN** the user taps the "Reels" tab while the "Posts" tab is active
- **THEN** the selection changes to the Reels tab and the Reels placeholder content is displayed

#### Scenario: Default selected tab is Posts
- **WHEN** the user launches the app for the first time
- **THEN** the Posts tab is selected by default and the Posts placeholder content is displayed

### Requirement: Posts tab placeholder
The Posts tab SHALL host a `PostsGridView` placeholder that contains a `NavigationStack` and displays a static message indicating the feature is upcoming. The placeholder MUST NOT render any grid, image picker, or item data in this phase.

#### Scenario: Placeholder content
- **WHEN** the Posts tab is active
- **THEN** the visible content is a `NavigationStack` containing a centered text identifying the tab (e.g., "Posts") and a subtitle indicating placeholder status (e.g., "Coming soon")

#### Scenario: No feature behavior yet
- **WHEN** the Posts tab is active
- **THEN** no PhotosPicker, no grid cells, no Instagram items, no refresh button, and no persistence are present

### Requirement: Reels tab placeholder
The Reels tab SHALL host a `ReelsGridView` placeholder that contains a `NavigationStack` and displays a static message indicating the feature is upcoming. The placeholder MUST NOT render any grid, image picker, or item data in this phase.

#### Scenario: Placeholder content
- **WHEN** the Reels tab is active
- **THEN** the visible content is a `NavigationStack` containing a centered text identifying the tab (e.g., "Reels") and a subtitle indicating placeholder status (e.g., "Coming soon")

#### Scenario: No feature behavior yet
- **WHEN** the Reels tab is active
- **THEN** no PhotosPicker, no grid cells, no Instagram items, no refresh button, and no persistence are present

### Requirement: Canonical project folder layout
The Xcode project SHALL contain the following top-level source folders under the app target, mirrored on disk and as Xcode groups: `App/`, `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/`. Empty folders SHALL be preserved in source control via a `.gitkeep` file until the first real file lands.

#### Scenario: All required folders exist on disk
- **WHEN** a developer inspects the project source tree
- **THEN** the directories `App/`, `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/` all exist under the app source root

#### Scenario: Skeleton files live in the correct folders
- **WHEN** a developer inspects file locations
- **THEN** `InstagramGridPlannerApp.swift` is located in `App/`, and `MainTabView.swift`, `PostsGridView.swift`, and `ReelsGridView.swift` are located in `Views/`

#### Scenario: Empty folders persist in git
- **WHEN** the repository is cloned fresh
- **THEN** each currently-empty folder (`Models/`, `ViewModels/`, `Services/`, `Utilities/`) contains a `.gitkeep` file so the folder is tracked

### Requirement: No premature dependencies or features
This change MUST NOT introduce any of the following: data models, persistence layer, `PhotosPicker` integration, `InstagramSyncService` or its mock, account/username UI, drag-and-drop behavior, or third-party Swift packages.

#### Scenario: No third-party dependencies
- **WHEN** a developer inspects the Xcode project's package dependencies
- **THEN** the list is empty (SwiftUI and Foundation only)

#### Scenario: No feature code from later phases
- **WHEN** a developer greps the codebase for `GridItem`, `PhotosPicker`, `InstagramSyncService`, `LocalStorageService`, `AppSettings`, or any drag/reorder API
- **THEN** no matches are found

### Requirement: Builds and runs on iOS 17+
The Xcode project SHALL build without errors or warnings introduced by this change, and SHALL run in the iOS Simulator targeting iPhone with a deployment target of iOS 17.0 or later.

#### Scenario: Clean build succeeds
- **WHEN** a developer runs a clean build of the `InstagramGridPlanner` scheme for an iPhone simulator
- **THEN** the build completes successfully with no errors

#### Scenario: App runs in simulator
- **WHEN** the developer runs the app in an iPhone simulator
- **THEN** the app launches, shows the two-tab interface, and remains responsive to tab taps without crashing

