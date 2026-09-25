import FoundationModels

@Generable
struct MeaningCompletion {
    @Guide(description: "The Spanish equivalent of the word in this sense, as a Spanish speaker would say it. Never a translation of the definition.")
    var translation: String

    @Guide(description: "The grammatical category of this sense. Use phrasalVerb only when the word is a verb followed by a particle.")
    var partOfSpeech: PartOfSpeech
}
