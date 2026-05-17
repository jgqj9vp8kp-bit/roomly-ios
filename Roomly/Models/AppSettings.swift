import Foundation

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .celsius:
            "Celsius"
        case .fahrenheit:
            "Fahrenheit"
        }
    }

    var shortTitle: String {
        switch self {
        case .celsius:
            "°C"
        case .fahrenheit:
            "°F"
        }
    }

    func formatted(celsius value: Int) -> String {
        switch self {
        case .celsius:
            "\(value)°C"
        case .fahrenheit:
            "\(Int((Double(value) * 9 / 5 + 32).rounded()))°F"
        }
    }
}

struct AppSettings {
    var temperatureUnit: TemperatureUnit
    var notificationsEnabled: Bool
    var isPremium: Bool

    static let preview = AppSettings(
        temperatureUnit: .celsius,
        notificationsEnabled: true,
        isPremium: false
    )
}
