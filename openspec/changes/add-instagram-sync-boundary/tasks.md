## 1. Confirm scope before adding files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm there is no sync code yet (`grep -RIn "InstagramSyncService\|InstagramMedia\|fetchPostedMedia" InstagramGridPlanner/` returns nothing). Record in apply notes.
  - **Acceptance**: One-line note "No Instagram sync boundary yet."
- [x] 1.2 Confirm scope: define the `InstagramSyncService` interface + `InstagramMedia` + mock only, kept out of the UI — explicitly NOT refresh/merge (Phase 10), real API/networking/auth (Phases 11–12), or replacing the sample placeholders.
  - **Acceptance**: Scope restated in apply notes.

## 2. Add the `InstagramMedia` model and conversion

- [x] 2.1 Create `Models/InstagramMedia.swift`: `struct InstagramMedia: Equatable { let id: String; let thumbnailURL: URL?; let takenAt: Date }`.
  - **Acceptance**: Compiles.
- [x] 2.2 Add a conversion to a locked grid item — `func gridItem(gridType: GridType, orderIndex: Int) -> GridItem` — producing `GridItem(source: .instagram, gridType:, instagramMediaId: id, thumbnailURL:, createdAt: takenAt, orderIndex:)`.
  - **Acceptance**: The produced item has `source == .instagram`, `isLocked == true`, `instagramMediaId == id`, `localImagePath == nil`, and the given `gridType`/`orderIndex`.

## 3. Add the `InstagramSyncService` protocol

- [x] 3.1 Create `Services/InstagramSyncService.swift`: `protocol InstagramSyncService { func fetchPostedMedia(forUsername username: String, gridType: GridType) async throws -> [GridItem] }`. Import only `Foundation`.
  - **Acceptance**: Compiles; no SwiftUI/UIKit import.

## 4. Add the mock implementation

- [x] 4.1 Create `Services/MockInstagramSyncService.swift`: `struct MockInstagramSyncService: InstagramSyncService` holding a few canned `InstagramMedia` per grid (distinct ids, `thumbnailURL == nil`, descending `takenAt`). `fetchPostedMedia` returns the requested grid's media converted to locked items, with `orderIndex` reflecting Instagram order (newest first). The username is accepted but ignored; the call always succeeds. Import only `Foundation`.
  - **Acceptance**: `fetchPostedMedia(forUsername:gridType: .posts)` returns a non-empty `[GridItem]` of locked Posts items; `.reels` returns a non-empty set of locked Reels items; no SwiftUI/UIKit import.

## 5. Build and verify

- [x] 5.1 Add a temporary `#if DEBUG` sanity check (in a `Task` since the call is `async`): `await MockInstagramSyncService().fetchPostedMedia(forUsername: "olgo.js", gridType: .posts)` and assert it is non-empty and every item has `source == .instagram`, `isLocked`, a non-empty `instagramMediaId`, `localImagePath == nil`, and `gridType == .posts`; repeat for `.reels`; assert orderIndex is ascending while `takenAt` is descending (newest first).
  - **Acceptance**: Runs without assertion failure in the simulator.
- [x] 5.2 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 5.3 Remove the temporary sanity check from 5.1 and rebuild.
  - **Acceptance**: Production code contains only the three new files; build still succeeds.

## 6. Negative checks

- [x] 6.1 Confirm no networking/auth/scraping leaked in: `grep -RIn "URLSession\|http\|OAuth\|password\|WKWebView\|scrap" InstagramGridPlanner/Services/InstagramSyncService.swift InstagramGridPlanner/Services/MockInstagramSyncService.swift` returns no matches.
  - **Acceptance**: The boundary is mock-only; no real network or login.
- [x] 6.2 Confirm UI isolation: `grep -RIn "SwiftUI\|import UIKit\|GridPlannerView\|ViewModel" InstagramGridPlanner/Services/InstagramSyncService.swift InstagramGridPlanner/Services/MockInstagramSyncService.swift InstagramGridPlanner/Models/InstagramMedia.swift` returns no matches.
  - **Acceptance**: The service/model reference no UI or view-model types.

## 7. Source control & reporting

- [x] 7.1 Stage the three new files.
  - **Acceptance**: `git status` shows `InstagramMedia.swift`, `InstagramSyncService.swift`, `MockInstagramSyncService.swift` added.
- [x] 7.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, how it was verified (DEBUG sanity check; not wired to UI), known limitations (mock only; nil thumbnails; not wired into refresh), and which requirements remain (Phases 10–13).
  - **Acceptance**: Summary lists the new files and confirms the `instagram-sync` scenarios pass.
- [x] 7.3 Include a **"How to test this change"** note in the apply summary: this phase has no visible UI change; it is verified by building plus the DEBUG sanity check, and will become visible when Phase 10 wires refresh/merge.
  - **Acceptance**: The reader understands there is no on-screen change yet and how the boundary was verified.
