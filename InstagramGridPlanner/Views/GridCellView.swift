import SwiftUI

/// One tile in the grid. Shows the imported local image when available,
/// otherwise a placeholder (Instagram thumbnails arrive in Phase 9/12), and
/// marks locked Instagram items. The parent grid passes the exact tile size.
struct GridCellView: View {
    let item: GridItem
    let width: CGFloat
    let height: CGFloat
    /// When non-nil, the tile shows a tappable × badge that calls this to
    /// remove the item. The parent supplies it only for local (deletable)
    /// items, so the cell never decides the business rule itself.
    var onDelete: (() -> Void)?

    @State private var loadedImage: UIImage?

    var body: some View {
        ZStack {
            tint
            if let loadedImage {
                // UIImageView's `.scaleAspectFill` reliably covers + clips,
                // avoiding SwiftUI's flaky `scaledToFill` sizing in grids.
                AspectFillImage(image: loadedImage)
                    .frame(width: width, height: height)
            } else {
                // Posted vs. planned are distinguished by tint and the lock badge.
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .overlay(alignment: .topTrailing) {
            // Mutually exclusive: Instagram items lock, local items get a ×.
            if item.isLocked {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(.black.opacity(0.5), in: Circle())
                    .padding(4)
            } else if let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(.black.opacity(0.5), in: Circle())
                        .padding(4)
                }
                .accessibilityLabel("Delete")
            }
        }
        .task(id: item.id) {
            await loadLocalImage()
        }
    }

    private func loadLocalImage() async {
        guard let url = LocalStorageService.shared.imageURL(for: item) else {
            loadedImage = nil
            return
        }
        let image = await Task.detached(priority: .utility) {
            UIImage(contentsOfFile: url.path)
        }.value
        loadedImage = image
    }

    /// Locked Instagram items and unlocked local items get distinct tints so
    /// posted vs. planned media look different.
    private var tint: Color {
        item.isLocked ? Color.gray.opacity(0.25) : Color.accentColor.opacity(0.15)
    }
}

/// Aspect-fill image backed by `UIImageView`, which crops-to-fill predictably
/// at any frame (SwiftUI's `Image.scaledToFill()` mis-sizes inside `LazyVGrid`).
private struct AspectFillImage: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> UIImageView {
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = image
    }
}

#Preview("Locked (Instagram)") {
    GridCellView(item: GridItem(id: "ig", source: .instagram, gridType: .posts, orderIndex: 0),
                 width: 120, height: 160,
                 onDelete: nil)
}

#Preview("Unlocked (Local)") {
    GridCellView(item: GridItem(id: "lo", source: .local, gridType: .posts, orderIndex: 1),
                 width: 120, height: 160,
                 onDelete: {})
}
