import Foundation

/// App-wide configuration persisted locally (`/docs/05-data-model.md`).
///
/// In Phase 8 only `selectedInstagramUsername` is set by the user — it is the
/// Instagram account whose grid is being planned, stored normalized (no `@`,
/// lowercased). The other fields exist for later phases:
/// `lastSuccessfulRefreshAt` is set by sync (Phase 10) and `activeGridType`
/// can track the active tab; both default so this phase needs no migration.
struct AppSettings: Codable, Equatable {
    var selectedInstagramUsername: String?
    var lastSuccessfulRefreshAt: Date?
    var activeGridType: GridType

    init(
        selectedInstagramUsername: String? = nil,
        lastSuccessfulRefreshAt: Date? = nil,
        activeGridType: GridType = .posts
    ) {
        self.selectedInstagramUsername = selectedInstagramUsername
        self.lastSuccessfulRefreshAt = lastSuccessfulRefreshAt
        self.activeGridType = activeGridType
    }
}
