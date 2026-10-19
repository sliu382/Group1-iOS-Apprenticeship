//
//  CircleIconButton.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

// Can be filled in circle or empty circle
struct CircleIconButton: View {
    let symbol: String
    var filled = false
    let action: () -> Void // takes in a function as an argument
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(filled ? .white : AppColor.ink)
                .frame(width: 42, height: 42)
                .background(filled ? AppColor.accent: AppColor.paper)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(filled ? AppColor.accent: AppColor.line, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    // Not filled-in circle
    // CircleIconButton(symbol:"bell", action: {})
    
    // Filled in Circle
    CircleIconButton(symbol:"bell", filled: true, action: {})
}
