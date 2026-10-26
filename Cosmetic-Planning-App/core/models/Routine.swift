//
//  Routine.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//


import Foundation

struct Routine: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var name: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
    }
}