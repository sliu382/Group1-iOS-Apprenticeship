//
//  ScreenHeader.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//



import SwiftUI
import UIKit

struct ScreenHeader<Content: View>: View {
    let title: String
    var eyebrow: String? = nil
    var showsAdd = false
    var onAdd: () -> Void = {}

    @ViewBuilder var content: () -> Content

    var body: some View {
        HStack(alignment: .center) {
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

            content() // Custom optional content

            if showsAdd {
                CircleIconButton(symbol: "plus", filled: true, action: onAdd)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

// Allows ScreenHeader to work without passing custom content
extension ScreenHeader where Content == EmptyView {
    init(
        title: String,
        eyebrow: String? = nil,
        showsAdd: Bool = false,
        onAdd: @escaping () -> Void = {}
    ) {
        self.init(
            title: title,
            eyebrow: eyebrow,
            showsAdd: showsAdd,
            onAdd: onAdd,
            content: { EmptyView() }
        )
    }
}

#Preview {
    ScreenHeader(title: "Profile", showsAdd: true)
}
//import SwiftUI
//import UIKit
//
//struct ScreenHeader: View {
//    let title: String
//    var eyebrow: String? = nil      // small caps line above the title, e.g. "THE MUSE COMMUNITY"
//    var showsAdd = false
//    var onAdd: () -> Void = {}
//    var body: some View {
//        HStack(alignment:.center) {
//            VStack(alignment: .leading, spacing: 2) {
//                if let eyebrow {
//                    Text(eyebrow.uppercased())
//                        .font(.appSans(10, weight: .semibold))
//                        .tracking(2)
//                        .foregroundStyle(AppColor.muted)
//                }
//                Text(title)
//                    .font(.appSerif(30))
//                    .foregroundStyle(AppColor.ink)
//            }
//            Spacer()
//            if showsAdd {
//                CircleIconButton(symbol: "plus", filled: true, action: onAdd)
//            }
//            //CircleIconButton(symbol: "bell") {}
//        }
//        .padding(.top,8)
//        .padding(.bottom,8)
//    }
//}
//
//#Preview {
//    ScreenHeader(title:"Profile",showsAdd:true)
//}
