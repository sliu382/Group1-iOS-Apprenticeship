//
//  AuthField.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/1/26.
//

import Foundation
import SwiftUI

struct AuthField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var secure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appSans(15, weight: .semibold))
                .foregroundStyle(Color(hex: 0x615761))

            Group {
                if secure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.appSans(13))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(.white.opacity(0.75))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .stroke(
                    Color(hex: 0xE7DDDC),
                    lineWidth: 1
                )
            }
        }
    }
}

#Preview {
    AuthFieldPreview()
}

private struct AuthFieldPreview: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 18) {
            AuthField(
                title: "Email",
                placeholder: "you@example.com",
                text: $email
            )

            AuthField(
                title: "Password",
                placeholder: "••••••••",
                text: $password,
                secure: true
            )
        }
        .padding(24)
        .background(Color(hex: 0xFBF7F2))
    }
}
