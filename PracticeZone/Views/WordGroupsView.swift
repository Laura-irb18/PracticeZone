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
                        Label {
                            Text(group.name)
                        } icon: {
                            Image(systemName: group.iconName)
                                .foregroundStyle(group.color.color)
                        }
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
                WordGroupEditorSheet(group: nil)
            }
        }
    }

    private func deleteGroups(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(wordGroups[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    WordGroupsView()
        .modelContainer(for: WordGroup.self, inMemory: true)
}
