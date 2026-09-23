import SwiftUI

struct ProductionQuestionView: View {
    let word: String
    let meaning: String
    let onResult: (String, PracticeFeedback) -> Void

    @State private var sentence = ""
    @State private var generator: PracticeFeedbackGenerator?
    @State private var hasSubmitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Write a sentence using \"\(word)\"")
                .font(.headline)

            TextField("Your sentence", text: $sentence, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .disabled(generator?.isGenerating == true || hasSubmitted)

            if let error = generator?.error {
                Label(error.localizedDescription, systemImage: "xmark.circle")
                    .foregroundStyle(.red)
            }

            if generator?.isGenerating == true {
                ProgressView()
            } else if !hasSubmitted {
                Button("Submit") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .task {
            guard generator == nil else { return }
            let newGenerator = PracticeFeedbackGenerator(word: word, meaning: meaning)
            generator = newGenerator
            newGenerator.prewarm()
        }
        .onChange(of: generator?.isGenerating) { _, isGenerating in
            guard isGenerating == false,
                  let generator,
                  generator.error == nil,
                  let result = generator.result else { return }
            onResult(sentence.trimmingCharacters(in: .whitespacesAndNewlines), result)
        }
    }

    private func submit() {
        let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let generator else { return }
        hasSubmitted = true
        generator.generate(for: trimmed)
    }
}

#Preview {
    ProductionQuestionView(
        word: "reservation",
        meaning: "an arrangement to have something held for you in advance"
    ) { _, _ in }
    .padding()
}
