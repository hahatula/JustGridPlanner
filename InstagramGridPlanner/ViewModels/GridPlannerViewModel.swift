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

        // Persisted local planned items, restored on top (by stored order).
        let saved = storage.loadItems(for: gridType)
            .filter { $0.source == .local }
            .sorted { $0.orderIndex < $1.orderIndex }

        // Instagram items come from sync (Phase 9); until then, seed the sample
        // placeholders in DEBUG only so the grid has visual context.
        #if DEBUG
        let placeholders = (gridType == .posts ? SampleData.posts : SampleData.reels)
            .filter { $0.source == .instagram }
        #else
        let placeholders: [GridItem] = []
        #endif

        self.items = Self.renumbered(saved + placeholders)
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
        items = Self.renumbered(newItems + items)
        persist()
    }

    /// Removes a local planned item: deletes its image file, drops it from the
    /// grid, renumbers the rest, and persists. Instagram items are locked and
    /// ignored — the `isLocked` guard is defense-in-depth so a misbehaving
    /// caller can never remove one.
    func removeLocalItem(_ item: GridItem) {
        guard !item.isLocked else { return }
        storage.deleteImage(for: item)
        items = Self.renumbered(items.filter { $0.id != item.id })
        persist()
    }

    /// Reorders a local planned item within the local block: moves the item
    /// with `draggedID` to the position of the item with `targetID`, renumbers
    /// `orderIndex`, and persists. Both ids must resolve to local (`!isLocked`)
    /// items — the guard is defense-in-depth so Instagram items can never be
    /// dragged or used as a drop target. Instagram items keep their relative
    /// order below the locals, so planned items always stay on top.
    func moveLocalItem(withID draggedID: String, beforeID targetID: String) {
        guard draggedID != targetID else { return }
        guard let dragged = items.first(where: { $0.id == draggedID }), !dragged.isLocked,
              let target = items.first(where: { $0.id == targetID }), !target.isLocked
        else { return }

        var locals = items.filter { $0.source == .local }
        let others = items.filter { $0.source != .local }
        guard let from = locals.firstIndex(where: { $0.id == draggedID }),
              let to = locals.firstIndex(where: { $0.id == targetID })
        else { return }

        locals.move(fromOffsets: [from], toOffset: to > from ? to + 1 : to)
        items = Self.renumbered(locals + others)
        persist()
    }

    /// Saves the grid's local planned items to disk. Instagram items are not
    /// persisted — they are sync-derived (Phase 9).
    private func persist() {
        do {
            try storage.saveItems(items.filter { $0.source == .local }, for: gridType)
        } catch {
            #if DEBUG
            print("[GridPlannerViewModel] persist failed: \(error)")
            #endif
        }
    }

    /// Reassigns `orderIndex` to each item's position so array order is the
    /// grid order (index 0 = top-left).
    private static func renumbered(_ items: [GridItem]) -> [GridItem] {
        items.enumerated().map { index, item in
            var copy = item
            copy.orderIndex = index
            return copy
        }
    }
}
