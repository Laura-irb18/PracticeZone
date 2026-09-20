import FoundationModels

@Generable
struct GrammarCheckResult {

    @Guide(description: "Name the grammar or spelling mistake in the sentence, or \"none\" if it is grammatically correct English. Ignore capitalization and punctuation. If unsure, write \"none\".")
    var mistake: String

    @Guide(description: "The sentence corrected if there was a mistake. Repeat it unchanged if there was none.")
    var correctedSentence: String
}

extension GrammarCheckResult {

    static let exampleCorrect = GrammarCheckResult(
        mistake: "none",
        correctedSentence: "There was a long delay before the train arrived."
    )

    static let exampleMistake = GrammarCheckResult(
        mistake: "\"My brother go\" should be \"My brother goes\".",
        correctedSentence: "My brother goes to the market every morning."
    )
}
