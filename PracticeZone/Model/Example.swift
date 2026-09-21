import Foundation
import SwiftData

@Model
final class Example {
    var text: String
    var translation: String
    var item: VocabularyItem?

    init(text: String, translation: String, item: VocabularyItem? = nil) {
        self.text = text
        self.translation = translation
        self.item = item
    }
}
