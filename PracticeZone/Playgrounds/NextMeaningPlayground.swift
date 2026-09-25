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

@Generable
private struct DraftNextMeaning {
    @Guide(description: "True only if a dictionary lists another sense of the expression that is not in the given list.")
    var hasAnotherSense: Bool

    @Guide(description: "The new sense. Leave it out when hasAnotherSense is false.")
    var meaning: DraftMeaning?
}

#Playground("3 · Next meaning") {
    let session = LanguageModelSession(instructions: """
        You are an English vocabulary tutor for Spanish-speaking learners. \
        When the word is a phrasal verb or an expression of several words, \
        describe the whole expression, never the meaning of its first word alone.
        """)
    let response = try await session.respond(
        to: """
            English phrasal verb or word: "work out"
            Senses already listed:
            - To solve a problem or calculate a result step by step.
            - To arrange or organize something in a specific way.
            Give another dictionary sense that is genuinely different from these, if one exists.
            """,
        generating: DraftNextMeaning.self,
        options: GenerationOptions(samplingMode: .greedy)
    )
    let next = response.content
}
