# grid-refresh

## Purpose

Refresh a grid from the Instagram sync boundary: fetch the selected account's posted media and merge it under the local planned block, replacing prior Instagram items while keeping local items on top in order, with loading/error states, an account requirement, and a recorded last-refresh time.

## Requirements

### Requirement: Refresh fetches and replaces Instagram items
The app SHALL provide a refresh action that fetches the selected account's posted media for a grid (via the Instagram sync service) and replaces that grid's Instagram-posted items with the fetched ones. A subsequent refresh SHALL replace (not duplicate) the previously fetched Instagram items.

#### Scenario: Refresh brings in posted media
- **WHEN** the user refreshes a grid for a selected account
- **THEN** the grid shows the fetched Instagram items as locked tiles

#### Scenario: Re-refresh replaces rather than duplicates
- **WHEN** the user refreshes a grid that already shows Instagram items
- **THEN** the previous Instagram items are replaced by the newly fetched set (no duplicates)

### Requirement: Local planned items are kept on top, in order
A refresh MUST keep every local planned item and MUST NOT delete any. Local items SHALL remain above the Instagram items and SHALL preserve their relative order; Instagram items SHALL appear below in Instagram order.

#### Scenario: Local items survive a refresh
- **WHEN** the user refreshes a grid containing local planned items
- **THEN** all local items are still present afterward

#### Scenario: Planned-on-top order after merge
- **WHEN** the merged grid is shown after a refresh
- **THEN** every local item appears above every Instagram item, the local items keep their previous relative order, and the Instagram items follow in Instagram order

### Requirement: Refresh requires a selected account
Refresh SHALL require a selected account. If no account is selected (empty username), the app MUST NOT attempt a fetch and SHALL prompt the user to set an account.

#### Scenario: Refresh with no account
- **WHEN** the user triggers refresh while no account is selected
- **THEN** no fetch occurs and the app prompts the user to set an account

### Requirement: Failed refresh preserves local items and shows an error
If a refresh fails, the app SHALL keep the grid's local planned items unchanged and SHALL show a clear error message rather than losing data.

#### Scenario: Refresh failure
- **WHEN** a refresh fails (the sync service throws)
- **THEN** the grid's local planned items are unchanged and a clear error message is shown

### Requirement: Refresh shows progress and records success
While a refresh is in flight the app SHALL indicate that it is loading. On a successful refresh the app SHALL record the time of the last successful refresh.

#### Scenario: Loading indicator during refresh
- **WHEN** a refresh is in progress
- **THEN** the UI shows a loading indication for that grid's refresh control

#### Scenario: Last successful refresh is recorded
- **WHEN** a refresh succeeds
- **THEN** the app updates its "last successful refresh" timestamp

### Requirement: Each grid refreshes independently
Refreshing one grid SHALL fetch and merge only that grid's media and SHALL NOT alter the other grid.

#### Scenario: Per-grid refresh
- **WHEN** the user refreshes the Posts grid
- **THEN** only the Posts grid's Instagram items change and the Reels grid is unchanged
