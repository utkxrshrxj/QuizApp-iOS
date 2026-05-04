import SwiftUI

struct Theme: Identifiable, Codable {
    let id: String
    let name: String
    let primaryColor: String // Hex
    let secondaryColor: String // Hex
    let accentColor: String // Hex
    let isPremium: Bool
    
    var gradientColors: [Color] {
        [Color(hex: primaryColor), Color(hex: secondaryColor)]
    }
    
    var accent: Color {
        Color(hex: accentColor)
    }
    
    static let neonNight = Theme(
        id: "neon_night",
        name: "Neon Night",
        primaryColor: "1E293B", // Dark Blue
        secondaryColor: "4C1D95", // Deep Purple
        accentColor: "06B6D4", // Cyan
        isPremium: false
    )
    
    static let midnightForest = Theme(
        id: "midnight_forest",
        name: "Midnight Forest",
        primaryColor: "064E3B", // Dark Green
        secondaryColor: "065F46", // Emerald
        accentColor: "10B981", // Green
        isPremium: true
    )
    
    static let sunsetEmpire = Theme(
        id: "sunset_empire",
        name: "Sunset Empire",
        primaryColor: "7C2D12", // Dark Orange
        secondaryColor: "991B1B", // Dark Red
        accentColor: "F59E0B", // Amber
        isPremium: true
    )
    
    static let allThemes: [Theme] = [.neonNight, .midnightForest, .sunsetEmpire]
}
