import SwiftUI

/// One tile in the grid. Renders a placeholder (no real media yet — local
/// files arrive in Phase 4, Instagram thumbnails in Phase 9/12) and marks
/// locked Instagram items. The parent grid sizes the tile to the tab's
/// portrait aspect ratio; this view just fills whatever space it is given.
struct GridCellView: View {
    let item: GridItem

    var body: some View {
        ZStack {
            tint
            // Image placeholder — no real media yet (local files arrive in
            // Phase 4, Instagram thumbnails in Phase 9/12). Posted vs. planned
            // are distinguished by tint and the lock badge, not by this icon.
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
