import SwiftUI
import SwiftData

struct WordDetailView: View {
    let item: VocabularyItem

    @Environment(\.aiStatus) private var aiStatus

    @State private var isPracticing = false
    @State private var isEditing = false

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 8) {
                DetailHeader(
                    iconName: item.wordGroup?.iconName ?? "text.book.closed",
                    color: item.wordGroup?.color.color ?? .accentColor
                ) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(item.word)
                                .font(.title.bold())
                            SpeakButton(text: item.word)
                                .font(.title3)
                        }
                        if !item.friendlyPronunciation.isEmpty {
                            Text(item.friendlyPronunciation)
                                .foregroundStyle(.secondary)
                        }
                        if let group = item.wordGroup {
                            Text(group.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }
                    }
                } details: {
                    Text(details)
                } action: {
                }
                VStack(spacing: 8) {
                    CompactActionButton(title: "Practice", systemImage: "target") {
                        isPracticing = true
                    }
                    .disabled(!aiStatus.isAvailable)
                    if !aiStatus.isAvailable {
                        AIUnavailableNote(message: aiStatus.practiceMessage)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

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

    /// Its parts of speech, without repeats, and how many meanings it has: "noun · 2 meanings".
    private var details: String {
        var partsOfSpeech: [String] = []
        for meaning in item.sortedMeanings where !partsOfSpeech.contains(meaning.partOfSpeech) {
            partsOfSpeech.append(meaning.partOfSpeech)
        }
        let meaningCount = item.meanings.count == 1 ? "1 meaning" : "\(item.meanings.count) meanings"
        return (partsOfSpeech + [meaningCount]).joined(separator: " · ")
    }
}

#Preview {
    let group = WordGroup(name: "Travel", iconName: "airplane")
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon", wordGroup: group)
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
