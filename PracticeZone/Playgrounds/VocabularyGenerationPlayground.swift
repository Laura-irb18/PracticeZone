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

#Playground("1 · One meaning") {
    let session = LanguageModelSession(instructions: "You are an English vocabulary tutor for Spanish-speaking learners.")
    let response = try await session.respond(
        to: "Describe the most common sense of the English word \"work out\".",
        generating: DraftMeaning.self
    )
    let meaning = response.content
}
