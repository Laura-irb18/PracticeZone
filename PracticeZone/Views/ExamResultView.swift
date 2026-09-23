import SwiftUI

struct ExamResultView: View {
    let attempt: ExamAttempt

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Text("\(attempt.scorePercentage)%")
                        .font(.system(size: 48, weight: .bold))
                    Text("\(attempt.multipleChoiceScore + attempt.productionScore) of \(attempt.multipleChoiceTotal + attempt.productionTotal) correct")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Questions") {
                ForEach(attempt.sortedQuestionResults) { result in
                    ExamQuestionResultRow(result: result)
                }
            }
        }
        .navigationTitle("Results")
    }
}

#Preview {
    let attempt = ExamAttempt(multipleChoiceScore: 2, multipleChoiceTotal: 3, productionScore: 1, productionTotal: 2)
    attempt.questionResults = [
        ExamQuestionResult(
            questionText: "Which word means: an arrangement to have something held for you in advance",
            kind: .multipleChoice,
            isCorrect: true,
            pointsEarned: 1,
            maxPoints: 1,
            userAnswer: "reservation"
        ),
        ExamQuestionResult(
            questionText: "Write a sentence using \"light\"",
            kind: .production,
            isCorrect: false,
            pointsEarned: 0,
            maxPoints: 1,
            userAnswer: "The room is a light."
        )
    ]
    return NavigationStack {
        ExamResultView(attempt: attempt)
    }
}
