import SwiftUI

struct SettingsView: View {
    // MARK: - Environment / State

    @EnvironmentObject private var store: StoreModel
    @Environment(\.dismiss) private var dismiss

    /// Developer mode persisted across launches.
    @AppStorage("Aquire_developerUnlocked")
    private var developerUnlocked: Bool = false

    /// Global debug overlay toggle (shared with ContentView / DebugOverlay).
    @AppStorage("Aquire_debugOverlayEnabled")
    private var debugOverlayEnabled: Bool = false

    /// Basic session info.
    @AppStorage("Aquire_userEmail") private var storedEmail: String = ""
    @AppStorage("Aquire_isLoggedIn") private var isLoggedIn: Bool = true

    @State private var showingDebugPanel: Bool = false
    @State private var showingAdminPanel: Bool = false
    @State private var showingResetConfirm: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header

                ScrollView {
                    VStack(spacing: 18) {
                        accountSection
                        diagnosticsSection
                        dataSection
                        aboutSection
                    }
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 10)
        }
        .sheet(isPresented: $showingDebugPanel) {
            DebugPanelView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showingAdminPanel) {
            AdminPanelView()
                .environmentObject(store)
        }
        .alert("Reset all demo data?", isPresented: $showingResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAll()
            }
        } message: {
            Text("This clears acquired items, orders, wishlists, firmware versions, and admin flags. It does not affect your Apple ID or device.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Settings")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            // Spacer to keep title centered
            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    // MARK: - Sections

    private var accountSection: some View {
        SettingsSectionCard(title: "Account") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    SettingsIcon(systemName: "person.crop.circle.fill", tint: .purple)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(storedEmail.isEmpty ? "Signed in" : storedEmail)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Session is stored locally for this device.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()
                }

                Button(role: .destructive) {
                    isLoggedIn = false
                    storedEmail = ""
                    dismiss()
                } label: {
                    Text("Sign out")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                .padding(.top, 4)
            }
        }
    }

    private var diagnosticsSection: some View {
        SettingsSectionCard(title: "Diagnostics & Developer") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $debugOverlayEnabled) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "waveform.path.ecg", tint: .blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Debug overlay")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                            Text("Show live store state in the corner.")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 11))
                        }
                    }
                }
                Toggle(isOn: $debugOverlayEnabled) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "waveform.path.ecg", tint: .blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Debug overlay")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                            Text("Show live store state in the corner.")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 11))
                        }
                    }
                }
                #if !os(tvOS)
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                #endif
                Toggle(isOn: $developerUnlocked) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "terminal.fill", tint: .purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Developer mode")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                            Text("Unlock admin tools and extra panels.")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 11))
                        }
                    }
                }
                Toggle(isOn: $developerUnlocked) {
                    HStack(spacing: 10) {
                        SettingsIcon(systemName: "terminal.fill", tint: .purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Developer mode")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                            Text("Unlock admin tools and extra panels.")
                                .foregroundColor(.white.opacity(0.7))
                                .font(.system(size: 11))
                        }
                    }
                }
                #if !os(tvOS)
                .toggleStyle(SwitchToggleStyle(tint: .purple))
                #endif

                if developerUnlocked {
                    Divider().background(Color.white.opacity(0.1))

                    Button {
                        showingDebugPanel = true
                    } label: {
                        HStack(spacing: 10) {
                            SettingsIcon(systemName: "ladybug.fill", tint: .pink)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Open Debug Panel")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Inspect environment, flags, and device info.")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 11))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)

                    Button {
                        showingAdminPanel = true
                    } label: {
                        HStack(spacing: 10) {
                            SettingsIcon(systemName: "slider.horizontal.3", tint: .orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Admin panel")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Tune product visibility, badges, and featured item.")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 11))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var dataSection: some View {
        SettingsSectionCard(title: "Data & Inventory") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Wishlist")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 13))
                    Spacer()
                    Text("\(store.wishlistProducts.count)")
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold))
                }

                HStack {
                    Text("Acquired devices")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 13))
                    Spacer()
                    Text("\(store.acquiredProducts.count)")
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold))
                }

                HStack {
                    Text("Orders")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 13))
                    Spacer()
                    Text("\(store.orders.count)")
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold))
                }

                if store.totalSpent > 0 {
                    HStack {
                        Text("Simulated total spend")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 13))
                        Spacer()
                        Text(store.totalSpent, format: .currency(code: "USD"))
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .semibold))
                    }
                }

                Button(role: .destructive) {
                    showingResetConfirm = true
                } label: {
                    Text("Reset demo data")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(SecondaryGlassButtonStyle())
                .padding(.top, 6)
            }
        }
    }

    private var aboutSection: some View {
        SettingsSectionCard(title: "About Aquire") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    SettingsIcon(systemName: "sparkles", tint: .purple)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Aquire")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        Text(appVersionString)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))

                        Text("A prismatic hardware command surface built for Foundation devices.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
}

// MARK: - Reusable settings helpers

private struct SettingsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))

            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 0.9)
                    )
                    .shadow(color: Color.black.opacity(0.45),
                            radius: 14, x: 0, y: 10)
            )
        }
    }
}

private struct SettingsIcon: View {
    let systemName: String
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.2))

            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(tint)
        }
        .frame(width: 32, height: 32)
    }
}
