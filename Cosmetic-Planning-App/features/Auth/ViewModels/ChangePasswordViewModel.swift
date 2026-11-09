//
//  ChangePasswordViewModel.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/8/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class ChangePasswordViewModel: ObservableObject {

    // Password information
    @Published var newPassword = ""
    @Published var confirmPassword = ""

    // UI state
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessConfirmation = false

    private let authService = AuthService()

    func changePassword() async {
        guard !isLoading else { return }

        do {
            try PasswordValidator.validate(
                password: newPassword,
                confirmPassword: confirmPassword
            )

            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            try await authService.changePassword(
                newPassword: newPassword
            )

            newPassword = ""
            confirmPassword = ""

            showSuccessConfirmation = true

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}