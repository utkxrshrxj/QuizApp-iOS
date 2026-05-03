import SwiftUI
import Combine

@MainActor
class QuizViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentCategory: QuizCategory?
    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    
    @Published var selectedOptionIndex: Int? = nil
    @Published var isAnswerChecked: Bool = false
    
    @Published var timeRemaining: Int = 15
    @Published var isQuizComplete: Bool = false
    
    // MARK: - Private Properties
    
    private var timerSubscription: AnyCancellable?
    private let timeLimit = 15
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progressText: String {
        guard !questions.isEmpty else { return "" }
        return "Question \(currentQuestionIndex + 1) of \(questions.count)"
    }
    
    var progressFraction: Double {
        guard !questions.isEmpty else { return 0.0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    // MARK: - Intents
    
    func startQuiz(category: QuizCategory) {
        self.currentCategory = category
        self.currentQuestionIndex = 0
        self.score = 0
        self.streak = 0
        self.isQuizComplete = false
        self.questions = []
        
        Task {
            isLoading = true
            do {
                let fetchedQuestions = try await TriviaService.shared.fetchQuestions(categoryId: category.apiId)
                self.questions = fetchedQuestions
                self.isLoading = false
                self.resetQuestionState()
            } catch {
                print("Error fetching questions: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func selectOption(index: Int) {
        guard !isAnswerChecked else { return }
        HapticManager.shared.impact(style: .medium)
        selectedOptionIndex = index
        checkAnswer()
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
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
            streak += 1
            
            // Streak gamification bonus (e.g., +1 extra point per 3 streaks)
            if streak >= 3 && streak % 3 == 0 {
                score += 1
            }
            
            HapticManager.shared.notification(type: .success)
            SoundManager.shared.playCorrectSound()
        } else {
            streak = 0
            HapticManager.shared.notification(type: .error)
            SoundManager.shared.playIncorrectSound()
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
        if score >= (questions.count / 2) {
            HapticManager.shared.notification(type: .success)
        }
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
                    // Time is up
                    self.stopTimer()
                    self.isAnswerChecked = true
                    self.streak = 0
                    HapticManager.shared.notification(type: .error)
                    SoundManager.shared.playIncorrectSound()
                }
            }
    }
    
    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
}
