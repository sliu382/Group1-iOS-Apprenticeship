//
//  ProfileView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var section = "Overview"
    @State private var viewModel = ProfileViewModel()
    @State private var isEditing = false
    @State private var isAddingProduct = false
    let onLogout: () -> Void
    
    var body: some View {
        NavigationStack {
        ScrollView {
            VStack(spacing: 12) {
                ScreenHeader(title: "Profile")
                
                /** Profile card */
                HStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Text(viewModel.profile?.initials ?? "")
                            .font(.appSerif(25))
                            .foregroundStyle(.white)
                            .frame(width: 62, height: 62)
                            .background(Color(hex: 0xA57A8E))
                            .clipShape(Circle())
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(hex: 0x9A7185))
                            .frame(width: 23, height: 23)
                            .background(.white)
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading, spacing: 4){
                        if let profile = viewModel.profile {
                            Text(profile.fullName).font(.appSerif(21))
                            Text("Beauty journey since \(profile.memberSince)")
                                .font(.appSans(9))
                                .foregroundStyle(AppColor.muted)
                        } else if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Your Name").font(.appSerif(21))
                        }
                    }
                    Spacer()
                    Button("Edit") { isEditing = true }
                        .font(.appSans(10, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x8E657A))
                        .frame(width: 44, height: 44)
                        .background(.white)
                        .clipShape(Circle())
                }
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xF1E4E6), Color(hex: 0xEBE6F1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.appSans(10))
                        .foregroundStyle(.red)
                }
                
                /** Check here*/
                Picker("Profile section", selection: $section) {
                    ForEach(["Overview", "Shelf", "Routines"], id: \.self, content: Text.init)
                }
                .pickerStyle(.segmented)

                switch section {
                case "Shelf": shelf
                case "Routines": routines
                default: overview
                }
                
                /** Log out button*/
                Button(action: onLogout) {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.appSans(10, weight: .medium))
                        .foregroundStyle(Color(hex: 0x9A6674))
                        .padding(.top, 15)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
        }
        .background(AppColor.cream)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadProfile()
            await viewModel.loadProducts()
            await viewModel.loadStats()
        }
        .refreshable {
            await viewModel.loadProfile()
            await viewModel.loadProducts()
            await viewModel.loadStats()
        }
        .sheet(isPresented: $isAddingProduct) {
            AddProductSheet { name, status, imageData in
                await viewModel.addProduct(name: name, status: status, imageData: imageData)
            }
        }
        .sheet(isPresented: $isEditing) {
            EditProfileSheet(profile: viewModel.profile) { draft in
                await viewModel.save(draft)
            }
        }
        }
    }
    
    /** Overview tab */
    private var overview: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Your beauty profile", action: "Edit") { isEditing = true }
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                BeautyTraitCard(symbol: "drop", tint: AppColor.peach, label: "Skin type", value: viewModel.profile?.skinType)
                BeautyTraitCard(symbol: "sparkles", tint: AppColor.lilac, label: "Hair type", value: viewModel.profile?.hairType)
                BeautyTraitCard(symbol: "heart", tint: AppColor.mint, label: "Top concern", value: viewModel.profile?.topConcern)
                BeautyTraitCard(symbol: "sun.max", tint: AppColor.rose, label: "Beauty style", value: viewModel.profile?.beautyStyle)
            }
            
            SectionHeader(title: "At a glance")
            
            HStack(spacing: 0) {
                // TODO: hook "Day streak" up once that feature has data
                GlanceStat(number: viewModel.products.count, label: "On my shelf")
                Divider().frame(height: 40)
                GlanceStat(number: viewModel.routineCount, label: "Routines")
                Divider().frame(height: 40)
                GlanceStat(number: 0, label: "Day streak")
            }
            .padding(.vertical, 14)
            .modifier(RectangularCard())
        }
    }
}

