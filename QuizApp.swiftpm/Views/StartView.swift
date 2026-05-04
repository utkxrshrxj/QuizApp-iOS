import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = QuizViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showThemeStore = false
    
    // Gradient animation state
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 25) {
                    headerSection
                    difficultySelector
                    dailyChallengeCard
                    categoriesSection
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showThemeStore) {
            ThemeStoreView(themeManager: themeManager)
        }
    }
    
    // MARK: - Sub-Views
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: themeManager.currentTheme.gradientColors,
            startPoint: gradientStart,
            endPoint: gradientEnd
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                gradientStart = .topTrailing
                gradientEnd = .bottomLeading
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Spacer()
            VStack(spacing: 5) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: themeManager.currentTheme.accent.opacity(0.5), radius: 15)
                
                Text("Quiz Master")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            
            // Theme Store Button
            Button(action: { showThemeStore = true }) {
                Image(systemName: "paintpalette.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
            .padding(.top, -40)
        }
        .padding(.top, 40)
    }
    
    private var difficultySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT DIFFICULTY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 24)
            
            HStack(spacing: 12) {
                ForEach(["Easy", "Medium", "Hard"], id: \.self) { diff in
                    Button(action: {
                        viewModel.selectedDifficulty = diff
                        HapticManager.shared.impact(style: .light)
                    }) {
                        Text(diff)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedDifficulty == diff ? themeManager.currentTheme.accent : Color.white.opacity(0.1))
                            .foregroundColor(viewModel.selectedDifficulty == diff ? .black : .white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DAILY CHALLENGE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 24)
            
            NavigationLink(destination: QuizView(viewModel: viewModel).onAppear { 
                viewModel.startDailyChallenge()
                SoundManager.shared.startBackgroundMusic()
            }) {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                        Image(systemName: "star.fill").foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Special").font(.headline).foregroundColor(.white)
                        Text("Test your skills with the daily rotation.").font(.caption).foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.5))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.currentTheme.accent.opacity(0.4), lineWidth: 2))
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORIES")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 24)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(QuizCategory.sampleCategories) { category in
                        categoryButton(for: category)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func categoryButton(for category: QuizCategory) -> some View {
        NavigationLink(destination: QuizView(viewModel: viewModel).onAppear { 
            viewModel.startQuiz(category: category)
            SoundManager.shared.startBackgroundMusic()
        }) {
            HStack {
                Text(category.name).font(.headline).foregroundColor(.white)
                Spacer()
                Image(systemName: "play.circle.fill").font(.title2).foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}
