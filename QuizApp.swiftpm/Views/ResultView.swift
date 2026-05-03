import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    var onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 5)
            
            Text("Quiz Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("Your Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(viewModel.score)")
                        .font(.system(size: 60, weight: .black))
                        .foregroundColor(.blue)
                    
                    Text("/ \(viewModel.currentCategory?.questions.count ?? 0)")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onRestart) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Choose Another Category")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}
