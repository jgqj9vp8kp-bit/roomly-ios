import Foundation
import OSLog

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Roomly"

    static let weather = Logger(subsystem: subsystem, category: "Weather")
    static let location = Logger(subsystem: subsystem, category: "Location")
    static let geocoding = Logger(subsystem: subsystem, category: "Geocoding")
    static let subscription = Logger(subsystem: subsystem, category: "Subscription")
    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
}
