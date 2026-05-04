import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: Theme {
        didSet {
            saveTheme()
        }
    }
    
    private let themeKey = "selected_theme_id"
    
    init() {
        // Load saved theme or default to neon night
        let savedId = UserDefaults.standard.string(forKey: themeKey)
        self.currentTheme = Theme.allThemes.first { $0.id == savedId } ?? Theme.neonNight
    }
    
    func applyTheme(_ theme: Theme) {
        withAnimation {
            self.currentTheme = theme
        }
        HapticManager.shared.impact(style: .medium)
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.id, forKey: themeKey)
    }
}
