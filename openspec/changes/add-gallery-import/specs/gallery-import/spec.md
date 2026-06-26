## ADDED Requirements

### Requirement: Import images from the iPhone gallery
The app SHALL let the user choose one or more images from the iPhone photo gallery using the system photo picker (`PhotosPicker`). Selecting images SHALL add them to the grid the user is currently viewing. The picker SHALL be limited to images.

#### Scenario: Picking an image adds it to the grid
- **WHEN** the user opens the gallery picker from the Posts tab and selects an image
- **THEN** a new item for that image appears in the Posts grid

#### Scenario: Multiple images can be selected at once
- **WHEN** the user selects more than one image in the picker
- **THEN** an item is added for each selected image

#### Scenario: Picker is limited to images
- **WHEN** the gallery picker is presented
- **THEN** it offers only images for selection (no video)

### Requirement: Add control lives outside the grid
The control that opens the gallery picker SHALL be placed outside the grid (e.g. in the navigation toolbar) and MUST NOT be rendered as a cell inside the grid, so that planned content is never polluted by interactive controls (`/docs/10-decisions.md` Decision 007).

#### Scenario: Add control is in the toolbar, not the grid
- **WHEN** a grid is displayed
- **THEN** the "add from gallery" control is shown in the navigation toolbar and no grid cell acts as an add button

### Requirement: No photo-library permission prompt
Importing SHALL use the system photo picker so that no photo-library permission prompt is shown and no `NSPhotoLibraryUsageDescription` or photo-library entitlement is required.

#### Scenario: No permission prompt on import
- **WHEN** the user opens the gallery picker for the first time
- **THEN** the system does not show a photo-library permission alert and the picker opens directly

### Requirement: Imported images are copied into local app storage
Each selected image SHALL be copied into the app's local storage (the app Documents directory) and referenced by a relative path stored on the item's `localImagePath`. The original gallery asset MUST NOT be required to remain available for the item to display.

#### Scenario: Selected image is written to app storage
- **WHEN** the user imports an image
- **THEN** the image data is written to a file under the app's Documents directory and the new item's `localImagePath` points to that file

### Requirement: Imported items are local planned items
For each imported image the app SHALL create a `GridItem` with `source == .local`, `gridType` equal to the active grid, a generated unique `id`, and the stored `localImagePath`. Such an item MUST be unlocked (`isLocked == false`).

#### Scenario: Imported item is unlocked and local
- **WHEN** an image is imported into the Reels grid
- **THEN** the created item has `source == .local`, `gridType == .reels`, a non-empty `id`, a `localImagePath`, and `isLocked == false`

### Requirement: Imported items appear at the top of the grid
Newly imported items SHALL be inserted at the top of the grid, above existing items (including already-posted Instagram items), with `orderIndex` updated so the planned items remain on top (`/docs/10-decisions.md` Decision 007). When several images are imported together, their on-screen order SHALL follow the order they were selected.

#### Scenario: New item goes to the top
- **WHEN** the user imports an image into a grid that already contains items
- **THEN** the new item appears first (top-left), above all previously present items

#### Scenario: Imported image is displayed
- **WHEN** an imported item is shown in the grid
- **THEN** its cell displays the imported image (not a placeholder)

#### Scenario: Imported image fills the tile without overflowing
- **WHEN** an imported image whose aspect ratio differs from the tile is shown
- **THEN** the image covers the tile, is centered, and is clipped to the tile bounds (it keeps the tile size and does not overflow into neighbouring cells)

### Requirement: Each grid imports independently
Importing into the Posts grid SHALL NOT affect the Reels grid and vice versa; each grid owns its own items (`/docs/01-business-logic.md`).

#### Scenario: Posts import does not change Reels
- **WHEN** the user imports an image while on the Posts tab
- **THEN** only the Posts grid gains an item and the Reels grid is unchanged
