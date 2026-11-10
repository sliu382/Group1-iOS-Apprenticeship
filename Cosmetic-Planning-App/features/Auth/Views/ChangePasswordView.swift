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
            AppBackground()

            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Header
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColor.accent) //Color(hex: 0x815C70)
                            .frame(width: 76, height: 76)
                            .background(
                                Color.white.opacity(0.8),
                                in: RoundedRectangle(
                                    cornerRadius: 22
                                )
                            )

                        Text("Change Password")
                            .font(.appSans(32,weight:.bold))
                            .foregroundStyle(AppColor.accent) //Color(hex: 0x543B47)
                       .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // MARK: - Password Form
                    VStack(alignment: .leading, spacing: 20) {

                        AuthField(
                            title: "New Password",
                            placeholder: "••••••••",
                            text: $viewModel.newPassword
                        )
                        .textContentType(.newPassword)
                        
                        AuthField(
                            title: "Confirm New Passsword",
                            placeholder: "••••••••",
                            text: $viewModel.confirmPassword,
                            secure: true
                        )
                        .textContentType(.newPassword)

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
                                        .font(.appSans(18,weight:.semibold))
                                }

                                Spacer()
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
