import SwiftUI

struct ProductionQuestionView: View {
    let word: String
    let onResult: (String, PracticeFeedback) -> Void
    let onSkip: (String) -> Void
    let onSkipQuestion: () -> Void

    @State private var sentence = ""
    @State private var generator: PracticeFeedbackGenerator?
    @State private var isConfirmingSkip = false
    @AccessibilityFocusState private var isPromptFocused: Bool
    @AccessibilityFocusState private var isErrorFocused: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                VStack(alignment: .leading, spacing: 6) {
                    // At accessibility sizes the counter goes under the hint, so the hint keeps the full width.
                    let layout = dynamicTypeSize.isAccessibilitySize
                        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                        : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
                    layout {
                        Text("Use \"\(word)\" with the meaning you studied. AI only checks that your sentence is well written. It can make mistakes.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(trimmedSentence.count)/\(PracticeFeedbackGenerator.maxSentenceLength)")
                            .monospacedDigit()
                            .foregroundStyle(isTooLong ? .red : .secondary)
                            .accessibilityLabel("\(trimmedSentence.count) of \(PracticeFeedbackGenerator.maxSentenceLength) characters")
                    }
                    // Says why Submit is off, not only with the red counter (HIG: more than color alone).
                    if isTooLong {
                        Label {
                            Text("^[\(trimmedSentence.count - PracticeFeedbackGenerator.maxSentenceLength) character](inflect: true) over the limit")
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            if let errorMessage = generator?.errorMessage {
                Section {
                    Label {
                        Text(errorMessage)
                    } icon: {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.red)
                    }
                    .accessibilityFocused($isErrorFocused)
                } footer: {
                    Text("Skipping counts as incorrect.")
                }
            }
        }
        .safeAreaBar(edge: .top) {
            Text("Write a sentence using \"\(word)\"")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($isPromptFocused)
        }
        .animation(.smooth, value: generator?.isGenerating)
        .safeAreaBar(edge: .bottom) {
            bottomBar
        }
        .task {
            guard generator == nil else { return }
            let newGenerator = PracticeFeedbackGenerator()
            generator = newGenerator
            newGenerator.prewarm()
        }
        .onChange(of: generator?.isGenerating) { _, isGenerating in
            if isGenerating == true {
                AccessibilityNotification.Announcement(String(localized: "Checking your sentence")).post()
            }
            guard isGenerating == false, let generator else { return }
            if generator.error != nil {
                isErrorFocused = true
                return
            }
            guard let result = generator.result else { return }
            onResult(trimmedSentence, result)
        }
        .onAppear {
            // VoiceOver starts each new question at its prompt instead of staying on Submit.
            isPromptFocused = true
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

            Button {
                isConfirmingSkip = true
            } label: {
                Text("Skip Question")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .disabled(isChecking)
            .confirmationDialog("Skip Question?", isPresented: $isConfirmingSkip, titleVisibility: .visible) {
                Button("Skip Question", role: .destructive) {
                    if hasError {
                        onSkip(trimmedSentence)
                    } else {
                        onSkipQuestion()
                    }
                }
            } message: {
                Text("It counts as incorrect, and you can't go back to it.")
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
        onSkip: { _ in },
        onSkipQuestion: {}
    )
}
