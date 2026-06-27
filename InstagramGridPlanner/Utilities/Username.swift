import Foundation

/// Normalizes raw account input into a clean Instagram handle
/// (`/docs/03-requirements.md`, `/docs/06-ui-ux-rules.md`,
/// `/docs/10-decisions.md` Decision 005: stored without `@`).
enum Username {
    /// Turns raw entry into a clean handle, or `nil` for "no account":
    /// trims whitespace; if the text contains `instagram.com/`, takes the
    /// segment after it up to the next `/` or `?`; strips a leading `@`;
    /// lowercases. Empty/whitespace-only input returns `nil`.
    ///
    /// A substring approach (vs. `URL` parsing) handles scheme-less pastes
    /// like `instagram.com/olgo.js`. Lowercasing matches Instagram's
    /// case-insensitive handles and prevents `Olgo.js`/`olgo.js` duplicates.
    static func normalized(_ raw: String) -> String? {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let range = text.range(of: "instagram.com/") {
            let afterHost = text[range.upperBound...]
            let handle = afterHost.prefix { $0 != "/" && $0 != "?" }
            text = String(handle)
        }

        if text.hasPrefix("@") {
            text.removeFirst()
        }

        text = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return text.isEmpty ? nil : text
    }
}
