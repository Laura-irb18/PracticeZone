import Foundation
import FoundationModels
import Observation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class VocabularyItemEditorViewModel {
    var word = ""
    var meaning = MeaningDraft()

    var canSave: Bool {
        !trimmed(word).isEmpty && !trimmed(meaning.definition).isEmpty
    }

    private let maxExamples = 3

    var canAddExample: Bool {
        meaning.examples.count < maxExamples
    }

    func addExample() {
        guard canAddExample else { return }
        meaning.examples.append(ExampleDraft())
    }

    func removeExample(_ example: ExampleDraft) {
        meaning.examples.removeAll { $0.id == example.id }
    }

    private(set) var isGeneratingMeaning = false
    private(set) var didGenerateMeaning = false
    var generationError: Error?

    var canGenerateMeaning: Bool {
        !trimmed(word).isEmpty
    }

    enum MeaningStep {
        case needsDefinition
        case needsTranslation
        case complete
    }

    var meaningStep: MeaningStep {
        if trimmed(meaning.definition).isEmpty {
            .needsDefinition
        } else if trimmed(meaning.translation).isEmpty {
            .needsTranslation
        } else {
            .complete
        }
    }

    private var nextMeaningSession = makeMeaningSession()

    func prewarmMeaningSession() {
        nextMeaningSession.prewarm()
    }

    func generateMeaning() async {
        let word = trimmed(word)
        guard !word.isEmpty, !isGeneratingMeaning else { return }
        isGeneratingMeaning = true
        generationError = nil
        defer { isGeneratingMeaning = false }

        // A new session per request, so earlier generations don't leak into this one.
        // Use the prewarmed session, and prepare a fresh one for the next request.
        let session = nextMeaningSession
        nextMeaningSession = Self.makeMeaningSession()
        let definition = trimmed(meaning.definition)
        do {
            if definition.isEmpty {
                let stream = session.streamResponse(
                    to: "Describe the most common sense of the English phrasal verb or word \"\(word)\".",
                    generating: MeaningSuggestion.self,
                    options: GenerationOptions(samplingMode: .greedy)
                )
                for try await partial in stream {
                    withAnimation {
                        if let definition = partial.content.definition {
                            meaning.definition = definition
                        }
                        if let translation = partial.content.translation {
                            meaning.translation = translation
                        }
                        if let partOfSpeech = partial.content.partOfSpeech {
                            meaning.partOfSpeech = partOfSpeech
                        }
                    }
                }
            } else {
                // The definition was typed by the user, so keep it and only fill in the rest.
                let stream = session.streamResponse(
                    to: """
                        English phrasal verb or word: "\(word)"
                        Sense: \(definition)
                        Give the Spanish equivalent of the word in exactly this sense, and its part of speech.
                        """,
                    generating: MeaningCompletion.self,
                    options: GenerationOptions(samplingMode: .greedy)
                )
                for try await partial in stream {
                    withAnimation {
                        if let translation = partial.content.translation {
                            meaning.translation = translation
                        }
                        if let partOfSpeech = partial.content.partOfSpeech {
                            meaning.partOfSpeech = partOfSpeech
                        }
                    }
                }
            }
            didGenerateMeaning = true
        } catch {
            generationError = error
        }
    }

    /// Clears the meaning and generates a new one from scratch. Examples are kept.
    func regenerateMeaning() async {
        guard !isGeneratingMeaning else { return }
        meaning.definition = ""
        meaning.translation = ""
        meaning.partOfSpeech = nil
        didGenerateMeaning = false
        await generateMeaning()
    }

    var saveError: Error?

    /// Returns whether the word was saved, so the view only closes on success.
    func save(to group: WordGroup, in modelContext: ModelContext) -> Bool {
        guard canSave else { return false }
        let item = VocabularyItem(word: trimmed(word), friendlyPronunciation: "", wordGroup: group)
        let newMeaning = Meaning(
            definition: trimmed(meaning.definition),
            translation: trimmed(meaning.translation),
            partOfSpeech: (meaning.partOfSpeech ?? .other).label,
            order: 0,
            item: item
        )
        let filledExamples = meaning.examples.filter { !trimmed($0.text).isEmpty }
        for (index, draft) in filledExamples.enumerated() {
            newMeaning.examples.append(Example(
                text: trimmed(draft.text),
                translation: trimmed(draft.translation),
                order: index,
                meaning: newMeaning
            ))
        }
        item.meanings.append(newMeaning)
        modelContext.insert(item)
        group.items.append(item)
        do {
            try modelContext.save()
            return true
        } catch {
            // Undo the insert so a retry doesn't create a duplicate.
            modelContext.delete(item)
            saveError = error
            return false
        }
    }

    private static func makeMeaningSession() -> LanguageModelSession {
        LanguageModelSession(instructions: """
            You are an English vocabulary tutor for Spanish-speaking learners. \
            When the word is a phrasal verb or an expression of several words, \
            describe the whole expression, never the meaning of its first word alone.
            """)
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
