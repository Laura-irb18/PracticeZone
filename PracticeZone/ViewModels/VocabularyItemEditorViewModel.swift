import Foundation
import FoundationModels
import Observation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class VocabularyItemEditorViewModel {
    var word = ""
    var friendlyPronunciation = ""
    var meanings = [MeaningDraft()]

    private let maxMeanings = 5
    private let maxExamples = 3

    private var item: VocabularyItem?

    var isEditing: Bool { item != nil }

    /// Fills the form with a saved word. `nil` leaves it empty, for a new word.
    func load(_ item: VocabularyItem?) {
        self.item = item
        guard let item else { return }
        word = item.word
        friendlyPronunciation = item.friendlyPronunciation
        meanings = item.sortedMeanings.map { meaning in
            MeaningDraft(
                definition: meaning.definition,
                translation: meaning.translation,
                partOfSpeech: PartOfSpeech(label: meaning.partOfSpeech),
                examples: meaning.sortedExamples.map {
                    ExampleDraft(text: $0.text, translation: $0.translation)
                }
            )
        }
        if meanings.isEmpty {
            meanings = [MeaningDraft()]
        }
    }

    var hasWord: Bool {
        !trimmed(word).isEmpty
    }

    var canSave: Bool {
        hasWord && generation == nil && meanings.allSatisfy { !trimmed($0.definition).isEmpty }
    }

    // MARK: Meanings

    var canAddMeaning: Bool {
        meanings.count < maxMeanings
    }

    func addMeaning() {
        guard canAddMeaning else { return }
        meanings.append(MeaningDraft())
    }

    func removeMeaning(_ meaning: MeaningDraft) {
        guard !isPrimary(meaning), generation == nil else { return }
        meanings.removeAll { $0.id == meaning.id }
    }

    func isPrimary(_ meaning: MeaningDraft) -> Bool {
        meaning.id == meanings.first?.id
    }

    func number(of meaning: MeaningDraft) -> Int {
        (meanings.firstIndex { $0.id == meaning.id } ?? 0) + 1
    }

    // MARK: Examples

    func canAddExample(to meaning: MeaningDraft) -> Bool {
        meaning.examples.count < maxExamples
    }

    func addExample(to meaning: MeaningDraft) {
        guard canAddExample(to: meaning) else { return }
        update(meaning.id) { $0.examples.append(ExampleDraft()) }
    }

    func removeExample(_ example: ExampleDraft, from meaning: MeaningDraft) {
        update(meaning.id) { $0.examples.removeAll { $0.id == example.id } }
    }

    // MARK: Generation

    enum MeaningStep {
        case needsDefinition
        case needsTranslation
        case complete
    }

    func step(for meaning: MeaningDraft) -> MeaningStep {
        if trimmed(meaning.definition).isEmpty {
            .needsDefinition
        } else if trimmed(meaning.translation).isEmpty {
            .needsTranslation
        } else {
            .complete
        }
    }

    /// What is being generated right now.
    enum GenerationTarget: Equatable {
        case meaning(MeaningDraft.ID)
        case translation(MeaningDraft.ID)
        case example(meaningID: MeaningDraft.ID, exampleID: ExampleDraft.ID)
    }

    private(set) var generation: GenerationTarget?
    private(set) var generationErrorTitle = ""
    private(set) var generationErrorMessage = ""
    var generationError: Error?

    private var generationTask: Task<Void, Never>?
    private var nextMeaningSession = makeMeaningSession()

    /// Whether one of this meaning's examples is being generated.
    func isGeneratingExample(in meaning: MeaningDraft) -> Bool {
        guard case .example(let meaningID, _) = generation else { return false }
        return meaningID == meaning.id
    }

    /// Whether a new generation can start: there is a word and nothing else is being generated.
    var canStartGeneration: Bool {
        hasWord && generation == nil
    }

    /// Stops the current generation. Whatever it had written is undone.
    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
    }

    /// A generation belongs to the word it started with, so changing the word stops it.
    /// Typing the first letter prewarms the session.
    func wordChanged(from oldValue: String, to newValue: String) {
        cancelGeneration()
        if oldValue.isEmpty && !newValue.isEmpty {
            nextMeaningSession.prewarm()
        }
    }

    /// Generates the first meaning from scratch: definition, translation and part of speech.
    func generateMeaning(_ meaning: MeaningDraft) {
        guard canStartGeneration, isPrimary(meaning) else { return }
        start(.meaning(meaning.id)) {
            await self.streamMeaning(meaning.id, varied: false)
        }
    }

    /// Replaces the first meaning with a new one.
    func regenerateMeaning(_ meaning: MeaningDraft) {
        guard canStartGeneration, isPrimary(meaning) else { return }
        start(.meaning(meaning.id)) {
            await self.streamMeaning(meaning.id, varied: true)
        }
    }

    /// Keeps the definition typed by the user and fills in the translation and part of speech.
    func translateMeaning(_ meaning: MeaningDraft) {
        guard canStartGeneration,
              let current = draft(meaning.id),
              !trimmed(current.definition).isEmpty else { return }
        start(.translation(meaning.id)) {
            await self.streamTranslation(meaning.id)
        }
    }

    /// Generates one example. It fills the first empty example, or adds a new one,
    /// so examples typed by the user are never replaced.
    func generateExample(for meaning: MeaningDraft) {
        guard canStartGeneration,
              let current = draft(meaning.id),
              !trimmed(current.definition).isEmpty else { return }
        if let empty = current.examples.first(where: { trimmed($0.text).isEmpty }) {
            start(.example(meaningID: meaning.id, exampleID: empty.id)) {
                await self.streamExample(empty.id, in: meaning.id, isNew: false)
            }
        } else if canAddExample(to: current) {
            let newExample = ExampleDraft()
            update(meaning.id) { $0.examples.append(newExample) }
            start(.example(meaningID: meaning.id, exampleID: newExample.id)) {
                await self.streamExample(newExample.id, in: meaning.id, isNew: true)
            }
        }
    }

    /// Replaces a generated example with a new sentence in the same place.
    func regenerateExample(_ example: ExampleDraft, in meaning: MeaningDraft) {
        guard canStartGeneration, example.isGenerated else { return }
        start(.example(meaningID: meaning.id, exampleID: example.id)) {
            await self.streamExample(example.id, in: meaning.id, isNew: false)
        }
    }

    /// Marks what is being generated right away, so a second tap can't start another request.
    private func start(_ target: GenerationTarget, _ work: @escaping () async -> Void) {
        generation = target
        generationError = nil
        generationTask = Task {
            await work()
        }
    }

    private func streamMeaning(_ id: MeaningDraft.ID, varied: Bool) async {
        defer { generation = nil }
        guard let previous = draft(id) else { return }
        let word = trimmed(word)
        update(id) { meaning in
            meaning.definition = ""
            meaning.translation = ""
            meaning.partOfSpeech = nil
            meaning.isGenerated = false
        }

        let session = takeMeaningSession()
        do {
            let stream = session.streamResponse(
                to: "Describe the most common sense of the English phrasal verb or word \"\(word)\".",
                generating: MeaningSuggestion.self,
                options: varied
                    ? GenerationOptions(samplingMode: .random(top: 5), temperature: 0.5)
                    : GenerationOptions(samplingMode: .greedy)
            )
            for try await partial in stream {
                try Task.checkCancellation()
                withAnimation {
                    update(id) { meaning in
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
            }
            try Task.checkCancellation()
            update(id) { $0.isGenerated = true }
        } catch {
            restore(id, from: previous)
            report(error, title: "Couldn't generate the meaning")
        }
    }

    private func streamTranslation(_ id: MeaningDraft.ID) async {
        defer { generation = nil }
        guard let previous = draft(id) else { return }
        let word = trimmed(word)

        let session = takeMeaningSession()
        do {
            let stream = session.streamResponse(
                to: """
                    English phrasal verb or word: "\(word)"
                    Sense: \(trimmed(previous.definition))
                    Give the Spanish equivalent of the word in exactly this sense, and its part of speech.
                    """,
                generating: MeaningCompletion.self,
                options: GenerationOptions(samplingMode: .greedy)
            )
            for try await partial in stream {
                try Task.checkCancellation()
                withAnimation {
                    update(id) { meaning in
                        if let translation = partial.content.translation {
                            meaning.translation = translation
                        }
                        if let partOfSpeech = partial.content.partOfSpeech {
                            meaning.partOfSpeech = partOfSpeech
                        }
                    }
                }
            }
            try Task.checkCancellation()
            update(id) { $0.isGenerated = true }
        } catch {
            restore(id, from: previous)
            report(error, title: "Couldn't translate the meaning")
        }
    }

    private func streamExample(_ exampleID: ExampleDraft.ID, in meaningID: MeaningDraft.ID, isNew: Bool) async {
        defer { generation = nil }
        guard let meaning = draft(meaningID),
              let previous = meaning.examples.first(where: { $0.id == exampleID }) else { return }
        let word = trimmed(word)

        let session = Self.makeExamplesSession()
        do {
            let stream = session.streamResponse(
                to: """
                    English phrasal verb or word: "\(word)"
                    Sense: \(trimmed(meaning.definition))
                    Write one sentence that uses "\(word)" with exactly this sense.
                    """,
                generating: ExampleSuggestion.self,
                // Some variety, so regenerating gives a new sentence, while staying with likely words.
                options: GenerationOptions(samplingMode: .random(top: 5), temperature: 0.5)
            )
            for try await partial in stream {
                try Task.checkCancellation()
                withAnimation {
                    updateExample(exampleID, in: meaningID) { example in
                        if let text = partial.content.text {
                            example.text = text
                        }
                        if let translation = partial.content.translation {
                            example.translation = translation
                        }
                    }
                }
            }
            try Task.checkCancellation()
            updateExample(exampleID, in: meaningID) { $0.isGenerated = true }
        } catch {
            if isNew {
                update(meaningID) { $0.examples.removeAll { $0.id == exampleID } }
            } else {
                updateExample(exampleID, in: meaningID) { $0 = previous }
            }
            report(error, title: "Couldn't generate an example")
        }
    }

    /// Puts back the fields a meaning generation writes, so a failed or stopped one loses nothing.
    private func restore(_ id: MeaningDraft.ID, from previous: MeaningDraft) {
        update(id) { meaning in
            meaning.definition = previous.definition
            meaning.translation = previous.translation
            meaning.partOfSpeech = previous.partOfSpeech
            meaning.isGenerated = previous.isGenerated
        }
    }

    /// Stopping a generation isn't an error, so it doesn't show an alert.
    private func report(_ error: Error, title: String) {
        guard !Task.isCancelled, !(error is CancellationError) else { return }
        generationErrorTitle = title
        if let languageError = error as? LanguageModelError, case .unsupportedLanguageOrLocale = languageError {
            generationErrorMessage = "The on-device model doesn't support this language."
        } else {
            generationErrorMessage = error.localizedDescription
        }
        generationError = error
    }

    private func draft(_ id: MeaningDraft.ID) -> MeaningDraft? {
        meanings.first { $0.id == id }
    }

    // MARK: Saving

    var saveError: Error?

    /// Returns whether the word was saved, so the view only closes on success.
    func save(to group: WordGroup?, in modelContext: ModelContext) -> Bool {
        guard canSave else { return false }
        if let item {
            item.word = trimmed(word)
            item.friendlyPronunciation = trimmed(friendlyPronunciation)
            // Replaced instead of matched one by one: nothing else points to a meaning or an example.
            let oldMeanings = item.meanings
            item.meanings = makeMeanings(for: item)
            for meaning in oldMeanings {
                modelContext.delete(meaning)
            }
        } else {
            guard let group else { return false }
            let item = VocabularyItem(
                word: trimmed(word),
                friendlyPronunciation: trimmed(friendlyPronunciation),
                wordGroup: group
            )
            item.meanings = makeMeanings(for: item)
            modelContext.insert(item)
            group.items.append(item)
        }
        do {
            try modelContext.save()
            return true
        } catch {
            // Undo the pending changes so a retry starts from what is saved.
            modelContext.rollback()
            saveError = error
            return false
        }
    }

    private func makeMeanings(for item: VocabularyItem) -> [Meaning] {
        meanings.enumerated().map { order, draft in
            let meaning = Meaning(
                definition: trimmed(draft.definition),
                translation: trimmed(draft.translation),
                partOfSpeech: (draft.partOfSpeech ?? .other).label,
                order: order,
                item: item
            )
            let filledExamples = draft.examples.filter { !trimmed($0.text).isEmpty }
            meaning.examples = filledExamples.enumerated().map { index, example in
                Example(
                    text: trimmed(example.text),
                    translation: trimmed(example.translation),
                    order: index,
                    meaning: meaning
                )
            }
            return meaning
        }
    }

    /// Changes a meaning by its id, so the right one is updated even if the list changed meanwhile.
    private func update(_ id: MeaningDraft.ID, _ change: (inout MeaningDraft) -> Void) {
        guard let index = meanings.firstIndex(where: { $0.id == id }) else { return }
        change(&meanings[index])
    }

    private func updateExample(_ exampleID: ExampleDraft.ID, in meaningID: MeaningDraft.ID, _ change: (inout ExampleDraft) -> Void) {
        update(meaningID) { meaning in
            guard let index = meaning.examples.firstIndex(where: { $0.id == exampleID }) else { return }
            change(&meaning.examples[index])
        }
    }

    /// A new session per request, so earlier generations don't leak into this one.
    /// Uses the prewarmed session, and prepares a fresh one for the next request.
    private func takeMeaningSession() -> LanguageModelSession {
        let session = nextMeaningSession
        nextMeaningSession = Self.makeMeaningSession()
        return session
    }

    private static func makeMeaningSession() -> LanguageModelSession {
        LanguageModelSession(instructions: """
            You are an English vocabulary tutor for Spanish-speaking learners. \
            When the word is a phrasal verb or an expression of several words, \
            describe the whole expression, never the meaning of its first word alone.
            """)
    }

    private static func makeExamplesSession() -> LanguageModelSession {
        LanguageModelSession(instructions: """
            You are an English vocabulary tutor for Spanish-speaking learners. \
            You write example sentences that use an English word or phrasal verb with one specific sense, \
            each with a natural translation into neutral Latin American Spanish.
            """)
    }

    private func trimmed(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
