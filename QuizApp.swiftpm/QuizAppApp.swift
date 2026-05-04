import SwiftUI

@main
struct QuizAppApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(themeManager)
        }
    }
}
