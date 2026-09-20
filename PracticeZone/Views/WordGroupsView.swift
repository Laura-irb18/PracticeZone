import SwiftUI
import SwiftData

struct WordGroupsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WordGroup.createdAt, order: .reverse) private var wordGroups: [WordGroup]

    @State private var isPresentingNewGroup = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(wordGroups) { group in
                    NavigationLink {
                        WordGroupDetailView(group: group)
                    } label: {
                        Label(group.name, systemImage: group.iconName)
                    }
                }
                .onDelete(perform: deleteGroups)
            }
            .navigationTitle("Word Groups")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingNewGroup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewGroup) {
                AddWordGroupSheet { name, description, icon in
                    createGroup(name: name, description: description, icon: icon)
                }
            }
        }
    }

    private func createGroup(name: String, description: String, icon: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        modelContext.insert(WordGroup(name: trimmedName, groupDescription: description, iconName: icon))
    }

    private func deleteGroups(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(wordGroups[index])
        }
    }
}

#Preview {
    WordGroupsView()
        .modelContainer(for: WordGroup.self, inMemory: true)
}
