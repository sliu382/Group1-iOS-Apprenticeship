//
//  Product.swift
//  Cosmetic-Planning-App
//

import Foundation

struct Product: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var name: String
    var brand: String?
    var barcode: String?
    var status: String
    var imageUrl: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, brand, barcode, status
        case userId = "user_id"
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }

    // Options shown in the Add Product sheet
    static let statuses = ["In rotation", "Backup", "Finished"]
}

// What the Add Product sheet sends
struct NewProductDraft {
    var name = ""
    var brand = ""
    var status = Product.statuses[0]
    var barcode: String?
    var photoData: Data?        // a photo the user picked (gets uploaded)
    var catalogImageUrl: String? // or a photo URL from the product catalog (used as-is)

    // Fill in from a product search result
    mutating func fill(from product: CatalogProduct) {
        name = product.name
        brand = product.brand ?? ""
        barcode = product.code
        catalogImageUrl = product.imageUrl
        photoData = nil
    }
}
