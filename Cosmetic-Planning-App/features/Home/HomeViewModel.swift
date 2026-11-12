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

    var isLoading = false
    var errorMessage: String?

    private let profileService = ProfileService()
    private let routineService = RoutineService()
    private let appointmentService = AppointmentService.shared
    private let reminderStore = RoutineReminderStore.shared
    private let stepService = RoutineStepService()

    /// Steps per routine id, loaded when a card's chevron is tapped.
    private(set) var stepsByRoutine: [UUID: [RoutineStep]] = [:]

    /// Fetches every time so edits made on the routine page show up.
    /// Cached steps stay on screen while the fetch runs.
    func loadSteps(for routineId: UUID) async {
        do {
            stepsByRoutine[routineId] = try await stepService.fetchSteps(routineId: routineId)
        } catch {
            if stepsByRoutine[routineId] == nil {
                stepsByRoutine[routineId] = []
            }
            print("Home: couldn't load steps: \(error.localizedDescription)")
        }
    }

    // These read straight from the shared stores, so anything added or
    // completed on the Calendar tab shows up here immediately.

    var todayAppointments: [Appointment] {
        appointmentService.todayAppointments
    }

    var upcomingAppointments: [Appointment] {
        appointmentService.upcomingAppointments
    }

    var todayRoutineReminders: [RoutineReminder] {
        reminderStore.todayReminders
    }

    func toggleReminder(id: UUID) {
        reminderStore.toggleComplete(id: id)
    }

    /// The routine a reminder is linked to, if it's one of the user's routines.
    func routine(for reminder: RoutineReminder) -> Routine? {
        guard let id = reminder.routineId else { return nil }
        return todayRoutines.first { $0.id == id }
    }

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
            // Updates AppointmentService.shared.appointments, which the
            // computed lists above (and the Calendar tab) read from.
            try await appointmentService.fetchAppointments()
        } catch {
            errorMessage = error.localizedDescription
        }

    }
}
