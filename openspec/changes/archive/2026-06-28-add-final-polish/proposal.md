## Why

The full product loop works (plan locally, arrange, persist, import posted media), but the rough edges from earlier phases were deferred to here. Phase 14 of `/docs/08-task-breakdown.md` is the final polish: an empty-state hint, loading and error states for the screenshot import, a "last imported" indicator, and a final manual test pass — so the app feels finished for everyday use.

## What Changes

- **Empty state**: when a grid has no items, show a clear hint — "Add photos from your gallery to plan your grid." (`/docs/06-ui-ux-rules.md`), using `ContentUnavailableView`.
- **Import loading state**: while a picked screenshot is being cropped/split/saved, show a progress indicator and disable the action so it can't be triggered twice.
- **Import error state**: if the picked image can't be loaded or split (e.g. an empty/invalid crop), surface a clear, recoverable error instead of failing silently or producing zero tiles.
- **Last imported indicator**: show "Last imported: <relative time>" in the account settings sheet, from `AppSettings.lastSuccessfulRefreshAt`.
- **Open Instagram button state**: disable the "Open Instagram" action when no account is selected (with a hint), complementing the existing prompt.
- **Final manual testing**: a full end-to-end pass across both tabs (plan, reorder, remove, import, re-import, relaunch).

## Capabilities

### Modified Capabilities
- `grid-display`: add an empty-state message when the grid has no items.
- `posted-grid-import`: add loading and error states to the import flow (progress while splitting; a clear error on failure).
- `account-selection`: show the last successful import time in the account settings.

### New Capabilities
<!-- None. Final polish refines existing capabilities; no new capability is introduced. -->

## Impact

- **Modified code**: `Views/GridPlannerView.swift` (empty state), `Views/ScreenshotImportView.swift` (loading + error states; Open-Instagram disabled state), `Views/AccountSettingsView.swift` (last-imported line).
- **New code**: none required (small UI additions); possibly a tiny date-formatting helper in `Utilities/` if reused.
- **Storage / model / dependencies**: none changed — purely presentational states reading existing data (`AppSettings.lastSuccessfulRefreshAt`, the grid's items).
- **Tech stack**: no deviation from `/docs/02-tech-stack.md`.

## Non-goals

- **No new features** — import, refresh-as-reimport, planning, persistence are done; this phase only refines states and feedback.
- **No app icon / launch screen / color theming / animations** beyond simple state views — out of scope for this polish pass (the brief is utility-focused, `/docs/06-ui-ux-rules.md`).
- **No automated test suite** — verification stays manual per `/docs/09-testing-strategy.md`; this phase adds the final manual test pass.
- **No real Instagram API / networking / auth** — Phase 12 (OUTDATED) / future.
- **No settings beyond the account + last-imported indicator** — "basic settings if needed" is satisfied by the existing account sheet plus the last-imported line.
- Nothing from `/docs/11-out-of-scope.md`.
