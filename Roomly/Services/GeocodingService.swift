import Foundation

struct LocationSearchResult: Identifiable, Equatable {
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
}

protocol GeocodingService {
    func searchLocations(query: String) async throws -> [LocationSearchResult]
}

enum GeocodingServiceError: LocalizedError {
    case invalidQuery
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            "Enter a city or location name to search."
        case .invalidResponse:
            "Location search came back in an unexpected format."
        }
    }
}

struct OpenMeteoGeocodingService: GeocodingService {
    var session: URLSession = .shared

    func searchLocations(query: String) async throws -> [LocationSearchResult] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            throw GeocodingServiceError.invalidQuery
        }

        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "name", value: trimmedQuery),
            URLQueryItem(name: "count", value: "12"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = components?.url else {
            throw GeocodingServiceError.invalidQuery
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw GeocodingServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(OpenMeteoGeocodingResponse.self, from: data)
        return decoded.results?.map {
            LocationSearchResult(
                name: $0.name,
                country: $0.country ?? "",
                adminRegion: $0.admin1,
                latitude: $0.latitude,
                longitude: $0.longitude,
                timezone: $0.timezone
            )
        } ?? []
    }
}

private struct OpenMeteoGeocodingResponse: Decodable {
    let results: [OpenMeteoGeocodingResult]?
}

private struct OpenMeteoGeocodingResult: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
    let timezone: String?
}
