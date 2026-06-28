## REMOVED Requirements

### Requirement: Only local items are persisted
**Reason**: Imported posted tiles (`source == .instagram`, backed by a local image file) are now persisted too, so persistence is no longer limited to `source == .local`.
**Migration**: Replaced by "Items backed by a local file are persisted" — items carrying a `localImagePath` (local planned and imported posted) are saved/restored; items with no local file (e.g. a future API fetch) still would not be.

## ADDED Requirements

### Requirement: Items backed by a local file are persisted
The app SHALL persist a grid's items that are backed by a local image file (i.e. have a `localImagePath`) — both local planned items and imported posted tiles. Items with no local file SHALL NOT be persisted. Restored items SHALL keep their source, order, and image references, with local planned items above imported posted items.

#### Scenario: Local and posted items are written
- **WHEN** a grid with local planned items and imported posted tiles is saved
- **THEN** the metadata file contains both (each with a `localImagePath`), and any item without a local file is excluded

#### Scenario: Restored grid matches what was saved
- **WHEN** the grid is reloaded from storage
- **THEN** the restored items match what was saved (id, source, gridType, localImagePath, orderIndex), with local planned items above imported posted items
