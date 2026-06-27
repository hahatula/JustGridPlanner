# UI/UX Rules

## General Style

The app should be simple, calm, and utility-focused.

No complex onboarding.

No marketing screens.

No account dashboard.

No unnecessary settings.

## Main Navigation

Use two tabs:

1. Posts

2. Reels

## Grid

- 3 columns

- Instagram-like visual preview

- Portrait tiles, not squares: Posts use a 3:4 aspect ratio, Reels use 9:16 (matching Instagram's profile grid)

- Posted items and planned items should look visually different

- Posted items should show a lock indicator

- Local planned items should show delete action

- Dragging should only work for local planned items

## Empty State

When no local items exist:

Show a simple message:

"Add photos from your gallery to plan your grid."

## Importing Posted Media (Screenshot)

Posted Instagram media is brought in by a manual screenshot import (see
`/docs/10-decisions.md` Decision 008), not by an API or scraping.

Flow:

- An "Open Instagram" action opens the selected account's profile.

- A short instruction tells the user: "Take a screenshot of the 3×3 grid, then return and tap Import Screenshot."

- "Import Screenshot" opens PhotosPicker (images only; no permission prompt).

- The app shows a draggable 3×3 overlay the user aligns to the grid.

- The app splits the cropped region into 9 locked posted tiles (Posts 3×3 of 3:4, Reels 3×3 of 9:16).

## Refresh

Refresh re-imports a newer screenshot and updates posted Instagram items only.

Manual planned items must remain.

## Account Selector UI

The app must provide a simple place to enter the Instagram username.

Preferred UI:

- A small account field at the top of the grid screen or settings sheet

- Placeholder: `@username`

- Current state: `Planning grid for @olgo.js`

- "Open Instagram" and "Import Screenshot" actions near the selected username (the import replaces the old API-refresh button)

The user should be able to edit the username without going through complex onboarding.

Validation should be simple:

- Empty username is not allowed for opening Instagram or importing a screenshot

- Leading `@` is allowed

- Instagram profile URL paste is allowed

- Spaces should be trimmed

If refresh fails, show a clear error message without losing local planned items.