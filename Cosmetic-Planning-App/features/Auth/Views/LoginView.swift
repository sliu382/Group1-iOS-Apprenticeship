//
//  LoginView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    //@State private var rememberMe = true]
    let onLogin: () -> Void
    
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xFBF7F2), Color(hex: 0xF7EEEC)],
                           startPoint: .topLeading,
                           endPoint: .topTrailing
            )
            .ignoresSafeArea()
            
            ScrollView{
                /** TITLE AREA **/
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 25))
                            .foregroundStyle(Color(hex: 0x815c70))
                            .frame(width: 54, height: 54)
                            .background(.white.opacity(0.62))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: AppColor.accent.opacity(0.12), radius: 20, y:10)
                        Text("APP NAME HERE")
                            .font(.appSerif(30))
                            .tracking(5)
                    }
                    .padding(.top, 45)
                    .padding(.bottom, 70)
            
                    VStack(spacing: 18) {
                        Text("WELCOME BACK")
                            .font(.appSans(20, weight: .bold))
                            .tracking(1.8)
                            .foregroundStyle(AppColor.muted)
                        
                        /** LOGIN AREA */
                        LoginField(title: "Email", placeholder: "you@example.com", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        LoginField(title: "Password", placeholder: "••••••••", text: $password, secure: true)
                        
                        /** Login Button*/
                        Button(action: onLogin) {
                            Text("Login")
                                .font(.appSans(18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color(hex: 0x4C3C48))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(EmptyButtonStyle())
                        
                        HStack(spacing: 3) {
                            Text("New to APP NAME?")
                                .foregroundStyle(AppColor.muted)
                            Button("Create an account", action: onLogin)
                                .foregroundStyle(Color(hex: 0x8B6074))
                        }
                        .font(.appSans(11, weight: .medium))
                    }
                    .padding(22)
                    .background(.white.opacity(0.76))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.95), lineWidth: 1)
                    }
                    .shadow(color: AppColor.accent.opacity(0.1), radius: 24, y: 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 38)
            }
        }
    }
}

private struct LoginField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var secure = false
    
    var body: some View {
        VStack(alignment:.leading, spacing: 6) {
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
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(.white.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 12, style:. continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(hex: 0xE7DDDC), lineWidth: 1)
            }
        }
    }
}

#Preview {
    LoginView(onLogin: {})
}
