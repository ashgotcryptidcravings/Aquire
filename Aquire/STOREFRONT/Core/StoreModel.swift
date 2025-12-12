import Foundation
import SwiftUI

@MainActor
final class StoreModel: ObservableObject {
    // MARK: - Core state (keyed by product name)

    /// product.name -> quantity
    @Published private(set) var acquired: [String: Int] = [:]

    /// All orders (product is resolved from the global `products` list)
    @Published private(set) var orders: [Order] = []

    /// product.name of wishlisted products
    @Published private(set) var wishlist: Set<String> = []

    /// product.name -> firmware version (starting at 1)
    @Published private(set) var firmwareVersions: [String: Int] = [:]

    // MARK: - Admin state

    /// product.name of the featured product (if any)
    @Published private(set) var featuredProductKey: String?

    /// Hidden products (by name)
    @Published private(set) var hiddenProductKeys: Set<String> = []

    /// product.name -> badge text (e.g. "LABS", "BETA")
    @Published private(set) var badgeLabels: [String: String] = [:]

    // MARK: - Persistence keys

    private struct Keys {
        static let localSnapshot = "Aquire_Store_Snapshot_v1"
        static let ubiquitousSnapshot = "Aquire_Store_Snapshot_Ubiq_v1"
    }

    private var ubiquitousObserver: NSObjectProtocol?

    // MARK: - Init

    init() {
        loadFromPersistentStorage()
        setupUbiquitousObserver()
    }

