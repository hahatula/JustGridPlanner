import SwiftUI

/// Posts tab: the 3-column grid for `GridType.posts`, owned by a view model.
/// Importing from the gallery (toolbar "+") adds local planned items on top.
struct PostsGridView: View {
    @State private var viewModel = GridPlannerViewModel(gridType: .posts)

    var body: some View {
        NavigationStack {
            GridPlannerView(gridType: .posts, items: viewModel.items)
                .navigationTitle("Posts")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        GalleryImportButton(viewModel: viewModel)
                    }
                }
        }
    }
}

#Preview {
    PostsGridView()
}
