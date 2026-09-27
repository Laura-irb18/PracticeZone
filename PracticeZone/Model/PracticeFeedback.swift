import Foundation

struct PracticeFeedback {
    let isCorrect: Bool
    let feedback: String
    let correctedSentences: [String]

    init(sentence: String, grammar: GrammarCheckResult) {
        let corrected = grammar.correctedSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        // Changes in case or punctuation only ("Last summer, we…") don't count as mistakes.
        self.isCorrect = corrected.isEmpty || Self.comparable(corrected) == Self.comparable(sentence)
        self.correctedSentences = isCorrect ? [] : [corrected]
        self.feedback = isCorrect
            ? "Well done — no grammar mistakes found."
            : "Check the corrected sentence below."
    }

    /// Lowercased, punctuation removed, whitespace collapsed.
    private static func comparable(_ text: String) -> String {
        let scalars = text.lowercased().unicodeScalars.filter { !CharacterSet.punctuationCharacters.contains($0) }
        return String(String.UnicodeScalarView(scalars))
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}

enum MotivationalPhrase {
    static func random(isCorrect: Bool) -> String {
        (isCorrect ? praise : encouragement).randomElement() ?? ""
    }

    private static let praise = [
        "You're doing great!", "Excellent work!", "Keep it up!", "You've got this!"
    ]

    private static let encouragement = [
        "Almost there.", "Good try, keep practicing.",
        "Every mistake gets you closer.", "Try again, you're on the right track."
    ]
}
