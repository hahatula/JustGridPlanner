## Context

The app has local planning (add/reorder/remove, persisted) and account selection. It has no way to bring in posted Instagram media. Phase 9 of `/docs/08-task-breakdown.md` builds the `InstagramSyncService` boundary that `/docs/04-architecture.md` describes ("Fetch posted media… Convert API response into locked grid items… Not responsible for UI ordering"), with a mock so Phase 10 can build refresh/merge without real API access (`/docs/10-decisions.md` Decision 004). `/docs/07-agent-workflow.md` permits official API or a mock only — no scraping, login, or unofficial APIs.

## Goals / Non-Goals

**Goals:**
- A protocol for fetching a username's posted media per grid, returning locked Instagram `GridItem`s, asynchronously and fallibly.
- A media value type and a conversion to a locked `GridItem`, reusable by the future real service.
- A deterministic mock returning posted posts and reels.
- Strict isolation from the UI.

**Non-Goals:**
- Refresh/merge wiring, real networking/auth, persistence of synced items, replacing the DEBUG sample placeholders. See proposal Non-goals.

## Decisions

### Decision 1: Protocol returns locked `GridItem`s per grid
- **Choice**: `protocol InstagramSyncService { func fetchPostedMedia(forUsername username: String, gridType: GridType) async throws -> [GridItem] }`. It returns the requested grid's posted media as locked items, in Instagram order.
- **Rationale**: Per-grid fetch maps cleanly onto the per-grid `GridPlannerViewModel` that Phase 10 will call (`viewModel.refresh()` fetches for its own `gridType`). `async throws` lets a real implementation surface network/API errors; the mock simply succeeds. Returning `GridItem`s (not raw DTOs) matches `/docs/04-architecture.md` ("convert API response into locked grid items").
- **Alternatives**: One call returning both grids (`{posts, reels}`) — more API-shaped but awkward for a per-grid view model; rejected. Returning raw DTOs and converting in the caller — rejected; `/docs/04` puts conversion in the service.

### Decision 2: `InstagramMedia` value type + conversion to a locked `GridItem`
- **Choice**: `struct InstagramMedia { let id: String; let thumbnailURL: URL?; let takenAt: Date }` models one posted item (the shape a real API response maps to). A conversion — `func gridItem(gridType: GridType, orderIndex: Int) -> GridItem` (or an equivalent `GridItem` factory) — produces `GridItem(source: .instagram, gridType:, instagramMediaId: id, thumbnailURL:, createdAt: takenAt, orderIndex:)`, which is locked by the model's derived rule.
- **Rationale**: Separating "what Instagram returns" from the app's `GridItem` makes the boundary explicit and gives Phase 12 (real API) a clear mapping target, while the mock and the real service share one conversion. Keeps it minimal (three fields) to avoid premature abstraction.
- **Alternatives**: Build `GridItem`s directly in the mock with no DTO — rejected; the DTO is the boundary's whole point and is tiny.

### Decision 3: `MockInstagramSyncService` returns canned, Instagram-ordered media
- **Choice**: A `MockInstagramSyncService: InstagramSyncService` holding a few canned `InstagramMedia` per grid (distinct ids, `thumbnailURL == nil` for now, descending `takenAt`), converting them to locked items with `orderIndex` reflecting Instagram order (newest first). It ignores the username (returns the same canned set) and always succeeds.
- **Rationale**: Deterministic data lets Phase 10 test the merge (locked Instagram items below local planned items) predictably. `nil` thumbnails are fine — cells already show a placeholder for Instagram items until real thumbnails arrive (Phase 12). Ignoring the username keeps the mock simple; empty-username refusal is a refresh-caller concern (Phase 10).
- **Alternatives**: Simulated delay/failure modes — useful for Phase 10/13 testing but not required now; can be added when refresh error handling is built.

### Decision 4: UI isolation and ordering responsibility
- **Choice**: The service and mock live in `Services/`, import only `Foundation`, and never reference views/view models. They return items in Instagram order; arranging them with local items (planned-on-top per Decision 007) is the caller's job in Phase 10.
- **Rationale**: Directly implements `/docs/04-architecture.md` ("not responsible for UI ordering") and Decision 004's isolation, so the real API can replace the mock with zero UI churn.

## Risks / Trade-offs

- **[Trade-off] Defining the boundary before it is used** could look speculative. → Acceptable and intended: Decision 004 mandates building the merge against a mock first; the interface is small and immediately exercised by a DEBUG sanity check.
- **[Risk] The mock shape may not match the eventual real API.** → Mitigation: the conversion is the single point to adjust when Phase 11 confirms the real fields; the protocol stays stable.
- **[Note] No thumbnails in the mock.** → Cells render the existing Instagram placeholder; real thumbnails are Phase 12.

## Migration Plan

Additive and standalone. Rollback = delete the three new files; nothing else references them. No storage, network, or UI change.

## Open Questions

- None blocking. Per-grid vs. combined fetch is settled (per-grid); failure/delay simulation is deferred to when Phase 10/13 needs it.
