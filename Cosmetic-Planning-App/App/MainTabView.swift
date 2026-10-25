//
//  MainTabView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var isLoggedIn = false //SET THIS TO FALSE LATER
    @State private var selectedTab: AppTab = .home
    var body: some View {
        Group {
            if isLoggedIn {
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
                    ProfileView(onLogout: {isLoggedIn = false})
                        .tag(AppTab.home)
                        .tabItem{ Label("Profile", systemImage: AppTab.profile.symbol)}
                }
            } else {
                LoginView(onLogin: {isLoggedIn = true})
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    MainTabView()
}
