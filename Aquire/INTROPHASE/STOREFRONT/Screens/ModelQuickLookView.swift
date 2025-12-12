//
//  ModelQuickLookView.swift
//  Aquire
//

import SwiftUI
#if os(iOS)
import QuickLook
#endif

#if os(iOS)

/// The ONLY public-facing QuickLook wrapper
struct ModelQuickLookView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            QuickLookController(url: url)
                .ignoresSafeArea()
            
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
    }
}
    // MARK: - UIKit Bridge
    
    struct QuickLookController: UIViewControllerRepresentable {
        let url: URL
        
        func makeUIViewController(context: Context) -> QLPreviewController {
            let controller = QLPreviewController()
            controller.dataSource = context.coordinator
            return controller
        }
        
        func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(url: url)
        }
        
        final class Coordinator: NSObject, QLPreviewControllerDataSource {
            let item: QLPreviewItem
            
            init(url: URL) {
                self.item = URLItem(url: url)
            }
            
            func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
            
            func previewController(_ controller: QLPreviewController,
                                   previewItemAt index: Int) -> QLPreviewItem {
                item
            }
        }
    }
    
    final class URLItem: NSObject, QLPreviewItem {
        let previewItemURL: URL?
        init(url: URL) { self.previewItemURL = url }
    }
#endif
