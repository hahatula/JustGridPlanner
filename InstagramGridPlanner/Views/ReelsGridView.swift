import SwiftUI

/// Reels tab: the 3-column grid for `GridType.reels`, owned by a view model.
/// Importing from the gallery (toolbar "+") adds local planned items on top.
struct ReelsGridView: View {
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
                        GalleryImportButton(viewModel: viewModel)
                    }
                }
        }
    }
}

#Preview {
    ReelsGridView()
}
