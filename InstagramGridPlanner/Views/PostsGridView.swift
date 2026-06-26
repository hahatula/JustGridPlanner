import SwiftUI

/// Placeholder for the Posts grid. Phase 3 replaces the body with the
/// real 3-column grid; the surrounding `NavigationStack` is kept now so
/// that change does not require re-wrapping.
struct PostsGridView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Text("Posts")
                    .font(.title)
                Text("Coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Posts")
        }
    }
}

#Preview {
    PostsGridView()
}
