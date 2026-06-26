## Context

After Phase 2 the app has the `GridItem`/`GridType`/`GridItemSource` models and DEBUG `SampleData`, but `PostsGridView`/`ReelsGridView` still render "Coming soon" inside a `NavigationStack`. Phase 3 of `/docs/08-task-breakdown.md` adds the reusable grid that `/docs/04-architecture.md` calls `GridPlannerView`, satisfying the grid rules (3 columns, Instagram-like portrait tiles, locked items marked).

Constraints carried in from `/docs`:
- 3-column, Instagram-like grid of portrait tiles; posted vs planned must look different; posted items show a lock indicator (`/docs/06-ui-ux-rules.md`). Posts use a **3:4** tile aspect ratio (`/docs/03-requirements.md`); reels use **9:16** (reel cover).
- Keep SwiftUI views small; keep business logic in models/view models, not views (`/docs/07-agent-workflow.md`). The lock rule already lives in `GridItem.isLocked`.
- Avoid premature abstraction (`/AGENTS.md`).

## Goals / Non-Goals

**Goals:**
- One reusable presentation view (`GridPlannerView`) used by both tabs, rendering a 3-column grid of portrait tiles (aspect ratio per tab: Posts 3:4, Reels 9:16) sorted by `orderIndex`.
- A `GridCellView` that makes Instagram (locked) and local (planned) items visually distinct and shows a lock indicator on Instagram items, reading `isLocked` from the model.
- Wire both tabs to the grid with minimal change, preserving their `NavigationStack` and titles.

**Non-Goals:**
- No `GridPlannerViewModel`, no add/remove/reorder, no storage, no sync, no real image loading, no polished empty state (see proposal Non-goals for the phase mapping).

## Decisions

### Decision 1: `GridPlannerView` is a pure presentation view; defer `GridPlannerViewModel` to Phase 4
- **Choice**: `GridPlannerView(gridType: GridType, items: [GridItem])` takes its items as input and only renders. No view model is introduced this phase.
- **Rationale**: Phase 3 is display-only — there is no mutable state to own yet. `/docs/04-architecture.md` defines `GridPlannerViewModel` for owning state and add/remove/reorder/refresh; all of that arrives in Phases 4/6/7/10. Introducing it now with nothing to manage is the premature abstraction `/AGENTS.md` warns against. The view stays small and the model already holds the only business rule (`isLocked`).
- **Alternatives**: Add `GridPlannerViewModel` now seeded from `SampleData` — rejected; it would be an empty shell this phase and is a clean, expected addition in Phase 4 when "add local media" needs owned state.

### Decision 2: Resolve the `GridItem` name collision with `SwiftUI.GridItem`
- **Choice**: Where `LazyVGrid` columns are declared, fully qualify SwiftUI's type — `Array(repeating: SwiftUI.GridItem(.flexible(), spacing: 1), count: 3)`. Unqualified `GridItem` everywhere else continues to mean our model.
- **Rationale**: Our module declares a `GridItem` model, which shadows `SwiftUI.GridItem` inside our module; an unqualified `GridItem(.flexible())` would fail to compile. Qualifying only the column declaration is the smallest, clearest fix and keeps the model name (mandated by `/docs/05-data-model.md`) intact.
- **Alternatives**: Rename the model to `GridMediaItem` — rejected; it diverges from the data-model doc and Phase 2 code. Type-alias gymnastics — rejected as needless indirection.

### Decision 3: Layout — `ScrollView` + `LazyVGrid`, portrait tiles, tight spacing
- **Choice**: A `ScrollView` containing a `LazyVGrid` with three flexible columns and ~1pt spacing; each cell is forced to the tab's portrait aspect ratio via `.aspectRatio(tileAspectRatio, contentMode: .fill)` with `.clipped()`.
- **Rationale**: Mirrors Instagram's current profile grid (`/docs/03-requirements.md`, `/docs/06-ui-ux-rules.md`): three tight, portrait columns that scroll. Instagram replaced 1:1 squares with 3:4 portrait thumbnails for posts; reels show as 9:16 covers. `LazyVGrid` is the idiomatic, performant SwiftUI choice and lazily renders cells.
- **Alternatives**: 1:1 square cells — rejected; no longer matches Instagram and the docs now specify 3:4 for posts. Fixed-size `GridItem(.fixed:)` columns — rejected; flexible columns adapt across iPhone widths without hard-coding sizes.

