//
//  HomeView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/18/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack (spacing: 12){
                ScreenHeader(title: "Good Morning, <FirstName>!")
                
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
    }
}

#Preview {
    HomeView()
}
