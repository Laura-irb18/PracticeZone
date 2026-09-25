import FoundationModels

@Generable
enum PartOfSpeech: CaseIterable {
    case noun
    case verb
    case phrasalVerb
    case adjective
    case adverb
    case preposition
    case other

    init?(label: String) {
        guard let match = Self.allCases.first(where: { $0.label == label }) else { return nil }
        self = match
    }

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
