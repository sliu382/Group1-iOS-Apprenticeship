//
//  PillShapedButton.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

struct PillShapedButton: View {
    let text: String
    var background: Color = Color(hex: 0xEEEafa)
    var foreground: Color = Color(hex: 0x6F638B)
    
    var body: some View {
        Text(text)
            .font(.appSans(0, weight: .bold))
            .tracking(1) // controls spacing around characters
            .foregroundStyle(foreground)
            .padding(.horizontal,9)
            .padding(.vertical, 9)
            .background(background)
            .clipShape(Capsule())
        
    }
}

#Preview {
    PillShapedButton(text:"SKINCARE", background:Color(hex: 0xccbade), foreground:Color(hex: 0xFFFFFF))
}
