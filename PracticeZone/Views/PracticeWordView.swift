import SwiftUI
import SwiftData

struct PracticeWordView: View {
    let item: VocabularyItem
    @Environment(\.modelContext) private var modelContext

    @State private var sentence = ""
    @State private var generator: PracticeFeedbackGenerator?
    @State private var hasSubmitted = false

    var body: some View {
        Form {
            Section {
                WordDetailView(item: item)
            }

            Section("Your sentence") {
                TextField("Write a sentence using \"\(item.word)\"", text: $sentence, axis: .vertical)
                    .disabled(generator?.isGenerating == true)
            }

            if hasSubmitted, let generator {
                if let error = generator.error {
                    Section {
                        Label(error.localizedDescription, systemImage: "xmark.circle")
                            .foregroundStyle(.red)
                    }
                } else if let result = generator.result {
                    Section("Feedback") {
                        Label(result.isCorrect ? "Correct" : "Needs work", systemImage: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(result.isCorrect ? .green : .red)
                        Text(result.feedback)
                        ForEach(result.correctedSentences, id: \.self) { corrected in
                            Text(corrected)
                                .italic()
                                .foregroundStyle(.secondary)
                        }
                        Text(MotivationalPhrase.random(isCorrect: result.isCorrect))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !item.sortedPracticeAttempts.isEmpty {
                Section("History") {
                    ForEach(item.sortedPracticeAttempts) { attempt in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: attempt.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(attempt.isCorrect ? .green : .red)
                                Text(attempt.sentence)
                                    .font(.subheadline)
                            }
                            Text(attempt.feedback)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text(attempt.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteAttempt(attempt)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Practice")
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .task(id: item.meaningSummary) {
            guard generator?.isGenerating != true else { return }
            if generator != nil { hasSubmitted = false }
            let newGenerator = PracticeFeedbackGenerator(
                word: item.word,
                meaning: item.meaningSummary
            )
            generator = newGenerator
            newGenerator.prewarm()
        }
        .onChange(of: generator?.isGenerating) { _, isGenerating in
            guard isGenerating == false,
                  let generator,
                  generator.error == nil,
                  let result = generator.result else { return }
            saveAttempt(sentence: sentence, result: result)
        }
    }

    @ViewBuilder
    private var bottomBar: some View {
        if generator?.isGenerating == true {
            ProgressView()
                .padding()
        } else if hasSubmitted, generator?.result != nil {
            Button {
                reset()
            } label: {
                Label("Try Another Sentence", systemImage: "arrow.counterclockwise")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        } else {
            Button {
                submit()
            } label: {
                Label("Check Sentence", systemImage: "checkmark")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding()
        }
    }

    private func submit() {
        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let generator else { return }
        hasSubmitted = true
        generator.generate(for: trimmed)
    }

    private func saveAttempt(sentence: String, result: PracticeFeedback) {
        let attempt = PracticeAttempt(
            sentence: sentence,
            isCorrect: result.isCorrect,
            feedback: result.feedback,
            correctedSentences: result.correctedSentences,
            item: item
        )
        modelContext.insert(attempt)
        item.practiceAttempts.append(attempt)
    }

    private func deleteAttempt(_ attempt: PracticeAttempt) {
        modelContext.delete(attempt)
    }

    private func reset() {
        hasSubmitted = false
        sentence = ""
    }
}

#Preview {
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon")
    item.meanings = [
        Meaning(
            definition: "an arrangement to have something held for you in advance",
            partOfSpeech: "noun",
            order: 0,
            item: item
        )
    ]
    return NavigationStack {
        PracticeWordView(item: item)
    }
}
