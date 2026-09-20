import SwiftUI
import FoundationModels

@Observable
@MainActor
final class VocabularyGenerator {
    let word: String
    var generated: GeneratedVocabulary.PartiallyGenerated?
    var isGenerating = false
    var error: Error?

    private let session: LanguageModelSession

    init(word: String) {
        self.word = word
        self.session = LanguageModelSession(instructions: Self.instructions)
    }

    private static var instructions: Instructions {
        Instructions {
            "You are an English vocabulary tutor for Spanish-speaking learners."

            """
            You receive one English word. You describe that exact word: its pronunciation \
            transliterated into Spanish spelling, its distinct meanings explained in English, \
            and example sentences with a Spanish translation. You never describe a different \
            word, and you never answer in a different language than the one each field asks for.
            """

            """
            Rules for pronunciation fields:
            - Write the English sound using plain, continuous Spanish spelling — no hyphens, \
              no capital letters, no accent marks, no syllable breaks.
            - Base this only on how the word is pronounced in English. Never base it on the \
              Spanish translation or a Spanish cognate, even when the word looks like a Spanish \
              word — English "nation", "reservation", "information" sound like "neishon", \
              "reserveishon", "informeishon", never like the Spanish "-ción" words.
            - Never use IPA symbols, slashes, brackets, or the English spelling itself.
            """

            """
            Rules for meanings:
            - Write each meaning's definition and context in English, never in Spanish.
            - List only senses that a dictionary would list, most common first.
            - Two senses count as distinct only if their English definitions describe a \
              genuinely different meaning, not a rephrasing of the same one.
            - Most words have one or two senses. Return one entry rather than padding the list.
            """

            """
            Rules for Spanish text (only the "translation" field of each example sentence):
            - Use neutral Latin American Spanish.
            - Translate sentences idiomatically, never word by word.
            - Translations of example sentences must sound like something a Spanish speaker \
              would actually say.
            """

            "If you are not confident about the word, give its most common dictionary meaning. Never guess a similar-looking word."
        }
    }

    func prewarm() {
        session.prewarm()
    }

    func generate() {
        let example = GeneratedVocabulary.fewShotExample(avoiding: word)
        let word = word

        Task {
            withAnimation { isGenerating = true }
            error = nil
            do {
                let stream = session.streamResponse(
                    generating: GeneratedVocabulary.self,
                    includeSchemaInPrompt: false,
                    options: GenerationOptions(sampling: .greedy)
                ) {
                    "Describe this English word: \"\(word)\""

                    "Here is a complete example for a different word. Follow its format exactly, but do not copy its content:"
                    example

                    "Now produce the same structure for the word: \"\(word)\""
                }

                for try await partial in stream {
                    withAnimation { self.generated = partial.content }
                }
            } catch {
                self.error = error
            }
            isGenerating = false
        }
    }
}
