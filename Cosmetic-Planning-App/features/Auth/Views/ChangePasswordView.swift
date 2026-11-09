//
//  ChangePasswordView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/8/26.
//


import SwiftUI

struct ChangePasswordView: View {

    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0xFBF7F2),
                    Color(hex: 0xF7EEEC)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(hex: 0x815C70))
                            .frame(width: 76, height: 76)
                            .background(
                                Color.white.opacity(0.8),
                                in: RoundedRectangle(
                                    cornerRadius: 22
                                )
                            )

                        Text("Change Password")
                            .font(.system(
                                size: 28,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundStyle(Color(hex: 0x543B47))

                        Text("Keep your account safe and secure")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // MARK: - Password Form
                    VStack(alignment: .leading, spacing: 20) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            SecureField(
                                "Enter new password",
                                text: $viewModel.newPassword
                            )
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(
                                Color.white,
                                in: RoundedRectangle(
                                    cornerRadius: 14
                                )
                            )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm New Password")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            SecureField(
                                "Confirm new password",
                                text: $viewModel.confirmPassword
                            )
                            .textContentType(.newPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(
                                Color.white,
                                in: RoundedRectangle(
                                    cornerRadius: 14
                                )
                            )
                        }

                        // MARK: - Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        // MARK: - Submit Button
                        Button {
                            Task {
                                await viewModel.changePassword()
                            }
                        } label: {
                            HStack {
                                Spacer()

                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Update Password")
                                        .fontWeight(.semibold)
                                }

                                Spacer()
                            }
                            .padding()
                            .foregroundStyle(.white)
                            .background(
                                Color(hex: 0x815C70),
                                in: RoundedRectangle(
                                    cornerRadius: 14
                                )
                            )
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding(24)
                    .background(
                        Color.white.opacity(0.5),
                        in: RoundedRectangle(
                            cornerRadius: 24
                        )
                    )
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Password Updated!",
            isPresented: $viewModel.showSuccessConfirmation
        ) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your password has been changed successfully.")
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
}