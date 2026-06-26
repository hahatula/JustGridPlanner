import Foundation
import Observation

/// Owns the items of one grid (Posts or Reels are independent) and the logic
/// for adding local planned items from the gallery. Storage and import
/// plumbing are kept out of the views.
@Observable
final class GridPlannerViewModel {
    let gridType: GridType
    private let storage: LocalStorageService

    var items: [GridItem]

    init(gridType: GridType, storage: LocalStorageService = .shared) {
        self.gridType = gridType
        self.storage = storage
        #if DEBUG
        self.items = gridType == .posts ? SampleData.posts : SampleData.reels
        #else
        self.items = []
        #endif
    }

    /// Saves each image, creates a local `GridItem` for it, and inserts the new
    /// items at the top of the grid (picked order preserved), then renumbers
    /// `orderIndex` to match array position so planned items stay on top.
    /// Images that fail to save are skipped without aborting the rest.
    func addLocalImages(_ datas: [Data]) {
        let newItems: [GridItem] = datas.compactMap { data in
            guard let path = try? storage.saveImageData(data) else { return nil }
            return GridItem(
                id: UUID().uuidString,
                source: .local,
                gridType: gridType,
                orderIndex: 0,
                localImagePath: path
            )
        }
        guard !newItems.isEmpty else { return }
        items = renumbered(newItems + items)
    }

    /// Reassigns `orderIndex` to each item's position so array order is the
    /// grid order (index 0 = top-left).
    private func renumbered(_ items: [GridItem]) -> [GridItem] {
        items.enumerated().map { index, item in
            var copy = item
            copy.orderIndex = index
            return copy
        }
    }
}
