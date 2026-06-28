import SwiftUI

/// Toolbar entry that launches the posted-media screenshot import for one grid.
/// Per-tab because the import is grid-specific (aspect ratio). `onComplete`
/// receives the saved tile paths; this phase's callers just dismiss (Phase 13
/// wires the tiles into the grid).
struct PostedImportButton: View {
    let gridType: GridType
    var onComplete: ([String]) -> Void = { _ in }

    @State private var isPresenting = false

    var body: some View {
        Button {
            isPresenting = true
        } label: {
            Image(systemName: "square.and.arrow.down")
        }
        // Full-screen so the screenshot and crop overlay get the full width and
        // height, making alignment easier.
        .fullScreenCover(isPresented: $isPresenting) {
            ScreenshotImportView(gridType: gridType, onComplete: onComplete)
        }
    }
}
