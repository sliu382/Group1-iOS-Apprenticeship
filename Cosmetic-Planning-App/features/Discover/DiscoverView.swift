//
//  DiscoverView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import SwiftUI

struct DiscoverView: View {
    @State private var viewModel = DiscoverViewModel()
    @State private var showsCreatePost = false
    @State private var postToDelete: Post?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ScreenHeader(title: "Discover", eyebrow: "The Muse Community", showsAdd: true) {
                        showsCreatePost = true
                    }

                    searchBar
                    categoryChips

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.appSans(11))
                            .foregroundStyle(.red)
                    }

                    feed
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .background(AppColor.cream)
            .toolbar(.hidden, for: .navigationBar)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .sheet(isPresented: $showsCreatePost) {
                CreatePostSheet(viewModel: viewModel)
            }
            .confirmationDialog(
                "Delete this post?",
                isPresented: Binding(get: { postToDelete != nil }, set: { if !$0 { postToDelete = nil } }),
                titleVisibility: .visible
            ) {
                Button("Delete post", role: .destructive) {
                    if let post = postToDelete {
                        Task { await viewModel.delete(post) }
                    }
                }
            } message: {
                Text("Its likes and comments will be deleted too.")
            }
        }
    }

    /** Search + filter menu */
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.muted)
            TextField("Search routines or creators...", text: $viewModel.query)
                .font(.appSans(12))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Divider()
                .frame(height: 22)
            Menu {
                Picker("Show", selection: $viewModel.kind) {
                    Text("All posts").tag(PostKind?.none)
                    Text("Routines").tag(PostKind?.some(.routine))
                    Text("Recommendations").tag(PostKind?.some(.recommendation))
                }
                Picker("Sort by", selection: $viewModel.sort) {
                    ForEach(DiscoverViewModel.SortOrder.allCases) { Text($0.rawValue).tag($0) }
                }
                Toggle("Saved only", systemImage: "bookmark", isOn: $viewModel.savedOnly)
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 17))
                    .foregroundStyle(viewModel.hasActiveFilters ? AppColor.accent : AppColor.ink)
                    .overlay(alignment: .topTrailing) {
                        if viewModel.hasActiveFilters {
                            Circle().fill(Color(hex: 0xC0707F)).frame(width: 6, height: 6).offset(x: 3, y: -3)
                        }
                    }
            }
        }
        .padding(.horizontal, 13)
        .frame(height: 48)
        .modifier(RectangularCard(radius: 15, color: .white))
    }

    /** For you / Skincare / Hair / Makeup */
    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip("For you", isSelected: viewModel.category == nil) { viewModel.category = nil }
                ForEach(PostCategory.allCases) { category in
                    chip(category.title, isSelected: viewModel.category == category) {
                        viewModel.category = category
                    }
                }
            }
        }
    }

    private func chip(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appSans(12))
                .foregroundStyle(isSelected ? .white : AppColor.ink)
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background(isSelected ? AppColor.accent : AppColor.paper, in: Capsule())
                .overlay { Capsule().stroke(isSelected ? .clear : AppColor.line, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }

    /** Posts, or a loading / empty state */
    @ViewBuilder
    private var feed: some View {
        let posts = viewModel.visiblePosts
        if viewModel.isLoading && viewModel.posts.isEmpty {
            ProgressView().padding(.top, 40)
        } else if posts.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.accent)
                Text(viewModel.posts.isEmpty ? "No posts yet" : "Nothing matches")
                    .font(.appSans(12, weight: .semibold))
                    .foregroundStyle(AppColor.ink)
                Text(viewModel.posts.isEmpty
                     ? "Tap + to share a routine or a product you love."
                     : "Try a different search or filter.")
                    .font(.appSans(10))
                    .foregroundStyle(AppColor.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .modifier(RectangularCard())
        } else {
            LazyVStack(spacing: 14) {
                ForEach(posts) { post in
                    PostCard(
                        post: post,
                        isMine: viewModel.isMine(post),
                        onLike: { Task { await viewModel.toggleLike(post) } },
                        onSave: { Task { await viewModel.toggleSave(post) } },
                        onDelete: { postToDelete = post }
                    ) {
                        PostDetailView(viewModel: viewModel, postId: post.id)
                    }
                }
            }
        }
    }
}

#Preview {
    DiscoverView()
}
