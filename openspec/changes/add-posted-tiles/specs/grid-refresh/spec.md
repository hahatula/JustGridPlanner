## MODIFIED Requirements

### Requirement: Refresh fetches and replaces Instagram items
"Refresh" for a grid means **re-importing a newer screenshot** (the manual import, `/docs/10-decisions.md` Decision 008): it replaces that grid's posted Instagram items with the newly imported tiles. A subsequent import SHALL replace (not duplicate) the previous posted items. On launch, the previously imported posted items are restored.

#### Scenario: Re-import brings in posted media
- **WHEN** the user re-imports a screenshot for a grid
- **THEN** the grid shows the imported items as locked tiles below the local planned items

#### Scenario: Re-import replaces rather than duplicates
- **WHEN** the user re-imports into a grid that already shows posted items
- **THEN** the previous posted items are replaced by the newly imported set (no duplicates)

## REMOVED Requirements

### Requirement: Refresh requires a selected account
**Reason**: Posted media is now obtained by importing a screenshot, which needs no account. The account requirement now applies only to the "Open Instagram" action.
**Migration**: See `posted-grid-import` ("Open the Instagram profile to screenshot" requires a selected account).

### Requirement: Failed refresh preserves local items and shows an error
**Reason**: There is no async fetch to fail. The interactive import is non-destructive (cancelling or failing leaves the grid unchanged), and the import flow owns its own error handling.
**Migration**: See `posted-grid-import` (the import flow) and `posted-tiles` (re-import replaces only on success).

### Requirement: Refresh shows progress and records success
**Reason**: The import is interactive, not an async background fetch, so there is no in-flight loading indicator.
**Migration**: Recording the last successful import time is covered by `posted-tiles` ("Last import time is recorded").
