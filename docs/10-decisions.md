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