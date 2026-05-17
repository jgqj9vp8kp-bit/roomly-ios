import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
}

enum MockOnboardingData {
    static let pages = [
        OnboardingPage(
            title: "Welcome to Roomly",
            subtitle: "A refined way to read Local Weather and understand how your home may feel.",
            symbol: "cloud.moon.fill",
            accent: .cyan
        ),
        OnboardingPage(
            title: "Indoor Estimate",
            subtitle: "See a careful indoor comfort estimate shaped by weather, humidity, and pressure context.",
            symbol: "house.fill",
            accent: .mint
        ),
        OnboardingPage(
            title: "Comfort Index",
            subtitle: "A calm score for quick decisions, from opening a window to settling in for the evening.",
            symbol: "dial.high.fill",
            accent: .orange
        )
    ]

    static let unitOptions = ["Celsius", "km/h", "hPa"]
}
