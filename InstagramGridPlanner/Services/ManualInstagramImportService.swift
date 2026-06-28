import Foundation

/// The runtime `InstagramSyncService`: posted media comes from the user's
/// manual screenshot import (`/docs/10-decisions.md` Decision 008), so the
/// "fetch" is simply loading the persisted imported tiles for a grid. The
/// username is ignored (the import isn't account-scoped). A future real-API
/// implementation can replace this one type behind the same boundary with no
/// view-model change (Decision 004).
struct ManualInstagramImportService: InstagramSyncService {
    private let storage: LocalStorageService

    init(storage: LocalStorageService = .shared) {
        self.storage = storage
    }

    func fetchPostedMedia(forUsername username: String, gridType: GridType) async throws -> [GridItem] {
        storage.loadItems(for: gridType).filter { $0.source == .instagram }
    }
}
