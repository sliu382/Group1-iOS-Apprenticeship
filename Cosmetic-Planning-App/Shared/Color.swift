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
    static let backgroundCream = Color(hex: 0xFBF7F2)
    static let backgroundPink = Color(hex: 0xF7EEEC)
}

// Global vividness knob for every Color(hex:) in the app.
// 1.0 = the original hex values exactly; higher = more saturated. Try 1.3–2.0.
enum ColorTuning {
    static let saturationBoost: Double = 1.6
}

// Creates a new constructor that allows hex values to be inputted as an argument
extension Color {
    init(hex: UInt, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255

        // Push each channel away from the color's brightness to increase saturation
        // while keeping its lightness roughly the same.
        let k = ColorTuning.saturationBoost
        let luma = 0.299 * r + 0.587 * g + 0.114 * b
        func boost(_ c: Double) -> Double { min(1, max(0, luma + (c - luma) * k)) }

        self.init(
            .sRGB,
            red: boost(r),
            green: boost(g),
            blue: boost(b),
            opacity: alpha
        )
    }
}
