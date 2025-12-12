import SwiftUI

// tvOS: simple placeholder – real admin tools are iOS/macOS only for now.
#if os(tvOS)

struct AdminPanelView: View {
    var body: some View {
        ZStack {
            AquireBackgroundView().ignoresSafeArea()
            Text("Admin Panel isn’t available on tvOS yet.")
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#else

@available(macOS 13.0, iOS 15.0, *)
struct AdminPanelView: View {
    @EnvironmentObject var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: Product?

    /// In a real app this would be fetched from a backend.
    /// For now we use the global `products` constant.
    private var allProducts: [Product] {
        products
    }

    var body: some View {
        NavigationView {
            ZStack {
                AquireBackgroundView()
                    .ignoresSafeArea()

                List {
                    productsSection
                    summarySection
                }
                .environment(\.defaultMinListRowHeight, 36)
                #if os(iOS)
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                #else
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                #endif
            }
            .navigationTitle("Admin Panel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $selectedProduct) { product in
                ProductAdminDetailView(product: product)
                    .environmentObject(store)
            }
        }
    }

    // MARK: - Sections

    private var productsSection: some View {
        Section("Products") {
            ForEach(allProducts) { product in
                Button {
                    selectedProduct = product
                } label: {
                    productRow(for: product)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.black)
            }
        }
    }

    private var summarySection: some View {
        Section("Summary") {
            HStack {
                Text("Visible")
                Spacer()
                Text("\(store.visibleProducts.count)")
                    .foregroundColor(.white.opacity(0.7))
            }
            HStack {
                Text("Wishlist")
                Spacer()
                Text("\(store.wishlistProducts.count)")
                    .foregroundColor(.white.opacity(0.7))
            }
            HStack {
                Text("Acquired")
                Spacer()
                Text("\(store.acquiredProducts.count)")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Row

    private func productRow(for product: Product) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.9))
                Image(systemName: product.imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.accentColor)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(product.name)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))

                    if store.isHidden(product) {
                        TagPill(text: "HIDDEN", tint: .red)
                    }

                    if let badge = store.badge(for: product) {
                        TagPill(text: badge.uppercased(),
                                tint: Color.purple.opacity(0.9))
                    }

                    if store.featuredProduct?.id == product.id {
                        TagPill(text: "FEATURED",
                                tint: Color.blue.opacity(0.9))
                    }
                }

                Text(product.category)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Text(product.price, format: .currency(code: "USD"))
                .foregroundColor(.white.opacity(0.8))
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail Sheet

struct ProductAdminDetailView: View {
    let product: Product

    @EnvironmentObject var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    @State private var isFeatured: Bool = false
    @State private var isHidden: Bool = false
    @State private var badgeText: String = ""

    var body: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                header

                VStack(alignment: .leading, spacing: 16) {
                    Toggle("Mark as Featured", isOn: $isFeatured)
                        .toggleStyle(.switch)
                        .tint(.purple)

                    Toggle("Hide from Browse", isOn: $isHidden)
                        .toggleStyle(.switch)
                        .tint(.purple)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Badge Label")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        TextField("e.g. LABS, PROTOTYPE, BETA", text: $badgeText)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                            )
                    }
                }

                Spacer()

                HStack {
                    Button("Discard") {
                        dismiss()
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())

                    Spacer()

                    Button("Apply Changes") {
                        applyChanges()
                        dismiss()
                    }
                    .buttonStyle(PrimaryGlassButtonStyle())
                }
            }
            .padding(20)
            .onAppear {
                loadCurrentValues()
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.9))
                Image(systemName: product.imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(.accentColor)
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Text(product.category)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
    }

    private func loadCurrentValues() {
        if let currentFeatured = store.featuredProduct,
           currentFeatured.id == product.id {
            isFeatured = true
        } else {
            isFeatured = false
        }

        isHidden = store.isHidden(product)
        badgeText = store.badge(for: product) ?? ""
    }

    private func applyChanges() {
        if isFeatured {
            store.setFeatured(product)
        } else if store.featuredProduct?.id == product.id {
            // crude “unfeature” by clearing featured product
            store.setFeatured(nil)
        }

        store.setHidden(isHidden, for: product)
        store.setBadge(
            badgeText.trimmingCharacters(in: .whitespacesAndNewlines),
            for: product
        )
    }
}

#endif
