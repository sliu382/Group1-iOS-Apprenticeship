//
//  PostService.swift
//  Cosmetic-Planning-App
//

import Foundation
import Supabase

struct PostService {

    private let supabase = SupabaseManager.client

    func currentUserId() async throws -> UUID {
        try await supabase.auth.session.user.id
    }

    // READ: Newest posts from everyone
    func fetchFeed() async throws -> [Post] {
        try await supabase
            .from("feed_posts")
            .select()
            .order("created_at", ascending: false)
            .limit(100)
            .execute()
            .value
    }

    // CREATE: Share a routine or recommend a product
    func createPost(_ draft: NewPostDraft) async throws {
        let userId = try await currentUserId()

        struct NewPost: Encodable {
            let user_id: UUID
            let category: String
            let kind: String
            let title: String
            let body: String?
            let routine_id: UUID?
            let product_name: String?
            let product_price: String?
        }

        func clean(_ value: String) -> String? {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }

        let isRoutine = draft.kind == .routine
        let post = NewPost(
            user_id: userId,
            category: draft.category.rawValue,
            kind: draft.kind.rawValue,
            title: draft.title.trimmingCharacters(in: .whitespaces),
            body: clean(draft.body),
            routine_id: isRoutine ? draft.routineId : nil,
            product_name: isRoutine ? nil : clean(draft.productName),
            product_price: isRoutine ? nil : clean(draft.productPrice)
        )

        try await supabase.from("posts").insert(post).execute()
    }

    // DELETE: Remove one of your own posts
    func deletePost(id: UUID) async throws {
        try await supabase.from("posts").delete().eq("id", value: id).execute()
    }

    // Like / unlike
    func setLiked(_ liked: Bool, postId: UUID) async throws {
        try await setReaction(table: "post_likes", on: liked, postId: postId)
    }

    // Bookmark / un-bookmark
    func setSaved(_ saved: Bool, postId: UUID) async throws {
        try await setReaction(table: "post_saves", on: saved, postId: postId)
    }

    private func setReaction(table: String, on: Bool, postId: UUID) async throws {
        let userId = try await currentUserId()
        if on {
            struct Reaction: Encodable { let post_id: UUID; let user_id: UUID }
            try await supabase.from(table).insert(Reaction(post_id: postId, user_id: userId)).execute()
        } else {
            try await supabase.from(table).delete()
                .eq("post_id", value: postId)
                .eq("user_id", value: userId)
                .execute()
        }
    }

    // Comments
    func fetchComments(postId: UUID) async throws -> [PostComment] {
        try await supabase
            .from("feed_comments")
            .select()
            .eq("post_id", value: postId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func addComment(_ text: String, postId: UUID) async throws {
        let userId = try await currentUserId()
        struct NewComment: Encodable { let post_id: UUID; let user_id: UUID; let body: String }
        try await supabase
            .from("post_comments")
            .insert(NewComment(post_id: postId, user_id: userId, body: text))
            .execute()
    }

    func deleteComment(id: UUID) async throws {
        try await supabase.from("post_comments").delete().eq("id", value: id).execute()
    }
}
