import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    var onRestart: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti if score is good (e.g. > 50% of max possible score)
            if viewModel.score >= viewModel.questions.count {
                ConfettiView()
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text(scoreReaction.emoji)
                        .font(.system(size: 100))
                        .shadow(radius: 10)
                    
                    Text(scoreReaction.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(scoreReaction.message)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    Text("Your Score")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(viewModel.score)")
                            .font(.system(size: 70, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("/ \(viewModel.questions.count * 2)")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    if viewModel.highestStreak > 0 {
                        Text("🔥 Best Streak: \(viewModel.highestStreak)")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.top, 10)
                    }
                }
                .padding(40)
                .background(.ultraThinMaterial)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.impact(style: .light)
                    onRestart()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Choose Another Category")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Reaction Logic
    
    private var scoreReaction: ScoreReaction {
        let maxScore = viewModel.questions.count * 2
        
        if viewModel.score >= maxScore {
            return ScoreReaction(emoji: "🏆", title: "Perfect!", message: "You are a true Quiz Master!")
        } else if viewModel.score > 10 {
            return ScoreReaction(emoji: "😊", title: "Great Job!", message: "That's an impressive score!")
        } else if viewModel.score > 5 {
            return ScoreReaction(emoji: "😐", title: "Okayish", message: "Not bad, but you can do better!")
        } else if viewModel.score == 0 {
            return ScoreReaction(emoji: "😢", title: "So Sad", message: "Better luck next time...")
        } else if viewModel.score < 0 {
            return ScoreReaction(emoji: "💀", title: "Disaster!", message: "Ouch! Negative points?!")
        } else {
            return ScoreReaction(emoji: "📝", title: "Keep Practicing", message: "You're getting there!")
        }
    }
}

struct ScoreReaction {
    let emoji: String
    let title: String
    let message: String
}
