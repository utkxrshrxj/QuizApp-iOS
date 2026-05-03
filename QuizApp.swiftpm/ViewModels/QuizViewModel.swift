import SwiftUI
import Combine

class QuizViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentCategory: QuizCategory?
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    
    @Published var selectedOptionIndex: Int? = nil
    @Published var isAnswerChecked: Bool = false
    
    @Published var timeRemaining: Int = 15
    @Published var isQuizComplete: Bool = false
    
    // MARK: - Private Properties
    
    private var timerSubscription: AnyCancellable?
    private let timeLimit = 15
    
    var currentQuestion: Question? {
        guard let category = currentCategory, currentQuestionIndex < category.questions.count else { return nil }
        return category.questions[currentQuestionIndex]
    }
    
    var progressText: String {
        guard let category = currentCategory else { return "" }
        return "Question \(currentQuestionIndex + 1) of \(category.questions.count)"
    }
    
    var progressFraction: Double {
        guard let category = currentCategory, !category.questions.isEmpty else { return 0.0 }
        return Double(currentQuestionIndex + 1) / Double(category.questions.count)
    }
    
    // MARK: - Intents
    
    func startQuiz(category: QuizCategory) {
        self.currentCategory = category
        self.currentQuestionIndex = 0
        self.score = 0
        self.isQuizComplete = false
        resetQuestionState()
    }
    
    func selectOption(index: Int) {
        guard !isAnswerChecked else { return }
        selectedOptionIndex = index
        checkAnswer()
    }
    
    func nextQuestion() {
        guard let category = currentCategory else { return }
        
        if currentQuestionIndex < category.questions.count - 1 {
            currentQuestionIndex += 1
            resetQuestionState()
        } else {
            endQuiz()
        }
    }
    
    func restartQuiz() {
        guard let category = currentCategory else { return }
        startQuiz(category: category)
    }
    
    // MARK: - Private Methods
    
    private func checkAnswer() {
        isAnswerChecked = true
        stopTimer()
        
        if let selected = selectedOptionIndex, selected == currentQuestion?.correctAnswerIndex {
            score += 1
            // Optional: Play correct sound
        } else {
            // Optional: Play incorrect sound
        }
    }
    
    private func resetQuestionState() {
        selectedOptionIndex = nil
        isAnswerChecked = false
        timeRemaining = timeLimit
        startTimer()
    }
    
    private func endQuiz() {
        stopTimer()
        isQuizComplete = true
    }
    
    // MARK: - Timer Logic
    
    private func startTimer() {
        timerSubscription?.cancel()
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    // Time is up, mark as incorrect
                    self.stopTimer()
                    self.isAnswerChecked = true
                }
            }
    }
    
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
}
