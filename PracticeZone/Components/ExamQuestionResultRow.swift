import SwiftUI

struct ExamQuestionResultRow: View {
    let result: ExamQuestionResult

    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(result.isCorrect ? .green : .red)
            VStack(alignment: .leading, spacing: 4) {
                Text(result.questionText)
                Text(result.kind == .multipleChoice ? "Multiple choice" : "Production")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let feedback = result.feedback, !feedback.isEmpty {
                    Text(feedback)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                ForEach(result.correctedSentences ?? [], id: \.self) { corrected in
                    Text(corrected)
                        .font(.footnote)
                        .italic()
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ExamQuestionResultRow(
        result: ExamQuestionResult(
            questionText: "Write a sentence using \"light\"",
            kind: .production,
            isCorrect: false,
            pointsEarned: 0,
            maxPoints: 1,
            feedback: "Good use of \"light\" — just fix the grammar: \"a light\" should be \"light\".",
            correctedSentences: ["The room is light."]
        )
    )
    .padding()
}
