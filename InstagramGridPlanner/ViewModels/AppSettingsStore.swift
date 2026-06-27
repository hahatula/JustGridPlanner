import Foundation
import Observation

/// App-level owner of `AppSettings`, shared by both tabs via `@Environment`.
/// Loads persisted settings on launch and saves on every change, keeping
/// persistence out of the views. One account is shared across grids, so a
/// single observable is the natural owner.
@Observable
final class AppSettingsStore {
    private let storage: LocalStorageService

    private(set) var settings: AppSettings

    init(storage: LocalStorageService = .shared) {
        self.storage = storage
        self.settings = storage.loadSettings()
    }

    /// The currently selected account, normalized (no `@`), or `nil`.
    var selectedUsername: String? {
        settings.selectedInstagramUsername
    }

    /// Normalizes raw input and stores it as the selected account, persisting
    /// the change. Empty/whitespace-only input clears the account.
    func setUsername(_ raw: String) {
        settings.selectedInstagramUsername = Username.normalized(raw)
        persist()
    }

    /// Clears the selected account and persists.
    func clearUsername() {
        settings.selectedInstagramUsername = nil
        persist()
    }

    private func persist() {
        do {
            try storage.saveSettings(settings)
        } catch {
            #if DEBUG
            print("[AppSettingsStore] saveSettings failed: \(error)")
            #endif
        }
    }
}
