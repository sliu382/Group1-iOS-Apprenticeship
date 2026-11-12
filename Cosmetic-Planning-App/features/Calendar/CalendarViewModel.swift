//
//  CalendarViewModel.swift
//  Cosmetic-Planning-App
//
//  Owns calendar state (mode, selected date), builds the month/week grids,
//  and merges reminders + appointments into CalendarEvents for the views.
//

import Foundation
import Observation

@MainActor
@Observable
final class CalendarViewModel {

    enum Mode: String, CaseIterable, Identifiable {
        case month = "Month"
        case week = "Week"
        case day = "Day"

        var id: Self { self }
    }

    // MARK: - State

    var mode: Mode = .month
    var selectedDate = Date()

    let calendar = Calendar.current

    /// The user's routines, for linking a reminder to one.
    private(set) var routines: [Routine] = []
    /// Step count per routine id, shown on calendar blocks.
    private(set) var stepCounts: [UUID: Int] = [:]

    private let reminderStore: RoutineReminderStore
    private let appointmentService: AppointmentService
    private let routineService = RoutineService()
    private let routineStepService = RoutineStepService()

    init() {
        reminderStore = .shared
        appointmentService = .shared
    }

    // MARK: - Loading

    /// Pulls appointments and routines from Supabase. Reminders are local.
    func load() async {
        await appointmentService.loadAppointments()

        do {
            routines = try await routineService.fetchRoutines()
        } catch {
            print("Calendar: couldn't load routines: \(error.localizedDescription)")
        }

        await loadStepCounts()
    }

    /// Fetches step counts for routines that reminders link to.
    private func loadStepCounts() async {
        let linkedIds = Set(reminderStore.reminders.compactMap(\.routineId))

        for id in linkedIds where stepCounts[id] == nil {
            if let steps = try? await routineStepService.fetchSteps(routineId: id) {
                stepCounts[id] = steps.count
            }
        }
    }

    func routineName(for id: UUID?) -> String? {
        guard let id else { return nil }
        return routines.first { $0.id == id }?.name
    }

    // MARK: - Events

    /// The dates the calendar can show for the selected date (the month
    /// grid plus a week either side), used to expand repeating items.
    private var visibleRange: (start: Date, end: Date) {
        let monthStart = calendar.dateInterval(of: .month, for: selectedDate)?.start
            ?? calendar.startOfDay(for: selectedDate)
        let start = calendar.date(byAdding: .day, value: -7, to: monthStart) ?? monthStart
        let end = calendar.date(byAdding: .day, value: 45, to: monthStart) ?? monthStart
        return (start, end)
    }

    var events: [CalendarEvent] {
        let range = visibleRange

        let reminders = reminderStore
            .occurrences(from: range.start, to: range.end)
            .map { reminder in
            CalendarEvent(
                reminder: reminder,
                stepCount: reminder.routineId.flatMap { stepCounts[$0] }
            )
        }
        let appointments = appointmentService.appointments
            .flatMap { $0.occurrences(from: range.start, to: range.end) }
            .map(CalendarEvent.init(appointment:))

        return (reminders + appointments)
            .sorted { $0.start < $1.start }
    }

    /// Events grouped by start-of-day. Build this once per render and
    /// look days up in it, instead of filtering for every cell.
    var eventsByDay: [Date: [CalendarEvent]] {
        Dictionary(grouping: events) {
            calendar.startOfDay(for: $0.start)
        }
    }

    var selectedDayEvents: [CalendarEvent] {
        events.filter {
            calendar.isDate($0.start, inSameDayAs: selectedDate)
        }
    }

    // MARK: - Reminders

    /// Includes repeating reminders that fall on the selected day.
    var selectedDayReminders: [RoutineReminder] {
        reminderStore.reminders(on: selectedDate)
    }

    func addReminder(_ reminder: RoutineReminder) {
        reminderStore.add(reminder)
        selectedDate = reminder.date

        if reminder.routineId != nil {
            Task { await loadStepCounts() }
        }
    }

    // MARK: - Appointments

    /// Saves to Supabase; AppointmentService refreshes its list, so the
    /// calendar and Home update on their own.
    func addAppointment(_ appointment: Appointment) async throws {
        try await appointmentService.addAppointment(appointment)
        selectedDate = appointment.date
    }

    func toggleReminder(id: UUID) {
        reminderStore.toggleComplete(id: id, on: selectedDate)
    }

    /// The selected day at the next full hour, so a reminder created from
    /// a tapped month cell doesn't default to 12:00 AM.
    var newReminderDefaultDate: Date {
        let now = Date()
        let nextHour = calendar.nextDate(
            after: now,
            matching: DateComponents(minute: 0),
            matchingPolicy: .nextTime
        ) ?? now
        let hour = calendar.component(.hour, from: nextHour)

        return calendar.date(
            bySettingHour: hour,
            minute: 0,
            second: 0,
            of: selectedDate
        ) ?? selectedDate
    }

    // MARK: - Titles

    var monthTitle: String {
        selectedDate.formatted(.dateTime.month(.wide).year())
    }

    var dayTitle: String {
        selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var remindersTitle: String {
        if calendar.isDateInToday(selectedDate) {
            return "Today’s Reminders"
        }
        return "\(selectedDate.formatted(.dateTime.month(.abbreviated).day()))’s Reminders"
    }

    // MARK: - Grids

    /// "SUN", "MON", ... in the user's first-weekday order.
    var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return (0..<7).map {
            symbols[(calendar.firstWeekday - 1 + $0) % 7].uppercased()
        }
    }

    /// Every cell in the month grid; nil = padding before/after the month.
    var monthGrid: [Date?] {
        guard
            let start = calendar.dateInterval(of: .month, for: selectedDate)?.start,
            let dayCount = calendar.range(of: .day, in: .month, for: selectedDate)?.count
        else {
            return []
        }

        let leading = (calendar.component(.weekday, from: start)
            - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leading)
        cells += (0..<dayCount).map {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return cells
    }

    var monthRowCount: Int {
        monthGrid.count / 7
    }

    var weekDates: [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start
            ?? calendar.startOfDay(for: selectedDate)

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
    }

    // MARK: - Helpers

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func select(_ date: Date) {
        selectedDate = date
    }

    // MARK: - Navigation

    func goToToday() {
        selectedDate = Date()
    }

    func step(by amount: Int) {
        let component: Calendar.Component
        switch mode {
        case .month: component = .month
        case .week: component = .weekOfYear
        case .day: component = .day
        }

        if let newDate = calendar.date(byAdding: component, value: amount, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
