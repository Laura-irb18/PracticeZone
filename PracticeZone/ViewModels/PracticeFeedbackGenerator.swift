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

    /// What the person sees when a check fails. `nil` while there is no error.
    var errorMessage: String? {
        guard let error else { return nil }
        guard let languageError = error as? LanguageModelError else {
            return "Couldn't check your sentence. Try again."
        }
        switch languageError {
        case .guardrailViolation:
            return "This sentence can't be checked because it touches a sensitive topic. Try a different one."
        case .refusal:
            return "The model couldn't check this sentence. Try writing a different one."
        case .rateLimited, .timeout:
            return "The model is busy right now. Wait a moment and try again."
        case .contextSizeExceeded:
            return "This sentence is too long to check. Try a shorter one."
        case .unsupportedLanguageOrLocale:
            return "The on-device model doesn't support this language."
        default:
            return "Couldn't check your sentence. Try again."
        }
    }

    // Replaced with fresh sessions on every answer, so one attempt's transcript
    // can't bias the next one.
    private var grammarSession: LanguageModelSession
    private var meaningSession: LanguageModelSession
    private var task: Task<Void, Never>?

    init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
        self.grammarSession = LanguageModelSession(instructions: Self.grammarInstructions)
        self.meaningSession = LanguageModelSession(instructions: Self.meaningInstructions(word: word, meaning: meaning))
    }

    private func resetSessions() {
        grammarSession = LanguageModelSession(instructions: Self.grammarInstructions)
        meaningSession = LanguageModelSession(instructions: Self.meaningInstructions(word: word, meaning: meaning))
    }

    private static var grammarInstructions: Instructions {
        Instructions {
            """
            You are an English teacher. Check the student's sentence for grammar and \
            spelling mistakes only. Give the corrected sentence, or the same sentence if \
            it is correct.
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
        task?.cancel()
        result = nil
        error = nil
        let grammarSession = grammarSession
        let meaningSession = meaningSession
        resetSessions()

        task = Task {
            isGenerating = true
            do {
                async let grammarResponse = grammarSession.respond(
                    generating: GrammarCheckResult.self,
                    // The cap turns a runaway generation into an error instead of a hang.
                    options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 200)
                ) {
                    sentence
                }

                async let meaningResponse = meaningSession.respond(
                    generating: MeaningCheckResult.self,
                    options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 200)
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
                // A cancelled check (the user left the question) isn't an error to show.
                if !Task.isCancelled, !(error is CancellationError) {
                    self.error = error
                }
            }
            isGenerating = false
            prewarm()
        }
    }

    func cancel() {
        task?.cancel()
    }
}
