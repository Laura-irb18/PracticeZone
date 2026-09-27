import SwiftUI
import SwiftData

struct WordGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var group: WordGroup

    @State private var isEditingGroup = false
    @State private var isAddingWord = false

    var body: some View {
        List {
            if !group.items.isEmpty {
                DetailHeader(iconName: group.iconName, color: group.color.color) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.name)
                            .font(.title2.bold())
                        if !group.groupDescription.isEmpty {
                            Text(group.groupDescription)
                                .foregroundStyle(.secondary)
                        }
                    }
                } details: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("^[\(group.items.count) word](inflect: true)")
                        Text("Created \(group.createdAt, format: .dateTime.month().day())")
                    }
                } action: {
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

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
        .scrollDisabled(group.items.isEmpty)
        .overlay {
            if group.items.isEmpty {
                ContentUnavailableView {
                    Label("No Words Yet", systemImage: "text.book.closed")
                } description: {
                    Text("Add your first word to start practicing.")
                } actions: {
                    Button {
                        isAddingWord = true
                    } label: {
                        Text("Add Word")
                            .fontWeight(.bold)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                }
            }
        }
        // Always set: VoiceOver announces it and the back button menu lists it.
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Word", systemImage: "plus") {
                    isAddingWord = true
                }
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
