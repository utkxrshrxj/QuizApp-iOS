import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    // Animation state for the 3D flip
    @State private var flipDegrees: Double = 0.0
    
    // Gradient animation
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing
    
    var body: some View {
        ZStack {
            // Animated Gradient Background
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
            
            if viewModel.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Fetching Questions...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            } else if viewModel.isQuizComplete {
                ResultView(viewModel: viewModel, onRestart: {
                    dismiss()
                })
            } else if let question = viewModel.currentQuestion {
                VStack(spacing: 20) {
                    // Header: Progress & Timer & Streak
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.progressText)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            ProgressBar(progress: viewModel.progressFraction)
                            
                            if viewModel.streak >= 3 {
                                Text("🔥 Streak: \(viewModel.streak)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Spacer()
                        
                        // Timer
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining) / 15.0)
                                .stroke(timerColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
                            
                            Text("\(viewModel.timeRemaining)")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(width: 50, height: 50)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Question Card (3D Flippable)
                    VStack(alignment: .leading, spacing: 20) {
                        Text(question.text)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<question.options.count, id: \.self) { index in
                                OptionButton(
                                    text: question.options[index],
                                    isSelected: viewModel.selectedOptionIndex == index,
                                    isCorrect: question.correctAnswerIndex == index,
                                    isAnswerChecked: viewModel.isAnswerChecked
                                ) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                                        viewModel.selectOption(index: index)
                                        flipDegrees += 360 // Trigger 3D flip
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial) // Glassmorphism
                    .cornerRadius(24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .padding(.horizontal)
                    .rotation3DEffect(
                        .degrees(flipDegrees),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
                    
                    Spacer()
                    
                    // Next / Submit Button
                    if viewModel.isAnswerChecked {
                        Button(action: {
                            HapticManager.shared.impact(style: .light)
                            withAnimation {
                                viewModel.nextQuestion()
                            }
                        }) {
                            Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finish Quiz" : "Next Question")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
        }
    }
    
    private var timerColor: Color {
        if viewModel.timeRemaining > 5 {
            return .green
        } else {
            return .red
        }
    }
}
