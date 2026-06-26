import Foundation

/// Distinguishes media already published on Instagram from media the user
/// added manually from their gallery. Drives the derived locked/unlocked rule
/// on `GridItem`.
///
/// String-backed and `Codable` for stable, readable persisted JSON (Phase 5).
enum GridItemSource: String, Codable {
    case instagram
    case local
}
