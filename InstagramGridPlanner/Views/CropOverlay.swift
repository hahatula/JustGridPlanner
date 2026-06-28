import SwiftUI

/// A movable, pinch-resizable 3×3 crop frame drawn over the displayed
/// screenshot. The frame is locked to `aspectRatio` (the grid's tile ratio —
/// 3:4 Posts, 9:16 Reels); a 3×3 block of such tiles has that same ratio, so
/// locking the whole frame keeps every split tile square-thirds and leaves only
/// three degrees of freedom (x, y, scale). The exterior is dimmed.
///
/// `center`/`size` are in the parent's view coordinates and are clamped to
/// `bounds` (the aspect-fit image frame).
struct CropOverlay: View {
    let aspectRatio: CGFloat
    let bounds: CGRect
    @Binding var center: CGPoint
    @Binding var size: CGSize

    /// Frame/size captured at the start of a gesture so movement is relative.
    @State private var dragStartCenter: CGPoint?
    @State private var pinchStartSize: CGSize?

    var body: some View {
        let rect = CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )

        ZStack {
            // Dim everything outside the crop rect (even-odd fill punches a hole).
            Canvas { context, canvasSize in
                var path = Path(CGRect(origin: .zero, size: canvasSize))
                path.addRect(rect)
                context.fill(path, with: .color(.black.opacity(0.5)), style: FillStyle(eoFill: true))
            }
            .allowsHitTesting(false)

            gridFrame(in: rect)
        }
        .contentShape(Rectangle())
        .gesture(dragGesture.simultaneously(with: pinchGesture))
    }

    /// The border plus two interior vertical and two horizontal lines (3×3).
    private func gridFrame(in rect: CGRect) -> some View {
        Path { path in
            path.addRect(rect)
            for i in 1...2 {
                let x = rect.minX + rect.width * CGFloat(i) / 3
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: rect.maxY))
                let y = rect.minY + rect.height * CGFloat(i) / 3
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
        }
        .stroke(Color.white, lineWidth: 1)
        .shadow(radius: 1)
        .allowsHitTesting(false)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let start = dragStartCenter ?? center
                if dragStartCenter == nil { dragStartCenter = center }
                center = clampedCenter(
                    CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height),
                    size: size
                )
            }
            .onEnded { _ in dragStartCenter = nil }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                let start = pinchStartSize ?? size
                if pinchStartSize == nil { pinchStartSize = size }
                let proposed = CGSize(width: start.width * scale, height: start.height * scale)
                size = clampedSize(proposed)
                center = clampedCenter(center, size: size)
            }
            .onEnded { _ in pinchStartSize = nil }
    }

    /// Clamps a size to the aspect ratio and to fit within `bounds`.
    private func clampedSize(_ proposed: CGSize) -> CGSize {
        // Keep the aspect ratio, then cap to the image bounds.
        var width = max(40, proposed.width)
        var height = width / aspectRatio
        if width > bounds.width { width = bounds.width; height = width / aspectRatio }
        if height > bounds.height { height = bounds.height; width = height * aspectRatio }
        return CGSize(width: width, height: height)
    }

    /// Clamps a center so a frame of `size` stays fully within `bounds`.
    private func clampedCenter(_ proposed: CGPoint, size: CGSize) -> CGPoint {
        let halfW = size.width / 2
        let halfH = size.height / 2
        return CGPoint(
            x: min(max(proposed.x, bounds.minX + halfW), bounds.maxX - halfW),
            y: min(max(proposed.y, bounds.minY + halfH), bounds.maxY - halfH)
        )
    }
}
