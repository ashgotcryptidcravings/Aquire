import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var store: StoreModel

    var body: some View {
        ZStack {
            AquireBackgroundView()

            if store.wishlistProducts.isEmpty {
                Text("No items in your wishlist yet.\nBrowse and star something to pin it here.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.85))
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Wishlist")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Text("\(store.wishlistProducts.count) item(s) saved")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 24)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(store.wishlistProducts) { product in
                                NavigationLink(
                                    destination: ProductDetailView(product: product)
                                ) {
                                    WishlistRow(product: product)
                                }
                                .pressable()
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: 700)
                        .frame(maxWidth: .infinity)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct WishlistRow: View {
    let product: Product
    @EnvironmentObject var store: StoreModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: product.imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))

                Text(product.price, format: .currency(code: "USD"))
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 11))
            }

            Spacer()

            if store.isAcquired(product) {
                Text("Owned")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .frostedPill(tint: .purple)
            }
        }
        .padding(10)
        .liquidGlass(cornerRadius: 14)
    }
}
