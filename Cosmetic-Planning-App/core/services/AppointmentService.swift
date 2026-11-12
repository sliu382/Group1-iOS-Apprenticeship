//
//  AppointmentService.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//

import Foundation
import Supabase
import Observation

@MainActor
@Observable
final class AppointmentService {

    static let shared = AppointmentService()

    private let supabase = SupabaseManager.client

    private(set) var appointments: [Appointment] = []

    var isLoading = false
    var errorMessage: String?

    private init() {}

    // MARK: - Database Payloads

    private struct AppointmentInsert: Encodable {
        let id: UUID
        let user_id: UUID
        let title: String
        let date: Date
        let location: String?
        let notes: String?
        let end_date: Date?
        let is_all_day: Bool
        let notify_minutes_before: Int?
        let recurrence: Recurrence?
        let is_complete: Bool
    }

    private struct AppointmentUpdate: Encodable {
        let title: String
        let date: Date
        let location: String?
        let notes: String?
        let end_date: Date?
        let is_all_day: Bool
        let notify_minutes_before: Int?
        let recurrence: Recurrence?
        let is_complete: Bool
        let updated_at: Date
    }

    // MARK: - Fetch Appointments

    @discardableResult
    func fetchAppointments() async throws -> [Appointment] {
        let session = try await supabase.auth.session

        let fetched: [Appointment] = try await supabase
            .from("appointments")
            .select("id, title, date, location, notes, end_date, is_all_day, notify_minutes_before, recurrence, is_complete")
            .eq("user_id", value: session.user.id)
            .order("date", ascending: true)
            .execute()
            .value

        appointments = fetched
        await rescheduleAllNotifications()
        return fetched
    }

    // MARK: - Add Appointment

    func addAppointment(_ appointment: Appointment) async throws {
        let session = try await supabase.auth.session

        let payload = AppointmentInsert(
            id: appointment.id,
            user_id: session.user.id,
            title: appointment.title,
            date: appointment.date,
            location: appointment.location,
            notes: appointment.notes,
            end_date: appointment.endDate,
            is_all_day: appointment.isAllDay,
            notify_minutes_before: appointment.notifyMinutesBefore,
            recurrence: appointment.recurrence,
            is_complete: appointment.isComplete
        )

        try await supabase
            .from("appointments")
            .insert(payload)
            .execute()

        try await fetchAppointments()
    }

    // MARK: - Update Appointment

    func updateAppointment(_ appointment: Appointment) async throws {
        let session = try await supabase.auth.session

        let payload = AppointmentUpdate(
            title: appointment.title,
            date: appointment.date,
            location: appointment.location,
            notes: appointment.notes,
            end_date: appointment.endDate,
            is_all_day: appointment.isAllDay,
            notify_minutes_before: appointment.notifyMinutesBefore,
            recurrence: appointment.recurrence,
            is_complete: appointment.isComplete,
            updated_at: Date()
        )

        try await supabase
            .from("appointments")
            .update(payload)
            .eq("id", value: appointment.id)
            .eq("user_id", value: session.user.id)
            .execute()

        try await fetchAppointments()
    }

    // MARK: - Delete Appointment

    func deleteAppointment(id: UUID) async throws {
        let session = try await supabase.auth.session

        try await supabase
            .from("appointments")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: session.user.id)
            .execute()

        NotificationScheduler.shared.cancelAll(for: id)
        try await fetchAppointments()
    }

    // MARK: - Notifications

    /// Runs after every fetch, so adds, edits and new launches all
    /// end up with the right notifications queued.
    private func rescheduleAllNotifications() async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let horizon = calendar.date(byAdding: .day, value: 60, to: today) ?? today

        for appointment in appointments {
            guard !appointment.isComplete else {
                NotificationScheduler.shared.cancelAll(for: appointment.id)
                continue
            }

            let planned = appointment
                .occurrences(from: today, to: horizon)
                .compactMap { occurrence -> PlannedNotification? in
                    guard let fireDate = occurrence.notificationDate else { return nil }

                    var body = occurrence.isAllDay ? occurrence.dateText : occurrence.timeText
                    if let location = occurrence.location, !location.isEmpty {
                        body += " · \(location)"
                    }
                    return PlannedNotification(fireDate: fireDate, title: occurrence.title, body: body)
                }

            await NotificationScheduler.shared.replaceNotifications(for: appointment.id, with: planned)
        }
    }

    // MARK: - Today's Appointments

    var todayAppointments: [Appointment] {
        appointments
            .compactMap { $0.occurrence(on: Date()) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Upcoming Appointments

    /// The next occurrence of each appointment, starting tomorrow.
    var upcomingAppointments: [Appointment] {
        let calendar = Calendar.current

        guard let tomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: Date())
        ) else {
            return []
        }

        return appointments
            .compactMap { $0.nextOccurrence(onOrAfter: tomorrow) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Load for View

    func loadAppointments() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await fetchAppointments()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Clear on Logout

    func clear() {
        appointments = []
        errorMessage = nil
    }
}
