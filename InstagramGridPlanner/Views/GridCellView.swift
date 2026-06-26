import SwiftUI

/// One tile in the grid. Shows the imported local image when available,
/// otherwise a placeholder (Instagram thumbnails arrive in Phase 9/12), and
/// marks locked Instagram items. The parent grid sizes the tile to the tab's
/// portrait aspect ratio; this view fills whatever space it is given.
struct GridCellView: View {
    let item: GridItem

    @State private var loadedImage: UIImage?

    var body: some View {
        content
            // Fill the tile the parent grid sized us to, then clip so a
            // cover-scaled image can never overflow its box.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .overlay(alignment: .topTrailing) {
                if item.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(.black.opacity(0.5), in: Circle())
                        .padding(4)
                }
            }
            .task(id: item.id) {
                await loadLocalImage()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let loadedImage {
            // Cover the tile, centered, without distortion: the clear base
            // takes the cell's size, the image fills it, the cell clips it.
            Color.clear
                .overlay {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFill()
                }
        } else {
            ZStack {
                tint
                // Placeholder when there is no local image to show. Posted vs.
                // planned are distinguished by tint and the lock badge.
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
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

#Preview("Locked (Instagram)") {
    GridCellView(item: GridItem(id: "ig", source: .instagram, gridType: .posts, orderIndex: 0))
        .frame(width: 120, height: 160)
}

#Preview("Unlocked (Local)") {
    GridCellView(item: GridItem(id: "lo", source: .local, gridType: .posts, orderIndex: 1))
        .frame(width: 120, height: 160)
}
