import Foundation
import SwiftData
import Observation

/// Shapes a freshly generated `GeneratedVocabulary` into a saved `VocabularyItem`:
/// validating the word matches and deduping repeated meanings before inserting into SwiftData.
@Observable
@MainActor
final class VocabularyItemSaver {
    var saveError: String?

    private struct MeaningEntry {
        let definition: String
        let partOfSpeech: String
        let context: String
    }

    /// Attempts to save the generated vocabulary for `word` into `group`. Returns
    /// `true` on success; on failure, `saveError` is set and `false` is returned.
    func save(
        generated: GeneratedVocabulary.PartiallyGenerated,
        word: String,
        group: WordGroup,
        modelContext: ModelContext
    ) -> Bool {
        if let generatedWord = generated.word,
           generatedWord.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != word.lowercased() {
            saveError = "The generated details didn't match \"\(word)\". Try again."
            return false
        }

        let meaningEntries = dedupedMeanings(from: generated.meanings ?? [])
        guard !meaningEntries.isEmpty else {
            saveError = "Couldn't generate a meaning for \"\(word)\". Try again."
            return false
        }

        let item = VocabularyItem(
            word: word,
            friendlyPronunciation: "",
            wordGroup: group
        )

        for (index, entry) in meaningEntries.enumerated() {
            let meaning = Meaning(
                definition: entry.definition,
                partOfSpeech: entry.partOfSpeech,
                context: entry.context,
                order: index,
                item: item
            )
            item.meanings.append(meaning)
        }

        for generatedExample in generated.examples ?? [] {
            let example = Example(
                text: generatedExample.text ?? "",
                translation: generatedExample.translation ?? "",
                item: item
            )
            item.examples.append(example)
        }

        modelContext.insert(item)
        group.items.append(item)
        return true
    }

    private func dedupedMeanings(from generated: [GeneratedMeaning.PartiallyGenerated]) -> [MeaningEntry] {
        var seen = Set<String>()
        var result: [MeaningEntry] = []
        for entry in generated {
            guard let definition = entry.definition?.trimmingCharacters(in: .whitespacesAndNewlines), !definition.isEmpty else { continue }
            let key = definition.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en"))
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(MeaningEntry(
                definition: definition,
                partOfSpeech: entry.partOfSpeech.map(String.init(describing:)) ?? "other",
                context: entry.context ?? ""
            ))
        }
        return result
    }
}
