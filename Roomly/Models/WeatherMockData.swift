import SwiftUI

struct WeatherSnapshot {
    let indoorEstimate: String
    let outdoorTemperature: String
    let comfortIndex: Int
    let humidity: String
    let wind: String
    let pressure: String
    let condition: String
    let location: String
    let updatedAt: String
    let metrics: [WeatherMetric]
}

struct WeatherMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let caption: String
    let symbol: String
    let tint: Color
}

struct HourlyForecast: Identifiable {
    let id = UUID()
    let time: String
    let temperature: String
    let symbol: String
    let chance: String
}

struct DailyForecast: Identifiable {
    let id = UUID()
    let day: String
    let summary: String
    let symbol: String
    let low: Int
    let high: Int
}

struct SettingsRowItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
}

enum MockWeatherData {
    static let indoorEstimateCelsius = 22
    static let outdoorTemperatureCelsius = 13

    static let snapshot = WeatherSnapshot(
        indoorEstimate: "22°C",
        outdoorTemperature: "13°C",
        comfortIndex: 86,
        humidity: "48%",
        wind: "11 km/h",
        pressure: "1017 hPa",
        condition: "Clear, calm air",
        location: "Minsk Home",
        updatedAt: "Updated 4 min ago",
        metrics: [
            WeatherMetric(title: "Indoor Estimate", value: "22°C", caption: "Feels balanced", symbol: "house.fill", tint: .cyan),
            WeatherMetric(title: "Outdoor Temperature", value: "13°C", caption: "Cool evening", symbol: "thermometer.medium", tint: .blue),
            WeatherMetric(title: "Comfort Index", value: "86", caption: "Premium range", symbol: "sparkles", tint: .mint),
            WeatherMetric(title: "Humidity", value: "48%", caption: "Ideal indoor air", symbol: "humidity.fill", tint: .teal),
            WeatherMetric(title: "Wind", value: "11 km/h", caption: "Light breeze", symbol: "wind", tint: .indigo),
            WeatherMetric(title: "Pressure", value: "1017 hPa", caption: "Stable", symbol: "barometer", tint: .orange)
        ]
    )

    static func metrics(for unit: TemperatureUnit) -> [WeatherMetric] {
        [
            WeatherMetric(title: "Indoor Estimate", value: unit.formatted(celsius: indoorEstimateCelsius), caption: "Feels balanced", symbol: "house.fill", tint: .cyan),
            WeatherMetric(title: "Outdoor Temperature", value: unit.formatted(celsius: outdoorTemperatureCelsius), caption: "Local Weather", symbol: "location.fill", tint: .blue),
            WeatherMetric(title: "Comfort Index", value: "86", caption: "Premium range", symbol: "sparkles", tint: .mint),
            WeatherMetric(title: "Humidity", value: "48%", caption: "Ideal indoor air", symbol: "humidity.fill", tint: .teal),
            WeatherMetric(title: "Wind", value: "11 km/h", caption: "Light breeze", symbol: "wind", tint: .indigo),
            WeatherMetric(title: "Pressure", value: "1017 hPa", caption: "Stable", symbol: "barometer", tint: .orange)
        ]
    }

    static let hourly: [HourlyForecast] = [
        HourlyForecast(time: "Now", temperature: "13°", symbol: "moon.stars.fill", chance: "2%"),
        HourlyForecast(time: "21:00", temperature: "12°", symbol: "moon.fill", chance: "3%"),
        HourlyForecast(time: "22:00", temperature: "11°", symbol: "cloud.moon.fill", chance: "8%"),
        HourlyForecast(time: "23:00", temperature: "10°", symbol: "cloud.fill", chance: "12%"),
        HourlyForecast(time: "00:00", temperature: "10°", symbol: "cloud.drizzle.fill", chance: "18%"),
        HourlyForecast(time: "01:00", temperature: "9°", symbol: "cloud.fill", chance: "14%")
    ]

    static let daily: [DailyForecast] = [
        DailyForecast(day: "Today", summary: "Clear night", symbol: "moon.stars.fill", low: 9, high: 15),
        DailyForecast(day: "Mon", summary: "Soft rain", symbol: "cloud.rain.fill", low: 8, high: 14),
        DailyForecast(day: "Tue", summary: "Bright spells", symbol: "cloud.sun.fill", low: 10, high: 18),
        DailyForecast(day: "Wed", summary: "Breezy", symbol: "wind", low: 11, high: 19),
        DailyForecast(day: "Thu", summary: "Sunny", symbol: "sun.max.fill", low: 12, high: 21),
        DailyForecast(day: "Fri", summary: "Cloud cover", symbol: "smoke.fill", low: 10, high: 17)
    ]

    static let settings: [SettingsRowItem] = [
        SettingsRowItem(title: "Units", subtitle: "Celsius, km/h, hPa", symbol: "slider.horizontal.3"),
        SettingsRowItem(title: "Home Profile", subtitle: "Apartment, bedroom priority", symbol: "house.and.flag.fill"),
        SettingsRowItem(title: "Notifications", subtitle: "Comfort shifts and pressure drops", symbol: "bell.badge.fill"),
        SettingsRowItem(title: "Data Source", subtitle: "Mock data for prototype", symbol: "antenna.radiowaves.left.and.right")
    ]

    static let premiumFeatures = [
        "Room-by-room comfort estimates",
        "Seven day indoor trend analysis",
        "Pressure and humidity alerts",
        "Premium dark weather widgets"
    ]
}
