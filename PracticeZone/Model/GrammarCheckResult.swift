import FoundationModels

@Generable
struct GrammarCheckResult {

    @Guide(description: "Name the grammar or spelling mistake in the sentence, or \"none\" if it is grammatically correct English. Ignore capitalization and punctuation. If unsure, write \"none\".")
    var mistake: String

    @Guide(description: """
        One or two corrected versions of the sentence. If there was a mistake, give the \
        corrected sentence as the first entry; add a second entry only when there is another, \
        genuinely different and equally natural way to fix it — never a trivial rewording of \
        the same fix. If there was no mistake, return exactly one entry repeating the sentence \
        unchanged.
        """, .minimumCount(1), .maximumCount(2))
    var correctedSentences: [String]
}

extension GrammarCheckResult {

    static let exampleCorrect = GrammarCheckResult(
        mistake: "none",
        correctedSentences: ["There was a long delay before the train arrived."]
    )

    static let exampleMistake = GrammarCheckResult(
        mistake: "\"My brother go\" should be \"My brother goes\".",
        correctedSentences: ["My brother goes to the market every morning."]
    )

    static let exampleTwoCorrections = GrammarCheckResult(
        mistake: "\"I are exciting for the trip\" should be \"I am excited...\".",
        correctedSentences: [
            "I am excited for the trip.",
            "I am excited about the trip."
        ]
    )
}