### Decision 3a: Tile aspect ratio is derived from `GridType` in the view layer
- **Choice**: `GridPlannerView` computes `tileAspectRatio` (a `CGFloat` width/height) from its `gridType` — `.posts → 3.0/4.0`, `.reels → 9.0/16.0` — and applies it to every cell. The mapping lives in the view layer (presentation), not on the `GridType` model.
- **Rationale**: Aspect ratio is how Instagram *displays* a grid, a presentation concern; keeping it out of the `Models/` enum preserves the layering in `/docs/04-architecture.md`. Deriving from `gridType` keeps `GridPlannerView` reusable while still giving each tab its correct shape — no extra parameter needed at the call site.
- **Alternatives**: Pass `tileAspectRatio` in from `PostsGridView`/`ReelsGridView` — acceptable but pushes a presentation constant into each caller; deriving from `gridType` centralizes it. Put the ratio on `GridType` — rejected; it would leak a UI detail into the model layer.

### Decision 4: `GridPlannerView` filters to its `gridType`, then sorts by `orderIndex` (non-mutating)
- **Choice**: Internally compute `items.filter { $0.gridType == gridType }.sorted { $0.orderIndex < $1.orderIndex }` for display; never mutate the input.
- **Rationale**: Guarantees the spec ("show only items whose `gridType` matches", "ascending `orderIndex`") even if a caller passes a mixed array, and keeps presentation logic (ordering) out of the model without inventing business rules.

### Decision 5: Cell rendering without real media — placeholder + source treatment + lock overlay
- **Choice**: `GridCellView(item: GridItem)` fills the tile with a neutral placeholder (e.g. a tinted background with a source-appropriate SF Symbol); the parent grid clips it to the tab's portrait aspect ratio. Local (planned) and Instagram (locked) items use distinct tints; Instagram items add a lock indicator (`lock.fill`) in a corner overlay. The lock decision reads `item.isLocked`.
- **Rationale**: Sample items carry `nil` `localImagePath`/`thumbnailURL`, so there is no image to load this phase. The placeholder still satisfies "posted and planned look different" and "posted items show a lock indicator". Real images replace the placeholder in Phase 4 (local files) and Phase 9/12 (Instagram thumbnails) without changing the cell's shape.
- **Alternatives**: Block Phase 3 until images exist — rejected; the grid layout and locked/unlocked treatment are independently valuable and unblock Phases 4–7.

### Decision 6: Tabs seed from `SampleData` under DEBUG only
- **Choice**: `PostsGridView`/`ReelsGridView` pass `SampleData.posts`/`.reels` to `GridPlannerView` inside `#if DEBUG`, and an empty array otherwise.
- **Rationale**: `SampleData` is `#if DEBUG` (Phase 2 decision); referencing it from non-DEBUG code would break a Release build. The app is run from Xcode in Debug, so previews and on-device Debug runs show the sample grid; Release simply shows an empty grid until Phase 4/9 supply real items.

## Risks / Trade-offs

- **[Risk] Unqualified `GridItem` in column code fails to compile due to the SwiftUI shadow.** → Mitigation: Decision 2 qualifies `SwiftUI.GridItem` at the one place it is needed; covered by a build in the tasks.
- **[Risk] Release builds show an empty grid (no `SampleData`).** → Mitigation: Intended and documented; real data lands in Phase 4/9. The personal install runs Debug from Xcode.
- **[Trade-off] Placeholder cells instead of real images.** → Acceptable: the layout and locked/unlocked treatment are the Phase 3 deliverable; image loading is explicitly later. Cell shape stays stable so swapping in images later is localized to `GridCellView`.
- **[Trade-off] No view model yet.** → Acceptable and intentional; Phase 4 introduces `GridPlannerViewModel` when mutation begins, a small additive step.

## Migration Plan

Additive UI change. Rollback = restore the two placeholder view bodies and delete `GridPlannerView.swift`/`GridCellView.swift`. No data, storage, or model changes; the app entry point and tab structure are untouched.

## Open Questions

- None blocking. Exact cell colors/symbols are cosmetic and may be refined in Phase 13 (Final Polish) without changing structure.
