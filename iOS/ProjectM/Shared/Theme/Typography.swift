import SwiftUI

extension Font {
    // Display: Fraunces (custom) — branding, empty states, onboarding
    static func display(_ size: CGFloat = 34, weight: Font.Weight = .semibold) -> Font {
        .custom("Fraunces-SemiBold", size: size, relativeTo: .largeTitle)
    }

    // All other text: SF Pro (system)
    static func mTitle(_ size: CGFloat = 28) -> Font { .system(size: size, weight: .bold) }
    static func mTitle2(_ size: CGFloat = 22) -> Font { .system(size: size, weight: .semibold) }
    static func mBody() -> Font { .system(size: 17, weight: .regular) }
    static func mCallout() -> Font { .system(size: 16, weight: .regular) }
    static func mCaption() -> Font { .system(size: 12, weight: .regular) }
}
