//
//  AddProductSheet.swift
//  Cosmetic-Planning-App
//

import SwiftUI
import PhotosUI

struct AddProductSheet: View {
    let onSave: (String, String, Data?) async -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var status = Product.statuses[0]
    @State private var photoItem: PhotosPickerItem?
    @State private var photo: UIImage?
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        HStack {
                            Spacer()
                            if let photo {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 155)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 26))
                                    Text("Add photo")
                                        .font(.appSans(11))
                                }
                                .foregroundStyle(AppColor.accent)
                                .frame(width: 140, height: 155)
                                .background(AppColor.rose.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.clear)
                
                Section("Product") {
                    TextField("Name (e.g. Barrier Bloom)", text: $name)
                    Picker("Status", selection: $status) {
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
                                await onSave(
                                    name.trimmingCharacters(in: .whitespaces),
                                    status,
                                    photo.flatMap(compressed)
                                )
                                isSaving = false
                                dismiss()
                            }
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
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
    AddProductSheet { _, _, _ in }
}
