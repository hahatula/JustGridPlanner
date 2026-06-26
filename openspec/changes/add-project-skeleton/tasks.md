## 1. Confirm scope before creating any files

- [x] 1.1 Re-read `/AGENTS.md` "Existing Code Awareness" section and confirm there is no existing Swift source in the repo (a fresh `find . -name "*.swift"` returns nothing). Record the result in the apply notes.
  - **Acceptance**: One-line note in the apply summary stating "Greenfield: no prior Swift code found."
- [x] 1.2 Confirm with the user where the Xcode project should live: repo root (`/InstagramGridPlanner.xcodeproj`) vs. subfolder (`/app/...`). Default to repo root if no preference.
  - **Acceptance**: Decision captured before any project file is created.

## 2. Create the Xcode project

- [x] 2.1 In Xcode, create a new iOS App project named **InstagramGridPlanner**, Interface = **SwiftUI**, Language = **Swift**, Storage = **None**, Include Tests = **No**, deployment target **iOS 17.0**, devices = **iPhone only**, bundle identifier `com.olgagolubev.InstagramGridPlanner`. Save at the location chosen in 1.2.
  - **Acceptance**: `InstagramGridPlanner.xcodeproj` exists and opens in Xcode without errors.
- [x] 2.2 In Project settings, verify: deployment target = iOS 17.0, supported destinations = iPhone only (uncheck iPad / Mac), orientations = Portrait only.
  - **Acceptance**: Settings match the above; no warnings in the Issue Navigator.
- [x] 2.3 Build the empty project once to confirm the Xcode-generated default app launches in the iPhone simulator.
  - **Manual test**: Run on "iPhone 15" simulator — app shows the default "Hello, world!" view; no crash.

## 3. Establish the canonical folder layout

- [x] 3.1 In the Xcode project navigator, create the following groups, each backed by a real on-disk folder under the app source root: `App/`, `Models/`, `Views/`, `ViewModels/`, `Services/`, `Utilities/`.
  - **Acceptance**: All six folders exist on disk and as Xcode groups; Xcode group icons show the folder badge (filesystem-backed).
- [x] 3.2 In each currently-empty folder (`Models/`, `ViewModels/`, `Services/`, `Utilities/`), add a `.gitkeep` file so the folder survives in git.
  - **Acceptance**: `git status` (after `git add`) shows four `.gitkeep` files staged.
- [x] 3.3 Move the auto-generated `InstagramGridPlannerApp.swift` from the project root into `App/` (drag in Xcode so the reference updates).
  - **Acceptance**: File appears in `App/` group, build still succeeds.

## 4. Implement `MainTabView`

- [x] 4.1 In `Views/`, create `MainTabView.swift` containing a SwiftUI `TabView` with exactly two tabs: a Posts tab (SF Symbol `square.grid.3x3`, label "Posts") hosting `PostsGridView()`, and a Reels tab (SF Symbol `play.rectangle`, label "Reels") hosting `ReelsGridView()`.
  - **Acceptance**: `MainTabView` compiles. No additional tabs are present.
- [x] 4.2 Add a `#Preview` for `MainTabView` so it renders in the Xcode canvas.
  - **Acceptance**: Canvas preview shows the tab bar with both tabs.

## 5. Implement placeholder tab views

- [x] 5.1 In `Views/`, create `PostsGridView.swift`: a SwiftUI `View` whose body is a `NavigationStack` containing a centered `VStack` with `Text("Posts").font(.title)` and `Text("Coming soon").foregroundStyle(.secondary)`. Add a `.navigationTitle("Posts")`.
  - **Acceptance**: File compiles. No PhotosPicker, no grid, no models, no services referenced.
- [x] 5.2 In `Views/`, create `ReelsGridView.swift`: same structure as 5.1 but with `Text("Reels")` and `.navigationTitle("Reels")`.
  - **Acceptance**: File compiles. No feature code from later phases.
- [x] 5.3 Add `#Preview` blocks for both `PostsGridView` and `ReelsGridView`.
  - **Acceptance**: Canvas previews render for both.

## 6. Wire the entry point

- [x] 6.1 Edit `App/InstagramGridPlannerApp.swift` so the `body` returns a `WindowGroup { MainTabView() }`. Remove the default `ContentView` reference and delete the generated `ContentView.swift` (no longer needed).
  - **Acceptance**: Only `InstagramGridPlannerApp.swift`, `MainTabView.swift`, `PostsGridView.swift`, `ReelsGridView.swift` exist as Swift source files. Build succeeds.

## 7. Build, run, and manually verify

- [x] 7.1 Clean and build the project (Cmd-Shift-K, then Cmd-B).
  - **Acceptance**: Build succeeds; no errors and no new warnings introduced by this change.
- [x] 7.2 Run on an iPhone simulator (iOS 17+).
  - **Manual test**:
    1. App launches; Posts tab is selected by default.
    2. Posts content shows the navigation title "Posts", body text "Posts" and subtitle "Coming soon".
    3. Tap the Reels tab — the Reels placeholder appears with title "Reels" and subtitle "Coming soon".
    4. Tap back to Posts — Posts placeholder returns.
    5. No crash, no console errors, no PhotosPicker prompts, no network activity.
- [x] 7.3 Run a quick negative check: `grep -RIn "GridItem\|PhotosPicker\|InstagramSyncService\|LocalStorageService\|AppSettings" InstagramGridPlanner/` returns no matches.
  - **Acceptance**: Confirms no premature feature code from later phases leaked in.

## 8. Source control & reporting

- [x] 8.1 Add a sensible `.gitignore` for Xcode (DerivedData, xcuserdata, `.DS_Store`, etc.) if not present.
  - **Acceptance**: `.gitignore` covers Xcode build artifacts.
- [x] 8.2 Stage all new files and write the apply-phase summary per `/docs/07-agent-workflow.md` "Implementation Rules": what changed, files changed, manual test steps, known limitations, remaining requirements.
  - **Acceptance**: Summary lists every new Swift file and confirms Phase 1 acceptance scenarios all pass; explicitly notes that Phases 2–13 remain incomplete (expected).
