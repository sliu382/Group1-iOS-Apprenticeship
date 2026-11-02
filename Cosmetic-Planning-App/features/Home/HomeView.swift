//
//  HomeView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

struct HomeView: View {
    @State private var profileViewModel = ProfileViewModel()
    
    // "Good Morning, Aarna!" — falls back to no name if the profile hasn't loaded or has no first name
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay = hour < 12 ? "Morning" : (hour < 17 ? "Afternoon" : "Evening")
        if let name = profileViewModel.profile?.firstName, !name.isEmpty {
            return "Good \(timeOfDay), \(name)!"
        }
        return "Good \(timeOfDay)!"
    }
    
    var body: some View {
        ScrollView {
            VStack (spacing: 12){
                ScreenHeader(title: greeting)
                
                SectionHeader(title:"Today's Routines", action: "Manage") {} //ADD ROUTING LATER
                
                VStack(spacing:9){
                    // MAKE A ROUTINE CARD
                }
                
                SectionHeader(title: "Today's Appointments", action: "Calendar") {}
                // MAKE AN APPOINTMENT CARD
                
                SectionHeader(title: "Coming up", action: "Calendar") {}

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)

        }
        .background(AppColor.cream)
        // Reload each time the Home tab appears so name edits on Profile show up here
        .onAppear {
            Task { await profileViewModel.loadProfile() }
        }
    }
}

#Preview {
    HomeView()
}
