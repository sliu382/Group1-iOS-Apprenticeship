//
//  AuthService.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//

import Foundation
import Supabase


struct AuthService {
    private let client = SupabaseManager.client

    // Create Account
    func signUp(email: String, password: String, profile: ProfileDraft) async throws {
        var metadata: [String: AnyJSON] = [
            "first_name": .string(profile.firstName),
            "last_name": .string(profile.lastName)
        ]

        // Add optional fields only if they're not empty
        if !profile.skinType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata["skin_type"] = .string(profile.skinType)
        }

        if !profile.hairType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata["hair_type"] = .string(profile.hairType)
        }

        if !profile.topConcern.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata["top_concern"] = .string(profile.topConcern)
        }

        if !profile.beautyStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            metadata["beauty_style"] = .string(profile.beautyStyle)
        }
        try await client.auth.signUp(
            email: email,
            password: password,
            data: metadata
        )
    }

    // Log in
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )
    }
    
    // Log out
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // Check for existing session
    func hasValidSession() async -> Bool {
        do {
            let session = try await client.auth.session
            return !session.isExpired
        } catch {
            return false
        }
    }
}

