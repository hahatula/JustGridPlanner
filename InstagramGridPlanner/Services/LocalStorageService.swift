import Foundation
import UIKit

/// Stores imported image files in the app's local storage. This phase only
/// handles image files; grid metadata save/load arrives in Phase 5 and image
/// deletion in Phase 6.
final class LocalStorageService {
    static let shared = LocalStorageService()

    private let fileManager: FileManager
    /// Relative directory (under Documents) where imported images live.
    private let imagesDirectoryName = "images"

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var imagesURL: URL {
        documentsURL.appendingPathComponent(imagesDirectoryName, isDirectory: true)
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

    enum StorageError: Error {
        case unsupportedImage
    }
}
