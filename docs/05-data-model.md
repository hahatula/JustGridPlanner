# Data Model

## GridType

Possible values:
- posts
- reels

## GridItemSource

Possible values:
- instagram
- local

## GridItem

Fields:
- id
- source
- gridType
- localImagePath
- instagramMediaId
- thumbnailURL
- createdAt
- orderIndex
- isLocked

## Rules

isLocked is derived from source:
- source == instagram => isLocked = true
- source == local => isLocked = false

Do not store business rules in UI components.

Posted (instagram) items imported via the manual screenshot import
(`/docs/10-decisions.md` Decision 008) are backed by a `localImagePath` pointing
to a cropped tile, rather than a remote `thumbnailURL`. They remain locked
(source == instagram) but persist locally because their image lives on device.

Example:
{
  "id": "local-001",
  "source": "local",
  "gridType": "posts",
  "localImagePath": "images/local-001.jpg",
  "instagramMediaId": null,
  "createdAt": "2026-06-26T10:00:00Z",
  "orderIndex": 4
}

## AppSettings

Stores app-level user configuration.

Fields:
- selectedInstagramUsername
- lastSuccessfulRefreshAt
- activeGridType

Example:
{
  "selectedInstagramUsername": "olgo.js",
  "lastSuccessfulRefreshAt": "2026-06-26T12:00:00Z",
  "activeGridType": "posts"
}