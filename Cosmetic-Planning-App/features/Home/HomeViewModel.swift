//
//  HomeViewModel.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//



import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var profile: UserProfile?
    var todayRoutines: [Routine] = []
    var todayAppointments: [Appointment] = []
    var upcomingAppointments: [Appointment] = []

    var isLoading = false
    var errorMessage: String?

    private let profileService = ProfileService()
    private let routineService = RoutineService()
    private let appointmentService = AppointmentService.shared

    var greeting: String {
        let hour = Calendar.current.component(
            .hour, from: Date()
        )

        let timeOfDay = hour < 12
            ? "Morning"
            : (hour < 17 ? "Afternoon" : "Evening")

        let name = profile?.firstName?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let name, !name.isEmpty {
            return "Good \(timeOfDay), \(name)!"
        }

        return "Good \(timeOfDay)!"
    }

    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await profileService.fetchProfile()
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            let routines = try await routineService.fetchRoutines()

            // Temporary assumption: every routine is daily.
            // Replace with schedule-based filtering later.
            todayRoutines = routines
        } catch {
            errorMessage = error.localizedDescription
        }

        
        do {
            let appointments = try await appointmentService.fetchAppointments()

            let calendar = Calendar.current
            let startOfTomorrow = calendar.date(
                byAdding: .day,
                value: 1,
                to: calendar.startOfDay(for: Date())
            )!

            todayAppointments = appointments
                .filter {
                    calendar.isDateInToday($0.date)
                }
                .sorted { $0.date < $1.date }

            upcomingAppointments = appointments
                .filter { $0.date >= startOfTomorrow }
                .sorted { $0.date < $1.date }

        } catch {
            errorMessage = error.localizedDescription
        }

    }
}
