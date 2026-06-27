import SwiftUI

/// Reusable toolbar control that refreshes one grid from the Instagram sync
/// boundary, placed beside the account button. Shows a spinner while the fetch
/// is in flight; on success it records the app-level last-refresh time. The
/// per-grid fetch is owned by the view model; the timestamp by the settings
/// store — this view just coordinates them.
struct RefreshButton: View {
    let viewModel: GridPlannerViewModel
    @Environment(AppSettingsStore.self) private var store

    var body: some View {
        Group {
            if viewModel.isRefreshing {
                ProgressView()
            } else {
                Button {
                    Task {
                        if await viewModel.refresh(username: store.selectedUsername) {
                            store.markRefreshed()
                        }
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
        }
        .disabled(viewModel.isRefreshing)
    }
}

#Preview {
    NavigationStack {
        Text("Grid")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    RefreshButton(viewModel: GridPlannerViewModel(gridType: .posts))
                }
            }
    }
    .environment(AppSettingsStore())
}
