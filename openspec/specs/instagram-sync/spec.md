# instagram-sync

## Purpose

Define the boundary for fetching already-posted Instagram media: an `InstagramSyncService` interface, an `InstagramMedia` model with conversion to locked grid items, and a mock implementation — all independent of the UI, so refresh/merge (Phase 10) can be built and tested deterministically and a real API can later replace the mock with no UI churn.

## Requirements

### Requirement: Instagram sync service interface
The app SHALL define an `InstagramSyncService` interface for fetching already-posted Instagram media for a given username and grid. The fetch operation SHALL be asynchronous and able to fail (so a real implementation can surface network/API errors). Implementations SHALL be interchangeable behind this interface (`/docs/10-decisions.md` Decision 004).

#### Scenario: Fetch is asynchronous and typed
- **WHEN** a caller invokes the service's fetch for a username and a grid type
- **THEN** it returns, asynchronously, the posted media for that grid as grid items, or throws on failure

#### Scenario: A mock can stand in for the real service
- **WHEN** code depends on `InstagramSyncService`
- **THEN** a mock implementation can be substituted without changing the caller

### Requirement: Synced media is converted to locked grid items
The service SHALL return posted media as `GridItem`s with `source == .instagram` (therefore `isLocked == true`), carrying the media's identifier (`instagramMediaId`) and thumbnail (`thumbnailURL`). Such items MUST NOT be local and MUST NOT carry a `localImagePath`.

#### Scenario: Posted media becomes a locked item
- **WHEN** the service returns a fetched media item as a `GridItem`
- **THEN** the item has `source == .instagram`, `isLocked == true`, a non-empty `instagramMediaId`, and no `localImagePath`

#### Scenario: Items belong to the requested grid
- **WHEN** the service is asked for `GridType.reels`
- **THEN** every returned item has `gridType == .reels`

### Requirement: Mock returns posted posts and reels
A `MockInstagramSyncService` SHALL implement the interface and return canned posted media — a non-empty set for the Posts grid and a non-empty set for the Reels grid — so later phases can develop refresh and merge deterministically.

#### Scenario: Mock posts grid
- **WHEN** the mock is asked for `GridType.posts`
- **THEN** it returns a non-empty list of locked Instagram items for the Posts grid

#### Scenario: Mock reels grid
- **WHEN** the mock is asked for `GridType.reels`
- **THEN** it returns a non-empty list of locked Instagram items for the Reels grid

### Requirement: The sync service is independent of the UI
The sync service and its mock MUST NOT depend on SwiftUI, views, or view models, and MUST NOT decide final UI ordering (planned-on-top merge). Returned items SHALL reflect Instagram's own order; arranging them with local items is the caller's responsibility (Phase 10).

#### Scenario: No UI dependency
- **WHEN** the service or mock is inspected
- **THEN** it references no SwiftUI/view/view-model types and performs no on-screen arrangement

#### Scenario: Items are in Instagram order, not merged order
- **WHEN** the mock returns items
- **THEN** they are ordered as Instagram would present them (e.g. newest first) and are not interleaved with any local planned items
