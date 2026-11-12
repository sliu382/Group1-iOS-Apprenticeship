//
//  ScreenHeader.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI
import UIKit

struct ScreenHeader: View {
    let title: String
    var eyebrow: String? = nil      // small caps line above the title, e.g. "THE MUSE COMMUNITY"
    var showsAdd = false
    var onAdd: () -> Void = {}
    var body: some View {
        HStack(alignment:.center) {
            VStack(alignment: .leading, spacing: 2) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.appSans(10, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(AppColor.muted)
                }
                Text(title)
                    .font(.appSerif(30))
                    .foregroundStyle(AppColor.ink)
            }
            Spacer()
            if showsAdd {
                CircleIconButton(symbol: "plus", filled: true, action: onAdd)
            }
            CircleIconButton(symbol: "bell") {}
        }
        .padding(.top,8)
        .padding(.bottom,8)
    }
}

#Preview {
    ScreenHeader(title:"Profile",showsAdd:true)
}
