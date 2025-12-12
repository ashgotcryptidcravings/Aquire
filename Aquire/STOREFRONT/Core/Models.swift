import Foundation
import SwiftUI
// MARK: - Models
import Foundation

struct Product: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Double
    let imageSystemName: String
    let category: String

    /// Main marketing / info copy shown in detail view + cards.
    let description: String

    /// Optional USDZ file name (without extension) for 3D preview.
    let modelName: String?
}

struct Order: Identifiable {
    let id = UUID()
    let product: Product
    let date: Date
    var status: OrderStatus
}

enum OrderStatus: String, CaseIterable {
    case processing = "Processing"
    case preparing  = "Preparing for Shipment"
    case shipped    = "Shipped"
    case delivered  = "Delivered"

    var displayName: String { rawValue }

    var next: OrderStatus? {
        switch self {
        case .processing: return .preparing
        case .preparing:  return .shipped
        case .shipped:    return .delivered
        case .delivered:  return nil
        }
    }

    var tint: SwiftUI.Color {
        switch self {
        case .processing: return .orange
        case .preparing:  return .yellow
        case .shipped:    return .blue
        case .delivered:  return .green
        }
    }
}

// MARK: - Sample Products

let products: [Product] = [
    Product(
        name: "AdvancaLink",
        price: 299.99,
        imageSystemName: "iphone",
        category: "Devices",
        description: "A next-gen Foundation handset that links every layer of your ecosystem together. Designed for seamless handoff between reality, VR, and FoundationOS.",
        modelName: "AdvancaLink"   // expects AdvancaLink.usdz in the bundle
    ),
    Product(
        name: "OnyxGlove V2",
        price: 349.00,
        imageSystemName: "hand.raised.fill",
        category: "Wearables",
        description: "A modular control glove for gestural input, haptic feedback, and real-time system control.",
        modelName: nil
    ),
    Product(
        name: "Foundation Dock",
        price: 249.00,
        imageSystemName: "square.stack.3d.down.right.fill",
        category: "Accessories",
        description: "A prismatic magnetic docking pedestal engineered for seamless Foundation ecosystem power, data, and synchronization. Features stabilized pillar architecture, triple-gold contact inlets, and a low-profile auxiliary pad.",
        modelName: "FoundationDock"
    )
]

// Fast lookup table: product.id → Product
let productsByID: [UUID: Product] = {
    Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
}()
