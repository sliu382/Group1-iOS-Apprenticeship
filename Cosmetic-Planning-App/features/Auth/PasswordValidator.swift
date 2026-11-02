//
//  PasswordValidator.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/1/26.
//


import Foundation

enum PasswordValidationError: LocalizedError {
    case tooShort
    case passwordsDoNotMatch

    var errorDescription: String? {
        switch self {
        case .tooShort:
            return "Password must be at least 8 characters."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        }
    }
}

struct PasswordValidator {

    static func validate(
        password: String,
        confirmPassword: String
    ) throws {

        guard password.count >= 8 else {
            throw PasswordValidationError.tooShort
        }

        guard password == confirmPassword else {
            throw PasswordValidationError.passwordsDoNotMatch
        }
    }
}

