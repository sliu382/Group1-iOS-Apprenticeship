//
//  AuthContainerView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/1/26.
//



import SwiftUI

struct AuthContainerView: View {
    @State private var showingSignUp = false

    let onAuthenticated: () -> Void

    var body: some View {
        Group {
            if showingSignUp {
                SignUpView(
                    onSignUp: {
                        // Return to Login after sign up
                        showingSignUp = false
                    },
                    onLogin: {
                        // Return to Login when tapped
                        showingSignUp = false
                    }
                )
            } else {
                LoginView(
                    onLogin: {
                        onAuthenticated()
                    },
                    onSignUp: {
                        // Navigate to Sign Up
                        showingSignUp = true
                    }
                )
            }
        }
    }
}

#Preview {
    AuthContainerView(onAuthenticated: {})
}
