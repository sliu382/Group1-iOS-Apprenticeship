//
//  ProductCatalogService.swift
//  Cosmetic-Planning-App
//

import Foundation

// Searches the free Open Beauty Facts product database. No API key needed.
// Their API asks apps to send a descriptive User-Agent and to keep search
// requests low (about 10 per minute), so we only search when the user submits.
struct ProductCatalogService {
    static let pageSize = 24

    enum CatalogError: LocalizedError {
        case unavailable
        var errorDescription: String? {
            "Couldn't reach the product database. Check your connection and try again."
        }
    }

    func search(_ query: String, page: Int = 1) async throws -> (products: [CatalogProduct], hasMore: Bool) {
        var components = URLComponents(string: "https://world.openbeautyfacts.org/cgi/search.pl")!
        components.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: String(Self.pageSize)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "fields", value: "code,product_name,brands,quantity,image_front_small_url,image_front_url")
        ]

        var request = URLRequest(url: components.url!, timeoutInterval: 20)
        request.setValue("CosmeticPlanningApp/1.0 (iOS student project)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw CatalogError.unavailable }

        struct SearchResponse: Decodable { let products: [CatalogProduct] }
        let products = try JSONDecoder().decode(SearchResponse.self, from: data).products

        // Skip entries with no name, and duplicates
        var seen = Set<String>()
        let cleaned = products.filter { !$0.name.isEmpty && seen.insert($0.code).inserted }
        return (cleaned, products.count == Self.pageSize)
    }
}
