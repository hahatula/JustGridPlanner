# remove-local-items

## Purpose

Allow users to remove local (imported) planned items from a grid, deleting the underlying image file and persisting the removal, while protecting Instagram-sourced items from deletion.

## Requirements

### Requirement: Local items show a delete control
Every local planned item (`source == .local`) SHALL display a visible delete control on its tile. Instagram items (`source == .instagram`) MUST NOT display a delete control.

#### Scenario: Local tile shows the delete control
- **WHEN** a local planned item is displayed in the grid
- **THEN** its tile shows a delete control (a × badge)

#### Scenario: Instagram tile shows no delete control
- **WHEN** an Instagram item is displayed in the grid
- **THEN** its tile shows the lock indicator and no delete control

### Requirement: Deleting a local item removes it from the grid
Activating a local item's delete control SHALL remove that item from its grid immediately. The other items SHALL keep their relative order, with planned items remaining on top.

#### Scenario: Delete removes the tapped item
- **WHEN** the user taps the delete control on a local tile
- **THEN** that item disappears from the grid and the remaining items keep their order

#### Scenario: Only the targeted item is removed
- **WHEN** the user deletes one local item from a grid containing several items
- **THEN** only that item is removed and all other items (local and Instagram) remain

### Requirement: Instagram items cannot be removed
The app SHALL NOT remove an Instagram item through the delete action. A request to remove an item with `source == .instagram` MUST be ignored.

#### Scenario: Instagram item is not removable
- **WHEN** removal is attempted for an item whose `source` is `.instagram`
- **THEN** the item remains in the grid and nothing is deleted

### Requirement: Removing a local item deletes its image file
Removing a local item SHALL delete the image file referenced by its `localImagePath` from local storage. Deletion MUST be safe: a missing or already-deleted file MUST NOT cause an error, and removal MUST still complete.

#### Scenario: Image file is deleted on removal
- **WHEN** the user removes a local item whose image file exists
- **THEN** that image file no longer exists in app storage

#### Scenario: Missing file does not block removal
- **WHEN** the user removes a local item whose image file is already missing
- **THEN** the item is still removed from the grid and the app does not error

### Requirement: Removal is persisted
After a local item is removed, the grid's saved metadata SHALL be updated so the removal survives an app restart.

#### Scenario: Removed item stays gone after restart
- **WHEN** the user removes a local item, then quits and relaunches the app
- **THEN** the removed item does not reappear in the grid

#### Scenario: Each grid removes independently
- **WHEN** the user removes a local item from the Posts grid
- **THEN** the Reels grid is unchanged
</content>
</invoke>
