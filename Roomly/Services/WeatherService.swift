import Foundation

struct WeatherLocation: Equatable {
    let name: String
    let latitude: Double
    let longitude: Double
    let source: LocationSource

    var cacheKey: String {
        "\(source.rawValue)-\(latitude.rounded(toPlaces: 4))-\(longitude.rounded(toPlaces: 4))-\(name)"
    }
}

struct WeatherDashboard {
    let snapshot: WeatherSnapshot
    let comfort: ComfortReport
    let usesCustomRoomSettings: Bool
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
    func fetchDashboard(for location: WeatherLocation, unit: TemperatureUnit, roomSettings: RoomSettings) async throws -> WeatherDashboard
}

enum WeatherServiceError: LocalizedError {
    case unavailable
    case emptyData
    case missingLocation
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Weather Insights are temporarily unavailable."
        case .emptyData:
            "No weather data is available yet."
        case .missingLocation:
            "Choose a location to load local Weather Insights."
        case .invalidResponse:
            "Weather data came back in an unexpected format."
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

    func fetchDashboard(for location: WeatherLocation, unit: TemperatureUnit, roomSettings: RoomSettings) async throws -> WeatherDashboard {
        try await Task.sleep(nanoseconds: delayNanoseconds)

        switch resultMode {
        case .success:
            let comfort = ComfortEngine().evaluate(
                ComfortInputs(
                    temperatureCelsius: Double(MockWeatherData.outdoorTemperatureCelsius),
                    feelsLikeCelsius: 12,
                    humidityPercent: 68,
                    windSpeedKmh: 11,
                    precipitationProbability: 39,
                    uvIndex: 2,
                    pressureHpa: 1017,
                    dailyForecast: MockWeatherData.daily.map {
                        ComfortForecastDay(
                            label: $0.day,
                            highCelsius: Double($0.high),
                            lowCelsius: Double($0.low),
                            precipitationProbability: Double($0.chance.replacingOccurrences(of: "%", with: "")),
                            windSpeedKmh: 11,
                            humidityPercent: 68,
                            uvIndex: 2
                        )
                    }
                ),
                roomSettings: roomSettings
            )
            let snapshot = WeatherSnapshot(
                indoorEstimate: unit.formatted(celsius: comfort.indoorEstimateCelsius),
                outdoorTemperature: unit.degreeString(celsius: Double(MockWeatherData.outdoorTemperatureCelsius)),
                comfortIndex: comfort.index,
                humidity: MockWeatherData.snapshot.humidity,
                feelsLike: unit.degreeString(celsius: 12),
                wind: MockWeatherData.snapshot.wind,
                pressure: MockWeatherData.snapshot.pressure,
                condition: MockWeatherData.snapshot.condition,
                location: location.name,
                updatedAt: "Mock fallback"
            )

            return WeatherDashboard(
                snapshot: snapshot,
                comfort: comfort,
                usesCustomRoomSettings: roomSettings.affectsIndoorEstimate,
                indoorEstimateCelsius: comfort.indoorEstimateCelsius,
                outdoorTemperatureCelsius: MockWeatherData.outdoorTemperatureCelsius,
                dashboardMetrics: dashboardMetrics(for: comfort, unit: unit, humidity: snapshot.humidity, pressure: "1017", usesCustomRoomSettings: roomSettings.affectsIndoorEstimate),
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

    private func dashboardMetrics(for comfort: ComfortReport, unit: TemperatureUnit, humidity: String, pressure: String, usesCustomRoomSettings: Bool) -> [WeatherMetric] {
        [
            WeatherMetric(title: "Comfort Index", value: "\(comfort.index)", caption: comfort.level.rawValue, symbol: "gauge.with.dots.needle.67percent", tint: RoomlyTheme.ColorToken.primaryBlue),
            WeatherMetric(title: "Indoor Estimate", value: unit.formatted(celsius: comfort.indoorEstimateCelsius), caption: usesCustomRoomSettings ? "Using your room settings" : "Estimated room comfort", symbol: "house.fill", tint: RoomlyTheme.ColorToken.green),
            WeatherMetric(title: "Humidity", value: humidity, caption: comfort.humidityComfort.level.rawValue, symbol: "humidity.fill", tint: RoomlyTheme.ColorToken.sky),
            WeatherMetric(title: "Pressure", value: pressure, caption: "hPa", symbol: "barometer", tint: RoomlyTheme.ColorToken.purple)
        ]
    }
}

struct OpenMeteoWeatherService: WeatherService {
    var session: URLSession = .shared

    func fetchDashboard(for location: WeatherLocation, unit: TemperatureUnit, roomSettings: RoomSettings) async throws -> WeatherDashboard {
        let url = try forecastURL(for: location)
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw WeatherServiceError.unavailable
        }

        let decoder = JSONDecoder()
        let forecast = try decoder.decode(OpenMeteoForecastResponse.self, from: data)
        return try OpenMeteoDashboardMapper(response: forecast, location: location, unit: unit, roomSettings: roomSettings).dashboard()
    }

    private func forecastURL(for location: WeatherLocation) throws -> URL {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "current", value: [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "is_day",
                "precipitation",
                "weather_code",
                "surface_pressure",
                "wind_speed_10m"
            ].joined(separator: ",")),
            URLQueryItem(name: "hourly", value: [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "precipitation_probability",
                "weather_code",
                "surface_pressure",
                "wind_speed_10m",
                "uv_index"
            ].joined(separator: ",")),
            URLQueryItem(name: "daily", value: [
                "weather_code",
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_probability_max",
                "sunrise",
                "sunset",
                "uv_index_max"
            ].joined(separator: ","))
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidResponse
        }

        return url
    }
}

