//
//  LoginViewModel.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/1/26.
//



import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Form State
    @Published var email = ""
    @Published var password = ""

    // MARK: - UI State
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService()

    // MARK: - Login
    func login() async -> Bool {
        guard !isLoading else { return false }

        let cleanedEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleanedEmail.isEmpty,
              !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return false
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await authService.signIn(
                email: cleanedEmail,
                password: password
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
