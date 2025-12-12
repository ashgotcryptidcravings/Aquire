import SwiftUI

/// One slide in a narrative sequence (Info tab, product story, etc.)
struct StorySlide: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let body: String
    let badge: String?          // e.g. "IN-PRODUCTION", "LOCAL-ONLY"
    let iconSystemName: String? // optional SF symbol
}

/// A sequence of slides for a given context.
struct StorySequence: Identifiable, Hashable {
    let id = UUID()
    let key: String         // e.g. "foundationOS", "advancaLinkStory"
    let slides: [StorySlide]
}