private struct OpenMeteoForecastResponse: Decodable {
    let current: CurrentWeather?
    let hourly: HourlyWeather?
    let daily: DailyWeather?
}

private struct CurrentWeather: Decodable {
    let time: String?
    let temperature2m: Double?
    let relativeHumidity2m: Double?
    let apparentTemperature: Double?
    let isDay: Int?
    let precipitation: Double?
    let weatherCode: Int?
    let surfacePressure: Double?
    let windSpeed10m: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case precipitation
        case weatherCode = "weather_code"
        case surfacePressure = "surface_pressure"
        case windSpeed10m = "wind_speed_10m"
    }
}

private struct HourlyWeather: Decodable {
    let time: [String]?
    let temperature2m: [Double]?
    let relativeHumidity2m: [Double]?
    let apparentTemperature: [Double]?
    let precipitationProbability: [Double]?
    let weatherCode: [Int]?
    let surfacePressure: [Double]?
    let windSpeed10m: [Double]?
    let uvIndex: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
        case surfacePressure = "surface_pressure"
        case windSpeed10m = "wind_speed_10m"
        case uvIndex = "uv_index"
    }
}

private struct DailyWeather: Decodable {
    let time: [String]?
    let weatherCode: [Int]?
    let temperature2mMax: [Double]?
    let temperature2mMin: [Double]?
    let precipitationProbabilityMax: [Double]?
    let sunrise: [String]?
    let sunset: [String]?
    let uvIndexMax: [Double]?

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
        case sunrise
        case sunset
        case uvIndexMax = "uv_index_max"
    }
}

private struct OpenMeteoDashboardMapper {
    let response: OpenMeteoForecastResponse
    let location: WeatherLocation
    let unit: TemperatureUnit
    let roomSettings: RoomSettings

