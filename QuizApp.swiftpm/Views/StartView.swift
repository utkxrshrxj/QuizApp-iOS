import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 50)
                    
                    Text("Quiz Master")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose a category to start the challenge.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        ForEach(QuizCategory.sampleCategories) { category in
                            NavigationLink(destination: QuizView(viewModel: viewModel)
                                .onAppear {
                                    viewModel.startQuiz(category: category)
                                }
                            ) {
                                HStack {
                                    Text(category.name)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
    }
}
