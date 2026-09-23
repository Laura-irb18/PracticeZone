import Foundation
import SwiftData

@Model
final class ExamAttempt {
    var date: Date
    var multipleChoiceScore: Int
    var multipleChoiceTotal: Int
    var productionScore: Int
    var productionTotal: Int
    var wordGroup: WordGroup?

    @Relationship(deleteRule: .cascade, inverse: \ExamQuestionResult.attempt)
    var questionResults: [ExamQuestionResult]

    init(date: Date = Date(), multipleChoiceScore: Int = 0, multipleChoiceTotal: Int = 0, productionScore: Int = 0, productionTotal: Int = 0, wordGroup: WordGroup? = nil, questionResults: [ExamQuestionResult] = []) {
        self.date = date
        self.multipleChoiceScore = multipleChoiceScore
        self.multipleChoiceTotal = multipleChoiceTotal
        self.productionScore = productionScore
        self.productionTotal = productionTotal
        self.wordGroup = wordGroup
        self.questionResults = questionResults
    }

    var scorePercentage: Int {
        let earned = multipleChoiceScore + productionScore
        let total = multipleChoiceTotal + productionTotal
        guard total > 0 else { return 0 }
        return Int((Double(earned) / Double(total) * 100).rounded())
    }

    var sortedQuestionResults: [ExamQuestionResult] {
        questionResults.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }
}

enum ExamQuestionKind: String, Codable {
    case multipleChoice
    case production
}

@Model
final class ExamQuestionResult {
    var questionText: String
    var kind: ExamQuestionKind
    var isCorrect: Bool
    var pointsEarned: Int
    var maxPoints: Int

    /// For a wrong multiple-choice answer, the correct word. For a production answer,
    /// the grammar/meaning feedback sentence from `PracticeFeedbackGenerator`. Nil when correct.
    /// Optional (rather than a non-optional default) so lightweight migration can add this
    /// attribute to existing rows without a "missing mandatory attribute" failure — SwiftData's
    /// automatic migration only fills in a default for genuinely optional attributes.
    var feedback: String?

    /// Corrected versions of the submitted sentence, for a production answer only. Optional
    /// for the same migration-safety reason as `feedback`.
    var correctedSentences: [String]?

    /// What the user answered: the chosen option for multiple choice, or the submitted
    /// sentence for production. Optional for the same migration-safety reason as `feedback`
    /// (and nil for results saved before this field existed).
    var userAnswer: String?

    /// Position of the question in the exam (0-based). SwiftData doesn't keep the order
    /// of a to-many relationship when it refetches from the store, so results are sorted
    /// by this. Optional for the same migration-safety reason as `feedback` (and nil for
    /// results saved before this field existed).
    var order: Int?

    var attempt: ExamAttempt?

    init(questionText: String, kind: ExamQuestionKind, isCorrect: Bool, pointsEarned: Int, maxPoints: Int, userAnswer: String? = nil, feedback: String? = nil, correctedSentences: [String]? = nil, attempt: ExamAttempt? = nil) {
        self.questionText = questionText
        self.kind = kind
        self.isCorrect = isCorrect
        self.pointsEarned = pointsEarned
        self.maxPoints = maxPoints
        self.userAnswer = userAnswer
        self.feedback = feedback
        self.correctedSentences = correctedSentences
        self.attempt = attempt
    }
}
