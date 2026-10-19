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
    var showsAdd = false
    var body: some View {
        HStack(alignment:.center) {
            Text(title)
                .font(.appSerif(30))
                .foregroundStyle(AppColor.ink)
            Spacer()
            if showsAdd {
                CircleIconButton(symbol: "plus", filled: true) {}
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
