import SwiftUI

/// Posts tab: the 3-column grid for `GridType.posts`, owned by a view model.
/// Importing from the gallery (toolbar "+") adds local planned items on top.
struct PostsGridView: View {
    @State private var viewModel = GridPlannerViewModel(gridType: .posts)

    /// Drives the error alert: presented while `refreshError` is set, cleared
    /// when the alert is dismissed.
    private var refreshErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.refreshError != nil },
            set: { if !$0 { viewModel.refreshError = nil } }
        )
    }

    var body: some View {
        NavigationStack {
            GridPlannerView(
                gridType: .posts,
                items: viewModel.items,
                onDelete: { viewModel.removeLocalItem($0) },
                onMove: { viewModel.moveLocalItem(withID: $0, beforeID: $1) }
            )
                .navigationTitle("Posts")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        AccountToolbarButton()
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        RefreshButton(viewModel: viewModel)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        PostedImportButton(gridType: .posts)
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
                .alert("Refresh", isPresented: refreshErrorBinding) {
                    Button("OK", role: .cancel) { viewModel.refreshError = nil }
                } message: {
                    Text(viewModel.refreshError ?? "")
                }
        }
    }
}

#Preview {
    PostsGridView()
}
