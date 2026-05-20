import Foundation

struct WeatherDashboard {
    let snapshot: WeatherSnapshot
    let indoorEstimateCelsius: Int
    let outdoorTemperatureCelsius: Int
    let dashboardMetrics: [WeatherMetric]
    let weatherMetrics: [WeatherMetric]
    let hourly: [HourlyForecast]
    let daily: [DailyForecast]
    let roomControls: [RoomControl]
    let outlookWeeks: [OutlookWeek]
    let settingsRows: [SettingsRowItem]
    let premiumFeatures: [String]
    let premiumPlans: [PremiumPlan]
}

protocol WeatherService {
    func fetchDashboard(unit: TemperatureUnit) async throws -> WeatherDashboard
}

enum WeatherServiceError: LocalizedError {
    case unavailable
    case emptyData

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Weather Insights are temporarily unavailable."
        case .emptyData:
            "No weather data is available yet."
        }
    }
}

struct MockWeatherService: WeatherService {
    var delayNanoseconds: UInt64 = 550_000_000
    var resultMode: ResultMode = .success

    enum ResultMode {
        case success
        case empty
        case failure
    }

    func fetchDashboard(unit: TemperatureUnit) async throws -> WeatherDashboard {
        try await Task.sleep(nanoseconds: delayNanoseconds)

        switch resultMode {
        case .success:
            return WeatherDashboard(
                snapshot: MockWeatherData.snapshot,
                indoorEstimateCelsius: MockWeatherData.indoorEstimateCelsius,
                outdoorTemperatureCelsius: MockWeatherData.outdoorTemperatureCelsius,
                dashboardMetrics: MockWeatherData.dashboardMetrics(for: unit),
                weatherMetrics: MockWeatherData.weatherMetrics,
                hourly: MockWeatherData.hourly,
                daily: MockWeatherData.daily,
                roomControls: MockWeatherData.roomControls,
                outlookWeeks: MockWeatherData.outlookWeeks,
                settingsRows: MockWeatherData.settings,
                premiumFeatures: MockWeatherData.premiumFeatures,
                premiumPlans: MockWeatherData.premiumPlans
            )
        case .empty:
            throw WeatherServiceError.emptyData
        case .failure:
            throw WeatherServiceError.unavailable
        }
    }
}
