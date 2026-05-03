import Foundation

/// Represents a quiz category containing a list of questions
struct QuizCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let questions: [Question]
    
    // Hashable and Equatable conformance for Navigation/Selection
    static func == (lhs: QuizCategory, rhs: QuizCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Mock Data
    
    static let sampleCategories: [QuizCategory] = [
        QuizCategory(name: "General Knowledge", questions: [
            Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswerIndex: 2),
            Question(text: "Which planet is known as the Red Planet?", options: ["Venus", "Mars", "Jupiter", "Saturn"], correctAnswerIndex: 1),
            Question(text: "Who painted the Mona Lisa?", options: ["Vincent Van Gogh", "Pablo Picasso", "Leonardo da Vinci", "Claude Monet"], correctAnswerIndex: 2),
            Question(text: "What is the largest ocean on Earth?", options: ["Atlantic Ocean", "Indian Ocean", "Arctic Ocean", "Pacific Ocean"], correctAnswerIndex: 3),
            Question(text: "In which year did the Titanic sink?", options: ["1912", "1905", "1898", "1923"], correctAnswerIndex: 0)
        ]),
        QuizCategory(name: "Tech & Science", questions: [
            Question(text: "What does CPU stand for?", options: ["Computer Personal Unit", "Central Process Unit", "Central Processing Unit", "Central Processor Unit"], correctAnswerIndex: 2),
            Question(text: "Which company developed the Swift programming language?", options: ["Google", "Microsoft", "Apple", "Facebook"], correctAnswerIndex: 2),
            Question(text: "What is the chemical symbol for Gold?", options: ["Au", "Ag", "Go", "Gd"], correctAnswerIndex: 0),
            Question(text: "Which is the most abundant gas in the earth's atmosphere?", options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"], correctAnswerIndex: 2),
            Question(text: "What does HTML stand for?", options: ["Hyper Text Markup Language", "High Tech Modern Language", "Hyperlink and Text Markup Language", "Home Tool Markup Language"], correctAnswerIndex: 0)
        ])
    ]
}
