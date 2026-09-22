import Foundation

/// A single exam question, either multiple choice (definition → word) or production
/// (write a sentence using the word, graded by `PracticeFeedbackGenerator`).
struct ExamQuestion: Identifiable {
    enum Kind {
        case multipleChoice(options: [String])
        case production
    }

    let id = UUID()

    /// The word's own item, kept so the exam can mark it as examined once the attempt finishes.
    let item: VocabularyItem

    let word: String

    /// For `.multipleChoice`, the definition shown as the question prompt.
    /// For `.production`, the meaning passed to `PracticeFeedbackGenerator` as grading context.
    let meaning: String

    let kind: Kind
}
