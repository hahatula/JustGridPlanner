import Foundation

/// Boundary for fetching already-posted Instagram media (`/docs/04-architecture.md`,
/// `/docs/10-decisions.md` Decision 004). Implementations convert API data into
/// **locked** Instagram `GridItem`s and return them in Instagram order; they are
/// NOT responsible for UI ordering (merging with local planned items is the
/// caller's job in Phase 10).
///
/// The fetch is `async throws` so a real implementation can surface network/API
/// errors; a mock can stand in without changing callers.
protocol InstagramSyncService {
    /// Fetches the given username's posted media for one grid, as locked
    /// Instagram items in Instagram order (e.g. newest first).
    func fetchPostedMedia(forUsername username: String, gridType: GridType) async throws -> [GridItem]
}
