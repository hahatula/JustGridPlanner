import Foundation

/// Identifies which of the two independent grids an item belongs to.
///
/// String-backed and `Codable` so persisted JSON (Phase 5) stays stable and
/// human-readable regardless of case ordering.
enum GridType: String, Codable, CaseIterable, Identifiable {
    case posts
    case reels

    var id: String { rawValue }
}
