import SwiftUI
import PhotosUI

/// Toolbar control that opens the system photo picker and hands the selected
/// images to the grid's view model. Lives outside the grid so the preview is
/// not polluted by controls (`/docs/10-decisions.md` Decision 007).
///
/// No `photoLibrary:` is passed, so the out-of-process picker is used and no
/// photo-library permission prompt is shown.
struct GalleryImportButton: View {
    @Bindable var viewModel: GridPlannerViewModel
    @State private var selection: [PhotosPickerItem] = []

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images) {
            Image(systemName: "plus")
        }
        .onChange(of: selection) { _, items in
            guard !items.isEmpty else { return }
            Task { await importItems(items) }
        }
    }

    private func importItems(_ items: [PhotosPickerItem]) async {
        var datas: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                datas.append(data)
            }
        }
        viewModel.addLocalImages(datas)
        selection = []
    }
}
