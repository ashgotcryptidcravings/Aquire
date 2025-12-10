import SwiftUI

// MARK: - Global Prismatic Background

struct AquireBackgroundView: View {
    var body: some View {
        ZStack {
            // Deep base
            Color.black.opacity(0.96)

            // Soft prismatic glows
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.45),
                    .clear
                ]),
                center: .topLeading,
                startRadius: 40,
                endRadius: 420
            )

            RadialGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    .clear
                ]),
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 520
            )

            // Very subtle vertical sheen
            LinearGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.screen)
            .opacity(0.7)
        }
        .blur(radius: 18)
        .ignoresSafeArea()
    }
}

// MARK: - Motion System

enum AquireMotion {
    /// Default squishy spring for taps.
    static let tap = Animation.interactiveSpring(
        response: 0.32,          // a bit slower
        dampingFraction: 0.6,    // more bounce
        blendDuration: 0.2
    )

    /// Slightly slower, for cards sliding in.
    static let cardEntrance = Animation.spring(
        response: 0.5,
        dampingFraction: 0.86,
        blendDuration: 0.2
    )

    /// Ambient breathing (e.g. background glow shifts).
    static let ambient = Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)
}

// MARK: - Frosted Card + Pills

private struct FrostCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.30),
                                        Color.white.opacity(0.06),
                                        Color.purple.opacity(0.45)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.9
                            )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 14)
            )
    }
}

/// Scales + squishes content when pressed.
struct PressableScaleStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.9
    var opacityAmount: Double = 0.9
    var shadowRadius: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        return configuration.label
            .scaleEffect(pressed ? scaleAmount : 1.02)   // tiny overshoot on release
            .opacity(pressed ? opacityAmount : 1.0)
            .offset(y: pressed ? 1.5 : 0)
            .shadow(
                color: Color.black.opacity(pressed ? 0.35 : 0.7),
                radius: pressed ? shadowRadius * 0.4 : shadowRadius,
                x: 0,
                y: pressed ? 2 : 7
            )
            .animation(AquireMotion.tap, value: pressed)
    }
}

/// Small circular icon button with glass feel.
struct IconGlassButton: View {
    let systemName: String
    var size: CGFloat = 26
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.55, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        )
                )
                .shadow(color: .black.opacity(0.7), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PressableScaleStyle(scaleAmount: 0.9))
    }
}

// MARK: - Status Pill (used in Orders and elsewhere)

struct StatusPill: View {
    let status: OrderStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .foregroundColor(status.tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status.tint.opacity(0.18))
                    .overlay(
                        Capsule()
                            .stroke(status.tint.opacity(0.65), lineWidth: 0.8)
                    )
            )
            .shadow(color: status.tint.opacity(0.4), radius: 5, x: 0, y: 2)
            .animation(.easeInOut(duration: 0.25), value: status)
    }
}

// MARK: - Liquid Glass Card

struct LiquidGlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    @State private var shimmer: Bool = false

    init(cornerRadius: CGFloat = 24,
         @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            // base frosted card look
            .modifier(FrostCardModifier(cornerRadius: cornerRadius))
            // animated highlight on top, masked to the same shape
            .overlay(
                liquidHighlight
                    .mask(shape)
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 5)
                        .repeatForever(autoreverses: true)
                ) {
                    shimmer = true
                }
            }
    }

    private var liquidHighlight: some View {
        // moving, soft “caustic” style gradient
        LinearGradient(
            colors: [
                Color.white.opacity(0.45),
                Color.white.opacity(0.0),
                Color.white.opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .rotationEffect(.degrees(25))
        .offset(x: shimmer ? 80 : -80,
                y: shimmer ? -40 : 40)
        .blur(radius: 18)
        .opacity(0.35)
        .blendMode(.screen)
    }
}

// MARK: - Convenience View Extensions

extension View {
    /// Drop the prismatic background behind any view.
    func aquireBackground() -> some View {
        self.background(AquireBackgroundView())
    }

    /// Frosted glass card with prismatic edge.
    func frostCard(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(FrostCardModifier(cornerRadius: cornerRadius))
    }

    /// Frosted pill style (for badges / status).
    func frostedPill(tint: Color) -> some View {
        self
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(tint.opacity(0.18))
                    .overlay(
                        Capsule()
                            .stroke(tint.opacity(0.65), lineWidth: 0.8)
                    )
            )
    }

    /// Handy wrapper for the pressable scale button style.
    func pressable() -> some View {
        self.buttonStyle(PressableScaleStyle())
    }

    /// Wraps this view in a liquid-glass styled card.
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        LiquidGlassCard(cornerRadius: cornerRadius) {
            self
        }
    }
}
// MARK: - Capsule Chrome (iOS 18-ish pills / search bars)

private struct AquireCapsuleBackground: View {
    let emphasized: Bool

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 999, style: .continuous)

        shape
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(emphasized ? 0.14 : 0.07),
                        Color.white.opacity(emphasized ? 0.02 : 0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.80),
                                Color.white.opacity(0.18)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: emphasized ? 1.4 : 1.0
                    )
            )
            .shadow(
                color: Color.black.opacity(emphasized ? 0.65 : 0.45),
                radius: emphasized ? 14 : 8,
                x: 0,
                y: emphasized ? 9 : 5
            )
    }
}

private struct CapsuleChromeModifier: ViewModifier {
    let emphasized: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, emphasized ? 18 : 14)
            .padding(.vertical, emphasized ? 10 : 8)
            .background(
                AquireCapsuleBackground(emphasized: emphasized)
            )
    }
}

extension View {
    /// Wraps content in that white-outlined, glossy pill like Apple’s search / Today controls.
    func capsuleChrome(emphasized: Bool = false) -> some View {
        modifier(CapsuleChromeModifier(emphasized: emphasized))
    }
}
