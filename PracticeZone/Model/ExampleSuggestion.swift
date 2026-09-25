import FoundationModels

@Generable
struct ExampleSuggestion {
    @Guide(description: "A natural English sentence, 6 to 12 words, that uses the word with exactly the given sense. Do not define the word inside the sentence.")
    var text: String

    @Guide(description: "The Spanish translation of the sentence: natural, idiomatic, neutral Latin American Spanish. Translate the meaning, not word by word.")
    var translation: String
}
