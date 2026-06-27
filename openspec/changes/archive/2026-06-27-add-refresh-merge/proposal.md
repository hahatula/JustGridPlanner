## Why

Everything is in place — local planning, an account, and a mock sync boundary — but nothing pulls posted Instagram media into the grid. Phase 10 of `/docs/08-task-breakdown.md` wires it together: a **refresh** that fetches posted media for the selected account, replaces the Instagram-posted part of the grid, and **keeps all local planned items on top in their order** (`/docs/01-business-logic.md`, `/docs/10-decisions.md` Decision 007). This is the first time the grid shows a real "planned + posted" preview, and it completes the MVP loop.

## What Changes

- Add **`GridPlannerViewModel.refresh(username:)`** (async) that calls `InstagramSyncService.fetchPostedMedia(forUsername:gridType:)`, then re-merges the grid as `local planned items (kept, in order, on top) + fetched Instagram items (in Instagram order)`, renumbering `orderIndex`. The view model takes an `InstagramSyncService` (default `MockInstagramSyncService`).
- **Replace** the Instagram-posted items on each refresh while **never** dropping local items; on failure the grid is left untouched (local items safe) and an error is surfaced.
- Add `isRefreshing` and `refreshError` state for a **loading indicator** and a **clear error message** (`/docs/06-ui-ux-rules.md`).
- Add a **refresh button** near the account, on each tab (`/docs/06-ui-ux-rules.md`: "Refresh button near the selected username"). Refresh requires a selected account; with none, it prompts to set one (empty username is not allowed for refresh).
- Set **`lastSuccessfulRefreshAt`** on success via a new `AppSettingsStore.markRefreshed()`.
- **Remove** the DEBUG `SampleData` Instagram seeding from the view model — Instagram items now come from refresh, not a stand-in. (`SampleData` remains for previews.)

## Capabilities

### New Capabilities
- `grid-refresh`: Refreshing a grid from the Instagram sync boundary — replacing posted Instagram items while keeping local planned items on top in order, with loading/error states, an account requirement, and the last-refresh timestamp.

### Modified Capabilities
<!-- None at the spec level. This wires existing capabilities together (instagram-sync stays UI-independent; the sync service is consumed by the view model, not depended on by it inversely). It does not change the requirements of account-selection, local-persistence, grid-display, or instagram-sync. -->

## Impact

- **Modified code**: `ViewModels/GridPlannerViewModel.swift` (inject `InstagramSyncService`, `refresh(username:)`, `isRefreshing`/`refreshError`, drop DEBUG Instagram seeding), `ViewModels/AppSettingsStore.swift` (`markRefreshed()`), `Views/PostsGridView.swift` + `Views/ReelsGridView.swift` (refresh button + error alert).
- **New code**: `Views/RefreshButton.swift` (reusable toolbar refresh control with loading state).
- **Storage / network**: no new storage (Instagram items are not persisted; local items unchanged so no extra write). The mock service makes no network call; real networking is Phase 12.
- **Dependencies**: none added.
- **Tech stack**: matches `/docs/02-tech-stack.md`; honors `/docs/07-agent-workflow.md` Instagram rules (mock only this phase).

## Non-goals

- **No real Instagram API / networking / auth** — Phases 11–12. Refresh uses the Phase 9 mock.
- **No persistence of Instagram items** — they are sync-derived and re-fetched on each refresh (`/docs/01-business-logic.md`); only local items persist.
- **No auto-refresh on launch** — refresh is user-triggered via the button (`/docs/06-ui-ux-rules.md`). On launch the grid shows local items until the user refreshes.
- **No reordering of Instagram items** — they keep Instagram order; only local items are user-arrangeable (Phases 6–7).
- **No pull-to-refresh, no "refresh both grids at once"** — single per-tab button; could be polish later (Phase 13).
- **No polished empty/error/loading visual design** — minimal indicators now; visual polish is Phase 13.
- Nothing from `/docs/11-out-of-scope.md`.
