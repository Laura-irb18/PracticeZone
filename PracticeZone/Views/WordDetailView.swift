import SwiftUI

/// Detail of a saved word, sharing the exact layout used while a word is being generated.
/// The pronunciation field is manual — Foundation Models no longer generates it.
struct WordDetailView: View {
    @Bindable var item: VocabularyItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(item.word)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                SpeakButton(text: item.word)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Pronunciation")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Add your own pronunciation", text: $item.friendlyPronunciation)
                    .font(.title3)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
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

#Preview {
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon")
    item.meanings = [
        Meaning(
            definition: "an arrangement to have something held for you in advance",
            partOfSpeech: "noun",
            context: "used when booking a table, room, or seat",
            order: 0,
            item: item
        )
    ]
    item.examples = [
        Example(
            text: "We made a reservation for dinner at eight.",
            translation: "Hicimos una reserva para cenar a las ocho.",
            item: item
        )
    ]
    return WordDetailView(item: item)
        .padding()
}
