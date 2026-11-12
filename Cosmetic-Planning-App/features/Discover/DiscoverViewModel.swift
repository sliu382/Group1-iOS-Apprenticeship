//
//  DiscoverViewModel.swift
//  Cosmetic-Planning-App
//

import Foundation
import Observation

@MainActor
@Observable
class DiscoverViewModel {
    enum SortOrder: String, CaseIterable, Identifiable {
        case newest = "Newest"
        case mostLiked = "Most liked"
        var id: String { rawValue }
    }

    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?
    var currentUserId: UUID?

    // Filters
    var query = ""
    var category: PostCategory?          // nil = "For you"
    var kind: PostKind?                  // nil = all post types
    var sort: SortOrder = .newest
    var savedOnly = false

    // For the Create Post sheet
    var myRoutines: [Routine] = []

    private let service = PostService()
    private let routineService = RoutineService()

    var hasActiveFilters: Bool { kind != nil || sort != .newest || savedOnly }

    var visiblePosts: [Post] {
        let search = query.trimmingCharacters(in: .whitespaces).lowercased()
        let filtered = posts.filter { post in
            if let category, post.category != category { return false }
            if let kind, post.kind != kind { return false }
            if savedOnly && !post.savedByMe { return false }
            if search.isEmpty { return true }
            let searchable = [post.title, post.body ?? "", post.authorName, post.authorUsername,
                              post.productName ?? ""] + post.stepTitles
            return searchable.contains { $0.lowercased().contains(search) }
        }
        switch sort {
        case .newest: return filtered
        case .mostLiked: return filtered.sorted { $0.likeCount > $1.likeCount }
        }
    }

    func post(id: UUID) -> Post? { posts.first { $0.id == id } }
    func isMine(_ post: Post) -> Bool { post.userId == currentUserId }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            currentUserId = try await service.currentUserId()
            posts = try await service.fetchFeed()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMyRoutines() async {
        myRoutines = (try? await routineService.fetchRoutines()) ?? []
    }

    func create(_ draft: NewPostDraft) async -> Bool {
        do {
            try await service.createPost(draft)
            await load()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func delete(_ post: Post) async {
        do {
            try await service.deletePost(id: post.id)
            posts.removeAll { $0.id == post.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Updates the heart right away, then syncs; undoes it if the request fails
    func toggleLike(_ post: Post) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let liked = !posts[index].likedByMe
        posts[index].likedByMe = liked
        posts[index].likeCount += liked ? 1 : -1
        do {
            try await service.setLiked(liked, postId: post.id)
        } catch {
            if let i = posts.firstIndex(where: { $0.id == post.id }) {
                posts[i].likedByMe = !liked
                posts[i].likeCount += liked ? -1 : 1
            }
            errorMessage = error.localizedDescription
        }
    }

    func toggleSave(_ post: Post) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let saved = !posts[index].savedByMe
        posts[index].savedByMe = saved
        do {
            try await service.setSaved(saved, postId: post.id)
        } catch {
            if let i = posts.firstIndex(where: { $0.id == post.id }) { posts[i].savedByMe = !saved }
            errorMessage = error.localizedDescription
        }
    }
}
