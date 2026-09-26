import SwiftData
import Testing
@testable import PracticeZone

struct ExamAttemptTests {
    let container: ModelContainer

    init() throws {
        container = try .inMemory()
    }

    @Test(arguments: [
        (0, 0, 0, 0, 0),
        (2, 3, 0, 0, 67),
        (1, 1, 0, 1, 50),
    ])
    func `Score percentage adds up both kinds of question`(
        multipleChoiceScore: Int, multipleChoiceTotal: Int,
        productionScore: Int, productionTotal: Int, expected: Int
    ) {
        let attempt = ExamAttempt(
            multipleChoiceScore: multipleChoiceScore, multipleChoiceTotal: multipleChoiceTotal,
            productionScore: productionScore, productionTotal: productionTotal
        )
        container.mainContext.insert(attempt)

        #expect(attempt.scorePercentage == expected)
    }
}
