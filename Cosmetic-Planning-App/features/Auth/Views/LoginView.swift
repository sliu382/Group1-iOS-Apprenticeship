//
//  LoginView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    let onLogin: () -> Void
    let onSignUp: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 0) {
                    titleSection
                    loginCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 38)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .alert(
            "Check Your Email",
            isPresented: $viewModel.showResetConfirmation
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "If an account exists with that email, you'll receive a password reset link."
            )
        }
    }
    
    // MARK: - TitleSection View
    private var titleSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 25))
                .foregroundStyle(Color(hex: 0x815C70))
                .frame(width: 54, height: 54)
                .background(.white.opacity(0.62))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                )
                .shadow(
                    color: AppColor.accent.opacity(0.12),
                    radius: 20,
                    y: 10
                )

            Text("CURA")
                .font(.appSerif( 45))
                .tracking(5)
                .foregroundStyle(AppColor.ink)
        }
        .padding(.top, 45)
        .padding(.bottom, 45)
    }
    // MARK: - LoginCard
    private var loginCard: some View {
        VStack(spacing: 18) {
            Text("WELCOME BACK")
                .font(.appSans(20, weight: .bold))
                .tracking(1.8)
                .foregroundStyle(AppColor.muted)

            AuthField(
                title: "Email",
                placeholder: "you@example.com",
                text: $viewModel.email
            )
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)

            AuthField(
                title: "Password",
                placeholder: "••••••••",
                text: $viewModel.password,
                secure: true
            )

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.appSans(12))
                    .foregroundStyle(.red)
            }

            loginButton
            
            forgotPasswordButton

            signUpButton
        }
        .padding(22)
        .background(.white.opacity(0.76))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .stroke(.white.opacity(0.95), lineWidth: 1)
        }
        .shadow(
            color: AppColor.accent.opacity(0.1),
            radius: 24,
            y: 12
        )
    }
    
    // MARK: - ForgotPasswordButton
    private var forgotPasswordButton: some View {
        HStack {
            //Spacer()

            Button("Forgot Password?") {
                Task {
                    await viewModel.resetPassword()
                }
            }
            .font(.appSans(12, weight:.medium))
            .foregroundStyle(AppColor.ink)
            .disabled(viewModel.isResettingPassword)
        }
    }
    // MARK: - LoginButton
    private var loginButton: some View {
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
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(AppColor.accent)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
            .padding(.top,10)
            .padding(.bottom,0)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.7 : 1)
    }
    
    // MARK: - SignUpButton
    private var signUpButton: some View {
        HStack(spacing: 3) {
            Button("Create an account") {
                onSignUp()
            }
            .foregroundStyle(AppColor.ink)
            .disabled(viewModel.isLoading)
        }
        .font(.appSans(12, weight: .medium))
    }
}

#Preview {
    LoginView(onLogin: {}, onSignUp: {})
}
