#if DEBUG
import Foundation

/// Development-only fixtures used by SwiftUI previews and Debug runs before
/// the gallery picker (Phase 4) and the mock Instagram sync (Phase 9) exist.
///
/// These are plain in-memory values: no network, no file access, no sync.
/// `thumbnailURL`/`localImagePath` are intentionally `nil` — Phase 3 chooses
/// placeholder visuals. Not compiled into Release builds.
enum SampleData {
    /// Fixed reference date so fixtures are deterministic across runs.
    private static let baseDate = Date(timeIntervalSince1970: 1_750_000_000)

    /// Sample Posts grid: locked Instagram items first, then unlocked local
    /// planned items, ordered by ascending `orderIndex`.
    static let posts: [GridItem] = [
        GridItem(id: "ig-posts-1", source: .instagram, gridType: .posts,
                 orderIndex: 0, instagramMediaId: "media_p1",
                 createdAt: baseDate),
        GridItem(id: "ig-posts-2", source: .instagram, gridType: .posts,
                 orderIndex: 1, instagramMediaId: "media_p2",
                 createdAt: baseDate.addingTimeInterval(-86_400)),
        GridItem(id: "ig-posts-3", source: .instagram, gridType: .posts,
                 orderIndex: 2, instagramMediaId: "media_p3",
                 createdAt: baseDate.addingTimeInterval(-172_800)),
        GridItem(id: "local-posts-1", source: .local, gridType: .posts,
                 orderIndex: 3, localImagePath: "images/local-posts-1.jpg",
                 createdAt: baseDate.addingTimeInterval(-200_000)),
        GridItem(id: "local-posts-2", source: .local, gridType: .posts,
                 orderIndex: 4, localImagePath: "images/local-posts-2.jpg",
                 createdAt: baseDate.addingTimeInterval(-210_000)),
    ]

    /// Sample Reels grid: same shape as `posts` for the Reels tab.
    static let reels: [GridItem] = [
        GridItem(id: "ig-reels-1", source: .instagram, gridType: .reels,
                 orderIndex: 0, instagramMediaId: "media_r1",
                 createdAt: baseDate),
        GridItem(id: "ig-reels-2", source: .instagram, gridType: .reels,
                 orderIndex: 1, instagramMediaId: "media_r2",
                 createdAt: baseDate.addingTimeInterval(-86_400)),
        GridItem(id: "local-reels-1", source: .local, gridType: .reels,
                 orderIndex: 2, localImagePath: "images/local-reels-1.jpg",
                 createdAt: baseDate.addingTimeInterval(-150_000)),
    ]
}
#endif
