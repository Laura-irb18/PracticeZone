import Foundation
import SwiftData
import Testing
@testable import PracticeZone

struct ExamSessionTests {
    let container: ModelContainer

    init() throws {
        container = try .inMemory()
    }

    @Test(arguments: [(0, 0), (0, 2)])
    func `A group without usable words has no questions`(words: Int, wordsWithoutMeaning: Int) {
        let session = ExamSession(group: makeGroup(words: words, wordsWithoutMeaning: wordsWithoutMeaning))

        #expect(session.questions.isEmpty)
        #expect(!session.isInProgress)
    }

    @Test func `Multiple choice needs at least four words with a meaning`() {
        let session = ExamSession(group: makeGroup(words: 3, wordsWithoutMeaning: 2))

        #expect(session.questions.count == 3)
        #expect(multipleChoiceOptions(in: session).isEmpty)
    }

    @Test(arguments: [(4, 2), (5, 3), (11, 5)])
    func `About half the questions are multiple choice`(words: Int, multipleChoiceCount: Int) {
        let session = ExamSession(group: makeGroup(words: words))

        #expect(session.questions.count == min(words, ExamSession.maxQuestionsPerExam))
        #expect(multipleChoiceOptions(in: session).count == multipleChoiceCount)
    }

    @Test func `Options are four different words with a meaning, including the answer`() {
        let session = ExamSession(group: makeGroup(words: 6, wordsWithoutMeaning: 2))

        for question in session.questions {
            guard case .multipleChoice(let options) = question.kind else { continue }
            #expect(options.count == 4)
            #expect(Set(options).count == options.count)
            #expect(options.contains(question.word))
            #expect(!options.contains { $0.hasPrefix("empty") })
        }
    }

    @Test func `A large group leaves out the most recently examined word`() throws {
        let group = makeGroup(words: 11)
        let recent = try #require(group.items.first { $0.word == "word0" })
        recent.lastExaminedAt = .now

        let session = ExamSession(group: group)

        #expect(session.questions.count == ExamSession.maxQuestionsPerExam)
        #expect(!session.questions.contains { $0.word == "word0" })
    }

    @Test func `Finishing the exam saves the attempt with its scores`() throws {
        let group = makeGroup(words: 6)
        let session = ExamSession(group: group)
        let multipleChoiceCount = multipleChoiceOptions(in: session).count
        let productionCount = session.questions.count - multipleChoiceCount
        let before = Date.now

        answerAllCorrectly(session)

        let attempt = try #require(session.finishedAttempt)
        #expect(!session.isInProgress)
        #expect(group.examAttempts.count == 1)
        #expect(attempt.multipleChoiceScore == multipleChoiceCount)
        #expect(attempt.multipleChoiceTotal == multipleChoiceCount)
        #expect(attempt.productionScore == productionCount)
        #expect(attempt.productionTotal == productionCount)
        #expect(attempt.sortedQuestionResults.map(\.order) == Array(0..<session.questions.count))
        for item in group.items {
            let examinedAt = try #require(item.lastExaminedAt)
            #expect(examinedAt >= before && examinedAt <= .now)
        }
    }

    @Test func `A wrong multiple choice answer counts as incorrect`() throws {
        let session = ExamSession(group: makeGroup(words: 4))

        while session.isInProgress {
            let question = session.currentQuestion
            switch question.kind {
            case .multipleChoice(let options):
                let wrongOption = try #require(options.first { $0 != question.word })
                session.recordMultipleChoice(selected: wrongOption)
            case .production:
                session.skipProduction(sentence: "")
            }
        }

        let attempt = try #require(session.finishedAttempt)
        let results = attempt.questionResults.filter { $0.kind == .multipleChoice }
        #expect(attempt.multipleChoiceTotal == 2)
        #expect(attempt.multipleChoiceScore == 0)
        #expect(results.allSatisfy { !$0.isCorrect })
        #expect(results.allSatisfy { $0.feedback?.hasPrefix("Correct answer:") == true })
    }

    @Test func `A skipped question counts as incorrect`() throws {
        let session = ExamSession(group: makeGroup(words: 3))

        session.skipProduction(sentence: "")
        answerAllCorrectly(session)

        let attempt = try #require(session.finishedAttempt)
        #expect(attempt.productionScore == 2)
        #expect(attempt.productionTotal == 3)
        #expect(attempt.sortedQuestionResults.first?.isCorrect == false)
    }

    @Test func `Skipping any question counts as incorrect`() throws {
        let session = ExamSession(group: makeGroup(words: 6))

        while session.isInProgress {
            session.skipQuestion()
        }

        let attempt = try #require(session.finishedAttempt)
        #expect(attempt.questionResults.count == session.questions.count)
        #expect(attempt.multipleChoiceTotal > 0)
        #expect(attempt.productionTotal > 0)
        #expect(attempt.scorePercentage == 0)
        #expect(attempt.questionResults.allSatisfy { !$0.isCorrect })
    }

    // MARK: Helpers

    private func makeGroup(words: Int, wordsWithoutMeaning: Int = 0) -> WordGroup {
        let group = WordGroup(name: "Test")
        container.mainContext.insert(group)
        for index in 0..<words {
            let item = VocabularyItem(word: "word\(index)", friendlyPronunciation: "")
            item.meanings = [Meaning(definition: "definition \(index)", partOfSpeech: "noun", order: 0)]
            group.items.append(item)
        }
        for index in 0..<wordsWithoutMeaning {
            group.items.append(VocabularyItem(word: "empty\(index)", friendlyPronunciation: ""))
        }
        return group
    }

    private func multipleChoiceOptions(in session: ExamSession) -> [[String]] {
        session.questions.compactMap { question in
            guard case .multipleChoice(let options) = question.kind else { return nil }
            return options
        }
    }

    /// Answers every remaining question: the right word, or a sentence the model left unchanged.
    private func answerAllCorrectly(_ session: ExamSession) {
        while session.isInProgress {
            switch session.currentQuestion.kind {
            case .multipleChoice:
                session.recordMultipleChoice(selected: session.currentQuestion.word)
            case .production:
                let feedback = PracticeFeedback(sentence: "A sentence.", grammar: GrammarCheckResult(correctedSentence: ""))
                session.recordProduction(sentence: "A sentence.", feedback: feedback)
            }
        }
    }
}
