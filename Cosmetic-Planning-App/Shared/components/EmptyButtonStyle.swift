//
//  EmptyButtonStyle.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//

import Foundation
import SwiftUI

struct EmptyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.72: 1)
    }
}
