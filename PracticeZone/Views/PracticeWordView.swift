import SwiftUI
import SwiftData

struct PracticeWordView: View {
    let item: VocabularyItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var sentence = ""
    @State private var generator: PracticeFeedbackGenerator?
    @State private var hasSubmitted = false

    private var isTooLong: Bool {
        sentence.trimmingCharacters(in: .whitespacesAndNewlines).count > PracticeFeedbackGenerator.maxSentenceLength
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close) {
                            dismiss()
                        }
                    }
                }
        }
    }

    private var content: some View {
        Form {
            Section {
                WordDetailHeader(word: item.word, friendlyPronunciation: item.friendlyPronunciation)
            }

            Section {
                TextField("Write a sentence using \"\(item.word)\"", text: $sentence, axis: .vertical)
                    .disabled(generator?.isGenerating == true)
            } header: {
                Text("Your sentence")
            } footer: {
                HStack(alignment: .firstTextBaseline) {
                    Text("Use \"\(item.word)\" in an English sentence. AI feedback can make mistakes.")
                    Spacer()
                    Text("\(sentence.count)/\(PracticeFeedbackGenerator.maxSentenceLength)")
                        .monospacedDigit()
                        .foregroundStyle(isTooLong ? .red : .secondary)
                }
            }

            if hasSubmitted, let generator {
                if let errorMessage = generator.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "xmark.circle")
                            .foregroundStyle(.red)
                    }
                } else if let result = generator.result {
                    Section("Feedback") {
                        Label(
                            result.isCorrect ? "Correct" : "Needs work",
                            systemImage: result.isCorrect ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
                        )
                        .foregroundStyle(result.isCorrect ? .green : .orange)
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
                                Image(systemName: attempt.isCorrect ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .foregroundStyle(attempt.isCorrect ? .green : .orange)
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
        .animation(.smooth, value: generator?.isGenerating)
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

    private var bottomBar: some View {
        let isChecking = generator?.isGenerating == true
        let showsTryAgain = hasSubmitted && generator?.result != nil && !isChecking
        let hasSentence = !sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return BottomActionButton {
            if showsTryAgain {
                reset()
            } else {
                submit()
            }
        } label: {
            if isChecking {
                Label("Checking your sentence…", systemImage: "sparkles")
                    .symbolEffect(.breathe)
            } else if showsTryAgain {
                Text("Try Another Sentence")
            } else {
                Text("Check Sentence")
            }
        }
        .disabled(isChecking || (!showsTryAgain && (!hasSentence || isTooLong)))
        .padding(.horizontal)
        .padding(.bottom, 8)
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
    return PracticeWordView(item: item)
}