    func dashboard() throws -> WeatherDashboard {
        guard let current = response.current,
              let currentTemperature = current.temperature2m else {
            throw WeatherServiceError.emptyData
        }

        let feelsLike = current.apparentTemperature ?? currentTemperature
        let humidity = current.relativeHumidity2m
        let pressure = current.surfacePressure
        let windSpeed = current.windSpeed10m
        let weatherCode = current.weatherCode ?? response.hourly?.weatherCode?.first ?? 0
        let condition = weatherCondition(for: weatherCode)
        let precipitationChance = maxNextHourlyValue(response.hourly?.precipitationProbability, count: 12)
            ?? response.daily?.precipitationProbabilityMax?.first
        let uvIndex = currentHourlyValue(response.hourly?.uvIndex) ?? response.daily?.uvIndexMax?.first
        let comfort = ComfortEngine().evaluate(
            ComfortInputs(
                temperatureCelsius: currentTemperature,
                feelsLikeCelsius: feelsLike,
                humidityPercent: humidity,
                windSpeedKmh: windSpeed,
                precipitationProbability: precipitationChance,
                uvIndex: uvIndex,
                pressureHpa: pressure,
                dailyForecast: makeComfortForecastDays()
            ),
            roomSettings: roomSettings
        )
        let indoorEstimate = Double(comfort.indoorEstimateCelsius)
        let comfortIndex = comfort.index

        let snapshot = WeatherSnapshot(
            indoorEstimate: unit.formatted(celsius: indoorEstimate),
            outdoorTemperature: unit.degreeString(celsius: currentTemperature),
            comfortIndex: comfortIndex,
            humidity: humidity.map { "\(Int($0.rounded()))%" } ?? "--",
            feelsLike: unit.degreeString(celsius: feelsLike),
            wind: windSpeed.map { "\(Int($0.rounded())) km/h" } ?? "--",
            pressure: pressure.map { "\(Int($0.rounded())) hPa" } ?? "--",
            condition: condition.title,
            location: location.name,
            updatedAt: updatedAtText(current.time)
        )

        let dashboardMetrics = [
            WeatherMetric(title: "Comfort Index", value: "\(comfortIndex)", caption: comfort.level.rawValue, symbol: "gauge.with.dots.needle.67percent", tint: RoomlyTheme.ColorToken.primaryBlue),
            WeatherMetric(title: "Indoor Estimate", value: unit.formatted(celsius: indoorEstimate), caption: roomSettings.affectsIndoorEstimate ? "Using your room settings" : "Estimated room comfort", symbol: "house.fill", tint: RoomlyTheme.ColorToken.green),
            WeatherMetric(title: "Humidity", value: snapshot.humidity, caption: comfort.humidityComfort.level.rawValue, symbol: "humidity.fill", tint: RoomlyTheme.ColorToken.sky),
            WeatherMetric(title: "Pressure", value: pressure.map { "\(Int($0.rounded()))" } ?? "--", caption: "hPa", symbol: "barometer", tint: RoomlyTheme.ColorToken.purple)
        ]

        let weatherMetrics = makeWeatherMetrics(
            currentTemperature: currentTemperature,
            feelsLike: feelsLike,
            humidity: humidity,
            pressure: pressure,
            windSpeed: windSpeed,
            uvIndex: uvIndex,
            precipitationChance: precipitationChance,
            sunrise: response.daily?.sunrise?.first,
            sunset: response.daily?.sunset?.first
        )

        return WeatherDashboard(
            snapshot: snapshot,
            comfort: comfort,
            usesCustomRoomSettings: roomSettings.affectsIndoorEstimate,
            indoorEstimateCelsius: Int(indoorEstimate.rounded()),
            outdoorTemperatureCelsius: Int(currentTemperature.rounded()),
            dashboardMetrics: dashboardMetrics,
            weatherMetrics: weatherMetrics,
            hourly: makeHourlyForecast(),
            daily: makeDailyForecast(),
            roomControls: MockWeatherData.roomControls,
            outlookWeeks: makeOutlookWeeks(comfort),
            settingsRows: liveSettingsRows,
            premiumFeatures: MockWeatherData.premiumFeatures,
            premiumPlans: MockWeatherData.premiumPlans
        )
    }

    private var liveSettingsRows: [SettingsRowItem] {
        [
            SettingsRowItem(title: "Units", subtitle: "Celsius or Fahrenheit", symbol: "slider.horizontal.3"),
            SettingsRowItem(title: "Home Profile", subtitle: "Room setup and comfort preferences", symbol: "house.and.flag.fill"),
            SettingsRowItem(title: "Notifications", subtitle: "Comfort shifts and pressure drops", symbol: "bell.badge.fill"),
            SettingsRowItem(title: "Data Source", subtitle: "Open-Meteo Forecast API", symbol: "antenna.radiowaves.left.and.right")
        ]
    }

