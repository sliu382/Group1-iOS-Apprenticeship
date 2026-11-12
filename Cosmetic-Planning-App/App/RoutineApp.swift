//
//  RoutineApp.swift
//  RoutineApp
//
//  Created by Siyu Liu on 10/3/26.
//

import SwiftUI

@main
struct RoutineApp: App {
    @State private var showPasswordRecovery = false
    @State private var recoveryError: String?

    private let authService = AuthService()

    init() {
        NotificationScheduler.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .fullScreenCover(
                    isPresented: $showPasswordRecovery
                ) {
                    NavigationStack {
                        ChangePasswordView()
                    }
                }
                .alert(
                    "Password Recovery Error",
                    isPresented: Binding(
                        get: { recoveryError != nil },
                        set: { if !$0 { recoveryError = nil } }
                    )
                ) {
                    Button("OK") {
                        recoveryError = nil
                    }
                } message: {
                    Text(recoveryError ?? "Unknown error")
                }
                .onOpenURL { url in
                    print("Deep link received")

                    guard url.scheme == "cura",
                          url.host == "reset-password"
                    else {
                        print("Recovery URL did not match")
                        return
                    }

                    print("Recovery URL matched")

                    Task {
                        do {
                            try await authService.handlePasswordRecovery(
                                url: url
                            )

                            print("Supabase recovery succeeded")

                            showPasswordRecovery = true

                            print("ChangePasswordView requested")

                        } catch {
                            print(
                                "Recovery failed: \(error.localizedDescription)"
                            )

                            recoveryError = error.localizedDescription
                        }
                    }
                }
        }
    }
}
