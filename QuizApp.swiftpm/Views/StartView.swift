import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    // Gradient animation state
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 30) {
                    headerSection
                    dailyChallengeCard
                    categoriesSection
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Sub-Views
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8), Color.indigo.opacity(0.8)],
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
        VStack(spacing: 15) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 90))
                .foregroundColor(.white)
                .padding(.top, 40)
                .shadow(color: .white.opacity(0.5), radius: 15)
            
            Text("Quiz Master")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DAILY CHALLENGE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 24)
            
            NavigationLink(destination: QuizView(viewModel: viewModel).onAppear { viewModel.startDailyChallenge() }) {
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 55, height: 55)
                        Image(systemName: "star.fill").foregroundColor(.white).font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Special").font(.headline).foregroundColor(.white)
                        Text("Unique questions every 24h!").font(.caption).foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.5))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.yellow.opacity(0.6), lineWidth: 2))
                .shadow(color: Color.yellow.opacity(0.2), radius: 15)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORIES")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
                .padding(.leading, 24)
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(QuizCategory.sampleCategories) { category in
                        categoryButton(for: category)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func categoryButton(for category: QuizCategory) -> some View {
        NavigationLink(destination: QuizView(viewModel: viewModel).onAppear { viewModel.startQuiz(category: category) }) {
            HStack {
                Text(category.name).font(.headline).foregroundColor(.white)
                Spacer()
                Image(systemName: "play.circle.fill").font(.title2).foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }
}
