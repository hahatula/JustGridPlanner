import Foundation
import UIKit

/// Stores a grid's local planned items (as JSON metadata) and the imported
/// image files they reference, and deletes an item's image file on removal.
final class LocalStorageService {
    static let shared = LocalStorageService()

    private let fileManager: FileManager
    /// Relative directory (under Documents) where imported images live.
    private let imagesDirectoryName = "images"
    /// Relative directory (under Documents) where grid metadata JSON lives.
    private let metadataDirectoryName = "metadata"

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    /// Optional base directory override (defaults to Documents). Lets tests and
    /// the DEBUG sanity checks run against an isolated directory instead of the
    /// app's real Documents, so they never touch the user's grids.
    private let rootOverride: URL?

    init(fileManager: FileManager = .default, root: URL? = nil) {
        self.fileManager = fileManager
        self.rootOverride = root
    }

    private var documentsURL: URL {
        rootOverride ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var imagesURL: URL {
        documentsURL.appendingPathComponent(imagesDirectoryName, isDirectory: true)
    }

    private var metadataURL: URL {
        documentsURL.appendingPathComponent(metadataDirectoryName, isDirectory: true)
    }

    private func metadataFileURL(for gridType: GridType) -> URL {
        metadataURL.appendingPathComponent("\(gridType.rawValue).json")
    }

    /// App settings JSON lives directly under Documents (it is app-wide config,
    /// not per-grid data).
    private var settingsFileURL: URL {
        documentsURL.appendingPathComponent("settings.json")
    }

    /// Re-encodes the given image data to JPEG and writes it under
    /// `images/<uuid>.jpg`, returning the relative path stored on a `GridItem`.
    func saveImageData(_ data: Data) throws -> String {
        guard let image = UIImage(data: data),
              let jpeg = image.jpegData(compressionQuality: 0.9) else {
            throw StorageError.unsupportedImage
        }
        try fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        let relativePath = "\(imagesDirectoryName)/\(UUID().uuidString).jpg"
        let fileURL = documentsURL.appendingPathComponent(relativePath)
        try jpeg.write(to: fileURL, options: .atomic)
        return relativePath
    }

    /// Resolves an item's `localImagePath` to an absolute file URL. Works for
    /// any file-backed item — local planned tiles and imported posted tiles
    /// both carry a `localImagePath`. Returns `nil` for items without one.
    func imageURL(for item: GridItem) -> URL? {
        guard let path = item.localImagePath else { return nil }
        return documentsURL.appendingPathComponent(path)
    }

    /// Deletes the image file backing a file-backed item (a local planned tile
    /// or an imported posted tile). An item without a `localImagePath` or a
    /// missing/already-deleted file is a safe no-op (no throw): each import
    /// writes a unique `images/<uuid>.jpg`, so no other item shares the file.
    func deleteImage(for item: GridItem) {
        guard let url = imageURL(for: item) else { return }
        try? fileManager.removeItem(at: url)
    }

    // MARK: - Metadata

    /// Writes a grid's items to `metadata/<grid>.json` (atomically).
    func saveItems(_ items: [GridItem], for gridType: GridType) throws {
        try fileManager.createDirectory(at: metadataURL, withIntermediateDirectories: true)
        let data = try encoder.encode(items)
        try data.write(to: metadataFileURL(for: gridType), options: .atomic)
    }

    /// Reads a grid's saved items. Returns an empty array (never throws) when
    /// the file is missing, unreadable, or contains invalid/corrupted JSON.
    func loadItems(for gridType: GridType) -> [GridItem] {
        guard let data = try? Data(contentsOf: metadataFileURL(for: gridType)),
              let items = try? decoder.decode([GridItem].self, from: data) else {
            return []
        }
        return items
    }

    // MARK: - Settings

    /// Writes app settings to `Documents/settings.json` (atomically), reusing
    /// the ISO-8601 encoder.
    func saveSettings(_ settings: AppSettings) throws {
        let data = try encoder.encode(settings)
        try data.write(to: settingsFileURL, options: .atomic)
    }

    /// Reads app settings. Returns a default `AppSettings()` (never throws) when
    /// the file is missing, unreadable, or contains invalid/corrupted JSON, so
    /// first launch and corruption never break startup.
    func loadSettings() -> AppSettings {
        guard let data = try? Data(contentsOf: settingsFileURL),
              let settings = try? decoder.decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    enum StorageError: Error {
        case unsupportedImage
    }
}
