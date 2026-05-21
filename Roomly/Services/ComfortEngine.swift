import Foundation

enum ComfortLevel: String, Equatable {
    case excellent = "Excellent"
    case good = "Good"
    case moderate = "Moderate"
    case poor = "Poor"
}

struct ComfortSignal: Equatable {
    let title: String
    let level: ComfortLevel
    let message: String
}

struct ComfortForecastDay: Equatable {
    let label: String
    let highCelsius: Double
    let lowCelsius: Double
    let precipitationProbability: Double?
    let windSpeedKmh: Double?
    let humidityPercent: Double?
    let uvIndex: Double?
}

struct ComfortInputs: Equatable {
    let temperatureCelsius: Double
    let feelsLikeCelsius: Double?
    let humidityPercent: Double?
    let windSpeedKmh: Double?
    let precipitationProbability: Double?
    let uvIndex: Double?
    let pressureHpa: Double?
    let dailyForecast: [ComfortForecastDay]
}

struct ComfortReport: Equatable {
    let index: Int
    let level: ComfortLevel
    let indoorEstimateCelsius: Int
    let sleepComfort: ComfortSignal
    let outdoorComfort: ComfortSignal
    let rainRisk: ComfortSignal
    let windRisk: ComfortSignal
    let humidityComfort: ComfortSignal
    let insights: [String]
    let roomInsight: String
    let outdoorInsight: String
    let weeklyTrendInsight: String
    let outlookSummary: String
    let bestComfortDay: String
    let rainiestDay: String
    let warmestDay: String
    let coolestNight: String
    let averageHighCelsius: Int
    let peakRainChance: Int
    let windSummary: String
}

struct ComfortEngine {
    func evaluate(_ inputs: ComfortInputs, roomSettings: RoomSettings = .defaults) -> ComfortReport {
        let apparentTemperature = inputs.feelsLikeCelsius ?? inputs.temperatureCelsius
        let indoorEstimate = indoorEstimateCelsius(
            outdoorTemperature: inputs.temperatureCelsius,
            feelsLike: apparentTemperature,
            humidity: inputs.humidityPercent,
            windSpeed: inputs.windSpeedKmh,
            roomSettings: roomSettings
        )
        let index = comfortIndex(
            temperature: inputs.temperatureCelsius,
            feelsLike: apparentTemperature,
            humidity: inputs.humidityPercent,
            windSpeed: inputs.windSpeedKmh,
            precipitationProbability: inputs.precipitationProbability,
            uvIndex: inputs.uvIndex,
            pressure: inputs.pressureHpa
        )
        let level = level(for: index)
        let sleepComfort = sleepSignal(inputs)
        let outdoorComfort = outdoorSignal(index: index, inputs: inputs)
        let rainRisk = rainSignal(inputs.precipitationProbability)
        let windRisk = windSignal(inputs.windSpeedKmh)
        let humidityComfort = humiditySignal(inputs.humidityPercent)
        let outlook = outlookValues(inputs.dailyForecast)
        let roomInsight = roomInsight(indoorEstimate: indoorEstimate, humidity: inputs.humidityPercent, level: level)
        let outdoorInsight = outdoorInsight(level: level, rainRisk: rainRisk, windRisk: windRisk, uvIndex: inputs.uvIndex)

        return ComfortReport(
            index: index,
            level: level,
            indoorEstimateCelsius: indoorEstimate,
            sleepComfort: sleepComfort,
            outdoorComfort: outdoorComfort,
            rainRisk: rainRisk,
            windRisk: windRisk,
            humidityComfort: humidityComfort,
            insights: insights(level: level, humidity: inputs.humidityPercent, rainRisk: rainRisk, windRisk: windRisk, sleepComfort: sleepComfort),
            roomInsight: roomInsight,
            outdoorInsight: outdoorInsight,
            weeklyTrendInsight: outlook.trend,
            outlookSummary: outlook.summary,
            bestComfortDay: outlook.bestComfortDay,
            rainiestDay: outlook.rainiestDay,
            warmestDay: outlook.warmestDay,
            coolestNight: outlook.coolestNight,
            averageHighCelsius: outlook.averageHigh,
            peakRainChance: outlook.peakRainChance,
            windSummary: windRisk.level == .poor ? "High" : windRisk.level == .moderate ? "Breezy" : "Low"
        )
    }

