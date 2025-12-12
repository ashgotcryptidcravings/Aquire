import SwiftUI

// MARK: - Product Detail + Checkout

struct ProductDetailView: View {
    let product: Product
    var showsCloseButton: Bool = false      // for macOS sheets

    @EnvironmentObject private var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingCheckout = false
    @State private var showingModel = false
    @State private var isUpdatingFirmware = false

    // MARK: - Derived

    private var hasModel: Bool { product.modelName != nil }
    private var isOwned: Bool { store.isAcquired(product) }
    private var isWishlisted: Bool { store.isWishlisted(product) }
    private var firmwareVersion: Int { store.currentFirmware(for: product) }

    var body: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView {
                    VStack(spacing: 24) {
                        heroCard
                        actionRow
                        detailsSection
                        statusSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .frame(maxWidth: 820)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView(product: product)
                .environmentObject(store)
        }
        // 3D Model sheet – iOS-only to avoid tvOS/macOS compile errors
        #if os(iOS)
        .sheet(isPresented: $showingModel) {
            if let modelName = product.modelName,
               let url = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
                ModelQuickLookView(url: url)
            } else {
                ZStack {
                    AquireBackgroundView().ignoresSafeArea()
                    Text("3D model not available.")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        #endif
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 14) {
            if showsCloseButton {
                IconGlassButton(systemName: "xmark") {
                    dismiss()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(product.category)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            if hasModel {
                StatusChip(text: "3D Model", style: .accent)
            }

            StatusChip(
                text: isOwned ? "Owned" : "Available",
                style: isOwned ? .accent : .neutral
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Hero card

    private var heroCard: some View {
        glassCard {
            HStack(alignment: .top, spacing: 18) {
                ZstackIcon

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(product.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)

                        Spacer(minLength: 12)

                        Text(product.price, format: .currency(code: "USD"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(product.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(4)
                }
            }
        }
    }

    private var ZstackIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.black.opacity(0.7))

            Image(systemName: product.imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundColor(.accentColor)
        }
        .frame(width: 120, height: 120)
    }

    // MARK: - Action row

    private var actionRow: some View {
        HStack(spacing: 14) {
            Button {
                if !isOwned {
                    showingCheckout = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isOwned ? "checkmark.circle.fill" : "cart.fill.badge.plus")
                    Text(isOwned ? "Purchased" : "Get with Aquire")
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryGlassButtonStyle())
            .disabled(isOwned)

            Button {
                store.toggleWishlist(for: product)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isWishlisted ? "heart.fill" : "heart")
                    Text(isWishlisted ? "In wishlist" : "Add to wishlist")
                }
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryGlassButtonStyle())
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Details")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(product.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
    }

    // MARK: - Status / firmware

    private var statusSection: some View {
        glassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Status & firmware")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                HStack {
                    Text(isOwned ? "Owned" : "Not owned")
                    Circle()
                        .fill(isOwned ? Color.green : Color.gray)
                        .frame(width: 6, height: 6)
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

                HStack {
                    Text("Firmware")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("v\(firmwareVersion)")
                        .foregroundColor(.white)
                }
                .font(.system(size: 13, weight: .medium))

                if isOwned {
                    Button {
                        Task {
                            guard !isUpdatingFirmware else { return }
                            isUpdatingFirmware = true
                            try? await Task.sleep(nanoseconds: 900_000_000)
                            store.updateFirmware(for: product)
                            isUpdatingFirmware = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isUpdatingFirmware {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }

                            Text(isUpdatingFirmware ? "Updating..." : "Update firmware")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                }
            }
        }
    }

    // MARK: - Glass card helper

    private func glassCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.45),
                            radius: 16, x: 0, y: 10)
            )
    }
}

// MARK: - Checkout Sheet

struct CheckoutView: View {
    let product: Product

    @EnvironmentObject private var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    @State private var isProcessing = false

    var body: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Confirm Purchase")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    IconGlassButton(systemName: "xmark") {
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Summary card
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.black.opacity(0.75))
                            Image(systemName: product.imageSystemName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.accentColor)
                        }
                        .frame(width: 72, height: 72)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                            Text(product.price, format: .currency(code: "USD"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()
                    }

                    Text("You’ll see this in Acquired and Orders as soon as checkout finishes.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.45),
                                radius: 16, x: 0, y: 10)
                )
                .padding(.horizontal, 24)

                // Apple Pay + cancel
                VStack(spacing: 14) {
                    ApplePayButton {
                        handleApplePay()
                    }
                    .frame(height: 50)
                    .disabled(isProcessing)
                    .opacity(isProcessing ? 0.6 : 1.0)

                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(SecondaryGlassButtonStyle())
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func handleApplePay() {
        guard !isProcessing else { return }
        isProcessing = true

        // Simulate a short payment process, then update store.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            store.addOne(product)
            store.createOrder(for: product)
            isProcessing = false
            dismiss()
        }
    }
}

// MARK: - Button Styles

struct PrimaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple,
                                Color(red: 0.9, green: 0.45, blue: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 0.9)
                    )
            )
            .shadow(color: Color.purple.opacity(0.6),
                    radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(
                .spring(response: 0.2, dampingFraction: 0.8),
                value: configuration.isPressed
            )
    }
}

struct SecondaryGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white.opacity(0.9))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.28), lineWidth: 0.9)
                    )
            )
            .shadow(color: Color.black.opacity(0.5),
                    radius: 10, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.22, dampingFraction: 0.85),
                value: configuration.isPressed
            )
    }
}
