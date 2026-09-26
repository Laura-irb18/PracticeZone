import Testing
@testable import PracticeZone

struct PartOfSpeechTests {

    @Test(arguments: PartOfSpeech.allCases)
    func `Every part of speech is found again by its label`(partOfSpeech: PartOfSpeech) {
        #expect(PartOfSpeech(label: partOfSpeech.label) == partOfSpeech)
    }

    @Test func `Unknown label gives no part of speech`() {
        #expect(PartOfSpeech(label: "conjunction") == nil)
    }
}