    func level(for index: Int) -> ComfortLevel {
        switch index {
        case 85...:
            .excellent
        case 70..<85:
            .good
        case 50..<70:
            .moderate
        default:
            .poor
        }
    }

    func comfortIndex(
        temperature: Double,
        feelsLike: Double,
        humidity: Double?,
        windSpeed: Double?,
        precipitationProbability: Double?,
        uvIndex: Double?,
        pressure: Double?
    ) -> Int {
        var score = 100.0
        score -= abs(feelsLike - 22) * 3.1

        if let humidity {
            if humidity < 35 {
                score -= (35 - humidity) * 0.55
            } else if humidity > 60 {
                score -= (humidity - 60) * 0.75
            }
        }

        if let windSpeed, windSpeed > 18 {
            score -= (windSpeed - 18) * 0.55
        }

        if let precipitationProbability, precipitationProbability > 20 {
            score -= (precipitationProbability - 20) * 0.18
        }

        if let uvIndex, uvIndex > 6 {
            score -= (uvIndex - 6) * 2.5
        }

        if let pressure {
            if pressure < 995 {
                score -= min(6, (995 - pressure) * 0.25)
            } else if pressure > 1030 {
                score -= min(4, (pressure - 1030) * 0.15)
            }
        }

        return min(100, max(0, Int(score.rounded())))
    }

    func indoorEstimateCelsius(
        outdoorTemperature: Double,
        feelsLike: Double,
        humidity: Double?,
        windSpeed: Double?,
        roomSettings: RoomSettings = .defaults
    ) -> Int {
        guard roomSettings.affectsIndoorEstimate else {
            return defaultIndoorEstimateCelsius(
                outdoorTemperature: outdoorTemperature,
                feelsLike: feelsLike,
                humidity: humidity,
                windSpeed: windSpeed
            )
        }

        var estimate = insulationAdjustedEstimate(
            outdoorTemperature: outdoorTemperature,
            feelsLike: feelsLike,
            humidity: humidity,
            windSpeed: windSpeed,
            insulationType: roomSettings.insulationType
        )

        if roomSettings.isACOn, let acTemperature = roomSettings.acTemperatureCelsius {
            estimate = estimate + (acTemperature - estimate) * 0.62
        }

        if roomSettings.isHeaterOn, let heaterTemperature = roomSettings.heaterTemperatureCelsius {
            estimate = estimate + (heaterTemperature - estimate) * 0.58
        }

        if roomSettings.isFanOn, let fanCoolingEffect = roomSettings.fanCoolingEffectCelsius {
            estimate -= min(max(fanCoolingEffect, 0), 6)
        }

        return Int(estimate.rounded())
    }

    private func defaultIndoorEstimateCelsius(
        outdoorTemperature: Double,
        feelsLike: Double,
        humidity: Double?,
        windSpeed: Double?
    ) -> Int {
        var estimate: Double

        switch outdoorTemperature {
        case 30...:
            estimate = outdoorTemperature - 4
        case 26..<30:
            estimate = outdoorTemperature - 2
        case 20..<26:
            estimate = outdoorTemperature - 1
        case 15..<20:
            estimate = outdoorTemperature + 1
        case 8..<15:
            estimate = outdoorTemperature + 3
        default:
            estimate = outdoorTemperature + 5
        }

        let apparentDelta = feelsLike - outdoorTemperature
        estimate += apparentDelta * 0.25

        if let humidity, humidity > 70 {
            estimate += 1
        } else if let humidity, humidity < 30 {
            estimate -= 1
        }

        if let windSpeed, windSpeed > 32 {
            estimate -= 1
        }

        return Int(estimate.rounded())
    }

    private func insulationAdjustedEstimate(
        outdoorTemperature: Double,
        feelsLike: Double,
        humidity: Double?,
        windSpeed: Double?,
        insulationType: InsulationType
    ) -> Double {
        let comfortAnchor = 22.0
        let outdoorInfluence: Double

        switch insulationType {
        case .light:
            outdoorInfluence = 0.44
        case .medium:
            outdoorInfluence = 0.30
        case .strong:
            outdoorInfluence = 0.16
        }

        var estimate = comfortAnchor + (outdoorTemperature - comfortAnchor) * outdoorInfluence
        estimate += (feelsLike - outdoorTemperature) * 0.18

        if let humidity, humidity > 70 {
            estimate += 0.8
        } else if let humidity, humidity < 30 {
            estimate -= 0.6
        }

        if let windSpeed, windSpeed > 32 {
            estimate -= 0.6
        }

        return estimate
    }

