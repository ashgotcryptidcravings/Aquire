import SwiftUI

struct BrowseView: View {
    let products: [Product]
    @EnvironmentObject var store: StoreModel

    @State private var searchText: String = ""
    @State private var selectedProduct: Product?   // macOS sheet

    // 2-column grid
    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]

    private var filteredProducts: [Product] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return products }

        let query = trimmed.lowercased()
        return products.filter {
            $0.name.lowercased().contains(query) ||
            $0.category.lowercased().contains(query)
        }
    }

    var body: some View {
        #if os(iOS)
        iOSBody
        #else
        macOSBody
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(product: product, showsCloseButton: true)
                    .environmentObject(store)
            }
        #endif
    }

    // MARK: - Shared header

    @ViewBuilder
    private func header(title: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

                Text("Explore devices, wearables, and more.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - macOS

    private var macOSBody: some View {
        ZStack {
            AquireBackgroundView()

            VStack(spacing: 18) {
                header(title: "Browse")

                macOSSearchBar

                macOSGridContent

                Spacer(minLength: 0)
            }
        }
    }

    private var macOSSearchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.75))

            TextField("Search devices, wearables…", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .medium))

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(PressableScaleStyle(scaleAmount: 0.9))
            }

            Spacer().frame(width: 24)
        }
        .padding(.horizontal, 24)
    }

    private var macOSGridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(filteredProducts) { product in
                    Button {
                        selectedProduct = product
                    } label: {
                        BrowseCard(product: product)
                    }
                    .buttonStyle(PressableScaleStyle(scaleAmount: 0.96))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: 960)
            .frame(maxWidth: .infinity)
        }
    }
}

#if os(iOS)
// MARK: - iOS body + search / grid

extension BrowseView {
    private var iOSBody: some View {
        NavigationView {
            ZStack {
                AquireBackgroundView()

                VStack(spacing: 18) {
                    header(title: "Browse")

                    searchBar

                    iOSGridContent
                }
                .padding(.bottom, 16)
            }
            // We’re doing our own header, so hide the system one on iOS.
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))

            TextField("Search devices, wearables…", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                // iOS-only text input tweaks
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(PressableScaleStyle(scaleAmount: 0.92))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }

    private var iOSGridContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(filteredProducts) { product in
                    NavigationLink(
                        destination: ProductDetailView(product: product)
                    ) {
                        BrowseCard(product: product)
                    }
                    .buttonStyle(PressableScaleStyle(scaleAmount: 0.94))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .frame(maxWidth: 820)          // keep it nicely centered
            .frame(maxWidth: .infinity)    // center in window
        }
    }
}
#endif

// MARK: - Card

struct BrowseCard: View {
    let product: Product
    @EnvironmentObject var store: StoreModel

    private var hasModel: Bool {
        product.modelName != nil
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.03))

                // Icon
                Image(systemName: product.imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 54, height: 54)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.purple.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(18)

                if hasModel {
                    MicroBadge(label: "3D")
                        .padding(8)
                }
            }

            VStack(spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(product.price, format: .currency(code: "USD"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(12)
        .liquidGlass(cornerRadius: 20)
    }
}

// MARK: - Micro badge

struct MicroBadge: View {
    let label: String

    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 9, weight: .semibold, design: .rounded))
            .tracking(0.6)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .foregroundColor(.white.opacity(0.95))
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.black.opacity(0.55))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.white.opacity(0.45), lineWidth: 0.9)
                    )
            )
    }
}
