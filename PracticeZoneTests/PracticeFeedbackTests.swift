import Foundation
import Testing
@testable import PracticeZone

struct PracticeFeedbackTests {

    @Test(arguments: [
        ("I traveled to Rome last summer.", "I traveled to Rome last summer."),
        ("last summer we traveled", "Last summer, we traveled."),
        ("She  agrees   with me.", "She agrees with me."),
        ("I arrived home late.", ""),
    ])
    func `Sentence counts as correct when only case, punctuation or spacing change`(sentence: String, corrected: String) {
        let feedback = PracticeFeedback(sentence: sentence, grammar: GrammarCheckResult(correctedSentence: corrected))

        #expect(feedback.isCorrect)
        #expect(feedback.correctedSentences.isEmpty)
    }

    @Test(arguments: [
        ("She agree with me.", "She agrees with me."),
        ("I travel to Rome last summer.", "I traveled to Rome last summer."),
        ("He don't like coffee.", "  He doesn't like coffee.  "),
    ])
    func `Sentence counts as incorrect when a word changes`(sentence: String, corrected: String) {
        let feedback = PracticeFeedback(sentence: sentence, grammar: GrammarCheckResult(correctedSentence: corrected))

        #expect(!feedback.isCorrect)
        #expect(feedback.correctedSentences == [corrected.trimmingCharacters(in: .whitespaces)])
    }

    @Test func `Incorrect sentence asks to check the correction`() {
        let feedback = PracticeFeedback(sentence: "She agree.", grammar: GrammarCheckResult(correctedSentence: "She agrees."))

        #expect(feedback.feedback == "Check the corrected sentence below.")
    }
}