    private func makeWeatherMetrics(
        currentTemperature: Double,
        feelsLike: Double,
        humidity: Double?,
        pressure: Double?,
        windSpeed: Double?,
        uvIndex: Double?,
        precipitationChance: Double?,
        sunrise: String?,
        sunset: String?
    ) -> [WeatherMetric] {
        let high = response.daily?.temperature2mMax?.first
        let low = response.daily?.temperature2mMin?.first

        return [
            WeatherMetric(title: "Max Temp", value: high.map { unit.degreeString(celsius: $0) } ?? "--", caption: "Today", symbol: "thermometer.sun.fill", tint: RoomlyTheme.ColorToken.orange),
            WeatherMetric(title: "Min Temp", value: low.map { unit.degreeString(celsius: $0) } ?? "--", caption: "Tonight", symbol: "thermometer.low", tint: RoomlyTheme.ColorToken.primaryBlue),
            WeatherMetric(title: "Feels Like", value: unit.degreeString(celsius: feelsLike), caption: "Apparent", symbol: "thermometer.medium", tint: RoomlyTheme.ColorToken.orange),
            WeatherMetric(title: "Wind", value: windSpeed.map { "\(Int($0.rounded())) km/h" } ?? "--", caption: windCaption(windSpeed), symbol: "wind", tint: RoomlyTheme.ColorToken.primaryBlue),
            WeatherMetric(title: "Humidity", value: humidity.map { "\(Int($0.rounded()))%" } ?? "--", caption: "Outdoor air", symbol: "drop.fill", tint: RoomlyTheme.ColorToken.sky),
            WeatherMetric(title: "UV Index", value: uvIndex.map { "\(Int($0.rounded()))" } ?? "--", caption: uvCaption(uvIndex), symbol: "sun.max.fill", tint: RoomlyTheme.ColorToken.sun),
            WeatherMetric(title: "Rain Chance", value: precipitationChance.map { "\(Int($0.rounded()))%" } ?? "--", caption: "Next hours", symbol: "cloud.rain.fill", tint: RoomlyTheme.ColorToken.primaryBlue),
            WeatherMetric(title: "Pressure", value: pressure.map { "\(Int($0.rounded()))" } ?? "--", caption: "hPa", symbol: "barometer", tint: RoomlyTheme.ColorToken.purple),
            WeatherMetric(title: "Sunrise", value: timeLabel(sunrise), caption: "Local", symbol: "sunrise.fill", tint: RoomlyTheme.ColorToken.sun),
            WeatherMetric(title: "Sunset", value: timeLabel(sunset), caption: "Local", symbol: "sunset.fill", tint: RoomlyTheme.ColorToken.orange)
        ]
    }

    private func makeHourlyForecast() -> [HourlyForecast] {
        guard let hourly = response.hourly,
              let times = hourly.time,
              let temperatures = hourly.temperature2m else {
            return []
        }

        let startIndex = currentHourIndex(times: times) ?? 0
        let endIndex = min(startIndex + 24, temperatures.count, times.count)
        guard startIndex < endIndex else { return [] }

        return (startIndex..<endIndex).map { index in
            let weatherCode = hourly.weatherCode?[safe: index] ?? 0
            return HourlyForecast(
                time: index == startIndex ? "Now" : hourLabel(times[index]),
                temperature: unit.degreeString(celsius: temperatures[index]),
                symbol: weatherCondition(for: weatherCode).symbol,
                chance: hourly.precipitationProbability?[safe: index].map { "\(Int($0.rounded()))%" } ?? "--"
            )
        }
    }

    private func makeDailyForecast() -> [DailyForecast] {
        guard let daily = response.daily,
              let times = daily.time,
              let lows = daily.temperature2mMin,
              let highs = daily.temperature2mMax else {
            return []
        }

        let count = min(times.count, lows.count, highs.count, 7)
        return (0..<count).map { index in
            let weatherCode = daily.weatherCode?[safe: index] ?? 0
            let condition = weatherCondition(for: weatherCode)
            return DailyForecast(
                day: index == 0 ? "Today" : dayLabel(times[index]),
                summary: condition.title,
                symbol: condition.symbol,
                chance: daily.precipitationProbabilityMax?[safe: index].map { "\(Int($0.rounded()))%" } ?? "--",
                low: Int(displayTemperature(celsius: lows[index]).rounded()),
                high: Int(displayTemperature(celsius: highs[index]).rounded())
            )
        }
    }

    private func makeComfortForecastDays() -> [ComfortForecastDay] {
        guard let daily = response.daily,
              let times = daily.time,
              let lows = daily.temperature2mMin,
              let highs = daily.temperature2mMax else {
            return []
        }

        let count = min(times.count, lows.count, highs.count, 7)
        return (0..<count).map { index in
            ComfortForecastDay(
                label: index == 0 ? "Today" : dayLabel(times[index]),
                highCelsius: highs[index],
                lowCelsius: lows[index],
                precipitationProbability: daily.precipitationProbabilityMax?[safe: index],
                windSpeedKmh: response.current?.windSpeed10m,
                humidityPercent: response.current?.relativeHumidity2m,
                uvIndex: daily.uvIndexMax?[safe: index]
            )
        }
    }

    private func makeOutlookWeeks(_ comfort: ComfortReport) -> [OutlookWeek] {
        guard let highs = response.daily?.temperature2mMax, !highs.isEmpty else {
            return MockWeatherData.outlookWeeks
        }

        return [
            OutlookWeek(title: "Week Ahead", temperature: unit.degreeString(celsius: Double(comfort.averageHighCelsius)), comfort: comfort.level.rawValue, symbol: "sun.max.fill"),
            OutlookWeek(title: "Rain Risk", temperature: "\(comfort.peakRainChance)%", comfort: comfort.rainRisk.level.rawValue, symbol: "cloud.rain.fill"),
            OutlookWeek(title: "Sleep", temperature: comfort.sleepComfort.level.rawValue, comfort: "Tonight", symbol: "moon.fill"),
            OutlookWeek(title: "Wind", temperature: comfort.windSummary, comfort: comfort.windRisk.message, symbol: "wind")
        ]
    }

