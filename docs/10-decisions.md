# Decisions

## Decision 001: Native iOS App

Chosen because the app is only for personal iPhone use and needs good access to the photo gallery.

## Decision 002: Local-first Storage

Chosen because the app does not require accounts, cloud sync, or sharing.

## Decision 003: No Instagram Scraping

Chosen because scraping is fragile and may create account/security issues. Official API or manual import are preferred.

## Decision 004: Instagram Sync Is Required, But Must Be Isolated

Instagram posted media refresh is part of the required product.

However, the implementation must be isolated behind an `InstagramSyncService` boundary so the app can be developed and tested with mock data before real Instagram API integration is complete.

Reasoning:

- The grid, drag, remove, and merge behavior can be developed without waiting for Instagram API setup.
- Instagram API access may require account configuration, permissions, and token handling.
- A mock service allows controlled testing of locked posted items and refresh behavior.
- The final product still requires Instagram refresh or an approved fallback path.

## Decision 005: Instagram Account Is Selected by Username

The app should allow the user to type the Instagram username they want to plan, for example `@olgo.js`.

Reasoning:

- The user has more than one public Instagram account.
- The app is for planning public visual grids, not account management.
- The user should not need a complex account system.
- Username-based selection matches the mental model: “I am planning this account’s grid.”

The username must be stored locally and normalized without `@`.

The app must not store Instagram passwords or use scraping.

If the official Instagram API cannot fetch public media directly by arbitrary username, the app must keep the same product UX while hiding implementation details behind `InstagramSyncService`.

## Decision 006: Grid Tiles Are Portrait, Not Square

The grid uses portrait tiles to match Instagram's current profile grid:

- Posts grid: 3:4 aspect ratio
- Reels grid: 9:16 aspect ratio (reel cover)

Reasoning:

- Instagram replaced the old 1:1 square thumbnails with 3:4 portrait thumbnails for profile posts; reels are shown as 9:16 covers.
- The app's purpose is to preview how the grid will look before posting, so the tile shape must match what Instagram actually renders.

The aspect ratio is a presentation concern, derived from the grid type in the view layer; it is not stored on the data model.

## Decision 007: Local Planned Items Appear on Top

Local planned items are shown at the top of the grid, above the already-posted Instagram items. Newly added items are inserted at the top; an Instagram refresh inserts fetched posts below the planned block and never reorders the planned items above them.

Reasoning:

- Planned items represent the user's next posts. When posted, they become the newest media and appear at the top-left of the Instagram grid, so the planning preview must show them on top.
- Posting affordances (e.g. "add from gallery") must live outside the grid (e.g. a toolbar button), never as interactive cells inside the grid, so the preview is not polluted by controls.

This supersedes the earlier examples that showed planned items at the bottom of the refresh merge.

## Decision 008: Posted Media Comes From Manual Screenshot Import

Already-posted Instagram media is brought into the grid by a user-driven screenshot import, not by the official API or scraping.

Reasoning (confirmed by Phase 11 research):

- The official Instagram API (Instagram API with Instagram Login / Business Discovery) cannot fetch arbitrary public accounts' media. It returns only the authenticated user's own professional account, or — via Business Discovery — other accounts that are themselves Business/Creator; personal accounts cannot be fetched at all, and it requires a professional account plus Meta app setup. (The Instagram Basic Display API was shut down in 2024.)
- Scraping the public profile is forbidden (Decision 003, `/docs/07-agent-workflow.md`) and against Instagram's terms.
- The app plans any account with low-fidelity previews, so a user-captured screenshot is sufficient and fully compliant — an approved manual fallback per `/docs/07-agent-workflow.md`.

Flow: the user opens the Instagram profile, screenshots the 3×3 grid, returns to the app, imports the screenshot via PhotosPicker, aligns a draggable 3×3 overlay to the grid, and the app splits it into 9 locked posted tiles backed by local image files. "Refresh" means re-importing a newer screenshot, which replaces the posted tiles.

This stays behind the `InstagramSyncService` boundary (Decision 004), so the official API remains a possible future implementation without changing the UX. Decision 005 (username selection) still holds: the username identifies which account is being planned and which profile "Open Instagram" opens, but it does not fetch media.