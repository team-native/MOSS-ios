import SwiftUI

@main
struct MoSSApp: App {
    init() {
        FontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
