//
//  RoutineReminder.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//

import Foundation

struct RoutineReminder: Identifiable, Codable, RecurringSchedule {
    var id = UUID()
    var title: String
    /// Start time. For all-day reminders this is the start of the day.
    /// For repeating reminders this is the first occurrence.
    var date: Date
    /// The routine this reminder is for.
    var routineId: UUID? = nil
    /// Optional end time (ignored when all-day).
    var endDate: Date? = nil
    var isAllDay = false
    /// Minutes before `date` to send a notification; nil = no notification.
    /// For all-day reminders the alert is based on 9 AM that day.
    var notifyMinutesBefore: Int? = nil
    /// nil = happens once.
    var recurrence: Recurrence? = nil
    /// Repeating reminders: the days (start of day) that were checked off.
    var completedOccurrences: [Date] = []
    /// One-time reminders: whether it's done. For an occurrence copy
    /// (from `occurrence(on:)`), whether that day is done.
    var isComplete = false

    enum CodingKeys: String, CodingKey {
        case id, title, date, routineId, endDate, isAllDay, notifyMinutesBefore
        case recurrence, completedOccurrences, isComplete
    }

    var timeText: String {
        ScheduleText.time(start: date, end: endDate, isAllDay: isAllDay)
    }

    var dateText: String {
        date.formatted(
            .dateTime.weekday(.abbreviated)
                .month(.abbreviated)
                .day()
        )
    }

    var notificationDate: Date? {
        ScheduleText.notificationDate(start: date, isAllDay: isAllDay, minutesBefore: notifyMinutesBefore)
    }

    func prepared(forOccurrenceOn day: Date) -> RoutineReminder {
        guard recurrence != nil else { return self }

        var copy = self
        copy.isComplete = completedOccurrences.contains(Calendar.current.startOfDay(for: day))
        return copy
    }
}

// Custom decoding so reminders saved before the newer fields existed still load.
extension RoutineReminder {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        date = try c.decode(Date.self, forKey: .date)
        routineId = try c.decodeIfPresent(UUID.self, forKey: .routineId)
        endDate = try c.decodeIfPresent(Date.self, forKey: .endDate)
        isAllDay = try c.decodeIfPresent(Bool.self, forKey: .isAllDay) ?? false
        notifyMinutesBefore = try c.decodeIfPresent(Int.self, forKey: .notifyMinutesBefore)
        recurrence = try c.decodeIfPresent(Recurrence.self, forKey: .recurrence)
        completedOccurrences = try c.decodeIfPresent([Date].self, forKey: .completedOccurrences) ?? []
        isComplete = try c.decodeIfPresent(Bool.self, forKey: .isComplete) ?? false
    }
}

/// Shared formatting for reminders and appointments.
enum ScheduleText {
    /// Hour of day that all-day notifications are based on.
    static let allDayAlertHour = 9

    /// "All day", "7:00 PM", or "7:00 – 8:00 PM".
    static func time(start: Date, end: Date?, isAllDay: Bool) -> String {
        if isAllDay {
            return "All day"
        }
        if let end, end > start {
            return (start..<end).formatted(.interval.hour().minute())
        }
        return start.formatted(date: .omitted, time: .shortened)
    }

    static func notificationDate(start: Date, isAllDay: Bool, minutesBefore: Int?) -> Date? {
        guard let minutesBefore else { return nil }

        let base: Date
        if isAllDay {
            base = Calendar.current.date(
                bySettingHour: allDayAlertHour,
                minute: 0,
                second: 0,
                of: start
            ) ?? start
        } else {
            base = start
        }
        return base.addingTimeInterval(-Double(minutesBefore) * 60)
    }
}
