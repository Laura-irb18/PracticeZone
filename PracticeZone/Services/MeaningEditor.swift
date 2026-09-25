import Foundation
import SwiftData

/// Edits a word's meanings: add, rewrite, delete and choose the main one.
/// The main meaning is the one with `order == 0`, which is what `primaryMeaning`
/// (and so multiple-choice exam questions) uses.
enum MeaningEditor {
    static func add(definition: String, to item: VocabularyItem) {
        let trimmed = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let nextOrder = (item.meanings.map(\.order).max() ?? -1) + 1
        let meaning = Meaning(definition: trimmed, partOfSpeech: "", order: nextOrder, item: item)
        item.meanings.append(meaning)
    }

    static func update(_ meaning: Meaning, definition: String) {
        let trimmed = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        meaning.definition = trimmed
    }

    /// Moves `meaning` to the top; the rest keep their relative order after it.
    static func makePrimary(_ meaning: Meaning, in item: VocabularyItem) {
        let others = item.sortedMeanings.filter { $0 != meaning }
        meaning.order = 0
        for (index, other) in others.enumerated() {
            other.order = index + 1
        }
    }

    /// A word always keeps at least one meaning, otherwise it drops out of exams.
    static func delete(_ meaning: Meaning, from item: VocabularyItem, in modelContext: ModelContext) {
        guard item.meanings.count > 1 else { return }
        item.meanings.removeAll { $0 == meaning }
        modelContext.delete(meaning)
    }
}
