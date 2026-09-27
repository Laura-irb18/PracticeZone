import Foundation
import SwiftData

@Model
final class VocabularyItem {
    var word: String
    var friendlyPronunciation: String
    var isFavorite: Bool
    var createdAt: Date
    var lastExaminedAt: Date?
    var wordGroup: WordGroup?

    @Relationship(deleteRule: .cascade, inverse: \Meaning.item)
    var meanings: [Meaning]

    @Relationship(deleteRule: .cascade, inverse: \PracticeAttempt.item)
    var practiceAttempts: [PracticeAttempt]

    init(word: String, friendlyPronunciation: String, meanings: [Meaning] = [], practiceAttempts: [PracticeAttempt] = [], isFavorite: Bool = false, createdAt: Date = Date(), lastExaminedAt: Date? = nil, wordGroup: WordGroup? = nil) {
        self.word = word
        self.friendlyPronunciation = friendlyPronunciation
        self.meanings = meanings
        self.practiceAttempts = practiceAttempts
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.lastExaminedAt = lastExaminedAt
        self.wordGroup = wordGroup
    }

    var sortedMeanings: [Meaning] {
        meanings.sorted { $0.order < $1.order }
    }

    var primaryMeaning: String {
        sortedMeanings.first?.definition ?? ""
    }

    var meaningSummary: String {
        sortedMeanings.map(\.definition).joined(separator: "; ")
    }

    var sortedPracticeAttempts: [PracticeAttempt] {
        practiceAttempts.sorted { $0.createdAt > $1.createdAt }
    }
}
