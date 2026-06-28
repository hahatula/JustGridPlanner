# posted-grid-import

## Purpose

The user-driven capture pipeline for already-posted Instagram media (`/docs/10-decisions.md` Decision 008): open the selected account's profile to screenshot the grid, import the screenshot, align a 3×3 crop overlay, and split the aligned region into nine saved tile images per grid. Turning those tiles into grid items is a later phase.

## Requirements

### Requirement: Open the Instagram profile to screenshot
The app SHALL provide an action that opens the selected account's Instagram profile so the user can screenshot their grid. This action SHALL require a selected account; with none, it SHALL prompt the user to set one. Opening MUST use the public profile web link (which routes to the Instagram app if installed) and MUST NOT require any login, API call, or scraping.

#### Scenario: Open the profile for a selected account
- **WHEN** an account is selected and the user taps "Open Instagram"
- **THEN** the app opens that account's Instagram profile

#### Scenario: Open with no account
- **WHEN** no account is selected and the user taps "Open Instagram"
- **THEN** the app does not open a profile and prompts the user to set an account

### Requirement: Import a screenshot from the photo library
The app SHALL let the user import a screenshot using the system photo picker, limited to images, with no photo-library permission prompt.

#### Scenario: Pick a screenshot
- **WHEN** the user taps "Import Screenshot"
- **THEN** the system photo picker opens (images only) with no permission alert, and the chosen image is loaded into the crop step

### Requirement: Align a 3×3 crop overlay to the grid
The import flow SHALL show the imported screenshot with a movable, resizable crop overlay divided into a 3×3 grid. The overlay's aspect ratio SHALL be locked to the grid being imported: 3:4 for Posts and 9:16 for Reels. The user SHALL be able to reposition and resize the overlay to align it with the screenshot's grid.

#### Scenario: Overlay is a 3×3 frame locked to the grid aspect
- **WHEN** the crop step is shown for the Posts grid
- **THEN** a 3×3 overlay is displayed with a 3:4 overall aspect ratio (9:16 for Reels) that the user can move and resize

### Requirement: Split the aligned region into nine tiles
On confirmation, the app SHALL crop the overlay's region from the screenshot and split it evenly into a 3×3 set of **nine** tile images, saved to local storage. Each tile SHALL have the grid's tile aspect ratio (3:4 for Posts, 9:16 for Reels). The split MUST map the on-screen overlay to the screenshot's pixels correctly (accounting for how the screenshot is scaled to fit the view).

#### Scenario: Nine tiles are produced
- **WHEN** the user confirms the aligned crop
- **THEN** exactly nine tile images are produced and saved, each roughly the grid's tile aspect ratio, in row-major (left-to-right, top-to-bottom) order

#### Scenario: Tiles reflect the cropped region
- **WHEN** the overlay covers a region of the screenshot and is confirmed
- **THEN** the nine tiles are crops of that region (not the whole screenshot), divided into equal thirds horizontally and vertically

### Requirement: Import is per grid and produces a reviewable result
The import flow SHALL be launched per grid (Posts or Reels) and SHALL show the nine resulting tiles for the user to review before finishing. This phase SHALL hand the saved tiles back to its caller; it does not itself place them in the grid.

#### Scenario: Review the split result
- **WHEN** the split completes
- **THEN** the nine tiles are shown for review and the flow can be confirmed or cancelled

#### Scenario: Result is delivered for the launching grid
- **WHEN** the import is launched from the Reels tab and confirmed
- **THEN** the nine saved Reels tiles are delivered to the caller (their placement in the grid is handled by a later phase)
