## Context

The per-grid `GridPlannerViewModel` owns items (local planned on top), persists local items, and currently DEBUG-seeds Instagram placeholders from `SampleData`. Phase 9 added `InstagramSyncService` + `MockInstagramSyncService` (`fetchPostedMedia(forUsername:gridType:) async throws -> [GridItem]`, returning locked items in Instagram order). `AppSettingsStore` exposes `selectedUsername`. Phase 10 of `/docs/08-task-breakdown.md` wires refresh + merge per `/docs/01-business-logic.md` (replace Instagram part, keep local, re-merge local-on-top) and `/docs/06-ui-ux-rules.md` (refresh button near the account, error without data loss).

## Goals / Non-Goals

**Goals:**
- A `refresh(username:)` that fetches posted media and merges it under the local block, keeping local items and order.
- A refresh button near the account with loading + error states; refresh requires an account.
- Record `lastSuccessfulRefreshAt` on success.

**Non-Goals:**
- Real networking/auth (Phases 11–12), persisting Instagram items, auto-refresh, pull-to-refresh, refresh-both, visual polish. See proposal Non-goals.

## Decisions

### Decision 1: `refresh` merges `locals + fetchedInstagram`, on success only
- **Choice**: `@discardableResult func refresh(username: String?) async -> Bool` on `GridPlannerViewModel`: if `username` is nil/empty, set `refreshError` (prompt to set account) and return `false`; else set `isRefreshing = true` (cleared via `defer`), `try await sync.fetchPostedMedia(forUsername:gridType:)`, then `items = renumbered(items.filter { $0.source == .local } + fetched)` and return `true`; on `catch`, set `refreshError` and return `false` (leaving `items` untouched).
- **Rationale**: Filtering to `.local` keeps every local item in its order and drops the *old* Instagram items, so a re-refresh replaces rather than duplicates; appending the fetched items puts Instagram below in Instagram order; renumbering keeps planned-on-top and the array-index == `orderIndex` invariant (`/docs/10` Decision 007). Mutating `items` only on success guarantees a failed refresh never loses local items (`/docs/06`). No persist is needed — local items are unchanged and Instagram items are not persisted.
- **Alternatives**: Mutate then roll back on error — rejected; build the new array and assign only on success. Persist after refresh — unnecessary (local unchanged).

### Decision 2: Inject `InstagramSyncService`, default `MockInstagramSyncService`
- **Choice**: `init(gridType:storage:sync: InstagramSyncService = MockInstagramSyncService())`. The view model depends on the protocol, not the concrete mock.
- **Rationale**: Phase 11–12 swaps in the real service with no view-model change; the default mock keeps current behavior and lets a DEBUG check inject a throwing stub to exercise the error path. Keeps the service UI-independent (the view model consumes it).

### Decision 3: Remove DEBUG `SampleData` Instagram seeding; Instagram comes from refresh
- **Choice**: `init` builds `items` from persisted local items only (`renumbered(saved)`); no Instagram placeholders. Instagram items appear after the user refreshes. `SampleData` stays for `#Preview`s.
- **Rationale**: Now that refresh provides real (mock) Instagram items, seeding placeholders would double up and misrepresent state. On launch the grid shows the user's planned items; refresh merges in posted media — the true model. No auto-refresh (manual per `/docs/06`; also avoids needless calls / future rate limits).
- **Alternatives**: Auto-refresh on launch — rejected; refresh is user-triggered, and auto-calling the real API later is undesirable.

### Decision 4: Reusable `RefreshButton` near the account; `markRefreshed()` on the store
- **Choice**: A `RefreshButton` (leading toolbar item, beside the account button) reads `@Environment(AppSettingsStore.self)`; it shows `arrow.clockwise`, or a `ProgressView` while `viewModel.isRefreshing`. On tap it runs `Task { if await viewModel.refresh(username: store.selectedUsername) { store.markRefreshed() } }`. Each grid view binds an `.alert` to `viewModel.refreshError`. `AppSettingsStore.markRefreshed()` sets `settings.lastSuccessfulRefreshAt = Date()` and persists.
- **Rationale**: Places refresh "near the selected username" (`/docs/06`) and reuses one control on both tabs. The view coordinates the per-grid refresh (view model) with the app-level timestamp (settings store), which each owns appropriately. The error alert surfaces failures without losing data.
- **Alternatives**: Refresh inside the settings sheet — rejected; too buried for a frequent action. Putting `lastSuccessfulRefreshAt` on the view model — rejected; it is app-level, owned by settings.

## Risks / Trade-offs

- **[Risk] After relaunch the grid shows no Instagram items until refreshed.** → Intended: Instagram items are sync-derived, not persisted; the user refreshes to see posted media. Local planning is fully available immediately.
- **[Risk] Failure path is hard to trigger with the always-succeeding mock.** → Mitigation: the DEBUG sanity check injects a throwing stub to verify local items survive and the error is set.
- **[Trade-off] Per-tab refresh (not both at once).** → Acceptable; each grid is independent. "Refresh both" is optional later.
- **[Trade-off] Minimal loading/error visuals.** → Acceptable; visual polish is Phase 13. Behavior (no data loss, clear message) is correct now.

## Migration Plan

Additive behavior; removes only the DEBUG placeholder seeding. Rollback = restore the seeding, drop `refresh`/`RefreshButton`/`markRefreshed`. No stored-format change (Instagram items never persisted; local items untouched by refresh).

## Open Questions

- None blocking. Displaying "last refreshed …" in the account sheet and pull-to-refresh are optional Phase 13 polish.
