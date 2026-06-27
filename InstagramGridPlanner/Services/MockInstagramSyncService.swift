import Foundation

/// Deterministic stand-in for the real Instagram sync (`/docs/10-decisions.md`
/// Decision 004), so Phase 10 can build refresh/merge without API access. Holds
/// a few canned posted items per grid (distinct ids, descending `takenAt`, no
/// thumbnails yet — cells show the Instagram placeholder until Phase 12). The
/// username is accepted but ignored, and the call always succeeds. Foundation
/// only; no UI, no networking.
struct MockInstagramSyncService: InstagramSyncService {
    /// Fixed reference date so the canned timeline is deterministic across runs.
    private static let baseDate = Date(timeIntervalSince1970: 1_750_000_000)

    private static let postsMedia: [InstagramMedia] = cannedMedia(prefix: "mock-ig-posts", count: 6)
    private static let reelsMedia: [InstagramMedia] = cannedMedia(prefix: "mock-ig-reels", count: 4)

    /// Builds `count` canned items, newest first (descending `takenAt`).
    private static func cannedMedia(prefix: String, count: Int) -> [InstagramMedia] {
        (0..<count).map { index in
            InstagramMedia(
                id: "\(prefix)-\(index + 1)",
                thumbnailURL: nil,
                takenAt: baseDate.addingTimeInterval(-86_400 * Double(index))
            )
        }
    }

    func fetchPostedMedia(forUsername username: String, gridType: GridType) async throws -> [GridItem] {
        let media = gridType == .posts ? Self.postsMedia : Self.reelsMedia
        // Already newest-first; `orderIndex` mirrors that Instagram order.
        return media.enumerated().map { index, item in
            item.gridItem(gridType: gridType, orderIndex: index)
        }
    }
}
