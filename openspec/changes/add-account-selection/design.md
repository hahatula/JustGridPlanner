## Context

The app plans local grids but has no notion of which Instagram account it is planning for. Phase 8 of `/docs/08-task-breakdown.md` adds account selection by username. `/docs/05-data-model.md` defines `AppSettings`; `/docs/03-requirements.md` and `/docs/06-ui-ux-rules.md` define normalization and the account UI; `/docs/10-decisions.md` Decision 005 fixes "username, stored locally, without `@`". `LocalStorageService` already persists JSON; both grids are independent but share one account.

## Goals / Non-Goals

**Goals:**
- An `AppSettings` model and a normalizer that turns raw input (`@handle`, plain, or a pasted IG URL) into a clean username.
- An app-level store that loads on launch, persists on change, and is shared by both tabs.
- A toolbar account button + settings sheet to view/change/clear the account.

**Non-Goals:**
- Refresh/sync, refresh button, login, multi-account, handle validation against Instagram, `activeGridType` wiring. See proposal Non-goals.

## Decisions

### Decision 1: `AppSettings` model with all three documented fields
- **Choice**: `struct AppSettings: Codable, Equatable` with `selectedInstagramUsername: String?`, `lastSuccessfulRefreshAt: Date?`, `activeGridType: GridType` (default `.posts`). Only the username is user-set this phase.
- **Rationale**: Matches `/docs/05-data-model.md` field-for-field, so Phase 10 (refresh sets `lastSuccessfulRefreshAt`) and tab tracking need no model change. Optionals model "not set yet".
- **Alternatives**: Only model the username now — rejected; the documented model is tiny and including it avoids a later migration.

### Decision 2: String-based username normalizer in `Utilities/`
- **Choice**: `enum Username { static func normalized(_ raw: String) -> String? }`. Steps: trim whitespace; if the text contains `instagram.com/`, take the segment after it up to the next `/` or `?`; strip a leading `@`; lowercase; return `nil` if the result is empty.
- **Rationale**: A substring approach handles partial URLs (`instagram.com/olgo.js`, no scheme) more robustly than `URL` parsing, and covers the documented cases (`@olgo.js`, `https://instagram.com/olgo.js`, surrounding spaces → `olgo.js`). Lowercasing matches Instagram handles (case-insensitive) and prevents `Olgo.js`/`olgo.js` duplicates. Pure function → trivially testable.
- **Alternatives**: `URLComponents` parsing — rejected; fails on scheme-less input. No lowercasing — rejected; risks duplicate-looking accounts.

### Decision 3: App-level `@Observable AppSettingsStore`, shared via `@Environment`
- **Choice**: `@Observable final class AppSettingsStore` loads `AppSettings` via `LocalStorageService.loadSettings()` on init, exposes `settings`, and offers `setUsername(_ raw: String)` (normalize → store → `saveSettings`) and `clearUsername()`. `MainTabView` creates it as `@State` and injects `.environment(store)`; tab views and the sheet read `@Environment(AppSettingsStore.self)`.
- **Rationale**: One account is shared by both tabs, so a single app-level observable is the natural owner; `@Environment` with `@Observable` is the iOS-17 idiom and re-renders the toolbar label when the account changes. Persistence stays in the store + service, not the views.
- **Alternatives**: A singleton — rejected; `@Environment` keeps it testable and explicit. Per-tab copies — rejected; they would diverge.

### Decision 4: Persist settings as JSON via `LocalStorageService`
- **Choice**: Add `saveSettings(_:) throws` and `loadSettings() -> AppSettings` writing/reading `Documents/settings.json` with the existing ISO-8601 JSON coders. `loadSettings` returns a default `AppSettings()` when the file is missing or corrupt (graceful, like `loadItems`).
- **Rationale**: Keeps a single local-JSON storage approach (`/docs/02-tech-stack.md`) and one storage service (`/docs/04-architecture.md`), reusing the configured coders. Graceful default means first launch and corruption never break startup.
- **Alternatives**: `UserDefaults` — idiomatic for prefs but introduces a second storage mechanism; rejected for consistency.

### Decision 5: Toolbar account button + settings sheet
- **Choice**: A reusable `AccountToolbarButton` (leading toolbar item) shows `@username` when set or a "Set account" prompt when empty, and presents `AccountSettingsView` as a sheet. The sheet has a username `TextField` (placeholder `@username`), shows the current state ("Planning grid for @username"), and a Save action that calls `store.setUsername(...)`; an empty field clears the account. The gallery "+" button stays in the trailing slot.
- **Rationale**: Implements the chosen UI (toolbar button → sheet) from `/docs/06-ui-ux-rules.md` while keeping the grid full-height. Reusing one button view across both tabs avoids duplication. The sheet is the simple, no-onboarding editor the docs call for.
- **Alternatives**: Inline header / always-visible field — not chosen (more persistent UI above the grid).

## Risks / Trade-offs

- **[Risk] Normalizer misses an odd URL/handle shape.** → Mitigation: cover the documented cases with the DEBUG sanity check; the field is freely re-editable, so a bad normalization is low-cost to fix.
- **[Trade-off] Lowercasing the handle.** → Acceptable and conventional for Instagram; documented.
- **[Trade-off] Settings stored separately from grid metadata.** → Intentional: app config vs grid data; both are local JSON via the same service.
- **[Note] No real handle validation.** → Out of scope; the username is only validated for emptiness (refresh-time check arrives in Phase 10).

## Migration Plan

Additive. First launch has no `settings.json`, so `loadSettings()` returns defaults (no account). Rollback = delete the new files, the `LocalStorageService` settings methods, and the toolbar wiring; restore `Utilities/.gitkeep`. No change to grid metadata/images.

## Open Questions

- None blocking. The refresh button placement (near the account) and `activeGridType` wiring are deferred to Phase 10.
