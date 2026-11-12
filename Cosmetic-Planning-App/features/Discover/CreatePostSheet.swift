//
//  CreatePostSheet.swift
//  Cosmetic-Planning-App
//

import SwiftUI

/** "+" on Discover: share a routine or recommend a product */
struct CreatePostSheet: View {
    let viewModel: DiscoverViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var draft = NewPostDraft()
    @State private var isPosting = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Post type", selection: $draft.kind) {
                        Text("Share a routine").tag(PostKind.routine)
                        Text("Recommend a product").tag(PostKind.recommendation)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                Section("Post") {
                    Picker("Category", selection: $draft.category) {
                        ForEach(PostCategory.allCases) { Text($0.title).tag($0) }
                    }
                    TextField("Title (e.g. My calm-skin morning ritual)", text: $draft.title)
                    TextField("Tell people about it...", text: $draft.body, axis: .vertical)
                        .lineLimit(3...6)
                }

                switch draft.kind {
                case .routine:
                    Section {
                        if viewModel.myRoutines.isEmpty {
                            Text("You don't have any routines yet. Create one in the Routines tab first.")
                                .font(.appSans(11))
                                .foregroundStyle(AppColor.muted)
                        } else {
                            Picker("Routine", selection: $draft.routineId) {
                                Text("Choose one").tag(UUID?.none)
                                ForEach(viewModel.myRoutines) { Text($0.name).tag(UUID?.some($0.id)) }
                            }
                        }
                    } header: {
                        Text("Routine to share")
                    } footer: {
                        Text("Its steps appear on your post.")
                    }
                case .recommendation:
                    Section("Product") {
                        TextField("Product name", text: $draft.productName)
                        TextField("Price (optional, e.g. 22)", text: $draft.productPrice)
                            .keyboardType(.decimalPad)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.appSans(11))
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Button("Post") {
                            Task {
                                isPosting = true
                                let posted = await viewModel.create(draft)
                                isPosting = false
                                if posted { dismiss() }
                            }
                        }
                        .disabled(!draft.isValid)
                    }
                }
            }
            .task { await viewModel.loadMyRoutines() }
        }
    }
}
