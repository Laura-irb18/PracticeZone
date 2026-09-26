import SwiftData
import Testing
@testable import PracticeZone

struct WordGroupEditorViewModelTests {
    let container: ModelContainer

    init() throws {
        container = try .inMemory()
    }

    @Test func `A new group is saved with trimmed text`() throws {
        let viewModel = WordGroupEditorViewModel()
        viewModel.name = "  Travel  "
        viewModel.groupDescription = " Trips abroad "
        viewModel.color = .green
        viewModel.iconName = "airplane"

        #expect(viewModel.save(in: container.mainContext))

        let groups = try container.mainContext.fetch(FetchDescriptor<WordGroup>())
        let group = try #require(groups.first)
        #expect(groups.count == 1)
        #expect(group.name == "Travel")
        #expect(group.groupDescription == "Trips abroad")
        #expect(group.color == .green)
        #expect(group.iconName == "airplane")
    }

    @Test func `Editing a group changes it instead of adding another`() throws {
        let group = WordGroup(name: "Food")
        container.mainContext.insert(group)
        let viewModel = WordGroupEditorViewModel()

        viewModel.load(group)
        #expect(viewModel.isEditing)
        #expect(viewModel.name == "Food")

        viewModel.name = "Cooking"
        #expect(viewModel.save(in: container.mainContext))

        #expect(try container.mainContext.fetchCount(FetchDescriptor<WordGroup>()) == 1)
        #expect(group.name == "Cooking")
    }

    @Test(arguments: ["", "   "])
    func `A group without a name isn't saved`(name: String) throws {
        let viewModel = WordGroupEditorViewModel()
        viewModel.name = name

        #expect(!viewModel.canSave)
        #expect(!viewModel.save(in: container.mainContext))
        #expect(try container.mainContext.fetchCount(FetchDescriptor<WordGroup>()) == 0)
    }
}
