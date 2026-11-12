//
//  RoutineReminderStore.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RoutineReminderStore {
    static let shared = RoutineReminderStore()

    /// The saved reminders. Repeating ones appear once here; use
    /// `reminders(on:)` or `occurrences(from:to:)` for calendar days.
    private(set) var reminders: [RoutineReminder] = []

    private let storageKey = "calendar.reminders.v1"

    private init() {
        load()

        // Repeating reminders only have their next few notifications queued,
        // so top them up each launch.
        Task { await rescheduleAllNotifications() }
    }

    func load() {
        guard
            let data = UserDefaults.standard
                .string(forKey: storageKey)?
                .data(using: .utf8),
            let saved = try? JSONDecoder().decode(
                [RoutineReminder].self,
                from: data
            )
        else {
            reminders = []
            return
        }

        reminders = saved
    }

    func add(_ reminder: RoutineReminder) {
        reminders.append(reminder)
        save()
        Task { await rescheduleNotifications(for: reminder) }
    }

    /// For a repeating reminder this only checks off `day`.
    func toggleComplete(id: UUID, on day: Date = Date()) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else {
            return
        }

        if reminders[index].recurrence != nil {
            let key = Calendar.current.startOfDay(for: day)
            if let done = reminders[index].completedOccurrences.firstIndex(of: key) {
                reminders[index].completedOccurrences.remove(at: done)
            } else {
                reminders[index].completedOccurrences.append(key)
            }
        } else {
            reminders[index].isComplete.toggle()
        }

        save()

        let reminder = reminders[index]
        Task { await rescheduleNotifications(for: reminder) }
    }

    private func save() {
        guard
            let data = try? JSONEncoder().encode(reminders),
            let string = String(data: data, encoding: .utf8)
        else {
            return
        }

        UserDefaults.standard.set(string, forKey: storageKey)
    }

    // MARK: - Occurrences

    /// Reminders happening on `day`, with repeating ones moved to that day.
    func reminders(on day: Date) -> [RoutineReminder] {
        reminders
            .compactMap { $0.occurrence(on: day) }
            .sorted { $0.date < $1.date }
    }

    func occurrences(from start: Date, to end: Date) -> [RoutineReminder] {
        reminders.flatMap { $0.occurrences(from: start, to: end) }
    }

    var todayReminders: [RoutineReminder] {
        reminders(on: Date())
    }

    /// Next 30 days, starting tomorrow.
    var upcomingReminders: [RoutineReminder] {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let end = calendar.date(byAdding: .day, value: 30, to: tomorrow)!

        return occurrences(from: tomorrow, to: end)
            .sorted { $0.date < $1.date }
    }

    // MARK: - Notifications

    private func rescheduleAllNotifications() async {
        for reminder in reminders {
            await rescheduleNotifications(for: reminder)
        }
    }

    /// Queues notifications for the upcoming, not-yet-done occurrences.
    private func rescheduleNotifications(for reminder: RoutineReminder) async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let horizon = calendar.date(byAdding: .day, value: 60, to: today) ?? today

        let planned = reminder
            .occurrences(from: today, to: horizon)
            .filter { !$0.isComplete }
            .compactMap { occurrence -> PlannedNotification? in
                guard let fireDate = occurrence.notificationDate else { return nil }
                return PlannedNotification(
                    fireDate: fireDate,
                    title: occurrence.title,
                    body: occurrence.isAllDay
                        ? occurrence.dateText
                        : "Time for your routine · \(occurrence.timeText)"
                )
            }

        await NotificationScheduler.shared.replaceNotifications(for: reminder.id, with: planned)
    }
}
