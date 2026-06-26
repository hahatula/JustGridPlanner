import Foundation

/// A single cell in a grid — either media already posted on Instagram
/// (locked) or an image the user planned locally (unlocked).
///
/// Fields mirror `/docs/05-data-model.md`. The type is `Codable` so Phase 5
/// can persist it unchanged, and `Equatable`/`Hashable` so the Phase 10
/// refresh can diff and merge items.
struct GridItem: Identifiable, Codable, Equatable, Hashable {
    /// Stable identifier. Local items generate this (e.g. `UUID().uuidString`)
    /// at creation; Instagram items reuse the media id from the API.
    let id: String
    let source: GridItemSource
    let gridType: GridType

    /// Relative path within app storage for a local image (e.g.
    /// `"images/local-001.jpg"`). Absent for Instagram items.
    var localImagePath: String?

    /// Instagram media id for posted items. Absent for local items.
    var instagramMediaId: String?

    /// Remote thumbnail for posted Instagram media. Absent for local items.
    var thumbnailURL: URL?

    var createdAt: Date
    var orderIndex: Int

    /// Locked state is derived from `source` and never stored — Instagram
    /// items are locked, local items are not. Because it is computed it is
    /// excluded from `Codable`, so it cannot drift from `source`
    /// (`/docs/05-data-model.md`: "Do not store business rules in UI components").
    var isLocked: Bool { source == .instagram }

    init(
        id: String,
        source: GridItemSource,
        gridType: GridType,
        orderIndex: Int,
        localImagePath: String? = nil,
        instagramMediaId: String? = nil,
        thumbnailURL: URL? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.gridType = gridType
        self.orderIndex = orderIndex
        self.localImagePath = localImagePath
        self.instagramMediaId = instagramMediaId
        self.thumbnailURL = thumbnailURL
        self.createdAt = createdAt
    }
}
