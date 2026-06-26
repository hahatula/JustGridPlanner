import SwiftUI

/// Placeholder for the Reels grid. Phase 3 replaces the body with the
/// real grid; the surrounding `NavigationStack` is kept now so that
/// change does not require re-wrapping.
struct ReelsGridView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Text("Reels")
                    .font(.title)
                Text("Coming soon")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Reels")
        }
    }
}

#Preview {
    ReelsGridView()
}
