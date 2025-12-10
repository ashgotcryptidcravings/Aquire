import SwiftUI

#if os(iOS)
import QuickLook

// MARK: - iOS Quick Look wrapper for USDZ models

struct ModelQuickLookView: UIViewControllerRepresentable {
    let url: URL

    // MARK: UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // nothing to update – the URL is fixed for the lifetime of the sheet
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        private let item: QLPreviewItem

        init(url: URL) {
            self.item = URLPreviewItem(url: url)
            super.init()
        }

        // One item only
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController,
                               previewItemAt index: Int) -> QLPreviewItem {
            item
        }
    }

    // MARK: - QLPreviewItem wrapper

    final class URLPreviewItem: NSObject, QLPreviewItem {
        let previewItemURL: URL?

        init(url: URL) {
            self.previewItemURL = url
            super.init()
        }
    }
}

#else

// MARK: - Stub for macOS / tvOS

/// On non-iOS platforms we don't have the QL USDZ viewer,
/// so just show a graceful fallback.
struct ModelQuickLookView: View {
    let url: URL    // kept for API compatibility

    var body: some View {
        VStack(spacing: 12) {
            Text("3D preview not available on this device.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))

            Text(url.lastPathComponent)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.7))
        )
    }
}

#endif
