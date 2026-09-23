import Foundation

/// Runs a single exam: builds the questions for a word group, records each answer
/// as an `ExamQuestionResult`, and once the last question is answered attaches the
/// `ExamAttempt` to the group and marks every examined word with `lastExaminedAt`.
///
/// No `ModelContext` is needed: appending the new attempt to the group (already
/// persisted) makes SwiftData insert the attempt and its results automatically.
@Observable @MainActor
final class ExamSession {
    /// Groups larger than this are capped to keep an exam a reasonable length — not
    /// because of any model context-window limit (each production question grades in
    /// its own short-lived session, so the cap is purely about exam duration).
    /// When capping, the least recently examined words are prioritized, so repeated
    /// exams eventually cover every word in a large group instead of relying on chance.
    static let maxQuestionsPerExam = 10

    let group: WordGroup
    let questions: [ExamQuestion]
    private(set) var currentIndex = 0
    private(set) var finishedAttempt: ExamAttempt?

    private var results: [ExamQuestionResult] = []

    init(group: WordGroup) {
        self.group = group
        self.questions = Self.makeQuestions(for: group)
    }

    var currentQuestion: ExamQuestion {
        questions[currentIndex]
    }

    func recordMultipleChoice(selected: String) {
        let question = currentQuestion
        let isCorrect = selected == question.word
        let result = ExamQuestionResult(
            questionText: "Which word means: \(question.meaning)",
            kind: .multipleChoice,
            isCorrect: isCorrect,
            pointsEarned: isCorrect ? 1 : 0,
            maxPoints: 1,
            userAnswer: selected,
            feedback: isCorrect ? "" : "Correct answer: \"\(question.word)\""
        )
        advance(with: result)
    }

    func recordProduction(sentence: String, feedback: PracticeFeedback) {
        let question = currentQuestion
        let result = ExamQuestionResult(
            questionText: "Write a sentence using \"\(question.word)\"",
            kind: .production,
            isCorrect: feedback.isCorrect,
            pointsEarned: feedback.isCorrect ? 1 : 0,
            maxPoints: 1,
            userAnswer: sentence,
            feedback: feedback.feedback,
            correctedSentences: feedback.correctedSentences
        )
        advance(with: result)
    }

    private func advance(with result: ExamQuestionResult) {
        results.append(result)
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            finish()
        }
    }

    private func finish() {
        let attempt = ExamAttempt(wordGroup: group)
        for result in results {
            result.attempt = attempt
            attempt.questionResults.append(result)
            switch result.kind {
            case .multipleChoice:
                attempt.multipleChoiceTotal += result.maxPoints
                attempt.multipleChoiceScore += result.pointsEarned
            case .production:
                attempt.productionTotal += result.maxPoints
                attempt.productionScore += result.pointsEarned
            }
        }
        group.examAttempts.append(attempt)

        let examinedAt = Date()
        for question in questions {
            question.item.lastExaminedAt = examinedAt
        }

        finishedAttempt = attempt
    }

    /// Half multiple choice (matching a definition to its word, with distractor words
    /// from the same group) and half production (writing a sentence, graded by
    /// `PracticeFeedbackGenerator`), shuffled.
    private static func makeQuestions(for group: WordGroup) -> [ExamQuestion] {
        let usableItems = group.items.filter { !$0.meanings.isEmpty }
        guard !usableItems.isEmpty else { return [] }

        let prioritizedItems = usableItems.sorted {
            ($0.lastExaminedAt ?? .distantPast) < ($1.lastExaminedAt ?? .distantPast)
        }
        let selectedItems = Array(prioritizedItems.prefix(maxQuestionsPerExam)).shuffled()

        let multipleChoiceCount = Int((Double(selectedItems.count) / 2).rounded())
        let multipleChoiceItems = selectedItems.prefix(multipleChoiceCount)
        let productionItems = selectedItems.dropFirst(multipleChoiceCount)
        let allWords = usableItems.map(\.word)

        let multipleChoiceQuestions = multipleChoiceItems.map { item in
            multipleChoiceQuestion(for: item, allWords: allWords)
        }
        let productionQuestions = productionItems.map { item in
            ExamQuestion(item: item, word: item.word, meaning: item.meaningSummary, kind: .production)
        }

        return (multipleChoiceQuestions + productionQuestions).shuffled()
    }

    private static func multipleChoiceQuestion(for item: VocabularyItem, allWords: [String]) -> ExamQuestion {
        let distractors = allWords.filter { $0 != item.word }.shuffled().prefix(3)
        let options = ([item.word] + distractors).shuffled()
        return ExamQuestion(item: item, word: item.word, meaning: item.primaryMeaning, kind: .multipleChoice(options: options))
    }
}
