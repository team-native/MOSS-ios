import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            Color.mossBackground
                .ignoresSafeArea()

            MoSSLogo()
        }
    }
}

#Preview {
    RootView()
}
