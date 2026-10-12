import SwiftUI

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            if appState.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environment(appState)
    }
}