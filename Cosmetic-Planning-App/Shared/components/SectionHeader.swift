//
//  SectionHeader.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var action: String?
    var onAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.appSerif(20))
                .foregroundStyle(AppColor.ink)
            Spacer()
            if let action {
                Button {
                    onAction?()
                } label: {
                    HStack (spacing: 2) {
                        Text(action)
                        Image(systemName: "chevron.right")
                    }
                    .font(.appSans(12))
                    .foregroundStyle(AppColor.muted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top,14)
    }
}

#Preview {
    SectionHeader(title: "My Routines", action: "See all") {}
}
