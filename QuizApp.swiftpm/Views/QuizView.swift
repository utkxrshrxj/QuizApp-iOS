import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    // Animation state for the 3D flip
    @State private var flipDegrees: Double = 0.0
    @State private var isPulsing: Bool = false
    
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
                    
                    // Lifelines
                    if !viewModel.isAnswerChecked {
                        LifelineView(viewModel: viewModel)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
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
                                    isAnswerChecked: viewModel.isAnswerChecked,
                                    isHidden: viewModel.hiddenOptionIndices.contains(index)
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
            
            // Floating Streak Overlay
            if viewModel.streak >= 3 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: -10) {
                            Text("🔥")
                                .font(.system(size: 80))
                            Text("\(viewModel.streak)")
                                .font(.system(size: 40, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            Text("STREAK")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.orange.opacity(0.6), lineWidth: 4))
                        .shadow(color: .orange.opacity(0.5), radius: 20)
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                isPulsing = true
                            }
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 100)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
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

struct LifelineView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            LifelineButton(
                icon: "scissors", 
                label: "50/50", 
                isUsed: viewModel.used5050
            ) {
                withAnimation {
                    viewModel.apply5050()
                }
            }
            
            LifelineButton(
                icon: "goforward.15", 
                label: "+15s", 
                isUsed: viewModel.usedTimeExtension
            ) {
                withAnimation {
                    viewModel.extendTime()
                }
            }
            
            LifelineButton(
                icon: "arrow.right.circle", 
                label: "Skip", 
                isUsed: viewModel.usedSkip
            ) {
                withAnimation {
                    viewModel.skipQuestion()
                }
            }
        }
        .padding(.horizontal)
    }
}

struct LifelineButton: View {
    let icon: String
    let label: String
    let isUsed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundColor(isUsed ? .white.opacity(0.4) : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isUsed ? Color.white.opacity(0.1) : Color.white.opacity(0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isUsed ? Color.clear : Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(isUsed)
    }
}
