import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case empty(String)
        case failed(String)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var dashboard: WeatherDashboard?
    @Published private(set) var fallbackNotice: String?
    @Published private(set) var roomSettings: RoomSettings

    private let service: WeatherService
    private let fallbackService: WeatherService
    private var activeLocation: WeatherLocation?
    private(set) var temperatureUnit: TemperatureUnit

    init(
        service: WeatherService = OpenMeteoWeatherService(),
        fallbackService: WeatherService = MockWeatherService(),
        temperatureUnit: TemperatureUnit = .fahrenheit
    ) {
        self.service = service
        self.fallbackService = fallbackService
        self.temperatureUnit = temperatureUnit
        self.roomSettings = RoomSettings.load()
    }

    var isLoading: Bool {
        if case .loading = phase {
            true
        } else {
            false
        }
    }

    func loadIfNeeded(for location: WeatherLocation? = nil) async {
        updateActiveLocation(location)
        guard dashboard == nil else { return }
        await reload()
    }

    func reload(for location: WeatherLocation? = nil, unit: TemperatureUnit? = nil) async {
        updateActiveLocation(location)

        if let unit {
            temperatureUnit = unit
        }

        phase = .loading
        fallbackNotice = nil

        guard let activeLocation else {
            await loadFallback(
                reason: WeatherServiceError.missingLocation.localizedDescription,
                location: fallbackLocation()
            )
            return
        }

        do {
            let response = try await service.fetchDashboard(for: activeLocation, unit: temperatureUnit, roomSettings: roomSettings)

            guard !response.dashboardMetrics.isEmpty || !response.weatherMetrics.isEmpty else {
                dashboard = nil
                phase = .empty("No Weather Insights are available yet.")
                return
            }

            dashboard = response
            phase = .loaded
        } catch {
            await loadFallback(
                reason: "Live weather is temporarily unavailable. Showing mock fallback data.",
                location: activeLocation
            )
        }
    }

    private func updateActiveLocation(_ location: WeatherLocation?) {
        if let location {
            activeLocation = location
        }
    }

    private func loadFallback(reason: String, location: WeatherLocation) async {
        do {
            let response = try await fallbackService.fetchDashboard(for: location, unit: temperatureUnit, roomSettings: roomSettings)
            dashboard = response
            fallbackNotice = reason
            phase = .loaded
        } catch {
            dashboard = nil
            fallbackNotice = nil
            phase = .failed("Weather Insights are temporarily unavailable. Please try again in a moment.")
        }
    }

    private func fallbackLocation() -> WeatherLocation {
        WeatherLocation(
            name: "Location not enabled",
            latitude: 40.7128,
            longitude: -74.0060,
            source: .none
        )
    }

    func saveRoomSettings(_ settings: RoomSettings) {
        settings.save()
        roomSettings = settings
    }

    func resetRoomSettings() {
        RoomSettings.reset()
        roomSettings = .defaults
    }
}
