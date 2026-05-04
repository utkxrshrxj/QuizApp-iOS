import SwiftUI

struct ReviewMistakesView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0F172A").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.attemptedQuestions) { attempt in
                            AttemptReviewCard(attempt: attempt)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Mistake Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.blue)
                }
            }
        }
    }
}

struct AttemptReviewCard: View {
    let attempt: QuizViewModel.AttemptedQuestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(attempt.question.text)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(0..<attempt.question.options.count, id: \.self) { index in
                    optionRow(index: index)
                }
            }
            
            if attempt.selectedIndex == nil {
                Text("⏰ Time Out")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
    
    private func optionRow(index: Int) -> some View {
        let isCorrect = index == attempt.question.correctAnswerIndex
        let isUserChoice = index == attempt.selectedIndex
        
        return HStack {
            Text(attempt.question.options[index])
                .font(.subheadline)
            Spacer()
            if isCorrect {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            } else if isUserChoice {
                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCorrect ? Color.green.opacity(0.2) : (isUserChoice ? Color.red.opacity(0.2) : Color.white.opacity(0.05)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCorrect ? Color.green.opacity(0.5) : (isUserChoice ? Color.red.opacity(0.5) : Color.clear), lineWidth: 1)
        )
    }
}
