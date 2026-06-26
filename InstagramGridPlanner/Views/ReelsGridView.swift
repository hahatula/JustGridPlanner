import SwiftUI

/// Reels tab: the 3-column grid for `GridType.reels`. Seeds from `SampleData`
/// in DEBUG; real items arrive via gallery import (Phase 4) and Instagram
/// sync (Phase 9).
struct ReelsGridView: View {
    var body: some View {
        NavigationStack {
            GridPlannerView(gridType: .reels, items: items)
                .navigationTitle("Reels")
        }
    }

    private var items: [GridItem] {
        #if DEBUG
        SampleData.reels
        #else
        []
        #endif
    }
}

#Preview {
    ReelsGridView()
}
