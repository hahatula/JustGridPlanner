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

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
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

    /// Resolves a local item's `localImagePath` to an absolute file URL.
    /// Returns `nil` for non-local items or items without a path.
    func imageURL(for item: GridItem) -> URL? {
        guard item.source == .local, let path = item.localImagePath else { return nil }
        return documentsURL.appendingPathComponent(path)
    }

    /// Deletes the image file backing a local item. A non-local item or a
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

    enum StorageError: Error {
        case unsupportedImage
    }
}
