//
//  Product.swift
//  Cosmetic-Planning-App
//

import Foundation

struct Product: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var name: String
    var status: String
    var imageUrl: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, status
        case userId = "user_id"
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }

    // Options shown in the Add Product sheet
    static let statuses = ["In rotation", "Backup", "Finished"]
}
