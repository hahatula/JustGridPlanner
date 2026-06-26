## 1. Confirm scope before adding files

- [x] 1.1 Re-inspect the codebase per `/AGENTS.md` "Existing Code Awareness": confirm `InstagramGridPlanner/Models/` contains only `.gitkeep` and no model types exist yet (`grep -RIn "struct GridItem\|enum GridType\|enum GridItemSource" InstagramGridPlanner/` returns nothing). Record the result in the apply notes.
  - **Acceptance**: One-line note "No prior model types found; Models/ holds only .gitkeep."
- [x] 1.2 Confirm this change adds **only** `GridType`, `GridItemSource`, `GridItem`, and dev sample data — explicitly NOT `AppSettings` (Phase 8), persistence (Phase 5), or any sync (Phase 9).
  - **Acceptance**: Scope restated in apply notes; no later-phase types planned.

## 2. Add `GridType`

- [x] 2.1 Create `InstagramGridPlanner/Models/GridType.swift`: `enum GridType: String, Codable, CaseIterable, Identifiable` with cases `posts` and `reels`, raw values `"posts"`/`"reels"`, and `var id: String { rawValue }`.
  - **Acceptance**: Compiles. `GridType.allCases` has exactly `[.posts, .reels]`.
  - **Manual test**: In a temporary `#if DEBUG` check, encode `.posts` with `JSONEncoder` → bytes contain `"posts"`; decode `"reels"` → `.reels`.

## 3. Add `GridItemSource`

- [x] 3.1 Create `InstagramGridPlanner/Models/GridItemSource.swift`: `enum GridItemSource: String, Codable` with cases `instagram` and `local`, raw values `"instagram"`/`"local"`.
  - **Acceptance**: Compiles. Exactly two cases; no others.
  - **Manual test**: Encode `.instagram` → `"instagram"`; decode `"local"` → `.local`.

## 4. Add `GridItem` with derived lock rule

- [x] 4.1 Create `InstagramGridPlanner/Models/GridItem.swift`: `struct GridItem: Identifiable, Codable, Equatable, Hashable` with stored fields `id: String`, `source: GridItemSource`, `gridType: GridType`, `localImagePath: String?`, `instagramMediaId: String?`, `thumbnailURL: URL?`, `createdAt: Date`, `orderIndex: Int`.
  - **Acceptance**: Compiles. Field names/types match `/docs/05-data-model.md`.
- [x] 4.2 Add a memberwise init with defaults for the optionals (`localImagePath: nil`, `instagramMediaId: nil`, `thumbnailURL: nil`, `createdAt: Date = Date()`) so call sites can omit them.
  - **Acceptance**: `GridItem(id:source:gridType:orderIndex:)` compiles using all defaults.
- [x] 4.3 Add `var isLocked: Bool { source == .instagram }` as a computed property (no stored backing, no setter, not in `CodingKeys`).
  - **Acceptance**: An `.instagram` item reports `isLocked == true`; a `.local` item reports `isLocked == false`.
  - **Manual test**: Encode a `.local` `GridItem` to JSON and confirm the output contains no `isLocked` key (derived, not persisted).

## 5. Add development sample data

- [x] 5.1 Create `InstagramGridPlanner/Models/SampleData.swift` wrapped in `#if DEBUG ... #endif`: a `SampleData` enum (namespace) exposing `static let posts: [GridItem]` and `static let reels: [GridItem]`. Each array mixes at least one `.instagram` (locked) item and at least one `.local` (unlocked) item, ordered by ascending `orderIndex`, with `thumbnailURL`/`localImagePath` left `nil`.
  - **Acceptance**: Compiles in a Debug build. Each array is non-empty and contains both sources. No network/file/sync calls anywhere in the file.
  - **Manual test**: In a temporary `#if DEBUG` check, print `SampleData.posts.count` and `SampleData.posts.filter(\.isLocked).count` → both > 0; same for `reels`.

## 6. Build and verify

- [x] 6.1 Add a temporary `#if DEBUG` sanity check (e.g., in `InstagramGridPlannerApp.init` or a throwaway `#Preview`) asserting: derived `isLocked` for both sources, a `GridItem` `Codable` round-trip equals the original, and `SampleData` arrays are non-empty with mixed sources.
  - **Acceptance**: Runs without assertion failure when launched in the simulator.
- [x] 6.2 Clean build the `InstagramGridPlanner` scheme for an iPhone simulator (iOS 17+) and confirm no errors and no new warnings.
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED.
- [x] 6.3 Remove the temporary sanity check from 6.1 and the temporary encode/decode checks from tasks 2–5, then rebuild.
  - **Acceptance**: Production code contains only the four model files; build still succeeds. No leftover debug scaffolding.
- [x] 6.4 Negative check: `grep -RIn "AppSettings\|PhotosPicker\|InstagramSyncService\|LocalStorageService\|URLSession\|FileManager" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: Confirms no later-phase concerns (settings, picker, sync, storage, network) leaked into Phase 2.

## 7. Source control & reporting

- [x] 7.1 Delete `InstagramGridPlanner/Models/.gitkeep` (the folder now holds real files) and stage the four new model files.
  - **Acceptance**: `git status` shows `GridType.swift`, `GridItemSource.swift`, `GridItem.swift`, `SampleData.swift` added and `.gitkeep` removed.
- [x] 7.2 Write the apply-phase summary per `/docs/07-agent-workflow.md` "Implementation Rules": what changed, files changed, manual test steps, known limitations, and which requirements remain (Phases 3–13).
  - **Acceptance**: Summary lists every new file, confirms the `grid-models` scenarios pass, and notes that views/persistence/sync remain (expected).
