//
//  User.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import Foundation

// Named UserProfile (not User) so it doesn't clash with Supabase's built-in Auth `User` type.
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var firstName: String?
    var lastName: String?
    var username: String?
    var skinType: String?
    var hairType: String?
    var topConcern: String?
    var beautyStyle: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case skinType = "skin_type"
        case hairType = "hair_type"
        case topConcern = "top_concern"
        case beautyStyle = "beauty_style"
        case createdAt = "created_at"
    }

    var fullName: String {
        let name = [firstName, lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return name.isEmpty ? "Your Name" : name
    }

    var initials: String {
        let letters = [firstName, lastName].compactMap { $0?.first }.map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    // e.g. "March 2024"
    var memberSince: String {
        createdAt.formatted(.dateTime.month(.wide).year())
    }
}

// Editable copy of the profile used by the Edit sheet
struct ProfileDraft {
    var firstName = ""
    var lastName = ""
    var username = ""
    var skinType = ""
    var hairType = ""
    var topConcern = ""
    var beautyStyle = ""

    // for new account registration
    init() {}
    
    init(from profile: UserProfile?) {
        firstName = profile?.firstName ?? ""
        lastName = profile?.lastName ?? ""
        username = profile?.username ?? ""
        skinType = profile?.skinType ?? ""
        hairType = profile?.hairType ?? ""
        topConcern = profile?.topConcern ?? ""
        beautyStyle = profile?.beautyStyle ?? ""
    }
}
