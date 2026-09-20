import SwiftUI

/// Read-only detail of a saved word, sharing the exact layout used while a word is being generated.
struct WordDetailView: View {
    let item: VocabularyItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(item.word)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                SpeakButton(text: item.word)
                    .font(.title2)
            }

            if !item.friendlyPronunciation.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pronunciation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.friendlyPronunciation)
                        .font(.title3)
                }
            }

            if !item.sortedMeanings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Meanings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(item.sortedMeanings) { meaning in
                        MeaningRow(
                            definition: meaning.definition,
                            partOfSpeech: meaning.partOfSpeech,
                            context: meaning.context
                        )
                    }
                }
            }

            if !item.examples.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Examples")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(item.examples) { example in
                        ExampleRow(text: example.text, translation: example.translation)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
