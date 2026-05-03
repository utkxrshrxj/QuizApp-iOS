import Foundation

/// Represents a quiz category containing a list of questions
struct QuizCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let apiId: Int? // Open Trivia DB ID (nil = Any Category)
    
    // Hashable and Equatable conformance for Navigation/Selection
    static func == (lhs: QuizCategory, rhs: QuizCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - API Categories
    
    static let sampleCategories: [QuizCategory] = [
        QuizCategory(name: "Mixed (Any)", apiId: nil),
        QuizCategory(name: "General Knowledge", apiId: 9),
        QuizCategory(name: "Science & Nature", apiId: 17),
        QuizCategory(name: "Computers & Tech", apiId: 18),
        QuizCategory(name: "Video Games", apiId: 15),
        QuizCategory(name: "History", apiId: 23)
    ]
}
