import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class WordGroupEditorViewModel {
    var name = ""
    var groupDescription = ""
    var color: GroupColor = .blue
    var iconName = "book.fill"

    private var group: WordGroup?

    var isEditing: Bool { group != nil }

    var canSave: Bool { !trimmedName.isEmpty }

    func load(_ group: WordGroup?) {
        self.group = group
        guard let group else { return }
        name = group.name
        groupDescription = group.groupDescription
        color = group.color
        iconName = group.iconName
    }

    var saveError: Error?

    /// Returns whether the group was saved, so the view only closes on success.
    func save(in modelContext: ModelContext) -> Bool {
        guard canSave else { return false }
        let trimmedDescription = groupDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if let group {
            group.name = trimmedName
            group.groupDescription = trimmedDescription
            group.color = color
            group.iconName = iconName
        } else {
            modelContext.insert(WordGroup(name: trimmedName, groupDescription: trimmedDescription, iconName: iconName, color: color))
        }
        do {
            try modelContext.save()
            return true
        } catch {
            // Undo the pending changes so a retry starts from what is saved.
            modelContext.rollback()
            saveError = error
            return false
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
