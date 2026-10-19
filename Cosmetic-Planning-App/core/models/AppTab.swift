//
//  AppTab.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/19/26.
//

import Foundation
import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case discover = "Discover"
    case routines = "Routines"
    case calendar = "Calendar"
    case profile = "Profile"

    var symbol: String {
        switch self {
        case .home: "house"
        case .discover: "magnifyingglass"
        case .routines: "sparkles"
        case .calendar: "calendar"
        case .profile: "person"
        }
    }
}
