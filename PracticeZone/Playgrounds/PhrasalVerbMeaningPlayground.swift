import FoundationModels
import Playgrounds

@Generable
private struct DraftMeaning {
    @Guide(description: "The grammatical category of this sense.")
    var partOfSpeech: PartOfSpeech

    @Guide(description: "A short English definition of this sense for a learner, 5 to 15 words.")
    var definition: String

    @Guide(description: "A short Spanish translation of this sense, 1 to 4 words.")
    var spanishGloss: String
}

#Playground("2 · Phrasal verb meaning") {
    let session = LanguageModelSession(instructions: """
        You are an English vocabulary tutor for Spanish-speaking learners. \
        When the word is a phrasal verb or an expression of several words, \
        describe the whole expression, never the meaning of its first word alone.
        """)
    let response = try await session.respond(
        to: "Describe the most common sense of the English phrasal verb or word \"work out\".",
        generating: DraftMeaning.self,
        options: GenerationOptions(samplingMode: .greedy)
    )
    let meaning = response.content
}
