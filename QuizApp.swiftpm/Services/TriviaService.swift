import Foundation

class TriviaService {
    static let shared = TriviaService()
    
    func fetchQuestions(categoryId: Int?, amount: Int = 10) async throws -> [Question] {
        var urlString = "https://opentdb.com/api.php?amount=\(amount)&type=multiple"
        if let categoryId = categoryId {
            urlString += "&category=\(categoryId)"
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TriviaResponse.self, from: data)
        
        return response.results.map { trivia in
            // API returns correct and incorrect separately. Mix them and find the correct index.
            let decodedCorrect = decodeHTMLEntities(trivia.correctAnswer)
            var allOptions = trivia.incorrectAnswers.map { decodeHTMLEntities($0) }
            
            // Insert correct answer at a random index
            let correctIndex = Int.random(in: 0...allOptions.count)
            allOptions.insert(decodedCorrect, at: correctIndex)
            
            return Question(
                text: decodeHTMLEntities(trivia.question),
                options: allOptions,
                correctAnswerIndex: correctIndex
            )
        }
    }
    
    // Quick helper to decode HTML entities like &quot;
    private func decodeHTMLEntities(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return string
    }
}
