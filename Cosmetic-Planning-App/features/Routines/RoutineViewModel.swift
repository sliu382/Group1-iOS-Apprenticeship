//
//  RoutineViewModel.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//


import Foundation
import Observation

@MainActor
@Observable
class RoutineViewModel {
    var routines: [Routine] = []
    var isLoading = false
    var errorMessage: String?

    private let service = RoutineService()

    func loadRoutines() async {
        isLoading = true
        defer { isLoading = false }

        do {
            routines = try await service.fetchRoutines()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addRoutine(name: String) async {
        do {
            try await service.createRoutine(name: name)
            await loadRoutines()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteRoutine(id: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.deleteRoutine(id: id)

            // Remove deleted routine from the UI
            routines.removeAll { $0.id == id }

            errorMessage = nil

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
