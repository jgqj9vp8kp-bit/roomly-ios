import Foundation
import UserNotifications

@MainActor
final class NotificationsService: ObservableObject {
    enum AuthorizationStatus: Equatable {
        case notDetermined
        case authorized
        case denied
        case provisional
        case ephemeral

        init(_ status: UNAuthorizationStatus) {
            switch status {
            case .notDetermined:
                self = .notDetermined
            case .authorized:
                self = .authorized
            case .denied:
                self = .denied
            case .provisional:
                self = .provisional
            case .ephemeral:
                self = .ephemeral
            @unknown default:
                self = .denied
            }
        }

        var isAuthorized: Bool {
            self == .authorized || self == .provisional || self == .ephemeral
        }
    }

    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined

    private let center: UNUserNotificationCenter
    private static let dailyComfortIdentifier = "roomly.dailyComfort"

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = AuthorizationStatus(settings.authorizationStatus)
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            AppLogger.notifications.error("Authorization request failed: \(error.localizedDescription, privacy: .public)")
            await refreshAuthorizationStatus()
            return false
        }
    }

    func scheduleDailyComfortReminder() async {
        await refreshAuthorizationStatus()
        guard authorizationStatus.isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Roomly Comfort Check"
        content.body = "See today's comfort index and indoor estimate."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: Self.dailyComfortIdentifier, content: content, trigger: trigger)

        do {
            try await center.add(request)
        } catch {
            AppLogger.notifications.error("Schedule failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func cancelScheduledNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyComfortIdentifier])
    }
}
