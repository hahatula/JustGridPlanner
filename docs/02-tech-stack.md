# Tech Stack

## Chosen Platform

Native iOS app.

## Language

Swift.

## UI Framework

SwiftUI.

Reasoning:

- The app is only for my iPhone.

- Native photo gallery access is important.

- SwiftUI is suitable for grid layouts, tabs, gestures, and local state.

- No backend is required for MVP.

- Direct installation via Xcode is acceptable because this is a personal app.

## Storage

MVP:

- Local JSON metadata

- Local image files stored in app documents directory

Possible later upgrade:

- SwiftData

Reasoning:

- The data model is simple.

- Local-only storage is enough.

- Avoid unnecessary database complexity at the beginning.

## Image Import

Use PhotosPicker.

## Networking

Use URLSession for future Instagram API sync.

## Authentication

Only needed if Instagram official API sync is implemented.

## Not Chosen

### React Native / Flutter

Not chosen because:

- App is only for iPhone.

- Native iOS is simpler for photo picker, local storage, and personal device installation.

### Backend

Not chosen for MVP because:

- No multi-device sync.

- No publishing.

- No sharing.

- No server-side processing needed.