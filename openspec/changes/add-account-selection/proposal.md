## Why

The local planning loop (add / reorder / remove, persisted) is complete, but the app doesn't yet know *which* Instagram account's grid is being planned. Phase 8 of `/docs/08-task-breakdown.md` lets the user choose and store an Instagram username — the prerequisite for Instagram sync (Phases 9–10). Per `/docs/10-decisions.md` Decision 005 the account is selected by username and stored locally, normalized without `@`.

## What Changes

- Add an **`AppSettings`** model (`/docs/05-data-model.md`): `selectedInstagramUsername`, `lastSuccessfulRefreshAt`, `activeGridType`. Only the username is read/written this phase; the other two are present for later phases (refresh, tab tracking) and default to `nil` / `.posts`.
- Add a **username normalizer** (`/docs/03-requirements.md`, `/docs/06-ui-ux-rules.md`): trims spaces, accepts a leading `@`, accepts a pasted Instagram profile URL, and yields a clean username without `@` (lowercased); empty input yields "no account".
- Add an app-level **`AppSettingsStore`** (`@Observable`) that loads settings on launch, exposes the current username, and saves on change — shared across both tabs via `@Environment`.
- Persist settings locally via **`LocalStorageService`** (`saveSettings`/`loadSettings`, JSON at `Documents/settings.json`; missing/corrupt loads as defaults).
- Add a **toolbar account button** on each tab (shows `@username`, or "Set account" when empty) that opens an **account settings sheet** with a username field. The sheet shows the current state ("Planning grid for @username") and lets the user change or clear it.

## Capabilities

### New Capabilities
- `account-selection`: Choosing the Instagram account to plan by username — normalizing input, storing it locally, restoring it on launch, and showing/editing it via a toolbar button and settings sheet.

### Modified Capabilities
<!-- None. The account UI is additive (a toolbar button + sheet); it does not change app-shell, grid-display, gallery-import, local-persistence, remove-local-items, reorder-local-items, or grid-models requirements. -->

## Impact

- **New code**: `Models/AppSettings.swift`, `Utilities/Username.swift` (normalizer), `ViewModels/AppSettingsStore.swift`, `Views/AccountToolbarButton.swift` (reusable toolbar button + sheet presentation), `Views/AccountSettingsView.swift` (the sheet).
- **Modified code**: `Services/LocalStorageService.swift` (`saveSettings`/`loadSettings`), `Views/MainTabView.swift` (create the store, inject via `.environment`), `Views/PostsGridView.swift` + `Views/ReelsGridView.swift` (add the account toolbar button).
- **Removed**: `Utilities/.gitkeep` (first real file there).
- **Storage**: adds `Documents/settings.json`; grid metadata/images unchanged.
- **Dependencies**: none added. SwiftUI + Foundation only.
- **Tech stack**: no deviation from `/docs/02-tech-stack.md` (local JSON).

## Non-goals

- **No Instagram refresh / sync** — Phases 9–10. The stored username is made available for refresh, but nothing fetches yet. `lastSuccessfulRefreshAt` stays `nil`.
- **No refresh button** — `/docs/06-ui-ux-rules.md` places it "near the selected username"; it is added in Phase 10.
- **No login / OAuth / password** — the account is just a username (`/docs/10-decisions.md` Decision 005, `/docs/11-out-of-scope.md`).
- **No multi-account support** — a single selected username (`/docs/11-out-of-scope.md`).
- **No account validation against Instagram** (does the handle exist?) — only input normalization; real validation is a sync concern (Phases 9–12).
- **No wiring of `activeGridType` to the tab selection** — the field exists but is not yet driven by the active tab.
- Nothing else from `/docs/11-out-of-scope.md`.
