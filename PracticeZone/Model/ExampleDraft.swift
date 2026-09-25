import Foundation

struct ExampleDraft: Identifiable {
    let id = UUID()
    var text = ""
    var translation = ""
    var isGenerated = false
}
