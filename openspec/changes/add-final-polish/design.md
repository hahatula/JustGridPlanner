## Context

All features are in place: `GridPlannerView` renders items (with an empty grid currently showing nothing), `ScreenshotImportView` runs the import (with only a no-account alert today), and `AccountSettingsView` edits the account (without showing `AppSettings.lastSuccessfulRefreshAt`, which is now set on import). Phase 14 of `/docs/08-task-breakdown.md` adds the deferred states and a final test pass. `/docs/09-testing-strategy.md` keeps verification manual.

## Goals / Non-Goals

**Goals:**
- Empty-state hint, import loading + error states, a last-imported indicator; a final end-to-end manual pass.

**Non-Goals:**
- New features, app icon/launch screen/theming/animations, automated tests, real API. See proposal Non-goals.

## Decisions

### Decision 1: Empty state via `ContentUnavailableView`, shown when the grid has no items
- **Choice**: In `GridPlannerView`, when `orderedItems.isEmpty`, show `ContentUnavailableView` with the message "Add photos from your gallery to plan your grid." (an SF Symbol like `photo.on.rectangle`), instead of the empty `ScrollView`.
- **Rationale**: iOS-17 idiomatic, zero custom layout. Shown when the whole grid is empty (no local *and* no posted) — overlaying a hint on a populated posted grid would be wrong; `/docs/06-ui-ux-rules.md` phrases it as "when no local items exist", and a fully empty grid is the only case with nothing to show.
- **Alternatives**: A custom `VStack` message — more code, same effect.

### Decision 2: Import loading state — process off-main with a progress overlay
- **Choice**: Add `@State private var isProcessing` to `ScreenshotImportView`. On "Split", run the crop/split/save on a background task (`Task.detached`) while showing a `ProgressView` overlay and disabling the Split button; advance to review on completion.
- **Rationale**: Splitting a full-resolution screenshot into nine JPEGs is non-trivial CPU work; doing it off the main thread keeps the UI responsive, and the indicator + disabled button prevent double-triggering (`posted-grid-import` loading requirement).
- **Alternatives**: Do it on the main thread — risks a visible hitch on large images.

### Decision 3: Import error state — validate and surface, never produce a partial set
- **Choice**: Add `@State private var errorMessage: String?`. If `loadTransferable` yields no image, or `GridSplitter` does not produce exactly nine tiles (e.g. a degenerate crop), set a clear message shown via `.alert`, stay on the pick/crop step, and produce no tiles.
- **Rationale**: Fail loudly and recoverably (`posted-grid-import` error requirement); the user can pick a different screenshot. Guarding "exactly nine" avoids a half-built posted grid.
- **Alternatives**: Silently ignore — rejected; confusing.

### Decision 4: Last-imported line in `AccountSettingsView`
- **Choice**: Read `AppSettingsStore.settings.lastSuccessfulRefreshAt`; show "Last imported: <relative>" using `RelativeDateTimeFormatter` (or `Text(date, format:)`), or "Not imported yet" when `nil`.
- **Rationale**: Surfaces the recorded timestamp (`account-selection` requirement) with no model change; relative time reads naturally for a personal app.

### Decision 5: Disable "Open Instagram" without an account
- **Choice**: Disable the "Open Instagram" button when `selectedUsername` is `nil`/empty, with a short hint; keep the existing prompt as a safety net.
- **Rationale**: Clearer affordance than only alerting after a tap; complements the existing `posted-grid-import` "open with no account → prompt" requirement.

## Risks / Trade-offs

- **[Trade-off] Empty state triggers on a fully empty grid, not strictly "no local items".** → Acceptable and clearer; documented above.
- **[Risk] Off-main image work + `@State` updates must hop back to the main actor.** → Mitigation: update `@State` on `@MainActor` after the detached work returns.
- **[Note] Polish only — no behavior or data changes.** → Low risk; all reads of existing state.

## Migration Plan

Purely additive UI states. Rollback = remove the empty-state branch, the loading/error `@State` and overlay/alert, and the last-imported line. No storage, model, or dependency changes.

## Open Questions

- None blocking. Further visual theming (icon, colors) is intentionally out of scope for this utility-focused app.
