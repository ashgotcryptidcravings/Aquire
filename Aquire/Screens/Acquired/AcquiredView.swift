import SwiftUI

struct AcquiredView: View {
    @EnvironmentObject var store: StoreModel

    @State private var selectedProduct: Product?

    var body: some View {
        #if os(iOS)
        iOSBody
        #else
        macOSBody
        #endif
    }

    // MARK: - iOS Body

    private var iOSBody: some View {
        NavigationView {
            ZStack {
                AquireBackgroundView()

                if store.acquiredProducts.isEmpty {
                    Text("No items acquired yet.\nBrowse the store to begin.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.85))
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.acquiredProducts) { product in
                                iOSRow(for: product)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Acquired")
        }
        .sheet(item: $selectedProduct) { product in
            PurchaseInfoView(product: product)
                .environmentObject(store)
        }
    }

    // MARK: - macOS Body

    private var macOSBody: some View {
        ZStack {
            AquireBackgroundView()

            if store.acquiredProducts.isEmpty {
                Text("No items acquired yet.\nBrowse the store to begin.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.85))
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Acquired")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Text("Devices and modules you’ve already brought into your Foundation stack.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 24)

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.acquiredProducts) { product in
                                macOSRow(for: product)
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
        .sheet(item: $selectedProduct) { product in
            PurchaseInfoView(product: product)
                .environmentObject(store)
        }
    }

    // MARK: - Rows

    private func iOSRow(for product: Product) -> some View {
        Button {
            selectedProduct = product
        } label: {
            HStack {
                Image(systemName: product.imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))

                    Text("Qty: \(store.quantity(for: product))")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 12))

                    if let order = store.lastOrder(for: product) {
                        Text(order.status.displayName)
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 11))
                    }
                }

                Spacer()
            }
            .padding()
            .liquidGlass(cornerRadius: 18)
        }
        .pressable()
    }

    private func macOSRow(for product: Product) -> some View {
        Button {
            selectedProduct = product
        } label: {
            HStack(spacing: 12) {
                Image(systemName: product.imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.purple)

                VStack(alignment: .leading, spacing: 3) {
                    Text(product.name)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))

                    Text("Qty: \(store.quantity(for: product))")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 11))

                    if let order = store.lastOrder(for: product) {
                        Text(order.status.displayName)
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 11))
                    }
                }

                Spacer()
            }
            .padding(10)
            .liquidGlass(cornerRadius: 18)
        }
        .pressable()
    }
}

// MARK: - Purchase Info Sheet

import SwiftUI

struct PurchaseInfoView: View {
    let product: Product

    @EnvironmentObject var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    @State private var isUpdatingFirmware = false

    // Most recent order for this product, if any
    private var latestOrder: Order? {
        store.lastOrder(for: product)
    }

    private var currentFirmwareLabel: String {
        "Firmware \(store.currentFirmware(for: product))"
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.96)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // Top bar
                HStack {
                    Text(product.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                }

                // Main info card
                HStack(alignment: .top, spacing: 20) {
                    // Icon block
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            Image(systemName: product.imageSystemName)
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.purple)
                        )
                        .frame(width: 120, height: 120)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(product.category.uppercased())
                            .font(.caption2)
                            .foregroundColor(.purple.opacity(0.9))

                        Text(product.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        Text(product.description)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(3)

                        if let order = latestOrder {
                            HStack(spacing: 8) {
                                StatusPill(status: order.status)

                                Text(formatted(order.date))
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        } else {
                            Text("No order history found (demo only).")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }

                        Text("Owned: \(store.quantity(for: product))")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 4)
                    }

                    Spacer()
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 20)

                // Firmware feature panel
                firmwarePanel

                Spacer()
            }
            .padding(28)
        }
    }

    // MARK: - Firmware Panel

    private var firmwarePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Firmware")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.9))

                    Text(currentFirmwareLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                Spacer()

                if isUpdatingFirmware {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Updating…")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.85))
                    .transition(.opacity.combined(with: .scale))
                } else {
                    Button {
                        startFirmwareUpdate()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            Text("Check for Update")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 16, x: 0, y: 10)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale))
                }
            }

            Text("Demo updater: bumps the firmware version and gives you a little XP when you tap it.")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    // MARK: - Actions

    private func startFirmwareUpdate() {
        guard !isUpdatingFirmware else { return }

        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            isUpdatingFirmware = true
        }

        // Fake delay so it feels like a real update
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            store.updateFirmware(for: product)

            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                isUpdatingFirmware = false
            }
        }
    }

    // MARK: - Helpers

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
