//
//  RoomlyTests.swift
//  RoomlyTests
//
//  Created by Дмитрий on 17.05.26.
//

import XCTest
@testable import Roomly

final class RoomlyTests: XCTestCase {
    func testComfortEngineScoresComfortableWeatherHighly() {
        let report = ComfortEngine().evaluate(
            ComfortInputs(
                temperatureCelsius: 22,
                feelsLikeCelsius: 22,
                humidityPercent: 45,
                windSpeedKmh: 8,
                precipitationProbability: 5,
                uvIndex: 3,
                pressureHpa: 1015,
                dailyForecast: [
                    ComfortForecastDay(label: "Today", highCelsius: 24, lowCelsius: 18, precipitationProbability: 5, windSpeedKmh: 8, humidityPercent: 45, uvIndex: 3)
                ]
            )
        )

        XCTAssertGreaterThanOrEqual(report.index, 85)
        XCTAssertEqual(report.level, .excellent)
        XCTAssertEqual(report.sleepComfort.level, .excellent)
    }

    func testComfortEnginePenalizesHighHumidityAndRainRisk() {
        let report = ComfortEngine().evaluate(
            ComfortInputs(
                temperatureCelsius: 29,
                feelsLikeCelsius: 34,
                humidityPercent: 82,
                windSpeedKmh: 18,
                precipitationProbability: 75,
                uvIndex: 7,
                pressureHpa: 1008,
                dailyForecast: [
                    ComfortForecastDay(label: "Today", highCelsius: 31, lowCelsius: 25, precipitationProbability: 75, windSpeedKmh: 18, humidityPercent: 82, uvIndex: 7)
                ]
            )
        )

        XCTAssertLessThan(report.index, 70)
        XCTAssertEqual(report.rainRisk.level, .poor)
        XCTAssertTrue(report.insights.contains("Humidity may make the air feel warmer."))
    }

    func testIndoorEstimateModeratesOutdoorExtremes() {
        let engine = ComfortEngine()
        let hotEstimate = engine.indoorEstimateCelsius(outdoorTemperature: 34, feelsLike: 36, humidity: 40, windSpeed: 8)
        let coldEstimate = engine.indoorEstimateCelsius(outdoorTemperature: 4, feelsLike: 1, humidity: 45, windSpeed: 10)

        XCTAssertLessThan(hotEstimate, 34)
        XCTAssertGreaterThan(coldEstimate, 4)
    }

    func testACPullsIndoorEstimateTowardACTemperature() {
        let engine = ComfortEngine()
        let defaultEstimate = engine.indoorEstimateCelsius(outdoorTemperature: 34, feelsLike: 36, humidity: 45, windSpeed: 8)
        let acEstimate = engine.indoorEstimateCelsius(
            outdoorTemperature: 34,
            feelsLike: 36,
            humidity: 45,
            windSpeed: 8,
            roomSettings: RoomSettings(
                isACOn: true,
                acTemperatureCelsius: 20,
                isHeaterOn: false,
                heaterTemperatureCelsius: nil,
                isFanOn: false,
                fanCoolingEffectCelsius: nil,
                insulationType: .medium
            )
        )

        XCTAssertLessThan(acEstimate, defaultEstimate)
        XCTAssertLessThan(abs(acEstimate - 20), abs(defaultEstimate - 20))
    }

    func testHeaterPullsIndoorEstimateWarmer() {
        let engine = ComfortEngine()
        let defaultEstimate = engine.indoorEstimateCelsius(outdoorTemperature: 5, feelsLike: 2, humidity: 45, windSpeed: 8)
        let heaterEstimate = engine.indoorEstimateCelsius(
            outdoorTemperature: 5,
            feelsLike: 2,
            humidity: 45,
            windSpeed: 8,
            roomSettings: RoomSettings(
                isACOn: false,
                acTemperatureCelsius: nil,
                isHeaterOn: true,
                heaterTemperatureCelsius: 24,
                isFanOn: false,
                fanCoolingEffectCelsius: nil,
                insulationType: .medium
            )
        )

        XCTAssertGreaterThan(heaterEstimate, defaultEstimate)
    }

    func testFanReducesPerceivedIndoorEstimate() {
        let engine = ComfortEngine()
        let baseSettings = RoomSettings(
            isACOn: false,
            acTemperatureCelsius: nil,
            isHeaterOn: false,
            heaterTemperatureCelsius: nil,
            isFanOn: false,
            fanCoolingEffectCelsius: nil,
            insulationType: .light
        )
        let fanSettings = RoomSettings(
            isACOn: false,
            acTemperatureCelsius: nil,
            isHeaterOn: false,
            heaterTemperatureCelsius: nil,
            isFanOn: true,
            fanCoolingEffectCelsius: 2,
            insulationType: .light
        )
        let baseEstimate = engine.indoorEstimateCelsius(outdoorTemperature: 28, feelsLike: 30, humidity: 55, windSpeed: 8, roomSettings: baseSettings)
        let fanEstimate = engine.indoorEstimateCelsius(outdoorTemperature: 28, feelsLike: 30, humidity: 55, windSpeed: 8, roomSettings: fanSettings)

        XCTAssertLessThan(fanEstimate, baseEstimate)
    }

    func testStrongInsulationReducesOutdoorImpact() {
        let engine = ComfortEngine()
        let lightEstimate = engine.indoorEstimateCelsius(
            outdoorTemperature: 34,
            feelsLike: 34,
            humidity: 45,
            windSpeed: 8,
            roomSettings: RoomSettings(isACOn: false, acTemperatureCelsius: nil, isHeaterOn: false, heaterTemperatureCelsius: nil, isFanOn: false, fanCoolingEffectCelsius: nil, insulationType: .light)
        )
        let strongEstimate = engine.indoorEstimateCelsius(
            outdoorTemperature: 34,
            feelsLike: 34,
            humidity: 45,
            windSpeed: 8,
            roomSettings: RoomSettings(isACOn: false, acTemperatureCelsius: nil, isHeaterOn: false, heaterTemperatureCelsius: nil, isFanOn: false, fanCoolingEffectCelsius: nil, insulationType: .strong)
        )

        XCTAssertLessThan(abs(strongEstimate - 22), abs(lightEstimate - 22))
    }
}
