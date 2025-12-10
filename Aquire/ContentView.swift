import SwiftUI

struct ContentView: View {
    @StateObject private var store = StoreModel()

    @AppStorage("Aquire_isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("Aquire_userEmail") private var storedEmail: String = ""
    @AppStorage("Aquire_debugOverlayEnabled") private var debugOverlayEnabled: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            mainContent

            if debugOverlayEnabled {
                DebugOverlay()
                    .transition(.opacity)
                    .padding()
            }

            debugToggleButton
        }
        .environmentObject(store)
    }

    // MARK: - Main content switch

    @ViewBuilder
    private var mainContent: some View {
        if isLoggedIn {
            #if os(iOS)
            IOSTabRootView(userEmail: storedEmail)
            #else
            MacRootView(userEmail: storedEmail)
            #endif
        } else {
            LoginView(isLoggedIn: $isLoggedIn, storedEmail: $storedEmail)
        }
    }

    // MARK: - Debug toggle

    private var debugToggleButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                debugOverlayEnabled.toggle()
            }
        } label: {
            Image(systemName: debugOverlayEnabled ? "ladybug.fill" : "ladybug")
                .font(.system(size: 16, weight: .semibold))
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(radius: 6)
                .padding()
        }
    }
}

#if os(iOS)
// MARK: - iOS: Custom floating tab root

struct IOSTabRootView: View {
    let userEmail: String
    @EnvironmentObject var store: StoreModel

    // Tabs for iOS – mirrors macOS cases
    enum Tab: String, CaseIterable, Identifiable {
        case featured
        case info
        case browse
        case wishlist
        case acquired
        case orders

        var id: String { rawValue }

        var title: String {
            switch self {
            case .featured: return "Featured"
            case .info:     return "Info"
            case .browse:   return "Browse"
            case .wishlist: return "Wishlist"
            case .acquired: return "Acquired"
            case .orders:   return "Orders"
            }
        }

        var systemImage: String {
            switch self {
            case .featured: return "star.fill"
            case .info:     return "info.circle"
            case .browse:   return "square.grid.2x2"
            case .wishlist: return "heart"
            case .acquired: return "shippingbox.fill"
            case .orders:   return "list.bullet.rectangle.portrait"
            }
        }
    }

    @State private var selectedTab: Tab = .featured

    var body: some View {
        ZStack(alignment: .bottom) {
            // Active tab content
            Group {
                switch selectedTab {
                case .featured:
                    HomeView(userEmail: userEmail)

                case .info:
                    InfoView(userEmail: userEmail)

                case .browse:
                    BrowseView(products: store.visibleProducts)

                case .wishlist:
                    WishlistView()

                case .acquired:
                    AcquiredView()

                case .orders:
                    OrdersView()
                }
            }
            .ignoresSafeArea(edges: .bottom)

            // Floating glass tab bar
            FloatingTabBar(selection: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
    }
}

/// Glassy, OS-18-style floating tab bar.
struct FloatingTabBar: View {
    @Binding var selection: IOSTabRootView.Tab

    private let tabs = IOSTabRootView.Tab.allCases

    var body: some View {
        HStack(spacing: 14) {
            ForEach(tabs) { tab in
                button(for: tab)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.05),
                                    Color.purple.opacity(0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.55),
                        radius: 22, x: 0, y: 12)
        )
    }

    private func button(for tab: IOSTabRootView.Tab) -> some View {
        let isSelected = (tab == selection)

        return Button {
            withAnimation(AquireMotion.tap) {
                selection = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 15, weight: .semibold))

                if isSelected {
                    Text(tab.title)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .padding(.horizontal, isSelected ? 12 : 10)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .background(
                Group {
                    if isSelected {
                        Capsule()
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
                                Capsule()
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                            )
                    } else {
                        Capsule()
                            .fill(Color.white.opacity(0.04))
                    }
                }
            )
            .shadow(color: isSelected ? Color.purple.opacity(0.6) : .clear,
                    radius: 10, x: 0, y: 6)
        }
        .buttonStyle(PressableScaleStyle(scaleAmount: 0.9))
    }
}
#endif

// MARK: - macOS: Sidebar root (unchanged, just kept here)

#if os(macOS)
@available(macOS 12.0, *)
struct MacRootView: View {
    let userEmail: String
    @EnvironmentObject var store: StoreModel

    @State private var selection: Tab? = .featured

    enum Tab: String, CaseIterable, Identifiable {
        case featured
        case info
        case browse
        case wishlist
        case acquired
        case orders

        var id: String { rawValue }

        var title: String {
            switch self {
            case .featured: return "Featured"
            case .info:     return "Info"
            case .browse:   return "Browse"
            case .wishlist: return "Wishlist"
            case .acquired: return "Acquired"
            case .orders:   return "Orders"
            }
        }

        var systemImage: String {
            switch self {
            case .featured: return "star.fill"
            case .info:     return "info.circle"
            case .browse:   return "square.grid.2x2"
            case .wishlist: return "heart"
            case .acquired: return "shippingbox.fill"
            case .orders:   return "list.bullet.rectangle.portrait"
            }
        }
    }

    var body: some View {
        NavigationView {
            sidebar
            contentArea
        }
        .navigationTitle("")
    }

    private var sidebar: some View {
        List(selection: $selection) {
            ForEach(Tab.allCases) { tab in
                HStack(spacing: 8) {
                    Image(systemName: tab.systemImage)
                    Text(tab.title)
                }
                .tag(tab as Tab?)
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
    }

    @ViewBuilder
    private var contentArea: some View {
        switch selection ?? .featured {
        case .featured:
            HomeView(userEmail: userEmail)

        case .info:
            InfoView(userEmail: userEmail)

        case .browse:
            BrowseView(products: store.visibleProducts)

        case .wishlist:
            WishlistView()

        case .acquired:
            AcquiredView()

        case .orders:
            if #available(macOS 13.0, *) {
                OrdersView()
            } else {
                VStack {
                    Text("Orders view requires macOS 13 or later.")
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                    Spacer()
                }
            }
        }
    }
}
#endif
