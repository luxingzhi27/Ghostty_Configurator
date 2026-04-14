import SwiftUI

@main
struct GhosttyConfiguratorApp: App {
    @StateObject private var lang = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lang)
                .edgesIgnoringSafeArea(.top)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
    }
}
