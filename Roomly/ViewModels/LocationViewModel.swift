import CoreLocation
import Foundation

enum LocationSource: String, CaseIterable {
    case gps
    case manual
    case none

    var title: String {
        switch self {
        case .gps:
            "GPS"
        case .manual:
            "Manual"
        case .none:
            "None"
        }
    }
}

enum LocationPermissionStatus: Equatable {
    case notDetermined
    case authorizedWhenInUse
    case denied
    case restricted

    init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self = .notDetermined
        case .authorizedAlways, .authorizedWhenInUse:
            self = .authorizedWhenInUse
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        @unknown default:
            self = .restricted
        }
    }

    var isAuthorized: Bool {
        self == .authorizedWhenInUse
    }
}

struct LocationCoordinate: Equatable {
    let latitude: Double
    let longitude: Double

    var formatted: String {
        "\(latitude.formatted(.number.precision(.fractionLength(3)))), \(longitude.formatted(.number.precision(.fractionLength(3))))"
    }
}

struct ManualLocationCity: Identifiable, Equatable {
    let name: String
    let latitude: Double
    let longitude: Double

    var id: String { name }

    var coordinate: LocationCoordinate {
        LocationCoordinate(latitude: latitude, longitude: longitude)
    }
}

enum ManualLocationData {
    static let cities: [ManualLocationCity] = [
        ManualLocationCity(name: "New York", latitude: 40.7128, longitude: -74.0060),
        ManualLocationCity(name: "Los Angeles", latitude: 34.0522, longitude: -118.2437),
        ManualLocationCity(name: "Chicago", latitude: 41.8781, longitude: -87.6298),
        ManualLocationCity(name: "Miami", latitude: 25.7617, longitude: -80.1918),
        ManualLocationCity(name: "Austin", latitude: 30.2672, longitude: -97.7431),
        ManualLocationCity(name: "Seattle", latitude: 47.6062, longitude: -122.3321),
        ManualLocationCity(name: "Boston", latitude: 42.3601, longitude: -71.0589),
        ManualLocationCity(name: "San Francisco", latitude: 37.7749, longitude: -122.4194)
    ]
}

@MainActor
final class LocationViewModel: ObservableObject {
    @Published private(set) var permissionStatus: LocationPermissionStatus
    @Published private(set) var currentCoordinates: LocationCoordinate?
    @Published private(set) var locationName: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var selectedManualCity: ManualLocationCity?
    @Published private(set) var locationSource: LocationSource = .none

    private let service: LocationService
    private let defaults: UserDefaults

    private enum StorageKey {
        static let selectedCityName = "selectedCityName"
        static let selectedCityLatitude = "selectedCityLatitude"
        static let selectedCityLongitude = "selectedCityLongitude"
        static let locationSource = "locationSource"
    }

    init(service: LocationService = LocationService(), defaults: UserDefaults = .standard) {
        self.service = service
        self.defaults = defaults
        self.permissionStatus = LocationPermissionStatus(service.authorizationStatus)
        restorePersistedLocation()
    }

    var displayName: String {
        activeLocationDisplayName
    }

    var activeLocationDisplayName: String {
        switch locationSource {
        case .manual:
            selectedManualCity?.name ?? "Manual Location"
        case .gps:
            gpsDisplayName
        case .none:
            "Location not enabled"
        }
    }

    var activeCoordinates: LocationCoordinate? {
        switch locationSource {
        case .manual:
            selectedManualCity?.coordinate
        case .gps:
            currentCoordinates
        case .none:
            nil
        }
    }

    var activeWeatherLocation: WeatherLocation? {
        guard let activeCoordinates else { return nil }
        return WeatherLocation(
            name: activeLocationDisplayName,
            latitude: activeCoordinates.latitude,
            longitude: activeCoordinates.longitude,
            source: locationSource
        )
    }

    var activeLocationKey: String {
        activeWeatherLocation?.cacheKey ?? "none"
    }

    var hasUsableLocation: Bool {
        locationSource != .none && activeCoordinates != nil
    }

    var isManualLocationSelected: Bool {
        locationSource == .manual && selectedManualCity != nil
    }

    private var gpsDisplayName: String {
        if let locationName {
            locationName
        } else if let currentCoordinates {
            currentCoordinates.formatted
        } else {
            "Current Location"
        }
    }

    func refreshAuthorizationStatus() {
        permissionStatus = LocationPermissionStatus(service.authorizationStatus)
        if !permissionStatus.isAuthorized, locationSource == .gps {
            locationSource = .none
            persistLocationSource()
        }
    }

    @discardableResult
    func requestPermissionAndFetchLocation() async -> Bool {
        isLoading = true
        errorMessage = nil

        let status = await service.requestWhenInUseAuthorization()
        permissionStatus = LocationPermissionStatus(status)

        guard permissionStatus.isAuthorized else {
            isLoading = false
            currentCoordinates = nil
            locationName = nil
            if locationSource == .gps {
                setLocationSource(.none)
            }
            errorMessage = fallbackMessage(for: permissionStatus)
            return false
        }

        do {
            let location = try await service.requestCurrentLocation()
            currentCoordinates = LocationCoordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            locationName = await service.reverseGeocode(location) ?? "Current Location"
            setLocationSource(.gps)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    func fetchLocationIfAuthorized() async {
        refreshAuthorizationStatus()
        guard permissionStatus.isAuthorized, locationSource != .manual, currentCoordinates == nil else { return }
        _ = await requestPermissionAndFetchLocation()
    }

    func selectManualCity(_ city: ManualLocationCity) {
        isLoading = false
        errorMessage = nil
        selectedManualCity = city
        setLocationSource(.manual)
        persistManualCity(city)
    }

    func clearManualLocation() {
        selectedManualCity = nil
        defaults.removeObject(forKey: StorageKey.selectedCityName)
        defaults.removeObject(forKey: StorageKey.selectedCityLatitude)
        defaults.removeObject(forKey: StorageKey.selectedCityLongitude)
        if locationSource == .manual {
            setLocationSource(.none)
        }
    }

    private func fallbackMessage(for status: LocationPermissionStatus) -> String {
        switch status {
        case .notDetermined:
            "Location has not been requested yet."
        case .authorizedWhenInUse:
            ""
        case .denied:
            "Location permission was denied. You can choose a city manually."
        case .restricted:
            "Location access is restricted on this device. You can choose a city manually."
        }
    }

    private func setLocationSource(_ source: LocationSource) {
        locationSource = source
        persistLocationSource()
    }

    private func persistManualCity(_ city: ManualLocationCity) {
        defaults.set(city.name, forKey: StorageKey.selectedCityName)
        defaults.set(city.latitude, forKey: StorageKey.selectedCityLatitude)
        defaults.set(city.longitude, forKey: StorageKey.selectedCityLongitude)
    }

    private func persistLocationSource() {
        defaults.set(locationSource.rawValue, forKey: StorageKey.locationSource)
    }

    private func restorePersistedLocation() {
        if let rawSource = defaults.string(forKey: StorageKey.locationSource),
           let source = LocationSource(rawValue: rawSource) {
            locationSource = source
        }

        if let cityName = defaults.string(forKey: StorageKey.selectedCityName) {
            let latitude = defaults.double(forKey: StorageKey.selectedCityLatitude)
            let longitude = defaults.double(forKey: StorageKey.selectedCityLongitude)

            if latitude != 0 || longitude != 0 {
                selectedManualCity = ManualLocationCity(name: cityName, latitude: latitude, longitude: longitude)
            }
        }

        if locationSource == .manual, selectedManualCity == nil {
            locationSource = .none
            persistLocationSource()
        }
    }
}
