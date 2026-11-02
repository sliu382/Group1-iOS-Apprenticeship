//
//  MainTabView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI

struct MainTabView: View {
    //@State private var isLoggedIn = false //SET THIS TO FALSE LATER
    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppTab = .home
    private let authService = AuthService()
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem{ Label("Home", systemImage: AppTab.home.symbol)}
            DiscoverView()
                .tag(AppTab.home)
                .tabItem{ Label("Discover", systemImage: AppTab.discover.symbol)}
            RoutinesView()
                .tag(AppTab.home)
                .tabItem{ Label("Routines", systemImage: AppTab.routines.symbol)}
            CalendarView()
                .tag(AppTab.home)
                .tabItem{ Label("Calendar", systemImage: AppTab.calendar.symbol)}
            ProfileView(
                onLogout: {
                    Task{
                        await logout()
                    }
                }
            )
            .tag(AppTab.profile)
            .tabItem{ Label("Profile", systemImage: AppTab.profile.symbol)}
        }
    }
    private func logout() async {
        do {
            try await authService.signOut()
            appState.isLoggedIn = false
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
