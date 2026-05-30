import SwiftUI

struct WeatherSnapshot {
    let indoorEstimate: String
    let outdoorTemperature: String
    let comfortIndex: Int
    let humidity: String
    let feelsLike: String
    let wind: String
    let pressure: String
    let condition: String
    let location: String
    let updatedAt: String
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
    let chance: String
    let low: Int
    let high: Int
}

struct RoomControl: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
    var isOn: Bool
}

struct OutlookWeek: Identifiable {
    let id = UUID()
    let title: String
    let temperature: String
    let comfort: String
    let symbol: String
}

struct SettingsRowItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let symbol: String
}

enum MockWeatherData {
    static let indoorEstimateCelsius = 15
    static let outdoorTemperatureCelsius = 14

    static let snapshot = WeatherSnapshot(
        indoorEstimate: "15°C",
        outdoorTemperature: "14°",
        comfortIndex: 82,
        humidity: "68%",
        feelsLike: "12°",
        wind: "11 km/h",
        pressure: "1017 hPa",
        condition: "Partially cloudy",
        location: "Your Location",
        updatedAt: "Current location"
    )

    static func dashboardMetrics(for unit: TemperatureUnit) -> [WeatherMetric] {
        [
            WeatherMetric(title: "Comfort Index", value: "82", caption: "Stable", symbol: "gauge.with.dots.needle.67percent", tint: RoomlyTheme.ColorToken.primaryBlue),
            WeatherMetric(title: "Indoor Estimate", value: unit.formatted(celsius: indoorEstimateCelsius), caption: "Room context", symbol: "house.fill", tint: RoomlyTheme.ColorToken.green),
            WeatherMetric(title: "Humidity", value: "68%", caption: "Moist air", symbol: "humidity.fill", tint: RoomlyTheme.ColorToken.sky),
            WeatherMetric(title: "Pressure", value: "1017", caption: "Stable hPa", symbol: "barometer", tint: RoomlyTheme.ColorToken.purple)
        ]
    }

    static let weatherMetrics: [WeatherMetric] = [
        WeatherMetric(title: "Max Temp", value: "20°", caption: "Today", symbol: "thermometer.sun.fill", tint: RoomlyTheme.ColorToken.orange),
        WeatherMetric(title: "Min Temp", value: "13°", caption: "Tonight", symbol: "thermometer.low", tint: RoomlyTheme.ColorToken.primaryBlue),
        WeatherMetric(title: "Wind", value: "11 km/h", caption: "Light breeze", symbol: "wind", tint: RoomlyTheme.ColorToken.primaryBlue),
        WeatherMetric(title: "Humidity", value: "68%", caption: "Outdoor air", symbol: "drop.fill", tint: RoomlyTheme.ColorToken.sky),
        WeatherMetric(title: "UV Index", value: "2", caption: "Low", symbol: "sun.max.fill", tint: RoomlyTheme.ColorToken.sun),
        WeatherMetric(title: "Visibility", value: "9 km", caption: "Clear", symbol: "eye.fill", tint: RoomlyTheme.ColorToken.green),
        WeatherMetric(title: "Cloud Cover", value: "54%", caption: "Partial", symbol: "cloud.fill", tint: RoomlyTheme.ColorToken.primaryBlue),
        WeatherMetric(title: "AQI", value: "42", caption: "Good", symbol: "leaf.fill", tint: RoomlyTheme.ColorToken.green),
        WeatherMetric(title: "Dew Point", value: "8°", caption: "Comfortable", symbol: "humidity", tint: RoomlyTheme.ColorToken.sky),
        WeatherMetric(title: "Pressure", value: "1017", caption: "hPa", symbol: "barometer", tint: RoomlyTheme.ColorToken.purple)
    ]

