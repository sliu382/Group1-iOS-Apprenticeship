//
//  RoutineTheme.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//


import SwiftUI

// A small shared token layer for the two routines screens.
// Uses your project's existing Color(hex:) helper and custom fonts in the views.
enum RoutineTheme {
    static let cream = Color(hex: 0xFBF7F2)
    static let paper = Color(hex: 0xFFFCFA)
    static let ink = Color(hex: 0x4C3C48)
    static let muted = Color(hex: 0x8F7E86)
    static let rose = Color(hex: 0x95657E)
    static let blush = Color(hex: 0xF9E8EA)
    static let peach = Color(hex: 0xF9E8DD)
    static let lavender = Color(hex: 0xEEE8F5)
    static let line = Color(hex: 0xEADDE2)

    static func symbol(for name: String) -> String {
        let name = name.lowercased()
        if name.contains("hair") { return "wind" }
        if name.contains("night") || name.contains("evening") { return "moon.stars.fill" }
        if name.contains("morning") { return "sun.max.fill" }
        if name.contains("skin") { return "drop.fill" }
        return "sparkles"
    }

    static func symbolColor(for name: String) -> Color {
        let name = name.lowercased()
        if name.contains("hair") { return Color(hex: 0x816EA3) }
        if name.contains("night") || name.contains("evening") { return Color(hex: 0x836D9A) }
        return Color(hex: 0xB77567)
    }

    static func symbolBackground(for name: String) -> Color {
        let name = name.lowercased()
        if name.contains("hair") || name.contains("night") || name.contains("evening") {
            return lavender
        }
        return peach
    }
}

private struct RoutinePastelCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoutineTheme.paper,
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(RoutineTheme.line, lineWidth: 1)
            }
            .shadow(color: RoutineTheme.ink.opacity(0.045), radius: 10, y: 4)
    }
}

extension View {
    func routinePastelCard() -> some View {
        modifier(RoutinePastelCard())
    }
}

