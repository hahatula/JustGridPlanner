## ADDED Requirements

### Requirement: Imported tiles become locked posted items
The app SHALL turn the tiles produced by a screenshot import into posted grid items with `source == .instagram` (therefore `isLocked == true`), each backed by its imported image file (`localImagePath`) and belonging to the grid the import was launched for. There SHALL be nine such items per import, in the order the tiles were produced.

#### Scenario: Tiles become locked posted items
- **WHEN** a screenshot import for the Posts grid completes with nine tiles
- **THEN** nine items appear with `source == .instagram`, `isLocked == true`, a `localImagePath`, and `gridType == .posts`, in tile order

### Requirement: Posted items merge below the local planned items
Imported posted items SHALL be placed below the local planned items, which stay on top in their order (`/docs/10-decisions.md` Decision 007). Importing posted items MUST NOT remove or reorder any local planned item.

#### Scenario: Planned items stay on top after import
- **WHEN** the user imports posted tiles into a grid that already has local planned items
- **THEN** every local planned item remains, in its order, above the imported posted items

### Requirement: Re-importing replaces the posted block
A new screenshot import SHALL replace the grid's existing posted items with the newly imported ones (it does not append). The image files of the replaced posted tiles SHALL be deleted so they do not accumulate. This is what "refresh" means for posted media.

#### Scenario: Re-import replaces, not appends
- **WHEN** the user imports posted tiles into a grid that already shows posted items
- **THEN** the previous posted items are replaced by the new ones (still nine), and the old tile image files are removed

### Requirement: Posted items are locked
Imported posted items MUST NOT be draggable, reorderable, or removable through the normal remove action (`/docs/01-business-logic.md`). They are changed only by re-importing.

#### Scenario: Posted items cannot be edited like local items
- **WHEN** a posted item is shown in the grid
- **THEN** it shows the lock indicator and offers no delete or drag affordance

### Requirement: Posted items persist across launches
Imported posted items and their image files SHALL be saved locally and restored on launch, so the posted grid survives a restart without re-importing.

#### Scenario: Posted items survive a restart
- **WHEN** the user imports posted tiles, then quits and relaunches the app
- **THEN** the same posted items are restored, below the local planned items

#### Scenario: Last import time is recorded
- **WHEN** an import completes successfully
- **THEN** the app records the time as the last successful refresh/import
