import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
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
                    .padding(12)
                    .transition(.opacity)
            }
        }
        .environmentObject(store)
    }

    // MARK: - Main Content by Platform

    @ViewBuilder
    private var mainContent: some View {
        #if os(iOS)
        iOSRoot
        #else
        macRoot
        #endif
    }

    // MARK: - iOS Root

    @ViewBuilder
    private var iOSRoot: some View {
        if isLoggedIn {
            IOSTabRootView(userEmail: storedEmail)
        } else {
            LoginView(isLoggedIn: $isLoggedIn,
                      storedEmail: $storedEmail)
        }
    }

    // MARK: - macOS Root

    @ViewBuilder
    private var macRoot: some View {
        if isLoggedIn {
            MacTabRootView(userEmail: storedEmail)
        } else {
            LoginView(isLoggedIn: $isLoggedIn,
                      storedEmail: $storedEmail)
        }
    }
}

// MARK: - iOS Tab Root

@available(iOS 15.0, *)
struct IOSTabRootView: View {
    let userEmail: String
    @EnvironmentObject private var store: StoreModel

    var body: some View {
        TabView {
            HomeView(userEmail: userEmail)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Featured")
                }

            InfoView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Info")
                }

            BrowseView(products: store.visibleProducts)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }

            WishlistView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Wishlist")
                }

            AcquiredView()
                .tabItem {
                    Image(systemName: "shippingbox.fill")
                    Text("Acquired")
                }

            OrdersTabWrapper()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Orders")
                }
        }
        .accentColor(.pink)
    }
}

// MARK: - macOS Tab Root

@available(macOS 12.0, *)
struct MacTabRootView: View {
    let userEmail: String
    @EnvironmentObject private var store: StoreModel

    var body: some View {
        TabView {
            HomeView(userEmail: userEmail)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Featured")
                }

            InfoView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("Info")
                }

            BrowseView(products: store.visibleProducts)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }

            WishlistView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Wishlist")
                }

            AcquiredView()
                .tabItem {
                    Image(systemName: "shippingbox.fill")
                    Text("Acquired")
                }

            OrdersTabWrapper()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Orders")
                }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

// MARK: - Orders Wrapper (for macOS availability)

struct OrdersTabWrapper: View {
    var body: some View {
        #if os(macOS)
        if #available(macOS 13.0, *) {
            OrdersView()
        } else {
            ZStack {
                AquireBackgroundView()
                Text("Orders view requires macOS 13 or later.")
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
        }
        #else
        // iOS: always allowed
        OrdersView()
        #endif
    }
}
