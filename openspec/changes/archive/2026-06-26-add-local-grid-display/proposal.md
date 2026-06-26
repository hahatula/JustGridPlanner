## Why

Phase 2 added the `GridItem` model and DEBUG `SampleData`, but the app still shows "Coming soon" placeholders — nothing renders the grid. Phase 3 of `/docs/08-task-breakdown.md` adds the visible product: a reusable 3-column Instagram-style grid that displays items for both tabs and visually distinguishes locked Instagram media from local planned media. This is the first phase the user can actually *see*, and every later interaction phase (import, remove, reorder, refresh) builds on this view.

## What Changes

- Add a reusable `GridPlannerView` that renders a 3-column Instagram-style profile grid of **portrait tiles** for a given `GridType` and an array of `GridItem`s, sorted by `orderIndex`. The tile aspect ratio is per tab — **3:4 for Posts**, **9:16 for Reels** — matching how Instagram displays profile posts vs. reel covers (`/docs/03-requirements.md`, `/docs/06-ui-ux-rules.md`).
- Add a `GridCellView` that renders one cell: a portrait placeholder with a **visually distinct** treatment for Instagram (locked) vs local (planned) items, and a **lock indicator** overlay on Instagram items (per `/docs/06-ui-ux-rules.md`).
- Replace the placeholder bodies of `PostsGridView` and `ReelsGridView` with `GridPlannerView(gridType:items:)`, keeping their existing `NavigationStack` and navigation titles. In DEBUG the views seed from `SampleData`; in Release they pass an empty array (real items arrive in Phase 4/9).
- Disambiguate the model `GridItem` from SwiftUI's own `GridItem` (used for `LazyVGrid` columns) by qualifying `SwiftUI.GridItem` where the layout columns are declared.

## Capabilities

### New Capabilities
- `grid-display`: The reusable 3-column grid presentation — `GridPlannerView` plus `GridCellView` — that shows `GridItem`s for the Posts and Reels tabs and renders locked vs. unlocked items differently. Display-only; no mutation.

### Modified Capabilities
<!-- None at the spec level. PostsGridView/ReelsGridView are updated, but the app-shell requirements (two tabs, each hosting its view inside a NavigationStack) are unchanged; this change is not yet archived into a baseline spec. -->

## Impact

- **New code**: `InstagramGridPlanner/Views/GridPlannerView.swift`, `InstagramGridPlanner/Views/GridCellView.swift`.
- **Modified code**: `InstagramGridPlanner/Views/PostsGridView.swift`, `InstagramGridPlanner/Views/ReelsGridView.swift` (placeholder bodies replaced with the grid).
- **Dependencies**: None added. SwiftUI + the existing `GridItem`/`GridType`/`GridItemSource` models only.
- **Affected systems**: UI only. No models, storage, services, or app entry point change. The two tabs and their titles stay the same.
- **Tech stack**: No deviation from `/docs/02-tech-stack.md`.

## Non-goals

- No `PhotosPicker` / gallery import or any "add" affordance — Phase 4. When added, the "add from gallery" control must live **outside** the grid (e.g. a toolbar button), never as an interactive in-grid cell, so the preview is not polluted (`/docs/10-decisions.md` Decision 007).
- No persistence / `LocalStorageService` — Phase 5; the grid renders whatever array it is handed.
- No remove/delete action on cells — Phase 6. (`/docs/06-ui-ux-rules.md` mentions a delete affordance for local items, but the wiring belongs to Phase 6.)
- No drag/reorder — Phase 7. Cells are static; `isLocked` is shown but not yet enforced against a gesture.
- No `GridPlannerViewModel` — deferred to Phase 4 when there is mutable state to own (avoid premature abstraction per `/AGENTS.md`). `GridPlannerView` is a pure presentation view that takes its items as input.
- No real image loading from disk or network — local files come in Phase 4, Instagram thumbnails in Phase 9/12. Phase 3 cells are placeholders (sample items carry `nil` paths/URLs).
- No account/username UI (Phase 8), no Instagram sync (Phase 9), no refresh (Phase 10).
- No polished empty-state message — Phase 13 (Final Polish). An empty array simply renders an empty grid.
- Nothing from `/docs/11-out-of-scope.md`.
