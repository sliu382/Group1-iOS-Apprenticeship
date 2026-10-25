//
//  ProfileView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var section = "Overview"
    let onLogout: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScreenHeader(title: "Profile")
                
                HStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Text("M")
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
                        Text("FIRST LAST_NAME").font(.appSerif(21))
                        Text("Beauty journey since March 2024")
                            .font(.appSans(9))
                            .foregroundStyle(AppColor.muted)
                    }
                    Spacer()
                    Button("Edit") {}
                        .font(.appSans(10, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x8E657A))
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
                
                /** Check here*/
                Picker("Profile section", selection: $section) {
                    ForEach(["Overview", "Shelf", "Routines"], id: \.self, content: Text.init)
                }
                .pickerStyle(.segmented)

//                switch section {
//                case "Shelf": shelf
//                case "Routines": routines
//                default: overview
//                }
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
    }
}

#Preview {
    ProfileView(onLogout: {})
}
