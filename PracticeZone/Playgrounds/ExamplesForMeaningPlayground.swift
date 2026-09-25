import FoundationModels
import Playgrounds

@Generable
private struct DraftExamples {
    @Guide(description: "Natural English sentences, 6 to 12 words, that use the expression with exactly the given sense.", .count(2))
    var examples: [GeneratedExample]
}

#Playground("5 · Examples for a meaning") {
    let session = LanguageModelSession(instructions: """
        You are an English vocabulary tutor for Spanish-speaking learners. \
        You write example sentences that use an English word or phrasal verb with one specific sense, \
        each with a natural translation into neutral Latin American Spanish.
        """)
    let response = try await session.respond(
        to: """
            English phrasal verb or word: "work out"
            Sense: To exercise, especially at a gym.
            Write sentences that use "work out" with exactly this sense.
            """,
        generating: DraftExamples.self,
        options: GenerationOptions(samplingMode: .greedy)
    )
    let examples = response.content.examples
}
