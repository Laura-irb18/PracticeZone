import FoundationModels

@Generable
struct MeaningCheckResult {

    @Guide(description: "true if the target word is used with a natural, correct common English meaning, whether or not it matches the example meaning given.")
    var isCorrect: Bool

    @Guide(description: "One short sentence: which meaning of the word is used in the sentence.")
    var senseUsed: String
}

extension MeaningCheckResult {

    static let exampleGivenSense = MeaningCheckResult(
        isCorrect: true,
        senseUsed: "\"delay\" is used as a noun meaning a wait before something happens, matching the given meaning."
    )

    static let exampleOtherSense = MeaningCheckResult(
        isCorrect: true,
        senseUsed: "\"match\" is used to mean a small stick for lighting fires, a different but equally valid common sense from the sports-game meaning given."
    )

    static let exampleWrongSense = MeaningCheckResult(
        isCorrect: false,
        senseUsed: "\"borrow\" always means to take something temporarily; the sentence uses it to mean giving, which is \"lend\" instead."
    )
}