    private func sleepSignal(_ inputs: ComfortInputs) -> ComfortSignal {
        let tonightLow = inputs.dailyForecast.first?.lowCelsius ?? inputs.temperatureCelsius
        var score = 100.0 - abs(tonightLow - 18) * 6

        if let humidity = inputs.humidityPercent, humidity > 65 {
            score -= (humidity - 65) * 0.7
        }

        if let wind = inputs.windSpeedKmh, wind > 30 {
            score -= 8
        }

        let level = level(for: Int(score.rounded()))
        let message: String
        switch level {
        case .excellent, .good:
            message = "Good conditions for sleep tonight."
        case .moderate:
            message = "Sleep comfort may be mixed tonight."
        case .poor:
            message = "Sleep may feel less comfortable tonight."
        }

        return ComfortSignal(title: "Sleep Comfort", level: level, message: message)
    }

    private func outdoorSignal(index: Int, inputs: ComfortInputs) -> ComfortSignal {
        let level = level(for: index)
        let message: String

        switch level {
        case .excellent:
            message = "Comfortable conditions for most of the day."
        case .good:
            message = "Outdoor comfort looks good with minor weather factors."
        case .moderate:
            message = "Outdoor comfort may vary through the day."
        case .poor:
            message = "Outdoor comfort is limited by current weather."
        }

        return ComfortSignal(title: "Outdoor Comfort", level: level, message: message)
    }

    private func rainSignal(_ precipitationProbability: Double?) -> ComfortSignal {
        guard let precipitationProbability else {
            return ComfortSignal(title: "Rain Risk", level: .good, message: "Rain risk is unavailable.")
        }

        switch precipitationProbability {
        case 70...:
            return ComfortSignal(title: "Rain Risk", level: .poor, message: "Rain risk is high later today.")
        case 40..<70:
            return ComfortSignal(title: "Rain Risk", level: .moderate, message: "Rain risk increases later today.")
        case 20..<40:
            return ComfortSignal(title: "Rain Risk", level: .good, message: "A light rain chance is possible.")
        default:
            return ComfortSignal(title: "Rain Risk", level: .excellent, message: "Rain risk stays low.")
        }
    }

    private func windSignal(_ windSpeed: Double?) -> ComfortSignal {
        guard let windSpeed else {
            return ComfortSignal(title: "Wind Risk", level: .good, message: "Wind data is unavailable.")
        }

        switch windSpeed {
        case 36...:
            return ComfortSignal(title: "Wind Risk", level: .poor, message: "Wind may reduce outdoor comfort.")
        case 24..<36:
            return ComfortSignal(title: "Wind Risk", level: .moderate, message: "Breezy conditions may be noticeable.")
        case 12..<24:
            return ComfortSignal(title: "Wind Risk", level: .good, message: "A light breeze is expected.")
        default:
            return ComfortSignal(title: "Wind Risk", level: .excellent, message: "Wind risk stays low.")
        }
    }

    private func humiditySignal(_ humidity: Double?) -> ComfortSignal {
        guard let humidity else {
            return ComfortSignal(title: "Humidity Comfort", level: .good, message: "Humidity data is unavailable.")
        }

        switch humidity {
        case ..<30:
            return ComfortSignal(title: "Humidity Comfort", level: .moderate, message: "Dry air may feel noticeable.")
        case 30...60:
            return ComfortSignal(title: "Humidity Comfort", level: .excellent, message: "Humidity is in a comfortable range.")
        case 60...72:
            return ComfortSignal(title: "Humidity Comfort", level: .good, message: "Humidity may make the air feel warmer.")
        default:
            return ComfortSignal(title: "Humidity Comfort", level: .moderate, message: "Humidity may make the air feel heavy.")
        }
    }

    private func roomInsight(indoorEstimate: Int, humidity: Double?, level: ComfortLevel) -> String {
        if let humidity, humidity > 70 {
            return "Humidity may make estimated room comfort feel warmer."
        }

        switch indoorEstimate {
        case 20...24 where level == .excellent || level == .good:
            return "Estimated room comfort looks steady."
        case 25...:
            return "Estimated room comfort may feel warm."
        case ..<17:
            return "Estimated room comfort may feel cool."
        default:
            return "Estimated room comfort looks manageable."
        }
    }

