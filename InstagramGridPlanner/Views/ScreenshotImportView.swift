import SwiftUI
import PhotosUI

/// The posted-media capture pipeline (`/docs/10-decisions.md` Decision 008):
/// open the profile, import a screenshot, align a 3×3 overlay, and split it into
/// nine saved tile images. Launched per grid (the `gridType` sets the tile
/// aspect ratio). On confirmation it returns the saved tile paths via
/// `onComplete`; placing them in the grid is a later phase.
struct ScreenshotImportView: View {
    let gridType: GridType
    var onComplete: ([String]) -> Void = { _ in }

    @Environment(AppSettingsStore.self) private var store
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    private enum Step { case intro, crop, review }
    @State private var step: Step = .intro

    @State private var photoItem: PhotosPickerItem?
    @State private var screenshot: UIImage?
    @State private var tilePaths: [String] = []

    // Crop overlay state (view coordinates), initialized when the crop appears.
    @State private var cropCenter: CGPoint = .zero
    @State private var cropSize: CGSize = .zero

    @State private var noAccountAlert = false

    /// Tile aspect ratio (width / height) for the imported grid.
    private var aspectRatio: CGFloat {
        switch gridType {
        case .posts: return 3.0 / 4.0
        case .reels: return 9.0 / 16.0
        }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Import \(gridType == .posts ? "Posts" : "Reels")")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .alert("Set an account first", isPresented: $noAccountAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Choose the Instagram account you're planning for, then open its profile to screenshot.")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .intro: introStep
        case .crop: cropStep
        case .review: reviewStep
        }
    }

    // MARK: - Intro

    private var introStep: some View {
        VStack(spacing: 24) {
            Text("Open your Instagram profile, screenshot the grid, then import the screenshot to split it into tiles.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                openProfile()
            } label: {
                Label("Open Instagram", systemImage: "arrow.up.right.square")
            }
            .buttonStyle(.bordered)

            PhotosPicker(selection: $photoItem, matching: .images) {
                Label("Import Screenshot", systemImage: "photo")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { await loadScreenshot(item) }
        }
    }

    private func openProfile() {
        guard let username = store.selectedUsername,
              let url = InstagramProfileLink.url(forUsername: username) else {
            noAccountAlert = true
            return
        }
        openURL(url)
    }

    private func loadScreenshot(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        screenshot = image
        step = .crop
    }

    // MARK: - Crop

    private var cropStep: some View {
        GeometryReader { geo in
            let imageSize = pixelSize(of: screenshot)
            // The displayed image and the crop overlay share this single
            // coordinate space (the full GeometryReader), and the split uses the
            // same `geo.size` — so what you align is exactly what gets cropped.
            let frame = displayFrame(imageSize: imageSize, in: geo.size)

            ZStack(alignment: .topLeading) {
                Color.black
                if let screenshot {
                    // Rendered at the exact `frame` the crop math inverts against,
                    // so what you align is what gets cropped.
                    Image(uiImage: screenshot)
                        .resizable()
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.minX, y: frame.minY)
                }
                CropOverlay(aspectRatio: aspectRatio, bounds: frame, center: $cropCenter, size: $cropSize)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear { initializeOverlay(in: frame) }
            // Float the Split control over the image (not a safe-area inset, which
            // would shrink the image area and desync the crop mapping).
            .overlay(alignment: .bottom) {
                Button {
                    splitAndAdvance(imageSize: imageSize, displayFrame: frame)
                } label: {
                    Text("Split").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    /// Starts the overlay at the **full image width**, aspect-locked, centered
    /// vertically — so it lines up with a full-width 3×3 grid and the user only
    /// nudges it into place.
    private func initializeOverlay(in frame: CGRect) {
        guard cropSize == .zero, frame.width > 0 else { return }
        var width = frame.width
        var height = width / aspectRatio
        if height > frame.height {
            height = frame.height
            width = height * aspectRatio
        }
        cropSize = CGSize(width: width, height: height)
        cropCenter = CGPoint(x: frame.midX, y: frame.midY)
    }

    private func splitAndAdvance(imageSize: CGSize, displayFrame: CGRect) {
        guard let screenshot else { return }
        let overlayRect = CGRect(
            x: cropCenter.x - cropSize.width / 2,
            y: cropCenter.y - cropSize.height / 2,
            width: cropSize.width,
            height: cropSize.height
        )
        let pixelRect = GridSplitter.pixelRect(imageSize: imageSize, displayFrame: displayFrame, overlayRect: overlayRect)
        let tiles = GridSplitter.split(screenshot, pixelRect: pixelRect)
        tilePaths = GridSplitter.saveTiles(tiles)
        if !tilePaths.isEmpty { step = .review }
    }

    // MARK: - Review

    private var reviewStep: some View {
        VStack(spacing: 16) {
            Text("Review the nine tiles, then use them or retake.")
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: SwiftUI.GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                ForEach(tilePaths, id: \.self) { path in
                    TilePreview(relativePath: path, aspectRatio: aspectRatio)
                }
            }
            .padding(.horizontal)

            HStack {
                Button("Retake") { reset() }
                    .buttonStyle(.bordered)
                Button("Use these") {
                    onComplete(tilePaths)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding()
    }

    private func reset() {
        step = .intro
        screenshot = nil
        photoItem = nil
        tilePaths = []
        cropSize = .zero
    }

    // MARK: - Geometry helpers

    private func pixelSize(of image: UIImage?) -> CGSize {
        guard let cg = image?.cgImage else { return .zero }
        return CGSize(width: cg.width, height: cg.height)
    }

    /// The frame the screenshot occupies inside `viewSize`, fit to the **full
    /// width** (centered vertically). For a device screenshot — whose aspect
    /// matches the screen — this fills the view with no left/right gaps; the
    /// height follows from the image aspect.
    private func displayFrame(imageSize: CGSize, in viewSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let scale = viewSize.width / imageSize.width
        let displayed = CGSize(width: viewSize.width, height: imageSize.height * scale)
        let origin = CGPoint(x: 0, y: (viewSize.height - displayed.height) / 2)
        return CGRect(origin: origin, size: displayed)
    }
}

/// Loads and shows one saved tile from local storage in the review grid.
private struct TilePreview: View {
    let relativePath: String
    let aspectRatio: CGFloat
    @State private var image: UIImage?

    var body: some View {
        Rectangle()
            .fill(.gray.opacity(0.2))
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                if let image {
                    Image(uiImage: image).resizable().scaledToFill()
                }
            }
            .clipped()
            .task {
                // Resolve the saved tile via the existing local-image API by
                // describing it as a local item (gridType is irrelevant here).
                let item = GridItem(id: relativePath, source: .local, gridType: .posts,
                                    orderIndex: 0, localImagePath: relativePath)
                guard let url = LocalStorageService.shared.imageURL(for: item) else { return }
                image = await Task.detached { UIImage(contentsOfFile: url.path) }.value
            }
    }
}
