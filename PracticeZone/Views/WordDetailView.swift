import SwiftUI
import SwiftData

/// Detail of a saved word, sharing the exact layout used while a word is being generated.
/// The pronunciation field is manual — Foundation Models no longer generates it.
struct WordDetailView: View {
    @Bindable var item: VocabularyItem
    @Environment(\.modelContext) private var modelContext
    @State private var isAddingMeaning = false
    @State private var editingMeaning: Meaning?

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

            VStack(alignment: .leading, spacing: 12) {
                Text("Meanings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(Array(item.sortedMeanings.enumerated()), id: \.element.id) { index, meaning in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            if item.meanings.count > 1 {
                                Button {
                                    MeaningEditor.makePrimary(meaning, in: item)
                                } label: {
                                    Image(systemName: index == 0 ? "star.fill" : "star")
                                        .foregroundStyle(index == 0 ? .yellow : .secondary)
                                }
                                .buttonStyle(.borderless)
                                .accessibilityLabel(index == 0 ? "Main meaning" : "Mark as main meaning")
                            }
                            MeaningRow(
                                definition: meaning.definition,
                                partOfSpeech: meaning.partOfSpeech
                            )
                            Spacer(minLength: 0)
                            Menu {
                                Button("Edit", systemImage: "pencil") {
                                    editingMeaning = meaning
                                }
                                if item.meanings.count > 1 {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        MeaningEditor.delete(meaning, from: item, in: modelContext)
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("Meaning options")
                        }
                        ForEach(meaning.sortedExamples) { example in
                            ExampleRow(text: example.text, translation: example.translation)
                        }
                        .padding(.leading)
                    }
                }
                Button("Add Meaning", systemImage: "plus") {
                    isAddingMeaning = true
                }
                .buttonStyle(.borderless)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $isAddingMeaning) {
            MeaningEditSheet(title: "New Meaning", initialDefinition: "") { definition in
                MeaningEditor.add(definition: definition, to: item)
            }
        }
        .sheet(item: $editingMeaning) { meaning in
            MeaningEditSheet(title: "Edit Meaning", initialDefinition: meaning.definition) { definition in
                MeaningEditor.update(meaning, definition: definition)
            }
        }
    }
}

#Preview {
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon")
    let booking = Meaning(
        definition: "an arrangement to have something held for you in advance",
        partOfSpeech: "noun",
        order: 0,
        item: item
    )
    booking.examples = [
        Example(
            text: "We made a reservation for dinner at eight.",
            translation: "Hicimos una reserva para cenar a las ocho.",
            order: 0,
            meaning: booking
        )
    ]
    item.meanings = [
        booking,
        Meaning(
            definition: "a doubt about whether something is right",
            partOfSpeech: "noun",
            order: 1,
            item: item
        )
    ]
    return WordDetailView(item: item)
        .padding()
}