    private func outdoorInsight(level: ComfortLevel, rainRisk: ComfortSignal, windRisk: ComfortSignal, uvIndex: Double?) -> String {
        if rainRisk.level == .poor || rainRisk.level == .moderate {
            return rainRisk.message
        }

        if windRisk.level == .poor || windRisk.level == .moderate {
            return windRisk.message
        }

        if let uvIndex, uvIndex >= 7 {
            return "UV is elevated during brighter hours."
        }

        return outdoorSignal(index: levelIndex(level), inputs: placeholderInputs).message
    }

    private func insights(
        level: ComfortLevel,
        humidity: Double?,
        rainRisk: ComfortSignal,
        windRisk: ComfortSignal,
        sleepComfort: ComfortSignal
    ) -> [String] {
        var values: [String] = []

        values.append(outdoorSignal(index: levelIndex(level), inputs: placeholderInputs).message)

        if let humidity, humidity > 60 {
            values.append("Humidity may make the air feel warmer.")
        }

        if rainRisk.level == .moderate || rainRisk.level == .poor {
            values.append(rainRisk.message)
        }

        if windRisk.level == .moderate || windRisk.level == .poor {
            values.append(windRisk.message)
        }

        values.append(sleepComfort.message)

        return Array(NSOrderedSet(array: values).compactMap { $0 as? String }.prefix(4))
    }

    private func outlookValues(_ days: [ComfortForecastDay]) -> (
        summary: String,
        trend: String,
        bestComfortDay: String,
        rainiestDay: String,
        warmestDay: String,
        coolestNight: String,
        averageHigh: Int,
        peakRainChance: Int
    ) {
        guard !days.isEmpty else {
            return (
                "Available forecast data is limited.",
                "Comfort trend is unavailable.",
                "--",
                "--",
                "--",
                "--",
                0,
                0
            )
        }

        let averageHigh = days.map(\.highCelsius).reduce(0, +) / Double(days.count)
        let bestDay = days.max { dailyComfortScore($0) < dailyComfortScore($1) }
        let rainiest = days.max { ($0.precipitationProbability ?? 0) < ($1.precipitationProbability ?? 0) }
        let warmest = days.max { $0.highCelsius < $1.highCelsius }
        let coolest = days.min { $0.lowCelsius < $1.lowCelsius }
        let peakRain = Int((rainiest?.precipitationProbability ?? 0).rounded())
        let summary: String

        if peakRain >= 60 {
            summary = "The next week has a wetter comfort pattern."
        } else if averageHigh >= 28 {
            summary = "The next week trends warm for comfort."
        } else if averageHigh <= 10 {
            summary = "The next week trends cool for comfort."
        } else {
            summary = "The next week has a manageable comfort pattern."
        }

        let trend: String
        if let first = days.first?.highCelsius, let last = days.last?.highCelsius {
            let delta = last - first
            if delta >= 3 {
                trend = "Comfort may feel warmer later in the forecast."
            } else if delta <= -3 {
                trend = "Comfort may feel cooler later in the forecast."
            } else {
                trend = "Comfort looks fairly steady across the forecast."
            }
        } else {
            trend = "Comfort trend is based on available forecast days."
        }

        return (
            summary,
            trend,
            bestDay?.label ?? "--",
            rainiest?.label ?? "--",
            warmest?.label ?? "--",
            coolest?.label ?? "--",
            Int(averageHigh.rounded()),
            peakRain
        )
    }

    private func dailyComfortScore(_ day: ComfortForecastDay) -> Int {
        let midday = (day.highCelsius + day.lowCelsius) / 2
        return comfortIndex(
            temperature: midday,
            feelsLike: midday,
            humidity: day.humidityPercent,
            windSpeed: day.windSpeedKmh,
            precipitationProbability: day.precipitationProbability,
            uvIndex: day.uvIndex,
            pressure: nil
        )
    }

    private func levelIndex(_ level: ComfortLevel) -> Int {
        switch level {
        case .excellent:
            92
        case .good:
            78
        case .moderate:
            60
        case .poor:
            40
        }
    }

    private var placeholderInputs: ComfortInputs {
        ComfortInputs(
            temperatureCelsius: 21,
            feelsLikeCelsius: 21,
            humidityPercent: 45,
            windSpeedKmh: 8,
            precipitationProbability: 0,
            uvIndex: 2,
            pressureHpa: 1015,
            dailyForecast: []
        )
    }
}
