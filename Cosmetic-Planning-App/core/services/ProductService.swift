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

    // CREATE: Add a product. Uploads the user's photo if they picked one;
    // otherwise uses the catalog photo URL (if it came from product search).
    func addProduct(_ draft: NewProductDraft) async throws {
        let session = try await supabase.auth.session
        let userId = session.user.id
        let productId = UUID()

        var imageUrl = draft.catalogImageUrl
        if let imageData = draft.photoData {
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
            let brand: String?
            let barcode: String?
            let status: String
            let image_url: String?
        }

        let brand = draft.brand.trimmingCharacters(in: .whitespaces)
        try await supabase
            .from("products")
            .insert(NewProduct(
                id: productId,
                user_id: userId,
                name: draft.name.trimmingCharacters(in: .whitespaces),
                brand: brand.isEmpty ? nil : brand,
                barcode: draft.barcode,
                status: draft.status,
                image_url: imageUrl
            ))
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
