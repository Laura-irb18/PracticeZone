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
    var attempt: ExamAttempt?

    init(questionText: String, kind: ExamQuestionKind, isCorrect: Bool, pointsEarned: Int, maxPoints: Int, attempt: ExamAttempt? = nil) {
        self.questionText = questionText
        self.kind = kind
        self.isCorrect = isCorrect
        self.pointsEarned = pointsEarned
        self.maxPoints = maxPoints
        self.attempt = attempt
    }
}
