import SwiftUI

// MARK: - Info View (FoundationOS / Aquire brief)

struct InfoView: View {
    @EnvironmentObject private var store: StoreModel
    @State private var selectedIndex: Int = 0

    /// Scripted slides that explain what Aquire + FoundationOS actually are.
    private let slides: [InfoSlide] = [
        .init(
            title: "What is Aquire?",
            kicker: "FoundationOS · Control Layer",
            body: "Aquire is your hardware command center. Devices, accounts, and signals all live in one controllable stack instead of being scattered across random apps.",
            bullets: [
                "Single inventory of everything you own.",
                "Same visual language on phone, Mac, and TV.",
                "Built for people who actually care about their hardware."
            ],
            accent: "Command center",
            icon: "rectangle.3.offgrid.bubble.left"
        ),
        .init(
            title: "How the stack thinks.",
            kicker: "Local-First · Human-Readable",
            body: "FoundationOS treats your data like gravity: it stays local by default and only leaves when you deliberately open a door.",
            bullets: [
                "No dark patterns, no surprise syncs.",
                "Plain-language status pills instead of raw error codes.",
                "You decide which services plug into the stack."
            ],
            accent: "Local gravity",
            icon: "shield.lefthalf.filled"
        ),
        .init(
            title: "Signals & firmware.",
            kicker: "Live Stack Telemetry",
            body: "Every device in Aquire has a readable state: online, idle, updating, or misbehaving. You can skim the surface or deep-dive per device when you feel like nerding out.",
            bullets: [
                "Firmware updates stay human-readable.",
                "Status chips tell you what’s happening in two words, not twenty.",
                "Future: cross-device automations and rituals."
            ],
            accent: "Built for signals",
            icon: "waveform.path.ecg"
        ),
        .init(
            title: "Why it feels like an OS.",
            kicker: "Not Just a Storefront",
            body: "Aquire isn’t just a shopping UI. It’s the front door into how FoundationOS thinks about ownership, upgrades, and the physical objects in your life.",
            bullets: [
                "See what you own, what’s aging, and what’s next.",
                "Treat firmware and accessories as first-class citizens.",
                "Eventually: surface rituals, checklists, and care cycles."
            ],
            accent: "Stack-aware",
            icon: "square.grid.2x2"
        ),
        .init(
            title: "Future: play the whole stack.",
            kicker: "Play TOS · Not Legalese",
            body: "Instead of ten pages of terms, you get a handful of rules. Simple enough to remember, strict enough to protect you and your stack.",
            bullets: [
                "You are not the product.",
                "Opt-in, never sneaky opt-out.",
                "Data is a tool, not a currency."
            ],
            accent: "In production",
            icon: "sparkles.rectangle.stack"
        )
    ]

    var body: some View {
        ZStack {
            AquireBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header
                    pager
                    footerStatus
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: 840)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .lastTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("FoundationOS")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Control layer for your hardware stack.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                StatusChip(text: "Prototype build", style: .accent)

                Text("Aquire · Internal instrumentation UI")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    // MARK: - Pager

    private var pager: some View {
        VStack(spacing: 16) {
            #if os(iOS)
            TabView(selection: $selectedIndex) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    InfoSlideView(slide: slide)
                        .padding(.horizontal, 4)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            #else
            // macOS: vertical stack instead of horizontal paging
            VStack(spacing: 16) {
                ForEach(slides) { slide in
                    InfoSlideView(slide: slide)
                }
            }
            #endif

            // Tiny page dots for iOS+macOS
            HStack(spacing: 6) {
                ForEach(slides.indices, id: \.self) { i in
                    Circle()
                        .fill(i == selectedIndex ? Color.white.opacity(0.9) : Color.white.opacity(0.25))
                        .frame(width: 6, height: 6)
                }
            }
            .opacity(slides.count > 1 ? 1 : 0)
        }
    }

    // MARK: - Footer / Status

    private var footerStatus: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Play TOS")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Text("Not legalese. Just the rules this stack plays by.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("You are not the product.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Foundation treats your data as local gravity, not ad fuel.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(14)
                .liquidGlass(cornerRadius: 18)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Opt-in, not opt-out.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Nothing leaves your stack unless you explicitly open a door.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(14)
                .liquidGlass(cornerRadius: 18)
            }

            HStack(spacing: 10) {
                StatusChip(text: "Local-first", style: .accent)
                StatusChip(text: "No ads", style: .neutral)
                StatusChip(text: "Play, not exploit", style: .neutral)
            }
        }
    }
}

// MARK: - Slide Model

struct InfoSlide: Identifiable {
    let id = UUID()
    let title: String
    let kicker: String
    let body: String
    let bullets: [String]
    let accent: String
    let icon: String?
}

// MARK: - Slide Card

struct InfoSlideView: View {
    let slide: InfoSlide

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                if let icon = slide.icon {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(slide.kicker.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundColor(.white.opacity(0.7))

                    Text(slide.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                StatusChip(text: slide.accent, style: .accent)
            }

            Text(slide.body)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(slide.bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 8) {
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 3, height: 3)
                            .offset(y: 6)

                        Text(bullet)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 24)
    }
}
