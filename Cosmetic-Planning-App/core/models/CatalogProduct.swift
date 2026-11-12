//
//  CatalogProduct.swift
//  Cosmetic-Planning-App
//

import Foundation

// A product from the Open Beauty Facts catalog (openbeautyfacts.org).
// The data is crowd-sourced, so every field except the barcode can be missing.
struct CatalogProduct: Decodable, Identifiable, Hashable {
    let code: String
    let name: String
    let brand: String?
    let quantity: String?
    let thumbnailUrl: String?
    let imageUrl: String?

    var id: String { code }

    // "Rare Beauty Soft Pinch Liquid Blush" — used when recommending a product in a post
    var displayName: String {
        guard let brand, !brand.isEmpty,
              !name.lowercased().hasPrefix(brand.lowercased()) else { return name }
        return "\(brand) \(name)"
    }

    enum CodingKeys: String, CodingKey {
        case code, brands, quantity
        case name = "product_name"
        case thumbnailUrl = "image_front_small_url"
        case imageUrl = "image_front_url"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // try? so one oddly-shaped field doesn't break the whole search
        code = (try? c.decode(String.self, forKey: .code)) ?? UUID().uuidString
        name = ((try? c.decode(String.self, forKey: .name)) ?? "").trimmingCharacters(in: .whitespaces)
        // "Nivea,Beiersdorf" -> "Nivea"
        brand = (try? c.decode(String.self, forKey: .brands))?
            .split(separator: ",").first
            .map { $0.trimmingCharacters(in: .whitespaces) }
        quantity = try? c.decode(String.self, forKey: .quantity)
        thumbnailUrl = try? c.decode(String.self, forKey: .thumbnailUrl)
        imageUrl = (try? c.decode(String.self, forKey: .imageUrl)) ?? thumbnailUrl
    }
}
