## 1. Confirm scope before changing files

- [x] 1.1 Re-inspect per `/AGENTS.md`: confirm there is no empty state in `GridPlannerView`, no loading/error states in `ScreenshotImportView` (only a no-account alert), and `AccountSettingsView` does not show `lastSuccessfulRefreshAt`. Record in apply notes.
  - **Acceptance**: One-line note "Empty/loading/error states + last-imported line missing."
- [x] 1.2 Confirm scope: presentational polish only (empty state, import loading + error, last-imported line, Open-Instagram disabled state, final manual test) — explicitly NOT new features, theming/icon, or automated tests.
  - **Acceptance**: Scope restated in apply notes.

## 2. Empty state

- [x] 2.1 In `GridPlannerView`, when there are no items to show, display `ContentUnavailableView` with "Add photos from your gallery to plan your grid." (and an SF Symbol) instead of an empty grid; otherwise render the grid unchanged.
  - **Acceptance**: An empty grid shows the hint; a grid with any item shows the grid and no hint.

## 3. Import loading state

- [x] 3.1 In `ScreenshotImportView`, add `@State isProcessing`. On "Split", run the crop/split/save off the main thread (`Task.detached`), show a `ProgressView` overlay, and disable the Split button until it completes; update `@State` back on the main actor and advance to review.
  - **Acceptance**: While splitting, a spinner shows and Split is disabled; the flow advances to review when done; the UI stays responsive on a large screenshot.

## 4. Import error state

- [x] 4.1 In `ScreenshotImportView`, add `@State errorMessage: String?`. If the picked image fails to load, or `GridSplitter` does not return exactly nine tiles, set a clear message shown via `.alert`, remain on the pick/crop step, and produce no tiles.
  - **Acceptance**: An unloadable/degenerate image shows a clear error and lets the user retake; no tiles are produced and no partial posted grid appears.

## 5. Last-imported indicator

- [x] 5.1 In `AccountSettingsView`, show "Last imported: <relative time>" from `AppSettingsStore.settings.lastSuccessfulRefreshAt` (using `RelativeDateTimeFormatter` or `Text(date, format:)`), or "Not imported yet" when `nil`.
  - **Acceptance**: After an import the sheet shows a relative last-import time; before any import it shows "Not imported yet".

## 6. Open Instagram button state

- [x] 6.1 In `ScreenshotImportView`, disable the "Open Instagram" button when no account is selected (with a short hint), keeping the existing prompt as a fallback.
  - **Acceptance**: With no account, "Open Instagram" is disabled and hints to set an account; with an account it opens the profile.

## 7. Build and final manual testing

- [x] 7.1 Clean build for an iPhone simulator (iOS 17+).
  - **Manual test**: `xcodebuild -scheme InstagramGridPlanner -destination 'platform=iOS Simulator,name=iPhone 17' clean build` → BUILD SUCCEEDED, no new warnings.
- [x] 7.2 Final end-to-end manual pass on both tabs:
  - **Manual test**:
    1. Fresh launch (no data): each grid shows the empty-state hint.
    2. Import local photos (gallery "+") → they appear on top; the hint disappears.
    3. Reorder local items (drag); remove one (×) — order/removal persist after relaunch.
    4. Set an account; open the account sheet → "Not imported yet".
    5. Run the screenshot import → a spinner shows while splitting; nine locked posted tiles appear below the local items.
    6. Reopen the account sheet → "Last imported: just now".
    7. Re-import → posted tiles replaced; relaunch → both local and posted restored.
    8. Trigger the error path (pick a tiny/invalid image) → a clear error, no tiles.
    9. With no account, "Open Instagram" is disabled.
- [x] 7.3 Capture a screenshot of the empty state and of a fully populated grid (local on top, posted below).
  - **Acceptance**: Screenshots show the hint (empty) and the planned-on-top + posted layout (populated).

## 8. Negative checks

- [x] 8.1 Confirm no scope creep / no new dependencies: `grep -RIn "URLSession\|OAuth\|import Alamofire\|UIColor(named" InstagramGridPlanner/` returns no unexpected matches; the diff is presentational only.
  - **Acceptance**: Only UI-state code changed; no networking/theming/deps added.

## 9. Source control & reporting

- [x] 9.1 Stage the modified files.
  - **Acceptance**: `git status` shows `GridPlannerView.swift`, `ScreenshotImportView.swift`, `AccountSettingsView.swift` modified.
- [x] 9.2 Write the apply-phase summary per `/docs/07-agent-workflow.md`: what changed, files changed, the final manual-test results (with screenshots), and a note that the MVP is feature-complete (Phases 1–14 done; the official-API path remains the documented future option).
  - **Acceptance**: Summary lists changed files and confirms the `grid-display`/`posted-grid-import`/`account-selection` polish scenarios pass.
- [x] 9.3 Include a **"How to test this change"** guide in the apply summary: open in Xcode and ⌘R; see the empty hint; add/import/reorder/remove; run the import (spinner → tiles); check "Last imported" in the account sheet; try the error path.
  - **Acceptance**: A reader can follow the guide to exercise all the polished states.
