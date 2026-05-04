import SwiftUI

struct ThemeStoreView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F172A").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        Text("Personalize your experience with premium themes.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.top)
                        
                        ForEach(Theme.allThemes) { theme in
                            ThemeCard(theme: theme, isSelected: theme.id == themeManager.currentTheme.id) {
                                themeManager.applyTheme(theme)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Theme Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.blue)
                }
            }
        }
    }
}

struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(theme.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    if theme.isPremium {
                        Text("PREMIUM")
                            .font(.caption2)
                            .fontWeight(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                
                HStack(spacing: 10) {
                    Circle().fill(Color(hex: theme.primaryColor)).frame(width: 30, height: 30)
                    Circle().fill(Color(hex: theme.secondaryColor)).frame(width: 30, height: 30)
                    Circle().fill(Color(hex: theme.accentColor)).frame(width: 30, height: 30)
                    Spacer()
                }
            }
            .padding(20)
            .foregroundColor(.white)
            .background(
                LinearGradient(colors: [Color(hex: theme.primaryColor), Color(hex: theme.secondaryColor)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
            .shadow(color: Color(hex: theme.primaryColor).opacity(0.3), radius: 10, y: 5)
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}
