import SwiftUI

/// Lightweight, always-on-top debug HUD toggled from Settings.
/// Shows core StoreModel state without heavy metrics.
struct DebugOverlay: View {
    @EnvironmentObject var store: StoreModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("DEBUG")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.purple)

            Text("Acquired: \(store.acquiredProducts.count) · Wishlist: \(store.wishlistProducts.count)")
                .font(.caption2)
                .foregroundColor(.white)

            Text("Acquired: \(store.acquiredProducts.count)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.85))

            Text("Wishlist: \(store.wishlistProducts.count)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.85))

            Text("Orders: \(store.orders.count)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.75))

            #if os(iOS)
            Text("Platform: iOS")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            #elseif os(macOS)
            Text("Platform: macOS")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            #endif
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.purple.opacity(0.6), lineWidth: 1)
        )
        .shadow(radius: 6)
        .padding(.top, 8)
        .padding(.trailing, 8)
    }
}
