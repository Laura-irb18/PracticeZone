import Foundation

/// Builds a shuffled set of exam questions for a word group: half multiple choice
/// (matching a definition to its word, with distractor words from the same group)
/// and half production (writing a sentence, graded by `PracticeFeedbackGenerator`).
///
/// Groups larger than `maxQuestionsPerExam` are capped to keep an exam a reasonable
/// length — not because of any model context-window limit (each production question
/// grades in its own short-lived session, so the cap is purely about exam duration).
/// When capping, the least recently examined words are prioritized, so repeated
/// exams eventually cover every word in a large group instead of relying on chance.
enum ExamGenerator {
    static let maxQuestionsPerExam = 10

    static func makeQuestions(for group: WordGroup) -> [ExamQuestion] {
        let usableItems = group.items.filter { !$0.meanings.isEmpty }
        guard !usableItems.isEmpty else { return [] }

        let prioritizedItems = usableItems.sorted {
            ($0.lastExaminedAt ?? .distantPast) < ($1.lastExaminedAt ?? .distantPast)
        }
        let selectedItems = Array(prioritizedItems.prefix(maxQuestionsPerExam)).shuffled()

        let multipleChoiceCount = Int((Double(selectedItems.count) / 2).rounded())
        let multipleChoiceItems = selectedItems.prefix(multipleChoiceCount)
        let productionItems = selectedItems.dropFirst(multipleChoiceCount)
        let allWords = usableItems.map(\.word)

        let multipleChoiceQuestions = multipleChoiceItems.map { item in
            multipleChoiceQuestion(for: item, allWords: allWords)
        }
        let productionQuestions = productionItems.map { item in
            ExamQuestion(item: item, word: item.word, meaning: item.meaningSummary, kind: .production)
        }

        return (multipleChoiceQuestions + productionQuestions).shuffled()
    }

    private static func multipleChoiceQuestion(for item: VocabularyItem, allWords: [String]) -> ExamQuestion {
        let distractors = allWords.filter { $0 != item.word }.shuffled().prefix(3)
        let options = ([item.word] + distractors).shuffled()
        return ExamQuestion(item: item, word: item.word, meaning: item.primaryMeaning, kind: .multipleChoice(options: options))
    }
}
