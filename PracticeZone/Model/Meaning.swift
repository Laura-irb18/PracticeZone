import Foundation
import SwiftData

@Model
final class Meaning {
    var definition: String
    var translation: String
    var partOfSpeech: String
    var order: Int
    var item: VocabularyItem?

    @Relationship(deleteRule: .cascade, inverse: \Example.meaning)
    var examples: [Example]

    init(definition: String, translation: String = "", partOfSpeech: String, order: Int, examples: [Example] = [], item: VocabularyItem? = nil) {
        self.definition = definition
        self.translation = translation
        self.partOfSpeech = partOfSpeech
        self.order = order
        self.examples = examples
        self.item = item
    }

    var sortedExamples: [Example] {
        examples.sorted { $0.order < $1.order }
    }
}
