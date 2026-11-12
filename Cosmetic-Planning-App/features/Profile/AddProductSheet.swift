//
//  AddProductSheet.swift
//  Cosmetic-Planning-App
//

import SwiftUI
import PhotosUI

struct AddProductSheet: View {
    let onSave: (NewProductDraft) async -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var draft = NewProductDraft()
    @State private var photoItem: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var showsSearch = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                /** Search the catalog to fill everything in */
                Section {
                    Button {
                        showsSearch = true
                    } label: {
                        Label("Search products", systemImage: "magnifyingglass")
                            .font(.appSans(13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(AppColor.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Find it in the product database, or fill it in yourself below.")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                /** Photo: one you pick, or the catalog's */
                Section {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            Spacer()
                            photoPreview
                                .frame(width: 140, height: 155)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.clear)
                
                Section("Product") {
                    TextField("Name (e.g. Barrier Bloom)", text: $draft.name)
                    TextField("Brand (optional)", text: $draft.brand)
                    Picker("Status", selection: $draft.status) {
                        ForEach(Product.statuses, id: \.self, content: Text.init)
                    }
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                isSaving = true
                                draft.photoData = photo.flatMap(compressed)
                                await onSave(draft)
                                isSaving = false
                                dismiss()
                            }
                        }
                        .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showsSearch) {
                ProductSearchView { product in
                    draft.fill(from: product)
                    photo = nil
                    photoItem = nil
                }
            }
            .onChange(of: photoItem) {
                Task {
                    if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                        photo = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var photoPreview: some View {
        if let photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
        } else if let urlString = draft.catalogImageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFit().padding(8)
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
        } else {
            VStack(spacing: 6) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 26))
                Text("Add photo")
                    .font(.appSans(11))
            }
            .foregroundStyle(AppColor.accent)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.rose.opacity(0.4))
        }
    }
    
    // Shrinks the photo to max 1000px and JPEG so uploads stay small
    private func compressed(_ image: UIImage) -> Data? {
        let maxSide: CGFloat = 1000
        let scale = min(1, maxSide / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.7)
    }
}

#Preview {
    AddProductSheet { _ in }
}
