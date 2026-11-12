//
//  NotificationScheduler.swift
//  Cosmetic-Planning-App
//
//  Schedules local notifications for routine reminders and appointments.
//  Each item gets up to `maxPerItem` one-time notifications with ids
//  "<item id>#0", "<item id>#1", …, so they can all be replaced or
//  cancelled together without looking up what's pending.
//

import Foundation
import UserNotifications

struct PlannedNotification {
    let fireDate: Date
    let title: String
    let body: String
}

@MainActor
final class NotificationScheduler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationScheduler()

    /// iOS keeps at most 64 pending notifications per app, so repeating
    /// items only queue their next few; they're topped up on launch.
    static let maxPerItem = 8

    private let center = UNUserNotificationCenter.current()

    /// Call once at launch so notifications also show while the app is open.
    func configure() {
        center.delegate = self
    }

    /// Replaces everything queued for `id` with the next upcoming items.
    func replaceNotifications(for id: UUID, with planned: [PlannedNotification]) async {
        cancelAll(for: id)

        let upcoming = planned
            .filter { $0.fireDate > Date() }
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(Self.maxPerItem)

        guard !upcoming.isEmpty else { return }
        guard await requestAuthorizationIfNeeded() else { return }

        for (index, item) in upcoming.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: item.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(id.uuidString)#\(index)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Notification: couldn't schedule: \(error.localizedDescription)")
            }
        }
    }

    func cancelAll(for id: UUID) {
        let ids = [id.uuidString] + (0..<Self.maxPerItem).map { "\(id.uuidString)#\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    private func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    // Show the banner even when the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}

// MARK: - Notification options

/// The choices shown in the "Notification" row of the add sheet.
struct NotifyOption: Hashable, Identifiable {
    let minutes: Int?
    let label: String

    var id: String { label }

    static let timed: [NotifyOption] = [
        NotifyOption(minutes: nil, label: "No notification"),
        NotifyOption(minutes: 0, label: "At time of event"),
        NotifyOption(minutes: 5, label: "5 minutes before"),
        NotifyOption(minutes: 10, label: "10 minutes before"),
        NotifyOption(minutes: 30, label: "30 minutes before"),
        NotifyOption(minutes: 60, label: "1 hour before"),
        NotifyOption(minutes: 1440, label: "1 day before"),
    ]

    static let allDay: [NotifyOption] = [
        NotifyOption(minutes: nil, label: "No notification"),
        NotifyOption(minutes: 0, label: "On the day at 9 AM"),
        NotifyOption(minutes: 1440, label: "The day before at 9 AM"),
    ]

    static func options(isAllDay: Bool) -> [NotifyOption] {
        isAllDay ? allDay : timed
    }

    static func label(for minutes: Int?, isAllDay: Bool) -> String {
        options(isAllDay: isAllDay).first { $0.minutes == minutes }?.label
            ?? "\(minutes ?? 0) minutes before"
    }
}
