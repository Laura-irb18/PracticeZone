import SwiftUI
import FoundationModels

struct GeneratedWordDetailView: View {
    let word: String
    let generated: GeneratedVocabulary.PartiallyGenerated

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(word)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                SpeakButton(text: word)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Meanings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let meanings = generated.meanings, !meanings.isEmpty {
                    ForEach(Array(meanings.enumerated()), id: \.offset) { _, meaning in
                        MeaningRow(
                            definition: meaning.definition ?? "Generating...",
                            partOfSpeech: meaning.partOfSpeech.map(String.init(describing:)) ?? "",
                            context: meaning.context ?? ""
                        )
                    }
                } else {
                    Text("Generating...")
                        .font(.title3)
                }
            }

            if let examples = generated.examples, !examples.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Examples")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                        ExampleRow(
                            text: example.text ?? "Generating...",
                            translation: example.translation ?? ""
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GeneratedWordDetailView(
        word: GeneratedVocabulary.exampleForReservation.word,
        generated: GeneratedVocabulary.exampleForReservation.asPartiallyGenerated()
    )
    .padding()
}
