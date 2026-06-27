import SwiftUI

/// Reusable leading toolbar button showing the current account (`@username`)
/// or a "Set account" prompt when none is selected. Tapping it presents the
/// account settings sheet. Shared by both tabs so the label stays in sync via
/// the environment's `AppSettingsStore`.
struct AccountToolbarButton: View {
    @Environment(AppSettingsStore.self) private var store

    @State private var isPresentingSettings = false

    var body: some View {
        Button {
            isPresentingSettings = true
        } label: {
            // An explicit icon+text row keeps the handle visible: the toolbar
            // renders a plain `Label` as an icon-only chip, hiding the account.
            HStack(spacing: 4) {
                if let username = store.selectedUsername {
                    Image(systemName: "person.crop.circle")
                    Text("@\(username)")
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                    Text("Set account")
                }
            }
            .font(.subheadline)
        }
        .sheet(isPresented: $isPresentingSettings) {
            AccountSettingsView()
        }
    }
}

#Preview {
    NavigationStack {
        Text("Grid")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AccountToolbarButton()
                }
            }
    }
    .environment(AppSettingsStore())
}
