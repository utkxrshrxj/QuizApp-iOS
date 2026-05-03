import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isQuizComplete {
                ResultView(viewModel: viewModel, onRestart: {
                    dismiss()
                })
            } else if let question = viewModel.currentQuestion {
                VStack(spacing: 20) {
                    // Header: Progress & Timer
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.progressText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ProgressBar(progress: viewModel.progressFraction)
                        }
                        
                        Spacer()
                        
                        // Timer
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(viewModel.timeRemaining) / 15.0)
                                .stroke(timerColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1.0), value: viewModel.timeRemaining)
                            
                            Text("\(viewModel.timeRemaining)")
                                .font(.headline)
                                .foregroundColor(timerColor)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Question Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text(question.text)
                            .font(.title2)
                            .fontWeight(.bold)
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
                                    withAnimation(.spring()) {
                                        viewModel.selectOption(index: index)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Next / Submit Button
                    if viewModel.isAnswerChecked {
                        Button(action: {
                            withAnimation {
                                viewModel.nextQuestion()
                            }
                        }) {
                            Text(viewModel.currentQuestionIndex == (viewModel.currentCategory?.questions.count ?? 1) - 1 ? "Finish Quiz" : "Next Question")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
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
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
        }
    }
    
    private var timerColor: Color {
        if viewModel.timeRemaining > 5 {
            return .blue
        } else {
            return .red
        }
    }
}
