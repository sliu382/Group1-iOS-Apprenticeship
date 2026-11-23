//
//  MainTabView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: AppTab = .home
    private let authService = AuthService()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(AppTab.home)
                .tabItem{
                    Label("Home", systemImage: AppTab.home.symbol)}
                .foregroundStyle(RoutineTheme.ink)
            DiscoverView()
                .tag(AppTab.discover)
                .tabItem{ Label("Discover", systemImage: AppTab.discover.symbol)}
                .foregroundStyle(RoutineTheme.ink)
            RoutinesView()
                .tag(AppTab.routines)
                .tabItem{
                    Label {
                        Text("Routines")
                    } icon: {
                        Image(systemName: AppTab.routines.symbol)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black)
                    }
                }
            CalendarView()
                .tag(AppTab.calendar)
                .tabItem{ Label("Calendar", systemImage: AppTab.calendar.symbol)}
                .foregroundStyle(RoutineTheme.ink)
            ProfileView(
                onLogout: {
                    Task{
                        await logout()
                    }
                }
            )
            .tag(AppTab.profile)
            .tabItem{ Label("Profile", systemImage: AppTab.profile.symbol)}
            .foregroundStyle(RoutineTheme.ink)
        }
        .tint(RoutineTheme.rose)
        .toolbarBackground(RoutineTheme.cream, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
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
