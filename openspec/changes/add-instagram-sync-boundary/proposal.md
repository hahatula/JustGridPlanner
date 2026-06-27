## Why

The user can now plan local items and pick an account, but the app has no way to bring in already-posted Instagram media. Phase 9 of `/docs/08-task-breakdown.md` establishes the **Instagram sync boundary**: an interface for fetching posted media plus a mock implementation, so the grid/refresh/merge work (Phase 10) can be built and tested against locked Instagram items without waiting on real Instagram API setup (`/docs/10-decisions.md` Decision 004). This phase defines and mocks the service only — it is not yet wired into the UI.

## What Changes

- Define an **`InstagramSyncService`** protocol: `func fetchPostedMedia(forUsername:gridType:) async throws -> [GridItem]` — fetches a username's posted media for one grid and returns it as **locked** Instagram `GridItem`s in Instagram order. The service converts API data into grid items and is **not** responsible for UI ordering (`/docs/04-architecture.md`).
- Add an **`InstagramMedia`** value type modeling one posted media item (`id`, `thumbnailURL`, `takenAt`) — the shape a real API response will map to — and a conversion to a locked `GridItem`.
- Add a **`MockInstagramSyncService`** returning canned posted posts and reels as locked items, so later phases can develop refresh/merge deterministically.
- Keep the service **isolated from the UI** (Services-only, no SwiftUI, no view-model coupling). Wiring into refresh and the view models is Phase 10.

## Capabilities

### New Capabilities
- `instagram-sync`: The boundary for fetching already-posted Instagram media — an `InstagramSyncService` interface, an `InstagramMedia` model with conversion to locked grid items, and a mock implementation returning posted posts and reels — kept independent of the UI.

### Modified Capabilities
<!-- None. The service is additive and not yet wired in; it does not change grid-models, grid-display, gallery-import, local-persistence, remove-local-items, reorder-local-items, account-selection, or app-shell requirements. -->

## Impact

- **New code**: `Models/InstagramMedia.swift` (DTO + conversion to a locked `GridItem`), `Services/InstagramSyncService.swift` (protocol), `Services/MockInstagramSyncService.swift` (mock implementation).
- **Modified code**: none — the service is standalone this phase (no UI or view-model wiring).
- **Dependencies**: none added. Foundation only (the protocol is `async`; no real networking yet).
- **Storage / network**: none. The mock returns in-memory data; no `URLSession`, no Instagram API call.
- **Tech stack**: matches `/docs/02-tech-stack.md` (URLSession reserved for the real sync later) and the Instagram rules in `/docs/07-agent-workflow.md` (official API or mock only; no scraping/login).

## Non-goals

- **No refresh / merge** of synced items into the grid — Phase 10 (`/docs/01-business-logic.md` merge rules). This phase does not call the service from any view model.
- **No real Instagram API, networking, auth, or tokens** — Phases 11–12. No `URLSession`, no credentials.
- **No replacing the DEBUG `SampleData` Instagram placeholders** in the view model yet — that swap happens when refresh is wired (Phase 10).
- **No persistence of synced items** — Instagram items are sync-derived and not stored (`/docs/01-business-logic.md`); only local items persist.
- **No scraping, browser automation, password storage, or unofficial APIs** — forbidden (`/docs/07-agent-workflow.md`, `/docs/11-out-of-scope.md`).
- **No UI ordering / planned-on-top merge** in the service — that is the caller's job in Phase 10.
