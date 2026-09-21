import Foundation

struct PracticeFeedback {
    let isCorrect: Bool
    let feedback: String
    let correctedSentences: [String]

    init(word: String, sentence: String, grammar: GrammarCheckResult, meaning: MeaningCheckResult) {
        let grammarOK = grammar.mistake.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "none"
        self.isCorrect = grammarOK && meaning.isCorrect
        self.correctedSentences = grammarOK ? [] : Self.dedupedCorrections(grammar.correctedSentences)

        switch (grammarOK, meaning.isCorrect) {
        case (true, true):
            self.feedback = "Well done — \"\(word)\" is used correctly and the sentence reads naturally."
        case (false, true):
            self.feedback = "Good use of \"\(word)\" — just fix the grammar: \(grammar.mistake)"
        case (true, false):
            self.feedback = "Grammar is fine, but check the meaning: \(meaning.senseUsed)"
        case (false, false):
            self.feedback = "Two things to fix: \(grammar.mistake) Also, \(meaning.senseUsed)"
        }
    }

    private static func dedupedCorrections(_ sentences: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for raw in sentences {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "en"))
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(trimmed)
        }
        return result
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
