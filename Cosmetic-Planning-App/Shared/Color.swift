//
//  Color.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

enum AppColor {
    static let ink = Color(hex: 0x332D38)
    static let muted = Color(hex: 0x817783)
    static let cream = Color(hex: 0xFCFAF7)
    static let paper = Color(hex: 0xFFFEFD)
    static let peach = Color(hex: 0xF4D7C7)
    static let rose = Color(hex: 0xEFD4DA)
    static let lilac = Color(hex: 0xDDD7ED)
    static let mint = Color(hex: 0xDBE7DC)
    static let line = Color(hex: 0xEBE5E2)
    static let accent = Color(hex: 0x6C5362)
}

// Creates a new constructor that allows hex values to be inputted as an argument
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
