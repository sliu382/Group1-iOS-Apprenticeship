//
//  ProfileService.swift
//  Cosmetic-Planning-App
//

import Foundation
import Supabase

struct ProfileService {

    private let supabase = SupabaseManager.client

    // READ: Get the logged-in user's profile
    func fetchProfile() async throws -> UserProfile? {
        let session = try await supabase.auth.session

        let profiles: [UserProfile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: session.user.id)
            .limit(1)
            .execute()
            .value

        return profiles.first
    }

    // CREATE/UPDATE: Save the logged-in user's profile
    func updateProfile(_ draft: ProfileDraft) async throws {
        let session = try await supabase.auth.session

        struct ProfileUpdate: Encodable {
            let id: UUID
            let first_name: String?
            let last_name: String?
            let skin_type: String?
            let hair_type: String?
            let top_concern: String?
            let beauty_style: String?
            let updated_at: Date
        }

        // Saves blank fields as null instead of ""
        func clean(_ value: String) -> String? {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            return trimmed.isEmpty ? nil : trimmed
        }

        let update = ProfileUpdate(
            id: session.user.id,
            first_name: clean(draft.firstName),
            last_name: clean(draft.lastName),
            skin_type: clean(draft.skinType),
            hair_type: clean(draft.hairType),
            top_concern: clean(draft.topConcern),
            beauty_style: clean(draft.beautyStyle),
            updated_at: Date()
        )

        // upsert = update the row if it exists, create it if it doesn't
        try await supabase
            .from("profiles")
            .upsert(update)
            .execute()
    }
}
