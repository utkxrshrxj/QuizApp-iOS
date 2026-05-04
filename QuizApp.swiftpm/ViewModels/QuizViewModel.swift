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
    @Published var highestStreak: Int = 0
    
    @Published var selectedOptionIndex: Int? = nil
    @Published var isAnswerChecked: Bool = false
    
    @Published var timeRemaining: Int = 10
    @Published var isQuizComplete: Bool = false
    @Published var isDailyChallenge: Bool = false
    @Published var selectedDifficulty: String = "Medium"
    @Published var questionType: String? = nil // nil = Mixed
    
    // Review Logic
    struct AttemptedQuestion: Identifiable {
        let id = UUID()
        let question: Question
        let selectedIndex: Int? // nil if timeout
    }
    @Published var attemptedQuestions: [AttemptedQuestion] = []
    
    // Lifelines
    @Published var used5050: Bool = false
    @Published var usedSkip: Bool = false
    @Published var usedTimeExtension: Bool = false
    @Published var hiddenOptionIndices: Set<Int> = []
    
    // MARK: - Private Properties
    
    private var timerSubscription: AnyCancellable?
    private let timeLimit = 10
    
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
    
    func startQuiz(category: QuizCategory, isDaily: Bool = false) {
        self.currentCategory = category
        self.currentQuestionIndex = 0
        self.score = 0
        self.streak = 0
        self.highestStreak = 0
        self.isQuizComplete = false
        self.isDailyChallenge = isDaily
        self.questions = []
        self.attemptedQuestions = []
        self.used5050 = false
        self.usedSkip = false
        self.usedTimeExtension = false
        self.hiddenOptionIndices = []
        
        Task {
            isLoading = true
            do {
                let fetchedQuestions = try await TriviaService.shared.fetchQuestions(
                    categoryId: category.apiId,
                    difficulty: selectedDifficulty,
                    type: questionType
                )
                self.questions = fetchedQuestions
                self.isLoading = false
                self.resetQuestionState()
            } catch {
                print("Error fetching questions: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func startDailyChallenge() {
        // Daily challenge uses a rotating category based on the day of the year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let categories = QuizCategory.sampleCategories
        let category = categories[dayOfYear % categories.count]
        startQuiz(category: category, isDaily: true)
    }
    
    // MARK: - Lifeline Intents
    
    func apply5050() {
        guard !used5050, !isAnswerChecked, let question = currentQuestion else { return }
        
        var incorrectIndices = Array(0..<question.options.count).filter { $0 != question.correctAnswerIndex }
        incorrectIndices.shuffle()
        
        // Hide two incorrect options
        hiddenOptionIndices = Set(incorrectIndices.prefix(2))
        used5050 = true
        HapticManager.shared.impact(style: .heavy)
    }
    
    func skipQuestion() {
        guard !usedSkip, !isAnswerChecked else { return }
        usedSkip = true
        HapticManager.shared.impact(style: .medium)
        nextQuestion()
    }
    
    func extendTime() {
        guard !usedTimeExtension, !isAnswerChecked else { return }
        timeRemaining += 10
        usedTimeExtension = true
        HapticManager.shared.impact(style: .light)
    }
    
    func selectOption(index: Int) {
        guard !isAnswerChecked, !hiddenOptionIndices.contains(index) else { return }
        HapticManager.shared.impact(style: .medium)
        selectedOptionIndex = index
        checkAnswer()
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            hiddenOptionIndices = [] // Reset hidden options for next question
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
        
        if let question = currentQuestion {
            attemptedQuestions.append(AttemptedQuestion(question: question, selectedIndex: selectedOptionIndex))
        }
        
        if let selected = selectedOptionIndex, selected == currentQuestion?.correctAnswerIndex {
            score += 2
            streak += 1
            
            // Update highest streak
            if streak > highestStreak {
                highestStreak = streak
            }
            
            // Streak gamification bonus (e.g., +1 extra point per 3 streaks)
            if streak >= 3 && streak % 3 == 0 {
                score += 1
            }
            
            HapticManager.shared.notification(type: .success)
            SoundManager.shared.playCorrectSound()
        } else {
            score -= 1
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
        if score >= questions.count { // Adjusted threshold since max score is higher now
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
                    
                    if let question = self.currentQuestion {
                        self.attemptedQuestions.append(AttemptedQuestion(question: question, selectedIndex: nil))
                    }
                    
                    // Award 0 points for timing out, but break the streak
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
