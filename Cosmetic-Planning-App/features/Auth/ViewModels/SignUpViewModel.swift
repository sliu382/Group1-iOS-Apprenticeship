//
//  SignUpViewModel.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/1/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {

    // Account credentials
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // Profile information
    @Published var profile = ProfileDraft()

    // UI state
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSignUpConfirmation = false

    private let authService = AuthService()

    func signUp() async {
        guard !isLoading else { return }

        let firstName = profile.firstName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let lastName = profile.lastName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let cleanedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !cleanedEmail.isEmpty,
              !password.isEmpty else {
            errorMessage = "Please fill out all required fields."
            return
        }

        do {
            try PasswordValidator.validate(
                password: password,
                confirmPassword: confirmPassword
            )

            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            var cleanedProfile = profile
            cleanedProfile.firstName = firstName
            cleanedProfile.lastName = lastName

            try await authService.signUp(
                email: cleanedEmail,
                password: password,
                profile: cleanedProfile
            )

            showSignUpConfirmation = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
