//
//  Font.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

extension Font {
    // optional italic argument
    static func appSerif(_ size: CGFloat, italic: Bool = false) -> Font {
        .custom(italic ? "DMSerifDisplay-Italic": "DMSerifDisplay-Regular", size: size)
        // ABOVE is an IMPLICIT return
    }
    
    static func appSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .semibold, .bold, .heavy, .black: name = "DMSans-SemiBold"
        case .medium: name = "DMSans-Medium"
        default: name = "DMSans-Regular"
        }
        return .custom(name, size:size)
    }
}
