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
                        LabeledContent {
                            Text("\(group.items.count)")
                        } label: {
                            Label {
                                Text(group.name)
                            } icon: {
                                GroupIconBadge(iconName: group.iconName, color: group.color.color)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteGroups)
            }
            .scrollDisabled(wordGroups.isEmpty)
            .navigationTitle("Library")
            .overlay {
                if wordGroups.isEmpty {
                    ContentUnavailableView {
                        Label("Your Library Is Empty", systemImage: "rectangle.stack")
                    } description: {
                        Text("Create a group to start adding words.")
                    } actions: {
                        Button {
                            isPresentingNewGroup = true
                        } label: {
                            Text("New Group")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Group", systemImage: "plus") {
                        isPresentingNewGroup = true
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
    }
}

#Preview {
    WordGroupsView()
        .modelContainer(for: WordGroup.self, inMemory: true)
}
#Preview("With groups") {
    let container = try! ModelContainer(for: WordGroup.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    container.mainContext.insert(WordGroup(name: "Travel", groupDescription: "Words for booking trips", iconName: "airplane", color: .blue))
    container.mainContext.insert(WordGroup(name: "Food", iconName: "fork.knife", color: .orange))
    container.mainContext.insert(WordGroup(name: "Work", iconName: "briefcase.fill", color: .purple))
    return WordGroupsView()
        .modelContainer(container)
}

