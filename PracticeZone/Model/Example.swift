import Foundation
import SwiftData

@Model
final class Example {
    var text: String
    var friendlyPronunciation: String
    var translation: String
    var item: VocabularyItem?

    init(text: String, friendlyPronunciation: String, translation: String, item: VocabularyItem? = nil) {
        self.text = text
        self.friendlyPronunciation = friendlyPronunciation
        self.translation = translation
        self.item = item
    }
}
