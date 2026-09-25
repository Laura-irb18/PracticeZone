import SwiftUI
import SwiftData

struct ExamTakingView: View {
    let group: WordGroup

    @State private var session: ExamSession?

    var body: some View {
        Group {
            if let session {
                if let finishedAttempt = session.finishedAttempt {
                    ExamResultView(attempt: finishedAttempt)
                } else if session.questions.isEmpty {
                    ContentUnavailableView(
                        "Not Enough Words",
                        systemImage: "questionmark.circle",
                        description: Text("Add more words with meanings to \"\(group.name)\" before taking an exam.")
                    )
                } else {
                    quizStack(session)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Exam")
        .task {
            guard session == nil else { return }
            session = ExamSession(group: group)
        }
    }

    private func quizStack(_ session: ExamSession) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            ProgressView(value: Double(session.currentIndex), total: Double(session.questions.count))

            Text("Question \(session.currentIndex + 1) of \(session.questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            let question = session.currentQuestion
            switch question.kind {
            case .multipleChoice(let options):
                MultipleChoiceQuestionView(meaning: question.meaning, options: options) { selected in
                    session.recordMultipleChoice(selected: selected)
                }
                .id(question.id)
            case .production:
                ProductionQuestionView(word: question.word, meaning: question.meaning) { sentence, feedback in
                    session.recordProduction(sentence: sentence, feedback: feedback)
                }
                .id(question.id)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    let group = WordGroup(name: "Travel", groupDescription: "Words for booking trips", iconName: "airplane")
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon", wordGroup: group)
    item.meanings = [
        Meaning(
            definition: "an arrangement to have something held for you in advance",
            partOfSpeech: "noun",
            order: 0,
            item: item
        )
    ]
    group.items = [item]
    return NavigationStack {
        ExamTakingView(group: group)
    }
}
