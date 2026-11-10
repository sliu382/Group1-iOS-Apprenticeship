//
//  SignUpView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()

    let onSignUp: () -> Void
    let onLogin: () -> Void

    var body: some View {
        ZStack {
            // MARK: - Background
            AppBackground()

            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Title Area
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

                        Text("APP NAME HERE")
                            .font(.appSerif(30))
                            .tracking(5)
                    }
                    .padding(.top, 45)
                    .padding(.bottom, 45)

                    // MARK: - Sign Up Card
                    VStack(spacing: 18) {
                        Text("CREATE ACCOUNT")
                            .font(.appSans(20, weight: .bold))
                            .tracking(1.8)
                            .foregroundStyle(AppColor.muted)
                            .padding(20)

                        // MARK: - Account Information
                        AuthField(
                            title: "First Name",
                            placeholder: "First",
                            text: $viewModel.profile.firstName
                        )
                        .textInputAutocapitalization(.words)

                        AuthField(
                            title: "Last Name",
                            placeholder: "Last",
                            text: $viewModel.profile.lastName
                        )
                        .textInputAutocapitalization(.words)

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

                        AuthField(
                            title: "Confirm Password",
                            placeholder: "••••••••",
                            text: $viewModel.confirmPassword,
                            secure: true
                        )

                        // MARK: - Beauty Profile
                        Divider()
                            .overlay(Color(hex: 0xE7DDDC))
                            .padding(.vertical, 5)

                        HStack {
                            sectionHeader("YOUR BEAUTY PROFILE")

                            Spacer()

                            Text("Optional")
                                .font(.appSans(11))
                                .foregroundStyle(AppColor.muted)
                        }

                        BeautyPicker(
                            title: "Skin Type",
                            selection: $viewModel.profile.skinType,
                            options: [
                                "Normal",
                                "Dry",
                                "Oily",
                                "Combination",
                                "Sensitive"
                            ]
                        )

                        BeautyPicker(
                            title: "Hair Type",
                            selection: $viewModel.profile.hairType,
                            options: [
                                "Straight",
                                "Wavy",
                                "Curly",
                                "Coily"
                            ]
                        )

                        BeautyPicker(
                            title: "Top Concern",
                            selection: $viewModel.profile.topConcern,
                            options: [
                                "Acne",
                                "Dryness",
                                "Hyperpigmentation",
                                "Aging",
                                "Frizz",
                                "Hair Damage"
                            ]
                        )

                        BeautyPicker(
                            title: "Beauty Style",
                            selection: $viewModel.profile.beautyStyle,
                            options: [
                                "Soft",
                                "Natural",
                                "Minimal",
                                "Glam",
                                "Bold"
                            ]
                        )

                        // MARK: - Optional Information Note
                        HStack(spacing: 10) {
                            Image(systemName: "heart")
                                .foregroundStyle(Color(hex: 0x815C70))

                            Text(
                                "You can always update your beauty preferences later!"
                            )
                            .font(.appSans(11))
                            .foregroundStyle(AppColor.muted)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(12)
                        .background(Color(hex: 0xF7EEEC))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )

                        // MARK: - Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.appSans(12))
                                .foregroundStyle(.red)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }

                        // MARK: - Create Account Button
                        Button {
                            Task {
                                await viewModel.signUp()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
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

                        // MARK: - Back to Login
                        HStack(spacing: 3) {
                            Text("Already have an account?")
                                .foregroundStyle(AppColor.muted)

                            Button("Login", action: onLogin)
                                .foregroundStyle(
                                    Color(hex: 0x8B6074)
                                )
                                .disabled(viewModel.isLoading)
                        }
                        .font(.appSans(11, weight: .medium))
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
                        .stroke(
                            .white.opacity(0.95),
                            lineWidth: 1
                        )
                    }
                    .shadow(
                        color: AppColor.accent.opacity(0.1),
                        radius: 24,
                        y: 12
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 38)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        // MARK: - Sign Up Confirmation
        .alert(
            "Account Created",
            isPresented: $viewModel.showSignUpConfirmation
        ) {
            Button("OK") {
                onSignUp()
            }
        } message: {
            Text(
                "Your account was created! Check your email for a confirmation link if verification is required, then login."
            )
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.appSans(12, weight: .semibold))
            .tracking(1.5)
            .foregroundStyle(Color(hex: 0x815C70))
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}

#Preview {
    SignUpView(
        onSignUp: {},
        onLogin: {}
    )
}
