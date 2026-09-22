import SwiftUI
import SwiftData

struct ExamTakingView: View {
    let group: WordGroup
    @Environment(\.modelContext) private var modelContext

    @State private var questions: [ExamQuestion] = []
    @State private var currentIndex = 0
    @State private var results: [ExamQuestionResult] = []
    @State private var finishedAttempt: ExamAttempt?

    var body: some View {
        Group {
            if let finishedAttempt {
                ExamResultView(attempt: finishedAttempt)
            } else if questions.isEmpty {
                ContentUnavailableView(
                    "Not Enough Words",
                    systemImage: "questionmark.circle",
                    description: Text("Add more words with meanings to \"\(group.name)\" before taking an exam.")
                )
            } else {
                quizStack
            }
        }
        .navigationTitle("Exam")
        .task {
            guard questions.isEmpty, finishedAttempt == nil else { return }
            questions = ExamGenerator.makeQuestions(for: group)
        }
    }

    @ViewBuilder
    private var quizStack: some View {
        VStack(alignment: .leading, spacing: 24) {
            ProgressView(value: Double(currentIndex), total: Double(questions.count))

            Text("Question \(currentIndex + 1) of \(questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)

            let question = questions[currentIndex]
            switch question.kind {
            case .multipleChoice(let options):
                MultipleChoiceQuestionView(meaning: question.meaning, options: options) { selected in
                    recordMultipleChoice(question: question, selected: selected)
                }
                .id(question.id)
            case .production:
                ProductionQuestionView(word: question.word, meaning: question.meaning) { feedback in
                    recordProduction(question: question, feedback: feedback)
                }
                .id(question.id)
            }

            Spacer()
        }
        .padding()
    }

    private func recordMultipleChoice(question: ExamQuestion, selected: String) {
        let isCorrect = selected == question.word
        let result = ExamQuestionResult(
            questionText: "Which word means: \(question.meaning)",
            kind: .multipleChoice,
            isCorrect: isCorrect,
            pointsEarned: isCorrect ? 1 : 0,
            maxPoints: 1,
            feedback: isCorrect ? "" : "Correct answer: \"\(question.word)\""
        )
        advance(with: result)
    }

    private func recordProduction(question: ExamQuestion, feedback: PracticeFeedback) {
        let result = ExamQuestionResult(
            questionText: "Write a sentence using \"\(question.word)\"",
            kind: .production,
            isCorrect: feedback.isCorrect,
            pointsEarned: feedback.isCorrect ? 1 : 0,
            maxPoints: 1,
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
            modelContext.insert(result)
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
        modelContext.insert(attempt)
        group.examAttempts.append(attempt)

        let examinedAt = Date()
        for question in questions {
            question.item.lastExaminedAt = examinedAt
        }

        finishedAttempt = attempt
    }
}

#Preview {
    let group = WordGroup(name: "Travel", groupDescription: "Words for booking trips", iconName: "airplane")
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon", wordGroup: group)
    item.meanings = [
        Meaning(
            definition: "an arrangement to have something held for you in advance",
            partOfSpeech: "noun",
            context: "used when booking a table, room, or seat",
            order: 0,
            item: item
        )
    ]
    group.items = [item]
    return NavigationStack {
        ExamTakingView(group: group)
    }
}
