//
//  Appointment.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//

import Foundation

struct Appointment: Identifiable, Codable, RecurringSchedule {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var location: String?
    var notes: String?
    /// Optional end time (ignored when all-day).
    var endDate: Date? = nil
    var isAllDay: Bool = false
    /// Minutes before `date` to send a notification; nil = none.
    var notifyMinutesBefore: Int? = nil
    /// nil = happens once. `date` is the first occurrence.
    var recurrence: Recurrence? = nil
    var isComplete: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case location
        case notes
        case endDate = "end_date"
        case isAllDay = "is_all_day"
        case notifyMinutesBefore = "notify_minutes_before"
        case recurrence
        case isComplete = "is_complete"
    }

    func prepared(forOccurrenceOn day: Date) -> Appointment {
        self
    }

    var timeText: String {
        ScheduleText.time(start: date, end: endDate, isAllDay: isAllDay)
    }

    var notificationDate: Date? {
        ScheduleText.notificationDate(start: date, isAllDay: isAllDay, minutesBefore: notifyMinutesBefore)
    }

    var dateText: String {
        date.formatted(
            .dateTime.weekday(.abbreviated)
                .month(.abbreviated)
                .day()
        )
    }
}

// Tolerates rows without the newer columns.
extension Appointment {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        date = try c.decode(Date.self, forKey: .date)
        location = try c.decodeIfPresent(String.self, forKey: .location)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        endDate = try c.decodeIfPresent(Date.self, forKey: .endDate)
        isAllDay = try c.decodeIfPresent(Bool.self, forKey: .isAllDay) ?? false
        notifyMinutesBefore = try c.decodeIfPresent(Int.self, forKey: .notifyMinutesBefore)
        recurrence = try c.decodeIfPresent(Recurrence.self, forKey: .recurrence)
        isComplete = try c.decodeIfPresent(Bool.self, forKey: .isComplete) ?? false
    }
}
