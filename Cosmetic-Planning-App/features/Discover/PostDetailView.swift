//
//  PostDetailView.swift
//  Cosmetic-Planning-App
//

import SwiftUI

/** Full post with comments ("View details") */
struct PostDetailView: View {
    let viewModel: DiscoverViewModel
    let postId: UUID

    @Environment(\.dismiss) private var dismiss
    @State private var comments: [PostComment] = []
    @State private var newComment = ""
    @State private var isSending = false
    @State private var errorMessage: String?
    @State private var showsDeleteConfirm = false
    @State private var shelfCandidate: ShelfCandidate?
    @FocusState private var commentFocused: Bool

    private let service = PostService()

    var body: some View {
        Group {
            if let post = viewModel.post(id: postId) {
                content(post)
            } else {
                Text("This post was removed.")
                    .font(.appSans(12))
                    .foregroundStyle(AppColor.muted)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.cream)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .task { await loadComments() }
        .addToShelfDialog($shelfCandidate, viewModel: viewModel)
        .shelfToast(viewModel)
    }

    private func content(_ post: Post) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 16) {
                    PostContent(
                        post: post,
                        isMine: viewModel.isMine(post),
                        isOnShelf: viewModel.isOnShelf(post),
                        onAddToShelf: { shelfCandidate = .post(post) },
                        onSave: { Task { await viewModel.toggleSave(post) } },
                        onDelete: { showsDeleteConfirm = true }
                    )
                    HStack(spacing: 18) {
                        LikeButton(post: post) { Task { await viewModel.toggleLike(post) } }
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left").font(.system(size: 18))
                            Text("\(comments.count)").font(.appSans(12))
                        }
                        .foregroundStyle(AppColor.muted)
                        Spacer()
                        SaveButton(post: post) { Task { await viewModel.toggleSave(post) } }
                    }
                }
                .padding(18)
                .modifier(RectangularCard(radius: 24))

                SectionHeader(title: "Comments")

                if let errorMessage {
                    Text(errorMessage)
                        .font(.appSans(11))
                        .foregroundStyle(.red)
                }

                if comments.isEmpty {
                    Text("No comments yet. Start the conversation!")
                        .font(.appSans(11))
                        .foregroundStyle(AppColor.muted)
                }

                ForEach(comments) { comment in
                    commentRow(comment)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { commentBar(post) }
        .confirmationDialog("Delete this post?", isPresented: $showsDeleteConfirm, titleVisibility: .visible) {
            Button("Delete post", role: .destructive) {
                Task {
                    await viewModel.delete(post)
                    dismiss()
                }
            }
        }
    }

    private func commentRow(_ comment: PostComment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AuthorAvatar(name: comment.authorName, id: comment.userId, size: 32)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(comment.authorName)
                        .font(.appSans(11, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                    Text("@\(comment.authorUsername) · \(comment.createdAt.shortTimeAgo)")
                        .font(.appSans(9))
                        .foregroundStyle(AppColor.muted)
                }
                Text(comment.body)
                    .font(.appSans(12))
                    .foregroundStyle(AppColor.ink)
            }
            Spacer(minLength: 0)
        }
        .contextMenu {
            if comment.userId == viewModel.currentUserId {
                Button("Delete comment", systemImage: "trash", role: .destructive) {
                    Task { await deleteComment(comment) }
                }
            }
        }
    }

    private func commentBar(_ post: Post) -> some View {
        HStack(spacing: 10) {
            TextField("Add a comment...", text: $newComment, axis: .vertical)
                .font(.appSans(12))
                .lineLimit(1...4)
                .focused($commentFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .modifier(RectangularCard(radius: 18, color: .white))
            Button {
                Task { await send(post) }
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(AppColor.accent, in: Circle())
            }
            .disabled(isSending || newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(AppColor.cream)
    }

    private func loadComments() async {
        do {
            comments = try await service.fetchComments(postId: postId)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func send(_ post: Post) async {
        let text = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isSending = true
        defer { isSending = false }
        do {
            try await service.addComment(text, postId: post.id)
            newComment = ""
            commentFocused = false
            await loadComments()
            await viewModel.load()   // refresh the comment count on the feed
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteComment(_ comment: PostComment) async {
        do {
            try await service.deleteComment(id: comment.id)
            comments.removeAll { $0.id == comment.id }
            await viewModel.load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
