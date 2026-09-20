import Foundation
import SwiftData

@Model
final class Meaning {
    var definition: String
    var partOfSpeech: String
    var context: String
    var order: Int
    var item: VocabularyItem?

    init(definition: String, partOfSpeech: String, context: String, order: Int, item: VocabularyItem? = nil) {
        self.definition = definition
        self.partOfSpeech = partOfSpeech
        self.context = context
        self.order = order
        self.item = item
    }
}
