//
//  ProductSearchView.swift
//  Cosmetic-Planning-App
//

import SwiftUI

/** Search the Open Beauty Facts catalog and pick a product.
    Used by Shelf -> Add product and Discover -> Recommend a product. */
struct ProductSearchView: View {
    var initialQuery = ""    // starts searching right away if set
    let onPick: (CatalogProduct) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [CatalogProduct] = []
    @State private var page = 1
    @State private var hasMore = false
    @State private var hasSearched = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var searchFocused: Bool

    private let service = ProductCatalogService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                searchField
                    .padding(.horizontal, 20)

                List {
                    content

                    Section {
                        Text("Product info from Open Beauty Facts, a free community database. Can't find it? Cancel and add it by hand.")
                            .font(.appSans(9))
                            .foregroundStyle(AppColor.muted)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.top, 8)
            .background(AppColor.cream)
            .navigationTitle("Search Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                if query.isEmpty && !initialQuery.isEmpty {
                    query = initialQuery
                    await search()
                } else if initialQuery.isEmpty {
                    searchFocused = true
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.muted)
            TextField("Brand or product, e.g. CeraVe cleanser", text: $query)
                .font(.appSans(12))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($searchFocused)
                .onSubmit { Task { await search() } }
            if !query.isEmpty {
                Button {
                    query = ""
                    searchFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.muted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 13)
        .frame(height: 46)
        .modifier(RectangularCard(radius: 15, color: .white))
    }

    @ViewBuilder
    private var content: some View {
        if isLoading && results.isEmpty {
            HStack { Spacer(); ProgressView(); Spacer() }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else if let errorMessage, results.isEmpty {
            message(icon: "wifi.exclamationmark", title: "Search didn't work", detail: errorMessage)
        } else if results.isEmpty {
            if hasSearched {
                message(icon: "magnifyingglass", title: "No matches",
                        detail: "Try fewer words or just the brand name.")
            } else {
                message(icon: "sparkles", title: "Find a product",
                        detail: "Type a brand or product name, then tap Search.")
            }
        } else {
            ForEach(results) { product in
                Button {
                    onPick(product)
                    dismiss()
                } label: {
                    resultRow(product)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }

            if hasMore {
                Button {
                    Task { await loadMore() }
                } label: {
                    HStack {
                        Spacer()
                        if isLoading { ProgressView() } else {
                            Text("Load more")
                                .font(.appSans(11, weight: .semibold))
                                .foregroundStyle(Color(hex: 0x8E657A))
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
    }

    private func resultRow(_ product: CatalogProduct) -> some View {
        HStack(spacing: 12) {
            Color.white
                .frame(width: 54, height: 54)
                .overlay {
                    if let urlString = product.thumbnailUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .padding(4)
                    } else {
                        Image(systemName: "photo")
                            .foregroundStyle(AppColor.muted)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(AppColor.line, lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                if let brand = product.brand {
                    Text(brand.uppercased())
                        .font(.appSans(8, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(AppColor.muted)
                }
                Text(product.name)
                    .font(.appSans(12, weight: .semibold))
                    .foregroundStyle(AppColor.ink)
                    .lineLimit(2)
                if let quantity = product.quantity, !quantity.isEmpty {
                    Text(quantity)
                        .font(.appSans(9))
                        .foregroundStyle(AppColor.muted)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "plus.circle")
                .font(.system(size: 18))
                .foregroundStyle(AppColor.accent)
        }
        .contentShape(Rectangle())
    }

    private func message(icon: String, title: String, detail: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColor.accent)
            Text(title)
                .font(.appSans(12, weight: .semibold))
                .foregroundStyle(AppColor.ink)
            Text(detail)
                .font(.appSans(10))
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func search() async {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        hasSearched = true
        results = []
        page = 1
        do {
            let response = try await service.search(text, page: 1)
            results = response.products
            hasMore = response.hasMore
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadMore() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await service.search(query.trimmingCharacters(in: .whitespaces), page: page + 1)
            page += 1
            let existing = Set(results.map(\.code))
            results += response.products.filter { !existing.contains($0.code) }
            hasMore = response.hasMore
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ProductSearchView { _ in }
}
