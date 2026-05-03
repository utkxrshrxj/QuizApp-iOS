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
            
            // Confetti if score is good (e.g. > 50%)
            if viewModel.score >= (viewModel.questions.count / 2) {
                ConfettiView()
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.8), radius: 20, x: 0, y: 5)
                
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Text("Your Score")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(viewModel.score)")
                            .font(.system(size: 70, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("/ \(viewModel.questions.count)")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    if viewModel.streak > 0 {
                        Text("🔥 Final Streak: \(viewModel.streak)")
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
}
