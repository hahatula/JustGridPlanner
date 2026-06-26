## Context

The repository currently contains only `/docs` and the OpenSpec workspace — no Xcode project, no Swift source files. Phase 1 of `/docs/08-task-breakdown.md` calls for a minimal runnable SwiftUI app skeleton with the agreed two-tab navigation and the folder layout defined in `/docs/04-architecture.md` ("Suggested Folder Structure"). All later phases (models, grid display, gallery import, persistence, Instagram sync) depend on this skeleton existing first.

Constraints carried in from `/docs`:
- Native iPhone-only app, Swift + SwiftUI (`/docs/02-tech-stack.md`).
- Two tabs only: Posts and Reels (`/docs/06-ui-ux-rules.md`).
- Layered architecture: SwiftUI Views → ViewModels → Local storage services → Optional Instagram sync service (`/docs/04-architecture.md`).
- No third-party dependencies for MVP (`/docs/02-tech-stack.md`).
- Not for App Store distribution (`/docs/00-project-brief.md`).

## Goals / Non-Goals

**Goals:**
- Produce a buildable, launchable iOS app that opens to a `TabView` with **Posts** and **Reels** tabs.
- Establish the canonical folder layout (`App/`, `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/`) so later phases drop files into the right place without re-debating structure.
- Land the app entry point (`@main App`) and `MainTabView` as the single root composition point. Each tab hosts a placeholder view that later phases will replace.

**Non-Goals:**
- No models, no grid layout, no cells, no images, no PhotosPicker, no persistence, no `LocalStorageService`, no `InstagramSyncService`, no account/username UI, no refresh logic. All deferred to Phases 2–10.
- No automated tests in this phase. The skeleton is verified by manual launch only; per `/docs/09-testing-strategy.md` automated testing strategy is deferred.
- No design polish, icons, color palette, or app icon — placeholder is acceptable.
- No CI, no signing/provisioning automation beyond what Xcode does by default for a local-only personal-team build.

## Decisions

### Decision 1: Use Xcode-generated SwiftUI App template (not Swift Package)
- **Choice**: Create a standard Xcode iOS App project (`InstagramGridPlanner.xcodeproj`) using the SwiftUI Life Cycle template.
- **Rationale**: The app needs Info.plist, asset catalog, photo-library entitlements (later), and PhotosPicker support — all of which work most smoothly inside an Xcode app target rather than a SwiftPM executable. Direct Xcode install to the user's iPhone is part of the chosen distribution model (`/docs/00-project-brief.md`, `/docs/02-tech-stack.md`).
- **Alternatives considered**: Swift Package with executable target — rejected because app targets, asset catalogs, and on-device installs are clunkier through SwiftPM-only setups.

### Decision 2: Project name and bundle id
- **Choice**: Product name `InstagramGridPlanner`; bundle identifier `com.olgagolubev.InstagramGridPlanner` (personal team, single device). Deployment target: iOS 17.0 (SwiftUI `TabView` + `NavigationStack` are stable; this also leaves room for `PhotosPicker` in Phase 4).
- **Rationale**: Matches the folder name suggested in `/docs/04-architecture.md`. iOS 17 is a reasonable floor for a personal iPhone in 2026 and covers all SwiftUI APIs needed by later phases.
- **Alternatives considered**: iOS 16 — fine, but iOS 17 simplifies `PhotosPicker` and Observation later; user runs a current iPhone so no need to support older.

### Decision 3: Folder structure as Xcode groups that mirror filesystem
- **Choice**: Create the folders `App/`, `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/` as both filesystem directories and Xcode groups. Place `InstagramGridPlannerApp.swift` in `App/`. Place `MainTabView.swift`, `PostsGridView.swift`, `ReelsGridView.swift` in `Views/`. Add a `.gitkeep` to each currently-empty folder (`Models/`, `ViewModels/`, `Services/`, `Utilities/`) so they survive in git.
- **Rationale**: Matches `/docs/04-architecture.md` exactly. Filesystem-backed groups (Xcode 15+ default) keep on-disk and in-project trees aligned, which prevents drift when later phases add files via the Edit/Write tools rather than Xcode UI.
- **Alternatives considered**: Lazy creation (only create folders when files are added) — rejected; we want the layout visible up front so contributors and agents always know where new code belongs.

### Decision 4: Placeholder content for Posts / Reels tabs
- **Choice**: Each placeholder view is a `NavigationStack` containing a centered `Text("Posts")` / `Text("Reels")` plus a smaller subtitle `Text("Coming soon")`. Each tab uses an SF Symbol (`square.grid.3x3` for Posts, `play.rectangle` for Reels) and a label.
- **Rationale**: Smallest viable placeholder that demonstrates tab navigation works. `NavigationStack` is added now so Phase 3 can drop the grid in without re-wrapping. SF Symbols avoid any image-asset work.
- **Alternatives considered**: Empty `VStack`s with no nav stack — rejected, would force a refactor in Phase 3.

### Decision 5: `MainTabView` as the single composition root
- **Choice**: `InstagramGridPlannerApp.body` returns a `WindowGroup` containing `MainTabView()`. `MainTabView` owns the `TabView` and the two placeholder views directly. No `@StateObject` view models in this phase — none exist yet.
- **Rationale**: Keeps the App entry point thin and gives later phases a single, obvious place to inject view models (Phase 2+) or environment values.

## Risks / Trade-offs

- **[Risk] The `.xcodeproj` is generated/edited by Xcode — text-only agent tooling can desync it.** → Mitigation: Create the project once via Xcode (or `xcodegen`/template) and commit it; document in tasks that any new Swift file must be added to the target. For Phase 1 the file count is small (4 Swift files), so manual add is trivial.
- **[Risk] Choosing iOS 17 might be higher than needed.** → Mitigation: Low risk — the user's device is current; can be lowered later by a single project setting without code changes.
- **[Risk] Empty folders disappear in git.** → Mitigation: Add `.gitkeep` to `Models/`, `ViewModels/`, `Services/`, `Utilities/`. Remove each `.gitkeep` when the first real file lands.
- **[Trade-off] No tests in this phase.** → Acceptable: there is no behavior yet beyond "the app launches and shows two tabs," which is a manual smoke test (`/docs/09-testing-strategy.md` defers automated testing).

## Migration Plan

Greenfield — no migration. Rollback = delete the new Xcode project and Swift files. No data, no users, no production system.

## Open Questions

- Should the Xcode project live at the repo root (`/InstagramGridPlanner.xcodeproj`) or under a subfolder (`/app/InstagramGridPlanner.xcodeproj`)? **Proposed default**: repo root, since this repo is single-purpose. Confirm with the user during apply if a subfolder is preferred.
- App icon and launch screen — placeholder only for Phase 1; revisit in Phase 13 (Final Polish).
