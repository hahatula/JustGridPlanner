import SwiftUI

/// Reels tab: the 3-column grid for `GridType.reels`, owned by a view model.
/// The gallery "+" adds local planned items on top; the import button brings in
/// posted tiles (locked) below them ("refresh" = re-import).
struct ReelsGridView: View {
    @Environment(AppSettingsStore.self) private var settingsStore
    @State private var viewModel = GridPlannerViewModel(gridType: .reels)

    var body: some View {
        NavigationStack {
            GridPlannerView(
                gridType: .reels,
                items: viewModel.items,
                onDelete: { viewModel.removeLocalItem($0) },
                onMove: { viewModel.moveLocalItem(withID: $0, beforeID: $1) }
            )
                .navigationTitle("Reels")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        AccountToolbarButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        PostedImportButton(gridType: .reels) { paths in
                            viewModel.importPostedTiles(paths)
                            settingsStore.markRefreshed()
                        }
                    }
                    // Break the shared toolbar background so import and "+" read
                    // as two separate buttons, not one.
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        GalleryImportButton(viewModel: viewModel)
                    }
                }
        }
    }
}

#Preview {
    ReelsGridView()
        .environment(AppSettingsStore())
}
