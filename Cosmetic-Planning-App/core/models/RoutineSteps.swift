//
//  RoutineSteps.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//

import Foundation

struct RoutineStep: Codable, Identifiable {
    let id: UUID
    let routineId: UUID
    var title: String
    var itemName: String?
    var description: String?
    var stepOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case routineId = "routine_id"
        case itemName = "item_name"
        case stepOrder = "step_order"
    }
}
