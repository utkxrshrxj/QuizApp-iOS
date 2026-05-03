import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    // Gradient animation
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing
    
    var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 30) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 90))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .shadow(color: .white.opacity(0.5), radius: 15, x: 0, y: 0)
                    
                    Text("Quiz Master")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Select a category. Questions are fetched live!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    ScrollView {
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
                                        Image(systemName: "play.circle.fill")
                                            .font(.title3)
                                    }
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    HapticManager.shared.impact(style: .light)
                                })
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
