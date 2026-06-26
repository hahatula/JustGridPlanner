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

    /// Sample Posts grid: local planned items sit at the top (they represent
    /// the user's next posts), followed by already-posted Instagram items
    /// newest-first. Ordered by ascending `orderIndex`.
    static let posts: [GridItem] = [
        GridItem(id: "local-posts-1", source: .local, gridType: .posts,
                 orderIndex: 0, localImagePath: "images/local-posts-1.jpg",
                 createdAt: baseDate),
        GridItem(id: "local-posts-2", source: .local, gridType: .posts,
                 orderIndex: 1, localImagePath: "images/local-posts-2.jpg",
                 createdAt: baseDate.addingTimeInterval(-10_000)),
        GridItem(id: "ig-posts-1", source: .instagram, gridType: .posts,
                 orderIndex: 2, instagramMediaId: "media_p1",
                 createdAt: baseDate.addingTimeInterval(-86_400)),
        GridItem(id: "ig-posts-2", source: .instagram, gridType: .posts,
                 orderIndex: 3, instagramMediaId: "media_p2",
                 createdAt: baseDate.addingTimeInterval(-172_800)),
        GridItem(id: "ig-posts-3", source: .instagram, gridType: .posts,
                 orderIndex: 4, instagramMediaId: "media_p3",
                 createdAt: baseDate.addingTimeInterval(-259_200)),
    ]

    /// Sample Reels grid: same shape as `posts` — local planned on top, then
    /// posted Instagram reels.
    static let reels: [GridItem] = [
        GridItem(id: "local-reels-1", source: .local, gridType: .reels,
                 orderIndex: 0, localImagePath: "images/local-reels-1.jpg",
                 createdAt: baseDate),
        GridItem(id: "ig-reels-1", source: .instagram, gridType: .reels,
                 orderIndex: 1, instagramMediaId: "media_r1",
                 createdAt: baseDate.addingTimeInterval(-86_400)),
        GridItem(id: "ig-reels-2", source: .instagram, gridType: .reels,
                 orderIndex: 2, instagramMediaId: "media_r2",
                 createdAt: baseDate.addingTimeInterval(-172_800)),
    ]
}
#endif
