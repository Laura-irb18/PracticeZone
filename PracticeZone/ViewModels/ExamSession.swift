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

    /// Options shown in a multiple-choice question: the word plus three distractors
    /// from the same group. Groups smaller than this only get production questions,
    /// so a question never shows a single (or too few) options.
    static let optionsPerQuestion = 4

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

    /// True while there are questions left to answer. Closing the exam then loses
    /// the answers given so far, because the attempt is only saved at the end.
    var isInProgress: Bool {
        finishedAttempt == nil && !questions.isEmpty
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

    /// Records a production question the user skipped because grading failed.
    /// It counts as incorrect, like a wrong answer.
    func skipProduction(sentence: String) {
        let question = currentQuestion
        let result = ExamQuestionResult(
            questionText: "Write a sentence using \"\(question.word)\"",
            kind: .production,
            isCorrect: false,
            pointsEarned: 0,
            maxPoints: 1,
            userAnswer: sentence,
            feedback: "Skipped: the sentence couldn't be checked."
        )
        advance(with: result)
    }

    private func advance(with result: ExamQuestionResult) {
        result.order = currentIndex
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
    /// `PracticeFeedbackGenerator`), shuffled. Groups with fewer than
    /// `optionsPerQuestion` words only get production questions.
    private static func makeQuestions(for group: WordGroup) -> [ExamQuestion] {
        let usableItems = group.items.filter { !$0.meanings.isEmpty }
        guard !usableItems.isEmpty else { return [] }

        let prioritizedItems = usableItems.sorted {
            ($0.lastExaminedAt ?? .distantPast) < ($1.lastExaminedAt ?? .distantPast)
        }
        let selectedItems = Array(prioritizedItems.prefix(maxQuestionsPerExam)).shuffled()

        let canAskMultipleChoice = usableItems.count >= optionsPerQuestion
        let multipleChoiceCount = canAskMultipleChoice ? Int((Double(selectedItems.count) / 2).rounded()) : 0
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
        let distractors = allWords.filter { $0 != item.word }.shuffled().prefix(optionsPerQuestion - 1)
        let options = ([item.word] + distractors).shuffled()
        return ExamQuestion(item: item, word: item.word, meaning: item.primaryMeaning, kind: .multipleChoice(options: options))
    }
}
