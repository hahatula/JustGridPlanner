## 1. Confirm scope before adding files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm there is no account/settings code yet (`grep -RIn "AppSettings\|selectedInstagramUsername\|AppSettingsStore" InstagramGridPlanner/` returns nothing) and that `Utilities/` holds only `.gitkeep`. Record in apply notes.
  - **Acceptance**: One-line note "No account selection yet."
- [x] 1.2 Confirm scope: add `AppSettings` model + username normalization + store/load + toolbar account button/sheet — explicitly NOT refresh/sync (Phases 9–10), refresh button, login/OAuth, multi-account, or `activeGridType` wiring.
  - **Acceptance**: Scope restated in apply notes.

## 2. Add the `AppSettings` model

- [x] 2.1 Create `Models/AppSettings.swift`: `struct AppSettings: Codable, Equatable` with `selectedInstagramUsername: String?`, `lastSuccessfulRefreshAt: Date?`, `activeGridType: GridType`, with defaults (`nil`, `nil`, `.posts`).
  - **Acceptance**: Compiles; encodes/decodes round-trip; default `AppSettings()` has no username.

## 3. Add the username normalizer

- [x] 3.1 Create `Utilities/Username.swift`: `enum Username { static func normalized(_ raw: String) -> String? }` — trim whitespace; if the text contains `instagram.com/`, take the segment after it up to the next `/` or `?`; strip a leading `@`; lowercase; return `nil` if empty.
  - **Acceptance**: `olgo.js`, `@olgo.js`, `https://instagram.com/olgo.js`, `instagram.com/olgo.js/?hl=en`, and `  @olgo.js  ` all normalize to `olgo.js`; `""` and `"   "` return `nil`.

## 4. Persist settings via `LocalStorageService`

- [x] 4.1 Add `func saveSettings(_ settings: AppSettings) throws` (write `Documents/settings.json` atomically with the existing ISO-8601 encoder) and `func loadSettings() -> AppSettings` (decode it; return a default `AppSettings()` when missing or corrupt — never throw).
  - **Acceptance**: Round-trips a saved `AppSettings`; returns defaults for a missing/corrupt file without crashing.

## 5. Add the `AppSettingsStore`

- [x] 5.1 Create `ViewModels/AppSettingsStore.swift`: `@Observable final class AppSettingsStore` that loads `AppSettings` via `storage.loadSettings()` on init and exposes `var settings`. Add `setUsername(_ raw: String)` (normalize via `Username.normalized`; set `selectedInstagramUsername`; `saveSettings`) and `clearUsername()` (set to `nil`; save). Inject `LocalStorageService = .shared` for testability.
  - **Acceptance**: A fresh store reflects the saved username; `setUsername("@olgo.js")` stores `olgo.js` and persists; `clearUsername()` removes it and persists.

## 6. Add the account UI and wire it in

- [x] 6.1 Create `Views/AccountSettingsView.swift`: a sheet reading `@Environment(AppSettingsStore.self)`; a `TextField` (placeholder `@username`) seeded with the current username, a current-state line ("Planning grid for @username" when set), and a Save action that calls `store.setUsername(field)` (an empty field clears the account) then dismisses.
  - **Acceptance**: Entering a username and saving updates the store; clearing the field and saving clears the account.
- [x] 6.2 Create `Views/AccountToolbarButton.swift`: reads `@Environment(AppSettingsStore.self)`; a button showing `@username` when set or "Set account" when empty; presents `AccountSettingsView` as a sheet (`@State` presentation flag).
  - **Acceptance**: The button label reflects the current account and toggles the sheet.
- [x] 6.3 In `Views/MainTabView.swift`, create `@State private var settings = AppSettingsStore()` and inject `.environment(settings)` on the `TabView`.
  - **Acceptance**: Both tabs receive the shared store.
- [x] 6.4 In `PostsGridView` and `ReelsGridView`, add `AccountToolbarButton()` as a leading toolbar item (keep the gallery "+" trailing).
  - **Acceptance**: Both tabs show the account button; opening the sheet and changing the account updates the label on both tabs.

## 7. Build and verify

- [x] 7.1 Add a temporary `#if DEBUG` sanity check: assert `Username.normalized` for the documented cases; then `AppSettingsStore().setUsername("@olgo.js")`, construct a **new** store and assert it restored `olgo.js`; `clearUsername()` and assert a fresh store has no account.
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 7.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 7.3 Manual test in the simulator:
  - **Manual test**:
    1. Launch — the account button shows "Set account".
    2. Tap it, enter `@olgo.js`, save — both tabs now show `@olgo.js`.
    3. Reopen, paste `https://instagram.com/olgo.js`, save — still `olgo.js`.
    4. Clear the field, save — shows "Set account" again.
    5. Relaunch — the last selected account is restored.
- [x] 7.4 Remove the temporary sanity check from 7.1 and rebuild.
  - **Acceptance**: Production code contains only the intended changes; build still succeeds.

## 8. Negative checks

- [x] 8.1 Confirm no out-of-scope concerns leaked in: `grep -RIn "password\|OAuth\|URLSession\|InstagramSyncService\|signIn\|login" InstagramGridPlanner/` returns no matches (account is username-only; no login or sync).
  - **Acceptance**: No login/network/sync code.
- [x] 8.2 Confirm the username is stored without `@` and lowercased (covered by the 7.1 normalization assertions and visible in the diff).
  - **Acceptance**: Stored handle matches `/docs/10-decisions.md` Decision 005.

## 9. Source control & reporting

- [x] 9.1 Delete `Utilities/.gitkeep` (first real file there) and stage all new/modified files.
  - **Acceptance**: `git status` shows `.gitkeep` removed, the new model/util/store/views added, and `LocalStorageService.swift`/`MainTabView.swift`/`PostsGridView.swift`/`ReelsGridView.swift` modified.
- [x] 9.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps, known limitations (no refresh/sync/login; `lastSuccessfulRefreshAt`/`activeGridType` unused yet), and which requirements remain (Phases 9–13).
  - **Acceptance**: Summary lists changed files and confirms the `account-selection` scenarios pass.
- [x] 9.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; tap the account button, set `@olgo.js` (try a pasted profile URL too), confirm both tabs show it and it persists across relaunch, and that clearing it shows "Set account".
  - **Acceptance**: A reader can follow the guide to exercise account selection end-to-end.