    private func currentHourIndex(times: [String]) -> Int? {
        guard let currentTime = response.current?.time,
              let currentDate = parseDate(currentTime) else {
            return nil
        }

        return times.firstIndex { time in
            guard let date = parseDate(time) else { return false }
            return date >= currentDate
        }
    }

    private func currentHourlyValue(_ values: [Double]?) -> Double? {
        guard let values,
              let index = currentHourlyIndex(),
              values.indices.contains(index) else {
            return values?.first
        }

        return values[index]
    }

    private func maxNextHourlyValue(_ values: [Double]?, count: Int) -> Double? {
        guard let values, !values.isEmpty else { return nil }
        let startIndex = currentHourlyIndex() ?? 0
        guard values.indices.contains(startIndex) else { return values.max() }
        let endIndex = min(values.count, startIndex + count)
        return values[startIndex..<endIndex].max()
    }

    private func currentHourlyIndex() -> Int? {
        guard let times = response.hourly?.time else { return nil }
        return currentHourIndex(times: times)
    }

    private func displayTemperature(celsius value: Double) -> Double {
        switch unit {
        case .celsius:
            value
        case .fahrenheit:
            value * 9 / 5 + 32
        }
    }

    private func comfortIndex(temperature: Double, humidity: Double?, windSpeed: Double?) -> Int {
        var score = 100 - abs(temperature - 21) * 3

        if let humidity {
            score -= abs(humidity - 45) * 0.25
        }

        if let windSpeed, windSpeed > 24 {
            score -= (windSpeed - 24) * 0.5
        }

        return min(99, max(35, Int(score.rounded())))
    }

    private func weatherCondition(for code: Int) -> (title: String, symbol: String) {
        switch code {
        case 0:
            ("Clear", "sun.max.fill")
        case 1, 2:
            ("Partly cloudy", "cloud.sun.fill")
        case 3:
            ("Cloudy", "cloud.fill")
        case 45, 48:
            ("Fog", "cloud.fog.fill")
        case 51, 53, 55, 56, 57:
            ("Drizzle", "cloud.drizzle.fill")
        case 61, 63, 65, 66, 67:
            ("Rain", "cloud.rain.fill")
        case 71, 73, 75, 77:
            ("Snow", "snowflake")
        case 80, 81, 82:
            ("Rain showers", "cloud.heavyrain.fill")
        case 85, 86:
            ("Snow showers", "cloud.snow.fill")
        case 95, 96, 99:
            ("Thunderstorm", "cloud.bolt.rain.fill")
        default:
            ("Weather", "cloud.sun.fill")
        }
    }

    private func updatedAtText(_ value: String?) -> String {
        guard let value else { return "Open-Meteo" }
        return "Updated \(timeLabel(value))"
    }

    private func hourLabel(_ value: String) -> String {
        guard let date = parseDate(value) else { return value }
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }

    private func dayLabel(_ value: String) -> String {
        guard let date = parseDay(value) else { return value }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func timeLabel(_ value: String?) -> String {
        guard let value, let date = parseDate(value) else { return "--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func parseDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter.date(from: value)
    }

    private func parseDay(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    private func comfortCaption(for score: Int) -> String {
        switch score {
        case 85...:
            "Excellent"
        case 70..<85:
            "Stable"
        case 55..<70:
            "Mixed"
        default:
            "Watch"
        }
    }

    private func humidityCaption(_ humidity: Double?) -> String {
        guard let humidity else { return "Unavailable" }
        switch humidity {
        case ..<35:
            return "Dry air"
        case 35...60:
            return "Comfortable"
        default:
            return "Moist air"
        }
    }

    private func windCaption(_ windSpeed: Double?) -> String {
        guard let windSpeed else { return "Unavailable" }
        switch windSpeed {
        case ..<12:
            return "Light"
        case 12..<28:
            return "Breezy"
        default:
            return "Windy"
        }
    }

    private func uvCaption(_ uvIndex: Double?) -> String {
        guard let uvIndex else { return "Unavailable" }
        switch uvIndex {
        case ..<3:
            return "Low"
        case 3..<6:
            return "Moderate"
        case 6..<8:
            return "High"
        default:
            return "Very high"
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
