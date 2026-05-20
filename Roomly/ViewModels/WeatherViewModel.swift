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

    private let service: WeatherService
    private(set) var temperatureUnit: TemperatureUnit

    init(service: WeatherService = MockWeatherService(), temperatureUnit: TemperatureUnit = .celsius) {
        self.service = service
        self.temperatureUnit = temperatureUnit
    }

    var isLoading: Bool {
        if case .loading = phase {
            true
        } else {
            false
        }
    }

    func loadIfNeeded() async {
        guard dashboard == nil else { return }
        await reload()
    }

    func reload(unit: TemperatureUnit? = nil) async {
        if let unit {
            temperatureUnit = unit
        }

        phase = .loading

        do {
            let response = try await service.fetchDashboard(unit: temperatureUnit)

            guard !response.dashboardMetrics.isEmpty || !response.weatherMetrics.isEmpty else {
                dashboard = nil
                phase = .empty("No Weather Insights are available yet.")
                return
            }

            dashboard = response
            phase = .loaded
        } catch {
            dashboard = nil
            phase = .failed(error.localizedDescription)
        }
    }
}
