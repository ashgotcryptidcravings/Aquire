import SwiftUI
#if os(iOS)
import UIKit
#endif

struct DebugPanelView: View {
    @EnvironmentObject var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    // Same keys used in ContentView / SettingsView / HomeView
    @AppStorage("Aquire_userEmail") private var storedEmail: String = ""
    @AppStorage("Aquire_developerUnlocked") private var developerUnlocked: Bool = false
    @AppStorage("Aquire_debugOverlayEnabled") private var debugOverlayEnabled: Bool = false

    // MARK: - Device Info (iOS)

    #if os(iOS)
    private var deviceName: String { UIDevice.current.name }
    private var deviceModel: String { UIDevice.current.model }          // e.g. "iPhone"
    private var systemVersion: String { UIDevice.current.systemVersion } // e.g. "18.2"
    #else
    private var deviceName: String { "Unknown Device" }
    private var deviceModel: String { "Unknown" }
    private var systemVersion: String { "-" }
    #endif

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Debug Panel")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    // spacer to keep title centered
                    Color.clear
                        .frame(width: 22, height: 22)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider().background(Color.white.opacity(0.1))

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {

                        // MARK: Device section
                        sectionHeader("DEVICE")
                        debugCard {
                            debugRow(label: "Name", value: deviceName)
                            debugRow(label: "Model", value: deviceModel)
                            debugRow(label: "System", value: "iOS \(systemVersion)")
                        }

                        // MARK: Account / store section
                        sectionHeader("SESSION")
                        debugCard {
                            let emailDisplay = storedEmail.isEmpty ? "Demo account" : storedEmail

                            debugRow(label: "Signed in as", value: emailDisplay)
                            debugRow(label: "Acquired items",
                                     value: "\(store.acquiredProducts.count)")
                            debugRow(label: "Wishlist items",
                                     value: "\(store.wishlistProducts.count)")
                            debugRow(label: "Orders",
                                     value: "\(store.orders.count)")
                        }

                        // MARK: Developer toggles
                        sectionHeader("DEVELOPER")
                        debugCard {
                            Toggle("Developer Mode", isOn: $developerUnlocked)
                                .tint(.purple)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)

                            Toggle("Debug Overlay", isOn: $debugOverlayEnabled)
                                .tint(.purple)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)

                            Button {
                                store.resetAll()
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Reset Demo Data")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    // MARK: - Small helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .foregroundColor(.purple.opacity(0.9))
            .padding(.horizontal, 4)
    }

    private func debugCard<Content: View>(
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.08))
        )
    }

    private func debugRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 13))

            Spacer()

            Text(value)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .medium))
                .multilineTextAlignment(.trailing)
        }
    }
}
