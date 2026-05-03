import Foundation

/// Represents a single multiple-choice question
struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}
