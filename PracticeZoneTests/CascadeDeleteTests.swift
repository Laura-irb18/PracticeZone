import SwiftData
import Testing
@testable import PracticeZone

/// The lists delete a group, a word or an exam attempt with a single `delete`,
/// so everything that belongs to it has to go with it.
struct CascadeDeleteTests {
    let container: ModelContainer

    init() throws {
        container = try .inMemory()
    }

    @Test func `Deleting a group deletes everything in it`() throws {
        let group = try makeGroupWithEverything()

        container.mainContext.delete(group)
        try container.mainContext.save()

        #expect(try count(WordGroup.self) == 0)
        #expect(try count(VocabularyItem.self) == 0)
        #expect(try count(Meaning.self) == 0)
        #expect(try count(Example.self) == 0)
        #expect(try count(PracticeAttempt.self) == 0)
        #expect(try count(ExamAttempt.self) == 0)
        #expect(try count(ExamQuestionResult.self) == 0)
    }

    @Test func `Deleting a word deletes its meanings, examples and practice, not its group`() throws {
        let group = try makeGroupWithEverything()
        let item = try #require(group.items.first)

        container.mainContext.delete(item)
        try container.mainContext.save()

        #expect(try count(VocabularyItem.self) == 0)
        #expect(try count(Meaning.self) == 0)
        #expect(try count(Example.self) == 0)
        #expect(try count(PracticeAttempt.self) == 0)
        #expect(try count(WordGroup.self) == 1)
        #expect(try count(ExamAttempt.self) == 1)
    }

    @Test func `Deleting an exam attempt deletes its results, not its group`() throws {
        let group = try makeGroupWithEverything()
        let attempt = try #require(group.examAttempts.first)

        container.mainContext.delete(attempt)
        try container.mainContext.save()

        #expect(try count(ExamAttempt.self) == 0)
        #expect(try count(ExamQuestionResult.self) == 0)
        #expect(try count(WordGroup.self) == 1)
        #expect(try count(VocabularyItem.self) == 1)
    }

    // MARK: Helpers

    /// A saved group with one of every model below it.
    private func makeGroupWithEverything() throws -> WordGroup {
        let group = WordGroup(name: "Travel")
        container.mainContext.insert(group)

        let meaning = Meaning(definition: "to go to another place", partOfSpeech: "verb", order: 0)
        meaning.examples = [Example(text: "I travel a lot.", translation: "Viajo mucho.", order: 0)]
        let item = VocabularyItem(word: "travel", friendlyPronunciation: "")
        item.meanings = [meaning]
        item.practiceAttempts = [PracticeAttempt(sentence: "I traveled to Rome.", isCorrect: true, feedback: "")]
        group.items.append(item)

        let attempt = ExamAttempt()
        attempt.questionResults = [
            ExamQuestionResult(questionText: "Write a sentence using \"travel\"", kind: .production, isCorrect: true, pointsEarned: 1, maxPoints: 1)
        ]
        group.examAttempts.append(attempt)

        try container.mainContext.save()
        return group
    }

    private func count<Model: PersistentModel>(_ type: Model.Type) throws -> Int {
        try container.mainContext.fetchCount(FetchDescriptor<Model>())
    }
}
