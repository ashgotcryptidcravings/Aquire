import SwiftUI

/// Universal hero-style card for a single product.
/// Used by ProductDetailView and BrowseView.
struct ProductCard: View {
    let product: Product

    @EnvironmentObject private var store: StoreModel

    @State private var hasAppeared: Bool = false

    private var hasModel: Bool { product.modelName != nil }
    private var isOwned: Bool { store.isAcquired(product) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top row: icon + 3D badge
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black.opacity(0.6))

                    Image(systemName: product.imageSystemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.accentColor)
                }
                .frame(width: 72, height: 72)

                Spacer()

                if hasModel {
                    Text("3D")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.accentColor)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 0.7)
                        )
                        .foregroundColor(.white)
                        .shadow(color: Color.accentColor.opacity(0.5),
                                radius: 12, x: 0, y: 4)
                }
            }

            // Category + name + description
            VStack(alignment: .leading, spacing: 4) {
                Text(product.category.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.8)
                    .foregroundColor(Color.accentColor.opacity(0.9))

                Text(product.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text(product.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(3)
            }

            // Price + status row
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(product.price, format: .currency(code: "USD"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if isOwned {
                    StatusChip(text: "Owned", style: .accent)
                } else {
                    StatusChip(text: "Available", style: .neutral)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.18),
                                    .white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                )
        )
        .shadow(
            color: Color.black.opacity(0.7),
            radius: 18, x: 0, y: 10
        )
        .scaleEffect(hasAppeared ? 1.0 : 0.96)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.9)) {
                hasAppeared = true
            }
        }
    }
}
