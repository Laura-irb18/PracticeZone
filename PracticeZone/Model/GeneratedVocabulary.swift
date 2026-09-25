import FoundationModels

@Generable
struct GeneratedVocabulary {

    @Guide(description: "The English word being described, copied character for character from the request. Never substitute a different word.")
    var word: String

    @Guide(description: """
        The genuinely distinct senses of this word, most common first, explained in English \
        (never in Spanish). Two senses are distinct only when they mean something different, \
        not just a stylistic variation. If the word has only one real sense, return exactly \
        one entry. Never invent a second sense and never repeat a sense with a synonym. \
        Stop after at most 2 entries even if more senses exist.
        """, .minimumCount(1), .maximumCount(2))
    var meanings: [GeneratedMeaning]

    @Guide(description: """
        Natural English sentences using the word. The first sentence must use the first \
        sense in the meanings list; if there is a second sense, the second sentence must use it. \
        A third sentence, if included, should show another natural everyday use of the word.
        """, .minimumCount(2), .maximumCount(3))
    var examples: [GeneratedExample]
}

@Generable
struct GeneratedMeaning {

    @Guide(description: "The grammatical category this sense belongs to.")
    var partOfSpeech: PartOfSpeech

    @Guide(description: """
        A short English definition of this sense, 3 to 10 words, written for a learner. \
        Written entirely in English. Never a Spanish translation, and never just the word itself.
        """)
    var definition: String

    @Guide(description: """
        A short English label, at most six words, saying when this sense is used. \
        Written entirely in English. Example for "book" as a verb: "used to reserve a hotel or flight".
        """)
    var context: String
}

@Generable
enum PartOfSpeech: CaseIterable {
    case noun
    case verb
    case phrasalVerb
    case adjective
    case adverb
    case preposition
    case other

    var label: String {
        switch self {
        case .noun: "noun"
        case .verb: "verb"
        case .phrasalVerb: "phrasal verb"
        case .adjective: "adjective"
        case .adverb: "adverb"
        case .preposition: "preposition"
        case .other: "other"
        }
    }
}

@Generable
struct GeneratedExample {

    @Guide(description: "A natural English sentence, 6 to 12 words, that uses the word. Do not define the word inside the sentence.")
    var text: String

    @Guide(description: "The Spanish translation of the sentence: natural, idiomatic, neutral Latin American Spanish. Translate the meaning, not word by word.")
    var translation: String
}

extension GeneratedVocabulary {

    /// Picks a few-shot example that is not the word being generated, so the model can't copy it verbatim.
    static func fewShotExample(avoiding word: String) -> GeneratedVocabulary {
        word.lowercased() == "reservation" ? exampleForLight : exampleForReservation
    }

    static let exampleForReservation = GeneratedVocabulary(
        word: "reservation",
        meanings: [
            GeneratedMeaning(
                partOfSpeech: .noun,
                definition: "an arrangement to have something held for you in advance",
                context: "used when booking a table, room, or seat"
            )
        ],
        examples: [
            GeneratedExample(
                text: "We made a reservation for dinner at eight.",
                translation: "Hicimos una reserva para cenar a las ocho."
            ),
            GeneratedExample(
                text: "The hotel canceled our reservation by mistake.",
                translation: "El hotel canceló nuestra reserva por error."
            ),
            GeneratedExample(
                text: "You should call ahead to confirm the reservation.",
                translation: "Deberías llamar antes para confirmar la reserva."
            )
        ]
    )

    static let exampleForLight = GeneratedVocabulary(
        word: "light",
        meanings: [
            GeneratedMeaning(
                partOfSpeech: .noun,
                definition: "the brightness that lets you see things",
                context: "used when talking about lamps or sunshine"
            ),
            GeneratedMeaning(
                partOfSpeech: .adjective,
                definition: "not heavy; easy to lift or carry",
                context: "used to describe the weight of an object"
            )
        ],
        examples: [
            GeneratedExample(
                text: "Please turn off the light before you leave.",
                translation: "Por favor apaga la luz antes de irte."
            ),
            GeneratedExample(
                text: "This backpack is very light for its size.",
                translation: "Esta mochila es muy ligera para su tamaño."
            ),
            GeneratedExample(
                text: "The room felt bright and full of light.",
                translation: "La habitación se sentía brillante y llena de luz."
            )
        ]
    )
}
