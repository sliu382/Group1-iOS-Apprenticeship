//
//  RectangularCard.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

struct RectangularCard: ViewModifier {
    var radius: CGFloat = 20
    var color: Color = AppColor.paper
    
    // Fullfills ViewModifier Protocol --> takes in some content as an argument
    func body(content: Content) -> some View {
        content
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppColor.line, lineWidth:1)
            }
    }
}

//******** DID NOT EXTEND VIEW SO --> USE .modifier(RectangularCard(...)) *********/
