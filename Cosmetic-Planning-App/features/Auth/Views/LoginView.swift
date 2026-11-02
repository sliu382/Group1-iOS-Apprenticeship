//
//  LoginView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI

struct LoginView: View {
//    @State private var email = ""
//    @State private var password = ""
//    //@State private var rememberMe = true
//    let onLogin: () -> Void
//    
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @State private var showSignUpConfirmation = false
//    
//    private let authService = AuthService()
    @StateObject private var viewModel = LoginViewModel()
    
    let onLogin: () -> Void
    let onSignUp: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xFBF7F2), Color(hex: 0xF7EEEC)],
                           startPoint: .topLeading,
                           endPoint: .topTrailing
            )
            .ignoresSafeArea()
            
            ScrollView{
                
                // MARK: - Title Area
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
                    
                    // MARK: - Login Card
                    VStack(spacing: 18) {
                        Text("WELCOME BACK")
                            .font(.appSans(20, weight: .bold))
                            .tracking(1.8)
                            .foregroundStyle(AppColor.muted)
                        
                        // Email
                        AuthField(
                            title: "Email",
                            placeholder: "you@example.com",
                            text: $viewModel.email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        // Passowrd
                        AuthField(
                            title: "Password",
                            placeholder: "••••••••",
                            text: $viewModel.password,
                            secure:true
                        )
                        /**User puts in wrong password**/
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.appSans(12))
                                .foregroundStyle(.red)
                        }
                        
                        // MARK: - Login button
                        Button {
                            Task {
                                let success = await viewModel.login()

                                if success {
                                    onLogin()
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Login")
                                        .font(
                                            .appSans(
                                                18,
                                                weight: .semibold
                                            )
                                        )
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 50
                            )
                            .background(Color(hex: 0x4C3C48))
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 14,
                                    style: .continuous
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoading)
                        .opacity(viewModel.isLoading ? 0.7 : 1)
                        
                        // MARK: - navigation to signup
                        HStack(spacing: 3) {
//                            Text("New to APP NAME?")
//                                .foregroundStyle(AppColor.muted)
                            Button("Create an account"){
                                onSignUp()
                            }
                            .foregroundStyle(Color(hex: 0x8B6074))
                            .disabled(viewModel.isLoading)
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
            .scrollDismissesKeyboard(.interactively)
        }
    }


//    private func login() {
//        guard !viewModel.email.isEmpty, !viewModel.password.isEmpty else {
//            errorMessage = "Please enter your email and password."
//            return
//        }
//
//        viewModel.isLoading = true
//        viewModel.errorMessage = nil
//
//        Task { @MainActor in
//            defer { isLoading = false }
//
//            do {
//                try await authService.signIn(
//                    email: viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines),
//                    password: viewModel.password
//                )
//
//                // Login succeeded, navigate to your app
//                onLogin()
//
//            } catch {
//                errorMessage = error.localizedDescription
//            }
//        }
}

//    private func signUp() {
//        guard !email.isEmpty, !password.isEmpty else {
//            errorMessage = "Please enter your email and password."
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        Task { @MainActor in
//            defer { isLoading = false }
//
//            do {
//                try await authService.signUp(
//                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
//                    password: password,
//                    profile: .init(displayName: "New User")
//                )
//
//                showSignUpConfirmation = true
//
//            } catch {
//                errorMessage = error.localizedDescription
//            }
//        }
//    }



#Preview {
    LoginView(onLogin: {}, onSignUp: {})
}
