import SwiftUI

struct RootView: View {
    @StateObject private var session = SessionManager()

    var body: some View {
        Group {
            switch session.state {
            case .loggedOut:
                LoginView()
            case .guest, .loggedIn:
                HomeView()
            }
        }
        .environmentObject(session)
        .animation(.default, value: session.state)
    }
}

#Preview {
    RootView()
}
