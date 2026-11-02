//
//  AppState.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/12/26.
//

import SwiftUI
import Observation

@Observable
final class AppState {
    var isLoggedIn = false
    var isLoading = true
}
