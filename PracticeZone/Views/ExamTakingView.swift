import SwiftUI
import SwiftData

struct ExamTakingView: View {
    let group: WordGroup
    @Environment(\.dismiss) private var dismiss

    @State private var session: ExamSession?
    @State private var isConfirmingEnd = false

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        if session?.isInProgress == true {
                            isConfirmingEnd = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog("End Exam?", isPresented: $isConfirmingEnd, titleVisibility: .visible) {
                        Button("End Exam", role: .destructive) {
                            dismiss()
                        }
                    } message: {
                        Text("Your answers so far won't be saved.")
                    }
                }
            }
        }
        .task {
            guard session == nil else { return }
            session = ExamSession(group: group)
        }
    }

    @ViewBuilder
    private func quizStack(_ session: ExamSession) -> some View {
        let question = session.currentQuestion
        switch question.kind {
        case .multipleChoice(let options):
            MultipleChoiceQuestionView(meaning: question.meaning, options: options) { selected in
                session.recordMultipleChoice(selected: selected)
            } onSkip: {
                session.skipQuestion()
            }
            .id(question.id)
            .safeAreaInset(edge: .top) {
                progressHeader(session)
                    .padding(.horizontal)
            }
        case .production:
            ProductionQuestionView(word: question.word) { sentence, feedback in
                session.recordProduction(sentence: sentence, feedback: feedback)
            } onSkip: { sentence in
                session.skipProduction(sentence: sentence)
            } onSkipQuestion: {
                session.skipQuestion()
            }
            .id(question.id)
            .safeAreaInset(edge: .top) {
                progressHeader(session)
                    .padding(.horizontal)
            }
        }
    }

    private func progressHeader(_ session: ExamSession) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            ProgressView(value: Double(session.currentIndex), total: Double(session.questions.count))
            Text("Question \(session.currentIndex + 1) of \(session.questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
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
    return ExamTakingView(group: group)
}
