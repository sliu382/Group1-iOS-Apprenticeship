//
//  RoutineService.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//


import Foundation
import Supabase

struct RoutineService {

    private let supabase = SupabaseManager.client

    // READ: Get all routines belonging to the logged-in user
    func fetchRoutines() async throws -> [Routine] {
        let session = try await supabase.auth.session
        let userId = session.user.id

        let routines: [Routine] = try await supabase
            .from("routines")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value

        return routines
    }

    // CREATE: Add a new routine
    func createRoutine(name: String) async throws {
        let session = try await supabase.auth.session

        struct NewRoutine: Encodable {
            let user_id: UUID
            let name: String
        }

        let routine = NewRoutine(
            user_id: session.user.id,
            name: name
        )

        try await supabase
            .from("routines")
            .insert(routine)
            .execute()
    }

    // UPDATE: Rename a routine
    func updateRoutine(id: UUID, name: String) async throws {
        try await supabase
            .from("routines")
            .update(["name": name])
            .eq("id", value: id)
            .execute()
    }

    // DELETE: Delete a routine
    func deleteRoutine(id: UUID) async throws {
        try await supabase
            .from("routines")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}