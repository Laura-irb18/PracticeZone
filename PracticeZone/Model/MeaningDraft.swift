import Foundation

struct MeaningDraft: Identifiable {
    let id = UUID()
    var definition = ""
    var translation = ""
    var partOfSpeech: PartOfSpeech?
    var examples: [ExampleDraft] = []
    var isGenerated = false
}
