## Context

Phase 1 produced the app shell (`InstagramGridPlannerApp`, `MainTabView`, two placeholder views) and the canonical folder layout; `Models/` currently holds only a `.gitkeep`. There is no data layer yet. Phase 2 of `/docs/08-task-breakdown.md` adds the core domain types defined in `/docs/05-data-model.md`. These types are pure value types with no UI, storage, or network behavior — they are the shared vocabulary the rest of the app is built on.

Constraints carried in from `/docs`:
- Local-first, `Codable` models; storage is a later, separate concern (`/docs/02-tech-stack.md`, `/docs/04-architecture.md`).
- The locked/unlocked rule is derived from `source` and must not live in UI (`/docs/05-data-model.md`).
- Instagram integration stays behind a future `InstagramSyncService`; nothing in this phase touches it (`/docs/10-decisions.md` Decision 004).
- No features from `/docs/11-out-of-scope.md`.

## Goals / Non-Goals

**Goals:**
- Land `GridType`, `GridItemSource`, and `GridItem` as small, `Codable` value types that match `/docs/05-data-model.md` field-for-field.
- Encode the locked/unlocked business rule once, in the model, as a derived value that cannot drift from `source`.
- Provide development sample data so Phase 3 can render real-looking grids before any picker or sync exists.
- Keep the types serialization-ready (so Phase 5 persistence is a drop-in) without adding any storage now.

**Non-Goals:**
- No `AppSettings` (Phase 8), no persistence/`LocalStorageService` (Phase 5), no `InstagramSyncService`/mock (Phase 9), no views (Phase 3), no `PhotosPicker` (Phase 4), no reorder/remove (Phases 6–7).
- No automated test target — there is none yet and `/docs/09-testing-strategy.md` defers it. Verification is build + a DEBUG sanity check.

## Decisions

### Decision 1: `id` is a `String`
- **Choice**: `GridItem.id: String`.
- **Rationale**: `/docs/05-data-model.md` examples use string ids (`"local-001"`), and Instagram media ids are opaque strings. A single `String` id represents both local and Instagram items without a union type. Local ids can be generated as `UUID().uuidString` when items are created (Phase 4).
- **Alternatives**: `UUID` — rejected; doesn't fit Instagram media ids and diverges from the documented examples.

### Decision 2: `isLocked` is a computed property, never stored
- **Choice**: `var isLocked: Bool { source == .instagram }`. It is not in `CodingKeys` (Swift excludes computed properties from synthesized `Codable`), so it never appears in encoded JSON.
- **Rationale**: Directly implements `/docs/05-data-model.md` ("isLocked is derived from source", "Do not store business rules in UI components"). Because it is computed, it cannot drift from `source` and there is no setter for UI to misuse.
- **Alternatives**: Stored `isLocked` with a custom encoder excluding it — rejected as redundant and drift-prone. Deciding lock state in the view — rejected; violates the documented rule.

### Decision 3: Field types
- **Choice**: `source: GridItemSource`, `gridType: GridType`, `localImagePath: String?`, `instagramMediaId: String?`, `thumbnailURL: URL?`, `createdAt: Date`, `orderIndex: Int`.
- **Rationale**: `localImagePath` is a relative path within app storage (`"images/local-001.jpg"`), so a `String` is appropriate; `thumbnailURL` is a real remote URL, so `URL?` gives type safety and free `Codable`. Optionality mirrors the data model: local items have no `instagramMediaId`, Instagram items have no `localImagePath`. `Date`/`Int` are `Codable` out of the box.
- **Alternatives**: Make every field non-optional with sentinel values — rejected; optionals model "not applicable for this source" honestly.

### Decision 4: Enums are `String`-raw-valued and `Codable`
- **Choice**: `enum GridType: String, Codable, CaseIterable` with `posts`/`reels`; `enum GridItemSource: String, Codable` with `instagram`/`local`. `GridType` also gets `Identifiable` (`id == self`) for use in SwiftUI iteration later.
- **Rationale**: Explicit string raw values give stable, human-readable JSON (`"posts"`, `"instagram"`) that survives case reordering — important once Phase 5 writes these to disk. `CaseIterable` on `GridType` supports driving the two tabs/grids from data later.
- **Alternatives**: Int-backed enums — rejected; fragile in JSON and unreadable.

### Decision 5: `GridItem` conformances and ergonomic init
- **Choice**: `GridItem: Identifiable, Codable, Equatable, Hashable`. Provide a memberwise-style init with defaults for the optionals (`localImagePath: nil`, `instagramMediaId: nil`, `thumbnailURL: nil`, `createdAt: Date = Date()`) so call sites (and sample data) stay terse.
- **Rationale**: `Identifiable` for `ForEach`; `Equatable`/`Hashable` for the Phase 10 refresh merge/diff and SwiftUI diffing. Defaulted optionals avoid noisy `nil` arguments everywhere.

### Decision 6: Sample data lives in `Models/SampleData.swift`, gated behind `#if DEBUG`
- **Choice**: A `SampleData` namespace exposing `SampleData.posts` and `SampleData.reels` (`[GridItem]`), each mixing locked Instagram and unlocked local items ordered by `orderIndex`, with `thumbnailURL` / `localImagePath` left `nil` (no assets or network yet). Wrapped in `#if DEBUG`.
- **Rationale**: Satisfies "development-only" literally — fixtures compile for previews/Debug runs but never ship in a Release build, keeping production free of fake data. Phase 3 SwiftUI previews (which run in DEBUG) consume it; Phase 9's real mock `InstagramSyncService` later supersedes it. `nil` media references keep the "no side effects / no network" scenario true; Phase 3 chooses placeholder visuals.
- **Alternatives**: Ship sample data unconditionally — rejected; risks fixtures leaking into a real run. Put fixtures in a test target — rejected; no test target exists and previews need them in the app module.

## Risks / Trade-offs

- **[Risk] `#if DEBUG` sample data is unavailable in a Release build, which could surprise a later phase that references it from non-DEBUG code.** → Mitigation: It is intentionally development-only per the proposal; Phase 3 uses it only in previews/Debug, and Phase 9 replaces it with the mock sync service. Documented here and in the spec.
- **[Risk] `String` id has no uniqueness guarantee.** → Mitigation: Local items generate ids via `UUID().uuidString` at creation (Phase 4); Instagram ids come from the API and are unique by definition.
- **[Trade-off] Types are `Codable` but nothing serializes them yet.** → Acceptable and intentional: it makes Phase 5 a drop-in and adds no storage surface now.
- **[Trade-off] No automated tests this phase.** → Acceptable per `/docs/09-testing-strategy.md`; the model is verified by a compile plus a temporary `#if DEBUG` sanity check (derived `isLocked` and a `Codable` round-trip) that is removed before completion.

## Migration Plan

Additive and greenfield for the data layer — no existing models, storage, or users. Rollback = delete the four new files under `Models/` and restore `Models/.gitkeep`. No runtime behavior changes; the app still launches to the same two placeholder tabs.

## Open Questions

- None blocking. `localImagePath` directory convention (`images/…`) and local id generation are settled when Phase 4 actually writes files; this phase only defines the field.
