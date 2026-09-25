import SwiftUI
import SwiftData

struct WordGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var group: WordGroup

    @State private var isEditingGroup = false
    @State private var isAddingWord = false

    var body: some View {
        List {
            Section {
                GroupDetailHeader(
                    name: group.name,
                    iconName: group.iconName,
                    color: group.color.color,
                    wordCount: group.items.count,
                    groupDescription: group.groupDescription
                )
            }

            if group.items.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label("No words yet", systemImage: "text.book.closed")
                    } description: {
                        Text("Add your first word to start practicing.")
                    } 
                }
            } else {
                Section("Words") {
                    ForEach(group.sortedItems) { item in
                        NavigationLink {
                            WordDetailView(item: item)
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
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Word", systemImage: "plus") {
                    isAddingWord = true
                }
//                .buttonStyle(.glassProminent)
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isEditingGroup = true
                }
            }
        
        }
        .sheet(isPresented: $isAddingWord) {
            VocabularyItemEditorSheet(group: group, item: nil)
        }
        .sheet(isPresented: $isEditingGroup) {
            WordGroupEditorSheet(group: group)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let items = group.sortedItems
        for index in offsets {
            modelContext.delete(items[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    let container = try! ModelContainer(for: WordGroup.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let group = WordGroup(name: "Travel", groupDescription: "Words for booking trips", iconName: "airplane")
    container.mainContext.insert(group)
    let item = VocabularyItem(word: "reservation", friendlyPronunciation: "reser-vei-shon", wordGroup: group)
    item.meanings = [
        
    ]
    group.items = []
    return NavigationStack {
        WordGroupDetailView(group: group)
    }
    .modelContainer(container)
}
