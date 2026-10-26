//
//  RoutineStepService.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//


import Foundation
import Supabase

struct RoutineStepService {
    private let supabase = SupabaseManager.client

    // Get all steps for a particular routine
    func fetchSteps(routineId: UUID) async throws -> [RoutineStep] {
        let steps: [RoutineStep] = try await supabase
            .from("routine_steps")
            .select()
            .eq("routine_id", value: routineId)
            .order("step_order", ascending: true)
            .execute()
            .value

        return steps
    }

    // Add a new step
    func addStep(
        routineId: UUID,
        title: String,
        itemName: String?,
        description: String?,
        order: Int
    ) async throws {

        struct NewStep: Encodable {
            let routine_id: UUID
            let title: String
            let item_name: String?
            let description: String?
            let step_order: Int
        }

        let step = NewStep(
            routine_id: routineId,
            title: title,
            item_name: itemName,
            description: description,
            step_order: order
        )

        try await supabase
            .from("routine_steps")
            .insert(step)
            .execute()
    }

    // Delete a step
    func deleteStep(id: UUID) async throws {
        try await supabase
            .from("routine_steps")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}