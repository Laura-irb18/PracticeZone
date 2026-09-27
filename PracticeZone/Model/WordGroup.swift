import Foundation
import SwiftData

@Model
final class WordGroup {
    var name: String
    var groupDescription: String
    var iconName: String
    var color: GroupColor
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \VocabularyItem.wordGroup)
    var items: [VocabularyItem]

    @Relationship(deleteRule: .cascade, inverse: \ExamAttempt.wordGroup)
    var examAttempts: [ExamAttempt]

    init(name: String, groupDescription: String = "", iconName: String = "book.fill", color: GroupColor = .blue, createdAt: Date = Date(), items: [VocabularyItem] = [], examAttempts: [ExamAttempt] = []) {
        self.name = name
        self.groupDescription = groupDescription
        self.iconName = iconName
        self.color = color
        self.createdAt = createdAt
        self.items = items
        self.examAttempts = examAttempts
    }

    var sortedItems: [VocabularyItem] {
        items.sorted { $0.createdAt > $1.createdAt }
    }

    var sortedExamAttempts: [ExamAttempt] {
        examAttempts.sorted { $0.date > $1.date }
    }

    /// Words that can appear in an exam: only those with at least one meaning.
    var examItems: [VocabularyItem] {
        items.filter { !$0.meanings.isEmpty }
    }
}
