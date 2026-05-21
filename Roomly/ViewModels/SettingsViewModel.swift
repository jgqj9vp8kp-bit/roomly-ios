import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var temperatureUnit: TemperatureUnit
    @Published var notificationsEnabled: Bool

    init(
        hasCompletedOnboarding: Bool = false,
        temperatureUnit: TemperatureUnit = .fahrenheit,
        notificationsEnabled: Bool = true
    ) {
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.temperatureUnit = temperatureUnit
        self.notificationsEnabled = notificationsEnabled
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
