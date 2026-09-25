import SwiftUI
import SwiftData

struct WordDetailView: View {
    let item: VocabularyItem

    @Environment(\.aiStatus) private var aiStatus

    @State private var isPracticing = false
    @State private var isEditing = false

    var body: some View {
        List {
            Section {
                WordDetailHeader(word: item.word, friendlyPronunciation: item.friendlyPronunciation)
            }

            ForEach(Array(item.sortedMeanings.enumerated()), id: \.element.id) { index, meaning in
                Section("Meaning \(index + 1)") {
                    MeaningRow(
                        definition: meaning.definition,
                        translation: meaning.translation,
                        partOfSpeech: meaning.partOfSpeech
                    )
                    ForEach(meaning.sortedExamples) { example in
                        ExampleRow(text: example.text, translation: example.translation)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if !aiStatus.isAvailable {
                    AIUnavailableNote(message: aiStatus.practiceMessage)
                }
                Button {
                    isPracticing = true
                } label: {
                    Text("Practice")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!aiStatus.isAvailable)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isPracticing) {
            PracticeWordView(item: item)
        }
        .sheet(isPresented: $isEditing) {
            VocabularyItemEditorSheet(group: nil, item: item)
        }
    }
}

#Preview {
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon")
    let booking = Meaning(
        definition: "an arrangement to have something held for you in advance",
        translation: "reserva",
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
            translation: "reserva, duda",
            partOfSpeech: "noun",
            order: 1,
            item: item
        )
    ]
    return NavigationStack {
        WordDetailView(item: item)
    }
}
