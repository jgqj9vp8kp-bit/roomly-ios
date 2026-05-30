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
    let country: String
    let adminRegion: String?
    let latitude: Double
    let longitude: Double
    let timezone: String?

    var id: String {
        [
            name,
            adminRegion,
            country,
            latitude.rounded(toPlaces: 4).description,
            longitude.rounded(toPlaces: 4).description
        ]
        .compactMap { $0 }
        .joined(separator: "-")
    }

    var coordinate: LocationCoordinate {
        LocationCoordinate(latitude: latitude, longitude: longitude)
    }

    var displayName: String {
        [name, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var fullDisplayName: String {
        var parts = [name]
        if let adminRegion, !adminRegion.isEmpty, adminRegion != name {
            parts.append(adminRegion)
        }
        if !country.isEmpty {
            parts.append(country)
        }
        return parts.joined(separator: ", ")
    }

    var subtitle: String {
        let parts = [adminRegion, country]
            .compactMap { value -> String? in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
        return parts.isEmpty ? coordinate.formatted : parts.joined(separator: ", ")
    }

    init(
        name: String,
        country: String = "United States",
        adminRegion: String? = nil,
        latitude: Double,
        longitude: Double,
        timezone: String? = nil
    ) {
        self.name = name
        self.country = country
        self.adminRegion = adminRegion
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
    }

    init(searchResult: LocationSearchResult) {
        self.init(
            name: searchResult.name,
            country: searchResult.country,
            adminRegion: searchResult.adminRegion,
            latitude: searchResult.latitude,
            longitude: searchResult.longitude,
            timezone: searchResult.timezone
        )
    }
}

enum ManualLocationData {
    static let cities: [ManualLocationCity] = [
        ManualLocationCity(name: "New York", adminRegion: "New York", latitude: 40.7128, longitude: -74.0060, timezone: "America/New_York"),
        ManualLocationCity(name: "Los Angeles", adminRegion: "California", latitude: 34.0522, longitude: -118.2437, timezone: "America/Los_Angeles"),
        ManualLocationCity(name: "Chicago", adminRegion: "Illinois", latitude: 41.8781, longitude: -87.6298, timezone: "America/Chicago"),
        ManualLocationCity(name: "Miami", adminRegion: "Florida", latitude: 25.7617, longitude: -80.1918, timezone: "America/New_York"),
        ManualLocationCity(name: "Austin", adminRegion: "Texas", latitude: 30.2672, longitude: -97.7431, timezone: "America/Chicago"),
        ManualLocationCity(name: "Seattle", adminRegion: "Washington", latitude: 47.6062, longitude: -122.3321, timezone: "America/Los_Angeles"),
        ManualLocationCity(name: "Boston", adminRegion: "Massachusetts", latitude: 42.3601, longitude: -71.0589, timezone: "America/New_York"),
        ManualLocationCity(name: "San Francisco", adminRegion: "California", latitude: 37.7749, longitude: -122.4194, timezone: "America/Los_Angeles")
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
        static let selectedCountry = "selectedCountry"
        static let selectedAdminRegion = "selectedAdminRegion"
        static let selectedCityLatitude = "selectedCityLatitude"
        static let selectedCityLongitude = "selectedCityLongitude"
        static let selectedTimezone = "selectedTimezone"
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
            selectedManualCity?.fullDisplayName ?? "Manual Location"
        case .gps:
            gpsDisplayName
        case .none:
            "Location not enabled"
        }
    }

    /// Concise, single-line city label for the onboarding map illustration.
    /// Falls back to a neutral placeholder until the user grants GPS or
    /// selects a city — it must never display a hardcoded default city.
    var onboardingLocationDisplayName: String {
        switch locationSource {
        case .manual:
            return selectedManualCity?.name ?? Self.onboardingLocationPlaceholder
        case .gps:
            if let locationName, !locationName.isEmpty, locationName != Self.gpsFallbackName {
                return locationName
            }
            return Self.onboardingLocationPlaceholder
        case .none:
            return Self.onboardingLocationPlaceholder
        }
    }

    static let onboardingLocationPlaceholder = "Your Location"
    private static let gpsFallbackName = "Current Location"

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
            Self.gpsFallbackName
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
            locationName = await service.reverseGeocode(location) ?? Self.gpsFallbackName
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

    func selectManualLocation(_ result: LocationSearchResult) {
        selectManualCity(ManualLocationCity(searchResult: result))
    }

    func clearManualLocation() {
        selectedManualCity = nil
        defaults.removeObject(forKey: StorageKey.selectedCityName)
        defaults.removeObject(forKey: StorageKey.selectedCountry)
        defaults.removeObject(forKey: StorageKey.selectedAdminRegion)
        defaults.removeObject(forKey: StorageKey.selectedCityLatitude)
        defaults.removeObject(forKey: StorageKey.selectedCityLongitude)
        defaults.removeObject(forKey: StorageKey.selectedTimezone)
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
        defaults.set(city.country, forKey: StorageKey.selectedCountry)
        if let adminRegion = city.adminRegion {
            defaults.set(adminRegion, forKey: StorageKey.selectedAdminRegion)
        } else {
            defaults.removeObject(forKey: StorageKey.selectedAdminRegion)
        }
        defaults.set(city.latitude, forKey: StorageKey.selectedCityLatitude)
        defaults.set(city.longitude, forKey: StorageKey.selectedCityLongitude)
        if let timezone = city.timezone {
            defaults.set(timezone, forKey: StorageKey.selectedTimezone)
        } else {
            defaults.removeObject(forKey: StorageKey.selectedTimezone)
        }
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
            let country = defaults.string(forKey: StorageKey.selectedCountry) ?? "United States"
            let adminRegion = defaults.string(forKey: StorageKey.selectedAdminRegion)
            let latitude = defaults.double(forKey: StorageKey.selectedCityLatitude)
            let longitude = defaults.double(forKey: StorageKey.selectedCityLongitude)
            let timezone = defaults.string(forKey: StorageKey.selectedTimezone)

            if latitude != 0 || longitude != 0 {
                selectedManualCity = ManualLocationCity(
                    name: cityName,
                    country: country,
                    adminRegion: adminRegion,
                    latitude: latitude,
                    longitude: longitude,
                    timezone: timezone
                )
            }
        }

        if locationSource == .manual, selectedManualCity == nil {
            locationSource = .none
            persistLocationSource()
        }
    }
}
