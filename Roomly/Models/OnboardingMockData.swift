import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    let kind: OnboardingHeroKind
}

enum OnboardingHeroKind {
    case location
    case comfort
}

enum MockOnboardingData {
    static let pages = [
        OnboardingPage(
            title: "Location Forecast",
            subtitle: "Get personalized weather and comfort insights based on your location.",
            symbol: "location.fill",
            accent: RoomlyTheme.ColorToken.primaryBlue,
            kind: .location
        ),
        OnboardingPage(
            title: "Estimated Room Comfort",
            subtitle: "Get personalized indoor comfort estimates based on weather and room conditions.",
            symbol: "house.fill",
            accent: RoomlyTheme.ColorToken.green,
            kind: .comfort
        )
    ]
}
