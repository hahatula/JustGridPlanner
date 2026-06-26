## Grid Types

The app has two separate grids:

1. Posts grid
2. Reels grid

Each grid has its own list of items and its own ordering.

## Item Types

There are two item sources:

### Instagram posted item

Represents media already published on Instagram.

Rules:

- Locked

- Cannot be dragged

- Cannot be reordered manually

- Cannot be removed by normal delete action

- Can be refreshed from Instagram sync

- Should keep its original order from Instagram

### Local planned item

Represents an image/video selected manually from the iPhone gallery.

Rules:

- Can be dragged

- Can be reordered

- Can be removed

- Must survive Instagram refresh

- Stored locally on device

## Refresh Logic

When refreshing Instagram data:

1. Fetch latest posted Instagram media.

2. Replace the Instagram-posted part of the grid.

3. Keep all local planned items.

4. Re-merge posted and planned items.

5. Do not delete local planned items.

Example:

Before refresh:

[IG-3, IG-2, IG-1, LOCAL-A, LOCAL-B]

After one new Instagram post is detected:

[IG-4, IG-3, IG-2, IG-1, LOCAL-A, LOCAL-B]

## Restrictions

- Do not implement auto-posting.

- Do not implement scheduling.

- Do not implement analytics.

- Do not implement multi-account support in MVP.

- Do not implement social login unless required for Instagram API sync.