//
//  Recurrence.swift
//  Cosmetic-Planning-App
//
//  Repeat rules for reminders and appointments, plus the helpers that turn
//  one saved item into its occurrences on the calendar.
//

import Foundation

struct Recurrence: Codable, Hashable {
    enum Frequency: String, Codable, CaseIterable {
        case daily
        case weekdays
        case weekly
        case monthly
        case yearly
    }

    var frequency: Frequency
    /// Weekly only: days of the week, 1 = Sunday … 7 = Saturday.
    /// Empty means "the same weekday as the first occurrence".
    var weekdays: [Int] = []
    /// Last day it can happen (inclusive). nil = repeats forever.
    var until: Date? = nil

    // MARK: - Matching

    func occurs(on day: Date, seriesStart: Date, calendar: Calendar = .current) -> Bool {
        let dayStart = calendar.startOfDay(for: day)
        let firstDay = calendar.startOfDay(for: seriesStart)

        guard dayStart >= firstDay else { return false }
        if let until, dayStart > calendar.startOfDay(for: until) { return false }

        switch frequency {
        case .daily:
            return true

        case .weekdays:
            return (2...6).contains(calendar.component(.weekday, from: dayStart))

        case .weekly:
            let days = weekdays.isEmpty
                ? [calendar.component(.weekday, from: firstDay)]
                : weekdays
            return days.contains(calendar.component(.weekday, from: dayStart))

        case .monthly:
            return calendar.component(.day, from: dayStart)
                == calendar.component(.day, from: firstDay)

        case .yearly:
            let a = calendar.dateComponents([.month, .day], from: dayStart)
            let b = calendar.dateComponents([.month, .day], from: firstDay)
            return a.month == b.month && a.day == b.day
        }
    }

    /// Start times of every occurrence whose day falls in `from ..< to`.
    func occurrences(
        seriesStart: Date,
        from: Date,
        to: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        var result: [Date] = []
        var day = calendar.startOfDay(for: max(from, seriesStart))
        let lastDay = until.map { calendar.startOfDay(for: $0) }

        while day < to {
            if let lastDay, day > lastDay { break }

            if occurs(on: day, seriesStart: seriesStart, calendar: calendar) {
                result.append(Recurrence.sameTime(as: seriesStart, on: day, calendar: calendar))
            }

            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    /// `day` at the hour/minute of `time`.
    static func sameTime(as time: Date, on day: Date, calendar: Calendar = .current) -> Date {
        let parts = calendar.dateComponents([.hour, .minute, .second], from: time)
        return calendar.date(
            bySettingHour: parts.hour ?? 0,
            minute: parts.minute ?? 0,
            second: parts.second ?? 0,
            of: day
        ) ?? day
    }

    // MARK: - Text

    /// "Every week on Tue and Thu, until Dec 1, 2026"
    func summary(for start: Date, includeEnd: Bool = true, calendar: Calendar = .current) -> String {
        var text: String

        switch frequency {
        case .daily:
            text = "Every day"
        case .weekdays:
            text = "Every weekday (Mon–Fri)"
        case .weekly:
            let days = weekdays.isEmpty
                ? [calendar.component(.weekday, from: start)]
                : weekdays.sorted()
            let names = days.map { calendar.shortWeekdaySymbols[$0 - 1] }
            text = "Every week on " + (ListFormatter.localizedString(byJoining: names))
        case .monthly:
            text = "Every month on day \(calendar.component(.day, from: start))"
        case .yearly:
            text = "Every year on " + start.formatted(.dateTime.month(.abbreviated).day())
        }

        if includeEnd, let until {
            text += ", until " + until.formatted(.dateTime.month(.abbreviated).day().year())
        }
        return text
    }
}

// MARK: - Recurring items

/// Shared by RoutineReminder and Appointment so the calendar, Home and
/// notifications can all ask "when does this happen?" the same way.
protocol RecurringSchedule {
    var date: Date { get set }
    var endDate: Date? { get set }
    var recurrence: Recurrence? { get }

    /// Lets a type adjust per-occurrence state on a copy (e.g. completion).
    func prepared(forOccurrenceOn day: Date) -> Self
}

extension RecurringSchedule {
    /// A copy of this item moved to `day`, or nil if it doesn't happen then.
    func occurrence(on day: Date, calendar: Calendar = .current) -> Self? {
        guard let recurrence else {
            return calendar.isDate(date, inSameDayAs: day) ? prepared(forOccurrenceOn: day) : nil
        }
        guard recurrence.occurs(on: day, seriesStart: date, calendar: calendar) else {
            return nil
        }
        return moved(toDay: day, calendar: calendar)
    }

    /// Every occurrence whose day falls in `from ..< to`.
    func occurrences(from: Date, to: Date, calendar: Calendar = .current) -> [Self] {
        guard let recurrence else {
            let day = calendar.startOfDay(for: date)
            return day >= calendar.startOfDay(for: from) && day < to
                ? [prepared(forOccurrenceOn: date)]
                : []
        }
        return recurrence
            .occurrences(seriesStart: date, from: from, to: to, calendar: calendar)
            .map { moved(toDay: $0, calendar: calendar) }
    }

    /// The first occurrence on or after `start` (looks up to a year ahead).
    func nextOccurrence(onOrAfter start: Date, calendar: Calendar = .current) -> Self? {
        let end = calendar.date(byAdding: .day, value: 366, to: start) ?? start
        return occurrences(from: start, to: end, calendar: calendar)
            .first { $0.date >= start }
    }

    private func moved(toDay day: Date, calendar: Calendar) -> Self {
        var copy = self
        let newStart = Recurrence.sameTime(as: date, on: day, calendar: calendar)
        let shift = newStart.timeIntervalSince(date)
        copy.date = newStart
        copy.endDate = endDate?.addingTimeInterval(shift)
        return copy.prepared(forOccurrenceOn: day)
    }
}
