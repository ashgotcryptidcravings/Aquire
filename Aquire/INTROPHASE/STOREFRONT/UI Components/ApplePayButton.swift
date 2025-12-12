
import SwiftUI

#if os(iOS)
import PassKit

/// A SwiftUI wrapper around the native PKPaymentButton.
/// On tap, it just calls the provided action.
struct ApplePayButton: UIViewRepresentable {
    var action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .buy,
                                     paymentButtonStyle: .black)
        button.addTarget(context.coordinator,
                         action: #selector(Coordinator.didTap),
                         for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) { }

    final class Coordinator {
        let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func didTap() {
            action()
        }
    }
}

#else

/// macOS stub so the app still compiles.
struct ApplePayButton: View {
    var action: () -> Void
    var body: some View {
        EmptyView()
    }
}

#endif
