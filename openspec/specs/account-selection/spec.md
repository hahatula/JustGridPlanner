# account-selection

## Purpose

Let the user choose which Instagram account a grid is being planned for, by username — normalizing the input, storing it locally, restoring it on launch, and showing/editing it from both tabs. This is the prerequisite for Instagram sync (later phases).

## Requirements

### Requirement: App settings model
The app SHALL define an `AppSettings` model carrying `selectedInstagramUsername`, `lastSuccessfulRefreshAt`, and `activeGridType` (`/docs/05-data-model.md`). It MUST be `Codable` so it can be stored locally. In this phase only `selectedInstagramUsername` is set by the user; the other fields exist for later phases.

#### Scenario: Settings hold the selected username
- **WHEN** the user has chosen an account
- **THEN** `AppSettings.selectedInstagramUsername` holds the normalized username and the model can be encoded/decoded without loss

### Requirement: Username normalization
The app SHALL normalize a raw username entry to a clean handle without a leading `@`: it MUST trim surrounding whitespace, accept and strip a leading `@`, and accept a pasted Instagram profile URL by extracting the username from it. Empty or whitespace-only input SHALL normalize to "no account" (no username).

#### Scenario: Plain handle
- **WHEN** the input is `olgo.js`
- **THEN** the normalized username is `olgo.js`

#### Scenario: Leading @ is stripped
- **WHEN** the input is `@olgo.js`
- **THEN** the normalized username is `olgo.js`

#### Scenario: Instagram URL is reduced to the handle
- **WHEN** the input is `https://instagram.com/olgo.js` (with or without scheme, trailing slash, or query)
- **THEN** the normalized username is `olgo.js`

#### Scenario: Surrounding spaces are trimmed
- **WHEN** the input is `  @olgo.js  `
- **THEN** the normalized username is `olgo.js`

#### Scenario: Empty input is no account
- **WHEN** the input is empty or only whitespace
- **THEN** the result is "no account" (no username is stored)

### Requirement: Selecting and changing the account
The app SHALL let the user enter, change, or clear the selected username through the account UI. Setting a username SHALL store its normalized form; clearing it SHALL remove the selected account.

#### Scenario: Set an account
- **WHEN** the user enters a username in the account settings and confirms
- **THEN** the normalized username becomes the selected account and is shown in the UI

#### Scenario: Change the account
- **WHEN** an account is already selected and the user enters a different username
- **THEN** the selected account is replaced with the new normalized username

#### Scenario: Clear the account
- **WHEN** the user clears the username field and confirms
- **THEN** no account is selected

### Requirement: The selected account persists
The selected username SHALL be saved locally and restored on app launch, so the chosen account survives a restart.

#### Scenario: Account survives a restart
- **WHEN** the user selects an account, then quits and relaunches the app
- **THEN** the same account is still selected and shown

### Requirement: The current account is shown
The app SHALL show the current target account in the UI: when an account is selected it SHALL indicate it (e.g. `Planning grid for @username`), and when none is selected it SHALL prompt the user to set one (e.g. "Set account"). The indicator SHALL be reachable from both the Posts and Reels tabs.

#### Scenario: Selected account is displayed
- **WHEN** an account is selected
- **THEN** the UI shows the account (e.g. `@username` / "Planning grid for @username") on both tabs

#### Scenario: Empty account state
- **WHEN** no account is selected
- **THEN** the UI prompts the user to set an account and does not error
