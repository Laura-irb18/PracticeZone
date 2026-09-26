import SwiftData
import Testing
@testable import PracticeZone

struct VocabularyItemEditorViewModelTests {
    let container: ModelContainer
    let group: WordGroup

    init() throws {
        container = try .inMemory()
        group = WordGroup(name: "Travel")
        container.mainContext.insert(group)
    }

    @Test func `A new word is saved in its group with its meanings in order`() throws {
        let viewModel = VocabularyItemEditorViewModel()
        viewModel.word = " travel "
        viewModel.friendlyPronunciation = " TRA-vel "
        viewModel.meanings[0].definition = " to go to another place "
        viewModel.meanings[0].translation = "viajar"
        viewModel.meanings[0].partOfSpeech = .verb
        viewModel.meanings[0].examples = [ExampleDraft(text: " I travel a lot. ", translation: "Viajo mucho."), ExampleDraft()]
        viewModel.addMeaning()
        viewModel.meanings[1].definition = "a journey"

        #expect(viewModel.save(to: group, in: container.mainContext))

        let item = try #require(group.items.first)
        #expect(group.items.count == 1)
        #expect(item.word == "travel")
        #expect(item.friendlyPronunciation == "TRA-vel")
        #expect(item.sortedMeanings.map(\.definition) == ["to go to another place", "a journey"])
        #expect(item.sortedMeanings.map(\.order) == [0, 1])
        #expect(item.sortedMeanings.map(\.partOfSpeech) == ["verb", "other"])
        #expect(item.sortedMeanings[0].sortedExamples.map(\.text) == ["I travel a lot."])
    }

    @Test func `Editing a word replaces its meanings and keeps its practice`() throws {
        let item = VocabularyItem(word: "run", friendlyPronunciation: "")
        item.meanings = [Meaning(definition: "to move fast", partOfSpeech: "verb", order: 0)]
        item.practiceAttempts = [PracticeAttempt(sentence: "I run every day.", isCorrect: true, feedback: "")]
        group.items.append(item)
        try container.mainContext.save()
        let viewModel = VocabularyItemEditorViewModel()

        viewModel.load(item)
        #expect(viewModel.isEditing)
        #expect(viewModel.meanings.map(\.definition) == ["to move fast"])

        viewModel.meanings[0].definition = "to manage a business"
        #expect(viewModel.save(to: group, in: container.mainContext))

        #expect(group.items.count == 1)
        #expect(item.meanings.map(\.definition) == ["to manage a business"])
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Meaning>()) == 1)
        #expect(item.practiceAttempts.count == 1)
    }

    @Test func `A word needs the word and every definition to be saved`() {
        let viewModel = VocabularyItemEditorViewModel()
        viewModel.meanings[0].definition = "to go"
        #expect(!viewModel.canSave)

        viewModel.word = "go"
        #expect(viewModel.canSave)

        viewModel.addMeaning()
        #expect(!viewModel.canSave)
    }

    @Test func `A word has at most five meanings and three examples each`() {
        let viewModel = VocabularyItemEditorViewModel()

        for _ in 0..<10 {
            viewModel.addMeaning()
            viewModel.addExample(to: viewModel.meanings[0])
        }

        #expect(viewModel.meanings.count == 5)
        #expect(!viewModel.canAddMeaning)
        #expect(viewModel.meanings[0].examples.count == 3)
    }

    @Test func `The first meaning can't be removed`() throws {
        let viewModel = VocabularyItemEditorViewModel()
        viewModel.addMeaning()

        viewModel.removeMeaning(viewModel.meanings[0])
        try #require(viewModel.meanings.count == 2)

        viewModel.removeMeaning(viewModel.meanings[1])
        #expect(viewModel.meanings.count == 1)
    }
}
