//
//  AppBackground.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/10/26.
//


import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppColor.backgroundCream,
                AppColor.backgroundPink
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}