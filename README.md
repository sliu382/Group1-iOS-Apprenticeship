// CURA

// A modern, privacy‑minded cosmetic planning and beauty routine companion. CURA helps you track products on your shelf, build routines, and plan appointments and reminders — all with a calm, elegant SwiftUI design.

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Welcome to CURA")
            .font(.appSans(.title))
            .foregroundColor(AppColor.primary)
            .padding()
            .background(AppBackground.material)
    }
}

// MARK: - AppColor

enum AppColor {
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let accent = Color("AccentColor")
    static let background = Color("BackgroundColor")
}

// MARK: - AppBackground

enum AppBackground {
    static let material = Color(UIColor.systemBackground)
}

// MARK: - Font Helpers

extension Font {
    static func appSans(_ style: TextStyle) -> Font {
        Font.system(style, design: .rounded)
    }

    static func appSerif(_ style: TextStyle) -> Font {
        Font.system(style, design: .serif)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
