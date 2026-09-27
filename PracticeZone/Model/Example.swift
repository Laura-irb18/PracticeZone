import Foundation
import SwiftData

@Model
final class Example {
    var text: String
    var translation: String
    var order: Int
    var meaning: Meaning?

    init(text: String, translation: String, order: Int, meaning: Meaning? = nil) {
        self.text = text
        self.translation = translation
        self.order = order
        self.meaning = meaning
    }
}
