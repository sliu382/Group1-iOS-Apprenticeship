//
//  ProductService.swift
//  Cosmetic-Planning-App
//

import Foundation
import Supabase

struct ProductService {

    private let supabase = SupabaseManager.client
    private let bucket = "product-images"

    // READ: Get all products on the logged-in user's shelf
    func fetchProducts() async throws -> [Product] {
        let session = try await supabase.auth.session

        let products: [Product] = try await supabase
            .from("products")
            .select()
            .eq("user_id", value: session.user.id)
            .order("created_at", ascending: false)
            .execute()
            .value

        return products
    }

    // CREATE: Add a product, uploading its photo first if there is one
    func addProduct(name: String, status: String, imageData: Data?) async throws {
        let session = try await supabase.auth.session
        let userId = session.user.id
        let productId = UUID()

        var imageUrl: String?
        if let imageData {
            // Stored as <user id>/<product id>.jpg so storage rules can check ownership
            let path = imagePath(userId: userId, productId: productId)
            try await supabase.storage
                .from(bucket)
                .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            imageUrl = try supabase.storage.from(bucket).getPublicURL(path: path).absoluteString
        }

        struct NewProduct: Encodable {
            let id: UUID
            let user_id: UUID
            let name: String
            let status: String
            let image_url: String?
        }

        try await supabase
            .from("products")
            .insert(NewProduct(id: productId, user_id: userId, name: name, status: status, image_url: imageUrl))
            .execute()
    }

    // DELETE: Remove a product and its photo
    func deleteProduct(_ product: Product) async throws {
        if product.imageUrl != nil {
            _ = try? await supabase.storage
                .from(bucket)
                .remove(paths: [imagePath(userId: product.userId, productId: product.id)])
        }

        try await supabase
            .from("products")
            .delete()
            .eq("id", value: product.id)
            .execute()
    }

    private func imagePath(userId: UUID, productId: UUID) -> String {
        "\(userId.uuidString.lowercased())/\(productId.uuidString.lowercased()).jpg"
    }
}
