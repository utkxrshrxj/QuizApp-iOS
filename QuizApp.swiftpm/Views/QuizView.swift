import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    @State private var flipDegrees: Double = 0.0
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            if viewModel.isLoading {
                loadingView
            } else if viewModel.isQuizComplete {
                ResultView(viewModel: viewModel, onRestart: { 
                    SoundManager.shared.stopBackgroundMusic()
                    dismiss() 
                })
            } else if let _ = viewModel.currentQuestion {
                mainGameplayContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { 
                    SoundManager.shared.stopBackgroundMusic()
                    dismiss() 
                }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.white).font(.title2)
                }
            }
        }
        .onChange(of: viewModel.timeRemaining) { newValue in
            if newValue == 5 {
                SoundManager.shared.setIntensity("intense")
            }
        }
    }
    
    // MARK: - Components
    
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
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.5).tint(.white)
            Text("Fetching \(viewModel.selectedDifficulty) Questions...")
                .font(.headline).foregroundColor(.white)
        }
    }
    
    private var mainGameplayContent: some View {
        VStack(spacing: 25) {
            headerSection
            
            if !viewModel.isAnswerChecked {
                LifelineView(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            questionCard
            
            Spacer()
            
            if viewModel.isAnswerChecked {
                nextButton
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.progressText).font(.subheadline).foregroundColor(.white.opacity(0.8))
                ProgressBar(progress: viewModel.progressFraction, color: themeManager.currentTheme.accent)
                if viewModel.streak >= 3 {
                    Text("🔥 Streak: \(viewModel.streak)").font(.caption).fontWeight(.bold).foregroundColor(.orange)
                }
            }
            Spacer()
            timerCircle
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var timerCircle: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining) / 10.0)
                .stroke(viewModel.timeRemaining > 3 ? Color.green : Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
            Text("\(viewModel.timeRemaining)").font(.headline).foregroundColor(.white)
        }
        .frame(width: 55, height: 55)
    }
    
    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let question = viewModel.currentQuestion {
                Text(question.text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Adjust layout for True/False (2 buttons) vs Multiple Choice (4 buttons)
                let columns = question.options.count == 2 ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        OptionButton(
                            text: question.options[index],
                            isSelected: viewModel.selectedOptionIndex == index,
                            isCorrect: question.correctAnswerIndex == index,
                            isAnswerChecked: viewModel.isAnswerChecked,
                            isHidden: viewModel.hiddenOptionIndices.contains(index),
                            accentColor: themeManager.currentTheme.accent
                        ) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                viewModel.selectOption(index: index)
                                flipDegrees += 360
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.3), lineWidth: 1))
        .padding(.horizontal)
        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
    }
    
    private var nextButton: some View {
        Button(action: {
            HapticManager.shared.impact(style: .light)
            withAnimation { 
                viewModel.nextQuestion() 
                SoundManager.shared.setIntensity("normal") // Reset intensity for next question
            }
        }) {
            Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finish Quiz" : "Next Question")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.accent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

struct LifelineView: View {
    @ObservedObject var viewModel: QuizViewModel
    var body: some View {
        HStack(spacing: 20) {
            LifelineButton(icon: "scissors", label: "50/50", isUsed: viewModel.used5050) { withAnimation { viewModel.apply5050() } }
            LifelineButton(icon: "goforward.15", label: "+15s", isUsed: viewModel.usedTimeExtension) { withAnimation { viewModel.extendTime() } }
            LifelineButton(icon: "arrow.right.circle", label: "Skip", isUsed: viewModel.usedSkip) { withAnimation { viewModel.skipQuestion() } }
        }
        .padding(.horizontal)
    }
}

struct LifelineButton: View {
    let icon: String; let label: String; let isUsed: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title3)
                Text(label).font(.caption).fontWeight(.bold)
            }
            .foregroundColor(isUsed ? .white.opacity(0.4) : .white)
            .frame(maxWidth: .infinity).padding(.vertical, 12).background(isUsed ? Color.white.opacity(0.1) : Color.white.opacity(0.2)).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isUsed ? Color.clear : Color.white.opacity(0.3), lineWidth: 1))
        }
        .disabled(isUsed)
    }
}
