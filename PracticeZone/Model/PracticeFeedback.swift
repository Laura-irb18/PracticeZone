import Foundation

struct PracticeFeedback {
    let isCorrect: Bool
    let feedback: String
    let correctedSentences: [String]

    init(word: String, sentence: String, grammar: GrammarCheckResult, meaning: MeaningCheckResult) {
        let corrected = grammar.correctedSentence.trimmingCharacters(in: .whitespacesAndNewlines)
        // Changes in case or punctuation only ("Last summer, we…") don't count as mistakes.
        let grammarOK = corrected.isEmpty || Self.comparable(corrected) == Self.comparable(sentence)
        self.isCorrect = grammarOK && meaning.isCorrect
        self.correctedSentences = grammarOK ? [] : [corrected]

        switch (grammarOK, meaning.isCorrect) {
        case (true, true):
            self.feedback = "Well done — \"\(word)\" is used correctly and the sentence reads naturally."
        case (false, true):
            self.feedback = "Good use of \"\(word)\" — check the corrected sentence below."
        case (true, false):
            self.feedback = "Grammar is fine, but check the meaning: \(meaning.senseUsed)"
        case (false, false):
            self.feedback = "Two things to fix: check the corrected sentence below. Also, \(meaning.senseUsed)"
        }
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
