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

- Posted items and planned items should look visually different

- Posted items should show a lock indicator

- Local planned items should show delete action

- Dragging should only work for local planned items

## Empty State

When no local items exist:

Show a simple message:

"Add photos from your gallery to plan your grid."

## Refresh

Refresh button should update posted Instagram items only.

Manual planned items must remain.

## Account Selector UI

The app must provide a simple place to enter the Instagram username.

Preferred UI:

- A small account field at the top of the grid screen or settings sheet

- Placeholder: `@username`

- Current state: `Planning grid for @olgo.js`

- Refresh button near the selected username

The user should be able to edit the username without going through complex onboarding.

Validation should be simple:

- Empty username is not allowed for Instagram refresh

- Leading `@` is allowed

- Instagram profile URL paste is allowed

- Spaces should be trimmed

If refresh fails, show a clear error message without losing local planned items.