import SwiftData
@testable import PracticeZone

extension ModelContainer {
    /// Same models as the app, stored only in memory, so each test starts empty.
    static func inMemory() throws -> ModelContainer {
        try ModelContainer(
            for: WordGroup.self, VocabularyItem.self, Meaning.self, Example.self,
            PracticeAttempt.self, ExamAttempt.self, ExamQuestionResult.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
}