extension ProfileView {
    /** Shelf tab */
    var shelf: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "My shelf", action: "Add product") { isAddingProduct = true }
            if viewModel.products.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColor.accent)
                    Text("Your shelf is empty")
                        .font(.appSans(11, weight: .semibold))
                        .foregroundStyle(AppColor.ink)
                    Text("Tap Add product to start your collection.")
                        .font(.appSans(9))
                        .foregroundStyle(AppColor.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .modifier(RectangularCard())
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), alignment: .leading, spacing: 16) {
                    ForEach(viewModel.products) { product in
                        ProductCard(product: product)
                            .contextMenu {
                                Button("Remove from shelf", systemImage: "trash", role: .destructive) {
                                    Task { await viewModel.deleteProduct(product) }
                                }
                            }
                    }
                }
            }
        }
    }
    
    /** Routines tab */
    var routines: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "My routines")
            if viewModel.routines.isEmpty {
                Text("No routines yet. Create one in the Routines tab.")
                    .font(.appSans(10))
                    .foregroundStyle(AppColor.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .modifier(RectangularCard())
            }
            ForEach(viewModel.routines) { routine in
                NavigationLink {
                    RoutineDetailView(routine: routine)
                } label: {
                    HStack(spacing: 13) {
                        Image(systemName: RoutineTheme.symbol(for: routine.name))
                            .font(.system(size: 16))
                            .foregroundStyle(RoutineTheme.symbolColor(for: routine.name))
                            .frame(width: 42, height: 42)
                            .background(
                                RoutineTheme.symbolBackground(for: routine.name),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(routine.name)
                                .font(.appSans(12, weight: .semibold))
                                .foregroundStyle(AppColor.ink)
                            let count = viewModel.stepCounts[routine.id] ?? 0
                            Text("\(count) step\(count == 1 ? "" : "s")")
                                .font(.appSans(9))
                                .foregroundStyle(AppColor.muted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColor.ink)
                    }
                    .padding(14)
                    .modifier(RectangularCard())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/** One product on the shelf */
struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Color(hex: 0xEFE6E6)
                .aspectRatio(0.9, contentMode: .fit)
                .overlay {
                    if let urlString = product.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AppColor.accent)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.bottom, 4)
            Text(product.name)
                .font(.appSans(10, weight: .semibold))
                .foregroundStyle(AppColor.ink)
                .lineLimit(1)
            Text(product.status)
                .font(.appSans(8))
                .foregroundStyle(AppColor.muted)
        }
    }
}

/** One of the four "Your beauty profile" cards */
struct BeautyTraitCard: View {
    let symbol: String
    let tint: Color
    let label: String
    let value: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 14))
                .foregroundStyle(AppColor.accent)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.bottom, 8)
            Text(label.uppercased())
                .font(.appSans(8))
                .tracking(0.8)
                .foregroundStyle(AppColor.muted)
            Text(value?.isEmpty == false ? value! : "Add")
                .font(.appSans(11, weight: .semibold))
                .foregroundStyle(value?.isEmpty == false ? AppColor.ink : AppColor.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .modifier(RectangularCard())
    }
}

/** One number in the "At a glance" row */
struct GlanceStat: View {
    let number: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(number)")
                .font(.appSerif(22))
                .foregroundStyle(AppColor.ink)
            Text(label)
                .font(.appSans(9))
                .foregroundStyle(AppColor.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

/** Edit profile sheet */
struct EditProfileSheet: View {
    let profile: UserProfile?
    let onSave: (ProfileDraft) async -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ProfileDraft(from: nil)
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("First name", text: $draft.firstName)
                    TextField("Last name", text: $draft.lastName)
                }
                Section("Your beauty profile") {
                    TextField("Skin type (e.g. Dry & sensitive)", text: $draft.skinType)
                    TextField("Hair type (e.g. Wavy · 2B)", text: $draft.hairType)
                    TextField("Top concern (e.g. Hydration)", text: $draft.topConcern)
                    TextField("Beauty style (e.g. Soft & natural)", text: $draft.beautyStyle)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isSaving = true
                            await onSave(draft)
                            isSaving = false
                            dismiss()
                        }
                    }
                    .disabled(isSaving || draft.firstName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { draft = ProfileDraft(from: profile) }
        }
    }
}

#Preview {
    ProfileView(onLogout: {})
}
