import SwiftUI

/// Reusable 3-column grid used by both the Posts and Reels tabs. Pure
/// presentation: it renders the items it is handed, sorted by `orderIndex`,
/// and applies the tab's portrait tile aspect ratio. No add/remove/reorder,
/// no storage, no networking (those arrive in later phases).
struct GridPlannerView: View {
    let gridType: GridType
    let items: [GridItem]

    private let columnCount = 3
    private let spacing: CGFloat = 1

    /// Aspect ratio Instagram uses for this surface (width / height). Derived
    /// from `gridType` in the view layer — not stored on the model.
    private var tileAspectRatio: CGFloat {
        switch gridType {
        case .posts: return 3.0 / 4.0
        case .reels: return 9.0 / 16.0
        }
    }

    private var orderedItems: [GridItem] {
        items
            .filter { $0.gridType == gridType }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    var body: some View {
        GeometryReader { geo in
            // Compute an exact tile size from the available width so every
            // cell is the same size regardless of its content (image vs
            // placeholder). `SwiftUI.GridItem` is qualified because this module
            // also declares a model named `GridItem`.
            let tileWidth = (geo.size.width - spacing * CGFloat(columnCount - 1)) / CGFloat(columnCount)
            let tileHeight = tileWidth / tileAspectRatio
            let columns = Array(
                repeating: SwiftUI.GridItem(.fixed(tileWidth), spacing: spacing),
                count: columnCount
            )

            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(orderedItems) { item in
                        GridCellView(item: item, width: tileWidth, height: tileHeight)
                    }
                }
            }
        }
    }
}

#Preview("Posts (3:4)") {
    GridPlannerView(gridType: .posts, items: SampleData.posts)
}

#Preview("Reels (9:16)") {
    GridPlannerView(gridType: .reels, items: SampleData.reels)
}
