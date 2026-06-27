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

- Can be refreshed by re-importing a screenshot (behind the Instagram sync boundary; see `/docs/10-decisions.md` Decision 008)

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

1. Obtain the latest posted Instagram media (re-import a newer screenshot).

2. Replace the Instagram-posted part of the grid.

3. Keep all local planned items.

4. Re-merge posted and planned items, keeping the local planned items on top (above the posted Instagram items).

5. Do not delete local planned items.

Local planned items represent the user's next posts, so they always sit at the top of the grid. Newly fetched Instagram posts are inserted below the planned block.

Example:

Before refresh:

[LOCAL-A, LOCAL-B, IG-3, IG-2, IG-1]

After one new Instagram post is detected:

[LOCAL-A, LOCAL-B, IG-4, IG-3, IG-2, IG-1]

## Restrictions

- Do not implement auto-posting.

- Do not implement scheduling.

- Do not implement analytics.

- Do not implement multi-account support in MVP.

- Do not implement social login unless required for Instagram API sync.