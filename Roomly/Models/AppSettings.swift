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
        formatted(celsius: Double(value))
    }

    func formatted(celsius value: Double) -> String {
        switch self {
        case .celsius:
            "\(Int(value.rounded()))°C"
        case .fahrenheit:
            "\(Int((value * 9 / 5 + 32).rounded()))°F"
        }
    }

    func degreeString(celsius value: Double) -> String {
        switch self {
        case .celsius:
            "\(Int(value.rounded()))°"
        case .fahrenheit:
            "\(Int((value * 9 / 5 + 32).rounded()))°"
        }
    }

    func celsiusValue(from value: Double) -> Double {
        switch self {
        case .celsius:
            value
        case .fahrenheit:
            (value - 32) * 5 / 9
        }
    }

    func displayValue(celsius value: Double) -> Double {
        switch self {
        case .celsius:
            value
        case .fahrenheit:
            value * 9 / 5 + 32
        }
    }

    func celsiusDelta(from value: Double) -> Double {
        switch self {
        case .celsius:
            value
        case .fahrenheit:
            value * 5 / 9
        }
    }

    func displayDelta(celsius value: Double) -> Double {
        switch self {
        case .celsius:
            value
        case .fahrenheit:
            value * 9 / 5
        }
    }
}

enum InsulationType: String, Codable, CaseIterable, Identifiable {
    case light
    case medium
    case strong

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light:
            "Light"
        case .medium:
            "Medium"
        case .strong:
            "Strong"
        }
    }
}

struct RoomSettings: Codable, Equatable {
    var isACOn: Bool
    var acTemperatureCelsius: Double?
    var isHeaterOn: Bool
    var heaterTemperatureCelsius: Double?
    var isFanOn: Bool
    var fanCoolingEffectCelsius: Double?
    var insulationType: InsulationType

    static let storageKey = "roomSettings"

    static let defaults = RoomSettings(
        isACOn: false,
        acTemperatureCelsius: nil,
        isHeaterOn: false,
        heaterTemperatureCelsius: nil,
        isFanOn: false,
        fanCoolingEffectCelsius: nil,
        insulationType: .medium
    )

    var hasCustomValues: Bool {
        isACOn || isHeaterOn || isFanOn || insulationType != .medium
    }

    var affectsIndoorEstimate: Bool {
        (isACOn && acTemperatureCelsius != nil)
            || (isHeaterOn && heaterTemperatureCelsius != nil)
            || (isFanOn && fanCoolingEffectCelsius != nil)
            || insulationType != .medium
    }

    static func load(from defaults: UserDefaults = .standard) -> RoomSettings {
        guard let data = defaults.data(forKey: storageKey),
              let settings = try? JSONDecoder().decode(RoomSettings.self, from: data) else {
            return .defaults
        }

        return settings
    }

    func save(to defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    static func reset(in defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: storageKey)
    }
}

struct AppSettings {
    var temperatureUnit: TemperatureUnit
    var notificationsEnabled: Bool
    var isPremium: Bool

    static let preview = AppSettings(
        temperatureUnit: .fahrenheit,
        notificationsEnabled: true,
        isPremium: false
    )
}
