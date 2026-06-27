## 1. Confirm scope before changing files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm Phase 9's `InstagramSyncService`/`MockInstagramSyncService` exist, the view model still DEBUG-seeds `SampleData` Instagram placeholders, and there is no `refresh` yet (`grep -RIn "func refresh\|isRefreshing\|markRefreshed" InstagramGridPlanner/` returns nothing). Record in apply notes.
  - **Acceptance**: One-line note "Sync mock present; no refresh yet."
- [x] 1.2 Confirm scope: wire refresh + merge (replace Instagram, keep local on top) + refresh button + loading/error + account requirement — explicitly NOT real API/networking (Phases 11–12), persisting Instagram items, auto-refresh, or visual polish (Phase 13).
  - **Acceptance**: Scope restated in apply notes.

## 2. Record last refresh in `AppSettingsStore`

- [x] 2.1 Add `func markRefreshed()` that sets `settings.lastSuccessfulRefreshAt = Date()` and persists.
  - **Acceptance**: Calling it updates the timestamp and writes `settings.json`.

## 3. Add refresh + merge to `GridPlannerViewModel`

- [x] 3.1 Inject `sync: InstagramSyncService = MockInstagramSyncService()`; remove the `#if DEBUG` `SampleData` Instagram seeding so `init` builds `items = renumbered(saved local items)` only.
  - **Acceptance**: A fresh view model starts with only persisted local items (no Instagram placeholders); `#Preview`s still use `SampleData`.
- [x] 3.2 Add `var isRefreshing = false` and `var refreshError: String?`, and `@discardableResult func refresh(username: String?) async -> Bool`: return `false` and set `refreshError` (prompt to set account) when `username` is nil/empty; else set `isRefreshing` (clear via `defer`), `try await sync.fetchPostedMedia(forUsername:gridType:)`, set `items = Self.renumbered(items.filter { $0.source == .local } + fetched)`, return `true`; on `catch` set `refreshError` and return `false` without touching `items`.
  - **Acceptance**: After a successful refresh the locals stay on top in order and the fetched Instagram items follow below; a second refresh replaces (not duplicates) Instagram items; a thrown error leaves `items` unchanged and sets `refreshError`; an empty username does no fetch.

## 4. Add the refresh control

- [x] 4.1 Create `Views/RefreshButton.swift`: takes the `GridPlannerViewModel`, reads `@Environment(AppSettingsStore.self)`. Show a `ProgressView` while `viewModel.isRefreshing`, else an `arrow.clockwise` button. On tap run `Task { if await viewModel.refresh(username: store.selectedUsername) { store.markRefreshed() } }`. Disable while refreshing.
  - **Acceptance**: Tapping refreshes the grid; a spinner shows during the fetch; success records the timestamp.

## 5. Wire the tabs

- [x] 5.1 In `PostsGridView` and `ReelsGridView`, add `RefreshButton(viewModel: viewModel)` to the leading toolbar near the account button (keep gallery "+" trailing).
  - **Acceptance**: Both tabs show a refresh control beside the account button.
- [x] 5.2 Bind an error alert on each grid view to `viewModel.refreshError` (a message with an OK that clears it).
  - **Acceptance**: A failed/empty-account refresh shows an alert; local items remain.

## 6. Build and verify

- [x] 6.1 Add a temporary `#if DEBUG` sanity check (in a `Task`): on a `posts` view model with the mock sync, add two local items, capture their order, `await refresh(username: "olgo.js")`, and assert all locals are still present on top in the same order, Instagram items follow below (locked), and `refresh` returned `true`. Then refresh again and assert Instagram count did not double. Then inject a throwing stub `InstagramSyncService` and assert `refresh` returns `false`, `refreshError != nil`, and the locals are unchanged. Finally assert `refresh(username: nil)` does no fetch and sets `refreshError`.
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 6.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 6.3 Manual test in the simulator:
  - **Manual test**:
    1. Set an account (`@olgo.js`). On Posts, import a couple of local images.
    2. Tap refresh — Instagram (mock) tiles appear **below** the local tiles; local tiles stay on top in order; a spinner shows briefly.
    3. Tap refresh again — Instagram tiles are replaced, not duplicated.
    4. Clear the account, tap refresh — an alert prompts to set an account; local items remain.
    5. Relaunch — local items are present; Instagram items are gone until you refresh again.
    6. Repeat on Reels; confirm Posts is unaffected.
- [x] 6.4 Remove the temporary sanity check from 6.1 and rebuild.
  - **Acceptance**: Production code contains only the intended changes; build still succeeds.

## 7. Negative checks

- [x] 7.1 Confirm no real networking/auth leaked in: `grep -RIn "URLSession\|OAuth\|password\|WKWebView" InstagramGridPlanner/` returns no matches (refresh uses the mock only).
  - **Acceptance**: No real network or login code.
- [x] 7.2 Confirm Instagram items are not persisted: `loadItems`/`saveItems` still operate on local items only, and the metadata file after a refresh contains no `"source" : "instagram"` (inspect or assert in 6.1).
  - **Acceptance**: Only local items persist.

## 8. Source control & reporting

- [x] 8.1 Stage the new and modified files.
  - **Acceptance**: `git status` shows `RefreshButton.swift` added and `GridPlannerViewModel.swift`, `AppSettingsStore.swift`, `PostsGridView.swift`, `ReelsGridView.swift` modified.
- [x] 8.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, manual test steps, known limitations (mock only; Instagram not persisted so gone until refresh; minimal loading/error visuals), and which requirements remain (Phases 11–13).
  - **Acceptance**: Summary lists changed files and confirms the `grid-refresh` scenarios pass.
- [x] 8.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; set an account; import local images; tap refresh to merge mock Instagram items below the local ones; re-refresh (no duplicates); clear account → prompt; relaunch → Instagram gone until refresh; both tabs.
  - **Acceptance**: A reader can follow the guide to exercise refresh/merge end-to-end.
