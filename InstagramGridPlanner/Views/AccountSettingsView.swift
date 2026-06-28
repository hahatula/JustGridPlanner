import SwiftUI

/// Sheet for viewing, changing, or clearing the selected Instagram account.
/// Reads the shared `AppSettingsStore` from the environment; a `TextField`
/// seeded with the current handle, a current-state line, and a Save action
/// that normalizes via `store.setUsername` (empty input clears the account).
struct AccountSettingsView: View {
    @Environment(AppSettingsStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var usernameField = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("@username", text: $usernameField)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } footer: {
                    if let username = store.selectedUsername {
                        Text("Planning grid for @\(username)")
                    } else {
                        Text("Enter the Instagram account you're planning for. You can paste a profile URL.")
                    }
                }

                Section {
                    LabeledContent("Last imported") {
                        if let date = store.settings.lastSuccessfulRefreshAt {
                            Text(date, format: .relative(presentation: .named))
                        } else {
                            Text("Not imported yet").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.setUsername(usernameField)
                        dismiss()
                    }
                }
            }
            .onAppear {
                usernameField = store.selectedUsername.map { "@\($0)" } ?? ""
            }
        }
    }
}

#Preview {
    AccountSettingsView()
        .environment(AppSettingsStore())
}
