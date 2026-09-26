import SwiftUI

struct ProductionQuestionView: View {
    let word: String
    let onResult: (String, PracticeFeedback) -> Void
    let onSkip: (String) -> Void

    @State private var sentence = ""
    @State private var generator: PracticeFeedbackGenerator?

    private var trimmedSentence: String {
        sentence.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isTooLong: Bool {
        trimmedSentence.count > PracticeFeedbackGenerator.maxSentenceLength
    }

    var body: some View {
        Form {
            Section {
                TextField("Your sentence", text: $sentence, axis: .vertical)
                    .disabled(generator?.isGenerating == true)
            } footer: {
                HStack(alignment: .firstTextBaseline) {
                    Text("AI feedback can make mistakes.")
                    Spacer()
                    Text("\(sentence.count)/\(PracticeFeedbackGenerator.maxSentenceLength)")
                        .monospacedDigit()
                        .foregroundStyle(isTooLong ? .red : .secondary)
                }
            }

            if let errorMessage = generator?.errorMessage {
                Section {
                    Label(errorMessage, systemImage: "xmark.circle")
                        .foregroundStyle(.red)
                } footer: {
                    Text("Skipping counts as incorrect.")
                }
            }
        }
        .safeAreaInset(edge: .top) {
            Text("Write a sentence using \"\(word)\"")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .animation(.smooth, value: generator?.isGenerating)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .task {
            guard generator == nil else { return }
            let newGenerator = PracticeFeedbackGenerator()
            generator = newGenerator
            newGenerator.prewarm()
        }
        .onChange(of: generator?.isGenerating) { _, isGenerating in
            guard isGenerating == false,
                  let generator,
                  generator.error == nil,
                  let result = generator.result else { return }
            onResult(trimmedSentence, result)
        }
        .onDisappear {
            generator?.cancel()
        }
    }

    private var bottomBar: some View {
        let isChecking = generator?.isGenerating == true
        let hasError = generator?.error != nil

        return VStack(spacing: 8) {
            BottomActionButton {
                submit()
            } label: {
                if isChecking {
                    Label("Checking your sentence…", systemImage: "sparkles")
                        .symbolEffect(.breathe)
                } else {
                    Text(hasError ? "Try Again" : "Submit")
                }
            }
            .disabled(isChecking || trimmedSentence.isEmpty || isTooLong)

            if hasError && !isChecking {
                Button {
                    onSkip(trimmedSentence)
                } label: {
                    Text("Skip Question")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func submit() {
        guard !trimmedSentence.isEmpty, let generator else { return }
        generator.generate(for: trimmedSentence)
    }
}

#Preview {
    ProductionQuestionView(
        word: "reservation",
        onResult: { _, _ in },
        onSkip: { _ in }
    )
}
