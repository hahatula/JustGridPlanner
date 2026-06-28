import UIKit

/// Pure helper for the posted-import crop: maps the on-screen overlay rect to
/// the screenshot's pixels, splits that region into nine tiles, and saves them.
/// Isolated from the gestures so the error-prone coordinate transform is
/// testable on its own (`/docs/10-decisions.md` Decision 008, design Decision 4).
///
/// Coordinates: `imageSize` is the screenshot's **pixel** size (`cgImage`
/// dimensions). Because aspect-fit geometry is identical whether computed from
/// the image's points or pixels (they share one aspect ratio), feeding pixel
/// size yields the crop directly in pixel space — no `UIImage.scale` juggling.
enum GridSplitter {
    /// Maps `overlayRect` (view coordinates) to a pixel `CGRect` in the image,
    /// clamped to the image bounds. `displayFrame` is the image's actual
    /// on-screen rect (origin + size, preserving aspect); inverting against it
    /// keeps the crop in lockstep with the display regardless of how the image
    /// is fit (full-width, letterboxed, …).
    static func pixelRect(imageSize: CGSize, displayFrame: CGRect, overlayRect: CGRect) -> CGRect {
        guard imageSize.width > 0, displayFrame.width > 0 else { return .zero }
        let scale = displayFrame.width / imageSize.width
        guard scale > 0 else { return .zero }

        let minX = (overlayRect.minX - displayFrame.minX) / scale
        let minY = (overlayRect.minY - displayFrame.minY) / scale
        let maxX = (overlayRect.maxX - displayFrame.minX) / scale
        let maxY = (overlayRect.maxY - displayFrame.minY) / scale

        let clampedMinX = max(0, min(minX, imageSize.width))
        let clampedMinY = max(0, min(minY, imageSize.height))
        let clampedMaxX = max(0, min(maxX, imageSize.width))
        let clampedMaxY = max(0, min(maxY, imageSize.height))

        return CGRect(
            x: clampedMinX,
            y: clampedMinY,
            width: max(0, clampedMaxX - clampedMinX),
            height: max(0, clampedMaxY - clampedMinY)
        )
    }

    /// Crops `pixelRect` from the image and divides it into 3 columns × 3 rows
    /// of equal size, returning nine sub-images in row-major (left→right,
    /// top→bottom) order. Returns `[]` if the region is too small to split.
    static func split(_ image: UIImage, pixelRect: CGRect) -> [UIImage] {
        guard let region = image.cgImage?.cropping(to: pixelRect.integral) else { return [] }
        let tileWidth = region.width / 3
        let tileHeight = region.height / 3
        guard tileWidth > 0, tileHeight > 0 else { return [] }

        var tiles: [UIImage] = []
        for row in 0..<3 {
            for col in 0..<3 {
                let r = CGRect(x: col * tileWidth, y: row * tileHeight, width: tileWidth, height: tileHeight)
                if let tile = region.cropping(to: r) {
                    tiles.append(UIImage(cgImage: tile))
                }
            }
        }
        return tiles
    }

    /// Encodes the tiles to JPEG and saves them via `LocalStorageService`,
    /// returning the relative paths (skipping any that fail to encode/save).
    static func saveTiles(_ tiles: [UIImage], using storage: LocalStorageService = .shared) -> [String] {
        tiles.compactMap { tile in
            guard let data = tile.jpegData(compressionQuality: 0.9) else { return nil }
            return try? storage.saveImageData(data)
        }
    }
}