    deinit {
        if let observer = ubiquitousObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Public computed properties

    /// Products the user has at least 1 of.
    var acquiredProducts: [Product] {
        products.filter { quantity(for: $0) > 0 }
    }

    /// Products the user has wishlisted.
    var wishlistProducts: [Product] {
        products.filter { isWishlisted($0) }
    }

    /// Products that are not marked hidden.
    var visibleProducts: [Product] {
        products.filter { !isHidden($0) }
    }

    /// The currently featured product, if any.
    var featuredProduct: Product? {
        guard let key = featuredProductKey else { return nil }
        return product(forKey: key)
    }

    /// Simple "money spent" metric based on all orders.
    var totalSpent: Double {
        orders.reduce(0) { $0 + $1.product.price }
    }

    // MARK: - Lookup helpers

    private func key(for product: Product) -> String {
        product.name
    }

    private func product(forKey key: String) -> Product? {
        products.first(where: { $0.name == key })
    }

    // MARK: - Acquisition / inventory

    func isAcquired(_ product: Product) -> Bool {
        quantity(for: product) > 0
    }

    func quantity(for product: Product) -> Int {
        acquired[key(for: product), default: 0]
    }

    func addOne(_ product: Product) {
        let k = key(for: product)
        acquired[k, default: 0] += 1
        awardXP(10)
        persist()
    }

    func removeAll(_ product: Product) {
        let k = key(for: product)
        acquired[k] = nil
        persist()
    }

    // MARK: - Wishlist

    func isWishlisted(_ product: Product) -> Bool {
        wishlist.contains(key(for: product))
    }

    func toggleWishlist(for product: Product) {
        let k = key(for: product)
        if wishlist.contains(k) {
            wishlist.remove(k)
        } else {
            wishlist.insert(k)
            awardXP(2)
        }
        persist()
    }

    // MARK: - Firmware

    func currentFirmware(for product: Product) -> Int {
        firmwareVersions[key(for: product)] ?? 1
    }

    func updateFirmware(for product: Product) {
        let k = key(for: product)
        let current = firmwareVersions[k] ?? 1
        firmwareVersions[k] = current + 1
        persist()
    }

    // MARK: - Orders

    func createOrder(for product: Product) {
        let order = Order(product: product, date: Date(), status: .processing)
        // Put newest first
        orders.insert(order, at: 0)
        persist()
    }

    func lastOrder(for product: Product) -> Order? {
        orders.first(where: { $0.product.name == product.name })
    }

    // MARK: - Admin: featured / hidden / badges

    func setFeatured(_ product: Product?) {
        featuredProductKey = product.map { key(for: $0) }
        persist()
    }

    func isHidden(_ product: Product) -> Bool {
        hiddenProductKeys.contains(key(for: product))
    }

    func setHidden(_ hidden: Bool, for product: Product) {
        let k = key(for: product)
        if hidden {
            hiddenProductKeys.insert(k)
        } else {
            hiddenProductKeys.remove(k)
        }
        persist()
    }

    func badge(for product: Product) -> String? {
        badgeLabels[key(for: product)]
    }

    func setBadge(_ label: String?, for product: Product) {
        let k = key(for: product)
        let cleaned = label?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let cleaned, !cleaned.isEmpty {
            badgeLabels[k] = cleaned
        } else {
            badgeLabels[k] = nil
        }
        persist()
    }

    // MARK: - Debug / reset

    func resetAll() {
        acquired.removeAll()
        orders.removeAll()
        wishlist.removeAll()
        firmwareVersions.removeAll()
        featuredProductKey = nil
        hiddenProductKeys.removeAll()
        badgeLabels.removeAll()
        persist()
    }

    // MARK: - Persistence + sync

    private struct Snapshot: Codable {
        var acquired: [String: Int]
        var wishlist: [String]
        var firmwareVersions: [String: Int]
        var orders: [OrderRecord]
        var featuredProductKey: String?
        var hiddenProductKeys: [String]
        var badgeLabels: [String: String]
    }

    private struct OrderRecord: Codable {
        var productName: String
        var date: Date
        var statusRaw: String
    }

    private func makeSnapshot() -> Snapshot {
        let orderRecords: [OrderRecord] = orders.map {
            OrderRecord(
                productName: $0.product.name,
                date: $0.date,
                statusRaw: $0.status.rawValue
            )
        }

        return Snapshot(
            acquired: acquired,
            wishlist: Array(wishlist),
            firmwareVersions: firmwareVersions,
            orders: orderRecords,
            featuredProductKey: featuredProductKey,
            hiddenProductKeys: Array(hiddenProductKeys),
            badgeLabels: badgeLabels
        )
    }

    private func apply(snapshot: Snapshot) {
        acquired = snapshot.acquired
        wishlist = Set(snapshot.wishlist)
        firmwareVersions = snapshot.firmwareVersions
        hiddenProductKeys = Set(snapshot.hiddenProductKeys)
        featuredProductKey = snapshot.featuredProductKey
        badgeLabels = snapshot.badgeLabels

        // Rebuild orders from product names
        orders = snapshot.orders.compactMap { record in
            guard let product = product(forKey: record.productName),
                  let status = OrderStatus(rawValue: record.statusRaw) else {
                return nil
            }
            return Order(product: product, date: record.date, status: status)
        }
    }

    private func loadFromPersistentStorage() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        // Prefer iCloud snapshot if available, fall back to local.
        let kvStore = NSUbiquitousKeyValueStore.default
        kvStore.synchronize()

        if let cloudData = kvStore.data(forKey: Keys.ubiquitousSnapshot),
           let snapshot = try? decoder.decode(Snapshot.self, from: cloudData) {
            apply(snapshot: snapshot)
            return
        }

        if let localData = defaults.data(forKey: Keys.localSnapshot),
           let snapshot = try? decoder.decode(Snapshot.self, from: localData) {
            apply(snapshot: snapshot)
        }
    }

    private func persist() {
        let snapshot = makeSnapshot()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(snapshot) else {
            return
        }

        // Local
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: Keys.localSnapshot)

        // iCloud KVS
        let kvStore = NSUbiquitousKeyValueStore.default
        kvStore.set(data, forKey: Keys.ubiquitousSnapshot)
        kvStore.synchronize()
    }

    private func setupUbiquitousObserver() {
        ubiquitousObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reloadFromCloud()
            }
        }
    }
        
        private func reloadFromCloud() {
            let kvStore = NSUbiquitousKeyValueStore.default
            kvStore.synchronize()
            
            guard let data = kvStore.data(forKey: Keys.ubiquitousSnapshot) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let snapshot = try? decoder.decode(Snapshot.self, from: data) {
                apply(snapshot: snapshot)
            }
        }
    }

    // MARK: - XP (currently disabled)

    /// XP/level system stub so old calls still compile.
    private func awardXP(_ amount: Int) {
        // no-op for now
    }
