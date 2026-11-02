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
        let is_complete: Bool
    }

    private struct AppointmentUpdate: Encodable {
        let title: String
        let date: Date
        let location: String?
        let notes: String?
        let is_complete: Bool
        let updated_at: Date
    }

    // MARK: - Fetch Appointments

    @discardableResult
    func fetchAppointments() async throws -> [Appointment] {
        let session = try await supabase.auth.session

        let fetched: [Appointment] = try await supabase
            .from("appointments")
            .select("id, title, date, location, notes, is_complete")
            .eq("user_id", value: session.user.id)
            .order("date", ascending: true)
            .execute()
            .value

        appointments = fetched
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

        try await fetchAppointments()
    }

    // MARK: - Today's Appointments

    var todayAppointments: [Appointment] {
        appointments
            .filter {
                Calendar.current.isDateInToday($0.date)
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Upcoming Appointments

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
            .filter { $0.date >= tomorrow }
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
