import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
struct HomeView: View {
    let userEmail: String

    @EnvironmentObject private var store: StoreModel

    @AppStorage("Aquire_developerUnlocked")
    private var developerUnlocked: Bool = false

    @State private var showSettings: Bool = false
    @State private var selectedProduct: Product?
    @State private var secretTapCount: Int = 0

    // MARK: - Derived

    private var featuredProduct: Product? {
        if let featured = store.featuredProduct {
            return featured
        } else if let firstVisible = store.visibleProducts.first {
            return firstVisible
        } else {
            return products.first
        }
    }

    private var highlightProducts: [Product] {
        let base = store.visibleProducts.isEmpty ? products : store.visibleProducts
        return Array(base.prefix(10))
    }

    private var acquiredCount: Int { store.acquiredProducts.count }
    private var wishlistCount: Int { store.wishlistProducts.count }
    private var ordersCount: Int { store.orders.count }

    // MARK: - Body

    var body: some View {
        #if os(tvOS)
        tvOSBody
        #else
        standardBody
        #endif
    }

    // MARK: - iOS / macOS body

    private var standardBody: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    if let hero = featuredProduct {
                        ProductCard(product: hero)
                            .onTapGesture {
                                selectedProduct = hero
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Featured device: \(hero.name)")
                    }

                    summaryRow

                    if !highlightProducts.isEmpty {
                        Text("Up next from Foundation")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(highlightProducts, id: \.id) { product in
                                    miniProductTile(product)
                                        .onTapGesture {
                                            selectedProduct = product
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(store)
        }
    }

    // MARK: - tvOS body

    private var tvOSBody: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 32) {
                tvOSHeader

                if let hero = featuredProduct {
                    Button {
                        selectedProduct = hero
                    } label: {
                        ProductCard(product: hero)
                            .frame(maxWidth: 800)
                            .frame(height: 360)
                    }
                    .buttonStyle(.plain)
                }

                tvOSSummaryRow

                if !highlightProducts.isEmpty {
                    Text("Browse Devices")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.leading, 60)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 40) {
                            ForEach(highlightProducts, id: \.id) { product in
                                Button {
                                    selectedProduct = product
                                } label: {
                                    tvOSMiniTile(product)
                                }
                                .buttonStyle(.plain)
                                .focusable(true)
                            }
                        }
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                    }
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(product: product)
                .environmentObject(store)
        }
    }

    // MARK: - Shared pieces (header, stats, tiles)

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Foundation Aquire")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(userEmail.isEmpty ? "Guest session" : userEmail)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            Button {
                incrementSecretTap()
                showSettings = true
            } label: {
                HStack(spacing: 6) {
                    if developerUnlocked {
                        StatusChip(text: "DEV", style: .accent)
                    }

                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.8)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var tvOSHeader: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Foundation Aquire")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text("Living room device surface")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button {
                incrementSecretTap()
                showSettings = true
            } label: {
                HStack(spacing: 8) {
                    if developerUnlocked {
                        StatusChip(text: "DEV", style: .accent)
                    }

                    Image(systemName: "gearshape.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 40)
        }
        .padding(.leading, 40)
        .padding(.top, 40)
    }

    private func incrementSecretTap() {
        secretTapCount += 1
        if secretTapCount >= 7 {
            developerUnlocked.toggle()
            secretTapCount = 0
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            statChip(title: "Wishlist", value: "\(wishlistCount)", icon: "heart.fill")
            statChip(title: "Acquired", value: "\(acquiredCount)", icon: "shippingbox.fill")
            statChip(title: "Orders", value: "\(ordersCount)", icon: "list.bullet.rectangle")
        }
    }

    private var tvOSSummaryRow: some View {
        HStack(spacing: 24) {
            tvOSStatTile(title: "Wishlist", value: "\(wishlistCount)", icon: "heart.fill")
            tvOSStatTile(title: "Acquired", value: "\(acquiredCount)", icon: "shippingbox.fill")
            tvOSStatTile(title: "Orders", value: "\(ordersCount)", icon: "list.bullet.rectangle")
        }
        .padding(.horizontal, 60)
    }

    private func statChip(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))

                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 18)
    }

    private func tvOSStatTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
            }

            Text(value)
                .font(.title.weight(.bold))
                .foregroundColor(.white)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 26)
    }

    private func miniProductTile(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.black.opacity(0.7))

                    Image(systemName: product.imageSystemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(.accentColor)
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(product.price, format: .currency(code: "USD"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .liquidGlass(cornerRadius: 20)
    }

    private func tvOSMiniTile(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.black.opacity(0.7))

                Image(systemName: product.imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.accentColor)
            }
            .frame(width: 160, height: 160)

            Text(product.name)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)

            Text(product.price, format: .currency(code: "USD"))
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 200)
        .padding(16)
        .liquidGlass(cornerRadius: 28)
    }
}
