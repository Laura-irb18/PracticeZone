import Foundation
import SwiftData

@Model
final class PracticeAttempt {
    var sentence: String
    var isCorrect: Bool
    var feedback: String
    var correctedSentences: [String]
    var createdAt: Date
    var item: VocabularyItem?

    init(sentence: String, isCorrect: Bool, feedback: String, correctedSentences: [String] = [], createdAt: Date = Date(), item: VocabularyItem? = nil) {
        self.sentence = sentence
        self.isCorrect = isCorrect
        self.feedback = feedback
        self.correctedSentences = correctedSentences
        self.createdAt = createdAt
        self.item = item
    }
}
