//
//  CalendarReminderStore.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//



import Foundation
import Observation

@MainActor
@Observable
final class CalendarReminderStore {
    static let shared = CalendarReminderStore()

    private(set) var reminders: [CalendarReminder] = []

    private let storageKey = "calendar.reminders.v1"

    private init() {
        load()
    }

    func load() {
        guard
            let data = UserDefaults.standard
                .string(forKey: storageKey)?
                .data(using: .utf8),
            let saved = try? JSONDecoder().decode(
                [CalendarReminder].self,
                from: data
            )
        else {
            reminders = []
            return
        }

        reminders = saved
    }

    func add(_ reminder: CalendarReminder) {
        reminders.append(reminder)
        save()
    }

    func toggleComplete(id: UUID) {
        guard let index = reminders.firstIndex(
            where: { $0.id == id }
        ) else {
            return
        }

        reminders[index].isComplete.toggle()
        save()
    }

    private func save() {
        guard
            let data = try? JSONEncoder().encode(reminders),
            let string = String(
                data: data,
                encoding: .utf8
            )
        else {
            return
        }

        UserDefaults.standard.set(
            string,
            forKey: storageKey
        )
    }

    var todayReminders: [CalendarReminder] {
        reminders
            .filter {
                Calendar.current.isDateInToday($0.date)
            }
            .sorted { $0.date < $1.date }
    }

    var upcomingReminders: [CalendarReminder] {
        let calendar = Calendar.current
        let startOfTomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: Date())
        )!

        return reminders
            .filter { $0.date >= startOfTomorrow }
            .sorted { $0.date < $1.date }
    }
}