    static let hourly: [HourlyForecast] = [
        HourlyForecast(time: "Now", temperature: "14°", symbol: "cloud.sun.fill", chance: "39%"),
        HourlyForecast(time: "12 PM", temperature: "16°", symbol: "sun.max.fill", chance: "18%"),
        HourlyForecast(time: "1 PM", temperature: "18°", symbol: "cloud.sun.fill", chance: "22%"),
        HourlyForecast(time: "2 PM", temperature: "19°", symbol: "cloud.fill", chance: "31%"),
        HourlyForecast(time: "3 PM", temperature: "19°", symbol: "cloud.sun.fill", chance: "28%"),
        HourlyForecast(time: "4 PM", temperature: "18°", symbol: "cloud.fill", chance: "34%"),
        HourlyForecast(time: "5 PM", temperature: "17°", symbol: "cloud.rain.fill", chance: "48%"),
        HourlyForecast(time: "6 PM", temperature: "16°", symbol: "cloud.rain.fill", chance: "52%"),
        HourlyForecast(time: "7 PM", temperature: "15°", symbol: "cloud.moon.fill", chance: "36%"),
        HourlyForecast(time: "8 PM", temperature: "14°", symbol: "moon.stars.fill", chance: "18%"),
        HourlyForecast(time: "9 PM", temperature: "13°", symbol: "moon.fill", chance: "12%"),
        HourlyForecast(time: "10 PM", temperature: "13°", symbol: "moon.fill", chance: "10%")
    ]

    static let daily: [DailyForecast] = [
        DailyForecast(day: "Today", summary: "Partially cloudy", symbol: "cloud.sun.fill", chance: "39%", low: 13, high: 20),
        DailyForecast(day: "Thu", summary: "Bright spells", symbol: "sun.max.fill", chance: "18%", low: 12, high: 21),
        DailyForecast(day: "Fri", summary: "Light rain", symbol: "cloud.rain.fill", chance: "62%", low: 11, high: 18),
        DailyForecast(day: "Sat", summary: "Sunny", symbol: "sun.max.fill", chance: "8%", low: 14, high: 23),
        DailyForecast(day: "Sun", summary: "Soft clouds", symbol: "cloud.fill", chance: "28%", low: 12, high: 19),
        DailyForecast(day: "Mon", summary: "Rain chance", symbol: "cloud.drizzle.fill", chance: "54%", low: 10, high: 17),
        DailyForecast(day: "Tue", summary: "Clear", symbol: "sun.max.fill", chance: "5%", low: 13, high: 22)
    ]

    static let roomControls: [RoomControl] = [
        RoomControl(title: "Is AC on?", subtitle: "Cooling affects comfort estimate", symbol: "snowflake", isOn: true),
        RoomControl(title: "Is heater on?", subtitle: "Heating adds indoor context", symbol: "flame.fill", isOn: false),
        RoomControl(title: "Is fan on?", subtitle: "Air movement improves comfort", symbol: "fan.fill", isOn: false)
    ]

    static let outlookWeeks: [OutlookWeek] = [
        OutlookWeek(title: "Week 1", temperature: "+2°", comfort: "Stable comfort", symbol: "sun.max.fill"),
        OutlookWeek(title: "Week 2", temperature: "+1°", comfort: "Higher humidity", symbol: "drop.fill"),
        OutlookWeek(title: "Week 3", temperature: "-1°", comfort: "Cooler nights", symbol: "moon.fill"),
        OutlookWeek(title: "Week 4", temperature: "+3°", comfort: "Warmer days", symbol: "thermometer.sun.fill")
    ]

    static let settings: [SettingsRowItem] = [
        SettingsRowItem(title: "Units", subtitle: "Celsius or Fahrenheit", symbol: "slider.horizontal.3"),
        SettingsRowItem(title: "Home Profile", subtitle: "Room setup and comfort preferences", symbol: "house.and.flag.fill"),
        SettingsRowItem(title: "Notifications", subtitle: "Comfort shifts and pressure drops", symbol: "bell.badge.fill"),
        SettingsRowItem(title: "Data Source", subtitle: "Mock data for prototype", symbol: "antenna.radiowaves.left.and.right")
    ]

    static let premiumFeatures = [
        "Unlimited comfort checks",
        "Advanced weather forecasts",
        "Personalized comfort insights",
        "Ad-free experience"
    ]
}
