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
    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password
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

