# local-persistence Specification

## Purpose
TBD - created by archiving change add-local-persistence. Update Purpose after archive.
## Requirements
### Requirement: Local planned items are saved on change
Whenever a grid's local planned items change (e.g. after an import), the app SHALL write that grid's local items to on-device storage as JSON. Each grid (Posts, Reels) SHALL be saved independently.

#### Scenario: Importing writes metadata to disk
- **WHEN** the user imports an image into the Posts grid
- **THEN** the Posts grid's local items are written to a JSON metadata file in the app's storage

#### Scenario: Grids are saved independently
- **WHEN** the Posts grid changes
- **THEN** only the Posts metadata file is updated and the Reels metadata file is left unchanged

### Requirement: Local planned items are restored on launch
On launch each grid SHALL load its previously saved local planned items so that imported items survive an app restart. Restored items SHALL keep their stored order and reference their stored image files.

#### Scenario: Imported items survive a restart
- **WHEN** the user imports images, then quits and relaunches the app
- **THEN** the same local planned items are present in the grid, in the same order, showing their images

#### Scenario: First launch with no saved data
- **WHEN** the app launches and no metadata file exists yet
- **THEN** the grid loads with no persisted local items and does not crash

### Requirement: Only local items are persisted
The app SHALL persist only items with `source == .local`. Items with `source == .instagram` MUST NOT be written to the metadata file, because Instagram items are derived from sync rather than stored as local user data (`/docs/01-business-logic.md`).

#### Scenario: Instagram items are not written
- **WHEN** a grid containing both local and Instagram items is saved
- **THEN** the metadata file contains only the local items and no Instagram items

#### Scenario: Restored grid contains the local items
- **WHEN** the grid is reloaded from storage
- **THEN** the restored local items match what was saved (id, source, gridType, localImagePath, orderIndex)

### Requirement: Imported image files are kept in storage
Persisting metadata MUST NOT remove or move the imported image files; the files referenced by `localImagePath` SHALL remain in app storage so restored items can display them.

#### Scenario: Image files remain after save and reload
- **WHEN** metadata is saved and later reloaded
- **THEN** each restored local item's image file still exists at its `localImagePath`

### Requirement: Missing or corrupted metadata is handled gracefully
Loading metadata SHALL never crash. If the metadata file is missing, unreadable, or contains invalid/corrupted JSON, the grid SHALL load as if there were no saved local items.

#### Scenario: Corrupted metadata file
- **WHEN** the metadata file contains invalid JSON
- **THEN** the grid loads with no persisted local items and the app does not crash

### Requirement: A missing image file degrades gracefully
If a restored local item's image file is missing or unreadable, the app SHALL keep the item and show its placeholder rather than crashing or silently deleting the item.

#### Scenario: Restored item whose image file is gone
- **WHEN** a persisted local item is loaded but its image file no longer exists
- **THEN** the item still appears in the grid showing the placeholder, and the app does not crash

