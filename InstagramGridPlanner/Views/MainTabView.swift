import SwiftUI

/// Root composition point for the app. Hosts the two top-level tabs:
/// Posts and Reels. Later phases inject view models and replace the
/// placeholder grid views, but the tab structure stays here.
struct MainTabView: View {
    var body: some View {
        TabView {
            PostsGridView()
                .tabItem {
                    Label("Posts", systemImage: "square.grid.3x3")
                }

            ReelsGridView()
                .tabItem {
                    Label("Reels", systemImage: "play.rectangle")
                }
        }
    }
}

#Preview {
    MainTabView()
}
