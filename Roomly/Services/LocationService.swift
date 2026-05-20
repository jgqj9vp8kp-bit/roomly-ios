import CoreLocation
import Foundation

enum LocationServiceError: LocalizedError {
    case permissionDenied
    case restricted
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Location permission is not enabled."
        case .restricted:
            "Location access is restricted on this device."
        case .locationUnavailable:
            "Current location is unavailable right now."
        }
    }
}

final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    func requestWhenInUseAuthorization() async -> CLAuthorizationStatus {
        let currentStatus = manager.authorizationStatus
        guard currentStatus == .notDetermined else {
            return currentStatus
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func requestCurrentLocation() async throws -> CLLocation {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation
                manager.requestLocation()
            }
        case .restricted:
            throw LocationServiceError.restricted
        case .denied, .notDetermined:
            throw LocationServiceError.permissionDenied
        @unknown default:
            throw LocationServiceError.locationUnavailable
        }
    }

    func reverseGeocode(_ location: CLLocation) async -> String? {
        await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                let placemark = placemarks?.first
                let name = placemark?.locality ?? placemark?.administrativeArea ?? placemark?.country
                continuation.resume(returning: name)
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let authorizationContinuation else { return }
        self.authorizationContinuation = nil
        authorizationContinuation.resume(returning: manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let locationContinuation else { return }
        self.locationContinuation = nil
        locationContinuation.resume(returning: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let locationContinuation else { return }
        self.locationContinuation = nil
        locationContinuation.resume(throwing: error)
    }
}
