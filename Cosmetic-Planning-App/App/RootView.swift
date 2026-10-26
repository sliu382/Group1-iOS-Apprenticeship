//
//  RootView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//


import SwiftUI

struct RootView: View {
    @State private var appState = AppState()
    
    private let authService = AuthService()

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
            } else {
                LoginView(onLogin: {
                    appState.isLoggedIn = true
                })
                    .transition(.opacity)
            }
        }
        .environment(appState)
        .task {
            appState.isLoggedIn = await authService.hasValidSession()
            appState.isLoading = false
        }
    }
}
