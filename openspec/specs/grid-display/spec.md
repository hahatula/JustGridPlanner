# grid-display Specification

## Purpose
TBD - created by archiving change add-local-grid-display. Update Purpose after archive.
## Requirements
### Requirement: Reusable three-column grid
The system SHALL provide a single reusable grid view that renders the items of one grid as a 3-column layout of portrait tiles, parameterized by `GridType` and the array of `GridItem`s to display. Both tabs MUST use this same view so Posts and Reels stay structurally consistent.

#### Scenario: Three equal columns of portrait tiles
- **WHEN** the reusable grid renders a non-empty set of items
- **THEN** items are laid out in exactly 3 columns and each cell is a portrait tile (taller than wide) using the tab's aspect ratio

#### Scenario: Scrolls when items overflow
- **WHEN** the number of items exceeds what fits on screen
- **THEN** the grid scrolls vertically to reveal the remaining items

#### Scenario: Empty input renders without error
- **WHEN** the reusable grid is given an empty array of items
- **THEN** it renders an empty grid without crashing and without showing any placeholder cells

### Requirement: Posts and Reels tabs display their grids
The Posts tab SHALL display the reusable grid for `GridType.posts` and the Reels tab SHALL display it for `GridType.reels`, each within the existing `NavigationStack` and keeping its navigation title. Each grid SHALL show only items whose `gridType` matches that tab.

#### Scenario: Posts tab shows the posts grid
- **WHEN** the Posts tab is active and posts items are available
- **THEN** the Posts grid is shown under the "Posts" navigation title with the posts items as cells

#### Scenario: Reels tab shows the reels grid
- **WHEN** the Reels tab is active and reels items are available
- **THEN** the Reels grid is shown under the "Reels" navigation title with the reels items as cells

### Requirement: Tile aspect ratio matches the Instagram profile grid
Each grid SHALL render its tiles with the portrait aspect ratio Instagram uses for that surface: the Posts grid MUST use a 3:4 tile aspect ratio and the Reels grid MUST use a 9:16 tile aspect ratio. The aspect ratio SHALL be derived from `GridType` in the view layer and MUST NOT be stored on the model.

#### Scenario: Posts tiles are 3:4
- **WHEN** the Posts grid renders its tiles
- **THEN** each tile uses a 3:4 (width:height) portrait aspect ratio

#### Scenario: Reels tiles are 9:16
- **WHEN** the Reels grid renders its tiles
- **THEN** each tile uses a 9:16 (width:height) portrait aspect ratio

### Requirement: Display order follows orderIndex
The grid SHALL present items in ascending `orderIndex` order so the visual arrangement matches the planned grid order. The view MUST NOT mutate the underlying items while sorting for display.

#### Scenario: Items appear in orderIndex order
- **WHEN** items with differing `orderIndex` values are displayed
- **THEN** the cell with the lowest `orderIndex` appears first (top-left) and cells follow in ascending `orderIndex` across then down

### Requirement: Locked Instagram items are visually distinct and marked
Each cell SHALL reflect the item's source. Items with `source == .instagram` (i.e. `isLocked == true`) MUST display a visible lock indicator and a treatment that distinguishes them from local planned items; items with `source == .local` MUST NOT display a lock indicator. The locked state MUST be read from the model's derived `isLocked`, not decided in the view.

#### Scenario: Instagram item shows a lock indicator
- **WHEN** a cell renders an item whose `source` is `.instagram`
- **THEN** the cell shows a lock indicator and is visually distinguishable from a local cell

#### Scenario: Local item shows no lock indicator
- **WHEN** a cell renders an item whose `source` is `.local`
- **THEN** the cell shows no lock indicator

#### Scenario: Lock state comes from the model
- **WHEN** a cell determines whether to show the lock indicator
- **THEN** it uses the item's `isLocked` value and does not re-derive the rule from `source` in view code


### Requirement: Empty grid shows a hint
When a grid has no items to show, the app SHALL display a clear empty-state message inviting the user to add photos (e.g. "Add photos from your gallery to plan your grid." — `/docs/06-ui-ux-rules.md`) instead of a blank screen.

#### Scenario: Empty grid
- **WHEN** a grid has no items
- **THEN** it shows an empty-state message prompting the user to add photos from their gallery

#### Scenario: Non-empty grid shows no hint
- **WHEN** a grid has at least one item
- **THEN** the empty-state message is not shown and the grid is displayed normally
