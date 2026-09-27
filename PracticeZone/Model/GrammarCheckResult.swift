import FoundationModels

@Generable
struct GrammarCheckResult {

    @Guide(description: "The sentence with its grammar and spelling mistakes fixed. The same sentence if it is correct.")
    var correctedSentence: String
}
