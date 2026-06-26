# Requirements

## Product Goal

Build a private iPhone app for planning the visual layout of an Instagram account grid.

The app must show already-posted Instagram media as locked items and allow manually selected local images to be added, reordered, and removed before publishing them manually on Instagram.

The app is for personal use only and will not be published, sold, or distributed.

## Required Features

### Instagram Posted Media

The app must be able to fetch already-posted media from an Instagram account.

Fetched Instagram media must be shown as locked grid items.

Instagram items:

- Must not be draggable
- Must not be manually reordered
- Must not be removed through the normal remove action
- Must preserve Instagram order
- Must be refreshed when the user triggers refresh

### Posts Grid

The app must provide a Posts tab.

The Posts tab must:

- Display a 3-column Instagram-like grid
- Use a 3:4 portrait aspect ratio
- Show already-posted Instagram posts
- Allow local planned images to be added from the iPhone gallery
- Allow local planned images to be reordered by drag
- Allow local planned images to be removed
- Keep local planned images after Instagram refresh

### Reels Grid

The app must provide a Reels tab.

The Reels tab must:

- Display a 3-column grid for reels planning
- Use a 9:16 portrait aspect ratio (reel cover)
- Show already-posted Instagram reels
- Allow local planned reel images or thumbnails to be added from the iPhone gallery
- Allow local planned items to be reordered by drag
- Allow local planned items to be removed
- Keep local planned items after Instagram refresh

### Local Gallery Import

The user must be able to choose images from the iPhone gallery.

Imported images must:

- Appear in the selected grid
- Be stored locally by the app
- Persist after app restart
- Be removable by the user

### Drag and Reorder

Only manually added local items may be draggable.

Instagram-posted items must remain locked.

Dragging must update the saved order.

### Refresh Behavior

The user must be able to refresh the posted Instagram part of the grid.

Refresh must:

- Fetch current posted Instagram media
- Replace/update Instagram-posted items
- Keep all manually added local items
- Keep manually added local items on top (above posted Instagram items)
- Preserve the user’s planned local order as much as possible
- Never delete local planned images

Example:

Before refresh:

text [LOCAL-A, LOCAL-B, IG-3, IG-2, IG-1] 

After a new Instagram post appears:

text [LOCAL-A, LOCAL-B, IG-4, IG-3, IG-2, IG-1] 

## Instagram Account Selection

The app must allow the user to choose which Instagram account grid to plan.

The account should be selected by typing an Instagram username/nickname, for example:
@olgo.js or olgo.js

The app must normalize the username internally.
@olgo.js -> olgo.js
olgo.js -> olgo.js
https://instagram.com/olgo.js -> olgo.js

The selected username must be saved locally and reused after app restart.
The user must be able to change the selected username.

## Required Constraints

- Native iPhone app
- Local-first storage
- No backend unless explicitly approved
- No Instagram password storage
- No Instagram scraping
- Official Instagram API or approved manual fallback only
- No publishing to Instagram from the app
- No App Store release