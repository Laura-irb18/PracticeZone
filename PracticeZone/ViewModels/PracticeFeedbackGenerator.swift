import SwiftUI
import FoundationModels

@Observable
@MainActor
final class PracticeFeedbackGenerator {
    let word: String
    let meaning: String

    var result: PracticeFeedback?
    var isGenerating = false
    var error: Error?

    private let grammarSession: LanguageModelSession
    private let meaningSession: LanguageModelSession

    init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
        self.grammarSession = LanguageModelSession(instructions: Self.grammarInstructions)
        self.meaningSession = LanguageModelSession(instructions: Self.meaningInstructions(word: word, meaning: meaning))
    }

    private static var grammarInstructions: Instructions {
        Instructions {
            """
            You check English sentences written by a language learner for grammar and \
            spelling mistakes only. Ignore meaning, ignore capitalization, ignore punctuation. \
            If you are not sure there is a mistake, say there is none.
            """
        }
    }

    private static func meaningInstructions(word: String, meaning: String) -> Instructions {
        Instructions {
            """
            You judge whether the English word "\(word)" is used with a natural, correct \
            common meaning in a sentence written by a language learner.
            """

            "One example meaning of \"\(word)\" is: \(meaning)"

            """
            That is only an example sense to help you — words often have other common, \
            equally correct meanings, and using one of those is still correct. Only say it is \
            incorrect when the word is used with a meaning that isn't a real common English \
            sense at all.
            """
        }
    }

    func prewarm() {
        grammarSession.prewarm()
        meaningSession.prewarm()
    }

    func generate(for sentence: String) {
        result = nil
        error = nil

        Task {
            isGenerating = true
            do {
                async let grammarResponse = grammarSession.respond(
                    generating: GrammarCheckResult.self,
                    options: GenerationOptions(sampling: .greedy)
                ) {
                    "Here are two examples of the output. Follow their style, but do not copy their content:"
                    GrammarCheckResult.exampleCorrect
                    GrammarCheckResult.exampleMistake

                    "Sentence: \"\(sentence)\""
                }

                async let meaningResponse = meaningSession.respond(
                    generating: MeaningCheckResult.self,
                    options: GenerationOptions(sampling: .greedy)
                ) {
                    "Here are three examples of the output. Follow their style, but do not copy their content:"
                    MeaningCheckResult.exampleGivenSense
                    MeaningCheckResult.exampleOtherSense
                    MeaningCheckResult.exampleWrongSense

                    "Sentence: \"\(sentence)\""
                }

                let (grammar, meaningResult) = try await (grammarResponse.content, meaningResponse.content)
                result = PracticeFeedback(word: word, sentence: sentence, grammar: grammar, meaning: meaningResult)
            } catch {
                self.error = error
            }
            isGenerating = false
        }
    }
}
