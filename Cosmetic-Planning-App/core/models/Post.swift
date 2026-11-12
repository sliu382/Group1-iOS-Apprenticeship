//
//  Post.swift
//  Cosmetic-Planning-App
//

import Foundation

enum PostCategory: String, Codable, CaseIterable, Identifiable {
    case skincare, hair, makeup
    var id: String { rawValue }
    var title: String { rawValue.capitalized }   // "Skincare"
}

enum PostKind: String, Codable, CaseIterable, Identifiable {
    case routine, recommendation
    var id: String { rawValue }
    var title: String { rawValue.capitalized }   // "Routine"
}

// One post in the Discover feed (read from the `feed_posts` view)
struct Post: Decodable, Identifiable {
    let id: UUID
    let userId: UUID
    let category: PostCategory
    let kind: PostKind
    let title: String
    let body: String?
    let routineId: UUID?
    let productName: String?
    let productPrice: String?
    let createdAt: Date
    let authorName: String
    let authorUsername: String
    var likeCount: Int
    let commentCount: Int
    var likedByMe: Bool
    var savedByMe: Bool
    let stepTitles: [String]

    enum CodingKeys: String, CodingKey {
        case id, category, kind, title, body
        case userId = "user_id"
        case routineId = "routine_id"
        case productName = "product_name"
        case productPrice = "product_price"
        case createdAt = "created_at"
        case authorName = "author_name"
        case authorUsername = "author_username"
        case likeCount = "like_count"
        case commentCount = "comment_count"
        case likedByMe = "liked_by_me"
        case savedByMe = "saved_by_me"
        case stepTitles = "step_titles"
    }

    // "SKINCARE · ROUTINE"
    var tag: String { "\(category.title) · \(kind.title)".uppercased() }

    var authorInitials: String { Post.initials(for: authorName) }

    // "Mallow Petal Tint Balm · $22"
    var productLine: String {
        guard let productName else { return "" }
        guard var price = productPrice?.trimmingCharacters(in: .whitespaces), !price.isEmpty else {
            return productName
        }
        if price.first?.isNumber == true { price = "$" + price }
        return "\(productName) · \(price)"
    }

    static func initials(for name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }
}

// A comment on a post (read from the `feed_comments` view)
struct PostComment: Decodable, Identifiable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let body: String
    let createdAt: Date
    let authorName: String
    let authorUsername: String

    enum CodingKeys: String, CodingKey {
        case id, body
        case postId = "post_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case authorName = "author_name"
        case authorUsername = "author_username"
    }
}

// What the Create Post sheet sends
struct NewPostDraft {
    var kind: PostKind = .routine
    var category: PostCategory = .skincare
    var title = ""
    var body = ""
    var routineId: UUID?
    var productName = ""
    var productPrice = ""

    var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        switch kind {
        case .routine: return routineId != nil
        case .recommendation: return !productName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}

extension Date {
    // "now", "18 min", "2 hr", "3 d", then "Nov 2"
    var shortTimeAgo: String {
        let seconds = Int(Date().timeIntervalSince(self))
        switch seconds {
        case ..<60: return "now"
        case ..<3600: return "\(seconds / 60) min"
        case ..<86400: return "\(seconds / 3600) hr"
        case ..<604800: return "\(seconds / 86400) d"
        default: return formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
