//
//  DiscoverView.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import SwiftUI

struct DiscoverView: View {
    @State private var query: String = ""
    @State private var showsFilters = false
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ScreenHeader(title: "Discover", showsAdd: true)
                
                HStack(spacing:10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColor.muted)
                    TextField("Search routines or creators...", text: $query)
                        .font(.appSans(12))
                    Divider()
                        .frame(height:22)
                    
                    // FILTER BUTTON TO TOGGLE ON/OFF
                    // Button {} label: {}
    
                    
                }
                .padding(.horizontal,13)
                .frame(height:48)
                .modifier(RectangularCard(radius:15,color:.white))
            }
            .padding(.horizontal,20)
            .padding(.bottom, 28)
            
        }
        .background(AppColor.cream)
    }
}

#Preview {
    DiscoverView()
}
