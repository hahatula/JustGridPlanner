import Foundation
import Observation

/// Owns the items of one grid (Posts or Reels are independent) and the logic
/// for adding local planned items from the gallery. Storage and import
/// plumbing are kept out of the views.
@Observable
final class GridPlannerViewModel {
    let gridType: GridType
    private let storage: LocalStorageService
    private let sync: InstagramSyncService

    var items: [GridItem]

    init(
        gridType: GridType,
        storage: LocalStorageService = .shared,
        sync: InstagramSyncService = ManualInstagramImportService()
    ) {
        self.gridType = gridType
        self.storage = storage
        self.sync = sync

        // Local planned items load synchronously and sit on top. Imported posted
        // tiles are restored just after via the sync boundary (async), so the
        // grid shows planning immediately and posted media a moment later.
        let saved = storage.loadItems(for: gridType)
            .filter { $0.source == .local }
            .sorted { $0.orderIndex < $1.orderIndex }
        self.items = Self.renumbered(saved)

        Task { await loadPostedTiles() }
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

    /// Turns imported screenshot tiles into locked posted items and merges them
    /// below the local planned block. Replaces any previous posted items —
    /// deleting their image files first so old screenshots don't accumulate —
    /// then persists. Local planned items are kept, on top, in order
    /// (`/docs/10-decisions.md` Decision 007).
    func importPostedTiles(_ paths: [String]) {
        // Replace: delete the files backing the current posted tiles.
        for item in items where item.source == .instagram {
            storage.deleteImage(for: item)
        }

        let posted = paths.map { path in
            GridItem(
                id: UUID().uuidString,
                source: .instagram,
                gridType: gridType,
                orderIndex: 0,
                localImagePath: path
            )
        }

        items = Self.renumbered(items.filter { $0.source == .local } + posted)
        persist()
    }

    /// Restores previously imported posted tiles via the sync boundary and
    /// merges them below the local planned items. Async so launch isn't blocked.
    private func loadPostedTiles() async {
        guard let posted = try? await sync.fetchPostedMedia(forUsername: "", gridType: gridType),
              !posted.isEmpty else { return }
        items = Self.renumbered(items.filter { $0.source == .local } + posted)
    }

    /// Saves the grid's file-backed items — local planned tiles and imported
    /// posted tiles (both carry a `localImagePath`). Items with no local file
    /// are not persisted.
    private func persist() {
        do {
            try storage.saveItems(items.filter { $0.localImagePath != nil }, for: gridType)
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
