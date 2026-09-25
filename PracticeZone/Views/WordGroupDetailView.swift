import SwiftUI
import SwiftData

struct WordGroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var group: WordGroup

    @State private var isEditingGroup = false
    @State private var isAddingWord = false
    @State private var isConfirmingDelete = false

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
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Word", systemImage: "plus") {
                    isAddingWord = true
                }
                .buttonStyle(.glassProminent)
            }
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis") {
                    Button("Edit Group", systemImage: "pencil") {
                        isEditingGroup = true
                    }
                    Divider()
                    Button("Delete Group", systemImage: "trash", role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingWord) {
            AddVocabularyItemView(group: group)
        }
        .sheet(isPresented: $isEditingGroup) {
            WordGroupEditorSheet(group: group)
        }
        .confirmationDialog("Delete \"\(group.name)\"?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete Group", role: .destructive) {
                dismiss()
                modelContext.delete(group)
            }
        } message: {
            Text("Its words and exam history will be deleted too.")
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(group.items[index])
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
