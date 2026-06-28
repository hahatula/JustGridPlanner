import Foundation

/// Builds the public web link to an Instagram profile. Opening this `https`
/// universal link routes to the Instagram app when installed, else Safari —
/// no custom scheme, no `LSApplicationQueriesSchemes`, and no login or API
/// access (`/docs/10-decisions.md` Decision 008).
enum InstagramProfileLink {
    /// `https://instagram.com/<username>` for a normalized handle (no `@`).
    /// Returns `nil` for an empty/whitespace-only username.
    static func url(forUsername username: String) -> URL? {
        let handle = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !handle.isEmpty else { return nil }
        return URL(string: "https://instagram.com/\(handle)")
    }
}
