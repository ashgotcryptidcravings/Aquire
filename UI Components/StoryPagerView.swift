import SwiftUI

struct StoryPagerView: View {
    let sequence: StorySequence
    @State private var index: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            pager
            dots
        }
    }

    // MARK: - Pager

    @ViewBuilder
    private var pager: some View {
        #if os(iOS)
        TabView(selection: $index) {
            ForEach(Array(sequence.slides.enumerated()), id: \.element.id) { i, slide in
                storyCard(for: slide)
                    .tag(i)
                    .padding(.horizontal, 4)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 260)
        #else
        // macOS: simple TabView without page style
        TabView(selection: $index) {
            ForEach(Array(sequence.slides.enumerated()), id: \.element.id) { i, slide in
                storyCard(for: slide)
                    .tag(i)
                    .padding(.horizontal, 4)
            }
        }
        .frame(height: 260)
        #endif
    }

    // MARK: - Dots

    private var dots: some View {
        HStack(spacing: 8) {
            ForEach(sequence.slides.indices, id: \.self) { i in
                Circle()
                    .fill(i == index ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Card

    @ViewBuilder
    private func storyCard(for slide: StorySlide) -> some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.black.opacity(0.6))
            .overlay(
                VStack(alignment: .leading, spacing: 10) {
                    if let badge = slide.badge {
                        Text(badge.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 10) {
                        if let icon = slide.iconSystemName {
                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(slide.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            if let subtitle = slide.subtitle {
                                Text(subtitle)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }

                    Text(slide.body)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
                .padding(20)
            )
    }
}
