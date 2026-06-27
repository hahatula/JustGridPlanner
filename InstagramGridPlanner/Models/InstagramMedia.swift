import Foundation

/// One already-posted Instagram media item — the shape a real API response
/// maps to (`/docs/04-architecture.md`). Kept minimal (three fields) so the
/// real service (Phase 12) and the mock share a single conversion to a
/// `GridItem`. This is the sync boundary's DTO; it carries no UI concerns.
struct InstagramMedia: Equatable {
    let id: String
    let thumbnailURL: URL?
    let takenAt: Date

    /// Converts the posted media into a locked grid item. `source == .instagram`
    /// makes `isLocked` true via the model's derived rule; the media id becomes
    /// the item's stable id (Instagram items reuse the API id). No
    /// `localImagePath` — these are not local items. `orderIndex` is supplied by
    /// the caller to reflect Instagram order; this method does not sort.
    func gridItem(gridType: GridType, orderIndex: Int) -> GridItem {
        GridItem(
            id: id,
            source: .instagram,
            gridType: gridType,
            orderIndex: orderIndex,
            instagramMediaId: id,
            thumbnailURL: thumbnailURL,
            createdAt: takenAt
        )
    }
}
