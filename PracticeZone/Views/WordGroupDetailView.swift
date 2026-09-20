import SwiftUI
import SwiftData

struct WordGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var group: WordGroup

    var body: some View {
        List {
            if !group.groupDescription.isEmpty {
                Section {
                    Text(group.groupDescription)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Words") {
                ForEach(group.items) { item in
                    NavigationLink {
                        PracticeWordView(item: item)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.word)
                                .font(.headline)
                            Text(item.primaryMeaning)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    AddVocabularyItemView(group: group)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(group.items[index])
        }
    }
}
