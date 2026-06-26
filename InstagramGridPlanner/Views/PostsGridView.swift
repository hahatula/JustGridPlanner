import SwiftUI

/// Posts tab: the 3-column grid for `GridType.posts`. Seeds from `SampleData`
/// in DEBUG; real items arrive via gallery import (Phase 4) and Instagram
/// sync (Phase 9).
struct PostsGridView: View {
    var body: some View {
        NavigationStack {
            GridPlannerView(gridType: .posts, items: items)
                .navigationTitle("Posts")
        }
    }

    private var items: [GridItem] {
        #if DEBUG
        SampleData.posts
        #else
        []
        #endif
    }
}

#Preview {
    PostsGridView()
}
