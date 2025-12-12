import SwiftUI

@available(macOS 13.0, *)
struct OrdersView: View {
    @EnvironmentObject var store: StoreModel

    var body: some View {
        NavigationView {
            ZStack {
                AquireBackgroundView()

                if store.orders.isEmpty {
                    Text("No orders yet.\nAcquire a device to see tracking info.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                } else {
                    List {
                        ForEach(store.orders) { order in
                            NavigationLink(
                                destination: OrderDetailView(order: order)
                            ) {
                                orderRow(order)
                            }
                            .listRowBackground(Color.black)
                        }
                    }
                    #if os(tvOS)
                    .listStyle(.plain)
                    #else
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    #endif
                }
            }
            .navigationTitle("Orders")
        }
    }

    private func orderRow(_ order: Order) -> some View {
        HStack {
            Image(systemName: order.product.imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.purple)

            VStack(alignment: .leading, spacing: 4) {
                Text(order.product.name)
                    .foregroundColor(.white)

                StatusPill(status: order.status)
            }

            Spacer()

            Text(order.date, style: .time)
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)
        }
    }
}

struct OrderDetailView: View {
    let order: Order

    private var currentIndex: Int {
        OrderStatus.allCases.firstIndex(of: order.status) ?? 0
    }

    var body: some View {
        ZStack {
            AquireBackgroundView()

            VStack(alignment: .leading, spacing: 24) {
                // Product header
                HStack(spacing: 16) {
                    Image(systemName: order.product.imageSystemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.purple)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.product.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        Text(order.product.price, format: .currency(code: "USD"))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }

                // Timeline
                OrderStatusTimeline(currentStatus: order.status)

                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Status:")
                            .foregroundColor(.white)
                        StatusPill(status: order.status)
                    }

                    Text("Placed: \(order.date.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(Color.white.opacity(0.7))
                        .font(.subheadline)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Order Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

// MARK: - Timeline Views

struct OrderStatusTimeline: View {
    let currentStatus: OrderStatus

    private let statuses = OrderStatus.allCases

    private func shortLabel(for status: OrderStatus) -> String {
        switch status {
        case .processing: return "Processing"
        case .preparing:  return "Preparing"
        case .shipped:    return "Shipped"
        case .delivered:  return "Delivered"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order Progress")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 0) {
                ForEach(statuses.indices, id: \.self) { index in
                    let status = statuses[index]
                    let isActive = index <= (statuses.firstIndex(of: currentStatus) ?? 0)

                    OrderStatusDot(status: status,
                                   label: shortLabel(for: status),
                                   isActive: isActive)

                    if index < statuses.count - 1 {
                        Rectangle()
                            .fill(isActive ? status.tint : Color.white.opacity(0.2))
                            .frame(height: 2)
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
}

struct OrderStatusDot: View {
    let status: OrderStatus
    let label: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .strokeBorder(
                    isActive ? status.tint : Color.white.opacity(0.3),
                    lineWidth: 2
                )
                .background(
                    Circle()
                        .fill(isActive ? status.tint.opacity(0.3) : Color.clear)
                )
                .frame(width: 20, height: 20)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: 60)
        }
        .frame(minWidth: 60)
    }
}
