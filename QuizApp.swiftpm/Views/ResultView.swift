import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    var onRestart: () -> Void
    
    @State private var showReview = false
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            if viewModel.score >= viewModel.questions.count {
                ConfettiView()
            }
            
            VStack(spacing: 25) {
                Spacer()
                reactionSection
                scoreCardSection
                Spacer()
                restartButtonSection
            }
        }
        .sheet(isPresented: $showReview) {
            ReviewMistakesView(viewModel: viewModel)
        }
    }
    
    // MARK: - Components
    
    private var backgroundLayer: some View {
        LinearGradient(
            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var reactionSection: some View {
        let reaction = currentReaction
        return VStack(spacing: 12) {
            Text(reaction.emoji).font(.system(size: 90)).shadow(radius: 10)
            Text(reaction.title).font(.largeTitle).fontWeight(.black).foregroundColor(.white)
            Text(reaction.message).font(.subheadline).foregroundColor(.white.opacity(0.8)).multilineTextAlignment(.center)
        }
    }
    
    private var scoreCardSection: some View {
        VStack(spacing: 20) {
            scoreDisplay
            
            if viewModel.highestStreak > 0 {
                Text("🔥 Best Streak: \(viewModel.highestStreak)").font(.headline).foregroundColor(.orange)
            }
            
            actionButtonsRow
        }
        .padding(30)
        .background(.ultraThinMaterial).cornerRadius(30)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.4), lineWidth: 1))
        .padding(.horizontal, 30)
    }
    
    private var scoreDisplay: some View {
        VStack(spacing: 4) {
            Text("YOUR SCORE").font(.caption).fontWeight(.bold).foregroundColor(.white.opacity(0.6))
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(viewModel.score)").font(.system(size: 80, weight: .black)).foregroundColor(.white)
                Text("/ \(viewModel.questions.count * 2)").font(.title).foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private var actionButtonsRow: some View {
        HStack(spacing: 20) {
            // Review Button
            Button(action: { showReview = true }) {
                buttonLabel(icon: "list.bullet.rectangle.portrait", label: "Review")
            }
            
            // Share Button
            ShareLink(item: "🚀 I scored \(viewModel.score) in Quiz Master! Best streak: \(viewModel.highestStreak) 🔥") {
                buttonLabel(icon: "square.and.arrow.up", label: "Share")
            }
        }
    }
    
    private func buttonLabel(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title2)
            Text(label).font(.caption2).fontWeight(.bold)
        }
        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Color.white.opacity(0.15)).cornerRadius(16)
    }
    
    private var restartButtonSection: some View {
        Button(action: {
            HapticManager.shared.impact(style: .medium)
            onRestart()
        }) {
            Text("PLAY AGAIN")
                .font(.headline).fontWeight(.bold).foregroundColor(.blue).frame(maxWidth: .infinity).padding()
                .background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.15), radius: 10)
        }
        .padding(.horizontal, 40).padding(.bottom, 40)
    }
    
    // MARK: - Logic Helpers
    
    private var currentReaction: (emoji: String, title: String, message: String) {
        let maxScore = viewModel.questions.count * 2
        if viewModel.score >= maxScore { return ("🏆", "PERFECT!", "You are a true Quiz Master!") }
        else if viewModel.score > 10 { return ("😊", "GREAT JOB!", "That's an impressive score!") }
        else if viewModel.score > 0 { return ("😐", "GOOD TRY", "Not bad, but you can do better!") }
        else { return ("😢", "OH NO!", "Don't give up, try again!") }
    }
}
