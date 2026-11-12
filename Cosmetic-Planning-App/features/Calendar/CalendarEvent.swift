//
//  CalendarEvent.swift
//  Cosmetic-Planning-App
//
//  A display model that lets the calendar draw reminders and appointments
//  the same way (bars in Month, timed blocks in Week and Day).
//

import SwiftUI

// MARK: - Tint

enum CalendarEventTint: CaseIterable {
    case mint, rose, lilac, peach

    var fill: Color {
        switch self {
        case .mint: AppColor.mint
        case .rose: AppColor.rose
        case .lilac: AppColor.lilac
        case .peach: AppColor.peach
        }
    }

    /// Darker shade of the fill, used for text and borders.
    var text: Color {
        switch self {
        case .mint: Color(hex: 0x4E6A54)
        case .rose: Color(hex: 0x8A4F5F)
        case .lilac: Color(hex: 0x5E5587)
        case .peach: Color(hex: 0x8C5843)
        }
    }

    /// Reminders get a stable color based on their id, so the same reminder
    /// is always the same color. Rose is reserved for appointments.
    static func reminderTint(for id: UUID) -> CalendarEventTint {
        let options: [CalendarEventTint] = [.mint, .lilac, .peach]
        return options[Int(id.uuid.0) % options.count]
    }
}

// MARK: - Event

struct CalendarEvent: Identifiable, Hashable {
    enum Kind: Hashable {
        case routine
        case appointment
    }

    /// Unique per occurrence ("<source id>-<day>"), since a repeating
    /// item shows up on many days.
    let id: String
    /// The reminder's or appointment's own id.
    let sourceId: UUID
    let kind: Kind
    let title: String
    let start: Date
    let end: Date?
    let detail: String?
    let isComplete: Bool
    let isAllDay: Bool
    let isRepeating: Bool
    let tint: CalendarEventTint

    static func occurrenceId(_ sourceId: UUID, _ start: Date) -> String {
        let day = Calendar.current.startOfDay(for: start)
        return "\(sourceId.uuidString)-\(Int(day.timeIntervalSince1970))"
    }

    /// "8:00 AM" or "All day"
    var startTimeText: String {
        isAllDay ? "All day" : start.formatted(date: .omitted, time: .shortened)
    }

    /// "8:00 – 8:15 AM · 4 steps" (or "All day · 4 steps")
    var subtitleText: String {
        var text = ScheduleText.time(start: start, end: end, isAllDay: isAllDay)
        if let detail, !detail.isEmpty {
            text += " · \(detail)"
        }
        return text
    }
}

extension CalendarEvent {
    /// `stepCount` comes from the linked routine, shown as "4 steps".
    init(reminder: RoutineReminder, stepCount: Int? = nil) {
        self.init(
            id: Self.occurrenceId(reminder.id, reminder.date),
            sourceId: reminder.id,
            kind: .routine,
            title: reminder.title,
            start: reminder.date,
            end: reminder.isAllDay ? nil : reminder.endDate,
            detail: stepCount.map { $0 == 1 ? "1 step" : "\($0) steps" },
            isComplete: reminder.isComplete,
            isAllDay: reminder.isAllDay,
            isRepeating: reminder.recurrence != nil,
            tint: .reminderTint(for: reminder.id)
        )
    }

    init(appointment: Appointment) {
        self.init(
            id: Self.occurrenceId(appointment.id, appointment.date),
            sourceId: appointment.id,
            kind: .appointment,
            title: appointment.title,
            start: appointment.date,
            end: appointment.isAllDay ? nil : appointment.endDate,
            detail: appointment.location,
            isComplete: appointment.isComplete,
            isAllDay: appointment.isAllDay,
            isRepeating: appointment.recurrence != nil,
            tint: .rose
        )
    }
}
