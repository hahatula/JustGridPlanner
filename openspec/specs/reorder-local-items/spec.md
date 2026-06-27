# reorder-local-items

## Purpose

Let users drag local planned items to reorder them within the top (planned) block of a grid, keeping Instagram items locked in their original order below the locals, and persisting the new order per grid.

## Requirements

### Requirement: Local items can be reordered by drag
The user SHALL be able to drag a local planned item and drop it onto another local item to change its position in the grid. On drop, the dragged item SHALL take the target item's position within the local block and the other items SHALL shift accordingly.

#### Scenario: Drag reorders a local item
- **WHEN** the user drags one local item and drops it onto another local item
- **THEN** the dragged item moves to the target's position and the remaining local items shift to accommodate it

#### Scenario: Dropping an item on itself is a no-op
- **WHEN** the user drops a local item onto its own tile
- **THEN** the order is unchanged

### Requirement: Only local items participate in reordering
Only items with `source == .local` SHALL be draggable and act as drop targets. Items with `source == .instagram` MUST NOT be draggable and MUST NOT accept drops.

#### Scenario: Instagram items are not draggable
- **WHEN** the user attempts to drag an Instagram tile
- **THEN** no drag begins and the item stays in place

#### Scenario: Instagram items are not drop targets
- **WHEN** a dragged local item is released over an Instagram tile
- **THEN** no reorder occurs (the drop is not accepted there)

### Requirement: Instagram order and planned-on-top are preserved
Reordering SHALL keep all Instagram items in their original relative order and SHALL keep local planned items above Instagram items. A reorder MUST only rearrange items within the local block.

#### Scenario: Instagram items keep their order after a reorder
- **WHEN** the user reorders local items
- **THEN** the Instagram items remain in the same relative order, below the local block

#### Scenario: Planned items stay on top
- **WHEN** the user reorders local items
- **THEN** every local item still appears above every Instagram item

### Requirement: Reordered order is persisted
After a reorder the grid's saved metadata SHALL reflect the new order so it survives an app restart. Each grid (Posts, Reels) SHALL reorder and persist independently.

#### Scenario: New order survives a restart
- **WHEN** the user reorders local items, then quits and relaunches the app
- **THEN** the local items appear in the new order

#### Scenario: Reorder is per-grid
- **WHEN** the user reorders items on the Posts tab
- **THEN** the Reels tab order is unchanged
</content>
