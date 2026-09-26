import SwiftUI
import FoundationModels

@Observable
@MainActor
final class PracticeFeedbackGenerator {
    /// Longest sentence a learner can submit. The corrected sentence must fit in the
    /// response cap, and one practice sentence never needs more.
    static let maxSentenceLength = 200

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

    // Replaced with a fresh session on every answer, so one attempt's transcript
    // can't bias the next one.
    private var session: LanguageModelSession
    private var task: Task<Void, Never>?

    init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
        self.session = LanguageModelSession(instructions: Self.instructions)
    }

    private static var instructions: Instructions {
        Instructions {
            """
            You are an English teacher. Check the student's sentence for grammar and \
            spelling mistakes only. Give the corrected sentence, or the same sentence if \
            it is correct.
            """
        }
    }

    func prewarm() {
        session.prewarm()
    }

    func generate(for sentence: String) {
        task?.cancel()
        result = nil
        error = nil
        let session = session
        self.session = LanguageModelSession(instructions: Self.instructions)

        task = Task {
            isGenerating = true
            do {
                let response = try await session.respond(
                    generating: GrammarCheckResult.self,
                    // The cap turns a runaway generation into an error instead of a hang.
                    options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 200)
                ) {
                    sentence
                }
                result = PracticeFeedback(sentence: sentence, grammar: response.content)
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
