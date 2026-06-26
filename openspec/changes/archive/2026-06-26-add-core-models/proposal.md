## Why

Phase 1 landed a runnable app shell with empty `Posts`/`Reels` placeholders but no data layer. Every later phase — grid display (Phase 3), gallery import (Phase 4), persistence (Phase 5), remove/reorder (Phases 6–7), and Instagram refresh merge (Phase 10) — operates on a shared set of core domain types. Phase 2 of `/docs/08-task-breakdown.md` defines exactly these types so subsequent phases build on one agreed, `Codable`, business-rule-correct model instead of re-deriving it ad hoc.

## What Changes

- Add a `GridType` enum (`posts`, `reels`) — identifies which of the two grids an item belongs to.
- Add a `GridItemSource` enum (`instagram`, `local`) — distinguishes already-posted Instagram media from manually planned local media.
- Add a `GridItem` model with the fields from `/docs/05-data-model.md`: `id`, `source`, `gridType`, `localImagePath`, `instagramMediaId`, `thumbnailURL`, `createdAt`, `orderIndex`, and a **derived** `isLocked`.
- Encode the locked/unlocked business rule in the model: `isLocked` is a computed property (`source == .instagram`), never a stored field and never decided in UI — per `/docs/05-data-model.md` ("Do not store business rules in UI components").
- Make all three types `Codable` (raw-value-backed enums) so Phase 5 persistence can serialize them without rework, plus `Identifiable`/`Equatable`/`Hashable` on `GridItem` for SwiftUI lists and later merge/diff logic.
- Add **development-only sample data** (`SampleData`) — static `posts`/`reels` arrays mixing locked Instagram items and unlocked local items, ordered by `orderIndex` — to feed Phase 3 previews. This is plain in-memory fixture data, explicitly **not** the Instagram mock service (Phase 9).

## Capabilities

### New Capabilities
- `grid-models`: The core domain types for the grid planner — `GridType`, `GridItemSource`, and `GridItem` (with the derived locked/unlocked rule) — plus development sample data. The shared vocabulary that all feature phases consume.

### Modified Capabilities
<!-- None — this introduces a new capability and does not change app-shell requirements. -->

## Impact

- **New code**: `InstagramGridPlanner/Models/GridType.swift`, `Models/GridItemSource.swift`, `Models/GridItem.swift`, `Models/SampleData.swift`. The `Models/.gitkeep` placeholder is removed once real files land.
- **Dependencies**: None added. Foundation only (`Date`, `URL`, `Codable`). No SwiftUI required in the model layer.
- **Affected systems**: None at runtime — no view, service, or storage wiring changes in this phase. The app still launches to the same two placeholder tabs.
- **Tech stack**: No deviation from `/docs/02-tech-stack.md` (Swift, local-first, `Codable` models).

## Non-goals

- No `AppSettings` model (`selectedInstagramUsername`, `lastSuccessfulRefreshAt`, `activeGridType`) — that is Phase 8 (Account Selection).
- No persistence / `LocalStorageService`, no reading or writing JSON to disk — Phase 5. (Types are made `Codable` now, but nothing serializes them yet.)
- No `InstagramSyncService` or its mock, and no network/API types — Phase 9. The Phase 2 sample data is dev fixtures, not a sync stub.
- No grid rendering, cells, 3-column layout, lock indicators, or any view code — Phase 3.
- No `PhotosPicker` / gallery import, no real image files or `localImagePath` contents — Phase 4.
- No drag/reorder or remove behavior — Phases 6–7.
- Nothing from `/docs/11-out-of-scope.md` (auto-posting, scheduling, analytics, multi-account, backend, login, AI features).
