# grid-refresh

## Purpose

Refresh a grid's posted media by re-importing a screenshot (the manual import, `/docs/10-decisions.md` Decision 008): replace the grid's posted Instagram items with the newly imported tiles while keeping local planned items on top in order, restoring previously imported posted items on launch. Each grid refreshes independently.

## Requirements

### Requirement: Refresh fetches and replaces Instagram items
"Refresh" for a grid means **re-importing a newer screenshot** (the manual import, `/docs/10-decisions.md` Decision 008): it replaces that grid's posted Instagram items with the newly imported tiles. A subsequent import SHALL replace (not duplicate) the previous posted items. On launch, the previously imported posted items are restored.

#### Scenario: Re-import brings in posted media
- **WHEN** the user re-imports a screenshot for a grid
- **THEN** the grid shows the imported items as locked tiles below the local planned items

#### Scenario: Re-import replaces rather than duplicates
- **WHEN** the user re-imports into a grid that already shows posted items
- **THEN** the previous posted items are replaced by the newly imported set (no duplicates)

### Requirement: Local planned items are kept on top, in order
A refresh MUST keep every local planned item and MUST NOT delete any. Local items SHALL remain above the Instagram items and SHALL preserve their relative order; Instagram items SHALL appear below in Instagram order.

#### Scenario: Local items survive a refresh
- **WHEN** the user refreshes a grid containing local planned items
- **THEN** all local items are still present afterward

#### Scenario: Planned-on-top order after merge
- **WHEN** the merged grid is shown after a refresh
- **THEN** every local item appears above every Instagram item, the local items keep their previous relative order, and the Instagram items follow in Instagram order

### Requirement: Each grid refreshes independently
Refreshing one grid SHALL fetch and merge only that grid's media and SHALL NOT alter the other grid.

#### Scenario: Per-grid refresh
- **WHEN** the user refreshes the Posts grid
- **THEN** only the Posts grid's Instagram items change and the Reels grid is unchanged
